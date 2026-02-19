#include "game_logic.h"
#include "sound_manager.h"
#include <QRandomGenerator>
#include <algorithm>
#include <ranges>

using namespace Qt::StringLiterals;

GameLogic::GameLogic(QObject *parent)
    : QObject(parent), m_timer(std::make_unique<QTimer>()),
      m_soundManager(std::make_unique<SoundManager>()), m_settings(u"MyCompany"_s, u"SnakeGB"_s) {
    connect(m_timer.get(), &QTimer::timeout, this, &GameLogic::update);
    m_highScore = m_settings.value(u"highScore"_s, 0).toInt();
    m_paletteIndex = m_settings.value(u"paletteIndex"_s, 0).toInt();
    m_shellIndex = m_settings.value(u"shellIndex"_s, 0).toInt();

    m_snakeModel.reset({{10, 10}, {10, 11}, {10, 12}});
    spawnFood();
}

GameLogic::~GameLogic() {
    if (m_state == Playing || m_state == Paused) {
        saveCurrentState();
    }
}

void GameLogic::startGame() { restart(); }

void GameLogic::restart() {
    m_snakeModel.reset({{10, 10}, {10, 11}, {10, 12}});
    m_direction = {0, -1};
    m_score = 0;
    m_state = Playing;
    m_obstacles.clear();
    clearSavedState();

    m_timer->start(150);
    spawnFood();
    m_soundManager->playBeep(1000, 200);

    emit scoreChanged();
    emit stateChanged();
    emit obstaclesChanged();
}

void GameLogic::togglePause() {
    if (m_state == Playing) {
        m_state = Paused;
        m_timer->stop();
        saveCurrentState();
    } else if (m_state == Paused) {
        m_state = Playing;
        m_timer->start();
    }
    emit stateChanged();
    emit requestFeedback();
}

void GameLogic::loadLastSession() {
    if (!m_settings.contains(u"saved_body"_s)) {
        return;
    }

    m_score = m_settings.value(u"saved_score"_s).toInt();

    std::deque<QPoint> body;
    const auto bodyVar = m_settings.value(u"saved_body"_s).toList();
    for (const auto &v : bodyVar) {
        body.emplace_back(v.toPoint());
    }

    m_obstacles.clear();
    const auto obsVar = m_settings.value(u"saved_obstacles"_s).toList();
    for (const auto &v : obsVar) {
        m_obstacles.emplace_back(v.toPoint());
    }

    m_food = m_settings.value(u"saved_food"_s).toPoint();
    m_direction = m_settings.value(u"saved_dir"_s).toPoint();

    m_snakeModel.reset(body);
    m_state = Paused;

    emit scoreChanged();
    emit stateChanged();
    emit obstaclesChanged();
    emit foodChanged();
    emit hasSaveChanged();
}

void GameLogic::saveCurrentState() {
    QVariantList bodyVar;
    for (const auto &p : m_snakeModel.body()) {
        bodyVar.append(p);
    }
    m_settings.setValue(u"saved_body"_s, bodyVar);

    QVariantList obsVar;
    for (const auto &p : m_obstacles) {
        obsVar.append(p);
    }
    m_settings.setValue(u"saved_obstacles"_s, obsVar);

    m_settings.setValue(u"saved_score"_s, m_score);
    m_settings.setValue(u"saved_food"_s, m_food);
    m_settings.setValue(u"saved_dir"_s, m_direction);

    emit hasSaveChanged();
}

void GameLogic::clearSavedState() {
    m_settings.remove(u"saved_body"_s);
    m_settings.remove(u"saved_obstacles"_s);
    emit hasSaveChanged();
}

bool GameLogic::hasSave() const noexcept { return m_settings.contains(u"saved_body"_s); }

void GameLogic::move(const int dx, const int dy) {
    if (m_state != Playing) {
        return;
    }
    if ((dx != 0 && m_direction.x() == -dx) || (dy != 0 && m_direction.y() == -dy)) {
        return;
    }
    m_direction = {dx, dy};
    m_soundManager->playBeep(200, 50);
}

