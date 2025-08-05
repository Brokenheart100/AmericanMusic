#ifndef CHATMANAGER_H
#define CHATMANAGER_H

#include <QList>
#include <QObject>
#include <QPointer>
#include <QQmlListProperty>

#include "iteminfo.h"
#include "friendmodel.h"

namespace Chat
{
    Q_NAMESPACE

    //! @brief 定义用户的登录状态
    enum LoginStatus
    {
        NoLogin,       //!< 未登录
        Logging,       //!< 登录中
        LoginSuccess,  //!< 登录成功（已验证，准备切换界面）
        LoginFinished, //!< 登录流程结束（已载入主界面）
        LoginFailure   //!< 登录失败
    };

    //! @brief 定义用户的在线聊天状态
    enum ChatStatus
    {
        Online = 0, //!< 在线
        Stealth,    //!< 隐身
        Busy,       //!< 忙碌
        Offline     //!< 离线
    };

    //! @brief 定义主窗口的停靠状态
    enum DockStatus
    {
        UnDock,    //!< 未停靠
        LeftDock,  //!< 左侧停靠
        RightDock, //!< 右侧停靠
        TopDock    //!< 顶部停靠
    };

    Q_ENUMS(LoginStatus)
    Q_ENUMS(ChatStatus)
    Q_ENUMS(DockStatus)
}

// 前向声明，用于减少头文件依赖
class ChatMessage;
class FriendGroup;
class FramelessWindow;
class NetworkManager;
class QQmlApplicationEngine;
class SystemTrayIcon;

/**
 * @class ChatManager
 * @brief 应用程序的核心管理类，采用单例模式。
 *
 * ChatManager 负责管理整个应用的生命周期、用户状态、数据模型以及与QML界面的交互。
 * 它是C++后端与QML前端之间的主要桥梁。
 */
class ChatManager : public QObject
{
    Q_OBJECT

    //! @brief 当前的登录状态，可被QML访问和绑定。
    Q_PROPERTY(Chat::LoginStatus loginStatus READ loginStatus WRITE setLoginStatus NOTIFY loginStatusChanged)
    //! @brief 当前用户的在线状态，可被QML访问和绑定。
    Q_PROPERTY(Chat::ChatStatus chatStatus READ chatStatus WRITE setChatStatus NOTIFY chatStatusChanged)
    //! @brief 是否记住密码，可被QML访问和绑定。
    Q_PROPERTY(bool rememberPassword READ rememberPassword WRITE setRememberPassword NOTIFY rememberPasswordChanged)
    //! @brief 是否自动登录，可被QML访问和绑定。
    Q_PROPERTY(bool autoLogin READ autoLogin WRITE setAutoLogin NOTIFY autoLoginChanged)
    //! @brief 当前用户的头像路径，可被QML访问和绑定。
    Q_PROPERTY(QString headImage READ headImage WRITE setHeadImage NOTIFY headImageChanged)
    //! @brief 当前用户的账号，可被QML访问和绑定。
    Q_PROPERTY(QString username READ username WRITE setUsername NOTIFY usernameChanged)
    //! @brief 当前用户的密码，可被QML访问和绑定。
    Q_PROPERTY(QString password READ password WRITE setPassword NOTIFY passwordChanged)
    //! @brief 当前登录用户信息的对象，只读，暴露给QML。
    Q_PROPERTY(ItemInfo *userInfo READ userInfo CONSTANT)
    //! @brief 好友分组列表，以QQmlListProperty形式暴露给QML的ListView。
    Q_PROPERTY(QQmlListProperty<FriendModel> friendGroups READ friendGroups NOTIFY friendGroupsChanged)
    //! @brief 最近消息列表，以QQmlListProperty形式暴露给QML的ListView。
    Q_PROPERTY(QQmlListProperty<ItemInfo> recentMessageID READ recentMessageID NOTIFY recentMessageIDChanged)

public:
    /**
     * @brief 获取 ChatManager 的全局唯一实例。
     * @return ChatManager 的实例指针。
     */
    static ChatManager *instance();
    ~ChatManager();

    /**
     * @brief 初始化 ChatManager。
     * @param qmlengine 全局的QML应用引擎指针。
     */
    void initChatManager(QQmlApplicationEngine *qmlengine);

    /**
     * @brief 动态加载并创建登录界面。
     * @return 如果加载成功返回 true，否则返回 false。
     */
    bool loadLoginInterface();

    /**
     * @brief 动态加载并创建主界面。
     * @return 如果加载成功返回 true，否则返回 false。
     */
    bool loadMainInterface();

    // --- Q_PROPERTY getters and setters ---
    Chat::LoginStatus loginStatus() const;
    void setLoginStatus(Chat::LoginStatus arg);

    Chat::ChatStatus chatStatus() const;
    void setChatStatus(Chat::ChatStatus arg);

    bool rememberPassword() const;
    void setRememberPassword(bool arg);

    bool autoLogin() const;
    void setAutoLogin(bool arg);

    QString headImage() const;
    void setHeadImage(const QString &arg);

