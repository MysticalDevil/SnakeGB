#pragma once

#include <QAbstractListModel>
#include <QColor>
#include <QObject>
#include <QRect>
#include <QSettings>
#include <QTimer>
#include <QVariantList>
#include <QRandomGenerator>
#include <QJSEngine>
#include <deque>
#include <memory>
#include <queue>

class SoundManager;
class GameState;
class SplashState;
class MenuState;
class PlayingState;
class ReplayingState;
class PausedState;
class GameOverState;

struct ReplayFrame {
    int frame;
    int dx;
    int dy;
    friend QDataStream &operator<<(QDataStream &out, const ReplayFrame &f) { return out << f.frame << f.dx << f.dy; }
    friend QDataStream &operator>>(QDataStream &in, ReplayFrame &f) { return in >> f.frame >> f.dx >> f.dy; }
};

class SnakeModel final : public QAbstractListModel {
    Q_OBJECT
public:
    enum Roles { PositionRole = Qt::UserRole + 1 };
    explicit SnakeModel(QObject *parent = nullptr) : QAbstractListModel(parent) {}
    ~SnakeModel() override = default;
    SnakeModel(const SnakeModel &) = delete;
    auto operator=(const SnakeModel &) -> SnakeModel & = delete;
    SnakeModel(SnakeModel &&) = delete;
    auto operator=(SnakeModel &&) -> SnakeModel & = delete;

    [[nodiscard]] auto rowCount(const QModelIndex & /*parent*/ = QModelIndex()) const noexcept -> int override {
        return static_cast<int>(m_body.size());
    }
    [[nodiscard]] auto data(const QModelIndex &index, int role = Qt::DisplayRole) const -> QVariant override {
        if (!index.isValid() || index.row() < 0 || index.row() >= static_cast<int>(m_body.size())) return {};
        if (role == PositionRole) return m_body[static_cast<size_t>(index.row())];
        return {};
    }
    [[nodiscard]] auto roleNames() const -> QHash<int, QByteArray> override { return {{PositionRole, "pos"}}; }
    [[nodiscard]] const std::deque<QPoint> &body() const noexcept { return m_body; }
    auto reset(const std::deque<QPoint> &newBody) -> void { beginResetModel(); m_body = newBody; endResetModel(); }
    auto moveHead(const QPoint &newHead, const bool grew) -> void {
        beginInsertRows(QModelIndex(), 0, 0); m_body.emplace_front(newHead); endInsertRows();
        if (!grew) {
            const int last = static_cast<int>(m_body.size() - 1);
            if (last >= 0) { beginRemoveRows(QModelIndex(), last, last); m_body.pop_back(); endRemoveRows(); }
        }
    }
private:
    std::deque<QPoint> m_body;
};

class GameLogic final : public QObject {
    Q_OBJECT
    Q_PROPERTY(SnakeModel *snakeModel READ snakeModel CONSTANT)
    Q_PROPERTY(QPoint food READ food NOTIFY foodChanged)
    Q_PROPERTY(QPoint powerUpPos READ powerUpPos NOTIFY powerUpChanged)
    Q_PROPERTY(int powerUpType READ powerUpType NOTIFY powerUpChanged)
    Q_PROPERTY(int score READ score NOTIFY scoreChanged)
    Q_PROPERTY(int highScore READ highScore NOTIFY highScoreChanged)
    Q_PROPERTY(State state READ state NOTIFY stateChanged)
    Q_PROPERTY(int boardWidth READ boardWidth CONSTANT)
    Q_PROPERTY(int boardHeight READ boardHeight CONSTANT)
    Q_PROPERTY(QVariantList palette READ palette NOTIFY paletteChanged)
    Q_PROPERTY(QString paletteName READ paletteName NOTIFY paletteChanged)
    Q_PROPERTY(QVariantList obstacles READ obstacles NOTIFY obstaclesChanged)
    Q_PROPERTY(QColor shellColor READ shellColor NOTIFY shellColorChanged)
    Q_PROPERTY(bool hasSave READ hasSave NOTIFY hasSaveChanged)
    Q_PROPERTY(bool hasReplay READ hasReplay NOTIFY highScoreChanged)
    Q_PROPERTY(int level READ level NOTIFY levelChanged)
    Q_PROPERTY(QVariantList ghost READ ghost NOTIFY ghostChanged)
    Q_PROPERTY(bool musicEnabled READ musicEnabled NOTIFY musicEnabledChanged)
    Q_PROPERTY(int activeBuff READ activeBuff NOTIFY buffChanged)
    Q_PROPERTY(QVariantList achievements READ achievements NOTIFY achievementsChanged)
    Q_PROPERTY(QVariantList medalLibrary READ medalLibrary CONSTANT)

public:
    enum State { Splash, StartMenu, Playing, Paused, GameOver, Replaying };
    enum PowerUp { None = 0, Ghost = 1, Slow = 2, Magnet = 3 };
    Q_ENUM(State)
    Q_ENUM(PowerUp)

    explicit GameLogic(QObject *parent = nullptr);
    ~GameLogic() override;

