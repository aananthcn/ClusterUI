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

    // create this app
    QGuiApplication app(argc, argv);
    app.setApplicationName("ClusterUI");
    app.setApplicationVersion("0.1");

    // cli usage : cluster-ui --vhal-server 192.168.1.10:50051
    QCommandLineParser parser;
    parser.addHelpOption();
    parser.addVersionOption();
    QCommandLineOption serverOpt(
        QStringLiteral("vhal-server"), // option name
        QStringLiteral("vhal-core gRPC server address (host:port)"), // option description
        QStringLiteral("address"), // option value name, will contain the gRPC server address
        QStringLiteral("localhost:50051")); // default value
    parser.addOption(serverOpt);
    parser.process(app);

    // Create the vhal bridge — it connects to vhal-core and starts subscribing
    const QString serverAddress = parser.value(serverOpt);
    VehicleBridge bridge(serverAddress);

    // Create the QML engine to deal with QML file
    QQmlApplicationEngine engine;

    // Expose the bridge to all QML files as a context property
    engine.rootContext()->setContextProperty("vehicle", &bridge);

    // For desktop: xcb / wayland auto-detected by Qt
    // For RPi eglfs: set QT_QPA_PLATFORM=eglfs in environment
    const QUrl url(QStringLiteral("qrc:/ClusterUI/qml/ClusterRoot.qml"));

    // connect objectCreationFailed signal to call app.exit() 
    QObject::connect(
        &engine, &QQmlApplicationEngine::objectCreationFailed,
        &app,    [&app](const QUrl &) { app.exit(1); },
        Qt::QueuedConnection
    );

    engine.load(url);
    return app.exec();
}
