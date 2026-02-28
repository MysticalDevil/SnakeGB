#pragma once

#include <QObject>

class AppState final : public QObject {
    Q_OBJECT

public:
    explicit AppState(QObject *parent = nullptr) : QObject(parent) {}

    enum Value {
        Splash = 0,
        StartMenu = 1,
        Playing = 2,
        Paused = 3,
        GameOver = 4,
        Replaying = 5,
        ChoiceSelection = 6,
        Library = 7,
        MedalRoom = 8
    };
    Q_ENUM(Value)
};
