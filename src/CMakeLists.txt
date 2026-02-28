add_library(snakegb_core
    core/game_rules.cpp
    core/buff_runtime.cpp
    core/session_core.cpp
    core/session_runner.cpp
    core/replay_timeline.cpp
    core/session_runtime.cpp
    core/level_runtime.cpp
    core/achievement_rules.cpp
    core/choice_runtime.cpp
)
target_include_directories(snakegb_core PUBLIC ${CMAKE_CURRENT_SOURCE_DIR})
target_link_libraries(snakegb_core PRIVATE Qt6::Core)

add_library(snakegb_fsm
    fsm/state_factory.cpp
    fsm/states.cpp
)
target_include_directories(snakegb_fsm PUBLIC ${CMAKE_CURRENT_SOURCE_DIR})
target_link_libraries(snakegb_fsm PRIVATE snakegb_core Qt6::Core)

add_library(snakegb_adapter
    adapter/engine_adapter.h
    adapter/engine_adapter.cpp
    adapter/input_router.cpp
    adapter/tick_driver.cpp
    adapter/simulation.cpp
    adapter/board_state.cpp
    adapter/session_state_runtime.cpp
    adapter/session_state.cpp
    adapter/level_flow.cpp
    adapter/persistence.cpp
    adapter/choices.cpp
    adapter/lifecycle.cpp
    adapter/view_model.cpp
    adapter/ui_action.cpp
    adapter/input_semantics.cpp
    adapter/achievement_runtime.cpp
    adapter/ghost_store.cpp
    adapter/choice_models.cpp
    adapter/library_models.cpp
    adapter/profile_bridge.cpp
    adapter/level_applier.cpp
    adapter/level_loader.cpp
    adapter/level_script_runtime.cpp
    services/audio_bus.cpp
    services/level_repository.cpp
    services/save_repository.cpp
    profile_manager.cpp
    profile_manager.h
)
target_include_directories(snakegb_adapter PUBLIC ${CMAKE_CURRENT_SOURCE_DIR})
target_link_libraries(snakegb_adapter PRIVATE snakegb_fsm snakegb_core
    Qt6::Core
    Qt6::Gui
    Qt6::Qml
    Qt6::Quick
)

add_executable(SnakeGB
    main.cpp
    app_state.h
    power_up_id.h
    input_injection_pipe.cpp
    input_injection_pipe.h
    sound_manager.cpp
    sound_manager.h
)
target_link_libraries(SnakeGB PRIVATE snakegb_adapter)

if(TARGET Qt6::Multimedia)
    target_link_libraries(snakegb_adapter PRIVATE Qt6::Multimedia)
    target_compile_definitions(snakegb_adapter PRIVATE SNAKEGB_HAS_MULTIMEDIA)
endif()
if(TARGET Qt6::Sensors)
    target_link_libraries(snakegb_adapter PRIVATE Qt6::Sensors)
    target_compile_definitions(snakegb_adapter PRIVATE SNAKEGB_HAS_SENSORS)
endif()
