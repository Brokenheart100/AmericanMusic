#include "audiodecoder.h"
#include "bufferqueue.h"
#include "musicmodel.h"

#include <QDebug>
#include <QFileInfo>
#include <QImage>
#include <QMutex>
#include <QQueue>
#include <QUrl>

// 包含 FFmpeg C 语言头文件
extern "C"
{
#include <libavcodec/avcodec.h>
#include <libavformat/avformat.h>
#include <libavutil/imgutils.h>
#include <libswscale/swscale.h>
#include <libswresample/swresample.h>
}

// 避免与某些Windows头文件宏冲突
#ifdef MKTAG
#undef MKTAG
#define MKTAG(a, b, c, d) ((a) | ((b) << 8) | ((c) << 16) | (unsigned(d) << 24))
#endif

// FFmpeg 的 AVERROR_EOF 是一个负值，这里重新定义以避免编译器警告
#ifdef AVERROR_EOF
#undef AVERROR_EOF
#define AVERROR_EOF (-int(MKTAG('E', 'O', 'F', ' ')))
#endif

/// @brief 一个类型定义，用于在 QByteArray 构造时避免类型转换警告。
typedef const char *const_int8ptr;

/**
 * @class AudioDecoderPrivate
 * @brief 使用 Pimpl (Pointer to implementation) 模式，隐藏 AudioDecoder 的所有私有成员和 FFmpeg 细节。
 *
 * 这样做的好处是：
 * 1. 将所有 FFmpeg 相关的头文件和数据结构隔离在 .cpp 文件中，使得 AudioDecoder.h 头文件非常干净。
 * 2. 任何私有成员的修改都只需要重新编译 .cpp 文件，而不需要重新编译所有包含了 AudioDecoder.h 的文件，加快编译速度。
 */
class AudioDecoderPrivate
{
public:
    AudioDecoderPrivate() {}

    // --- 线程同步与状态 ---
    QMutex m_mutex;         ///< 用于保护所有需要跨线程访问的成员变量。
    bool m_runnable = true; ///< 控制解码线程循环是否继续运行的标志位。

    // --- 音频元数据 ---
    QAudioFormat m_format;        ///< 解码后的音频格式。
    qreal m_duration = 0.0;       ///< 音频总时长（秒）。
    QString m_title = QString();  ///< 标题。
    QString m_singer = QString(); ///< 艺术家。
    QString m_album = QString();  ///< 专辑。
    QImage m_playbill = QImage(); ///< 解码出的封面。

    // --- 文件与错误处理 ---
    QString m_filename = QString();  ///< 当前正在处理的文件名。
    QString m_lastError = QString(); ///< 记录发生的最后一个错误。

    // --- FFmpeg 核心数据结构 ---
    SwrContext *m_swrContext = nullptr;            ///< 用于音频重采样。
    AVFormatContext *m_formatContext = nullptr;    ///< 媒体文件的格式上下文（容器）。
    AVCodecContext *m_audioCodecContext = nullptr; ///< 音频解码器上下文。
    AVCodecContext *m_videoCodecContext = nullptr; ///< 视频（封面）解码器上下文。
    AVStream *m_audioStream = nullptr;             ///< 指向音频流。
    AVStream *m_videoStream = nullptr;             ///< 指向视频（封面）流。
    AVPacket *m_packet = nullptr;                  ///< 用于存储从文件中读取的压缩数据包。
    AVFrame *m_frame = nullptr;                    ///< 用于存储解码后的原始数据帧。
    int m_audioIndex = -1;                         ///< 音频流在文件中的索引。
    int m_videoIndex = -1;                         ///< 视频（封面）流在文件中的索引。

    // --- 数据缓冲 ---
    BufferQueue<AudioPacket> m_bufferQueue; ///< 解码后音频包的线程安全缓冲队列。

    // --- 私有辅助函数 ---

    /**
     * @brief 查找指定类型的流，并为其打开解码器上下文。
     * @param type 要查找的媒体类型 (如 AVMEDIA_TYPE_AUDIO)。
     * @param formatCtx 媒体文件的格式上下文。
     * @param codecCtx 用于接收创建的解码器上下文的指针。
     * @param stream_index 用于接收找到的流索引的指针。
     * @return 成功返回 true，失败返回 false。
     */
    bool openCodecContext(AVMediaType type, AVFormatContext *&formatCtx, AVCodecContext *&codecCtx, int *stream_index);

