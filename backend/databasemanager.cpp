#include "databasemanager.h"
#include "chatmanager.h"
#include "chatmessage.h"
#include "chatmessagelist.h" // 包含完整定义

#include <QSqlError>
#include <QThread>
#include <QDir>
#include <QDebug>

/**
 * @brief 获取 DatabaseManager 的全局唯一实例。
 * @return DatabaseManager 的实例指针。
 */
DatabaseManager *DatabaseManager::instance()
{
    static DatabaseManager databaseManager;
    return &databaseManager;
}

/**
 * @brief DatabaseManager的构造函数。
 *
 * 在此构造函数中，会创建一个新的QThread，并将当前DatabaseManager实例移动到该线程中。
 * 这样可以确保所有的数据库操作都在一个独立的后台线程中执行，避免阻塞UI主线程。
 * 同时，连接了所有对外暴露的信号到其对应的私有槽函数。
 * @param parent 父QObject对象，默认为nullptr。
 */
DatabaseManager::DatabaseManager(QObject *parent)
    : QObject(parent)
{
    QThread *thread = new QThread;
    // 当线程结束时，自动删除线程对象
    connect(thread, &QThread::finished, thread, &QThread::deleteLater);
    // 将所有请求信号连接到在数据库线程中执行的槽函数
    connect(this, &DatabaseManager::initDatabase, this, &DatabaseManager::initDatabaseSlot);
    connect(this, &DatabaseManager::openDatabase, this, &DatabaseManager::openDatabaseSlot);
    connect(this, &DatabaseManager::closeDatabase, this, &DatabaseManager::closeDatabaseSlot);
    connect(this, &DatabaseManager::getChatMessage, this, &DatabaseManager::getChatMessageSlot);
    connect(this, &DatabaseManager::insertChatMessage, this, &DatabaseManager::insertChatMessageSlot);

    // 将当前对象移动到新创建的线程
    this->moveToThread(thread);
    // 启动线程的事件循环
    thread->start();
}

/**
 * @brief DatabaseManager的析构函数。
 *
 * 在对象销毁前，确保数据库连接被关闭。
 */
DatabaseManager::~DatabaseManager()
{
    closeDatabaseSlot();
}

/**
 * @brief 初始化数据库连接配置。
 *
 * 此函数在数据库线程中执行。它设置了数据库驱动为QSQLITE，并根据当前登录用户的
 * 用户名构建数据库文件的路径。
 * @note 数据库的用户名和密码对于SQLite是可选的，这里设置了可能用于未来扩展。
 */
void DatabaseManager::initDatabaseSlot()
{
    QMutexLocker locker(&m_mutex);

    m_database = QSqlDatabase::addDatabase("QSQLITE");
    m_database.setDatabaseName(QDir::homePath() + "/MChat/ChatRecord/MSG_" +
                               ChatManager::instance()->username() + ".db");
    // 以下设置对于SQLite不是必需的
    m_database.setUserName("MChat");
    m_database.setHostName("localhost");
    m_database.setPassword("123456");
}

/**
 * @brief 打开数据库连接。
 *
 * 如果数据库文件所在的目录不存在，则创建它。
 * 然后尝试打开数据库连接。
 */
void DatabaseManager::openDatabaseSlot()
{
    QString recordPath = QDir::homePath() + "/MChat/ChatRecord";
    if (!QFile::exists(recordPath))
    {
        QDir dir;
        dir.mkpath(recordPath);
    }

    if (!m_database.isOpen())
    {
        if (!m_database.open())
        {
            qDebug() << "DatabaseManager::openDatabaseSlot: " << m_database.lastError().text();
        }
    }
}

/**
 * @brief 关闭数据库连接。
 */
void DatabaseManager::closeDatabaseSlot()
{
    if (m_database.isOpen())
    {
        m_database.close();
    }
}

/**
 * @brief 检查指定的表是否存在。
 *
 * 使用 "CREATE TABLE IF NOT EXISTS" SQL语句，这个语句在表不存在时会创建它，
 * 在表已存在时则什么也不做。这是一个高效且安全的方式来确保表的存在。
 * @param tableName 要检查或创建的表名。
 * @return 如果操作成功返回true，否则返回false。
 */
