/****************************************************************************
** Meta object code from reading C++ file 'game_logic.h'
**
** Created by: The Qt Meta Object Compiler version 69 (Qt 6.10.1)
**
** WARNING! All changes made in this file will be lost!
*****************************************************************************/

#include "../../../src/game_logic.h"
#include <QtCore/qmetatype.h>

#include <QtCore/qtmochelpers.h>

#include <memory>


#include <QtCore/qxptype_traits.h>
#if !defined(Q_MOC_OUTPUT_REVISION)
#error "The header file 'game_logic.h' doesn't include <QObject>."
#elif Q_MOC_OUTPUT_REVISION != 69
#error "This file was generated using the moc from 6.10.1. It"
#error "cannot be used with the include files from this version of Qt."
#error "(The moc has changed too much.)"
#endif

#ifndef Q_CONSTINIT
#define Q_CONSTINIT
#endif

QT_WARNING_PUSH
QT_WARNING_DISABLE_DEPRECATED
QT_WARNING_DISABLE_GCC("-Wuseless-cast")
namespace {
struct qt_meta_tag_ZN10SnakeModelE_t {};
} // unnamed namespace

template <> constexpr inline auto SnakeModel::qt_create_metaobjectdata<qt_meta_tag_ZN10SnakeModelE_t>()
{
    namespace QMC = QtMocConstants;
    QtMocHelpers::StringRefStorage qt_stringData {
        "SnakeModel"
    };

    QtMocHelpers::UintData qt_methods {
    };
    QtMocHelpers::UintData qt_properties {
    };
    QtMocHelpers::UintData qt_enums {
    };
    return QtMocHelpers::metaObjectData<SnakeModel, qt_meta_tag_ZN10SnakeModelE_t>(QMC::MetaObjectFlag{}, qt_stringData,
            qt_methods, qt_properties, qt_enums);
}
Q_CONSTINIT const QMetaObject SnakeModel::staticMetaObject = { {
    QMetaObject::SuperData::link<QAbstractListModel::staticMetaObject>(),
    qt_staticMetaObjectStaticContent<qt_meta_tag_ZN10SnakeModelE_t>.stringdata,
    qt_staticMetaObjectStaticContent<qt_meta_tag_ZN10SnakeModelE_t>.data,
    qt_static_metacall,
    nullptr,
    qt_staticMetaObjectRelocatingContent<qt_meta_tag_ZN10SnakeModelE_t>.metaTypes,
    nullptr
} };

void SnakeModel::qt_static_metacall(QObject *_o, QMetaObject::Call _c, int _id, void **_a)
{
    auto *_t = static_cast<SnakeModel *>(_o);
    (void)_t;
    (void)_c;
    (void)_id;
    (void)_a;
}

const QMetaObject *SnakeModel::metaObject() const
{
    return QObject::d_ptr->metaObject ? QObject::d_ptr->dynamicMetaObject() : &staticMetaObject;
}

void *SnakeModel::qt_metacast(const char *_clname)
{
    if (!_clname) return nullptr;
    if (!strcmp(_clname, qt_staticMetaObjectStaticContent<qt_meta_tag_ZN10SnakeModelE_t>.strings))
        return static_cast<void*>(this);
    return QAbstractListModel::qt_metacast(_clname);
}

int SnakeModel::qt_metacall(QMetaObject::Call _c, int _id, void **_a)
{
    _id = QAbstractListModel::qt_metacall(_c, _id, _a);
    return _id;
}
namespace {
struct qt_meta_tag_ZN9GameLogicE_t {};
} // unnamed namespace

