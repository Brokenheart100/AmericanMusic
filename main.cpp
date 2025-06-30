#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include "pathutils.h"
#include <QQmlContext>
#include <QQuickStyle>

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);
    QQuickStyle::setStyle("Material");
    QQmlApplicationEngine engine;
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
