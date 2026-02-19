#pragma once

#include <QObject>
#include <QPoint>
#include <QVector>
#include <QTimer>
#include <QRandomGenerator>
#include <QVariant>

class GameLogic : public QObject {
    Q_OBJECT
    Q_PROPERTY(QVariantList snake READ snake NOTIFY snakeChanged)
    Q_PROPERTY(QPoint food READ food NOTIFY foodChanged)
    Q_PROPERTY(int score READ score NOTIFY scoreChanged)
    Q_PROPERTY(State state READ state NOTIFY stateChanged)
    Q_PROPERTY(int boardWidth READ boardWidth CONSTANT)
    Q_PROPERTY(int boardHeight READ boardHeight CONSTANT)

public:
    enum State {
        StartMenu,
        Playing,
        GameOver
    };
    Q_ENUM(State)

    explicit GameLogic(QObject *parent = nullptr);

    QVariantList snake() const;
    QPoint food() const { return m_food; }
    int score() const { return m_score; }
    State state() const { return m_state; }
    int boardWidth() const { return m_boardWidth; }
    int boardHeight() const { return m_boardHeight; }

    Q_INVOKABLE void move(int dx, int dy);
    Q_INVOKABLE void startGame();
    Q_INVOKABLE void restart();

signals:
    void snakeChanged();
    void foodChanged();
    void scoreChanged();
    void stateChanged();

private slots:
    void update();

private:
    void spawnFood();
    bool isOutOfBounds(const QPoint &p) const;

    QVector<QPoint> m_snakeBody;
    QPoint m_food;
    QPoint m_direction;
    int m_score = 0;
    State m_state = StartMenu;
    const int m_boardWidth = 20;
    const int m_boardHeight = 18;
    QTimer *m_timer;
};