template <> constexpr inline auto GameLogic::qt_create_metaobjectdata<qt_meta_tag_ZN9GameLogicE_t>()
{
    namespace QMC = QtMocConstants;
    QtMocHelpers::StringRefStorage qt_stringData {
        "GameLogic",
        "foodChanged",
        "",
        "powerUpChanged",
        "buffChanged",
        "scoreChanged",
        "highScoreChanged",
        "stateChanged",
        "requestFeedback",
        "magnitude",
        "paletteChanged",
        "obstaclesChanged",
        "shellColorChanged",
        "hasSaveChanged",
        "levelChanged",
        "ghostChanged",
        "musicEnabledChanged",
        "achievementsChanged",
        "achievementEarned",
        "title",
        "volumeChanged",
        "reflectionOffsetChanged",
        "foodEaten",
        "pan",
        "powerUpEaten",
        "playerCrashed",
        "uiInteractTriggered",
        "update",
        "deactivateBuff",
        "move",
        "dx",
        "dy",
        "startGame",
        "startReplay",
        "restart",
        "togglePause",
        "nextPalette",
        "nextShellColor",
        "loadLastSession",
        "nextLevel",
        "quitToMenu",
        "toggleMusic",
        "quit",
        "handleSelect",
        "handleStart",
        "deleteSave",
        "snakeModel",
        "SnakeModel*",
        "food",
        "QPoint",
        "powerUpPos",
        "powerUpType",
        "score",
        "highScore",
        "state",
        "State",
        "boardWidth",
        "boardHeight",
        "palette",
        "QVariantList",
        "paletteName",
        "obstacles",
        "shellColor",
        "QColor",
        "hasSave",
        "hasReplay",
        "level",
        "currentLevelName",
        "ghost",
        "musicEnabled",
        "activeBuff",
        "achievements",
        "medalLibrary",
        "coverage",
        "volume",
        "reflectionOffset",
        "QPointF",
        "Splash",
        "StartMenu",
        "Playing",
        "Paused",
        "GameOver",
        "Replaying",
        "PowerUp",
        "None",
        "Ghost",
        "Slow",
        "Magnet"
    };

    QtMocHelpers::UintData qt_methods {
        // Signal 'foodChanged'
        QtMocHelpers::SignalData<void()>(1, 2, QMC::AccessPublic, QMetaType::Void),
        // Signal 'powerUpChanged'
        QtMocHelpers::SignalData<void()>(3, 2, QMC::AccessPublic, QMetaType::Void),
        // Signal 'buffChanged'
        QtMocHelpers::SignalData<void()>(4, 2, QMC::AccessPublic, QMetaType::Void),
        // Signal 'scoreChanged'
        QtMocHelpers::SignalData<void()>(5, 2, QMC::AccessPublic, QMetaType::Void),
        // Signal 'highScoreChanged'
        QtMocHelpers::SignalData<void()>(6, 2, QMC::AccessPublic, QMetaType::Void),
        // Signal 'stateChanged'
        QtMocHelpers::SignalData<void()>(7, 2, QMC::AccessPublic, QMetaType::Void),
        // Signal 'requestFeedback'
        QtMocHelpers::SignalData<void(int)>(8, 2, QMC::AccessPublic, QMetaType::Void, {{
            { QMetaType::Int, 9 },
        }}),
        // Signal 'paletteChanged'
        QtMocHelpers::SignalData<void()>(10, 2, QMC::AccessPublic, QMetaType::Void),
        // Signal 'obstaclesChanged'
        QtMocHelpers::SignalData<void()>(11, 2, QMC::AccessPublic, QMetaType::Void),
        // Signal 'shellColorChanged'
        QtMocHelpers::SignalData<void()>(12, 2, QMC::AccessPublic, QMetaType::Void),
        // Signal 'hasSaveChanged'
        QtMocHelpers::SignalData<void()>(13, 2, QMC::AccessPublic, QMetaType::Void),
        // Signal 'levelChanged'
        QtMocHelpers::SignalData<void()>(14, 2, QMC::AccessPublic, QMetaType::Void),
        // Signal 'ghostChanged'
        QtMocHelpers::SignalData<void()>(15, 2, QMC::AccessPublic, QMetaType::Void),
        // Signal 'musicEnabledChanged'
        QtMocHelpers::SignalData<void()>(16, 2, QMC::AccessPublic, QMetaType::Void),
        // Signal 'achievementsChanged'
        QtMocHelpers::SignalData<void()>(17, 2, QMC::AccessPublic, QMetaType::Void),
        // Signal 'achievementEarned'
        QtMocHelpers::SignalData<void(QString)>(18, 2, QMC::AccessPublic, QMetaType::Void, {{
            { QMetaType::QString, 19 },
        }}),
        // Signal 'volumeChanged'
        QtMocHelpers::SignalData<void()>(20, 2, QMC::AccessPublic, QMetaType::Void),
        // Signal 'reflectionOffsetChanged'
        QtMocHelpers::SignalData<void()>(21, 2, QMC::AccessPublic, QMetaType::Void),
        // Signal 'foodEaten'
        QtMocHelpers::SignalData<void(float)>(22, 2, QMC::AccessPublic, QMetaType::Void, {{
            { QMetaType::Float, 23 },
        }}),
        // Signal 'powerUpEaten'
        QtMocHelpers::SignalData<void()>(24, 2, QMC::AccessPublic, QMetaType::Void),
        // Signal 'playerCrashed'
        QtMocHelpers::SignalData<void()>(25, 2, QMC::AccessPublic, QMetaType::Void),
        // Signal 'uiInteractTriggered'
        QtMocHelpers::SignalData<void()>(26, 2, QMC::AccessPublic, QMetaType::Void),
        // Slot 'update'
        QtMocHelpers::SlotData<void()>(27, 2, QMC::AccessPrivate, QMetaType::Void),
        // Slot 'deactivateBuff'
        QtMocHelpers::SlotData<void()>(28, 2, QMC::AccessPrivate, QMetaType::Void),
        // Method 'move'
        QtMocHelpers::MethodData<void(int, int)>(29, 2, QMC::AccessPublic, QMetaType::Void, {{
            { QMetaType::Int, 30 }, { QMetaType::Int, 31 },
        }}),
        // Method 'startGame'
        QtMocHelpers::MethodData<void()>(32, 2, QMC::AccessPublic, QMetaType::Void),
        // Method 'startReplay'
        QtMocHelpers::MethodData<void()>(33, 2, QMC::AccessPublic, QMetaType::Void),
        // Method 'restart'
        QtMocHelpers::MethodData<void()>(34, 2, QMC::AccessPublic, QMetaType::Void),
        // Method 'togglePause'
        QtMocHelpers::MethodData<void()>(35, 2, QMC::AccessPublic, QMetaType::Void),
        // Method 'nextPalette'
        QtMocHelpers::MethodData<void()>(36, 2, QMC::AccessPublic, QMetaType::Void),
        // Method 'nextShellColor'
        QtMocHelpers::MethodData<void()>(37, 2, QMC::AccessPublic, QMetaType::Void),
        // Method 'loadLastSession'
        QtMocHelpers::MethodData<void()>(38, 2, QMC::AccessPublic, QMetaType::Void),
        // Method 'nextLevel'
        QtMocHelpers::MethodData<void()>(39, 2, QMC::AccessPublic, QMetaType::Void),
        // Method 'quitToMenu'
        QtMocHelpers::MethodData<void()>(40, 2, QMC::AccessPublic, QMetaType::Void),
        // Method 'toggleMusic'
        QtMocHelpers::MethodData<void()>(41, 2, QMC::AccessPublic, QMetaType::Void),
        // Method 'quit'
        QtMocHelpers::MethodData<void()>(42, 2, QMC::AccessPublic, QMetaType::Void),
        // Method 'handleSelect'
        QtMocHelpers::MethodData<void()>(43, 2, QMC::AccessPublic, QMetaType::Void),
        // Method 'handleStart'
        QtMocHelpers::MethodData<void()>(44, 2, QMC::AccessPublic, QMetaType::Void),
        // Method 'deleteSave'
        QtMocHelpers::MethodData<void()>(45, 2, QMC::AccessPublic, QMetaType::Void),
    };
    QtMocHelpers::UintData qt_properties {
        // property 'snakeModel'
        QtMocHelpers::PropertyData<SnakeModel*>(46, 0x80000000 | 47, QMC::DefaultPropertyFlags | QMC::EnumOrFlag | QMC::Constant),
        // property 'food'
        QtMocHelpers::PropertyData<QPoint>(48, 0x80000000 | 49, QMC::DefaultPropertyFlags | QMC::EnumOrFlag, 0),
        // property 'powerUpPos'
        QtMocHelpers::PropertyData<QPoint>(50, 0x80000000 | 49, QMC::DefaultPropertyFlags | QMC::EnumOrFlag, 1),
        // property 'powerUpType'
        QtMocHelpers::PropertyData<int>(51, QMetaType::Int, QMC::DefaultPropertyFlags, 1),
        // property 'score'
        QtMocHelpers::PropertyData<int>(52, QMetaType::Int, QMC::DefaultPropertyFlags, 3),
        // property 'highScore'
        QtMocHelpers::PropertyData<int>(53, QMetaType::Int, QMC::DefaultPropertyFlags, 4),
        // property 'state'
        QtMocHelpers::PropertyData<enum State>(54, 0x80000000 | 55, QMC::DefaultPropertyFlags | QMC::EnumOrFlag, 5),
        // property 'boardWidth'
        QtMocHelpers::PropertyData<int>(56, QMetaType::Int, QMC::DefaultPropertyFlags | QMC::Constant),
        // property 'boardHeight'
        QtMocHelpers::PropertyData<int>(57, QMetaType::Int, QMC::DefaultPropertyFlags | QMC::Constant),
        // property 'palette'
        QtMocHelpers::PropertyData<QVariantList>(58, 0x80000000 | 59, QMC::DefaultPropertyFlags | QMC::EnumOrFlag, 7),
        // property 'paletteName'
        QtMocHelpers::PropertyData<QString>(60, QMetaType::QString, QMC::DefaultPropertyFlags, 7),
        // property 'obstacles'
        QtMocHelpers::PropertyData<QVariantList>(61, 0x80000000 | 59, QMC::DefaultPropertyFlags | QMC::EnumOrFlag, 8),
        // property 'shellColor'
        QtMocHelpers::PropertyData<QColor>(62, 0x80000000 | 63, QMC::DefaultPropertyFlags | QMC::EnumOrFlag, 9),
        // property 'hasSave'
        QtMocHelpers::PropertyData<bool>(64, QMetaType::Bool, QMC::DefaultPropertyFlags, 10),
        // property 'hasReplay'
        QtMocHelpers::PropertyData<bool>(65, QMetaType::Bool, QMC::DefaultPropertyFlags, 4),
        // property 'level'
        QtMocHelpers::PropertyData<int>(66, QMetaType::Int, QMC::DefaultPropertyFlags, 11),
        // property 'currentLevelName'
        QtMocHelpers::PropertyData<QString>(67, QMetaType::QString, QMC::DefaultPropertyFlags, 11),
        // property 'ghost'
        QtMocHelpers::PropertyData<QVariantList>(68, 0x80000000 | 59, QMC::DefaultPropertyFlags | QMC::EnumOrFlag, 12),
        // property 'musicEnabled'
        QtMocHelpers::PropertyData<bool>(69, QMetaType::Bool, QMC::DefaultPropertyFlags, 13),
        // property 'activeBuff'
        QtMocHelpers::PropertyData<int>(70, QMetaType::Int, QMC::DefaultPropertyFlags, 2),
        // property 'achievements'
        QtMocHelpers::PropertyData<QVariantList>(71, 0x80000000 | 59, QMC::DefaultPropertyFlags | QMC::EnumOrFlag, 14),
        // property 'medalLibrary'
        QtMocHelpers::PropertyData<QVariantList>(72, 0x80000000 | 59, QMC::DefaultPropertyFlags | QMC::EnumOrFlag | QMC::Constant),
        // property 'coverage'
        QtMocHelpers::PropertyData<float>(73, QMetaType::Float, QMC::DefaultPropertyFlags, 3),
        // property 'volume'
        QtMocHelpers::PropertyData<float>(74, QMetaType::Float, QMC::DefaultPropertyFlags | QMC::Writable | QMC::StdCppSet, 16),
        // property 'reflectionOffset'
        QtMocHelpers::PropertyData<QPointF>(75, 0x80000000 | 76, QMC::DefaultPropertyFlags | QMC::EnumOrFlag, 17),
    };
    QtMocHelpers::UintData qt_enums {
        // enum 'State'
        QtMocHelpers::EnumData<enum State>(55, 55, QMC::EnumFlags{}).add({
            {   77, State::Splash },
            {   78, State::StartMenu },
            {   79, State::Playing },
            {   80, State::Paused },
            {   81, State::GameOver },
            {   82, State::Replaying },
        }),
        // enum 'PowerUp'
        QtMocHelpers::EnumData<enum PowerUp>(83, 83, QMC::EnumFlags{}).add({
            {   84, PowerUp::None },
            {   85, PowerUp::Ghost },
            {   86, PowerUp::Slow },
            {   87, PowerUp::Magnet },
        }),
    };
    return QtMocHelpers::metaObjectData<GameLogic, qt_meta_tag_ZN9GameLogicE_t>(QMC::MetaObjectFlag{}, qt_stringData,
            qt_methods, qt_properties, qt_enums);
}
Q_CONSTINIT const QMetaObject GameLogic::staticMetaObject = { {
    QMetaObject::SuperData::link<QObject::staticMetaObject>(),
    qt_staticMetaObjectStaticContent<qt_meta_tag_ZN9GameLogicE_t>.stringdata,
    qt_staticMetaObjectStaticContent<qt_meta_tag_ZN9GameLogicE_t>.data,
    qt_static_metacall,
    nullptr,
    qt_staticMetaObjectRelocatingContent<qt_meta_tag_ZN9GameLogicE_t>.metaTypes,
    nullptr
} };

