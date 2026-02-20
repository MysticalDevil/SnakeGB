#pragma once

#include <QAbstractListModel>
#include <QColor>
#include <QObject>
#include <QRect>
#include <QTimer>
#include <QVariantList>
#include <QRandomGenerator>
#include <QJSEngine>
#include <QAccelerometer>
#include "game_engine_interface.h"
#include <deque>
#include <memory>

class SoundManager;
class ProfileManager;
class GameState;

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
    int rowCount(const QModelIndex &parent = QModelIndex()) const noexcept override { return static_cast<int>(m_body.size()); }
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override {
        if (!index.isValid() || index.row() < 0 || index.row() >= static_cast<int>(m_body.size())) return {};
        if (role == PositionRole) return m_body[static_cast<size_t>(index.row())];
        return {};
    }
    QHash<int, QByteArray> roleNames() const override { return {{PositionRole, "pos"}}; }
    const std::deque<QPoint> &body() const noexcept { return m_body; }
    void reset(const std::deque<QPoint> &newBody) { beginResetModel(); m_body = newBody; endResetModel(); }
    void moveHead(const QPoint &newHead, bool grew) {
        beginInsertRows(QModelIndex(), 0, 0); m_body.emplace_front(newHead); endInsertRows();
        if (!grew) {
            const int last = static_cast<int>(m_body.size() - 1);
            if (last >= 0) { beginRemoveRows(QModelIndex(), last, last); m_body.pop_back(); endRemoveRows(); }
        }
    }
private:
    std::deque<QPoint> m_body;
};

class GameLogic final : public QObject, public IGameEngine {
    Q_OBJECT
    Q_PROPERTY(SnakeModel *snakeModel READ snakeModelPtr CONSTANT)
    Q_PROPERTY(QPoint food READ food NOTIFY foodChanged)
    Q_PROPERTY(QPoint powerUpPos READ powerUpPos NOTIFY powerUpChanged)
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
    Q_PROPERTY(QString currentLevelName READ currentLevelName NOTIFY levelChanged)
    Q_PROPERTY(QVariantList ghost READ ghost NOTIFY ghostChanged)
    Q_PROPERTY(bool musicEnabled READ musicEnabled NOTIFY musicEnabledChanged)
    Q_PROPERTY(int activeBuff READ activeBuff NOTIFY buffChanged)
    Q_PROPERTY(QVariantList achievements READ achievements NOTIFY achievementsChanged)
    Q_PROPERTY(QVariantList medalLibrary READ medalLibrary CONSTANT)
    Q_PROPERTY(float coverage READ coverage NOTIFY scoreChanged)
    Q_PROPERTY(float volume READ volume WRITE setVolume NOTIFY volumeChanged)
    Q_PROPERTY(QPointF reflectionOffset READ reflectionOffset NOTIFY reflectionOffsetChanged)

public:
    enum State { Splash, StartMenu, Playing, Paused, GameOver, Replaying };
    enum PowerUp { None = 0, Ghost = 1, Slow = 2, Magnet = 3 };
    Q_ENUM(State)

    explicit GameLogic(QObject *parent = nullptr);
    ~GameLogic() override;

    // --- IGameEngine Interface ---
    void setInternalState(int s) override;
    void requestStateChange(int newState) override;
    
    SnakeModel* snakeModel() override { return &m_snakeModel; }
    QPoint& direction() override { return m_direction; }
    std::deque<QPoint>& inputQueue() override { return m_inputQueue; }
    QList<ReplayFrame>& currentInputHistory() override { return m_currentInputHistory; }
    QList<ReplayFrame>& bestInputHistory() override { return m_bestInputHistory; }
    int& gameTickCounter() override { return m_gameTickCounter; }
    QPoint foodPos() const override { return m_food; }
    bool hasSave() const override;

    bool checkCollision(const QPoint &head) override;
    void handleFoodConsumption(const QPoint &head) override;
    void handlePowerUpConsumption(const QPoint &head) override;
    void applyMovement(const QPoint &newHead, bool grew) override;

    void restart() override;
    void loadLastSession() override;
    void togglePause() override;
    void nextLevel() override;
    
    void startEngineTimer(int intervalMs = -1) override;
    void stopEngineTimer() override;

    void triggerHaptic(int magnitude) override;
    void playEventSound(int type, float pan = 0.0f) override;
    void updatePersistence() override;
    void lazyInit() override;
    void forceUpdate() override { update(); }

