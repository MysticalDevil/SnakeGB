cmake_minimum_required(VERSION 3.16)

project(SnakeGB VERSION 1.3.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 23)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

if(CMAKE_BUILD_TYPE STREQUAL "Release" OR NOT CMAKE_BUILD_TYPE)
    set(CMAKE_BUILD_TYPE "MinSizeRel" CACHE STRING "" FORCE)
endif()

if(MSVC)
    add_compile_options(/Os /GL)
else()
    add_compile_options(-Os -fdata-sections -ffunction-sections -fvisibility=hidden)
    include(CheckIPOSupported)
    check_ipo_supported(RESULT ipo_supported OUTPUT error)
    if(ipo_supported)
        set(CMAKE_INTERPROCEDURAL_OPTIMIZATION TRUE)
    endif()
endif()

find_package(Qt6 REQUIRED COMPONENTS Core Gui Qml Quick OpenGL Multimedia Sensors ShaderTools Test)

qt_standard_project_setup(REQUIRES 6.7)

qt_add_executable(SnakeGB
    src/main.cpp
    src/game_logic.cpp
    src/game_logic.h
    src/sound_manager.cpp
    src/sound_manager.h
    src/profile_manager.cpp
    src/profile_manager.h
    src/fsm/states.cpp
    src/fsm/states.h
    src/fsm/game_state.h
    src/game_engine_interface.h
)

# Optimized resource mapping
qt_add_resources(SnakeGB "resources"
    PREFIX "/"
    BASE_RESOURCES_PATH "src/qml"
    FILES
        src/qml/main.qml
        src/qml/GameScreen.qml
        src/qml/DPad.qml
        src/qml/GBButton.qml
        src/qml/SmallButton.qml
        src/qml/OSDLayer.qml
        src/qml/MedalRoom.qml
        src/qml/GameBoyShell.qml
        src/qml/icon.svg
)

qt_add_resources(SnakeGB "levels"
    PREFIX "/"
    BASE_RESOURCES_PATH "src/levels"
    FILES
        src/levels/levels.json
)

qt6_add_shaders(SnakeGB "shaders"
    PREFIX "/shaders"
    FILES
        src/qml/lcd.frag
)

target_link_libraries(SnakeGB PRIVATE
    Qt6::Core
    Qt6::Gui
    Qt6::Qml
    Qt6::Quick
    Qt6::OpenGL
    Qt6::Multimedia
    Qt6::Sensors
)

if(NOT MSVC)
    if(APPLE)
        target_link_options(SnakeGB PRIVATE "-Wl,-dead_strip")
    else()
        target_link_options(SnakeGB PRIVATE "-Wl,--gc-sections" "-Wl,--strip-all")
    endif()
endif()

include(GNUInstallDirs)
install(TARGETS SnakeGB
    BUNDLE DESTINATION .
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
)

if(ANDROID)
    set_property(TARGET SnakeGB PROPERTY QT_ANDROID_PACKAGE_SOURCE_DIR "${CMAKE_CURRENT_SOURCE_DIR}/android")
endif()

enable_testing()
add_executable(game-tests
    tests/test_game_logic.cpp
    src/game_logic.cpp
    src/sound_manager.cpp
    src/profile_manager.cpp
    src/fsm/states.cpp
)
target_include_directories(game-tests PRIVATE src)
target_link_libraries(game-tests PRIVATE Qt6::Test Qt6::Core Qt6::Gui Qt6::Qml Qt6::Multimedia Qt6::Sensors)
add_test(NAME GameLogicTest COMMAND game-tests)
