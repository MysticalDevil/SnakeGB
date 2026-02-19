cmake_minimum_required(VERSION 3.25)
project(gameboy-snack VERSION 0.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 23)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
set(CMAKE_AUTOUIC ON)

find_package(Qt6 REQUIRED COMPONENTS Core Gui Qml Quick)

qt_add_executable(gameboy-snack
    main.cpp
    game_logic.cpp
    game_logic.h
    resources.qrc
)

target_link_libraries(gameboy-snack PRIVATE
    Qt6::Core
    Qt6::Gui
    Qt6::Qml
    Qt6::Quick
)

target_compile_definitions(gameboy-snack PRIVATE
    $<$<CONFIG:Debug>:QT_QML_DEBUG>
)
