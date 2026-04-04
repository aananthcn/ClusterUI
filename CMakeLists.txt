cmake_minimum_required(VERSION 3.22)
project(ClusterUI VERSION 0.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)

# ── Dependencies injected by Conan ────────────────────────────────────────────
# Run:
#   conan install . --output-folder=build/Release --build=missing -pr <profile>
#   cmake -B build/Release \
#         -DCMAKE_TOOLCHAIN_FILE=build/Release/conan_toolchain.cmake \
#         -DCMAKE_BUILD_TYPE=Release
#   cmake --build build/Release

find_package(Qt6 REQUIRED COMPONENTS Core Qml Quick QuickControls2)
find_package(gRPC REQUIRED)
find_package(Protobuf REQUIRED)   # pulled in by gRPC; found via CMakeDeps

# ── vhal-core packages ────────────────────────────────────────────────────────
# ClusterUI depends only on vhal-types (AIDL headers, stubs) and
# vhal-ipc-grpc (VehicleServer::Stub). vhal-server is not needed at build time.
add_subdirectory(../vhal-core/packages/vhal-types    ${CMAKE_BINARY_DIR}/vhal-types    EXCLUDE_FROM_ALL)
add_subdirectory(../vhal-core/packages/vhal-ipc-grpc ${CMAKE_BINARY_DIR}/vhal-ipc-grpc EXCLUDE_FROM_ALL)

# ── Qt setup ──────────────────────────────────────────────────────────────────
if(Qt6_VERSION VERSION_GREATER_EQUAL "6.8")
    qt_policy(SET QTP0004 NEW)
endif()
qt_standard_project_setup(REQUIRES 6.5)

# ── Executable ────────────────────────────────────────────────────────────────
qt_add_executable(cluster-ui
    src/main.cpp
    src/vehiclebridge.cpp
    src/vehiclebridge.h
    src/vehiclestate.h
    src/VhalGrpcClient.cpp
    src/VhalGrpcClient.h
)

qt_add_qml_module(cluster-ui
    URI ClusterUI
    VERSION 1.0
    RESOURCE_PREFIX "/"
    QML_FILES
        qml/ClusterRoot.qml
        qml/Speedometer.qml
        qml/Tachometer.qml
        qml/PipOverlay.qml
        qml/themes/Sport.qml
        qml/themes/Normal.qml
    RESOURCES
        assets/fonts/cluster.ttf
        assets/images/warning_icons.svg
)

set_target_properties(cluster-ui PROPERTIES
    QT_RESOURCE_PREFIX "/"
)

target_link_libraries(cluster-ui PRIVATE
    Qt6::Core
    Qt6::Quick
    Qt6::QuickControls2
    gRPC::grpc++
    protobuf::libprotobuf
    VehicleServerProtoStub
    AidlPropertyHeaders
    AndroidStubs
)

# ── Install target — used by deploy.sh ────────────────────────────────────────
install(TARGETS cluster-ui
    RUNTIME DESTINATION bin
)
install(DIRECTORY qml/    DESTINATION qml)
install(DIRECTORY assets/ DESTINATION assets)
