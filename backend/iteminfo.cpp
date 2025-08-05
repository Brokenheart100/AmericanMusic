#include "iteminfo.h"
#include "chatmessage.h"
#include "chatmanager.h"
#include "databasemanager.h"
#include "networkmanager.h"
#include "chatmessagelist.h" // 包含完整定义

#include <QDateTime>
#include <QDate>
#include <QDebug>

/**
 * @brief ItemInfo的构造函数。
 *
 * 初始化成员变量，并获取各大管理类的单例。
 * @param parent 父QObject对象，默认为nullptr。
 */
ItemInfo::ItemInfo(QObject *parent)
    : QObject(parent), m_username(""), m_nickname(""), m_headImage(""), m_unreadMessage(0)
{
    m_chatRecord = new ChatMessageList(this);
    m_chatManager = ChatManager::instance();
    m_databaseManager = DatabaseManager::instance();
    m_networkManager = NetworkManager::instance();
}

/**
 * @brief ItemInfo的析构函数。
 */
ItemInfo::~ItemInfo()
{
}

QString ItemInfo::username() const { return m_username; }
QString ItemInfo::nickname() const { return m_nickname; }
QString ItemInfo::headImage() const { return m_headImage; }
int ItemInfo::unreadMessage() const { return m_unreadMessage; }

/**
 * @brief 获取最近一条聊天消息。
 * @return 指向ChatMessage对象的指针，如果聊天记录为空则可能返回nullptr。
 */
ChatMessage *ItemInfo::lastMessage() const
{
    // 调用ChatMessageList的last方法，如果没有消息则返回nullptr
    return m_chatRecord ? m_chatRecord->last() : nullptr;
}

/**
 * @brief 获取聊天记录列表模型。
 * @return 指向ChatMessageList对象的指针。
 */
ChatMessageList *ItemInfo::chatRecord() const
{
    return m_chatRecord;
}

void ItemInfo::setNickname(const QString &arg)
{
    if (arg != m_nickname)
    {
        m_nickname = arg;
        emit nicknameChanged();
    }
}

void ItemInfo::setUsername(const QString &arg)
{
    if (m_username != arg)
    {
        m_username = arg;
        emit usernameChanged();
    }
}

/**
 * @brief 从本地数据库加载聊天记录。
 *
 * 如果当前聊天记录为空，则向数据库请求加载最近的40条消息。
 */
void ItemInfo::loadRecord()
{
    if (m_chatRecord->count() == 0)
    {
        m_databaseManager->getChatMessage(m_username, 40, m_chatRecord);
    }
}

/**
 * @brief 添加一条文本消息到聊天记录中。
 * @param sender 发送方。
 * @param msg 消息内容。
 */
void ItemInfo::addTextMessage(const QString &sender, const QString &msg)
{
    addMessage(MT_TEXT, sender, msg);
}

/**
 * @brief 添加一条消息的通用实现。
 *
 * 这是处理新消息的核心逻辑：
 * 1. 创建一个新的ChatMessage对象。
 * 2. 设置消息属性（发送方、时间、内容、初始状态）。
 * 3. 将消息添加到聊天记录列表(m_chatRecord)中。
 * 4. 判断消息是自己发送的还是接收的：
 *    - 如果是自己发送的，则通过NetworkManager将消息发送出去。
 *    - 如果是接收的，则更新消息状态为成功，并检查是否需要增加未读消息数。
 * 5. 将当前聊天对象添加到“最近消息”列表中。
 * 6. 发出lastMessageChanged信号，通知UI更新。
 * @param type 消息类型。
 * @param sender 发送方。
 * @param msg 消息内容。
 */
