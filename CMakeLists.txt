cmake_minimum_required(VERSION 3.16)

project(SnakeGB VERSION 1.4.6 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 23)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

if(NOT CMAKE_BUILD_TYPE)
    set(CMAKE_BUILD_TYPE "Release" CACHE STRING "Build type" FORCE)
endif()

option(SNAKEGB_OPTIMIZE_SIZE "Enable binary size optimizations" ON)
option(SNAKEGB_USE_CCACHE "Use ccache as compiler launcher when available" ON)

if(SNAKEGB_USE_CCACHE)
    find_program(SNAKEGB_CCACHE_PROGRAM ccache)
    if(SNAKEGB_CCACHE_PROGRAM)
        set(SNAKEGB_CCACHE_DIR "${CMAKE_BINARY_DIR}/.ccache")
        set(CMAKE_C_COMPILER_LAUNCHER
            "${CMAKE_COMMAND};-E;env;CCACHE_DIR=${SNAKEGB_CCACHE_DIR};${SNAKEGB_CCACHE_PROGRAM}")
        set(CMAKE_CXX_COMPILER_LAUNCHER
            "${CMAKE_COMMAND};-E;env;CCACHE_DIR=${SNAKEGB_CCACHE_DIR};${SNAKEGB_CCACHE_PROGRAM}")
        message(STATUS "ccache enabled: ${SNAKEGB_CCACHE_PROGRAM} (dir=${SNAKEGB_CCACHE_DIR})")
    endif()
endif()

find_package(Qt6 REQUIRED COMPONENTS Core Gui Qml Quick OpenGL ShaderTools Test)
find_package(Qt6 QUIET COMPONENTS Multimedia Sensors)

qt_standard_project_setup(REQUIRES 6.7)
set(CMAKE_AUTOUIC OFF)

qt_add_executable(SnakeGB
    src/main.cpp
    src/game_logic.cpp
    src/game_logic_input.cpp
    src/game_logic_runtime.cpp
    src/game_logic_session.cpp
    src/game_logic_levels.cpp
    src/game_logic_persistence.cpp
    src/game_logic_choices.cpp
    src/game_logic_lifecycle.cpp
    src/game_logic_view.cpp
    src/game_logic.h
    src/sound_manager.cpp
    src/sound_manager.h
    src/profile_manager.cpp
    src/profile_manager.h
    src/input_injection_pipe.cpp
    src/input_injection_pipe.h
    src/adapter/ui_action.cpp
    src/adapter/ui_action.h
    src/adapter/input_semantics.cpp
    src/adapter/input_semantics.h
    src/adapter/ghost_store.cpp
    src/adapter/ghost_store.h
    src/adapter/choice_models.cpp
    src/adapter/choice_models.h
    src/adapter/library_models.cpp
    src/adapter/library_models.h
    src/adapter/session_state.cpp
    src/adapter/session_state.h
    src/adapter/profile_bridge.cpp
    src/adapter/profile_bridge.h
    src/adapter/level_applier.cpp
    src/adapter/level_applier.h
    src/adapter/level_loader.cpp
    src/adapter/level_loader.h
    src/adapter/level_script_runtime.cpp
    src/adapter/level_script_runtime.h
    src/app_state.h
    src/core/game_rules.cpp
    src/core/game_rules.h
    src/core/buff_runtime.cpp
    src/core/buff_runtime.h
    src/core/session_step.cpp
    src/core/session_step.h
    src/core/replay_timeline.cpp
    src/core/replay_timeline.h
    src/core/replay_types.h
    src/core/level_runtime.cpp
    src/core/level_runtime.h
    src/core/achievement_rules.cpp
    src/core/achievement_rules.h
    src/core/choice_runtime.cpp
    src/core/choice_runtime.h
    src/fsm/states.cpp
    src/fsm/state_factory.cpp
    src/fsm/states.h
    src/fsm/state_factory.h
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
)

if(TARGET Qt6::Multimedia)
    target_link_libraries(SnakeGB PRIVATE Qt6::Multimedia)
    target_compile_definitions(SnakeGB PRIVATE SNAKEGB_HAS_MULTIMEDIA)
endif()

