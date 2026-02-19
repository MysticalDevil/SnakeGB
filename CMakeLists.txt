cmake_minimum_required(VERSION 3.25)
project(SnakeGB VERSION 1.0.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 23)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
set(CMAKE_AUTOUIC ON)

find_package(Qt6 REQUIRED COMPONENTS Core Gui Qml Quick)

# Group sources for better organization
set(PROJECT_SOURCES
    src/main.cpp
    src/game_logic.cpp
    src/game_logic.h
    src/qml/resources.qrc
)

qt_add_executable(gameboy-snack
    ${PROJECT_SOURCES}
)

# Include directories
target_include_directories(gameboy-snack PRIVATE src)

target_link_libraries(gameboy-snack PRIVATE
    Qt6::Core
    Qt6::Gui
    Qt6::Qml
    Qt6::Quick
)

target_compile_definitions(gameboy-snack PRIVATE
    $<$<CONFIG:Debug>:QT_QML_DEBUG>
)
