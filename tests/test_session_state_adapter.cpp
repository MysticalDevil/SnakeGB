#include "adapter/session_state.h"

#include <QtTest/QtTest>

using namespace Qt::StringLiterals;

class TestSessionStateAdapter : public QObject {
    Q_OBJECT

private slots:
    void testDecodeSessionSnapshotFromVariantMap();
    void testDecodeSessionSnapshotRejectsEmptyBody();
};

void TestSessionStateAdapter::testDecodeSessionSnapshotFromVariantMap() {
    QVariantMap data;
    data.insert(u"score"_s, 12);
    data.insert(u"food"_s, QPoint(3, 4));
    data.insert(u"dir"_s, QPoint(0, -1));
    data.insert(u"obstacles"_s, QVariantList{QPoint(1, 1), QPoint(2, 2)});
    data.insert(u"body"_s, QVariantList{QPoint(5, 5), QPoint(5, 6)});

    const auto snapshot = snakegb::adapter::decodeSessionSnapshot(data);
    QVERIFY(snapshot.has_value());
    QCOMPARE(snapshot->score, 12);
    QCOMPARE(snapshot->food, QPoint(3, 4));
    QCOMPARE(snapshot->direction, QPoint(0, -1));
    QCOMPARE(snapshot->obstacles.size(), 2);
    QCOMPARE(snapshot->body.size(), 2);
}

void TestSessionStateAdapter::testDecodeSessionSnapshotRejectsEmptyBody() {
    QVariantMap data;
    data.insert(u"score"_s, 1);
    data.insert(u"food"_s, QPoint(0, 0));
    data.insert(u"dir"_s, QPoint(1, 0));
    data.insert(u"body"_s, QVariantList{});

    const auto snapshot = snakegb::adapter::decodeSessionSnapshot(data);
    QVERIFY(!snapshot.has_value());
}

QTEST_MAIN(TestSessionStateAdapter)
#include "test_session_state_adapter.moc"
