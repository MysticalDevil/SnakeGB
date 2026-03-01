add_library(snakegb_core
    core/game/rules.cpp
    core/buff/runtime.cpp
    core/session/core.cpp
    core/session/runner.cpp
    core/replay/timeline.cpp
    core/session/runtime.cpp
    core/level/runtime.cpp
    core/achievement/rules.cpp
    core/choice/runtime.cpp
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
    app_state.h
    audio/cue.h
    audio/event.h
    audio/score.h
    audio/score.cpp
    adapter/engine_adapter.h
    adapter/engine_adapter.cpp
    adapter/view_models/audio.h
    adapter/view_models/audio.cpp
    adapter/view_models/theme.h
    adapter/view_models/theme.cpp
    adapter/view_models/status.h
    adapter/view_models/status.cpp
    adapter/view_models/render.h
    adapter/view_models/render.cpp
    adapter/view_models/selection.h
    adapter/view_models/selection.cpp
    adapter/input/router.cpp
    adapter/tick_driver.cpp
    adapter/simulation.cpp
    adapter/board_state.cpp
    adapter/session/runtime.cpp
    adapter/session/state.cpp
    adapter/level/flow.cpp
    adapter/persistence.cpp
    adapter/choices.cpp
    adapter/lifecycle.cpp
    adapter/view_model.cpp
    adapter/ui/action.cpp
    adapter/ui/controller.cpp
    adapter/input/semantics.cpp
    adapter/achievement/runtime.cpp
    adapter/ghost/store.cpp
    adapter/models/choice.cpp
    adapter/models/library.cpp
    adapter/profile/bridge.cpp
    adapter/level/applier.cpp
    adapter/level/loader.cpp
    adapter/level/script_runtime.cpp
    services/audio/bus.cpp
    services/level/repository.cpp
    services/save/repository.cpp
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
qt_add_resources(snakegb_adapter "audio_score_res"
    PREFIX "/"
    FILES
        "audio/score_catalog.json"
)

add_executable(SnakeGB
    main.cpp
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