    /**
     * @brief 将 QAudioFormat 的采样类型转换为 FFmpeg 的 AVSampleFormat。
     * @param format Qt 的采样类型。
     * @return FFmpeg 的采样格式。
     */
    AVSampleFormat converSampleFormat(QAudioFormat::SampleType format)
    {
        AVSampleFormat type;
        switch (format)
        {
        case QAudioFormat::Float:
            type = AV_SAMPLE_FMT_FLT;
            break;

        default:
        case QAudioFormat::SignedInt:
            type = AV_SAMPLE_FMT_S32;
            break;
        }

        return type;
    };

    /**
     * @brief 解析媒体文件，初始化所有 FFmpeg 上下文和元数据。
     * @return 成功返回 true，失败返回 false。
     */
    bool resolve();

    /**
     * @brief 清理并释放所有已分配的 FFmpeg 资源。
     */
    void cleanup();
};

// ------------------------------------------------------------------------------------------------
// AudioDecoder 类的实现
// ------------------------------------------------------------------------------------------------

AudioDecoder::AudioDecoder(QObject *parent)
    : QThread(parent)
{
    d = new AudioDecoderPrivate;
}

AudioDecoder::~AudioDecoder()
{
    stop();       // 确保线程已停止
    d->cleanup(); // 清理资源
    delete d;
}

void AudioDecoder::getAudioInfo(AudioData *data)
{
    // ... （静态工具函数的实现）
}

void AudioDecoder::stop()
{
    d->m_bufferQueue.init(); // 重置并唤醒可能在等待的消费者
    d->m_runnable = false;
    wait(); // 等待 run() 函数执行完毕
}

void AudioDecoder::open(const QString &filename)
{
    if (isRunning())
    {
        stop(); // 如果线程正在运行，先停止它
    }

    QMutexLocker locker(&d->m_mutex);
    d->m_filename = filename;
    d->cleanup(); // 在锁定状态下清理旧资源

    start(); // 启动新线程
}

void AudioDecoder::setProgress(qreal ratio)
{
    QMutexLocker locker(&d->m_mutex);
    if (!d->m_formatContext || !d->m_audioStream)
        return; // 确保上下文有效

    qreal seconds = ratio * d->m_duration;
    // 使用 av_seek_frame 跳转到指定时间戳
    av_seek_frame(d->m_formatContext, d->m_audioIndex, int64_t(seconds / av_q2d(d->m_audioStream->time_base)), AVSEEK_FLAG_BACKWARD);

    locker.unlock();
    d->m_bufferQueue.init(); // 清空并重置缓冲队列

    // 如果线程因为解码完成而退出，需要重新启动它
    if (!isRunning())
        start();
}

// --- 公开的 Getters (使用 QMutexLocker 保证线程安全) ---
QAudioFormat AudioDecoder::format()
{
    QMutexLocker locker(&d->m_mutex);
    return d->m_format;
}
qreal AudioDecoder::duration()
{
    QMutexLocker locker(&d->m_mutex);
    return d->m_duration;
}
QString AudioDecoder::title()
{
    QMutexLocker locker(&d->m_mutex);
    return d->m_title;
}
QString AudioDecoder::singer()
{
    QMutexLocker locker(&d->m_mutex);
    return d->m_singer;
}
QString AudioDecoder::album()
{
    QMutexLocker locker(&d->m_mutex);
    return d->m_album;
}

AudioPacket AudioDecoder::currentPacket()
{
    return d->m_bufferQueue.tryDequeue(); // 委托给线程安全的队列
}

/**
 * @brief 解码线程的主循环。
 */
