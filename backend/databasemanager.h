#ifndef DATABASEMANAGER_H
#define DATABASEMANAGER_H

#include <QMutex>
#include <QObject>
#include <QSqlDatabase>
#include <QSqlQuery>

// 前向声明
class ChatMessage;
class ChatMessageList;

/**
 * @class DatabaseManager
 * @brief 数据库管理类，采用单例模式，并在独立线程中运行。
 *
 * 该类负责所有与本地SQLite数据库的交互，包括初始化、连接、关闭以及聊天记录的增删改查。
 * 所有数据库操作都通过信号槽机制异步执行，以避免阻塞主线程。
 */
class DatabaseManager : public QObject
{
    Q_OBJECT

public:
    /**
     * @brief 获取 DatabaseManager 的全局唯一实例。
     * @return DatabaseManager 的实例指针。
     */
    static DatabaseManager *instance();
    ~DatabaseManager();

signals:
    // 所有的外部操作都通过发射这些信号来请求，对应的槽函数会在数据库线程中执行。

    /**
     * @brief 请求初始化数据库连接信息。
     */
    void initDatabase();

    /**
     * @brief 请求打开数据库连接。
     */
    void openDatabase();

    /**
     * @brief 请求关闭数据库连接。
     */
    void closeDatabase();

    /**
     * @brief 请求向数据库中插入一条聊天消息。
     * @param username 与之聊天的用户的账号，用于确定表名。
     * @param chatMessage 要插入的聊天消息对象指针。
     */
    void insertChatMessage(const QString &username, ChatMessage *chatMessage);

    /**
     * @brief 请求从数据库中获取指定数量的聊天记录。
     * @param username 与之聊天的用户的账号，用于确定表名。
     * @param count 希望获取的最近消息数量。
     * @param chatMessageList 用于存放查询结果的消息列表对象指针。
     */
    void getChatMessage(const QString &username, int count, ChatMessageList *chatMessageList);

private slots:
    // 这些槽函数在数据库线程中实际执行数据库操作。

    /**
     * @brief 初始化数据库连接配置的槽函数。
     */
    void initDatabaseSlot();

    /**
     * @brief 打开数据库连接的槽函数。
     */
    void openDatabaseSlot();

    /**
     * @brief 关闭数据库连接的槽函数。
     */
    void closeDatabaseSlot();

    /**
     * @brief 插入聊天消息到数据库的槽函数。
     * @param username 用户账号。
     * @param chatMessage 消息对象。
     */
    void insertChatMessageSlot(const QString &username, ChatMessage *chatMessage);

    /**
     * @brief 从数据库获取聊天消息的槽函数。
     * @param username 用户账号。
     * @param count 消息数量。
     * @param chatMessageList 存放结果的消息列表。
     */
    void getChatMessageSlot(const QString &username, int count, ChatMessageList *chatMessageList);

private:
    /**
     * @brief 私有构造函数，实现单例模式并设置线程关联。
     */
    DatabaseManager(QObject *parent = nullptr);

    /**
     * @brief 检查指定的表是否存在。如果不存在，则会尝试创建它。
     * @param tableName 表名。
     * @return 如果表存在或创建成功，返回 true；否则返回 false。
     */
    bool tableExist(const QString &tableName);

    /**
     * @brief 获取指定表中的记录总数。
     * @param tableName 表名。
     * @return 表中的记录数量；如果查询失败，返回 -1。
     */
    int getTableSize(const QString &tableName);

    /**
     * @brief 根据用户ID生成对应的聊天记录表名。
     * @param username 用户账号。
     * @return 生成的表名，格式为 "Message" + username。
     */
    QString getTableName(const QString &username);

private:
    QMutex m_mutex;          //!< 互斥锁，用于保护对数据库对象的并发访问。
    QSqlDatabase m_database; //!< Qt的数据库连接对象。
};

#endif // DATABASEMANAGER_H