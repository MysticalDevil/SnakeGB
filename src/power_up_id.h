#pragma once

#include <QObject>

#include "core/buff/runtime.h"

class PowerUpId final : public QObject {
    Q_OBJECT

public:
    explicit PowerUpId(QObject *parent = nullptr) : QObject(parent) {}

    enum Value {
        None = static_cast<int>(snakegb::core::BuffId::None),
        Ghost = static_cast<int>(snakegb::core::BuffId::Ghost),
        Slow = static_cast<int>(snakegb::core::BuffId::Slow),
        Magnet = static_cast<int>(snakegb::core::BuffId::Magnet),
        Shield = static_cast<int>(snakegb::core::BuffId::Shield),
        Portal = static_cast<int>(snakegb::core::BuffId::Portal),
        Double = static_cast<int>(snakegb::core::BuffId::Double),
        Rich = static_cast<int>(snakegb::core::BuffId::Rich),
        Laser = static_cast<int>(snakegb::core::BuffId::Laser),
        Mini = static_cast<int>(snakegb::core::BuffId::Mini)
    };
    Q_ENUM(Value)
};
