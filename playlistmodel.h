#ifndef PLAYLISTMODEL_H
#define PLAYLISTMODEL_H

#include <QAbstractListModel>
#include <QList>
#include <QUrl>

class PlaylistModel : public QAbstractListModel
{
    Q_OBJECT

public:
    struct Song
    {
        QString title = "";
        QString artist = "";
        QString album = "";
        qint64 duration = 0; // 使用 qint64 存储毫秒数，更精确
        QUrl path = QUrl();
        QUrl coverSource = QUrl();
    };

    enum SongRoles
    {
        TitleRole = Qt::UserRole + 1,
        ArtistRole,
        AlbumRole,
        DurationRole,
        CoverSourceRole,
        PathRole
    };
    explicit PlaylistModel(QObject *parent = nullptr);

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    QHash<int, QByteArray> roleNames() const override;

    void addSongs(const QList<Song> &songs);
    void clear();
    Song getSong(int index) const;

private:
    QList<Song> m_songs;
};

#endif // PLAYLISTMODEL_H