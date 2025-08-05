#ifndef ITEMINFO_H
#define ITEMINFO_H

#include "chatmanager.h"
#include "protocol.h"

#include <QObject>

// 解决 Qt 6 下 Q_PROPERTY 对自定义类型指针要求完整定义的问题
#include "chatmessage.h"

// 前向声明
class ChatMessageList;
class DatabaseManager;
class NetworkManager;

/**
 * @class ItemInfo
 * @brief 通用的信息项基类，用于表示可以与之聊天的实体，如好友、群组等。
 *
 * ItemInfo 封装了一个聊天对象的基本信息，如ID、昵称、头像，以及与之相关的
 * 聊天记录（m_chatRecord）。它是 FriendInfo 的基类，也可以直接用于表示
 * 比如“文件传输助手”这样的非好友聊天对象。
 */
class ItemInfo : public QObject
{
    Q_OBJECT

    //! @brief 用户的唯一标识（账号）。
    Q_PROPERTY(QString username READ username WRITE setUsername NOTIFY usernameChanged)
    //! @brief 用户的昵称。
    Q_PROPERTY(QString nickname READ nickname WRITE setNickname NOTIFY nicknameChanged)
    //! @brief 用户的头像资源路径。
    Q_PROPERTY(QString headImage READ headImage WRITE setHeadImage NOTIFY headImageChanged)
    //! @brief 未读消息的数量。
    Q_PROPERTY(int unreadMessage READ unreadMessage WRITE setUnreadMessage NOTIFY unreadMessageChanged)
    //! @brief 最近一条聊天消息的对象指针。
    Q_PROPERTY(ChatMessage *lastMessage READ lastMessage NOTIFY lastMessageChanged)
    //! @brief 完整的聊天记录列表模型，只读，暴露给QML。
    Q_PROPERTY(ChatMessageList *chatRecord READ chatRecord CONSTANT)

public:
    /**
     * @brief ItemInfo的构造函数。
     * @param parent 父QObject对象，默认为nullptr。
     */
    ItemInfo(QObject *parent = nullptr);
    ~ItemInfo();

    // --- Q_PROPERTY getters and setters ---
    QString username() const;
    void setUsername(const QString &arg);

    QString nickname() const;
    void setNickname(const QString &arg);

    QString headImage() const;
    void setHeadImage(const QString &arg);

    int unreadMessage() const;
    void setUnreadMessage(int arg);

    ChatMessage *lastMessage() const;
    ChatMessageList *chatRecord() const;
    // --- End of Q_PROPERTY getters and setters ---

    /**
     * @brief 从本地数据库加载聊天记录。
     *
     * 这是一个可从QML调用的方法，用于初次加载历史消息。
     */
    Q_INVOKABLE void loadRecord();

    /**
     * @brief 在消息记录中添加一条新的文本消息。
     * @param sender 消息发送方的用户名。
     * @param msg 消息内容。
     */
    Q_INVOKABLE void addTextMessage(const QString &sender, const QString &msg);

    /**
     * @brief 在消息记录中撤回一条消息（当前未实现）。
     * @param sender 消息发送方的用户名。
     * @param msg 消息内容。
     */
    Q_INVOKABLE void recallMessage(const QString &sender, const QString &msg);

signals:
    void usernameChanged();
    void nicknameChanged();
    void headImageChanged();
    void unreadMessageChanged();
    void lastMessageChanged();

protected:
    /**
     * @brief 添加一条消息的通用内部方法。
     *
     * 此方法被 addTextMessage、addShakeMessage 等调用，用于统一处理消息的创建和发送逻辑。
     * @param type 消息类型（如 MT_TEXT, MT_SHAKE）。
     * @param sender 消息发送方。
     * @param msg 消息内容。
     */
    void addMessage(msg_t type, const QString &sender, const QString &msg);

private:
    QString m_username;  //!< ID
    QString m_nickname;  //!< 昵称
    QString m_headImage; //!< 头像路径
    int m_unreadMessage; //!< 未读消息数

    ChatMessageList *m_chatRecord;      //!< 聊天记录列表模型
    ChatManager *m_chatManager;         //!< 全局ChatManager实例
    DatabaseManager *m_databaseManager; //!< 全局DatabaseManager实例
    NetworkManager *m_networkManager;   //!< 全局NetworkManager实例
};

/**
 * @class FriendInfo
 * @brief 继承自ItemInfo，专门用于表示好友的信息。
 *
 * FriendInfo 在 ItemInfo 的基础上，增加了更多好友特有的属性，如在线状态、
 * 背景、签名、生日、性别等。
 */
class FriendInfo : public ItemInfo
{
    Q_OBJECT

    //! @brief 好友的在线状态（使用Chat::ChatStatus枚举）。
    Q_PROPERTY(int chatStatus READ chatStatus WRITE setChatStatus NOTIFY chatStatusChanged)
    //! @brief 好友的个人资料背景图片路径。
    Q_PROPERTY(QString background READ background WRITE setBackground NOTIFY backgroundChanged)
    //! @brief 好友的个性签名。
    Q_PROPERTY(QString signature READ signature WRITE setSignature NOTIFY signatureChanged)
    //! @brief 好友的生日（"yyyy-MM-dd"格式）。
    Q_PROPERTY(QString birthday READ birthday WRITE setBirthday NOTIFY birthdayChanged)
    //! @brief 好友的性别。
    Q_PROPERTY(QString gender READ gender WRITE setGender NOTIFY genderChanged)
    //! @brief 好友的等级。
    Q_PROPERTY(int level READ level WRITE setLevel NOTIFY levelChanged)
    //! @brief 根据生日计算出的年龄（只读）。
    Q_PROPERTY(int age READ age NOTIFY ageChanged)

public:
    FriendInfo(QObject *parent = nullptr);
    ~FriendInfo();

    // --- Q_PROPERTY getters and setters ---
    int chatStatus() const;
    void setChatStatus(int status);

    QString background() const;
    void setBackground(const QString &arg);

    QString signature() const;
    void setSignature(const QString &arg);

    QString birthday() const;
    void setBirthday(const QString &arg);

    QString gender() const;
    void setGender(const QString &arg);

    int level() const;
    void setLevel(int arg);

    int age() const;
    // --- End of Q_PROPERTY getters and setters ---

public slots:
    /**
     * @brief 在消息记录中添加一条窗口抖动消息。
     * @param sender 发送方用户名。
     */
    void addShakeMessage(const QString &sender);

signals:
    void chatStatusChanged();
    void backgroundChanged();
    void signatureChanged();
    void birthdayChanged();
    void genderChanged();
    void levelChanged();
    void ageChanged();

private:
    int m_status;         //!< 在线状态
    QString m_background; //!< 背景图片路径
    QString m_signature;  //!< 个性签名
    QString m_birthday;   //!< 生日
    QString m_gender;     //!< 性别
    int m_level;          //!< 等级
};

#endif // ITEMINFO_H