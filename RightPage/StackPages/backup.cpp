#include "musicplayer.h"
#include <QAudioOutput>
#include <QDirIterator>
#include <QFileInfo>
#include <QFileDialog>
#include <QRandomGenerator>

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
QUrl MusicPlayer::saveEmbeddedCover(const QFileInfo &audioFileInfo)
{
    // 将文件路径转为 TagLib 可用的格式
    TagLib::FileRef fileRef(audioFileInfo.absoluteFilePath().toStdWString().c_str());
    if (fileRef.isNull())
    {
        return QUrl();
    }

    // 尝试从不同文件类型的标签中提取封面
    const TagLib::Tag *tag = fileRef.tag();
    QImage coverImage;

    // --- 尝试 MP3 (ID3v2) ---
    TagLib::MPEG::File *mpegFile = dynamic_cast<TagLib::MPEG::File *>(fileRef.file());
    if (mpegFile && mpegFile->ID3v2Tag())
    {
        const TagLib::ID3v2::FrameList frames = mpegFile->ID3v2Tag()->frameList("APIC");
        if (!frames.isEmpty())
        {
            auto picFrame = static_cast<TagLib::ID3v2::AttachedPictureFrame *>(frames.front());
            coverImage.loadFromData(reinterpret_cast<const uchar *>(picFrame->picture().data()), picFrame->picture().size());
        }
    }

    // --- 尝试 FLAC/OGG (Vorbis Comment) ---
    if (coverImage.isNull())
    {
        TagLib::Ogg::XiphComment *vorbis = nullptr;
        if (dynamic_cast<TagLib::FLAC::File *>(fileRef.file()))
        {
            vorbis = dynamic_cast<TagLib::FLAC::File *>(fileRef.file())->xiphComment();
        }
        else if (dynamic_cast<TagLib::Ogg::Vorbis::File *>(fileRef.file()))
        {
            vorbis = dynamic_cast<TagLib::Ogg::Vorbis::File *>(fileRef.file())->tag();
        }
        if (vorbis && vorbis->pictureList().size() > 0)
        {
            const TagLib::FLAC::Picture *pic = vorbis->pictureList()[0];
            coverImage.loadFromData(reinterpret_cast<const uchar *>(pic->data().data()), pic->data().size());
        }
    }

    // 如果成功加载了图片，就保存它
    if (!coverImage.isNull())
    {
        // 1. 获取一个可写的缓存目录
        QString cachePath = QStandardPaths::writableLocation(QStandardPaths::CacheLocation) + "/covers";
        QDir cacheDir(cachePath);
        if (!cacheDir.exists())
        {
            cacheDir.mkpath("."); // 确保目录存在
        }

        // 2. 创建一个唯一的文件名（例如，使用音频文件的基本名）
        QString coverFileName = audioFileInfo.completeBaseName() + ".jpg";
        QString coverFilePath = cachePath + "/" + coverFileName;

        // 3. 保存图片
        if (coverImage.save(coverFilePath, "JPG"))
        {
            // 4. 返回这个临时文件的 URL
            return QUrl::fromLocalFile(coverFilePath);
        }
    }

    // 如果所有尝试都失败了，返回一个空 URL
    return QUrl();
}
PlaylistModel *MusicPlayer::playlistModel() const
{
    return m_playlistModel;
}

QString MusicPlayer::formatDuration(qint64 milliseconds)
{
    qint64 totalSeconds = milliseconds / 1000;
    qint64 minutes = totalSeconds / 60;
    qint64 seconds = totalSeconds % 60;

    // 使用QString::arg()确保两位数格式（例如 03:05 而非 3:5）
    return QString("%1:%2")
        .arg(minutes, 2, 10, QChar('0'))  // 分钟，至少2位，不足补0
        .arg(seconds, 2, 10, QChar('0')); // 秒，至少2位，不足补0
}
/**
 * @brief 使用 TagLib 尝试从音频文件中提取内嵌封面。
 *
 * 如果成功，它会将封面保存到应用的缓存目录中，并返回一个本地文件的 QUrl。
 * 如果失败或没有内嵌封面，它会返回一个空的 QUrl。
 *
 * @param audioFileInfo 指向音频文件的 QFileInfo 对象。
 * @return QUrl 封面临时文件的路径，如果失败则为空。
 */
