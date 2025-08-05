#include "networkmanager.h"
#include "chatmessage.h"
#include "databasemanager.h"
// #include "friendgroup.h" // 包含完整定义
#include "friendmodel.h"
#include "jsonparse.h"
#include "tcpmanager.h"

#include <QDateTime>
#include <QFile>
#include <QJsonObject>
#include <QJsonDocument>
#include <QThread>
#include <QDebug>

/**
 * @brief 获取 NetworkManager 的全局唯一实例。
 * @return NetworkManager 的实例指针。
 */
NetworkManager *NetworkManager::instance()
{
    static NetworkManager networkManager;
    return &networkManager;
}

/**
 * @brief NetworkManager的构造函数。
 *
 * 在此构造函数中，会创建一个新的QThread，并将TcpManager实例移动到该线程中。
 * 这样可以确保所有的TCP网络操作都在一个独立的后台线程中执行，避免阻塞UI主线程。
 * @param parent 父QObject对象，默认为nullptr。
 */
NetworkManager::NetworkManager(QObject *parent)
    : QObject(parent), m_mode(NetworkMode::Internet)
{
    QThread *thread = new QThread;
    m_tcpManager = new TcpManager;

    // 当线程结束时，自动删除线程对象
    connect(thread, &QThread::finished, thread, &QThread::deleteLater);

    // 连接来自TcpManager的信号到本类的槽函数或信号
    connect(m_tcpManager, &TcpManager::checked, this, &NetworkManager::onLogined);
    connect(m_tcpManager, &TcpManager::infoGot, this, &NetworkManager::onInfoGot);
    connect(m_tcpManager, &TcpManager::loginError, this, &NetworkManager::loginError);
    connect(m_tcpManager, &TcpManager::chatMessageSent, this, [this](const QString &username, ChatMessage *chatMessage)
            {
        // 消息成功发送后，请求数据库管理器将其存入本地数据库
        m_databaseManager->insertChatMessage(username, chatMessage); });
    connect(m_tcpManager, &TcpManager::hasNewMessage, this, &NetworkManager::disposeNewMessage);

    // 将TcpManager对象移动到新创建的线程
    m_tcpManager->moveToThread(thread);
    // 启动线程的事件循环
    thread->start();
}

/**
 * @brief NetworkManager的析构函数。
 *
 * 清理动态分配的资源，如m_jsonParser。
 */
NetworkManager::~NetworkManager()
{
    if (m_jsonParser)
    {
        delete m_jsonParser;
        m_jsonParser = nullptr;
    }
}

/**
 * @brief 设置网络模式。
 * @param mode 新的网络模式。
 */
void NetworkManager::setMode(NetworkMode::Mode mode)
{
    if (mode != m_mode)
    {
        m_mode = mode;
        emit modeChanged();
    }
}

/**
 * @brief 从JSON解析器获取当前登录用户的信息。
 * @return ItemInfo 指针。
 */
ItemInfo *NetworkManager::getUserInfo()
{
    return m_jsonParser ? m_jsonParser->userInfo() : nullptr;
}

/**
 * @brief 请求TCP管理器开始校验登录信息。
 */
void NetworkManager::checkLoginInfo()
{
    // 通过信号触发在TcpManager线程中执行
    m_tcpManager->checkLoginInfo();
}

/**
 * @brief 使用JSON解析器创建好友列表和分组。
 * @param friendGroup 用于存放好友分组的模型指针。
 * @param friendList 用于存放好友列表的映射指针。
 */
void NetworkManager::createFriend(FriendGroup *friendGroup, QMap<QString, ItemInfo *> *friendList)
{
    if (m_jsonParser)
    {
        m_jsonParser->createFriend(friendGroup, friendList);
    }
}

/**
 * @brief 请求连接到服务器。
 */
void NetworkManager::connectServer()
{
    m_tcpManager->requestNewConnection();
}

/**
 * @brief 取消登录过程（即断开与服务器的连接）。
 */
void NetworkManager::cancelLogin()
{
    m_tcpManager->abortConnection();
}

/**
 * @brief 发送更新当前用户信息的请求到服务器。
 */
void NetworkManager::updateInfomation()
{
    FriendInfo *userInfo = qobject_cast<FriendInfo *>(ChatManager::instance()->userInfo());
    if (userInfo && m_jsonParser)
    {
        QByteArray data = m_jsonParser->infoToJson(userInfo);
        m_tcpManager->sendMessage(MT_USERINFO, MO_UPLOAD, SERVER_ID, data);
    }
}

/**
 * @brief 发送注册新账户的请求。
 * @param json 包含新用户信息的JSON字符串。
 */
void NetworkManager::registerUser(const QString &json)
{
    m_tcpManager->requestNewConnection();
    m_tcpManager->sendMessage(MT_REGISTER, MO_UPLOAD, SERVER_ID, json.toUtf8());
}

/**
 * @brief 发送获取指定用户信息的请求。
 * @param username 要查询的用户名。
 */
void NetworkManager::requestUserInfo(const QString &username)
{
    m_tcpManager->sendMessage(MT_SEARCH, MO_DOWNLOAD, SERVER_ID, username.toLocal8Bit());
}

/**
 * @brief 发送添加好友的请求。
 * @param username 目标好友的用户名。
 */
void NetworkManager::requestAddFriend(const QString &username)
{
    m_tcpManager->sendMessage(MT_ADDFRIEND, MO_UPLOAD, username.toLatin1(), ADDFRIEND);
}

/**
 * @brief 发送同意添加好友的响应。
 * @param username 发起好友请求的用户名。
 */