void GameLogic::qt_static_metacall(QObject *_o, QMetaObject::Call _c, int _id, void **_a)
{
    auto *_t = static_cast<GameLogic *>(_o);
    if (_c == QMetaObject::InvokeMetaMethod) {
        switch (_id) {
        case 0: _t->foodChanged(); break;
        case 1: _t->powerUpChanged(); break;
        case 2: _t->buffChanged(); break;
        case 3: _t->scoreChanged(); break;
        case 4: _t->highScoreChanged(); break;
        case 5: _t->stateChanged(); break;
        case 6: _t->requestFeedback((*reinterpret_cast<std::add_pointer_t<int>>(_a[1]))); break;
        case 7: _t->paletteChanged(); break;
        case 8: _t->obstaclesChanged(); break;
        case 9: _t->shellColorChanged(); break;
        case 10: _t->hasSaveChanged(); break;
        case 11: _t->levelChanged(); break;
        case 12: _t->ghostChanged(); break;
        case 13: _t->musicEnabledChanged(); break;
        case 14: _t->achievementsChanged(); break;
        case 15: _t->achievementEarned((*reinterpret_cast<std::add_pointer_t<QString>>(_a[1]))); break;
        case 16: _t->volumeChanged(); break;
        case 17: _t->reflectionOffsetChanged(); break;
        case 18: _t->foodEaten((*reinterpret_cast<std::add_pointer_t<float>>(_a[1]))); break;
        case 19: _t->powerUpEaten(); break;
        case 20: _t->playerCrashed(); break;
        case 21: _t->uiInteractTriggered(); break;
        case 22: _t->update(); break;
        case 23: _t->deactivateBuff(); break;
        case 24: _t->move((*reinterpret_cast<std::add_pointer_t<int>>(_a[1])),(*reinterpret_cast<std::add_pointer_t<int>>(_a[2]))); break;
        case 25: _t->startGame(); break;
        case 26: _t->startReplay(); break;
        case 27: _t->restart(); break;
        case 28: _t->togglePause(); break;
        case 29: _t->nextPalette(); break;
        case 30: _t->nextShellColor(); break;
        case 31: _t->loadLastSession(); break;
        case 32: _t->nextLevel(); break;
        case 33: _t->quitToMenu(); break;
        case 34: _t->toggleMusic(); break;
        case 35: _t->quit(); break;
        case 36: _t->handleSelect(); break;
        case 37: _t->handleStart(); break;
        case 38: _t->deleteSave(); break;
        default: ;
        }
    }
    if (_c == QMetaObject::IndexOfMethod) {
        if (QtMocHelpers::indexOfMethod<void (GameLogic::*)()>(_a, &GameLogic::foodChanged, 0))
            return;
        if (QtMocHelpers::indexOfMethod<void (GameLogic::*)()>(_a, &GameLogic::powerUpChanged, 1))
            return;
        if (QtMocHelpers::indexOfMethod<void (GameLogic::*)()>(_a, &GameLogic::buffChanged, 2))
            return;
        if (QtMocHelpers::indexOfMethod<void (GameLogic::*)()>(_a, &GameLogic::scoreChanged, 3))
            return;
        if (QtMocHelpers::indexOfMethod<void (GameLogic::*)()>(_a, &GameLogic::highScoreChanged, 4))
            return;
        if (QtMocHelpers::indexOfMethod<void (GameLogic::*)()>(_a, &GameLogic::stateChanged, 5))
            return;
        if (QtMocHelpers::indexOfMethod<void (GameLogic::*)(int )>(_a, &GameLogic::requestFeedback, 6))
            return;
        if (QtMocHelpers::indexOfMethod<void (GameLogic::*)()>(_a, &GameLogic::paletteChanged, 7))
            return;
        if (QtMocHelpers::indexOfMethod<void (GameLogic::*)()>(_a, &GameLogic::obstaclesChanged, 8))
            return;
        if (QtMocHelpers::indexOfMethod<void (GameLogic::*)()>(_a, &GameLogic::shellColorChanged, 9))
            return;
        if (QtMocHelpers::indexOfMethod<void (GameLogic::*)()>(_a, &GameLogic::hasSaveChanged, 10))
            return;
        if (QtMocHelpers::indexOfMethod<void (GameLogic::*)()>(_a, &GameLogic::levelChanged, 11))
            return;
        if (QtMocHelpers::indexOfMethod<void (GameLogic::*)()>(_a, &GameLogic::ghostChanged, 12))
            return;
        if (QtMocHelpers::indexOfMethod<void (GameLogic::*)()>(_a, &GameLogic::musicEnabledChanged, 13))
            return;
        if (QtMocHelpers::indexOfMethod<void (GameLogic::*)()>(_a, &GameLogic::achievementsChanged, 14))
            return;
        if (QtMocHelpers::indexOfMethod<void (GameLogic::*)(QString )>(_a, &GameLogic::achievementEarned, 15))
            return;
        if (QtMocHelpers::indexOfMethod<void (GameLogic::*)()>(_a, &GameLogic::volumeChanged, 16))
            return;
        if (QtMocHelpers::indexOfMethod<void (GameLogic::*)()>(_a, &GameLogic::reflectionOffsetChanged, 17))
            return;
        if (QtMocHelpers::indexOfMethod<void (GameLogic::*)(float )>(_a, &GameLogic::foodEaten, 18))
            return;
        if (QtMocHelpers::indexOfMethod<void (GameLogic::*)()>(_a, &GameLogic::powerUpEaten, 19))
            return;
        if (QtMocHelpers::indexOfMethod<void (GameLogic::*)()>(_a, &GameLogic::playerCrashed, 20))
            return;
        if (QtMocHelpers::indexOfMethod<void (GameLogic::*)()>(_a, &GameLogic::uiInteractTriggered, 21))
            return;
    }
    if (_c == QMetaObject::RegisterPropertyMetaType) {
        switch (_id) {
        default: *reinterpret_cast<int*>(_a[0]) = -1; break;
        case 0:
            *reinterpret_cast<int*>(_a[0]) = qRegisterMetaType< SnakeModel* >(); break;
        }
    }
    if (_c == QMetaObject::ReadProperty) {
        void *_v = _a[0];
        switch (_id) {
        case 0: *reinterpret_cast<SnakeModel**>(_v) = _t->snakeModel(); break;
        case 1: *reinterpret_cast<QPoint*>(_v) = _t->food(); break;
        case 2: *reinterpret_cast<QPoint*>(_v) = _t->powerUpPos(); break;
        case 3: *reinterpret_cast<int*>(_v) = _t->powerUpType(); break;
        case 4: *reinterpret_cast<int*>(_v) = _t->score(); break;
        case 5: *reinterpret_cast<int*>(_v) = _t->highScore(); break;
        case 6: *reinterpret_cast<enum State*>(_v) = _t->state(); break;
        case 7: *reinterpret_cast<int*>(_v) = _t->boardWidth(); break;
        case 8: *reinterpret_cast<int*>(_v) = _t->boardHeight(); break;
        case 9: *reinterpret_cast<QVariantList*>(_v) = _t->palette(); break;
        case 10: *reinterpret_cast<QString*>(_v) = _t->paletteName(); break;
        case 11: *reinterpret_cast<QVariantList*>(_v) = _t->obstacles(); break;
        case 12: *reinterpret_cast<QColor*>(_v) = _t->shellColor(); break;
        case 13: *reinterpret_cast<bool*>(_v) = _t->hasSave(); break;
        case 14: *reinterpret_cast<bool*>(_v) = _t->hasReplay(); break;
        case 15: *reinterpret_cast<int*>(_v) = _t->level(); break;
        case 16: *reinterpret_cast<QString*>(_v) = _t->currentLevelName(); break;
        case 17: *reinterpret_cast<QVariantList*>(_v) = _t->ghost(); break;
        case 18: *reinterpret_cast<bool*>(_v) = _t->musicEnabled(); break;
        case 19: *reinterpret_cast<int*>(_v) = _t->activeBuff(); break;
        case 20: *reinterpret_cast<QVariantList*>(_v) = _t->achievements(); break;
        case 21: *reinterpret_cast<QVariantList*>(_v) = _t->medalLibrary(); break;
        case 22: *reinterpret_cast<float*>(_v) = _t->coverage(); break;
        case 23: *reinterpret_cast<float*>(_v) = _t->volume(); break;
        case 24: *reinterpret_cast<QPointF*>(_v) = _t->reflectionOffset(); break;
        default: break;
        }
    }
    if (_c == QMetaObject::WriteProperty) {
        void *_v = _a[0];
        switch (_id) {
        case 23: _t->setVolume(*reinterpret_cast<float*>(_v)); break;
        default: break;
        }
    }
}

