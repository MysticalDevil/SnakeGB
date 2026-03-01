cmake_minimum_required(VERSION 3.16)

project(SnakeGB VERSION 1.5.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 23)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Place executables in the build root (not subdirectories like build/<profile>/src).
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR})
if(CMAKE_CONFIGURATION_TYPES)
    foreach(cfg IN LISTS CMAKE_CONFIGURATION_TYPES)
        string(TOUPPER "${cfg}" cfg_upper)
        set(CMAKE_RUNTIME_OUTPUT_DIRECTORY_${cfg_upper} ${CMAKE_BINARY_DIR})
    endforeach()
endif()

if(CMAKE_SOURCE_DIR STREQUAL CMAKE_BINARY_DIR)
    message(FATAL_ERROR "In-source builds are not supported. Use: cmake -S . -B build/<profile>")
endif()

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

add_subdirectory(src)

# Standard Resource mapping
qt_add_resources(SnakeGB "res"
    PREFIX "/"
    FILES
        "src/qml/main.qml"
        "src/qml/ScreenView.qml"
        "src/qml/IconLabLayer.qml"
        "src/qml/HudLayer.qml"
        "src/qml/ReplayBanner.qml"
        "src/qml/ModalSurface.qml"
        "src/qml/ModalTextPanel.qml"
        "src/qml/ModalChoiceCard.qml"
        "src/qml/LevelUpModal.qml"
        "src/qml/BuffStatusPanel.qml"
        "src/qml/LibraryLayer.qml"
        "src/qml/MenuLayer.qml"
        "src/qml/StaticDebugLayer.qml"
        "src/qml/OverlayLayer.qml"
        "src/qml/WorldLayer.qml"
        "src/qml/SplashLayer.qml"
        "src/qml/DPad.qml"
        "src/qml/GBButton.qml"
        "src/qml/SmallButton.qml"
        "src/qml/UiActionRouter.qml"
        "src/qml/DebugTokenRouter.qml"
        "src/qml/InputPressController.qml"
        "src/qml/OSDLayer.qml"
        "src/qml/MedalRoom.qml"
        "src/qml/MedalRoomCard.qml"
        "src/qml/Shell.qml"
        "src/qml/ShellBridge.qml"
        "src/qml/ShellSurface.qml"
        "src/qml/ScreenBezel.qml"
        "src/qml/ShellBranding.qml"
        "src/qml/SpeakerGrill.qml"
        "src/qml/VolumeWheel.qml"
        "src/qml/ThemeCatalog.js"
        "src/qml/ScreenThemeTokens.js"
        "src/qml/PowerMeta.js"
        "src/qml/ReadabilityRules.js"
        "src/qml/LayerScale.js"
        "src/qml/icon.svg"
        "src/themes/theme_catalog.json"
        "src/levels/levels.json"
)

# Shader compilation
qt6_add_shaders(SnakeGB "shaders"
    PREFIX "/shaders"
    FILES
        "src/qml/blur.frag"
        "src/qml/lcd.frag"
)