void AudioDecoder::run()
{
    // 1. 解析文件
    if (!d->resolve())
    {
        emit error(d->m_lastError);
        d->cleanup();
        return;
    }
    else
    {
        emit resolved();
    }

    AVSampleFormat out_sample_fmt = d->converSampleFormat(d->m_format.sampleType());

    // 2. 循环读取数据包并解码
    while (d->m_runnable)
    {
        // 从文件中读取一个压缩的数据包
        if (av_read_frame(d->m_formatContext, d->m_packet) < 0)
        {
            break; // 文件读取完毕或发生错误
        }

        // --- 处理音频包 ---
        if (d->m_packet->stream_index == d->m_audioIndex)
        {
            // 将包发送给解码器
            if (avcodec_send_packet(d->m_audioCodecContext, d->m_packet) < 0)
                break;

            // 循环接收解码后的帧，因为一个包可能包含多个帧
            while (d->m_runnable)
            {
                int ret = avcodec_receive_frame(d->m_audioCodecContext, d->m_frame);
                if (ret == AVERROR(EAGAIN) || ret == AVERROR_EOF)
                {
                    break; // 需要更多数据或已结束
                }
                else if (ret < 0)
                {
                    goto end_loop; // 发生不可恢复的错误
                }

                // --- 音频重采样 ---
                // 将解码出的音频帧转换为我们期望的输出格式（如S32或Float）
                QByteArray data;
                int size = av_samples_get_buffer_size(nullptr, d->m_frame->channels, d->m_frame->nb_samples, out_sample_fmt, 0);
                uint8_t *buf = new uint8_t[size];
                swr_convert(d->m_swrContext, &buf, d->m_frame->nb_samples, const_cast<const uint8_t **>(d->m_frame->data), d->m_frame->nb_samples);

                data.append(const_int8ptr(buf), size);
                delete[] buf;

                // 计算当前帧的时间戳
                qreal time = d->m_frame->pts * av_q2d(d->m_audioStream->time_base);

                // 将解码后的数据包放入缓冲队列
                d->m_bufferQueue.enqueue({data, time});

                av_frame_unref(d->m_frame);
            }
        }
        // --- 处理视频包 (仅用于获取第一帧作为封面) ---
        else if (d->m_packet->stream_index == d->m_videoIndex && d->m_playbill.isNull())
        {
            if (avcodec_send_packet(d->m_videoCodecContext, d->m_packet) < 0)
                continue;

            while (d->m_runnable)
            {
                if (avcodec_receive_frame(d->m_videoCodecContext, d->m_frame) < 0)
                    break;
                else if (ret < 0)
                    return;

                int dst_linesize[4];
                uint8_t *dst_data[4];
                SwsContext *swsContext = sws_getContext(d->m_frame->width, d->m_frame->height, d->m_videoCodecContext->pix_fmt, d->m_frame->width,
                                                        d->m_frame->height, AV_PIX_FMT_RGB24, SWS_BILINEAR, nullptr, nullptr, nullptr);
                av_image_alloc(dst_data, dst_linesize, d->m_frame->width, d->m_frame->height, AV_PIX_FMT_RGB24, 1);
                sws_scale(swsContext, d->m_frame->data, d->m_frame->linesize, 0, d->m_frame->height, dst_data, dst_linesize);

                // 注意后面的copy(),dst_data[0]释放后image也无效了,因此必须拷贝一份
                QImage image = QImage(dst_data[0], d->m_frame->width, d->m_frame->height, dst_linesize[0], QImage::Format_RGB888).copy();
                av_freep(&dst_data[0]);
                sws_freeContext(swsContext);

                // m_playbill只在内部使用
                d->m_playbill = image;
                emit hasPlaybill(image);

                av_frame_unref(d->m_frame);
            }
        }

        av_packet_unref(d->m_packet);
    }

end_loop:
    // 3. 循环结束后清理资源
    d->cleanup();
    d->m_bufferQueue.init(); // 确保消费者线程不会被阻塞
}

