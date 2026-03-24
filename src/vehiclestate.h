#pragma once
#include <cstdint>

// Plain struct representing one vehicle state snapshot.
// Sent over UDP from RPi-2 Linux domain, or generated
// synthetically on desktop for UI development.
struct VehicleState {
    float   speed_kmh   = 0.0f;   // 0 – 240
    float   rpm         = 0.0f;   // 0 – 8000
    int8_t  gear        = 0;      // -1 = R, 0 = N, 1–8 = forward
    float   fuel_pct    = 100.0f; // 0 – 100
    float   temp_c      = 90.0f;  // engine coolant °C
    bool    warn_engine = false;
    bool    warn_battery= false;
    bool    warn_brake  = false;
    uint8_t drive_mode  = 0;      // 0=normal 1=sport 2=reverse
    uint64_t timestamp_us = 0;    // microseconds, for latency measurement
};
static_assert(sizeof(VehicleState) < 128,
    "VehicleState must stay small enough for a single UDP packet");
