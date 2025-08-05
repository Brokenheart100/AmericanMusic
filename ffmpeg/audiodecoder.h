#ifndef AUDIODECODER_H
#define AUDIODECODER_H

#include <QObject>
#include <QThread>
#include <QAudioFormat>
#include <QImage>

/**
 * @struct AudioPacket
 * @brief  定义一个解码后的音频数据包结构。
 *
 * 包含解码出的原始PCM音频数据以及该数据包对应的时间戳。
 */
typedef struct AudioPacket
{
    QByteArray data; ///< 存储PCM音频数据。
    qreal time;      ///< 该数据包开始播放的时间点（单位：秒）。
} AudioPacket;

// 前向声明，避免在头文件中包含不必要的完整定义
class AudioData;
class AudioDecoderPrivate;

/**
 * @class AudioDecoder
 * @brief 一个使用 FFmpeg 在独立线程中解码音频文件的类。
 *
 * 该类继承自 QThread，将所有耗时的解码操作放在 `run()` 方法中执行，
 * 从而避免阻塞主 UI 线程。它能够解码音频流和附带的视频流（通常用于获取封面）。
 *
 * @note 所有公开的成员函数都被设计为线程安全的。
 */
class AudioDecoder : public QThread
{
    Q_OBJECT
public:
    /**
     * @brief 构造函数。
     * @param parent 父QObject对象。
     */
    explicit AudioDecoder(QObject *parent = nullptr);

    /**
     * @brief 析构函数。
     *
     * 会确保解码线程被安全地停止和清理。
     */
    ~AudioDecoder();

    /**
     * @brief 静态工具函数，用于快速获取一个音频文件的基本信息。
     * @param data 一个指向 AudioData 对象的指针，函数将把解析出的信息填充到这个对象中。
     * @note 这是一个阻塞式操作，但通常很快完成。
     */
    static void getAudioInfo(AudioData *data);

    /**
     * @brief 请求停止当前的解码过程。
     *
     * 该方法是线程安全的。它会设置一个标志位，让解码循环在下一次迭代时退出。
     * @warning 调用此函数后，线程不会立即停止，需要等待当前循环结束。
     *          可以使用 `wait()` 来确保线程完全退出。
     */
    void stop();

    /**
     * @brief 打开一个新的媒体文件并开始解码。
     *
     * 该方法是线程安全的。它会首先停止任何正在进行的解码，然后配置新的文件名并启动解码线程。
     * @param filename 要打开的媒体文件的完整路径。
     */
    void open(const QString &filename);

    /**
     * @brief 跳转到指定的播放进度。
     *
     * 该方法是线程安全的。它会清空内部的缓冲队列，并请求 FFmpeg 跳转到最接近指定比例的时间点。
     * @param ratio 进度比例，取值范围在 0.0 到 1.0 之间。
     */
    void setProgress(qreal ratio);

    /**
     * @brief 获取音频文件的总时长。
     *
     * 该方法是线程安全的。
     * @return 音频文件的总时长（单位：秒）。
     * @note 必须在 `resolved()` 信号发出后调用，否则可能返回0。
     */
    qreal duration();

    /**
     * @brief 获取音频的标题。
     *
     * 该方法是线程安全的。
     * @return 从元数据中解析出的标题。如果元数据中没有，则返回不带后缀的文件名。
     */
    QString title();

    /**
     * @brief 获取音频的艺术家/歌手。
     *
     * 该方法是线程安全的。
     * @return 从元数据中解析出的艺术家。如果没有，则返回'未知'。
     */
    QString singer();

    /**
     * @brief 获取音频的专辑名称。
     *
     * 该方法是线程安全的。
     * @return 从元数据中解析出的专辑名称。如果没有，则返回'无'。
     */
    QString album();

    /**
     * @brief 获取解码输出的音频格式。
     *
     * 该方法是线程安全的。格式通常是PCM。
     * @return 一个 QAudioFormat 对象，描述了采样率、通道数、采样大小等信息。
     */
    QAudioFormat format();

    /**
     * @brief 从内部缓冲队列中取出一个解码后的音频包。
     *
     * 该方法是线程安全的。如果队列为空，它会立即返回一个空的数据包。
     * @return 一个 AudioPacket 结构体。可以通过检查 `packet.data.isEmpty()` 来判断是否成功取到数据。
     */
    AudioPacket currentPacket();

signals:
    /**
     * @brief 当解码过程中发生错误时发出此信号。
     * @param error 描述错误的字符串。
     */
    void error(const QString &error);

    /**
     * @brief 当文件被成功打开且流信息被解析完毕后发出此信号。
     *
     * 在此信号发出后，`duration()`, `title()`, `format()` 等函数才能返回有效值。
     * @warning 此信号在解复用之后、开始正式解码循环之前发出。
     */
    void resolved();

    /**
     * @brief 当从视频流中成功解码出第一帧图像（通常是封面）时发出此信号。
     *
     * 对于很多音频文件（如MP3, M4A），封面是作为视频流存储的。
     * @param playbill 解码出的 QImage 格式的封面。
     */
    void hasPlaybill(const QImage &playbill);

protected:
    /**
     * @brief QThread 的主执行函数。
     *
     * 当调用 `start()` 时，这个函数会在新的线程中被执行。
     * 它包含了打开文件、读取数据包、解码、重采样以及填充缓冲队列的完整循环。
     */
    void run() override;

private:
    AudioDecoderPrivate *d = nullptr; ///< 使用 Pimpl 模式，隐藏所有FFmpeg相关的私有实现细节。
};

#endif // AUDIODECODER_H