// ------------------------------------------------------------------------------------------------
// AudioDecoderPrivate 辅助函数的实现
// ------------------------------------------------------------------------------------------------
bool AudioDecoderPrivate::resolve()
{
    // 打开输入文件,并分配格式上下文
    avformat_open_input(&m_formatContext, m_filename.toStdString().c_str(), nullptr, nullptr);

    if (!m_formatContext)
    {
        m_lastError = "未知的音乐格式.";
        return false;
    }

    avformat_find_stream_info(m_formatContext, nullptr);

    if (!openCodecContext(AVMEDIA_TYPE_AUDIO, m_formatContext, m_audioCodecContext, &m_audioIndex))
        return false;

    if (!openCodecContext(AVMEDIA_TYPE_VIDEO, m_formatContext, m_videoCodecContext, &m_videoIndex))
        m_lastError = "无法找到或解析海报.";

    m_audioStream = m_formatContext->streams[m_audioIndex];
    if (m_videoIndex != -1)
        m_videoStream = m_formatContext->streams[m_videoIndex];

    // 打印相关信息
    av_dump_format(m_formatContext, 0, "format_information", 0);
    fflush(stderr);

    QAudioFormat format;
    format.setCodec("audio/pcm");
    format.setSampleRate(m_audioCodecContext->sample_rate);
    format.setChannelCount(m_audioCodecContext->channels);
    if (m_audioCodecContext->sample_fmt == AV_SAMPLE_FMT_FLT)
    {
        format.setSampleType(QAudioFormat::Float);
        format.setSampleSize(8 * av_get_bytes_per_sample(AV_SAMPLE_FMT_FLT));
    }
    else
    {
        format.setSampleType(QAudioFormat::SignedInt);
        format.setSampleSize(8 * av_get_bytes_per_sample(AV_SAMPLE_FMT_S32));
    }
    m_format = format;
    m_duration = m_audioStream->duration * av_q2d(m_audioStream->time_base);

    AVDictionaryEntry *title = av_dict_get(m_formatContext->metadata, "title", nullptr, AV_DICT_MATCH_CASE);
    AVDictionaryEntry *artist = av_dict_get(m_formatContext->metadata, "artist", nullptr, AV_DICT_MATCH_CASE);
    AVDictionaryEntry *album = av_dict_get(m_formatContext->metadata, "album", nullptr, AV_DICT_MATCH_CASE);
    if (album)
        m_album = album->value;
    if (artist)
        m_singer = artist->value;
    if (title)
        m_title = title->value;
    else
        m_title = QFileInfo(m_filename).baseName();

    m_swrContext = swr_alloc_set_opts(nullptr, int64_t(m_audioCodecContext->channel_layout), converSampleFormat(m_format.sampleType()),
                                      m_audioCodecContext->sample_rate, int64_t(m_audioCodecContext->channel_layout),
                                      m_audioCodecContext->sample_fmt, m_audioCodecContext->sample_rate, 0, nullptr);
    swr_init(m_swrContext);

    // 分配并初始化一个临时的帧和包
    m_packet = av_packet_alloc();
    m_frame = av_frame_alloc();
    m_packet->data = nullptr;
    m_packet->size = 0;

    return true;
}
void AudioDecoderPrivate::cleanup()
{
    m_audioIndex = m_videoIndex = -1;
    m_audioStream = m_videoStream = nullptr;
    m_title.clear();
    m_singer = QString("未知");
    m_album = QString("未知");
    m_playbill = QImage();
    m_duration = 0.0;
    m_runnable = true;
    m_lastError.clear();

    if (m_frame)
        av_frame_free(&m_frame);
    if (m_packet)
        av_packet_free(&m_packet);
    if (m_swrContext)
        swr_free(&m_swrContext);
    if (m_audioCodecContext)
        avcodec_free_context(&m_audioCodecContext);
    if (m_videoCodecContext)
        avcodec_free_context(&m_videoCodecContext);
    if (m_formatContext)
        avformat_close_input(&m_formatContext);
}
bool AudioDecoderPrivate::openCodecContext(AVMediaType type, AVFormatContext *&formatCtx, AVCodecContext *&codecCtx, int *stream_index)
{
    // 找到流的索引
    int ret = av_find_best_stream(formatCtx, type, -1, -1, nullptr, 0);
    const char *typeStr = av_get_media_type_string(type);

    if (ret < 0)
    {
        m_lastError = QString("无法找到%1的%2流'").arg(m_filename).arg(typeStr);
        return false;
    }
    else
    {
        *stream_index = ret;
        AVStream *stream = formatCtx->streams[ret];
        AVCodec *decoder = nullptr;

        if (stream)
            decoder = avcodec_find_decoder(stream->codecpar->codec_id);

        if (!decoder)
        {
            m_lastError = QString("无法找到%1编解码器").arg(typeStr);
            return false;
        }

        codecCtx = avcodec_alloc_context3(decoder);
        if (!codecCtx)
        {
            m_lastError = QString("无法分配%1编解码上下文").arg(typeStr);
            return false;
        }

        int ret = avcodec_parameters_to_context(codecCtx, stream->codecpar);
        if (ret < 0)
        {
            m_lastError = QString("无法将%1编解码器参数复制到解码器上下文").arg(typeStr);
            return false;
        }

        ret = avcodec_open2(codecCtx, decoder, nullptr);
        if (ret < 0)
        {
            m_lastError = QString("打开%1编解码器失败").arg(typeStr);
            return false;
        }
    }

    return true;
}