void GameLogic::update() {
    if (m_state != Playing) {
        return;
    }
    const auto &body = m_snakeModel.body();
    const QPoint nextHead = body.front() + m_direction;

    if (isOutOfBounds(nextHead) || std::ranges::contains(body, nextHead) ||
        std::ranges::contains(m_obstacles, nextHead)) {
        m_state = GameOver;
        m_timer->stop();
        updateHighScore();
        clearSavedState();
        m_soundManager->playCrash(500);
        emit stateChanged();
        emit requestFeedback();
        return;
    }

    const bool grew = (nextHead == m_food);
    if (grew) {
        m_score++;
        m_timer->setInterval(std::max(50, 150 - (m_score / 5) * 10));
        m_soundManager->playBeep(880, 100);

        if (m_score % 10 == 0) {
            bool valid = false;
            while (!valid) {
                const QPoint obs(QRandomGenerator::global()->bounded(BOARD_WIDTH),
                                 QRandomGenerator::global()->bounded(BOARD_HEIGHT));
                if (!std::ranges::contains(body, obs) && obs != m_food &&
                    !std::ranges::contains(m_obstacles, obs)) {
                    m_obstacles.append(obs);
                    valid = true;
                }
            }
            emit obstaclesChanged();
        }
        emit scoreChanged();
        spawnFood();
        emit requestFeedback();
    }
    m_snakeModel.moveHead(nextHead, grew);
}

void GameLogic::nextPalette() {
    m_paletteIndex = (m_paletteIndex + 1) % 4;
    m_settings.setValue(u"paletteIndex"_s, m_paletteIndex);
    emit paletteChanged();
    m_soundManager->playBeep(600, 50);
}

void GameLogic::nextShellColor() {
    m_shellIndex = (m_shellIndex + 1) % 5;
    m_settings.setValue(u"shellIndex"_s, m_shellIndex);
    emit shellColorChanged();
    m_soundManager->playBeep(500, 50);
}

QVariantList GameLogic::palette() const noexcept {
    static const QList<QVariantList> palettes = {
        {u"#9bbc0f"_s, u"#8bac0f"_s, u"#306230"_s, u"#0f380f"_s},
        {u"#c4cfa1"_s, u"#8b956d"_s, u"#4d533c"_s, u"#1f1f1f"_s},
        {u"#70a0d0"_s, u"#4070a0"_s, u"#204060"_s, u"#001020"_s},
        {u"#ffffff"_s, u"#aaaaaa"_s, u"#555555"_s, u"#000000"_s}};
    return palettes[m_paletteIndex];
}

QVariantList GameLogic::obstacles() const noexcept {
    QVariantList list;
    for (const auto &p : m_obstacles) {
        list.append(p);
    }
    return list;
}

QColor GameLogic::shellColor() const noexcept {
    static const QList<QColor> colors = {u"#c0c0c0"_s, u"#f0f0f0"_s, u"#9370db"_s, u"#ffd700"_s,
                                         u"#32cd32"_s};
    return colors[m_shellIndex];
}

void GameLogic::updateHighScore() {
    if (m_score > m_highScore) {
        m_highScore = m_score;
        m_settings.setValue(u"highScore"_s, m_highScore);
        emit highScoreChanged();
    }
}

void GameLogic::spawnFood() {
    const auto &body = m_snakeModel.body();
    bool foodIsInvalid = true;
    while (foodIsInvalid) {
        m_food = QPoint(QRandomGenerator::global()->bounded(BOARD_WIDTH),
                        QRandomGenerator::global()->bounded(BOARD_HEIGHT));
        foodIsInvalid =
            std::ranges::contains(body, m_food) || std::ranges::contains(m_obstacles, m_food);
    }
    emit foodChanged();
}

auto GameLogic::isOutOfBounds(const QPoint &p) noexcept -> bool { return !m_boardRect.contains(p); }
