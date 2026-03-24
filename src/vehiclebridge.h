#pragma once
#include <QObject>
#include <QTimer>
#include <QString>
#include "vehiclestate.h"

// VehicleBridge exposes vehicle state to QML as Q_PROPERTYs.
// On desktop (USE_SYNTHETIC_BRIDGE): a QTimer drives a sine-wave
// speed + RPM so all animations are exercised without hardware.
// On RPi-2 (USE_UDP_BRIDGE): a QUdpSocket receives packed
// VehicleState structs from the Linux CAN domain.
class VehicleBridge : public QObject
{
    Q_OBJECT

    Q_PROPERTY(float   speed      READ speed      NOTIFY stateChanged)
    Q_PROPERTY(float   rpm        READ rpm        NOTIFY stateChanged)
    Q_PROPERTY(int     gear       READ gear       NOTIFY stateChanged)
    Q_PROPERTY(float   fuel       READ fuel       NOTIFY stateChanged)
    Q_PROPERTY(float   temp       READ temp       NOTIFY stateChanged)
    Q_PROPERTY(bool    warnEngine READ warnEngine NOTIFY stateChanged)
    Q_PROPERTY(bool    warnBatt   READ warnBatt   NOTIFY stateChanged)
    Q_PROPERTY(bool    warnBrake  READ warnBrake  NOTIFY stateChanged)
    Q_PROPERTY(int     driveMode  READ driveMode  NOTIFY stateChanged)

public:
    explicit VehicleBridge(QObject *parent = nullptr);

    float speed()      const { return m_state.speed_kmh; }
    float rpm()        const { return m_state.rpm; }
    int   gear()       const { return m_state.gear; }
    float fuel()       const { return m_state.fuel_pct; }
    float temp()       const { return m_state.temp_c; }
    bool  warnEngine() const { return m_state.warn_engine; }
    bool  warnBatt()   const { return m_state.warn_battery; }
    bool  warnBrake()  const { return m_state.warn_brake; }
    int   driveMode()  const { return m_state.drive_mode; }

signals:
    void stateChanged();

private slots:
    void tick();          // synthetic: called by QTimer
    void readPendingData(); // UDP: called by QUdpSocket::readyRead

private:
    void applyState(const VehicleState &s);

    VehicleState m_state;
    float        m_phase = 0.0f; // synthetic sine phase
    QTimer      *m_timer = nullptr;
};
