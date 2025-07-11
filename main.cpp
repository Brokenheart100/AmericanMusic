#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include "pathutils.h"
#include <QQmlContext>
#include <QQuickStyle>
#include "musicplayer.h"
#include <QApplication> // <-- 修改头文件

int main(int argc, char *argv[])
{
    QApplication app(argc, argv);
    QQuickStyle::setStyle("Material");
    QQmlApplicationEngine engine;
    MusicPlayer musicPlayer;
    engine.rootContext()->setContextProperty("musicPlayer", &musicPlayer);
    QObject::connect(
        &engine,
        &QQmlApplicationEngine::objectCreationFailed,
        &app,
        []()
        { QCoreApplication::exit(-1); },
        Qt::QueuedConnection);
    engine.loadFromModule("AmericanMusic", "Main");
    QString svgAbsPath = PathUtils::getSvgDirectoryPath();
    return app.exec();
}
