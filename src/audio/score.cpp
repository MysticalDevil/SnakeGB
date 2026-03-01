#include "audio/score.h"

#include <array>
#include <cmath>

#include <QFile>
#include <QJsonArray>
#include <QJsonDocument>
#include <QJsonObject>

namespace snakegb::audio {
using namespace Qt::StringLiterals;
namespace {

struct ScoreCatalog {
  QVector<ScoreStep> uiInteractCue;
  QVector<ScoreStep> confirmCue;
  QVector<ScoreTrackStep> menuTrack;
  QVector<ScoreTrackStep> gameplayTrack;
  QVector<ScoreTrackStep> replayTrack;
};

auto parseDuty(const QStringView name, const PulseDuty fallback) -> PulseDuty {
  if (name == u"narrow") {
    return PulseDuty::Narrow;
  }
  if (name == u"quarter") {
    return PulseDuty::Quarter;
  }
  if (name == u"half") {
    return PulseDuty::Half;
  }
  if (name == u"wide") {
    return PulseDuty::Wide;
  }
  return fallback;
}

auto parseCueSteps(const QJsonArray& stepsJson) -> QVector<ScoreStep> {
  QVector<ScoreStep> steps;
  steps.reserve(stepsJson.size());
  for (const auto& item : stepsJson) {
    const auto object = item.toObject();
    steps.push_back({
      .frequencyHz = object.value("frequencyHz").toInt(),
      .durationMs = object.value("durationMs").toInt(),
      .duty = object.value("duty").toDouble(0.5),
      .amplitude = object.value("amplitude").toInt(32),
    });
  }
  return steps;
}

auto parseTrackSteps(const QJsonArray& stepsJson) -> QVector<ScoreTrackStep> {
  QVector<ScoreTrackStep> steps;
  steps.reserve(stepsJson.size());
  for (const auto& item : stepsJson) {
    const auto object = item.toObject();
    steps.push_back({
      .leadPitch = pitchFromName(object.value("lead").toString()),
      .bassPitch = pitchFromName(object.value("bass").toString()),
      .durationMs = object.value("durationMs").toInt(),
      .leadDuty = parseDuty(object.value("leadDuty").toString(), PulseDuty::Quarter),
      .bassDuty = parseDuty(object.value("bassDuty").toString(), PulseDuty::Half),
    });
  }
  return steps;
}

auto loadScoreCatalog() -> ScoreCatalog {
  QFile file(":/audio/score_catalog.json");
  if (!file.open(QIODevice::ReadOnly)) {
    return {};
  }

  const auto document = QJsonDocument::fromJson(file.readAll());
  if (!document.isObject()) {
    return {};
  }

  const auto root = document.object();
  const auto cues = root.value("cues").toObject();
  const auto tracks = root.value("tracks").toObject();

  return {
    .uiInteractCue = parseCueSteps(cues.value("ui_interact").toArray()),
    .confirmCue = parseCueSteps(cues.value("confirm").toArray()),
    .menuTrack = parseTrackSteps(tracks.value("menu").toArray()),
    .gameplayTrack = parseTrackSteps(tracks.value("gameplay").toArray()),
    .replayTrack = parseTrackSteps(tracks.value("replay").toArray()),
  };
}

auto catalog() -> const ScoreCatalog& {
  static const ScoreCatalog cached = loadScoreCatalog();
  return cached;
}

} // namespace

auto dutyCycle(const PulseDuty duty) -> double {
  switch (duty) {
  case PulseDuty::Narrow:
    return 0.125;
  case PulseDuty::Quarter:
    return 0.25;
  case PulseDuty::Half:
    return 0.5;
  case PulseDuty::Wide:
    return 0.75;
  }
  return 0.5;
}

auto pitchFrequencyHz(const Pitch pitch) -> int {
  if (pitch == Pitch::Rest) {
    return 0;
  }
  const auto midiNote = static_cast<int>(pitch);
  const auto semitoneOffset = static_cast<double>(midiNote - 69) / 12.0;
  return static_cast<int>(std::lround(440.0 * std::exp2(semitoneOffset)));
}

auto pitchFromName(const QStringView name) -> Pitch {
  static constexpr std::array noteMap{
    std::pair<QStringView, Pitch>{u"REST", Pitch::Rest},
    std::pair<QStringView, Pitch>{u"C3", Pitch::C3},
    std::pair<QStringView, Pitch>{u"D3", Pitch::D3},
    std::pair<QStringView, Pitch>{u"E3", Pitch::E3},
    std::pair<QStringView, Pitch>{u"F3", Pitch::F3},
    std::pair<QStringView, Pitch>{u"G3", Pitch::G3},
    std::pair<QStringView, Pitch>{u"A3", Pitch::A3},
    std::pair<QStringView, Pitch>{u"B3", Pitch::B3},
    std::pair<QStringView, Pitch>{u"C4", Pitch::C4},
    std::pair<QStringView, Pitch>{u"D4", Pitch::D4},
    std::pair<QStringView, Pitch>{u"E4", Pitch::E4},
    std::pair<QStringView, Pitch>{u"F4", Pitch::F4},
    std::pair<QStringView, Pitch>{u"G4", Pitch::G4},
    std::pair<QStringView, Pitch>{u"A4", Pitch::A4},
    std::pair<QStringView, Pitch>{u"B4", Pitch::B4},
    std::pair<QStringView, Pitch>{u"C5", Pitch::C5},
    std::pair<QStringView, Pitch>{u"D5", Pitch::D5},
    std::pair<QStringView, Pitch>{u"E5", Pitch::E5},
    std::pair<QStringView, Pitch>{u"F5", Pitch::F5},
    std::pair<QStringView, Pitch>{u"G5", Pitch::G5},
    std::pair<QStringView, Pitch>{u"A5", Pitch::A5},
  };

  for (const auto& [note, pitch] : noteMap) {
    if (name == note) {
      return pitch;
    }
  }
  return Pitch::Rest;
}

auto scoreCueSteps(const ScoreCueId cueId) -> std::span<const ScoreStep> {
  switch (cueId) {
  case ScoreCueId::UiInteract:
    return catalog().uiInteractCue;
  case ScoreCueId::Confirm:
    return catalog().confirmCue;
  }
  return {};
}

auto scoreTrackSteps(const ScoreTrackId trackId) -> std::span<const ScoreTrackStep> {
  switch (trackId) {
  case ScoreTrackId::Menu:
    return catalog().menuTrack;
  case ScoreTrackId::Gameplay:
    return catalog().gameplayTrack;
  case ScoreTrackId::Replay:
    return catalog().replayTrack;
  }
  return {};
}

} // namespace snakegb::audio
