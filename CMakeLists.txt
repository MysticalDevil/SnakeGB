cmake_minimum_required(VERSION 3.16)

project(SnakeGB VERSION 1.3.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 23)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
set(CMAKE_AUTOUIC ON)

find_package(Qt6 REQUIRED COMPONENTS Core Gui Qml Quick Multimedia Network OpenGL)

qt_standard_project_setup()

set(PROJECT_SOURCES
    src/main.cpp
    src/game_logic.h
    src/game_logic.cpp
    src/sound_manager.h
    src/sound_manager.cpp
    src/fsm/game_state.h
    src/fsm/states.h
    src/fsm/states.cpp
    src/qml/resources.qrc
)

qt_add_executable(SnakeGB
    ${PROJECT_SOURCES}
)

target_include_directories(SnakeGB PRIVATE src)

# Set Android-specific properties
if(ANDROID)
    set_target_properties(SnakeGB PROPERTIES
        QT_ANDROID_PACKAGE_SOURCE_DIR "${CMAKE_CURRENT_SOURCE_DIR}/android"
    )
endif()

target_link_libraries(SnakeGB PRIVATE
    Qt6::Core
    Qt6::Gui
    Qt6::Qml
    Qt6::Quick
    Qt6::Multimedia
    Qt6::Network
    Qt6::OpenGL
)

# Shader compilation
find_package(Qt6ShaderTools REQUIRED)
qt_add_shaders(SnakeGB "shaders"
    PREFIX "/shaders"
    FILES
        "src/qml/lcd.frag"
)

# Testing (Disabled for Android)
if(NOT ANDROID)
    find_package(Qt6 REQUIRED COMPONENTS Test)
    enable_testing()
    add_executable(game-tests tests/test_game_logic.cpp src/game_logic.cpp src/sound_manager.cpp src/fsm/states.cpp)
    target_link_libraries(game-tests PRIVATE Qt6::Test Qt6::Core Qt6::Gui Qt6::Multimedia Qt6::Network Qt6::Qml)
    target_include_directories(game-tests PRIVATE src)
    add_test(NAME GameLogicTest COMMAND game-tests)
endif()

install(TARGETS SnakeGB
    BUNDLE DESTINATION .
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
)
