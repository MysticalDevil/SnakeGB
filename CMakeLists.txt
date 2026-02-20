cmake_minimum_required(VERSION 3.25)
project(SnakeGB VERSION 1.3.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 23)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

if(MSVC)
    add_compile_options(/W4 /WX)
else()
    add_compile_options(-Wall -Wextra -Wpedantic -Werror)
endif()

set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
set(CMAKE_AUTOUIC ON)

find_package(Qt6 REQUIRED COMPONENTS Core Gui Qml Quick Multimedia Test ShaderTools)

qt_standard_project_setup()

enable_testing()

set(PROJECT_SOURCES
    src/main.cpp
    src/game_logic.cpp
    src/game_logic.h
    src/sound_manager.cpp
    src/sound_manager.h
    src/fsm/states.cpp
    src/fsm/states.h
    src/fsm/game_state.h
    src/qml/resources.qrc
)

qt_add_executable(gameboy-snack
    ${PROJECT_SOURCES}
)
set_property(TARGET gameboy-snack PROPERTY QT_QML_MODULE_NO_IMPORT_SCAN TRUE)

# Platform Specific Deployment
if(ANDROID)
    set_property(TARGET gameboy-snack PROPERTY QT_ANDROID_PACKAGE_SOURCE_DIR "${CMAKE_CURRENT_SOURCE_DIR}/android")
elseif(WASM)
    # WASM settings
    set_target_properties(gameboy-snack PROPERTIES
        QT_WASM_PTHREADS OFF
        QT_WASM_INITIAL_MEMORY "64MB"
    )
endif()

set_target_properties(gameboy-snack PROPERTIES
    MACOSX_BUNDLE_ICON_FILE "icon.svg"
    WIN32_EXECUTABLE TRUE
)

qt_add_shaders(gameboy-snack "lcd_shaders"
    PREFIX "/shaders"
    FILES
        "src/qml/lcd.frag"
)

target_include_directories(gameboy-snack PRIVATE src)

target_link_libraries(gameboy-snack PRIVATE
    Qt6::Core
    Qt6::Gui
    Qt6::Qml
    Qt6::Quick
    Qt6::Multimedia
)

target_compile_definitions(gameboy-snack PRIVATE
    $<$<CONFIG:Debug>:QT_QML_DEBUG>
)

install(TARGETS gameboy-snack
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)

add_executable(game-tests
    tests/test_game_logic.cpp
    src/game_logic.cpp
    src/sound_manager.cpp
    src/fsm/states.cpp
)
target_include_directories(game-tests PRIVATE src)
target_link_libraries(game-tests PRIVATE Qt6::Test Qt6::Core Qt6::Gui Qt6::Multimedia Qt6::Qml)
add_test(NAME GameLogicTest COMMAND game-tests)

find_package(Doxygen)
if (DOXYGEN_FOUND)
    add_custom_target(docs
        COMMAND ${DOXYGEN_EXECUTABLE} ${CMAKE_CURRENT_SOURCE_DIR}/Doxyfile
        WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
        COMMENT "Generating API documentation with Doxygen"
        VERBATIM
    )
endif()
