# BudgetTracker

تطبيق تتبّع راتب ومصروفات شخصي — مبني بـ **C++20 + Qt 6 (Qt Quick/QML) + SQLite + CMake**.
الأولوية لسطح المكتب (Windows EXE)، مع تصميم جاهز لإضافة Android (APK/AAB) لاحقًا دون إعادة كتابة المنطق.

> الوثيقة الكاملة للتصميم والمعمارية و الـ roadmap موجودة في **[docs/DESIGN.md](docs/DESIGN.md)**.

## المتطلبات

- **Qt 6.8 LTS** (مستحسن) — `Core, Gui, Qml, Quick, QuickControls2, Sql`
- **CMake ≥ 3.21.1**
- مترجم C++20: MSVC 2022 (مستحسن على Windows) أو MinGW
- (لاحقًا للأندرويد) Android SDK + NDK r26b/r27c + JDK 17

## البناء على Windows (سطر الأوامر)

```bat
:: من جذر المشروع. عدّل مسار Qt حسب جهازك.
cmake -S . -B build -G "Ninja" -DCMAKE_PREFIX_PATH="C:/Qt/6.8.2/msvc2022_64"
cmake --build build --config Release
:: الناتج: build/src/app/BudgetTracker.exe
```

أو افتح `CMakeLists.txt` مباشرة من **Qt Creator** واضغط Run.

## نشر EXE مستقل (بعد البناء)

```bat
windeployqt --qmldir src/app/qml build/src/app/BudgetTracker.exe
```

## هيكل المشروع (مختصر)

```
src/core/   ← منطق مشترك (DB + repositories + services) — لا يعتمد على QML
src/app/    ← view-models (C++) + واجهة QML + main.cpp
tests/      ← اختبارات وحدة للـ core
docs/       ← DESIGN.md
```

## بناء الاختبارات

```bat
cmake -S . -B build -DBT_BUILD_TESTS=ON -DCMAKE_PREFIX_PATH="C:/Qt/6.8.2/msvc2022_64"
cmake --build build
ctest --test-dir build
```
