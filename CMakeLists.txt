cmake_minimum_required(VERSION 3.16)

project(SnakeGB VERSION 1.4.6 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 23)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

if(NOT CMAKE_BUILD_TYPE)
    set(CMAKE_BUILD_TYPE "Release" CACHE STRING "Build type" FORCE)
endif()

option(SNAKEGB_OPTIMIZE_SIZE "Enable binary size optimizations" ON)

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
    src/input_injection_pipe.cpp
    src/input_injection_pipe.h
    src/app_state.h
    src/core/game_rules.cpp
    src/core/game_rules.h
    src/core/buff_runtime.cpp
    src/core/buff_runtime.h
    src/core/session_step.cpp
    src/core/session_step.h
    src/core/replay_timeline.cpp
    src/core/replay_timeline.h
    src/core/level_runtime.cpp
    src/core/level_runtime.h
    src/fsm/states.cpp
    src/fsm/states.h
    src/fsm/game_state.h
    src/game_engine_interface.h
)

# Standard Resource mapping
qt_add_resources(SnakeGB "res"
    PREFIX "/"
    FILES
        "src/qml/main.qml"
        "src/qml/GameScreen.qml"
        "src/qml/DPad.qml"
        "src/qml/GBButton.qml"
        "src/qml/SmallButton.qml"
        "src/qml/OSDLayer.qml"
        "src/qml/MedalRoom.qml"
        "src/qml/GameBoyShell.qml"
        "src/qml/ThemeCatalog.js"
        "src/qml/icon.svg"
        "src/themes/theme_catalog.json"
        "src/levels/levels.json"
)

# Shader compilation
qt6_add_shaders(SnakeGB "shaders"
    PREFIX "/shaders"
    FILES
        "src/qml/lcd.frag"
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

# Keep verbose logs in Debug, silence non-critical logs in release-like builds.
target_compile_definitions(SnakeGB PRIVATE
    $<$<OR:$<CONFIG:Release>,$<CONFIG:MinSizeRel>,$<CONFIG:RelWithDebInfo>>:
        QT_NO_DEBUG_OUTPUT;QT_NO_INFO_OUTPUT;QT_NO_WARNING_OUTPUT>
)

if(SNAKEGB_OPTIMIZE_SIZE)
    set(CMAKE_INTERPROCEDURAL_OPTIMIZATION_RELEASE ON)
    set(CMAKE_INTERPROCEDURAL_OPTIMIZATION_MINSIZEREL ON)
    if(CMAKE_CXX_COMPILER_ID MATCHES "GNU|Clang")
        target_compile_options(SnakeGB PRIVATE -ffunction-sections -fdata-sections)
        target_link_options(SnakeGB PRIVATE -Wl,--gc-sections)
        if(CMAKE_BUILD_TYPE STREQUAL "MinSizeRel")
            target_compile_options(SnakeGB PRIVATE -Oz)
        endif()
    endif()
endif()

if(ANDROID)
    set_property(TARGET SnakeGB PROPERTY QT_ANDROID_PACKAGE_SOURCE_DIR "${CMAKE_CURRENT_SOURCE_DIR}/android")
endif()

enable_testing()
add_executable(game-tests
    tests/test_game_logic.cpp
    src/game_logic.cpp
    src/core/game_rules.cpp
    src/core/buff_runtime.cpp
    src/core/session_step.cpp
    src/core/replay_timeline.cpp
    src/core/level_runtime.cpp
    src/sound_manager.cpp
    src/profile_manager.cpp
    src/fsm/states.cpp
)
target_include_directories(game-tests PRIVATE src)
target_link_libraries(game-tests PRIVATE Qt6::Test Qt6::Core Qt6::Gui Qt6::Qml Qt6::Multimedia Qt6::Sensors)
add_test(NAME GameLogicTest COMMAND game-tests)