void ItemInfo::addMessage(msg_t type, const QString &sender, const QString &msg)
{
    ChatMessage *message = new ChatMessage(this);
    QString datetime = QDateTime::currentDateTime().toString("yyyy-MM-dd hh:mm:ss");
    message->setSender(sender);
    message->setDateTime(datetime);
    message->setMessage(msg);
    message->setState(ChatMessageStatus::Sending); // 初始状态为“发送中”

    m_chatRecord->append(message); // 加入到消息列表

    if (sender == m_chatManager->username()) // 如果是自己发送的
    {
        m_networkManager->sendChatMessage(type, m_username, message);
    }
    else // 如果是接收到的消息
    {
        message->setState(ChatMessageStatus::Success); // 直接设置为成功状态
        if (!m_chatManager->chatWindowIsOpenned(sender))
        {
            setUnreadMessage(unreadMessage() + 1); // 如果聊天窗口未打开，未读数+1
        }
    }

    m_chatManager->appendRecentMessageID(m_username); // 将此会话加入到最近消息列表
    emit lastMessageChanged();
}

/**
 * @brief 撤回消息（占位函数，当前未实现）。
 */
void ItemInfo::recallMessage(const QString &sender, const QString &msg)
{
    Q_UNUSED(sender);
    Q_UNUSED(msg);
}

void ItemInfo::setHeadImage(const QString &arg)
{
    if (m_headImage != arg)
    {
        m_headImage = arg;
        emit headImageChanged();
    }
}

/**
 * @brief 设置未读消息数。
 *
 * 通常在打开聊天窗口时被调用，以清零未读数。
 * @param arg 新的未读消息数。
 */
void ItemInfo::setUnreadMessage(int arg)
{
    if (m_unreadMessage != arg)
    {
        m_unreadMessage = arg;
        emit unreadMessageChanged();
    }
}

// --- FriendInfo Implementation ---

/**
 * @brief FriendInfo的构造函数。
 *
 * 初始化好友特有的属性。
 * @param parent 父QObject对象，默认为nullptr。
 */
FriendInfo::FriendInfo(QObject *parent)
    : ItemInfo(parent), m_status(Chat::Offline), m_background("qrc:/image/Background/7.jpg"), m_signature(""), m_birthday(""), m_gender(""), m_level(0)
{
}

FriendInfo::~FriendInfo()
{
}

int FriendInfo::chatStatus() const { return m_status; }

void FriendInfo::setChatStatus(int status)
{
    if (status != m_status)
    {
        m_status = status;
        emit chatStatusChanged();
    }
}

QString FriendInfo::background() const { return m_background; }
QString FriendInfo::signature() const { return m_signature; }
QString FriendInfo::birthday() const { return m_birthday; }
QString FriendInfo::gender() const { return m_gender; }
int FriendInfo::level() const { return m_level; }

void FriendInfo::setBackground(const QString &arg)
{
    if (m_background != arg)
    {
        m_background = arg;
        emit backgroundChanged();
    }
}

void FriendInfo::setSignature(const QString &arg)
{
    if (m_signature != arg)
    {
        m_signature = arg;
        emit signatureChanged();
    }
}

void FriendInfo::setBirthday(const QString &arg)
{
    if (m_birthday != arg)
    {
        m_birthday = arg;
        emit birthdayChanged();
        emit ageChanged(); // 生日改变，年龄也随之改变
    }
}

void FriendInfo::setGender(const QString &arg)
{
    if (m_gender != arg)
    {
        m_gender = arg;
        emit genderChanged();
    }
}

void FriendInfo::setLevel(int arg)
{
    if (m_level != arg)
    {
        m_level = arg;
        emit levelChanged();
    }
}

/**
 * @brief 计算并返回好友的年龄。
 *
 * 年龄是根据生日和当前日期动态计算的。
 * @return 年龄（整数）。
 */
int FriendInfo::age() const
{
    QDate birth = QDate::fromString(m_birthday, "yyyy-MM-dd");
    if (!birth.isValid())
        return 0;

    QDate today = QDate::currentDate();
    int age = today.year() - birth.year();
    if (today.month() < birth.month() || (today.month() == birth.month() && today.day() < birth.day()))
    {
        age--; // 如果还没到今年的生日，年龄减一
    }
    return age > 0 ? age : 0;
}

/**
 * @brief 在聊天记录中添加一条窗口抖动消息。
 * @param sender 发送方。
 */
void FriendInfo::addShakeMessage(const QString &sender)
{
    addMessage(MT_SHAKE, sender, QString("窗口抖动~~"));
}