const QMetaObject *GameLogic::metaObject() const
{
    return QObject::d_ptr->metaObject ? QObject::d_ptr->dynamicMetaObject() : &staticMetaObject;
}

void *GameLogic::qt_metacast(const char *_clname)
{
    if (!_clname) return nullptr;
    if (!strcmp(_clname, qt_staticMetaObjectStaticContent<qt_meta_tag_ZN9GameLogicE_t>.strings))
        return static_cast<void*>(this);
    return QObject::qt_metacast(_clname);
}

int GameLogic::qt_metacall(QMetaObject::Call _c, int _id, void **_a)
{
    _id = QObject::qt_metacall(_c, _id, _a);
    if (_id < 0)
        return _id;
    if (_c == QMetaObject::InvokeMetaMethod) {
        if (_id < 39)
            qt_static_metacall(this, _c, _id, _a);
        _id -= 39;
    }
    if (_c == QMetaObject::RegisterMethodArgumentMetaType) {
        if (_id < 39)
            *reinterpret_cast<QMetaType *>(_a[0]) = QMetaType();
        _id -= 39;
    }
    if (_c == QMetaObject::ReadProperty || _c == QMetaObject::WriteProperty
            || _c == QMetaObject::ResetProperty || _c == QMetaObject::BindableProperty
            || _c == QMetaObject::RegisterPropertyMetaType) {
        qt_static_metacall(this, _c, _id, _a);
        _id -= 25;
    }
    return _id;
}

