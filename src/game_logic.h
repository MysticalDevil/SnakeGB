#pragma once

#include <deque>
#include <QAbstractListModel>
#include <QObject>
#include <QPoint>
#include <QRandomGenerator>
#include <QSettings>
#include <QTimer>

class SnakeModel : public QAbstractListModel
{
    Q_OBJECT
public:
    enum Roles
    {
        PositionRole = Qt::UserRole + 1
    };
    explicit SnakeModel(QObject *parent = nullptr) : QAbstractListModel(parent) {}
    int rowCount(const QModelIndex &parent = QModelIndex()) const override
    {
        return static_cast<int>(m_body.size());
    }
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override
    {
        if (!index.isValid() || index.row() >= m_body.size())
            return {};
        if (role == PositionRole)
            return m_body[index.row()];
        return {};
    }
    QHash<int, QByteArray> roleNames() const override
    {
        return {{PositionRole, "pos"}};
    }
    void reset(const std::deque<QPoint> &newBody)
    {
        beginResetModel();
        m_body = newBody;
        endResetModel();
    }
    void moveHead(const QPoint &newHead, bool grew)
    {
        beginInsertRows(QModelIndex(), 0, 0);
        m_body.push_front(newHead);
        endInsertRows();
        if (!grew) {
            int last = static_cast<int>(m_body.size() - 1);
            beginRemoveRows(QModelIndex(), last, last);
            m_body.pop_back();
            endRemoveRows();
        }
    }

private:
    std::deque<QPoint> m_body;
};

class GameLogic : public QObject
{
    Q_OBJECT
    Q_PROPERTY(SnakeModel *snakeModel READ snakeModel CONSTANT)
    Q_PROPERTY(QPoint food READ food NOTIFY foodChanged)
    Q_PROPERTY(int score READ score NOTIFY scoreChanged)
    Q_PROPERTY(int highScore READ highScore NOTIFY highScoreChanged)
    Q_PROPERTY(State state READ state NOTIFY stateChanged)
    Q_PROPERTY(int boardWidth READ boardWidth CONSTANT)
    Q_PROPERTY(int boardHeight READ boardHeight CONSTANT)

public:
    enum State
    {
        StartMenu,
        Playing,
        Paused,
        GameOver
    };
    Q_ENUM(State)

    explicit GameLogic(QObject *parent = nullptr);

    SnakeModel *snakeModel()
    {
        return &m_snakeModel;
    }
    [[nodiscard]] QPoint food() const noexcept
    {
        return m_food;
    }
    [[nodiscard]] int score() const noexcept
    {
        return m_score;
    }
    [[nodiscard]] int highScore() const noexcept
    {
        return m_highScore;
    }
    [[nodiscard]] State state() const noexcept
    {
        return m_state;
    }
    static constexpr int boardWidth() noexcept
    {
        return 20;
    }
    static constexpr int boardHeight() noexcept
    {
        return 18;
    }

    Q_INVOKABLE void move(int dx, int dy);
    Q_INVOKABLE void startGame();
    Q_INVOKABLE void restart();
    Q_INVOKABLE void togglePause();

signals:
    void foodChanged();
    void scoreChanged();
    void highScoreChanged();
    void stateChanged();
    void requestFeedback();

private slots:
    void update();

private:
    void spawnFood();
    void updateHighScore();
    [[nodiscard]] bool isOutOfBounds(const QPoint &p) const noexcept;

    SnakeModel m_snakeModel;
    std::deque<QPoint> m_currentBody;
    QPoint m_food;
    QPoint m_direction;
    int m_score = 0;
    int m_highScore = 0;
    State m_state = StartMenu;
    QTimer *m_timer;
    int m_currentInterval = 150;
};
