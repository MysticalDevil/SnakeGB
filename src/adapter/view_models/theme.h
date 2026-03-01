#pragma once

#include <QColor>
#include <QObject>
#include <QString>
#include <QVariantList>

class EngineAdapter;

class ThemeViewModel final : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QVariantList palette READ palette NOTIFY paletteChanged)
    Q_PROPERTY(QString paletteName READ paletteName NOTIFY paletteChanged)
    Q_PROPERTY(QColor shellColor READ shellColor NOTIFY shellChanged)
    Q_PROPERTY(QString shellName READ shellName NOTIFY shellChanged)

public:
    explicit ThemeViewModel(EngineAdapter *engineAdapter, QObject *parent = nullptr);

    [[nodiscard]] auto palette() const -> QVariantList;
    [[nodiscard]] auto paletteName() const -> QString;
    [[nodiscard]] auto shellColor() const -> QColor;
    [[nodiscard]] auto shellName() const -> QString;

signals:
    void paletteChanged();
    void shellChanged();

private:
    EngineAdapter *m_engineAdapter = nullptr;
};