// SIGNAL 0
void GameLogic::foodChanged()
{
    QMetaObject::activate(this, &staticMetaObject, 0, nullptr);
}

// SIGNAL 1
void GameLogic::powerUpChanged()
{
    QMetaObject::activate(this, &staticMetaObject, 1, nullptr);
}

// SIGNAL 2
void GameLogic::buffChanged()
{
    QMetaObject::activate(this, &staticMetaObject, 2, nullptr);
}

// SIGNAL 3
void GameLogic::scoreChanged()
{
    QMetaObject::activate(this, &staticMetaObject, 3, nullptr);
}

// SIGNAL 4
void GameLogic::highScoreChanged()
{
    QMetaObject::activate(this, &staticMetaObject, 4, nullptr);
}

// SIGNAL 5
void GameLogic::stateChanged()
{
    QMetaObject::activate(this, &staticMetaObject, 5, nullptr);
}

// SIGNAL 6
void GameLogic::requestFeedback(int _t1)
{
    QMetaObject::activate<void>(this, &staticMetaObject, 6, nullptr, _t1);
}

// SIGNAL 7
void GameLogic::paletteChanged()
{
    QMetaObject::activate(this, &staticMetaObject, 7, nullptr);
}

// SIGNAL 8
void GameLogic::obstaclesChanged()
{
    QMetaObject::activate(this, &staticMetaObject, 8, nullptr);
}

