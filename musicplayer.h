#ifndef MUSICPLAYER_H
#define MUSICPLAYER_H

#include <QObject>
#include <QMediaPlayer>
#include "playlistmodel.h"

class QAudioOutput;

class MusicPlayer : public QObject
{
    Q_OBJECT
    Q_PROPERTY(PlaylistModel *playlistModel READ playlistModel CONSTANT)
    Q_PROPERTY(QMediaPlayer::PlaybackState status READ status NOTIFY statusChanged)
    Q_PROPERTY(qint64 position READ position NOTIFY positionChanged)
    Q_PROPERTY(qint64 duration READ duration NOTIFY durationChanged)
    Q_PROPERTY(int currentIndex READ currentIndex NOTIFY currentIndexChanged)

public:
    explicit MusicPlayer(QObject *parent = nullptr);

    PlaylistModel *playlistModel() const;
    QMediaPlayer::PlaybackState status() const;
    qint64 position() const;
    qint64 duration() const;
    int currentIndex() const;

    Q_INVOKABLE void openFolder();
    Q_INVOKABLE void addSongsFromFolder(const QUrl &folderUrl);
    Q_INVOKABLE void play(int index);
    Q_INVOKABLE void pause();
    Q_INVOKABLE void stop();
    Q_INVOKABLE void next();
    Q_INVOKABLE void previous();
    Q_INVOKABLE void setPosition(qint64 position);

signals:
    void statusChanged();
    void positionChanged();
    void durationChanged();
    void currentIndexChanged();

private slots:
    void onMediaStatusChanged(QMediaPlayer::MediaStatus status);

private:
    QMediaPlayer *m_player;
    QAudioOutput *m_audioOutput;
    PlaylistModel *m_playlistModel;
    int m_currentIndex;
    bool m_playOnLoaded = false;
};

#endif // MUSICPLAYER_H