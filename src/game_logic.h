#pragma once

#include <QAbstractListModel>
#include <QObject>
#include <QRect>
#include <QSettings>
#include <QTimer>
#include <deque>
#include <memory>

class SoundManager; // Forward declaration

/**
 * @class SnakeModel
 * @brief 深度优化的蛇身模型，利用 C++23 语义
 */
class SnakeModel : public QAbstractListModel {
    Q_OBJECT
public:
    enum Roles { PositionRole = Qt::UserRole + 1 };
    explicit SnakeModel(QObject *parent = nullptr) : QAbstractListModel(parent) {}

    [[nodiscard]] int rowCount(const QModelIndex &parent = QModelIndex()) const noexcept override {
        return static_cast<int>(m_body.size());
    }

    [[nodiscard]] QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override {
        if (!index.isValid() || index.row() >= static_cast<int>(m_body.size())) {
            return {};
        }
        if (role == PositionRole) {
            return m_body[static_cast<size_t>(index.row())];
        }
        return {};
    }

    [[nodiscard]] QHash<int, QByteArray> roleNames() const override { return {{PositionRole, "pos"}}; }

    [[nodiscard]] const std::deque<QPoint> &body() const noexcept { return m_body; }

    void reset(const std::deque<QPoint> &newBody) {
        beginResetModel();
        m_body = newBody;
        endResetModel();
    }

    void moveHead(const QPoint &newHead, const bool grew) {
        beginInsertRows(QModelIndex(), 0, 0);
        m_body.emplace_front(newHead); // 优化：使用 emplace
        endInsertRows();

        if (!grew) {
            const int last = static_cast<int>(m_body.size() - 1);
            beginRemoveRows(QModelIndex(), last, last);
            m_body.pop_back();
            endRemoveRows();
        }
    }

private:
    std::deque<QPoint> m_body;
};

class GameLogic : public QObject {
    Q_OBJECT
    Q_PROPERTY(SnakeModel *snakeModel READ snakeModel CONSTANT)
    Q_PROPERTY(QPoint food READ food NOTIFY foodChanged)
    Q_PROPERTY(int score READ score NOTIFY scoreChanged)
    Q_PROPERTY(int highScore READ highScore NOTIFY highScoreChanged)
    Q_PROPERTY(State state READ state NOTIFY stateChanged)
    Q_PROPERTY(int boardWidth READ boardWidth CONSTANT)
    Q_PROPERTY(int boardHeight READ boardHeight CONSTANT)

public:
    enum State { StartMenu, Playing, Paused, GameOver };
    Q_ENUM(State)

    explicit GameLogic(QObject *parent = nullptr);
    ~GameLogic() override;

    [[nodiscard]] SnakeModel *snakeModel() noexcept { return &m_snakeModel; }
    [[nodiscard]] QPoint food() const noexcept { return m_food; }
    [[nodiscard]] int score() const noexcept { return m_score; }
    [[nodiscard]] int highScore() const noexcept { return m_highScore; }
    [[nodiscard]] State state() const noexcept { return m_state; }

    static constexpr int BOARD_WIDTH = 20;
    static constexpr int BOARD_HEIGHT = 18;

    [[nodiscard]] static int boardWidth() noexcept { return BOARD_WIDTH; }
    [[nodiscard]] static int boardHeight() noexcept { return BOARD_HEIGHT; }

    Q_INVOKABLE void move(const int dx, const int dy);
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

    [[nodiscard]] static auto isOutOfBounds(const QPoint &p) noexcept -> bool;

    SnakeModel m_snakeModel;
    QPoint m_food;
    QPoint m_direction{0, -1};
    int m_score = 0;
    int m_highScore = 0;
    State m_state = StartMenu;

    std::unique_ptr<QTimer> m_timer;
    std::unique_ptr<SoundManager> m_soundManager;
    QSettings m_settings{"MyCompany", "SnakeGB"};

    static constexpr QRect m_boardRect{0, 0, BOARD_WIDTH, BOARD_HEIGHT};
};
