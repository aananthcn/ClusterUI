cmake_minimum_required(VERSION 3.22)
project(ClusterUI VERSION 0.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)

find_package(Qt6 REQUIRED COMPONENTS
    Core
    Quick
    QuickControls2
)

qt_policy(SET QTP0004 NEW)

qt_standard_project_setup(REQUIRES 6.5)

qt_add_executable(cluster-ui
    src/main.cpp
    src/vehiclebridge.cpp
	src/vehiclestate.h
    src/vehiclebridge.h  
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

# Desktop: synthetic data. RPi cross-build: UDP socket.
if(CMAKE_CROSSCOMPILING)
    target_compile_definitions(cluster-ui PRIVATE USE_UDP_BRIDGE)
else()
    target_compile_definitions(cluster-ui PRIVATE USE_SYNTHETIC_BRIDGE)
endif()

target_link_libraries(cluster-ui PRIVATE
    Qt6::Core
    Qt6::Quick
    Qt6::QuickControls2
)

# Install target — used by deploy.sh
install(TARGETS cluster-ui
    RUNTIME DESTINATION bin
)
install(DIRECTORY qml/ DESTINATION qml)
install(DIRECTORY assets/ DESTINATION assets)