    GameLogic(const GameLogic &) = delete;
    auto operator=(const GameLogic &) -> GameLogic & = delete;
    GameLogic(GameLogic &&) = delete;
    auto operator=(GameLogic &&) -> GameLogic & = delete;

    [[nodiscard]] auto snakeModel() noexcept -> SnakeModel * { return &m_snakeModel; }
    [[nodiscard]] auto food() const noexcept -> QPoint { return m_food; }
    [[nodiscard]] auto powerUpPos() const noexcept -> QPoint { return m_powerUpPos; }
    [[nodiscard]] auto powerUpType() const noexcept -> int { return static_cast<int>(m_powerUpType); }
    [[nodiscard]] auto activeBuff() const noexcept -> int { return static_cast<int>(m_activeBuff); }
    [[nodiscard]] auto score() const noexcept -> int { return m_score; }
    [[nodiscard]] auto highScore() const noexcept -> int { return m_highScore; }
    [[nodiscard]] auto state() const noexcept -> State { return m_state; }
    [[nodiscard]] auto boardWidth() const noexcept -> int { return BOARD_WIDTH; }
    [[nodiscard]] auto boardHeight() const noexcept -> int { return BOARD_HEIGHT; }
    [[nodiscard]] auto palette() const noexcept -> QVariantList;
    [[nodiscard]] auto paletteName() const noexcept -> QString;
    [[nodiscard]] auto obstacles() const noexcept -> QVariantList;
    [[nodiscard]] auto shellColor() const noexcept -> QColor;
    [[nodiscard]] auto hasSave() const noexcept -> bool;
    [[nodiscard]] auto hasReplay() const noexcept -> bool;
    [[nodiscard]] auto level() const noexcept -> int { return m_levelIndex; }
    [[nodiscard]] auto ghost() const noexcept -> QVariantList;
    [[nodiscard]] auto musicEnabled() const noexcept -> bool;
    [[nodiscard]] auto achievements() const noexcept -> QVariantList;
    [[nodiscard]] auto medalLibrary() const noexcept -> QVariantList;

    static constexpr int BOARD_WIDTH = 20;
    static constexpr int BOARD_HEIGHT = 18;

    Q_INVOKABLE void move(int dx, int dy);
    Q_INVOKABLE void startGame();
    Q_INVOKABLE void startReplay();
    Q_INVOKABLE void restart();
    Q_INVOKABLE void togglePause();
    Q_INVOKABLE void nextPalette();
    Q_INVOKABLE void nextShellColor();
    Q_INVOKABLE void loadLastSession();
    Q_INVOKABLE void nextLevel();
    Q_INVOKABLE void quitToMenu();
    Q_INVOKABLE void toggleMusic();
    Q_INVOKABLE void quit();
    Q_INVOKABLE void handleSelect();
    Q_INVOKABLE void handleStart();
    Q_INVOKABLE void deleteSave();

    auto changeState(std::unique_ptr<GameState> newState) -> void;
    auto setInternalState(State s) -> void;
    auto lazyInit() -> void;
    auto checkAchievements() -> void;
    auto incrementCrashes() -> void;
    auto logFoodEaten() -> void;
    auto logPowerUpTriggered(PowerUp type) -> void;
    
    // New Scripting API
    void runLevelScript();

    friend class SplashState;
    friend class MenuState;
    friend class PlayingState;
    friend class ReplayingState;
    friend class PausedState;
    friend class GameOverState;

signals:
    void foodChanged();
    void powerUpChanged();
    void buffChanged();
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
    void musicEnabledChanged();
    void achievementsChanged();
    void achievementEarned(QString title);

private slots:
    void update();
    void deactivateBuff();

private:
    auto spawnFood() -> void;
    auto spawnPowerUp() -> void;
    auto updateHighScore() -> void;
    auto saveCurrentState() -> void;
    auto clearSavedState() -> void;
    auto loadLevelData(int index) -> void;
    [[nodiscard]] static auto isOutOfBounds(const QPoint &p) noexcept -> bool;

    SnakeModel m_snakeModel;
    QRandomGenerator m_rng;
    QPoint m_food = {0, 0};
    QPoint m_powerUpPos = {-1, -1};
    PowerUp m_powerUpType = None;
    PowerUp m_activeBuff = None;
    QPoint m_direction = {0, -1};
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
    uint m_randomSeed = 0;
    uint m_bestRandomSeed = 0;
    int m_gameTickCounter = 0;
    QList<ReplayFrame> m_currentInputHistory;
    QList<ReplayFrame> m_bestInputHistory;
    int m_totalCrashes = 0;
    int m_totalFoodEaten = 0;
    int m_totalGhostTriggers = 0;
    qint64 m_sessionStartTime = 0;
    QList<QString> m_unlockedMedals;
    QSettings m_settings;

    // Scripting Engine
    QJSEngine m_jsEngine;
    QString m_currentScript;

    std::unique_ptr<QTimer> m_timer;
    std::unique_ptr<SoundManager> m_soundManager;
    std::unique_ptr<GameState> m_fsmState;
    std::deque<QPoint> m_inputQueue;
    std::unique_ptr<QTimer> m_buffTimer;

    static constexpr QRect m_boardRect{0, 0, BOARD_WIDTH, BOARD_HEIGHT};
};
