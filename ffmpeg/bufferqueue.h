#ifndef BUFFERQUEUE_H
#define BUFFERQUEUE_H

#include <QDebug>
#include <QSemaphore>
#include <QScopedPointer>
#include <vector>
#include <atomic>

/**
 * @class BufferQueue
 * @brief 一个线程安全的、固定大小的循环缓冲队列 (Circular Buffer / Ring Buffer)。
 *
 * 该类使用模板实现，可以存储任何类型 T 的对象。
 * 它主要用于经典的“生产者-消费者”场景，其中一个线程（生产者）向队列中添加元素，
 * 另一个线程（消费者）从队列中取出元素。
 *
 * @tparam T 队列中存储的元素类型。
 *
 * @note 内部使用两个 QSemaphore 来实现线程同步和阻塞/唤醒，效率很高。
 *       - 一个信号量 (`m_freeSpace`) 记录空闲槽位的数量。
 *       - 另一个信号量 (`m_useableSpace`) 记录已用槽位的数量（即队列中元素的数量）。
 */
template <class T>
class BufferQueue
{
public:
    /**
     * @brief 构造函数。
     * @param bufferSize 队列的固定容量。默认为30。
     */
    explicit BufferQueue(int bufferSize = 30)
    {
        setBufferSize(bufferSize);
    }

    /**
     * @brief 析构函数。
     *
     * 确保所有资源被释放，并清空内部的 vector 以释放内存。
     */
    ~BufferQueue()
    {
        init();                               // 唤醒任何可能在等待的线程
        std::vector<T>().swap(m_bufferQueue); // 使用 swap-to-shrink idiom 释放 vector 内存
    }

    /**
     * @brief 设置或重置队列的容量。
     * @param bufferSize 新的队列容量。
     */
    void setBufferSize(int bufferSize)
    {
        m_bufferSize = bufferSize;
        m_bufferQueue.resize(bufferSize); // 调整 vector 大小

        // m_useableSpace: 初始时队列为空，所以可用元素为 0。
        m_useableSpace.reset(new QSemaphore(0));
        // m_freeSpace: 初始时队列全空，所以空闲槽位为 bufferSize。
        m_freeSpace.reset(new QSemaphore(m_bufferSize));

        // 重置读写指针
        m_front = m_rear = 0;
    }

    /**
     * @brief (生产者调用) 向队列尾部添加一个元素。
     *
     * 如果队列已满（没有空闲槽位），此函数会阻塞调用线程，直到有消费者取走元素腾出空间。
     * @param element 要添加到队列的元素。
     */
    void enqueue(const T &element)
    {
        // 1. 请求一个空闲槽位。如果 m_freeSpace 计数器为0，则阻塞。
        m_freeSpace->acquire();

        // 2. 将元素放入循环数组的下一个写位置。
        //    使用原子变量 m_front 并取模，确保多生产者环境下的线程安全和循环行为。
        m_bufferQueue[m_front++ % m_bufferSize] = element;

        // 3. 增加一个可用元素。这会唤醒任何因队列为空而阻塞在 dequeue() 的消费者线程。
        //    QSemaphoreReleaser 是一个 RAII 包装器，确保 release() 在作用域结束时被调用。
        QSemaphoreReleaser releaser(m_useableSpace.get());
    }

    /**
     * @brief (消费者调用) 从队列头部取出一个元素。
     *
     * 如果队列为空（没有可用元素），此函数会阻塞调用线程，直到有生产者添加新元素。
     * @return 队列头部的元素。
     */
    T dequeue()
    {
        // 1. 请求一个可用元素。如果 m_useableSpace 计数器为0，则阻塞。
        m_useableSpace->acquire();

        // 2. 从循环数组的下一个读位置取出元素。
        T element = m_bufferQueue[m_rear++ % m_bufferSize];

        // 3. 增加一个空闲槽位。这会唤醒任何因队列已满而阻塞在 enqueue() 的生产者线程。
        m_freeSpace->release();

        return element;
    }

    /**
     * @brief (消费者调用) 尝试从队列头部取出一个元素，但不阻塞。
     *
     * @return 如果队列不为空，返回队列头部的元素。
     *         如果队列为空，立即返回一个默认构造的 T 类型元素。
     */
    T tryDequeue()
    {
        T element; // 默认构造的元素

        // 尝试获取一个可用元素信号量，如果当前不可用，立即返回 false，不阻塞。
        if (m_useableSpace->tryAcquire())
        {
            // 如果成功获取，则执行与 dequeue() 相同的逻辑
            element = m_bufferQueue[m_rear++ % m_bufferSize];
            m_freeSpace->release();
        }

        return element;
    }

    /**
     * @brief 重置队列状态。
     *
     * 将队列清空，并唤醒所有可能在等待的生产者或消费者线程，使它们能正常退出。
     * 这在停止解码或切换歌曲时非常重要。
     */
    void init()
    {
        // 消耗掉所有已用空间的信号量，模拟清空队列
        if (m_useableSpace)
            m_useableSpace->acquire(m_useableSpace->available());

        // 释放所有可能被生产者占用的空闲空间信号量，恢复到满容量状态
        if (m_freeSpace)
            m_freeSpace->release(m_bufferSize - m_freeSpace->available());

        // 使用 store 是因为 m_front 和 m_rear 是 std::atomic 类型
        m_front.store(0);
        m_rear.store(0);
    }

private:
    // m_freeSpace:    一个计数信号量，表示队列中还有多少个空闲的位置。
    //                 生产者在放入元素前需要 acquire() 一个，消费者在取出元素后需要 release() 一个。
    QScopedPointer<QSemaphore> m_freeSpace;

    // m_useableSpace: 一个计数信号量，表示队列中已经有多少个可用的元素。
    //                 消费者在取出元素前需要 acquire() 一个，生产者在放入元素后需要 release() 一个。
    QScopedPointer<QSemaphore> m_useableSpace;

    // 使用 std::atomic 来确保在多线程环境下的读写指针的原子性操作，避免数据竞争。
    std::atomic_int m_rear{0};  ///< 读指针 (消费者使用)。
    std::atomic_int m_front{0}; ///< 写指针 (生产者使用)。

    // 使用 std::vector 作为底层的循环数组存储。
    std::vector<T> m_bufferQueue;
    int m_bufferSize; ///< 队列的总容量。
};

#endif // BUFFERQUEUE_H