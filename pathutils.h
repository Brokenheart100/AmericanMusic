#ifndef PATHUTILS_H
#define PATHUTILS_H

#include <QString>

namespace PathUtils
{

    /**
     * @brief getSvgDirectoryPath 获取SVG资源文件夹的绝对物理路径。
     *
     * 该函数智能地处理开发环境（源代码目录）和发布环境（可执行文件目录）的路径差异。
     * 它首先检查可执行文件同级目录是否存在 "svg" 文件夹（发布模式），
     * 如果不存在，则假定处于开发模式，并从可执行文件目录向上查找项目根目录，
     * 然后拼接 "svg" 路径。
     *
     * @return QString 返回找到的 "svg" 文件夹的绝对路径。如果未找到，则返回空字符串。
     */
    QString getSvgDirectoryPath();

} // namespace PathUtils

#endif // PATHUTILS_H