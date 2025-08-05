#include "chatmanager.h"
#include "databasemanager.h"
// #include "framelesswindow.h"
// #include "friendgroup.h"
#include "friendmodel.h"
#include "iteminfo.h"
#include "networkmanager.h"
// #include "systemtrayicon.h"

#include <QApplication>
#include <QDir>
#include <QQmlComponent>
#include <QQmlContext>
#include <QQmlApplicationEngine>
#include <QSettings>

/**
 * @brief 获取 ChatManager 的全局唯一实例。
 * @return ChatManager 的实例指针。
 */
ChatManager *ChatManager::instance()
{
    static ChatManager m_instance;
    return &m_instance;
}

/**
 * @brief 私有构造函数，实现单例模式。
 *
 * 初始化成员变量，并连接来自 NetworkManager 的信号。
 * @param parent 父QObject对象，默认为nullptr。
 */
ChatManager::ChatManager(QObject *parent)
    : QObject(parent), m_username(""), m_password(""), m_rememberPassword(false), m_autoLogin(false)
{
    m_networkManager = NetworkManager::instance();
    // 为 m_recentMessageID 创建一个 QQmlListProperty 代理，以便在 QML 中使用
    // 注意：这里传递的是 m_recentMessageID 的地址
    m_rencentMessageIDProxy = new QQmlListProperty<ItemInfo>(this, &m_recentMessageID);

    connect(m_networkManager, &NetworkManager::loginFinshed, this, &ChatManager::onLoginFinshed);
}

/**
 * @brief 析构函数。
 */
ChatManager::~ChatManager()
{
}

/**
 * @brief 初始化 ChatManager。
 *
 * 保存 QML 引擎指针，并读取初始设置。
 * @param qmlengine 全局的 QML 应用引擎指针。
 */
void ChatManager::initChatManager(QQmlApplicationEngine *qmlengine)
{
    m_qmlEngine = qmlengine;
    readSettings();
}

/**
 * @brief 动态加载并创建登录界面。
 *
 * 如果登录界面尚未创建，则使用 QQmlComponent 从 QRC 资源加载。
 * 同时创建并注册全局的系统托盘图标。
 * @return 如果加载成功返回 true，否则返回 false。
 */
bool ChatManager::loadLoginInterface()
{
    if (m_loginInterface.isNull())
    {
        QQmlComponent component(m_qmlEngine, QUrl("qrc:/qml/main.qml"));
        QObject *object = component.create();
        m_loginInterface = qobject_cast<FramelessWindow *>(object);
        if (m_loginInterface.isNull())
        {
            qDebug() << "载入登录界面失败";
            return false;
        }

        // 给应用一个全局的托盘图标
        QQmlComponent component1(m_qmlEngine, QUrl("qrc:/qml/MyWidgets/SystemTray.qml"), this);
        QObject *object1 = component1.create();
        m_systemTray = qobject_cast<SystemTrayIcon *>(object1);
        // 将托盘图标实例注册为 QML 上下文属性，以便在任何 QML 文件中通过名字 'systemTray' 访问
        // m_qmlEngine->rootContext()->setContextProperty("systemTray", m_systemTray);
    }

    return true;
}

/**
 * @brief 动态加载并创建主界面。
 *
 * 如果主界面尚未创建，则使用 QQmlComponent 从 QRC 资源加载。
 * 加载成功后，读取主界面相关的设置（如窗口位置、大小）并调用其 display 方法。
 * @return 如果加载成功返回 true，否则返回 false。
 */
bool ChatManager::loadMainInterface()
{
    if (m_mainInterface.isNull())
    {
        QQmlComponent component(m_qmlEngine, QUrl("qrc:/qml/MainInterface/MainInterface.qml"));
        QObject *object = component.create();
        m_mainInterface = qobject_cast<FramelessWindow *>(object);
        if (m_mainInterface.isNull())
        {
            qDebug() << "载入主界面失败";
            return false;
        }
        else
        {
            readSettings(); // 读取主界面的相关设置
            // QMetaObject::invokeMethod(m_mainInterface, "display", Qt::QueuedConnection);
        }
    }
    return true;
}

/**
 * @brief 获取当前的登录状态。
 * @return Chat::LoginStatus 枚举值。
 */
Chat::LoginStatus ChatManager::loginStatus() const
{
    return m_loginStatus;
}

/**
 * @brief 设置当前的登录状态，并根据新状态执行相应的操作。
 *
 * 这是一个核心的状态机函数，驱动着整个登录流程。
 * @param arg 新的登录状态。
 */