// SIGNAL 9
void GameLogic::shellColorChanged()
{
    QMetaObject::activate(this, &staticMetaObject, 9, nullptr);
}

// SIGNAL 10
void GameLogic::hasSaveChanged()
{
    QMetaObject::activate(this, &staticMetaObject, 10, nullptr);
}

// SIGNAL 11
void GameLogic::levelChanged()
{
    QMetaObject::activate(this, &staticMetaObject, 11, nullptr);
}

// SIGNAL 12
void GameLogic::ghostChanged()
{
    QMetaObject::activate(this, &staticMetaObject, 12, nullptr);
}

// SIGNAL 13
void GameLogic::musicEnabledChanged()
{
    QMetaObject::activate(this, &staticMetaObject, 13, nullptr);
}

// SIGNAL 14
void GameLogic::achievementsChanged()
{
    QMetaObject::activate(this, &staticMetaObject, 14, nullptr);
}

// SIGNAL 15
void GameLogic::achievementEarned(QString _t1)
{
    QMetaObject::activate<void>(this, &staticMetaObject, 15, nullptr, _t1);
}

// SIGNAL 16
void GameLogic::volumeChanged()
{
    QMetaObject::activate(this, &staticMetaObject, 16, nullptr);
}

// SIGNAL 17
void GameLogic::reflectionOffsetChanged()
{
    QMetaObject::activate(this, &staticMetaObject, 17, nullptr);
}

// SIGNAL 18
void GameLogic::foodEaten(float _t1)
{
    QMetaObject::activate<void>(this, &staticMetaObject, 18, nullptr, _t1);
}

// SIGNAL 19
void GameLogic::powerUpEaten()
{
    QMetaObject::activate(this, &staticMetaObject, 19, nullptr);
}

// SIGNAL 20
void GameLogic::playerCrashed()
{
    QMetaObject::activate(this, &staticMetaObject, 20, nullptr);
}

// SIGNAL 21
void GameLogic::uiInteractTriggered()
{
    QMetaObject::activate(this, &staticMetaObject, 21, nullptr);
}
QT_WARNING_POP
