#pragma once

#include <QObject>

#include "adapter/engine_adapter.h"

class AppState final : public QObject {
    Q_OBJECT

public:
    explicit AppState(QObject *parent = nullptr) : QObject(parent) {}

    enum Value {
        Splash = EngineAdapter::Splash,
        StartMenu = EngineAdapter::StartMenu,
        Playing = EngineAdapter::Playing,
        Paused = EngineAdapter::Paused,
        GameOver = EngineAdapter::GameOver,
        Replaying = EngineAdapter::Replaying,
        ChoiceSelection = EngineAdapter::ChoiceSelection,
        Library = EngineAdapter::Library,
        MedalRoom = EngineAdapter::MedalRoom
    };
    Q_ENUM(Value)
};