    // --- QML API ---
    Q_INVOKABLE void move(int dx, int dy);
    Q_INVOKABLE void startGame() { restart(); }
    Q_INVOKABLE void startReplay();
    Q_INVOKABLE void nextPalette();
    Q_INVOKABLE void nextShellColor();
    Q_INVOKABLE void quitToMenu();
    Q_INVOKABLE void toggleMusic();
    Q_INVOKABLE void quit();
    Q_INVOKABLE void handleSelect();
    Q_INVOKABLE void handleStart();
    Q_INVOKABLE void deleteSave();

    // Property Getters
    SnakeModel* snakeModelPtr() noexcept { return &m_snakeModel; }
    QPoint food() const noexcept { return m_food; }
    QPoint powerUpPos() const noexcept { return m_powerUpPos; }
    int score() const noexcept { return m_score; }
    int highScore() const;
    State state() const noexcept { return m_state; }
    int boardWidth() const noexcept { return BOARD_WIDTH; }
    int boardHeight() const noexcept { return BOARD_HEIGHT; }
    QVariantList palette() const;
    QString paletteName() const;
    QVariantList obstacles() const;
    QColor shellColor() const;
    bool hasReplay() const noexcept;
    int level() const noexcept { return m_levelIndex; }
    QString currentLevelName() const noexcept { return m_currentLevelName; }
    QVariantList ghost() const;
    bool musicEnabled() const noexcept;
    QVariantList achievements() const;
    QVariantList medalLibrary() const;
    float coverage() const noexcept;
    float volume() const;
    void setVolume(float v);
    QPointF reflectionOffset() const noexcept { return m_reflectionOffset; }
    int activeBuff() const noexcept { return static_cast<int>(m_activeBuff); }

    static constexpr int BOARD_WIDTH = 20;
    static constexpr int BOARD_HEIGHT = 18;

signals:
    void foodChanged(); void powerUpChanged(); void buffChanged(); void scoreChanged();
    void highScoreChanged(); void stateChanged(); void requestFeedback(int magnitude);
    void paletteChanged(); void obstaclesChanged(); void shellColorChanged();
    void hasSaveChanged(); void levelChanged(); void ghostChanged();
    void musicEnabledChanged(); void achievementsChanged(); void achievementEarned(QString title);
    void volumeChanged(); void reflectionOffsetChanged();
    
    void foodEaten(float pan); void powerUpEaten(); void playerCrashed(); void uiInteractTriggered();

private slots:
    void update();

private:
    void deactivateBuff();
    void changeState(std::unique_ptr<GameState> newState);
    void spawnFood();
    void spawnPowerUp();
    void updateHighScore();
    void saveCurrentState();
    void clearSavedState();
    void loadLevelData(int index);
    void checkAchievements();
    void runLevelScript();
    static bool isOutOfBounds(const QPoint &p) noexcept;

    SnakeModel m_snakeModel;
    QRandomGenerator m_rng;
    QPoint m_food = {0, 0};
    QPoint m_powerUpPos = {-1, -1};
    PowerUp m_powerUpType = None;
    PowerUp m_activeBuff = None;
    int m_buffTicksRemaining = 0;
    QPoint m_direction = {0, -1};
    int m_score = 0;
    State m_state = Splash;
    int m_levelIndex = 0;
    QString m_currentLevelName = QStringLiteral("Classic");
    QList<QPoint> m_obstacles;
    QList<QPoint> m_currentRecording;
    QList<QPoint> m_bestRecording;
    QList<ReplayFrame> m_currentInputHistory;
    QList<ReplayFrame> m_bestInputHistory;
    uint m_randomSeed = 0;
    uint m_bestRandomSeed = 0;
    int m_bestLevelIndex = 0;
    int m_gameTickCounter = 0;
    int m_ghostFrameIndex = 0;
    qint64 m_sessionStartTime = 0;
    QPointF m_reflectionOffset = {0.0, 0.0};
    QJSEngine m_jsEngine;
    QString m_currentScript;

    std::unique_ptr<QTimer> m_timer;
    std::unique_ptr<SoundManager> m_soundManager;
    std::unique_ptr<ProfileManager> m_profileManager;
    std::deque<QPoint> m_inputQueue;
    std::unique_ptr<GameState> m_fsmState;

    static constexpr QRect m_boardRect{0, 0, BOARD_WIDTH, BOARD_HEIGHT};
};
