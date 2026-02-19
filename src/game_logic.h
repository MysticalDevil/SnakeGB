#pragma once

#include <QAbstractListModel>
#include <QColor>
#include <QObject>
#include <QRect>
#include <QSettings>
#include <QTimer>
#include <QVariantList>
#include <deque>
#include <memory>

class SoundManager;
class GameState;
class SplashState;
class MenuState;
class PlayingState;
class PausedState;
class GameOverState;

class SnakeModel final : public QAbstractListModel {
    Q_OBJECT
public:
    enum Roles { PositionRole = Qt::UserRole + 1 };
    explicit SnakeModel(QObject *parent = nullptr) : QAbstractListModel(parent) {}
    [[nodiscard]] int rowCount(const QModelIndex &parent = QModelIndex()) const noexcept override { return static_cast<int>(m_body.size()); }
    [[nodiscard]] QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override {
        if (!index.isValid() || index.row() < 0 || index.row() >= static_cast<int>(m_body.size())) return {};
        if (role == PositionRole) return m_body[static_cast<size_t>(index.row())];
        return {};
    }
    [[nodiscard]] QHash<int, QByteArray> roleNames() const override { return {{PositionRole, "pos"}}; }
    [[nodiscard]] const std::deque<QPoint> &body() const noexcept { return m_body; }
    void reset(const std::deque<QPoint> &newBody) { beginResetModel(); m_body = newBody; endResetModel(); }
    void moveHead(const QPoint &newHead, const bool grew) {
        beginInsertRows(QModelIndex(), 0, 0); m_body.emplace_front(newHead); endInsertRows();
        if (!grew) {
            const int last = static_cast<int>(m_body.size() - 1);
            beginRemoveRows(QModelIndex(), last, last); m_body.pop_back(); endRemoveRows();
        }
    }
private:
    std::deque<QPoint> m_body;
};

class GameLogic final : public QObject {
    Q_OBJECT
    Q_PROPERTY(SnakeModel *snakeModel READ snakeModel CONSTANT)
    Q_PROPERTY(QPoint food READ food NOTIFY foodChanged)
    Q_PROPERTY(int score READ score NOTIFY scoreChanged)
    Q_PROPERTY(int highScore READ highScore NOTIFY highScoreChanged)
    Q_PROPERTY(State state READ state NOTIFY stateChanged)
    Q_PROPERTY(int boardWidth READ boardWidth CONSTANT)
    Q_PROPERTY(int boardHeight READ boardHeight CONSTANT)
    Q_PROPERTY(QVariantList palette READ palette NOTIFY paletteChanged)
    Q_PROPERTY(QVariantList obstacles READ obstacles NOTIFY obstaclesChanged)
    Q_PROPERTY(QColor shellColor READ shellColor NOTIFY shellColorChanged)
    Q_PROPERTY(bool hasSave READ hasSave NOTIFY hasSaveChanged)
    Q_PROPERTY(int level READ level NOTIFY levelChanged)
    Q_PROPERTY(QVariantList ghost READ ghost NOTIFY ghostChanged)

public:
    enum State { Splash, StartMenu, Playing, Paused, GameOver };
    Q_ENUM(State)

    explicit GameLogic(QObject *parent = nullptr);
    ~GameLogic() override;

    [[nodiscard]] SnakeModel *snakeModel() noexcept { return &m_snakeModel; }
    [[nodiscard]] QPoint food() const noexcept { return m_food; }
    [[nodiscard]] int score() const noexcept { return m_score; }
    [[nodiscard]] int highScore() const noexcept { return m_highScore; }
    [[nodiscard]] State state() const noexcept { return m_state; }
    [[nodiscard]] int boardWidth() const noexcept { return BOARD_WIDTH; }
    [[nodiscard]] int boardHeight() const noexcept { return BOARD_HEIGHT; }
    [[nodiscard]] QVariantList palette() const noexcept;
    [[nodiscard]] QVariantList obstacles() const noexcept;
    [[nodiscard]] QColor shellColor() const noexcept;
    [[nodiscard]] bool hasSave() const noexcept;
    [[nodiscard]] int level() const noexcept { return m_levelIndex; }
    [[nodiscard]] QVariantList ghost() const noexcept;

    static constexpr int BOARD_WIDTH = 20;
    static constexpr int BOARD_HEIGHT = 18;

    Q_INVOKABLE void move(const int dx, const int dy);
    Q_INVOKABLE void startGame();
    Q_INVOKABLE void restart();
    Q_INVOKABLE void togglePause();
    Q_INVOKABLE void nextPalette();
    Q_INVOKABLE void nextShellColor();
    Q_INVOKABLE void loadLastSession();
    Q_INVOKABLE void nextLevel();

    void changeState(std::unique_ptr<GameState> newState);
    void setInternalState(State s);

    friend class SplashState;
    friend class MenuState;
    friend class PlayingState;
    friend class PausedState;
    friend class GameOverState;

signals:
    void foodChanged();
    void scoreChanged();
    void highScoreChanged();
    void stateChanged();
    void requestFeedback(int magnitude);
    void paletteChanged();
    void obstaclesChanged();
    void shellColorChanged();
    void hasSaveChanged();
    void levelChanged();
    void ghostChanged();

private slots:
    void update();

private:
    void spawnFood();
    void updateHighScore();
    void saveCurrentState();
    void clearSavedState();
    void loadLevelData(int index);
    [[nodiscard]] static auto isOutOfBounds(const QPoint &p) noexcept -> bool;

    SnakeModel m_snakeModel;
    QPoint m_food;
    QPoint m_direction{0, -1};
    int m_score = 0;
    int m_highScore = 0;
    State m_state = Splash;
    int m_paletteIndex = 0;
    int m_shellIndex = 0;
    int m_levelIndex = 0;
    QList<QPoint> m_obstacles;

    QList<QPoint> m_currentRecording;
    QList<QPoint> m_bestRecording;
    int m_ghostFrameIndex = 0;

    std::unique_ptr<QTimer> m_timer;
    std::unique_ptr<SoundManager> m_soundManager;
    QSettings m_settings;
    std::unique_ptr<GameState> m_fsmState;

    static constexpr QRect m_boardRect{0, 0, BOARD_WIDTH, BOARD_HEIGHT};
};
