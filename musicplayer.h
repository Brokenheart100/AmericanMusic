#ifndef MUSICPLAYER_H
#define MUSICPLAYER_H

#include <QObject>
#include <QMediaPlayer>
#include "playlistmodel.h"
#include <taglib/tag.h>
#include <taglib/fileref.h>
#include <taglib/tpropertymap.h>
#include <taglib/mpegfile.h>
#include <taglib/flacfile.h>
#include <taglib/id3v2tag.h>
#include <taglib/attachedpictureframe.h>
#include <taglib/vorbisfile.h>
#include <taglib/xiphcomment.h>
#include <QStandardPaths>
#include <QFileInfo>

class QAudioOutput;

class MusicPlayer : public QObject
{
    Q_OBJECT
    Q_PROPERTY(PlaylistModel *playlistModel READ playlistModel CONSTANT)
    Q_PROPERTY(QMediaPlayer::PlaybackState status READ status NOTIFY statusChanged)
    Q_PROPERTY(int currentIndex READ currentIndex NOTIFY currentIndexChanged)

    Q_PROPERTY(QUrl currentCoverSource READ currentCoverSource NOTIFY currentSongChanged)
    Q_PROPERTY(QString currentTitle READ currentTitle NOTIFY currentSongChanged)
    Q_PROPERTY(QString currentArtist READ currentArtist NOTIFY currentSongChanged)

    Q_PROPERTY(qint64 duration READ duration NOTIFY durationChanged)
    Q_PROPERTY(qint64 position READ position NOTIFY positionChanged)

    Q_PROPERTY(QMediaPlayer::PlaybackState status READ status NOTIFY statusChanged)

public:
    explicit MusicPlayer(QObject *parent = nullptr);

    PlaylistModel *playlistModel() const;
    int currentIndex() const;

    QUrl currentCoverSource() const;
    QString currentTitle() const;
    QString currentArtist() const;

    qint64 duration() const;
    qint64 position() const;
    QMediaPlayer::PlaybackState status() const;

    Q_INVOKABLE void addSongsFromFolder(const QUrl &folderUrl);
    Q_INVOKABLE void play(int index);
    Q_INVOKABLE void pause();
    Q_INVOKABLE void stop();
    Q_INVOKABLE void next();
    Q_INVOKABLE void previous();
    Q_INVOKABLE void setPosition(qint64 position);

signals:
    void currentIndexChanged();
    void currentSongChanged();

    void durationChanged();
    void positionChanged();
    void statusChanged();

private slots:
    void onMediaStatusChanged(QMediaPlayer::MediaStatus status);

private:
    void processFolder(const QString &folderPath);
    QUrl saveEmbeddedCover(const QFileInfo &audioFileInfo);
    QString formatDuration(qint64 milliseconds);

    QUrl extractCoverAsDataUrl(const QFileInfo &audioFileInfo);

    QMediaPlayer *m_player;
    QAudioOutput *m_audioOutput;
    PlaylistModel *m_playlistModel;
    int m_currentIndex;
    bool m_playOnLoaded = false;

    PlaylistModel::Song m_currentSong;
};

#endif // MUSICPLAYER_H