if(TARGET Qt6::Sensors)
    target_link_libraries(SnakeGB PRIVATE Qt6::Sensors)
    target_compile_definitions(SnakeGB PRIVATE SNAKEGB_HAS_SENSORS)
endif()

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
    src/game_logic_input.cpp
    src/game_logic_runtime.cpp
    src/game_logic_session.cpp
    src/game_logic_levels.cpp
    src/game_logic_persistence.cpp
    src/game_logic_choices.cpp
    src/game_logic_lifecycle.cpp
    src/game_logic_view.cpp
    src/core/game_rules.cpp
    src/core/buff_runtime.cpp
    src/core/session_step.cpp
    src/core/replay_timeline.cpp
    src/core/level_runtime.cpp
    src/core/achievement_rules.cpp
    src/core/choice_runtime.cpp
    src/sound_manager.cpp
    src/profile_manager.cpp
    src/adapter/ui_action.cpp
    src/adapter/input_semantics.cpp
    src/adapter/ghost_store.cpp
    src/adapter/choice_models.cpp
    src/adapter/library_models.cpp
    src/adapter/session_state.cpp
    src/adapter/profile_bridge.cpp
    src/adapter/level_applier.cpp
    src/adapter/level_loader.cpp
    src/adapter/level_script_runtime.cpp
    src/fsm/state_factory.cpp
    src/fsm/states.cpp
)
target_include_directories(game-tests PRIVATE src)
target_link_libraries(game-tests PRIVATE Qt6::Test Qt6::Core Qt6::Gui Qt6::Qml)
if(TARGET Qt6::Multimedia)
    target_link_libraries(game-tests PRIVATE Qt6::Multimedia)
    target_compile_definitions(game-tests PRIVATE SNAKEGB_HAS_MULTIMEDIA)
endif()
if(TARGET Qt6::Sensors)
    target_link_libraries(game-tests PRIVATE Qt6::Sensors)
    target_compile_definitions(game-tests PRIVATE SNAKEGB_HAS_SENSORS)
endif()
add_test(NAME GameLogicTest COMMAND game-tests)
set_tests_properties(GameLogicTest PROPERTIES ENVIRONMENT "QT_QPA_PLATFORM=offscreen")

add_executable(core-rules-tests
    tests/test_core_rules.cpp
    src/core/game_rules.cpp
    src/core/buff_runtime.cpp
    src/core/replay_timeline.cpp
    src/core/level_runtime.cpp
    src/core/choice_runtime.cpp
)
target_include_directories(core-rules-tests PRIVATE src)
target_link_libraries(core-rules-tests PRIVATE Qt6::Test Qt6::Core Qt6::Gui)
add_test(NAME CoreRulesTest COMMAND core-rules-tests)
set_tests_properties(CoreRulesTest PROPERTIES ENVIRONMENT "QT_QPA_PLATFORM=offscreen")

add_executable(adapter-tests
    tests/test_ui_action_parser.cpp
    src/adapter/ui_action.cpp
)
target_include_directories(adapter-tests PRIVATE src)
target_link_libraries(adapter-tests PRIVATE Qt6::Test Qt6::Core)
add_test(NAME AdapterTest COMMAND adapter-tests)
set_tests_properties(AdapterTest PROPERTIES ENVIRONMENT "QT_QPA_PLATFORM=offscreen")

add_executable(adapter-ui-dispatch-tests
    tests/test_ui_action_dispatch_adapter.cpp
    src/adapter/ui_action.cpp
)
target_include_directories(adapter-ui-dispatch-tests PRIVATE src)
target_link_libraries(adapter-ui-dispatch-tests PRIVATE Qt6::Test Qt6::Core)
add_test(NAME AdapterUiDispatchTest COMMAND adapter-ui-dispatch-tests)
set_tests_properties(AdapterUiDispatchTest PROPERTIES ENVIRONMENT "QT_QPA_PLATFORM=offscreen")

add_executable(adapter-semantics-tests
    tests/test_input_semantics_adapter.cpp
    src/adapter/input_semantics.cpp
)
target_include_directories(adapter-semantics-tests PRIVATE src)
target_link_libraries(adapter-semantics-tests PRIVATE Qt6::Test Qt6::Core)
add_test(NAME AdapterSemanticsTest COMMAND adapter-semantics-tests)
set_tests_properties(AdapterSemanticsTest PROPERTIES ENVIRONMENT "QT_QPA_PLATFORM=offscreen")

