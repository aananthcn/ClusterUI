#include "vehiclebridge.h"
#include <QtMath>
#include <QDebug>

#ifdef USE_UDP_BRIDGE
#  include <QUdpSocket>
#  include <QNetworkDatagram>
static constexpr quint16 UDP_PORT = 5005;
#endif

VehicleBridge::VehicleBridge(QObject *parent)
    : QObject(parent)
{
#ifdef USE_SYNTHETIC_BRIDGE
    // Tick at 50 Hz — fast enough to make gauge animations smooth
    m_timer = new QTimer(this);
    m_timer->setInterval(20);
    connect(m_timer, &QTimer::timeout, this, &VehicleBridge::tick);
    m_timer->start();
    qDebug() << "[VehicleBridge] synthetic mode — 50 Hz sine generator";

#elif defined(USE_UDP_BRIDGE)
    auto *sock = new QUdpSocket(this);
    if (!sock->bind(QHostAddress::AnyIPv4, UDP_PORT, QUdpSocket::ShareAddress)) {
        qWarning() << "[VehicleBridge] failed to bind UDP port" << UDP_PORT;
    } else {
        qDebug() << "[VehicleBridge] UDP mode — listening on port" << UDP_PORT;
    }
    connect(sock, &QUdpSocket::readyRead, this, &VehicleBridge::readPendingData);
#endif
}

// ── Synthetic ─────────────────────────────────────────────────────────────────

void VehicleBridge::tick()
{
    m_phase += 0.015f; // ~3 full cycles per minute

    VehicleState s;
    s.speed_kmh   = 60.0f + 55.0f * qSin(m_phase);          // 5 – 115 km/h
    s.rpm         = 1200.0f + 2800.0f * qSin(m_phase * 1.3f + 0.5f); // 0–4000 rpm
    s.gear        = static_cast<int8_t>(qMax(1, static_cast<int>(s.speed_kmh / 30)));
    s.fuel_pct    = 75.0f;
    s.temp_c      = 88.0f + 4.0f * qSin(m_phase * 0.1f);
    s.warn_engine = (m_phase > 6.0f && m_phase < 6.5f);      // brief warning flash
    s.warn_battery= false;
    s.warn_brake  = false;
    // Cycle through drive modes every ~10 seconds so you can see QML transitions
    int modeIndex = static_cast<int>(m_phase / 3.0f) % 3;
    s.drive_mode  = static_cast<uint8_t>(modeIndex);

    applyState(s);
}

// ── UDP ───────────────────────────────────────────────────────────────────────

void VehicleBridge::readPendingData()
{
#ifdef USE_UDP_BRIDGE
    auto *sock = qobject_cast<QUdpSocket *>(sender());
    while (sock && sock->hasPendingDatagrams()) {
        QNetworkDatagram dg = sock->receiveDatagram(sizeof(VehicleState));
        if (dg.data().size() == sizeof(VehicleState)) {
            VehicleState s;
            memcpy(&s, dg.data().constData(), sizeof(VehicleState));
            applyState(s);
        } else {
            qWarning() << "[VehicleBridge] unexpected datagram size"
                       << dg.data().size();
        }
    }
#endif
}

// ── Common ────────────────────────────────────────────────────────────────────

void VehicleBridge::applyState(const VehicleState &s)
{
    m_state = s;
    emit stateChanged();
}