QUrl extractAndSaveEmbeddedCover(const QFileInfo &audioFileInfo)
{
    // 使用 TagLib::FileRef 打开文件。注意路径需要转换为 TagLib 接受的格式。
    TagLib::FileRef fileRef(audioFileInfo.absoluteFilePath().toStdWString().c_str());

    if (fileRef.isNull())
    {
        qDebug() << "TagLib: Could not open file" << audioFileInfo.fileName();
        return QUrl(); // 文件打开失败，返回空
    }

    QImage coverImage;

    // --- 策略1: 尝试解析为 MP3 文件 (ID3v2 标签) ---
    // 我们使用 dynamic_cast 来安全地尝试将通用文件指针转换为特定的 MPEG 文件指针。
    TagLib::MPEG::File *mpegFile = dynamic_cast<TagLib::MPEG::File *>(fileRef.file());
    if (mpegFile && mpegFile->ID3v2Tag())
    {
        TagLib::ID3v2::Tag *id3v2tag = mpegFile->ID3v2Tag();
        // APIC 帧代表 "Attached Picture"
        const TagLib::ID3v2::FrameList frames = id3v2tag->frameList("APIC");
        if (!frames.isEmpty())
        {
            auto picFrame = static_cast<TagLib::ID3v2::AttachedPictureFrame *>(frames.front());
            // 从二进制数据加载 QImage
            coverImage.loadFromData(reinterpret_cast<const uchar *>(picFrame->picture().data()), picFrame->picture().size());
        }
    }

    // --- 策略2: 如果不是 MP3，尝试解析为 FLAC 文件 ---
    if (coverImage.isNull())
    {
        TagLib::FLAC::File *flacFile = dynamic_cast<TagLib::FLAC::File *>(fileRef.file());
        if (flacFile && !flacFile->pictureList().isEmpty())
        {
            const TagLib::FLAC::Picture *pic = flacFile->pictureList()[0]; // 获取第一张封面
            coverImage.loadFromData(reinterpret_cast<const uchar *>(pic->data().data()), pic->data().size());
        }
    }

    // --- 如果成功从任何一种格式中加载了图片，就保存它 ---
    if (!coverImage.isNull())
    {
        // 1. 获取一个安全的可写目录（应用的缓存目录是最佳选择）
        QString cachePath = QStandardPaths::writableLocation(QStandardPaths::CacheLocation) + "/album_covers";
        QDir cacheDir(cachePath);
        if (!cacheDir.exists())
        {
            cacheDir.mkpath("."); // 如果目录不存在，就创建它
        }

        // 2. 创建一个可预测但不容易冲突的文件名
        // (可以使用 hash 或者就是音频文件名)
        QString coverFileName = audioFileInfo.completeBaseName() + ".jpg";
        QString coverFilePath = cachePath + "/" + coverFileName;

        // 3. 将 QImage 保存为 JPG 文件
        if (coverImage.save(coverFilePath, "JPG"))
        {
            qDebug() << "TagLib: Saved embedded cover to" << coverFilePath;
            // 4. 返回这个新创建的临时文件的 QUrl
            return QUrl::fromLocalFile(coverFilePath);
        }
        else
        {
            qDebug() << "TagLib: Failed to save cover image for" << audioFileInfo.fileName();
        }
    }

    // 如果所有尝试都失败了，返回一个空 URL
    return QUrl();
}
void MusicPlayer::processFolder(const QString &folderPath)
{
    if (folderPath.isEmpty())
        return;

    m_playlistModel->clear();
    m_player->stop();
    m_currentIndex = -1;
    m_currentSong = {};
    emit currentIndexChanged();
    emit currentSongChanged();

    QList<PlaylistModel::Song> foundSongs;
    QDirIterator it(folderPath, {"*.mp3", "*.flac", "*.wav", "*.m4a"}, QDir::Files | QDir::NoDotAndDotDot, QDirIterator::Subdirectories);

    while (it.hasNext())
    {
        QFileInfo fileInfo(it.next());
        PlaylistModel::Song song;
        song.path = QUrl::fromLocalFile(fileInfo.absoluteFilePath());

        // --- ✅ 步骤 2: 使用 TagLib 解析元数据 ---
        // TagLib 需要一个宽字符路径，我们用 toStdWString() 转换
        TagLib::FileRef f(fileInfo.absoluteFilePath().toStdWString().c_str());

        if (!f.isNull() && f.tag())
        {
            TagLib::Tag *tag = f.tag();

            song.title = QString::fromUtf8(tag->title().toCString(true));
            song.artist = QString::fromUtf8(tag->artist().toCString(true));
            song.album = QString::fromUtf8(tag->album().toCString(true));
            // 如果标签中没有标题，就用文件名
            if (song.title.isEmpty())
            {
                song.title = fileInfo.completeBaseName();
            }
        }
        else
        {
            // 如果解析失败，使用文件名作为备用
            song.title = fileInfo.completeBaseName();
            song.artist = "Unknown Artist";
            song.album = "Unknown Album";
        }
        qDebug() << "Found song:" << song.title << "by" << song.artist << "from album" << song.album;

        // 获取时长 (可选，QMediaPlayer 也可以做)
        if (!f.isNull() && f.audioProperties())
        {
            song.duration = f.audioProperties()->lengthInMilliseconds();
        }
        else
        {
            song.duration = 0;
        }

        // 1. 尝试提取内嵌封面
        song.coverSource = saveEmbeddedCover(fileInfo);
        // 2. 如果内嵌封面不存在，再尝试查找外部同名文件
        if (song.coverSource.isEmpty())
        {
            QDir songDir = fileInfo.dir();
            QString baseName = fileInfo.completeBaseName();
            QFileInfo coverInfo(songDir, baseName + ".jpg");
            if (coverInfo.exists())
            {
                song.coverSource = QUrl::fromLocalFile(coverInfo.absoluteFilePath());
            }
            else
            {
                coverInfo.setFile(songDir, baseName + ".png");
                if (coverInfo.exists())
                {
                    song.coverSource = QUrl::fromLocalFile(coverInfo.absoluteFilePath());
                }
            }
        }

        // 查找同名封面
        QFileInfo coverInfo(fileInfo.dir(), fileInfo.completeBaseName() + ".jpg");
        if (coverInfo.exists())
        {
            song.coverSource = QUrl::fromLocalFile(coverInfo.absoluteFilePath());
        }
        else
        {
            coverInfo.setFile(fileInfo.dir(), fileInfo.completeBaseName() + ".png");
            if (coverInfo.exists())
            {
                song.coverSource = QUrl::fromLocalFile(coverInfo.absoluteFilePath());
            }
            else
            {
                int randomIndex = QRandomGenerator::global()->bounded(51);

                // 设置封面路径（使用QUrl::fromLocalFile处理本地文件路径）
                song.coverSource = QUrl::fromLocalFile(
                    QString("E:/Computer/Qt6/AmericanMusic/CoverImage/%1.jpg").arg(randomIndex));
            }
        }
        foundSongs.append(song);
    }

    if (!foundSongs.isEmpty())
    {
        m_playlistModel->addSongs(foundSongs);
    }
}
// 添加这个新方法
void MusicPlayer::addSongsFromFolder(const QUrl &folderUrl)
{
    qDebug() << "Adding songs from folder:" << folderUrl.toString();
    processFolder(folderUrl.toLocalFile());
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
QString MusicPlayer::currentTitle() const
{
    return m_currentSong.title;
}

QString MusicPlayer::currentArtist() const
{
    return m_currentSong.artist;
}
QUrl MusicPlayer::currentCoverSource() const
{
    return m_currentSong.coverSource;
}
void MusicPlayer::play(int index)
{
    if (index < 0 || index >= m_playlistModel->rowCount())
    {
        return;
    }
    m_currentIndex = index;
    m_playOnLoaded = true;
    // ✅ 步骤 2: 在播放新歌曲时，获取封面 URL 并更新属性
    m_currentSong = m_playlistModel->getSong(index);

    // ✅ 然后再发出信号
    emit currentIndexChanged();
    emit currentSongChanged();

    m_player->setSource(m_currentSong.path);
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