void ChatManager::setLoginStatus(Chat::LoginStatus arg)
{
    m_loginStatus = arg;
    emit loginStatusChanged(arg);

    switch (arg)
    {
    case Chat::Logging: // 状态：正在登录
        qDebug() << "登录中";
        m_networkManager->checkLoginInfo();
        break;

    case Chat::LoginSuccess: // 状态：登录成功（已验证）
        qDebug() << "登录成功";
        // 调用QML的quit()函数，以启动登录窗口的关闭动画
        QMetaObject::invokeMethod(m_loginInterface, "quit", Qt::QueuedConnection);
        break;

    case Chat::LoginFinished: // 状态：登录流程结束（已加载主界面）
        qDebug() << "登录完成";
        // 为当前登录的帐号创建一个专属的设置文件夹
        {
            QString path = QDir::homePath() + "/MChat/Settings/" + m_username;
            if (!QFile::exists(path))
            {
                QDir dir;
                dir.mkpath(path);
                dir.mkpath(path + "/headImage"); // 用于存放头像等资源
            }
        }
        loadMainInterface();
        // 主界面加载后，通知系统托盘创建消息提示窗口
        // QMetaObject::invokeMethod(m_systemTray, "createMessageTipWindow");
        break;

    case Chat::LoginFailure: // 状态：登录失败
        qDebug() << "登录失败";
        // 将状态重置为未登录，以便QML界面可以响应（例如停止加载动画）
        m_loginStatus = Chat::NoLogin;
        emit loginStatusChanged(m_loginStatus); // 再次发射信号通知QML状态已重置
        break;

    default:
        return;
    }
}

/**
 * @brief 获取用户的在线状态。
 * @return Chat::ChatStatus 枚举值。
 */
Chat::ChatStatus ChatManager::chatStatus() const
{
    return m_chatStatus;
}

/**
 * @brief 设置用户的在线状态。
 *
 * 如果用户已登录，此函数还会通知服务器状态已变更。
 * @param arg 新的在线状态。
 */
void ChatManager::setChatStatus(Chat::ChatStatus arg)
{
    if (arg != m_chatStatus)
    {
        m_chatStatus = arg;
        if (m_loginStatus == Chat::LoginFinished)
        {
            // 发送状态改变通知到服务器
            m_networkManager->sendStateChange(arg);
        }
        emit chatStatusChanged(arg);
    }
}

/**
 * @brief 获取是否记住密码的设置。
 */
bool ChatManager::rememberPassword() const
{
    return m_rememberPassword;
}

/**
 * @brief 设置是否记住密码。
 */
void ChatManager::setRememberPassword(bool arg)
{
    if (m_rememberPassword != arg)
    {
        m_rememberPassword = arg;
        emit rememberPasswordChanged(arg);
    }
}

/**
 * @brief 获取是否自动登录的设置。
 */
bool ChatManager::autoLogin() const
{
    return m_autoLogin;
}

/**
 * @brief 设置是否自动登录。
 */
void ChatManager::setAutoLogin(bool arg)
{
    if (m_autoLogin != arg)
    {
        m_autoLogin = arg;
        emit autoLoginChanged(arg);
    }
}

/**
 * @brief 获取当前显示的头像路径。
 */
QString ChatManager::headImage() const
{
    return m_headImage;
}

/**
 * @brief 设置当前显示的头像路径。
 */
void ChatManager::setHeadImage(const QString &arg)
{
    if (m_headImage != arg)
    {
        m_headImage = arg;
        emit headImageChanged(arg);
    }
}

/**
 * @brief 获取当前输入的用户名。
 */
QString ChatManager::username() const
{
    return m_username;
}

/**
 * @brief 设置当前输入的用户名。
 */
void ChatManager::setUsername(const QString &arg)
{
    if (m_username != arg)
    {
        m_username = arg;
        emit usernameChanged(arg);
    }
}

/**
 * @brief 获取当前输入的密码。
 */
QString ChatManager::password() const
{
    return m_password;
}

/**
 * @brief 设置当前输入的密码。
 */
void ChatManager::setPassword(const QString &arg)
{
    if (m_password != arg)
    {
        m_password = arg;
        emit passwordChanged(arg);
    }
}

/**
 * @brief 将一个好友信息添加到指定的分组中。
 * @param group 分组名称。
 * @param info 好友信息对象指针。
 */
void ChatManager::addFriendToGroup(const QString &group, ItemInfo *info)
{
    info->setParent(m_friendGroup);
    m_friendList[info->username()] = info;
    m_friendGroup->addFriendToGroup(group, info);
    emit friendGroupsChanged();
}

/**
 * @brief 获取当前登录用户的信息对象。
 * @return ItemInfo 指针。
 */
ItemInfo *ChatManager::userInfo() const
{
    return m_userInfo;
}

