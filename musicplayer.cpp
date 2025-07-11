#include "musicplayer.h"
#include <QAudioOutput>
#include <QDirIterator>
#include <QFileInfo>
#include <QFileDialog>

MusicPlayer::MusicPlayer(QObject *parent)
    : QObject(parent),
      m_currentIndex(-1)
{
    m_player = new QMediaPlayer(this);
    m_audioOutput = new QAudioOutput(this);
    m_player->setAudioOutput(m_audioOutput);
    m_playlistModel = new PlaylistModel(this);

    // 连接信号和槽，以便在QML中更新属性
    connect(m_player, &QMediaPlayer::playbackStateChanged, this, &MusicPlayer::statusChanged);
    connect(m_player, &QMediaPlayer::positionChanged, this, &MusicPlayer::positionChanged);
    connect(m_player, &QMediaPlayer::durationChanged, this, &MusicPlayer::durationChanged);
    connect(m_player, &QMediaPlayer::mediaStatusChanged, this, &MusicPlayer::onMediaStatusChanged);
}

PlaylistModel *MusicPlayer::playlistModel() const
{
    return m_playlistModel;
}
// 添加这个新方法
void MusicPlayer::addSongsFromFolder(const QUrl &folderUrl)
{
    qDebug() << "Adding songs from folder:" << folderUrl.toString();
    const QString folderPath = folderUrl.toLocalFile();

    if (folderPath.isEmpty())
    {
        return;
    }

    m_playlistModel->clear();
    m_currentIndex = -1;
    emit currentIndexChanged();

    QList<PlaylistModel::Song> songs;
    QDirIterator it(folderPath, {"*.mp3", "*.flac", "*.wav", "*.ogg"}, QDir::Files, QDirIterator::Subdirectories);
    while (it.hasNext())
    {
        it.next();
        QFileInfo fileInfo = it.fileInfo();
        PlaylistModel::Song song;
        song.title = fileInfo.baseName();
        song.path = QUrl::fromLocalFile(fileInfo.absoluteFilePath());
        songs.append(song);
    }

    if (!songs.isEmpty())
    {
        m_playlistModel->addSongs(songs);
    }
}
QMediaPlayer::PlaybackState MusicPlayer::status() const
{
    return m_player->playbackState();
}

qint64 MusicPlayer::position() const
{
    return m_player->position();
}

qint64 MusicPlayer::duration() const
{
    return m_player->duration();
}

int MusicPlayer::currentIndex() const
{
    return m_currentIndex;
}

void MusicPlayer::openFolder()
{
    const QString folderPath = QFileDialog::getExistingDirectory(nullptr, "选择音乐文件夹");
    if (folderPath.isEmpty())
    {
        return;
    }

    m_playlistModel->clear();
    m_currentIndex = -1;
    emit currentIndexChanged();

    QList<PlaylistModel::Song> songs;
    QDirIterator it(folderPath, {"*.mp3", "*.flac", "*.wav", "*.ogg"}, QDir::Files, QDirIterator::Subdirectories);
    while (it.hasNext())
    {
        it.next();
        QFileInfo fileInfo = it.fileInfo();
        // songs.append({fileInfo.baseName(), QUrl::fromLocalFile(fileInfo.absoluteFilePath())});
    }

    if (!songs.isEmpty())
    {
        m_playlistModel->addSongs(songs);
    }
}

void MusicPlayer::play(int index)
{
    if (index < 0 || index >= m_playlistModel->rowCount())
    {
        return;
    }
    m_currentIndex = index;
    emit currentIndexChanged();
    m_playOnLoaded = true;
    m_player->setSource(m_playlistModel->getSong(index).path);
    m_player->play();
}

void MusicPlayer::pause()
{
    m_playOnLoaded = false;
    m_player->pause();
}

void MusicPlayer::stop()
{
    m_player->stop();
}

void MusicPlayer::next()
{
    if (m_playlistModel->rowCount() == 0)
        return;
    int newIndex = (m_currentIndex + 1) % m_playlistModel->rowCount();
    play(newIndex);
}

void MusicPlayer::previous()
{
    if (m_playlistModel->rowCount() == 0)
        return;
    int newIndex = (m_currentIndex - 1 + m_playlistModel->rowCount()) % m_playlistModel->rowCount();
    play(newIndex);
}

void MusicPlayer::setPosition(qint64 position)
{
    m_player->setPosition(position);
}

void MusicPlayer::onMediaStatusChanged(QMediaPlayer::MediaStatus status)
{
    switch (status)
    {
    case QMediaPlayer::LoadedMedia:
        if (m_playOnLoaded)
        {
            m_player->play();
            m_playOnLoaded = false; // 重置标志位
        }
        break;
    case QMediaPlayer::InvalidMedia:
        // 媒体文件无效或损坏
        qDebug() << "Error: Invalid media file:" << m_player->source();
        m_playOnLoaded = false; // 无法播放，重置标志位
        // 可以在这里触发一个信号告诉UI播放失败，或者自动跳到下一首
        next();
        break;

    case QMediaPlayer::EndOfMedia:
        // 歌曲播放完毕，自动播放下一首
        next();
        break;

    default:
        // 处理其他状态，如 NoMedia, Buffering, Stalled...
        break;
    }
}