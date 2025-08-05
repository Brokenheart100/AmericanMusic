#ifndef NETWORKMANAGER_H
#define NETWORKMANAGER_H

#include "chatmanager.h"
#include "protocol.h"

#include <QObject>
#include <QPointer>

#include "iteminfo.h"

namespace NetworkMode
{
    Q_NAMESPACE

    //! @brief 定义网络连接的模式
    enum Mode
    {
        Internet = 0, //!< 互联网模式，连接到公网服务器
        LocalInternet //!< 局域网模式，可能使用UDP广播等
    };

    Q_ENUMS(Mode)
}

// 前向声明，减少头文件依赖
class ChatMessage;
class DatabaseManager;
class FriendGroup;
class FriendInfo;
class JsonParser;
class TcpManager;
class UdpManager;

/**
 * @class NetworkManager
 * @brief 网络管理类，采用单例模式。
 *
 * NetworkManager 是网络通信的顶层封装。它根据不同的网络模式（互联网/局域网），
 * 管理和协调底层的TCP/UDP管理器，并为上层业务（如ChatManager）提供统一的、
 * 抽象的网络请求接口。
 */
class NetworkManager : public QObject
{
    Q_OBJECT

    //! @brief 当前的网络连接模式，可被QML访问和绑定。
    Q_PROPERTY(NetworkMode::Mode mode READ mode WRITE setMode NOTIFY modeChanged)

public:
    /**
     * @brief 获取 NetworkManager 的全局唯一实例。
     * @return NetworkManager 的实例指针。
     */
    static NetworkManager *instance();
    ~NetworkManager();

    /**
     * @brief 获取当前的网络模式。
     */
    NetworkMode::Mode mode() const { return m_mode; }
    /**
     * @brief 设置网络模式。
     */
    void setMode(NetworkMode::Mode mode);

    /**
     * @brief 从JSON解析器获取当前登录用户的信息。
     * @return ItemInfo 指针。
     */
    ItemInfo *getUserInfo();

    /**
     * @brief 请求TCP管理器开始校验登录信息。
     */
    void checkLoginInfo();

    /**
     * @brief 使用JSON解析器创建好友列表和分组。
     * @param friendGroup 用于存放好友分组的模型指针。
     * @param friendList 用于存放好友列表的映射指针。
     */
    void createFriend(FriendGroup *friendGroup, QMap<QString, ItemInfo *> *friendList);

    /**
     * @brief 请求连接到服务器。
     */
    Q_INVOKABLE void connectServer();

    /**
     * @brief 取消登录过程（即断开与服务器的连接）。
     */
    Q_INVOKABLE void cancelLogin();

    /**
     * @brief 发送更新当前用户信息的请求到服务器。
     */
    Q_INVOKABLE void updateInfomation();

    /**
     * @brief 发送注册新账户的请求。
     * @param json 包含新用户信息的JSON字符串。
     */
    Q_INVOKABLE void registerUser(const QString &json);

    /**
     * @brief 发送获取指定用户信息的请求。
     * @param username 要查询的用户名。
     */
    Q_INVOKABLE void requestUserInfo(const QString &username);

    /**
     * @brief 发送添加好友的请求。
     * @param username 目标好友的用户名。
     */
    Q_INVOKABLE void requestAddFriend(const QString &username);

    /**
     * @brief 发送同意添加好友的响应。
     * @param username 发起好友请求的用户名。
     */
    Q_INVOKABLE void acceptFriendRequest(const QString &username);

    /**
     * @brief 发送拒绝添加好友的响应。
     * @param username 发起好友请求的用户名。
     */
    Q_INVOKABLE void rejectFriendRequest(const QString &username);

    /**
     * @brief 发送用户在线状态变更的消息。
     * @param status 新的在线状态。
     */
    Q_INVOKABLE void sendStateChange(Chat::ChatStatus status);

    /**
     * @brief 发送一条聊天消息。
     * @param type 消息类型（如文本、图片等）。
     * @param receiver 接收方的用户名。
     * @param chatMessage 聊天消息对象指针。
     */
    Q_INVOKABLE void sendChatMessage(msg_t type, const QString &receiver, ChatMessage *chatMessage);

signals:
    /**
     * @brief 当网络模式改变时发出此信号。
     */
    void modeChanged();

    /**
     * @brief 当登录过程中发生错误时发出此信号。
     * @param error 错误信息描述。
     */
    void loginError(const QString &error);

    /**
     * @brief 当整个登录流程（包括信息获取）完成时发出此信号。
     * @param ok 登录是否成功。
     */
    void loginFinshed(bool ok);

    /**
     * @brief 当收到注册结果时发出此信号。
     * @param result 注册结果的描述字符串。
     */
    void hasRegister(const QString &result);

    /**
     * @brief 当收到用户搜索结果时发出此信号。
     * @param info 搜索到的用户信息对象指针。
     */
    void hasSearchResult(FriendInfo *info);

    /**
     * @brief 当收到新的好友请求时发出此信号。
     * @param username 发起请求的用户名。
     */
    void hasFriendRequest(const QString &username);

    /**
     * @brief 当收到窗口抖动消息时发出此信号。
     * @param sender 发送方的用户名。
     */
    void hasNewShake(const QString &sender);

    /**
     * @brief 当收到新的文本消息时发出此信号。
     * @param sender 发送方的用户名。
     * @param message 消息内容。
     */
    void hasNewText(const QString &sender, const QString &message);

public slots:
    /**
     * @brief 响应TCP管理器登录验证完成的槽函数。
     * @param ok 验证是否通过。
     */
    void onLogined(bool ok);

    /**
     * @brief 响应TCP管理器获取到用户信息JSON的槽函数。
     * @param infoJson 包含用户信息的JSON数据。
     */
    void onInfoGot(const QByteArray &infoJson);

private slots:
    /**
     * @brief 处理从TCP/UDP管理器收到的所有新消息的中央分发槽函数。
     * @param sender 消息发送方的用户名。
     * @param type 消息类型。
     * @param data 消息数据。
     */
    void disposeNewMessage(const QString &sender, msg_t type, const QByteArray &data);

private:
    /**
     * @brief 私有构造函数，实现单例模式。
     */
    NetworkManager(QObject *parent = nullptr);

    QPointer<TcpManager> m_tcpManager;  //!< TCP通信管理器，运行在独立线程
    QPointer<UdpManager> m_udpManager;  //!< UDP通信管理器（当前未使用）
    DatabaseManager *m_databaseManager; //!< 数据库管理器实例
    JsonParser *m_jsonParser;           //!< JSON数据解析器
    NetworkMode::Mode m_mode;           //!< 当前的网络模式
};

#endif