/**
 * @brief 获取好友分组列表，供QML使用。
 * @return QQmlListProperty<FriendModel>
 */
QQmlListProperty<FriendModel> ChatManager::friendGroups() const
{
    return m_friendGroup->friendGroups();
}

/**
 * @brief 获取最近消息列表，供QML使用。
 * @return QQmlListProperty<ItemInfo>
 */
QQmlListProperty<ItemInfo> ChatManager::recentMessageID() const
{
    return *m_rencentMessageIDProxy;
}

/**
 * @brief 响应网络管理器登录完成的信号。
 *
 * 根据登录结果，更新登录状态。
 * @param ok 登录是否成功。
 */
void ChatManager::onLoginFinshed(bool ok)
{
    if (ok) // 帐号密码验证成功
    {
        m_userInfo = m_networkManager->getUserInfo();
        m_friendGroup = new FriendGroup(this);
        m_networkManager->createFriend(m_friendGroup, &m_friendList);
        m_networkManager->sendStateChange(m_chatStatus);
        setLoginStatus(Chat::LoginSuccess);
    }
    else
    {
        setLoginStatus(Chat::LoginFailure);
    }
}

/**
 * @brief 从本地设置目录中获取登录历史记录（即所有登录过的用户名）。
 * @return 包含用户名的字符串列表。
 */
QStringList ChatManager::getLoginHistory()
{
    QDir dir(QDir::homePath() + "/MChat/Settings");
    QFileInfoList list = dir.entryInfoList(QDir::Dirs | QDir::NoDotAndDotDot);
    QStringList historyList;

    for (const auto &it : list)
    {
        historyList.append(it.fileName());
    }

    return historyList;
}

/**
 * @brief 创建或显示一个与指定用户的聊天窗口。
 *
 * 如果窗口已存在，则激活并显示现有窗口；否则，创建一个新窗口。
 * @param username 目标用户的账号。
 * @return 聊天窗口的指针。如果用户不存在或创建失败，返回 nullptr。
 */
FramelessWindow *ChatManager::addChatWindow(const QString &username)
{
    auto info = createFriendInfo(username);
    if (!info)
        return nullptr;

    info->setUnreadMessage(0); // 打开聊天窗口时，清空未读消息数

    if (m_chatList.contains(username))
    {
        m_chatList[username]->requestActivate();
        m_chatList[username]->show();
        return m_chatList[username];
    }
    else
    {
        QQmlComponent component(m_qmlEngine, QUrl("qrc:/qml/ChatWindow/ChatWindow.qml"));
        QObject *object = component.create();
        FramelessWindow *window = qobject_cast<FramelessWindow *>(object);
        if (!window)
            return nullptr;

        window->setProperty("username", username);
        connect(window, &FramelessWindow::closed, this, &ChatManager::deleteChatWindow);
        m_chatList.insert(username, window);
        window->requestActivate();
        window->show();
        return window;
    }
}

/**
 * @brief 判断与指定用户的聊天窗口是否已经打开。
 * @param username 目标用户的账号。
 * @return 如果已打开返回 true，否则返回 false。
 */
bool ChatManager::chatWindowIsOpenned(const QString &username)
{
    return m_chatList.contains(username);
}

/**
 * @brief 将一个用户添加到最近消息列表中。
 * @param username 要添加的用户的账号。
 */
void ChatManager::appendRecentMessageID(const QString &username)
{
    ItemInfo *info = createFriendInfo(username);
    if (info && !m_recentMessageID.contains(info))
    {
        m_recentMessageID.append(info);
        emit recentMessageIDChanged();
    }
}

/**
 * @brief 判断指定用户是否为当前登录用户的好友。
 * @param username 目标用户的账号。
 * @return 如果是好友返回 true，否则返回 false。
 */
bool ChatManager::isFriend(const QString &username)
{
    return m_friendList.contains(username);
}

/**
 * @brief 关闭所有已打开的聊天窗口。
 */
void ChatManager::closeAllOpenedChat()
{
    for (FramelessWindow *window : qAsConst(m_chatList))
    {
        if (window)
            window->close();
    }
}

/**
 * @brief 响应聊天窗口关闭的信号，用于清理资源。
 *
 * 此槽函数由被关闭的窗口发出信号时调用。
 */
void ChatManager::deleteChatWindow()
{
    FramelessWindow *chatWindow = qobject_cast<FramelessWindow *>(sender());
    if (chatWindow)
    {
        m_chatList.remove(m_chatList.key(chatWindow));
    }
}

/**
 * @brief 根据用户名获取好友信息对象。
 * @param username 好友的账号。
 * @return 如果是好友，返回其 ItemInfo 指针；否则返回 nullptr。
 */
