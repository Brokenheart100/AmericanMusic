#include "PathUtils.h"
#include <QCoreApplication>
#include <QDir>
#include <QDebug>

namespace PathUtils
{

    QString getSvgDirectoryPath()
    {
        QString appDir = QCoreApplication::applicationDirPath();
        QDir currentDir(appDir);

        // --- 检查发布模式 ---
        QString releasePath = currentDir.filePath("svg");
        if (QDir(releasePath).exists())
        {
            qDebug() << "Found SVG directory in release mode:" << releasePath;
            // 使用 Qt 的标准函数进行转换
            return QDir::fromNativeSeparators(releasePath);
        }

        // --- 检查开发/构建模式 ---
        currentDir.cdUp();

        int maxLevelsUp = 5;
        for (int i = 0; i < maxLevelsUp; ++i)
        {
            QString devPath = currentDir.filePath("svg");
            if (QDir(devPath).exists())
            {
                qDebug() << "Found SVG directory in development mode:" << devPath;
                // 使用 Qt 的标准函数进行转换
                return QDir::fromNativeSeparators(devPath);
            }

            if (!currentDir.cdUp())
            {
                break;
            }
        }

        qWarning() << "SVG directory not found. Looked relative to:" << appDir;
        return QString();
    }

} // namespace PathUtils