import QtQuick

QtObject {
    readonly property list<var> conversations: [
        {
            name: "高...",
            lastMessage: "[小号1]...",
            avatar: "https://i.imgur.com/O3hY0dih.jpg"
        },
        {
            name: "H... 星...",
            lastMessage: "哈哈哈...",
            avatar: "https://i.imgur.com/r53i933h.jpg"
        },
        {
            name: "天...",
            lastMessage: "对方已...",
            avatar: "https://i.imgur.com/uG3pP1Bh.jpg"
        },
        {
            name: "小...",
            lastMessage: "对方已成...",
            avatar: "https://i.imgur.com/8zTCG8Mh.jpg"
        }
    ]

    readonly property list<var> messages: [
        {
            type: "system",
            text: "12:44"
        },
        {
            type: "incoming",
            author: "<阿凯> LV100 管理员",
            text: "你最近在干嘛",
            avatar: "https://i.imgur.com/N8MPlrhh.jpg"
        },
        {
            type: "system",
            text: "13:22"
        },
        {
            type: "outgoing",
            author: "[小号1] LV100 群主",
            text: "😆",
            avatar: "https://i.imgur.com/uG3pP1Bh.jpg"
        }
    ]
}
