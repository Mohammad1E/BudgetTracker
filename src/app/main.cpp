#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QQuickWindow>
#include <QQuickStyle>
#include <QStandardPaths>
#include <QDir>

#include "data/Database.h"
#include "viewmodels/AppController.h"
#include "viewmodels/LanguageManager.h"

using namespace bt;

// Where the SQLite file lives (per-user app data on every platform).
static QString defaultDbPath()
{
    const QString dir = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation);
    QDir().mkpath(dir);
    return dir + "/budget.sqlite";
}

int main(int argc, char* argv[])
{
    QGuiApplication app(argc, argv);
    QGuiApplication::setApplicationName("BudgetTracker");
    QGuiApplication::setOrganizationName("BudgetTracker");
    QGuiApplication::setApplicationDisplayName("Budget Tracker");

    // Desktop -> clean neutral "Basic" style; mobile -> Material.
#if defined(Q_OS_ANDROID) || defined(Q_OS_IOS)
    QQuickStyle::setStyle("Material");
#else
    QQuickStyle::setStyle("Basic");
    QQuickWindow::setTextRenderType(QQuickWindow::NativeTextRendering);
#endif

    // Open (and migrate/seed) the database before the UI loads.
    Database db;
    if (!db.open(defaultDbPath())) {
        qCritical("Failed to open database. Exiting.");
        return 1;
    }

    AppController controller(&db);
    LanguageManager languageManager;

    QQmlApplicationEngine engine;
    engine.rootContext()->setContextProperty("App", &controller);
    engine.rootContext()->setContextProperty("I18n", &languageManager);

    // Loads Main.qml from the BudgetTrackerUi module. CMake compiles the
    // desktop OR mobile Main.qml depending on the target platform.
    engine.loadFromModule("BudgetTrackerUi", "Main");
    if (engine.rootObjects().isEmpty())
        return 1;

    return app.exec();
}
