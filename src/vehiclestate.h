#pragma once
#include <cstdint>

// the following headerfile comes from VHAL
#include <aidl/android/hardware/automotive/vehicle/VehicleGear.h> 

namespace aidl_vhal = aidl::android::hardware::automotive::vehicle;

enum class DriveMode : uint8_t {
    NORMAL = 0,
    SPORTS = 1,
    REVERSE = 2,
    ECO = 3,
    MAX
};


// Plain struct representing one vehicle state snapshot.
// Values are populated from vhal-core gRPC property updates.
struct VehicleState {
    float     speed_kmh    = 0.0f;   // 0 – 240
    float     rpm          = 0.0f;   // 0 – 8000
    int8_t    gear         = 0;      // -1 = R, 0 = N, 1–8 = forward
    float     fuel_pct     = 0.0f;   // 0 – 100
    float     temp_c       = 0.0f;   // engine coolant °C
    bool      warn_engine  = false;
    bool      warn_battery = false;
    bool      park_brake   = false;
    DriveMode drive_mode   = DriveMode::NORMAL;      // 0=normal 1=sport 2=eco
};