target_link_libraries(SnakeGB PRIVATE
    Qt6::Core
    Qt6::Gui
    Qt6::Qml
    Qt6::Quick
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
        foreach(target_name IN ITEMS snakegb_core snakegb_fsm snakegb_adapter SnakeGB)
            if(TARGET ${target_name})
                target_compile_options(${target_name} PRIVATE -ffunction-sections -fdata-sections)
                if(CMAKE_BUILD_TYPE STREQUAL "MinSizeRel")
                    target_compile_options(${target_name} PRIVATE -Oz)
                endif()
            endif()
        endforeach()
        target_link_options(SnakeGB PRIVATE -Wl,--gc-sections)
    endif()
endif()

if(ANDROID)
    set_property(TARGET SnakeGB PROPERTY QT_ANDROID_PACKAGE_SOURCE_DIR "${CMAKE_CURRENT_SOURCE_DIR}/android")
endif()

enable_testing()
add_executable(engine-adapter-tests
    tests/test_engine_adapter.cpp
)
target_include_directories(engine-adapter-tests PRIVATE src)
target_link_libraries(engine-adapter-tests PRIVATE Qt6::Test Qt6::Core Qt6::Gui Qt6::Qml snakegb_adapter)
if(TARGET Qt6::Multimedia)
    target_link_libraries(engine-adapter-tests PRIVATE Qt6::Multimedia)
    target_compile_definitions(engine-adapter-tests PRIVATE SNAKEGB_HAS_MULTIMEDIA)
endif()
if(TARGET Qt6::Sensors)
    target_link_libraries(engine-adapter-tests PRIVATE Qt6::Sensors)
    target_compile_definitions(engine-adapter-tests PRIVATE SNAKEGB_HAS_SENSORS)
endif()
add_test(NAME EngineAdapterTest COMMAND engine-adapter-tests)
set_tests_properties(EngineAdapterTest PROPERTIES ENVIRONMENT "QT_QPA_PLATFORM=offscreen")

add_executable(core-rules-tests
    tests/test_core_rules.cpp
)
target_include_directories(core-rules-tests PRIVATE src)
target_link_libraries(core-rules-tests PRIVATE Qt6::Test Qt6::Core Qt6::Gui snakegb_core snakegb_fsm)
add_test(NAME CoreRulesTest COMMAND core-rules-tests)
set_tests_properties(CoreRulesTest PROPERTIES ENVIRONMENT "QT_QPA_PLATFORM=offscreen")

add_executable(session-core-tests
    tests/test_session_core.cpp
)
target_include_directories(session-core-tests PRIVATE src)
target_link_libraries(session-core-tests PRIVATE Qt6::Test Qt6::Core Qt6::Gui snakegb_core)
add_test(NAME SessionCoreTest COMMAND session-core-tests)
set_tests_properties(SessionCoreTest PROPERTIES ENVIRONMENT "QT_QPA_PLATFORM=offscreen")

add_executable(session-runner-tests
    tests/test_session_runner.cpp
)
target_include_directories(session-runner-tests PRIVATE src)
target_link_libraries(session-runner-tests PRIVATE Qt6::Test Qt6::Core Qt6::Gui snakegb_core)
add_test(NAME SessionRunnerTest COMMAND session-runner-tests)
set_tests_properties(SessionRunnerTest PROPERTIES ENVIRONMENT "QT_QPA_PLATFORM=offscreen")

add_executable(adapter-tests
    tests/test_ui_action_parser.cpp
)
target_include_directories(adapter-tests PRIVATE src)
target_link_libraries(adapter-tests PRIVATE Qt6::Test Qt6::Core snakegb_adapter)
add_test(NAME AdapterTest COMMAND adapter-tests)
set_tests_properties(AdapterTest PROPERTIES ENVIRONMENT "QT_QPA_PLATFORM=offscreen")

add_executable(adapter-ui-dispatch-tests
    tests/test_ui_action_dispatch_adapter.cpp
)
target_include_directories(adapter-ui-dispatch-tests PRIVATE src)
target_link_libraries(adapter-ui-dispatch-tests PRIVATE Qt6::Test Qt6::Core snakegb_adapter)
add_test(NAME AdapterUiDispatchTest COMMAND adapter-ui-dispatch-tests)
set_tests_properties(AdapterUiDispatchTest PROPERTIES ENVIRONMENT "QT_QPA_PLATFORM=offscreen")

add_executable(adapter-ui-command-tests
    tests/test_ui_command_controller.cpp
)
target_include_directories(adapter-ui-command-tests PRIVATE src)
target_link_libraries(adapter-ui-command-tests PRIVATE Qt6::Test Qt6::Core Qt6::Gui Qt6::Qml snakegb_adapter)
if(TARGET Qt6::Multimedia)
    target_link_libraries(adapter-ui-command-tests PRIVATE Qt6::Multimedia)
    target_compile_definitions(adapter-ui-command-tests PRIVATE SNAKEGB_HAS_MULTIMEDIA)
endif()
if(TARGET Qt6::Sensors)
    target_link_libraries(adapter-ui-command-tests PRIVATE Qt6::Sensors)
    target_compile_definitions(adapter-ui-command-tests PRIVATE SNAKEGB_HAS_SENSORS)
endif()
add_test(NAME AdapterUiCommandTest COMMAND adapter-ui-command-tests)
set_tests_properties(AdapterUiCommandTest PROPERTIES ENVIRONMENT "QT_QPA_PLATFORM=offscreen")

add_executable(adapter-semantics-tests
    tests/test_input_semantics_adapter.cpp
)
target_include_directories(adapter-semantics-tests PRIVATE src)
target_link_libraries(adapter-semantics-tests PRIVATE Qt6::Test Qt6::Core snakegb_adapter)
add_test(NAME AdapterSemanticsTest COMMAND adapter-semantics-tests)
set_tests_properties(AdapterSemanticsTest PROPERTIES ENVIRONMENT "QT_QPA_PLATFORM=offscreen")

add_executable(adapter-theme-tests
    tests/test_theme_view_model.cpp
)
target_include_directories(adapter-theme-tests PRIVATE src)
target_link_libraries(adapter-theme-tests PRIVATE Qt6::Test Qt6::Core Qt6::Gui Qt6::Qml snakegb_adapter)
if(TARGET Qt6::Multimedia)
    target_link_libraries(adapter-theme-tests PRIVATE Qt6::Multimedia)
    target_compile_definitions(adapter-theme-tests PRIVATE SNAKEGB_HAS_MULTIMEDIA)
endif()
if(TARGET Qt6::Sensors)
    target_link_libraries(adapter-theme-tests PRIVATE Qt6::Sensors)
    target_compile_definitions(adapter-theme-tests PRIVATE SNAKEGB_HAS_SENSORS)
endif()
add_test(NAME AdapterThemeTest COMMAND adapter-theme-tests)
set_tests_properties(AdapterThemeTest PROPERTIES ENVIRONMENT "QT_QPA_PLATFORM=offscreen")

add_executable(adapter-session-status-tests
    tests/test_session_status_view_model.cpp
)
target_include_directories(adapter-session-status-tests PRIVATE src)
target_link_libraries(adapter-session-status-tests PRIVATE Qt6::Test Qt6::Core Qt6::Gui Qt6::Qml snakegb_adapter)
if(TARGET Qt6::Multimedia)
    target_link_libraries(adapter-session-status-tests PRIVATE Qt6::Multimedia)
    target_compile_definitions(adapter-session-status-tests PRIVATE SNAKEGB_HAS_MULTIMEDIA)
endif()
if(TARGET Qt6::Sensors)
    target_link_libraries(adapter-session-status-tests PRIVATE Qt6::Sensors)
    target_compile_definitions(adapter-session-status-tests PRIVATE SNAKEGB_HAS_SENSORS)
endif()
add_test(NAME AdapterSessionStatusTest COMMAND adapter-session-status-tests)
set_tests_properties(AdapterSessionStatusTest PROPERTIES ENVIRONMENT "QT_QPA_PLATFORM=offscreen")

add_executable(adapter-session-render-tests
    tests/test_session_render_view_model.cpp
)
target_include_directories(adapter-session-render-tests PRIVATE src)
target_link_libraries(adapter-session-render-tests PRIVATE Qt6::Test Qt6::Core Qt6::Gui Qt6::Qml snakegb_adapter)
if(TARGET Qt6::Multimedia)
    target_link_libraries(adapter-session-render-tests PRIVATE Qt6::Multimedia)
    target_compile_definitions(adapter-session-render-tests PRIVATE SNAKEGB_HAS_MULTIMEDIA)
endif()
if(TARGET Qt6::Sensors)
    target_link_libraries(adapter-session-render-tests PRIVATE Qt6::Sensors)
    target_compile_definitions(adapter-session-render-tests PRIVATE SNAKEGB_HAS_SENSORS)
endif()
add_test(NAME AdapterSessionRenderTest COMMAND adapter-session-render-tests)
set_tests_properties(AdapterSessionRenderTest PROPERTIES ENVIRONMENT "QT_QPA_PLATFORM=offscreen")

add_executable(adapter-selection-tests
    tests/test_selection_view_model.cpp
)
target_include_directories(adapter-selection-tests PRIVATE src)
target_link_libraries(adapter-selection-tests PRIVATE Qt6::Test Qt6::Core Qt6::Gui Qt6::Qml snakegb_adapter)
if(TARGET Qt6::Multimedia)
    target_link_libraries(adapter-selection-tests PRIVATE Qt6::Multimedia)
    target_compile_definitions(adapter-selection-tests PRIVATE SNAKEGB_HAS_MULTIMEDIA)
endif()
if(TARGET Qt6::Sensors)
    target_link_libraries(adapter-selection-tests PRIVATE Qt6::Sensors)
    target_compile_definitions(adapter-selection-tests PRIVATE SNAKEGB_HAS_SENSORS)
endif()
add_test(NAME AdapterSelectionTest COMMAND adapter-selection-tests)
set_tests_properties(AdapterSelectionTest PROPERTIES ENVIRONMENT "QT_QPA_PLATFORM=offscreen")

add_executable(adapter-audio-settings-tests
    tests/test_audio_settings_view_model.cpp
)
target_include_directories(adapter-audio-settings-tests PRIVATE src)
target_link_libraries(adapter-audio-settings-tests PRIVATE Qt6::Test Qt6::Core Qt6::Gui Qt6::Qml snakegb_adapter)
if(TARGET Qt6::Multimedia)
    target_link_libraries(adapter-audio-settings-tests PRIVATE Qt6::Multimedia)
    target_compile_definitions(adapter-audio-settings-tests PRIVATE SNAKEGB_HAS_MULTIMEDIA)
endif()
if(TARGET Qt6::Sensors)
    target_link_libraries(adapter-audio-settings-tests PRIVATE Qt6::Sensors)
    target_compile_definitions(adapter-audio-settings-tests PRIVATE SNAKEGB_HAS_SENSORS)
endif()
add_test(NAME AdapterAudioSettingsTest COMMAND adapter-audio-settings-tests)
set_tests_properties(AdapterAudioSettingsTest PROPERTIES ENVIRONMENT "QT_QPA_PLATFORM=offscreen")

add_executable(adapter-level-loader-tests
    tests/test_level_loader_adapter.cpp
)
target_include_directories(adapter-level-loader-tests PRIVATE src)
target_link_libraries(adapter-level-loader-tests PRIVATE Qt6::Test Qt6::Core snakegb_adapter)
add_test(NAME AdapterLevelLoaderTest COMMAND adapter-level-loader-tests)
set_tests_properties(AdapterLevelLoaderTest PROPERTIES ENVIRONMENT "QT_QPA_PLATFORM=offscreen")

add_executable(service-level-repository-tests
    tests/test_level_repository_service.cpp
)
target_include_directories(service-level-repository-tests PRIVATE src)
target_link_libraries(service-level-repository-tests PRIVATE Qt6::Test Qt6::Core snakegb_adapter)
add_test(NAME ServiceLevelRepositoryTest COMMAND service-level-repository-tests)
set_tests_properties(ServiceLevelRepositoryTest PROPERTIES ENVIRONMENT "QT_QPA_PLATFORM=offscreen")

add_executable(service-audio-bus-tests
    tests/test_audio_bus_service.cpp
)
target_include_directories(service-audio-bus-tests PRIVATE src)
target_link_libraries(service-audio-bus-tests PRIVATE Qt6::Test Qt6::Core snakegb_adapter)
add_test(NAME ServiceAudioBusTest COMMAND service-audio-bus-tests)
set_tests_properties(ServiceAudioBusTest PROPERTIES ENVIRONMENT "QT_QPA_PLATFORM=offscreen")

add_executable(adapter-level-applier-tests
    tests/test_level_applier_adapter.cpp
)
target_include_directories(adapter-level-applier-tests PRIVATE src)
target_link_libraries(adapter-level-applier-tests PRIVATE Qt6::Test Qt6::Core Qt6::Gui snakegb_adapter)
add_test(NAME AdapterLevelApplierTest COMMAND adapter-level-applier-tests)
set_tests_properties(AdapterLevelApplierTest PROPERTIES ENVIRONMENT "QT_QPA_PLATFORM=offscreen")

add_executable(adapter-level-script-runtime-tests
    tests/test_level_script_runtime_adapter.cpp
)
target_include_directories(adapter-level-script-runtime-tests PRIVATE src)
target_link_libraries(adapter-level-script-runtime-tests PRIVATE Qt6::Test Qt6::Core Qt6::Qml snakegb_adapter)
add_test(NAME AdapterLevelScriptRuntimeTest COMMAND adapter-level-script-runtime-tests)
set_tests_properties(AdapterLevelScriptRuntimeTest PROPERTIES ENVIRONMENT "QT_QPA_PLATFORM=offscreen")

add_executable(adapter-ghost-store-tests
    tests/test_ghost_store_adapter.cpp
)
target_include_directories(adapter-ghost-store-tests PRIVATE src)
target_link_libraries(adapter-ghost-store-tests PRIVATE Qt6::Test Qt6::Core snakegb_adapter)
add_test(NAME AdapterGhostStoreTest COMMAND adapter-ghost-store-tests)
set_tests_properties(AdapterGhostStoreTest PROPERTIES ENVIRONMENT "QT_QPA_PLATFORM=offscreen")

add_executable(adapter-session-state-tests
    tests/test_session_state_adapter.cpp
)
target_include_directories(adapter-session-state-tests PRIVATE src)
target_link_libraries(adapter-session-state-tests PRIVATE Qt6::Test Qt6::Core snakegb_adapter)
add_test(NAME AdapterSessionStateTest COMMAND adapter-session-state-tests)
set_tests_properties(AdapterSessionStateTest PROPERTIES ENVIRONMENT "QT_QPA_PLATFORM=offscreen")

add_executable(adapter-library-models-tests
    tests/test_library_models_adapter.cpp
)
target_include_directories(adapter-library-models-tests PRIVATE src)
target_link_libraries(adapter-library-models-tests PRIVATE Qt6::Test Qt6::Core snakegb_adapter)
add_test(NAME AdapterLibraryModelsTest COMMAND adapter-library-models-tests)
set_tests_properties(AdapterLibraryModelsTest PROPERTIES ENVIRONMENT "QT_QPA_PLATFORM=offscreen")

add_executable(adapter-choice-models-tests
    tests/test_choice_models_adapter.cpp
)
target_include_directories(adapter-choice-models-tests PRIVATE src)
target_link_libraries(adapter-choice-models-tests PRIVATE Qt6::Test Qt6::Core snakegb_adapter)
add_test(NAME AdapterChoiceModelsTest COMMAND adapter-choice-models-tests)
set_tests_properties(AdapterChoiceModelsTest PROPERTIES ENVIRONMENT "QT_QPA_PLATFORM=offscreen")

if(UNIX AND NOT APPLE AND NOT ANDROID)
    install(TARGETS SnakeGB RUNTIME DESTINATION bin)
    install(FILES linux/org.devil.snakegb.desktop DESTINATION share/applications)
    install(FILES src/qml/icon.svg DESTINATION share/icons/hicolor/scalable/apps RENAME snakegb.svg)
endif()
