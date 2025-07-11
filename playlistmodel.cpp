#include "playlistmodel.h"

PlaylistModel::PlaylistModel(QObject *parent)
    : QAbstractListModel(parent)
{
}

int PlaylistModel::rowCount(const QModelIndex &parent) const
{
    if (parent.isValid())
        return 0;
    return m_songs.count();
}

QVariant PlaylistModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid() || index.row() >= m_songs.count())
        return QVariant();

    const Song &song = m_songs[index.row()];
    switch (role)
    {
    case TitleRole:
        return song.title;
    case ArtistRole:
        return song.artist;
    case AlbumRole:
        return song.album;
    case DurationRole:
        return song.duration; // 返回毫秒数
    case CoverSourceRole:
        return song.coverSource;
    case PathRole:
        return song.path;
    default:
        return QVariant();
    }
}

QHash<int, QByteArray> PlaylistModel::roleNames() const
{
    QHash<int, QByteArray> roles;
    roles[PathRole] = "path";
    roles[TitleRole] = "title";
    roles[ArtistRole] = "artist";
    roles[AlbumRole] = "album";
    roles[DurationRole] = "duration";
    roles[CoverSourceRole] = "coverSource";
    return roles;
}

void PlaylistModel::addSongs(const QList<Song> &songs)
{
    beginInsertRows(QModelIndex(), rowCount(), rowCount() + songs.count() - 1);
    m_songs.append(songs);
    endInsertRows();
}

void PlaylistModel::clear()
{
    beginResetModel();
    m_songs.clear();
    endResetModel();
}

PlaylistModel::Song PlaylistModel::getSong(int index) const
{
    if (index < 0 || index >= m_songs.count())
    {
        return {};
    }
    return m_songs.at(index);
}