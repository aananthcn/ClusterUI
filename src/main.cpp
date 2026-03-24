#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QQuickWindow>
#include "vehiclebridge.h"

int main(int argc, char *argv[])
{
    // Request OpenGL ES 2.0 — works on both desktop Mesa and RPi V3D
    QQuickWindow::setGraphicsApi(QSGRendererInterface::OpenGLRhi);

    QGuiApplication app(argc, argv);
    app.setApplicationName("ClusterUI");
    app.setApplicationVersion("0.1");

    // Create the bridge — it starts generating/receiving data immediately
    VehicleBridge bridge;

    QQmlApplicationEngine engine;

    // Expose the bridge to all QML files as a context property
    engine.rootContext()->setContextProperty("vehicle", &bridge);

    // For desktop: xcb / wayland auto-detected by Qt
    // For RPi eglfs: set QT_QPA_PLATFORM=eglfs in environment
    const QUrl url(QStringLiteral("qrc:/ClusterUI/qml/ClusterRoot.qml"));

    QObject::connect(
        &engine, &QQmlApplicationEngine::objectCreationFailed,
        &app,    [&app](const QUrl &) { app.exit(1); },
        Qt::QueuedConnection
    );

    engine.load(url);
    return app.exec();
}