void NetworkManager::acceptFriendRequest(const QString &username)
{
    m_tcpManager->sendMessage(MT_ADDFRIEND, MO_UPLOAD, username.toLatin1(), ADD_SUCCESS);
}

/**
 * @brief 发送拒绝添加好友的响应。
 * @param username 发起好友请求的用户名。
 */
void NetworkManager::rejectFriendRequest(const QString &username)
{
    m_tcpManager->sendMessage(MT_ADDFRIEND, MO_UPLOAD, username.toLatin1(), ADD_FAILURE);
}

/**
 * @brief 发送用户在线状态变更的消息。
 * @param status 新的在线状态。
 */
void NetworkManager::sendStateChange(Chat::ChatStatus status)
{
    m_tcpManager->sendMessage(MT_STATECHANGE, MO_UPLOAD, SERVER_ID, QByteArray::number(status));
}

/**
 * @brief 发送一条聊天消息。
 * @param type 消息类型（如文本、图片等）。
 * @param receiver 接收方的用户名。
 * @param chatMessage 聊天消息对象指针。
 */
void NetworkManager::sendChatMessage(msg_t type, const QString &receiver, ChatMessage *chatMessage)
{
    m_tcpManager->sendChatMessage(type, receiver.toLatin1(), chatMessage);
}

/**
 * @brief 响应TCP管理器登录验证完成的槽函数。
 *
 * 如果验证通过，则向服务器请求完整的用户信息；如果失败，则发出登录错误信号。
 * @param ok 验证是否通过。
 */
void NetworkManager::onLogined(bool ok)
{
    if (ok)
    {
        qDebug() << "登录验证通过，正在请求用户信息...";
        // 请求下载用户信息
        m_tcpManager->sendMessage(MT_USERINFO, MO_DOWNLOAD, SERVER_ID, USERINFO);
    }
    else
    {
        qDebug() << "登录验证不通过";
        emit loginError("密码不正确\n"
                        "你输入的帐号或密码不正确，你要找回密码吗？\n"
                        "如果你的密码丢失或遗忘，可以点击找回密码。");
    }
}

/**
 * @brief 响应TCP管理器获取到用户信息JSON的槽函数。
 *
 * 解析收到的用户信息JSON。如果成功，则初始化JSON解析器、数据库、开始心跳，
 * 并发出 loginFinshed(true) 信号，标志整个登录流程成功。如果失败，则发出
 * loginFinshed(false) 信号。
 * @param infoJson 包含用户信息的JSON数据。
 */
void NetworkManager::onInfoGot(const QByteArray &infoJson)
{
    QJsonParseError error;
    QJsonDocument myInfo = QJsonDocument::fromJson(infoJson, &error);
    if (!myInfo.isNull() && (error.error == QJsonParseError::NoError))
    {
        m_jsonParser = new JsonParser(myInfo); // 创建json解析器
        m_tcpManager->startHeartbeat();        // 开始心跳检测
        m_databaseManager = DatabaseManager::instance();
        m_databaseManager->initDatabase(); // 初始化本地数据库
        emit loginFinshed(true);           // 登录流程全部完成
    }
    else
    {
        qDebug() << "用户信息数据初始化不成功：" << error.errorString();
        emit loginFinshed(false);
    }
}

/**
 * @brief 处理从TCP/UDP管理器收到的所有新消息的中央分发槽函数。
 *
 * 根据消息类型(type)进行分发，调用不同的处理逻辑或发出不同的信号。
 * @param sender 消息发送方的用户名。
 * @param type 消息类型。
 * @param data 消息数据。
 */
void NetworkManager::disposeNewMessage(const QString &sender, msg_t type, const QByteArray &data)
{
    // 获取发送方的好友信息对象，以便更新其状态
    ItemInfo *info = ChatManager::instance()->createFriendInfo(sender);

    switch (type)
    {
    case MT_STATECHANGE:
        if (info)
        {
            FriendInfo *friendInfo = qobject_cast<FriendInfo *>(info);
            if (friendInfo)
                friendInfo->setChatStatus(int(data.toInt()));
        }
        break;

    case MT_SEARCH:
    {
        if (m_jsonParser)
        {
            FriendInfo *newInfo = qobject_cast<FriendInfo *>(m_jsonParser->jsonToInfo(data));
            emit hasSearchResult(newInfo);
        }
        break;
    }
    case MT_SHAKE:
        if (info)
        {
            // 暂时没有addShakeMessage方法，此行为未实现
            // info->addShakeMessage(sender);
            emit hasNewShake(sender);
        }
        break;

    case MT_TEXT:
        if (info)
        {
            // 暂时没有addTextMessage方法，此行为未实现
            // info->addTextMessage(sender, QString::fromLocal8Bit(data));
            emit hasNewText(sender, QString::fromLocal8Bit(data));
        }
        break;

    case MT_ADDFRIEND:
    {
        QString addStr = QString::fromLocal8Bit(data);
        if (addStr == ADDFRIEND)
        {
            emit hasFriendRequest(sender);
        }
        else if (addStr == ADD_FAILURE)
        {
            // 好友请求被拒绝，可以在此处理UI提示
        }
        else // data中是新好友的完整信息
        {
            if (m_jsonParser)
            {
                ItemInfo *newInfo = m_jsonParser->jsonToInfo(data);
                ChatManager::instance()->addFriendToGroup("我的好友", newInfo);
            }
        }
        break;
    }
    case MT_REGISTER:
    {
        QString result = QString::fromLocal8Bit(data);
        if (result == REG_SUCCESS)
            emit hasRegister("注册成功~\n可以登陆了哟~");
        else
            emit hasRegister("注册失败\n原因：已经存在。");
        break;
    }

    default:
        break;
    }
}