bool DatabaseManager::tableExist(const QString &tableName)
{
    if (!m_database.isOpen())
    {
        openDatabaseSlot();
    }

    QString query_create = "CREATE TABLE IF NOT EXISTS " + tableName +
                           "("
                           "  msg_index          INTEGER     PRIMARY KEY AUTOINCREMENT," // 使用自增主键更佳
                           "  msg_sender         TEXT        NOT NULL,"
                           "  msg_datetime       TEXT        NOT NULL,"
                           "  msg_chatMessage    TEXT        NOT NULL,"
                           "  msg_state          INTEGER     NOT NULL"
                           ");";
    QSqlQuery query(m_database);
    if (query.exec(query_create))
    {
        return true;
    }
    else
    {
        qDebug() << "DatabaseManager::tableExist: " << query.lastError().text();
        return false;
    }
}

/**
 * @brief 获取指定表中的记录总数。
 * @param tableName 表名。
 * @return 表中的记录数量；如果查询失败，返回 -1。
 */
int DatabaseManager::getTableSize(const QString &tableName)
{
    if (!m_database.isOpen())
    {
        openDatabaseSlot();
    }

    QSqlQuery size_query(m_database);
    if (size_query.exec("SELECT COUNT(*) FROM " + tableName))
    {
        if (size_query.next())
        {
            return size_query.value(0).toInt();
        }
    }

    qDebug() << "DatabaseManager::getTableSize: " << size_query.lastError().text();
    return -1;
}

/**
 * @brief 根据用户ID生成对应的聊天记录表名。
 *
 * 表名规则为 "Message" + 用户名，以区分不同好友的聊天记录。
 * @param username 用户账号。
 * @return 生成的表名。
 */
QString DatabaseManager::getTableName(const QString &username)
{
    // 使用下划线连接，避免用户名包含特殊字符时可能引发的问题
    return "Message_" + username;
}

/**
 * @brief 将一条聊天消息插入到对应的表中。
 *
 * 首先确保表存在，然后使用预处理语句 (prepared statement) 来安全地插入数据，
 * 防止SQL注入。
 * @param username 与之聊天的用户账号。
 * @param chatMessage 要插入的消息对象。
 */
void DatabaseManager::insertChatMessageSlot(const QString &username, ChatMessage *chatMessage)
{
    QString tableName = getTableName(username);
    if (tableExist(tableName))
    {
        // 使用自增主键后，不再需要手动计算index
        QString query_insert = "INSERT INTO " + tableName +
                               " (msg_sender, msg_datetime, msg_chatMessage, msg_state) VALUES(?, ?, ?, ?);";
        QSqlQuery query(m_database);
        query.prepare(query_insert);
        query.addBindValue(chatMessage->sender());
        query.addBindValue(chatMessage->dateTime());
        query.addBindValue(chatMessage->message());
        query.addBindValue(int(chatMessage->state()));

        if (!query.exec())
        {
            qDebug() << "DatabaseManager::insertChatMessageSlot: " << query.lastError().text();
            closeDatabaseSlot();
        }
    }
}

/**
 * @brief 从数据库中获取最近的N条聊天记录。
 *
 * @param username 与之聊天的用户账号。
 * @param count 希望获取的消息数量。
 * @param chatMessageList 用于存放结果的消息列表对象。该对象应属于主线程。
 */
void DatabaseManager::getChatMessageSlot(const QString &username, int count, ChatMessageList *chatMessageList)
{
    QString tableName = getTableName(username);
    if (tableExist(tableName))
    {
        QSqlQuery query(m_database);

        // 使用 ORDER BY 和 LIMIT 来获取最后N条记录，效率更高
        QString select = QString("SELECT msg_sender, msg_datetime, msg_chatMessage, msg_state FROM " + tableName +
                                 " ORDER BY msg_index DESC LIMIT %1")
                             .arg(count);

        if (query.exec(select))
        {
            // 因为是倒序查询，需要将结果暂存再正序插入
            QList<ChatMessage> results;
            while (query.next())
            {
                ChatMessage chatMessage;
                chatMessage.setSender(query.value(0).toString());
                chatMessage.setDateTime(query.value(1).toString());
                chatMessage.setMessage(query.value(2).toString());
                chatMessage.setState(ChatMessageStatus::Status(query.value(3).toInt()));
                results.prepend(chatMessage); // 插入到列表头部，实现正序
            }

            for (const auto &msg : results)
            {
                // 使用 QMetaObject::invokeMethod 进行跨线程调用，安全地将数据添加到主线程的Model中
                QMetaObject::invokeMethod(chatMessageList, "append", Qt::QueuedConnection, Q_ARG(ChatMessage, msg));
            }
        }
        else
        {
            qDebug() << "DatabaseManager::getChatMessageSlot: " << query.lastError().text();
            closeDatabaseSlot();
        }
    }
}