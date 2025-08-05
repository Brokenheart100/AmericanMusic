#include "jsonparse.h"
#include "friendgroup.h" // 包含完整定义
#include "friendmodel.h"
#include "iteminfo.h"
#include "chatmanager.h" // 需要访问 ChatManager 单例

#include <QDir>
#include <QJsonObject>
#include <QJsonArray>
#include <QVariant>
#include <QFileInfo> // 用于 infoToJson
#include <QDebug>

/**
 * @brief JsonParser的构造函数。
 * @param doc 初始的QJsonDocument对象。
 */
JsonParser::JsonParser(const QJsonDocument &doc)
    : m_doc(doc)
{
}

/**
 * @brief JsonParser的析构函数。
 */
JsonParser::~JsonParser()
{
}

/**
 * @brief 设置要解析的JSON文档。
 * @param doc 新的QJsonDocument对象。
 */
void JsonParser::setJsonDocument(const QJsonDocument &doc)
{
    if (!doc.isNull())
        m_doc = doc;
}

/**
 * @brief 获取当前正在使用的JSON文档。
 * @return 当前的QJsonDocument对象。
 */
QJsonDocument JsonParser::jsonDocument() const
{
    return m_doc;
}

/**
 * @brief 从当前JSON文档中解析出当前登录用户的信息。
 *
 * 假定JSON文档的根是一个对象，其中包含了用户的各种属性。
 * @return 返回一个包含用户信息的 FriendInfo 对象指针。如果解析失败，返回nullptr。
 */
ItemInfo *JsonParser::userInfo()
{
    if (m_doc.isObject())
    {
        FriendInfo *info = new FriendInfo;
        QJsonObject object = m_doc.object();

        QString username;
        QJsonValue value = object.value("Username");
        if (value.isString())
        {
            username = value.toString();
            info->setUsername(username);
        }

        value = object.value("Nickname");
        if (value.isString())
            info->setNickname(value.toString());

        value = object.value("Gender");
        if (value.isString())
            info->setGender(value.toString());

        value = object.value("HeadImage");
        if (value.isString())
        {
            QString image = value.toString();
            if (image.left(3) == "qrc") // 如果是qrc资源
                info->setHeadImage(image);
            else // 否则认为是需要拼接的本地文件路径
                info->setHeadImage("file:///" + QDir::homePath() + "/MChat/Settings/" +
                                   username + "/headImage/" + image);
        }

        value = object.value("Background");
        if (value.isString())
        {
            QString image = value.toString();
            if (image.left(3) == "qrc" || image.isEmpty())
                info->setBackground(image);
            else
                info->setBackground("file:///" + QDir::homePath() + "/MChat/Settings/" +
                                    username + "/" + image);
        }

        value = object.value("Signature");
        if (value.isString())
            info->setSignature(value.toString());

        value = object.value("Birthday");
        if (value.isString())
            info->setBirthday(value.toString());

        value = object.value("Level");
        if (value.isDouble())
            info->setLevel(value.toInt());

        return info;
    }
    return nullptr;
}

/**
 * @brief 从当前JSON文档中解析出完整的好友列表和分组信息。
 *
 * JSON结构应为: { "FriendList": [ { "Group": "GroupName", "Friend": [ {friend_info}, ... ] }, ... ] }
 * @param friendGroup 用于填充好友分组数据的 FriendGroup 对象指针。
 * @param friendList 用于填充好友列表映射的 QMap 指针。
 */
