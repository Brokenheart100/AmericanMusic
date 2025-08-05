#ifndef JSONPARSE_H
#define JSONPARSE_H

#include <QJsonDocument>
#include <QMap> // 包含QMap的完整定义

// 前向声明，以减少头文件依赖
class FriendGroup;
class ItemInfo;

/**
 * @class JsonParser
 * @brief JSON数据解析器类。
 *
 * 该类不继承自QObject，是一个纯粹的工具类，负责处理应用程序中
 * 所有与JSON相关的序列化和反序列化操作。它将JSON数据与C++的数据模型
 * （如 ItemInfo, FriendInfo, FriendGroup）进行相互转换。
 */
class JsonParser
{
public:
    /**
     * @brief JsonParser的构造函数。
     * @param doc 初始的QJsonDocument对象。
     */
    JsonParser(const QJsonDocument &doc);
    ~JsonParser();

    /**
     * @brief 设置要解析的JSON文档。
     * @param doc 新的QJsonDocument对象。
     */
    void setJsonDocument(const QJsonDocument &doc);

    /**
     * @brief 获取当前正在使用的JSON文档。
     * @return 当前的QJsonDocument对象。
     */
    QJsonDocument jsonDocument() const;

public:
    /**
     * @brief 从当前JSON文档中解析出当前登录用户的信息。
     * @return 返回一个包含用户信息的 FriendInfo 对象指针。如果解析失败，返回nullptr。
     */
    ItemInfo *userInfo();

    /**
     * @brief 从当前JSON文档中解析出完整的好友列表和分组信息。
     * @param friendGroup 用于填充好友分组数据的 FriendGroup 对象指针。
     * @param friendList 用于填充好友列表映射的 QMap 指针。
     */
    void createFriend(FriendGroup *friendGroup, QMap<QString, ItemInfo *> *friendList);

    /**
     * @brief 将一个 ItemInfo (实际上是 FriendInfo) 对象序列化为JSON格式的QByteArray。
     * @param info 要序列化的用户信息对象指针。
     * @return 包含JSON数据的QByteArray。如果序列化失败，返回空的QByteArray。
     */
    QByteArray infoToJson(ItemInfo *info);

    /**
     * @brief 将一个包含单个用户信息的JSON数据反序列化为一个 ItemInfo 对象。
     * @param data 包含JSON数据的QByteArray。
     * @return 返回一个包含用户信息的 FriendInfo 对象指针。如果反序列化失败，返回nullptr。
     */
    ItemInfo *jsonToInfo(const QByteArray &data);

private:
    QJsonDocument m_doc; //!< 存储当前要操作的JSON文档。
};

#endif // JSONPARSE_H