add_executable(adapter-level-loader-tests
    tests/test_level_loader_adapter.cpp
    src/adapter/level_loader.cpp
    src/core/level_runtime.cpp
)
target_include_directories(adapter-level-loader-tests PRIVATE src)
target_link_libraries(adapter-level-loader-tests PRIVATE Qt6::Test Qt6::Core)
add_test(NAME AdapterLevelLoaderTest COMMAND adapter-level-loader-tests)
set_tests_properties(AdapterLevelLoaderTest PROPERTIES ENVIRONMENT "QT_QPA_PLATFORM=offscreen")

add_executable(adapter-level-applier-tests
    tests/test_level_applier_adapter.cpp
    src/adapter/level_applier.cpp
)
target_include_directories(adapter-level-applier-tests PRIVATE src)
target_link_libraries(adapter-level-applier-tests PRIVATE Qt6::Test Qt6::Core Qt6::Gui)
add_test(NAME AdapterLevelApplierTest COMMAND adapter-level-applier-tests)
set_tests_properties(AdapterLevelApplierTest PROPERTIES ENVIRONMENT "QT_QPA_PLATFORM=offscreen")

add_executable(adapter-level-script-runtime-tests
    tests/test_level_script_runtime_adapter.cpp
    src/adapter/level_script_runtime.cpp
    src/core/level_runtime.cpp
)
target_include_directories(adapter-level-script-runtime-tests PRIVATE src)
target_link_libraries(adapter-level-script-runtime-tests PRIVATE Qt6::Test Qt6::Core Qt6::Qml)
add_test(NAME AdapterLevelScriptRuntimeTest COMMAND adapter-level-script-runtime-tests)
set_tests_properties(AdapterLevelScriptRuntimeTest PROPERTIES ENVIRONMENT "QT_QPA_PLATFORM=offscreen")

add_executable(adapter-ghost-store-tests
    tests/test_ghost_store_adapter.cpp
    src/adapter/ghost_store.cpp
)
target_include_directories(adapter-ghost-store-tests PRIVATE src)
target_link_libraries(adapter-ghost-store-tests PRIVATE Qt6::Test Qt6::Core)
add_test(NAME AdapterGhostStoreTest COMMAND adapter-ghost-store-tests)
set_tests_properties(AdapterGhostStoreTest PROPERTIES ENVIRONMENT "QT_QPA_PLATFORM=offscreen")

add_executable(adapter-session-state-tests
    tests/test_session_state_adapter.cpp
    src/adapter/session_state.cpp
)
target_include_directories(adapter-session-state-tests PRIVATE src)
target_link_libraries(adapter-session-state-tests PRIVATE Qt6::Test Qt6::Core)
add_test(NAME AdapterSessionStateTest COMMAND adapter-session-state-tests)
set_tests_properties(AdapterSessionStateTest PROPERTIES ENVIRONMENT "QT_QPA_PLATFORM=offscreen")

add_executable(adapter-library-models-tests
    tests/test_library_models_adapter.cpp
    src/adapter/library_models.cpp
)
target_include_directories(adapter-library-models-tests PRIVATE src)
target_link_libraries(adapter-library-models-tests PRIVATE Qt6::Test Qt6::Core)
add_test(NAME AdapterLibraryModelsTest COMMAND adapter-library-models-tests)
set_tests_properties(AdapterLibraryModelsTest PROPERTIES ENVIRONMENT "QT_QPA_PLATFORM=offscreen")

add_executable(adapter-choice-models-tests
    tests/test_choice_models_adapter.cpp
    src/adapter/choice_models.cpp
)
target_include_directories(adapter-choice-models-tests PRIVATE src)
target_link_libraries(adapter-choice-models-tests PRIVATE Qt6::Test Qt6::Core)
add_test(NAME AdapterChoiceModelsTest COMMAND adapter-choice-models-tests)
set_tests_properties(AdapterChoiceModelsTest PROPERTIES ENVIRONMENT "QT_QPA_PLATFORM=offscreen")