ItemInfo *ChatManager::createFriendInfo(const QString &username)
{
    return m_friendList.value(username, nullptr);
}

/**
 * @brief 从配置文件读取基本设置。
 *
 * 根据当前的登录状态（LoginFinished之前或之后），读取不同的设置组。
 */
void ChatManager::readSettings()
{
    QSettings settings(QDir::homePath() + "/MChat/Settings/" + m_username + "/configura.ini", QSettings::IniFormat);

    if (m_loginStatus != Chat::LoginFinished)
    {
        // 读取登录界面相关的设置
        settings.beginGroup("LoginSettings");
        setChatStatus(Chat::ChatStatus(settings.value("ChatStatus", Chat::Online).toInt()));
        setRememberPassword(settings.value("RememberPassword", false).toBool());
        setAutoLogin(settings.value("AutoLogin", false).toBool());
        setHeadImage(settings.value("HeadImage").toString());
        settings.endGroup();

        settings.beginGroup("AccountInfo");
        setUsername(settings.value("Username").toString());
        if (m_rememberPassword)
        {
            //! @warning 密码以Base64形式存储，存在严重安全风险。
            setPassword(QString::fromLatin1(QByteArray::fromBase64(settings.value("Password").toByteArray())));
        }
        else
        {
            setPassword("");
        }
        settings.endGroup();
    }
    else
    {
        // 读取主界面相关的设置
        settings.beginGroup("MainSettings");
        if (!m_mainInterface.isNull())
        {
            // m_mainInterface->setCoord(settings.value("Coord", m_mainInterface->coord()).toPoint());
            // m_mainInterface->setWidth(settings.value("Width", m_mainInterface->width()).toInt());
            // m_mainInterface->setHeight(settings.value("Height", m_mainInterface->height()).toInt());
            // m_mainInterface->setProperty("isDock", settings.value("IsDock", false).toBool());
            // m_mainInterface->setProperty("dockState", settings.value("DockState", 0).toInt());
        }
        settings.endGroup();
    }
}

/**
 * @brief 将当前设置写入配置文件。
 *
 * 同样，根据登录状态写入不同的信息。
 */
void ChatManager::writeSettings()
{
    QString path = QDir::homePath() + "/MChat/Settings/" + m_username;
    QSettings settings(path + "/configura.ini", QSettings::IniFormat);

    settings.beginGroup("LoginSettings");
    settings.setValue("ChatStatus", m_chatStatus);
    settings.setValue("RememberPassword", m_rememberPassword);
    settings.setValue("AutoLogin", m_autoLogin);
    settings.endGroup();

    if (m_loginStatus == Chat::LoginFinished && !m_mainInterface.isNull())
    {
        settings.beginGroup("LoginSettings");
        settings.setValue("HeadImage", m_userInfo->headImage());
        settings.endGroup();

        settings.beginGroup("AccountInfo");
        settings.setValue("Username", m_username);
        if (m_rememberPassword)
        {
            //! @warning 密码以Base64形式存储，存在严重安全风险。
            settings.setValue("Password", m_password.toLatin1().toBase64());
        }
        else
        {
            settings.remove("Password"); // 不记住密码时，从配置文件中删除该键
        }
        settings.endGroup();

        settings.beginGroup("MainSettings");
        settings.setValue("Coord", m_mainInterface->coord());
        settings.setValue("Width", m_mainInterface->width());
        settings.setValue("Height", m_mainInterface->height());
        settings.setValue("IsDock", m_mainInterface->property("isDock"));
        settings.setValue("DockState", m_mainInterface->property("dockState"));
        settings.endGroup();
    }
}

/**
 * @brief 显示当前活动的界面（登录界面或主界面）。
 *
 * 激活并显示正确的窗口。
 */
void ChatManager::show()
{
    // if (!m_loginInterface.isNull())
    // {
    //     m_loginInterface->requestActivate();
    //     m_loginInterface->show();
    // }
    // else if (!m_mainInterface.isNull())
    // {
    //     m_mainInterface->requestActivate();
    //     QMetaObject::invokeMethod(m_mainInterface, "entered");
    //     m_mainInterface->show();
    // }
}

/**
 * @brief 退出应用程序。
 *
 * 在退出前，会先调用 writeSettings() 保存设置。
 */
void ChatManager::quit()
{
    // writeSettings();
    // if (!m_loginInterface.isNull())
    //     QMetaObject::invokeMethod(m_loginInterface, "quit");
    // if (!m_mainInterface.isNull())
    // {
    //     QMetaObject::invokeMethod(m_mainInterface, "quit");
    //     closeAllOpenedChat();
    // }
    // if (m_systemTray)
    //     m_systemTray->onExit();
}