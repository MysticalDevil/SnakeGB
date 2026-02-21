#pragma once

#include <QObject>

#include "game_logic.h"

class AppState final : public QObject {
    Q_OBJECT

public:
    explicit AppState(QObject *parent = nullptr) : QObject(parent) {}

    enum Value {
        Splash = GameLogic::Splash,
        StartMenu = GameLogic::StartMenu,
        Playing = GameLogic::Playing,
        Paused = GameLogic::Paused,
        GameOver = GameLogic::GameOver,
        Replaying = GameLogic::Replaying,
        ChoiceSelection = GameLogic::ChoiceSelection,
        Library = GameLogic::Library,
        MedalRoom = GameLogic::MedalRoom
    };
    Q_ENUM(Value)
};