void JsonParser::createFriend(FriendGroup *friendGroup, QMap<QString, ItemInfo *> *friendList)
{
    QList<FriendModel *> groups;
    if (m_doc.isObject())
    {
        QJsonValue value = m_doc.object().value("FriendList");
        if (value.isArray())
        {
            QJsonArray friendGroupArray = value.toArray();
            // 遍历每个好友分组
            for (const auto &groupValue : friendGroupArray)
            {
                QList<ItemInfo *> friends;
                QJsonObject friendGroupObject = groupValue.toObject();
                value = friendGroupObject.value("Friend");
                if (value.isArray())
                {
                    QJsonArray friendArray = value.toArray();
                    // 遍历分组内的每个好友
                    for (const auto &friendValue : friendArray)
                    {
                        QJsonObject object = friendValue.toObject();
                        FriendInfo *info = new FriendInfo(friendGroup);
                        QString username;

                        // 解析好友的详细信息
                        value = object.value("Username");
                        if (value.isString())
                        {
                            username = value.toString();
                            info->setUsername(username);
                        }
                        // ... (此处省略了与userInfo函数中重复的解析代码)
                        value = object.value("Nickname");
                        if (value.isString())
                            info->setNickname(value.toString());
                        value = object.value("Gender");
                        if (value.isString())
                            info->setGender(value.toString());
                        value = object.value("HeadImage");
                        if (value.isString())
                        {
                            QString image = value.toString();
                            if (image.left(3) == "qrc")
                                info->setHeadImage(image);
                            else
                                info->setHeadImage("file:///" + QDir::homePath() + "/MChat/Settings/" +
                                                   username + "/headImage/" + image);
                        }
                        value = object.value("Background");
                        if (value.isString())
                        {
                            QString image = value.toString();
                            if (image.left(3) == "qrc" || image.isEmpty())
                                info->setBackground(image);
                            else
                                info->setBackground("file:///" + QDir::homePath() + "/MChat/Settings/" +
                                                    username + "/" + image);
                        }
                        value = object.value("Signature");
                        if (value.isString())
                            info->setSignature(value.toString());
                        value = object.value("Birthday");
                        if (value.isString())
                            info->setBirthday(value.toString());
                        value = object.value("UnreadMessage");
                        if (value.isDouble())
                            info->setUnreadMessage(value.toInt());
                        value = object.value("Level");
                        if (value.isDouble())
                            info->setLevel(value.toInt());

                        info->loadRecord();                         // 加载本地聊天记录
                        friendList->insert(info->username(), info); // 添加到全局好友列表
                        friends.append(info);                       // 添加到当前分组的好友列表
                    }
                }
                QString groupName = friendGroupObject.value("Group").toString();
                FriendModel *friendModel = new FriendModel(groupName, friends.count(), friends, friendGroup);
                groups.append(friendModel);
            }
        }
    }
    friendGroup->setData(groups); // 设置好友分组模型的最终数据
}

/**
 * @brief 将一个 ItemInfo (实际上是 FriendInfo) 对象序列化为JSON格式的QByteArray。
 * @param info 要序列化的用户信息对象指针。
 * @return 包含JSON数据的QByteArray。如果序列化失败，返回空的QByteArray。
 */
QByteArray JsonParser::infoToJson(ItemInfo *info)
{
    FriendInfo *userInfo = qobject_cast<FriendInfo *>(info);
    if (!userInfo)
        return QByteArray(); // 类型转换失败，返回空

    QJsonObject object;
    object.insert("Username", userInfo->username());
    object.insert("Nickname", userInfo->nickname());
    object.insert("Gender", userInfo->gender());
    object.insert("Background", userInfo->background());
    // 注意：这里将当前用户的密码也打包进去了
    object.insert("Password", ChatManager::instance()->password());

    QString headImage = userInfo->headImage();
    // 如果头像是本地文件路径，只取文件名部分
    if (headImage.startsWith("file:///"))
    {
        headImage = QFileInfo(headImage).fileName();
    }
    object.insert("HeadImage", headImage);
    object.insert("Signature", userInfo->signature());
    object.insert("Birthday", userInfo->birthday());
    object.insert("Level", userInfo->level());

    QJsonDocument doc(object);
    qDebug() << __func__ << "成功!";
    return doc.toJson();
}

/**
 * @brief 将一个包含单个用户信息的JSON数据反序列化为一个 ItemInfo 对象。
 *
 * 通常用于处理服务器返回的搜索结果或新好友信息。
 * @param data 包含JSON数据的QByteArray。
 * @return 返回一个包含用户信息的 FriendInfo 对象指针。如果反序列化失败，返回nullptr。
 */
ItemInfo *JsonParser::jsonToInfo(const QByteArray &data)
{
    QJsonParseError error;
    QJsonDocument doc = QJsonDocument::fromJson(data, &error);
    if (!doc.isNull() && (error.error == QJsonParseError::NoError))
    {
        if (doc.isObject())
        {
            FriendInfo *info = new FriendInfo;
            QJsonObject object = doc.object();
            QString username;

            // 解析逻辑与 userInfo() 基本相同
            QJsonValue value = object.value("Username");
            if (value.isString())
            {
                username = value.toString();
                info->setUsername(username);
            }
            value = object.value("Nickname");
            if (value.isString())
                info->setNickname(value.toString());
            value = object.value("Gender");
            if (value.isString())
                info->setGender(value.toString());
            value = object.value("Background");
            if (value.isString())
                info->setBackground(value.toString());
            value = object.value("HeadImage");
            if (value.isString())
            {
                QString image = value.toString();
                if (image.left(3) == "qrc")
                    info->setHeadImage(image);
                else // 注意：这里拼接的是当前登录用户的路径，而不是对方用户的路径
                    info->setHeadImage("file:///" + QDir::homePath() + "/MChat/Settings/" +
                                       ChatManager::instance()->username() + "/headImage/" + image);
            }
            value = object.value("Signature");
            if (value.isString())
                info->setSignature(value.toString());
            value = object.value("Birthday");
            if (value.isString())
                info->setBirthday(value.toString());
            value = object.value("Level");
            if (value.isDouble())
                info->setLevel(value.toInt());

            return info;
        }
    }

    qDebug() << "JsonParser::jsonToInfo failed:" << error.errorString();
    return nullptr;
}