#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QQuickWindow>
#include <QCommandLineParser>
#include "vehiclebridge.h"

int main(int argc, char *argv[])
{
    // Request OpenGL ES 2.0 — works on both desktop Mesa and RPi V3D
    QQuickWindow::setGraphicsApi(QSGRendererInterface::OpenGLRhi);

    QGuiApplication app(argc, argv);
    app.setApplicationName("ClusterUI");
    app.setApplicationVersion("0.1");

    // Allow the vhal-core server address to be overridden at runtime.
    // Default: localhost:50051
    // Example: cluster-ui --vhal-server 192.168.1.10:50051
    QCommandLineParser parser;
    parser.addHelpOption();
    parser.addVersionOption();
    QCommandLineOption serverOpt(
        QStringLiteral("vhal-server"),
        QStringLiteral("vhal-core gRPC server address (host:port)"),
        QStringLiteral("address"),
        QStringLiteral("localhost:50051"));
    parser.addOption(serverOpt);
    parser.process(app);

    const QString serverAddress = parser.value(serverOpt);

    // Create the bridge — it connects to vhal-core and starts subscribing
    VehicleBridge bridge(serverAddress);

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