    QString username() const;
    void setUsername(const QString &arg);

    QString password() const;
    void setPassword(const QString &arg);

    ItemInfo *userInfo() const;
    // QQmlListProperty<FriendModel> friendGroups() const;
    QQmlListProperty<ItemInfo> recentMessageID() const;
    // --- End of Q_PROPERTY getters and setters ---

    /**
     * @brief 将一个好友信息添加到指定的分组中。
     * @param group 分组名称。
     * @param info 好友信息对象指针。
     */
    void addFriendToGroup(const QString &group, ItemInfo *info);

    // --- Q_INVOKABLE methods for QML ---

    /**
     * @brief 从本地设置目录中获取登录历史记录（即所有登录过的用户名）。
     * @return 包含用户名的字符串列表。
     */
    Q_INVOKABLE QStringList getLoginHistory();

    /**
     * @brief 创建或显示一个与指定用户的聊天窗口。
     * @param username 目标用户的账号。
     * @return 聊天窗口的指针。如果窗口已存在，则返回现有窗口指针。
     */
    Q_INVOKABLE FramelessWindow *addChatWindow(const QString &username);

    /**
     * @brief 判断与指定用户的聊天窗口是否已经打开。
     * @param username 目标用户的账号。
     * @return 如果已打开返回 true，否则返回 false。
     */
    Q_INVOKABLE bool chatWindowIsOpenned(const QString &username);

    /**
     * @brief 将一个用户添加到最近消息列表中。
     * @param username 要添加的用户的账号。
     */
    Q_INVOKABLE void appendRecentMessageID(const QString &username);

    /**
     * @brief 判断指定用户是否为当前登录用户的好友。
     * @param username 目标用户的账号。
     * @return 如果是好友返回 true，否则返回 false。
     */
    Q_INVOKABLE bool isFriend(const QString &username);

    /**
     * @brief 根据用户名获取好友信息对象。
     * @param username 好友的账号。
     * @return 如果是好友，返回其 ItemInfo 指针；否则返回 nullptr。
     */
    Q_INVOKABLE ItemInfo *createFriendInfo(const QString &username);

    /**
     * @brief 显示当前活动的界面（登录界面或主界面）。
     */
    Q_INVOKABLE void show();

    /**
     * @brief 退出应用程序。会先写入设置。
     */
    Q_INVOKABLE void quit();

    /**
     * @brief 关闭所有已打开的聊天窗口。
     */
    Q_INVOKABLE void closeAllOpenedChat();

    /**
     * @brief 从配置文件读取基本设置。
     */
    Q_INVOKABLE void readSettings();

    /**
     * @brief 将当前设置写入配置文件。
     */
    Q_INVOKABLE void writeSettings();

signals:
    void loginStatusChanged(Chat::LoginStatus arg);
    void chatStatusChanged(Chat::ChatStatus arg);
    void rememberPasswordChanged(bool arg);
    void autoLoginChanged(bool arg);
    void headImageChanged(const QString &arg);
    void usernameChanged(const QString &arg);
    void passwordChanged(const QString &arg);
    void friendGroupsChanged();
    void recentMessageIDChanged();

private slots:
    /**
     * @brief 响应网络管理器登录完成的信号。
     * @param ok 登录是否成功。
     */
    void onLoginFinshed(bool ok);

    /**
     * @brief 响应聊天窗口关闭的信号，用于清理资源。
     */
    void deleteChatWindow();

private:
    /**
     * @brief 私有构造函数，实现单例模式。
     */
    ChatManager(QObject *parent = nullptr);

    QPointer<FramelessWindow> m_loginInterface, m_mainInterface; //!< 登录界面和主界面的智能指针
    QPointer<QQmlApplicationEngine> m_qmlEngine;                 //!< 当前的QML引擎
    Chat::LoginStatus m_loginStatus;                             //!< 当前登录状态
    Chat::ChatStatus m_chatStatus;                               //!< 当前聊天的状态
    QString m_username;                                          //!< 当前用户ID
    QString m_password;                                          //!< 当前用户密码
    QString m_headImage;                                         //!< 当前用户的头像路径
    bool m_rememberPassword;                                     //!< 是否记住密码
    bool m_autoLogin;                                            //!< 是否自动登录
    NetworkManager *m_networkManager;                            //!< 网络管理模块指针
    SystemTrayIcon *m_systemTray;                                //!< 全局系统托盘图标
    ItemInfo *m_userInfo;                                        //!< 当前登录的用户信息对象
    FriendGroup *m_friendGroup;                                  //!< 保存好友分组的模型
    QQmlListProperty<ItemInfo> *m_rencentMessageIDProxy;         //!< 最近消息列表的QML属性代理
    QList<ItemInfo *> m_recentMessageID;                         //!< 保存最近消息ID的列表
    QMap<QString, ItemInfo *> m_friendList;                      //!< 保存好友列表的映射，键为用户名
    QMap<QString, FramelessWindow *> m_chatList;                 //!< 保存当前已打开聊天窗口的映射，键为用户名
};

#endif // CHATMANAGER_H