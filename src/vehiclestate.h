#pragma once
#include <cstdint>

// Plain struct representing one vehicle state snapshot.
// Values are populated from vhal-core gRPC property updates.
struct VehicleState {
    float   speed_kmh    = 0.0f;   // 0 – 240
    float   rpm          = 0.0f;   // 0 – 8000
    int8_t  gear         = 0;      // -1 = R, 0 = N, 1–8 = forward
    float   fuel_pct     = 0.0f;   // 0 – 100
    float   temp_c       = 0.0f;   // engine coolant °C
    bool    warn_engine  = false;
    bool    warn_battery = false;
    bool    warn_brake   = false;
    uint8_t drive_mode   = 0;      // 0=normal 1=sport 2=eco
};
