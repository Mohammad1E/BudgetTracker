# BudgetTracker — وثيقة التصميم الكاملة

> تطبيق تتبّع راتب ومصروفات شخصي.
> **C++20 + Qt 6 (Qt Quick/QML) + SQLite + CMake**.
> **Desktop-first**: الأولوية لويندوز (EXE)، ثم Android (APK/AAB) دون إعادة كتابة المنطق.

هذه الوثيقة تغطّي كل ما طلبته نقطة بنقطة، بالإضافة إلى **التعديل المهم** (Desktop-first + Core مشترك + UI منفصلة)، وقسم **نصائح وبدائل أفضل** في النهاية.

---

## ملاحظات تقنية محدّثة (مهمة قبل البدء)

| الموضوع | القرار / الحقيقة | لماذا |
|---|---|---|
| إصدار Qt | **Qt 6.8 LTS** (مدعوم حتى أكتوبر 2029) | LTS = استقرار لمشروع طويل. تجنّب أحدث إصدار (6.11/6.12) لأنه غير LTS. |
| الترخيص | استخدم Qt **Open Source (LGPLv3)** مع **ربط ديناميكي (dynamic linking)** | الربط الديناميكي = لا تُجبر على نشر شيفرتك المصدرية. الربط الساكن (static) تحت LGPL يفرض التزامات (نشر object files أو فتح المصدر). |
| الرسوم البيانية | **لا تستخدم QtCharts** في البداية — ارسم المخططات يدويًا بـ QML | QtCharts/Qt Graphs مرخّصة **GPLv3** أو تجاري، وهذا يفرض GPL على تطبيقك كله. الرسم اليدوي بـ `Rectangle`/`Canvas`/`Shapes` يبقى تحت LGPL. |
| الحد الأدنى لأندرويد | API 28 (Android 9) لـ Qt 6.8 | هذا أدنى مستوى يدعمه Qt 6.8. الهواتف الأقدم من Android 9 غير مدعومة بـ Qt 6.8 (راجع قسم Android). |
| تعدّد المعماريات | مدعوم للتطبيقات منذ Qt 6.3 عبر `QT_ANDROID_ABIS` / `QT_ANDROID_BUILD_ALL_ABIS` | يتيح بناء APK/AAB واحد يدعم `armeabi-v7a` و `arm64-v8a` معًا. |
| المال | يُخزَّن دائمًا كـ **أعداد صحيحة (minor units / قروش)** | تجنّب أخطاء الفاصلة العائمة (`float`). 12.50 د.أ = 1250. |

(المصادر في آخر الوثيقة.)

---

## 1) فكرة التطبيق الكاملة

تطبيق شخصي لإدارة المال الشهري:

- تُسجّل **راتبك** (دخل) و**مصروفاتك** أولًا بأول.
- كل عملية لها: نوع (دخل/مصروف)، مبلغ، تاريخ، **تصنيف** (طعام، مواصلات...)، و**شخص** اختياري (لمن دفعت/منه استلمت)، وملاحظة.
- التطبيق يحسب تلقائيًا: **المتبقي من الراتب**، إجمالي الدخل، إجمالي المصروف لكل شهر.
- يعرض **تقارير**: شهرية، يومية، وحسب التصنيف.
- يعمل **بالكامل أوفلاين** (SQLite محلي). لا حاجة لإنترنت ولا حساب.
- **مزامنة/نسخ احتياطي** عبر تصدير/استيراد JSON (وخيار LAN لاحقًا)، ثم Backend REST لاحقًا.
- واجهتان: **سطح مكتب** (Sidebar + جداول واسعة) و**هاتف** (تبويب سفلي + بطاقات + إضافة سريعة) — تشتركان في نفس المنطق.

**جمهور المستخدم:** فرد يريد ضبط مصروفه الشهري ببساطة وسرعة وخصوصية تامة.

---

## 2) ميزات الـ MVP الأساسية (سطح المكتب أولًا)

هذه هي النسخة الأولى القابلة للاستخدام:

1. **إضافة/تعديل/حذف عملية** (دخل أو مصروف) بالمبلغ والتاريخ والتصنيف والشخص والملاحظة.
2. **تصنيفات** افتراضية + إضافة تصنيف جديد (باسم ولون ونوع).
3. **أشخاص**: إضافة شخص وربطه بالعمليات.
4. **لوحة معلومات (Dashboard)**: بطاقات الدخل/المصروف/المتبقي للشهر الحالي + أحدث العمليات.
5. **جدول عمليات** كبير مع فلتر بالشهر والنوع.
6. **التنقّل بين الشهور** (السابق/التالي).
7. **حساب المتبقي** = الدخل − المصروف (للشهر).
8. **تقرير المصروفات حسب التصنيف** (أشرطة بسيطة).
9. **تصدير/استيراد JSON** (نسخ احتياطي).
10. **تخزين محلي دائم** في SQLite + هجرات schema.

> كل هذه الميزات **منفّذة فعليًا** في الـ scaffold المرفق (باستثناء تعديل عملية، وهو مهيّأ كنقطة توسعة واضحة).

---

## 3) الميزات المتقدمة لاحقًا

- تعديل العملية من نفس نافذة الإضافة (وضع Edit).
- **ميزانيات/حدود لكل تصنيف** شهريًا (جدول `budgets` جاهز) + تنبيه عند تجاوز الحد.
- **راتب مخطّط** للشهر ومقارنة الفعلي بالمخطّط (جدول `monthly_income_plan` جاهز).
- **عملات متعددة** وحسابات/محافظ متعددة (جدول `accounts` جاهز).
- **عمليات متكررة** (اشتراكات، إيجار) تُولَّد تلقائيًا.
- **بحث** متقدم وفلاتر مركّبة (تاريخ من/إلى، شخص، نص).
- **مرفقات** (صورة فاتورة) لكل عملية.
- **تقارير متقدمة**: اتجاه يومي، مقارنة شهور، تصدير PDF.
- **مزامنة LAN** بين الكمبيوتر والهاتف، ثم **Backend REST**.
- **واجهة الهاتف** كاملة (موجودة كـ stub).
- **القفل** (PIN/بصمة) و**الوضع الليلي**.
- **تعدد اللغات** (عربي/إنجليزي) عبر `qsTr` (مهيّأ مسبقًا في QML).

---

## 4) المعمارية (Architecture) — Desktop-first + Core مشترك + UI منفصلة

المبدأ: **طبقات نظيفة، الاعتماد يتجه للأسفل فقط**. الواجهة تعتمد على المنطق، والمنطق لا يعرف شيئًا عن الواجهة.

```
┌──────────────────────────────────────────────────────────────┐
│  UI Layer  (QML)            ← منفصلة لكل منصة                  │
│  ┌────────────────┐   ┌────────────────┐   ┌───────────────┐  │
│  │ qml/desktop/   │   │ qml/mobile/    │   │ qml/shared/   │  │
│  │ Sidebar+جداول  │   │ تبويب+بطاقات   │   │ Theme+مكوّنات │  │
│  └───────┬────────┘   └───────┬────────┘   └──────┬────────┘  │
│          └───────────────┬────┴───────────────────┘           │
│                          ▼  (تربط عبر context property "App") │
│  ViewModel Layer (C++/QObject)  ← مشترك بين المنصّتين          │
│  AppController · TransactionListModel · DashboardViewModel ·   │
│  CategoryListModel · PersonListModel                          │
└──────────────────────────┬───────────────────────────────────┘
                           ▼
┌──────────────────────────────────────────────────────────────┐
│  CORE (مكتبة bt_core الساكنة)  ← مشترك 100% (لا QML هنا)       │
│  ┌─────────────┐  ┌──────────────────────┐  ┌──────────────┐  │
│  │ Services    │  │ Data / Repositories  │  │ Domain       │  │
│  │ BudgetSvc   │→ │ TransactionRepo ...  │→ │ Transaction  │  │
│  │ ImportExport│  │ Database (SQLite)    │  │ Category ...  │  │
│  └─────────────┘  └──────────┬───────────┘  └──────────────┘  │
└────────────────────────────────┬─────────────────────────────┘
                                 ▼
                          SQLite (Qt6::Sql)
```

**الفكرة العملية:**

- **`bt_core`** مكتبة C++ ساكنة تعتمد فقط على `Qt6::Core` و`Qt6::Sql`. تُترجَم **بنفس الشيفرة** على Windows و Android. هنا كل المنطق: قاعدة البيانات، الـ repositories، الحسابات، JSON.
- **ViewModels** (طبقة C++ ترث `QObject`) تغلّف الـ core وتعرضه لـ QML عبر `Q_PROPERTY` و`Q_INVOKABLE`. **مشتركة أيضًا** بين المنصّتين.
- **QML** هي الطبقة الوحيدة المنفصلة: `desktop/` و`mobile/` و`shared/`. الفصل يتم وقت البناء (CMake يختار مجموعة QML حسب المنصة)، فلا يوجد `#ifdef` فوضوي.

**كيف يتم اختيار الواجهة؟**
في `CMakeLists.txt` الخاص بالتطبيق: إذا `ANDROID` → نُضيف ملفات `qml/mobile/*`، وإلا → `qml/desktop/*`. ثم `main.cpp` يحمّل النوع `Main` من الموديول نفسه:
```cpp
engine.loadFromModule("BudgetTrackerUi", "Main");
```
وهكذا نفس `main.cpp` يعمل على المنصّتين، والاختلاف فقط في أي `Main.qml` تم تجميعه.

> **لماذا هذا نظيف لكن غير معقّد؟** لا Dependency Injection framework، لا إشارات معقدة عبر الطبقات. مجرد: `Database` → `Repositories` → `Services` → `ViewModels` → `QML`. سهل الفهم، سهل الاختبار، سهل إضافة Android.

---

## 5) هيكل المجلدات (Folder Structure)

```
BudgetTracker/
├─ CMakeLists.txt                  # الجذر: يجد Qt، يضيف core و app
├─ README.md
├─ .gitignore
│
├─ src/
│  ├─ core/                        # ★ مشترك 100% — لا يعتمد على QML
│  │  ├─ CMakeLists.txt            #   add_library(bt_core STATIC ...)
│  │  ├─ domain/                   #   structs خالصة (بيانات فقط)
│  │  │  ├─ Types.h                #     enum TxType, alias Money
│  │  │  ├─ Transaction.h
│  │  │  ├─ Category.h
│  │  │  ├─ Person.h
│  │  │  ├─ Account.h
│  │  │  └─ Budget.h
│  │  ├─ data/                     #   الوصول لقاعدة البيانات
│  │  │  ├─ Database.{h,cpp}       #     الاتصال + الهجرات + seed
│  │  │  ├─ TransactionRepository.{h,cpp}
│  │  │  ├─ CategoryRepository.{h,cpp}
│  │  │  └─ PersonRepository.{h,cpp}
│  │  └─ services/                 #   منطق الأعمال (قابل للاختبار)
│  │     ├─ BudgetService.{h,cpp}       # الحسابات والتقارير
│  │     └─ ImportExportService.{h,cpp} # JSON
│  │
│  └─ app/                         # ★ تطبيق Qt Quick (ViewModels + QML + main)
│     ├─ CMakeLists.txt            #   qt_add_executable + qt_add_qml_module
│     ├─ main.cpp                  #   يفتح DB ويحمّل Main.qml
│     ├─ viewmodels/               #   جسر C++ ↔ QML (مشترك)
│     │  ├─ AppController.{h,cpp}
│     │  ├─ TransactionListModel.{h,cpp}   # QAbstractListModel
│     │  ├─ DashboardViewModel.{h,cpp}
│     │  ├─ CategoryListModel.{h,cpp}
│     │  └─ PersonListModel.{h,cpp}
│     └─ qml/
│        ├─ shared/                #   مشترك بين المنصّتين
│        │  ├─ Theme.qml           #     singleton ألوان/مسافات
│        │  ├─ Card.qml
│        │  ├─ KpiCard.qml
│        │  ├─ MoneyText.qml
│        │  └─ TransactionDialog.qml
│        ├─ desktop/               #   واجهة الكمبيوتر (Sidebar + جداول)
│        │  ├─ Main.qml
│        │  ├─ Sidebar.qml
│        │  ├─ DashboardPage.qml
│        │  ├─ TransactionsPage.qml
│        │  ├─ ReportsPage.qml
│        │  ├─ PeoplePage.qml
│        │  ├─ CategoriesPage.qml
│        │  └─ SettingsPage.qml
│        └─ mobile/                #   واجهة الهاتف (تبويب + بطاقات) — لاحقًا
│           ├─ Main.qml
│           ├─ HomePage.qml
│           ├─ QuickAddPage.qml
│           ├─ TransactionsPage.qml
│           └─ SettingsPage.qml
│
├─ tests/                          # اختبارات وحدة للـ core (Qt Test)
│  ├─ CMakeLists.txt
│  └─ tst_budgetservice.cpp
│
└─ docs/
   └─ DESIGN.md                    # هذه الوثيقة
```

---

## 6) Database Schema (SQLite)

> منفّذة في `src/core/data/Database.cpp` داخل دالة `migrate()`، مع ترقيم إصدار عبر `PRAGMA user_version` لتسهيل الترقية لاحقًا.

```sql
PRAGMA foreign_keys = ON;
PRAGMA journal_mode = WAL;

CREATE TABLE categories (
  id          INTEGER PRIMARY KEY AUTOINCREMENT,
  name        TEXT    NOT NULL,
  type        INTEGER NOT NULL,                 -- 0 = expense, 1 = income
  color       TEXT    NOT NULL DEFAULT '#3B82F6',
  icon        TEXT,
  parent_id   INTEGER REFERENCES categories(id) ON DELETE SET NULL,
  is_archived INTEGER NOT NULL DEFAULT 0,
  created_at  TEXT    NOT NULL DEFAULT (datetime('now'))
);

CREATE TABLE people (
  id          INTEGER PRIMARY KEY AUTOINCREMENT,
  name        TEXT    NOT NULL,
  phone       TEXT,
  note        TEXT,
  is_archived INTEGER NOT NULL DEFAULT 0,
  created_at  TEXT    NOT NULL DEFAULT (datetime('now'))
);

CREATE TABLE accounts (
  id              INTEGER PRIMARY KEY AUTOINCREMENT,
  name            TEXT    NOT NULL,
  opening_balance INTEGER NOT NULL DEFAULT 0,    -- minor units
  currency        TEXT    NOT NULL DEFAULT 'JOD',
  is_archived     INTEGER NOT NULL DEFAULT 0,
  created_at      TEXT    NOT NULL DEFAULT (datetime('now'))
);

CREATE TABLE transactions (
  id          INTEGER PRIMARY KEY AUTOINCREMENT,
  type        INTEGER NOT NULL,                  -- 0 = expense, 1 = income
  amount      INTEGER NOT NULL,                  -- minor units, دائمًا موجب
  currency    TEXT    NOT NULL DEFAULT 'JOD',
  occurred_on TEXT    NOT NULL,                  -- 'YYYY-MM-DD'
  category_id INTEGER REFERENCES categories(id) ON DELETE SET NULL,
  person_id   INTEGER REFERENCES people(id)     ON DELETE SET NULL,
  account_id  INTEGER REFERENCES accounts(id)   ON DELETE SET NULL,
  note        TEXT,
  created_at  TEXT    NOT NULL DEFAULT (datetime('now')),
  updated_at  TEXT    NOT NULL DEFAULT (datetime('now'))
);
CREATE INDEX idx_tx_occurred_on ON transactions(occurred_on);
CREATE INDEX idx_tx_category    ON transactions(category_id);
CREATE INDEX idx_tx_person      ON transactions(person_id);
CREATE INDEX idx_tx_type        ON transactions(type);

CREATE TABLE budgets (                            -- حدود الإنفاق الشهرية لكل تصنيف
  id             INTEGER PRIMARY KEY AUTOINCREMENT,
  month          TEXT    NOT NULL,               -- 'YYYY-MM'
  category_id    INTEGER REFERENCES categories(id) ON DELETE CASCADE,
  planned_amount INTEGER NOT NULL,
  UNIQUE(month, category_id)
);

CREATE TABLE monthly_income_plan (                -- الراتب المخطّط للشهر
  month          TEXT PRIMARY KEY,               -- 'YYYY-MM'
  planned_salary INTEGER NOT NULL DEFAULT 0
);
```

**قرارات تصميم مهمة:**

- المال `INTEGER` (minor units) لا `REAL`. تحويل العرض: `amount / 100.0`.
- النوع `type` عدد صحيح (0/1) لا نص — أسرع وأبسط.
- التاريخ نص `'YYYY-MM-DD'` — يسمح بالفرز والتجميع الشهري عبر `substr(occurred_on,1,7)`.
- `ON DELETE SET NULL` للتصنيف/الشخص: حذف تصنيف لا يحذف عملياته.
- **نصيحة للمزامنة المستقبلية:** أضِف مبكرًا عمودَي `uuid TEXT` و`is_deleted INTEGER` لكل جدول رئيسي (مهيّأ في الـ roadmap). يوفّر عليك هجرة مؤلمة عند بناء الـ REST API. (لم نضِفهما في MVP لإبقائه بسيطًا، لكن خطّتهما جاهزة.)

---

## 7) C++ Classes المطلوبة

### طبقة Domain (structs خالصة)
| النوع | الوصف |
|---|---|
| `TxType` (enum) | `Expense=0`, `Income=1` |
| `Money` (alias = qint64) | المال بالـ minor units |
| `Transaction` | عملية واحدة (+ حقول عرض مثل `categoryName`) |
| `Category`, `Person`, `Account`, `Budget` | كيانات البيانات |

### طبقة Data
| الكلاس | المسؤولية |
|---|---|
| `Database` | يملك اتصال SQLite، يطبّق `PRAGMA`، يشغّل الهجرات، يزرع تصنيفات افتراضية. |
| `TransactionRepository` | CRUD + `list(Filter)` مع JOIN للأسماء + فلترة شهر/نوع/تصنيف/شخص/بحث. |
| `CategoryRepository` | list / insert / update / archive. |
| `PersonRepository` | list / insert / update / archive. |

### طبقة Services (منطق الأعمال)
| الكلاس | المسؤولية |
|---|---|
| `BudgetService` | `monthlySummary`, `expensesByCategory`, `dailyTotals`, `plannedSalary`, `remainingVsPlan`. |
| `ImportExportService` | `exportToJson`, `importFromJson`. |

### طبقة ViewModels (QObject — جسر QML)
| الكلاس | يعرض لـ QML |
|---|---|
| `AppController` | الكائن الجذر (`App`): النماذج كـ properties + دوال `addTransaction`, `removeTransaction`, `addCategory`, `addPerson`, `exportJson`, `importJson`, `goToPreviousMonth/NextMonth`, `setTransactionTypeFilter`, `expenseByCategory`. |
| `TransactionListModel` | `QAbstractListModel` لقائمة/جدول العمليات (roles: amountText, dateText, categoryName...). |
| `DashboardViewModel` | properties: `incomeText`, `expenseText`, `remainingText`, `isNegative`, `currency`. |
| `CategoryListModel` / `PersonListModel` | `QAbstractListModel` للقوائم وعناصر الاختيار في النوافذ. |

---

## 8) QML Screens المطلوبة

### واجهة سطح المكتب (Desktop — الأولوية)
- **`Main.qml`**: `ApplicationWindow` فيه `Sidebar` (يسار) + شريط علوي (عنوان + تنقل الشهور + زر إضافة) + `StackLayout` للصفحات.
- **`Sidebar.qml`**: شريط جانبي داكن، عناصر: لوحة المعلومات، العمليات، التقارير، الأشخاص، التصنيفات، الإعدادات.
- **`DashboardPage.qml`**: 3 بطاقات KPI (دخل/مصروف/متبقي) + قائمة أحدث العمليات.
- **`TransactionsPage.qml`**: فلتر بالنوع + **جدول كبير** (رأس ثابت + صفوف) + حذف لكل صف + عدّاد.
- **`ReportsPage.qml`**: أشرطة المصروفات حسب التصنيف (مرسومة بـ QML، بلا QtCharts).
- **`PeoplePage.qml`** / **`CategoriesPage.qml`**: نموذج إضافة + قائمة.
- **`SettingsPage.qml`**: تصدير/استيراد JSON عبر `FileDialog` + معلومات.

### واجهة الهاتف (Mobile — لاحقًا، موجودة كـ stub)
- **`Main.qml`**: `ApplicationWindow` + `TabBar` سفلي + `StackLayout`.
- **`HomePage.qml`**: بطاقة "المتبقي" كبيرة + بطاقات أحدث العمليات.
- **`QuickAddPage.qml`**: حقل مبلغ كبير + زرّا (مصروف/دخل) + تصنيف + حفظ — **إضافة بضغطة واحدة**.
- **`TransactionsPage.qml`**: قائمة بطاقات.
- **`SettingsPage.qml`**: تصدير/استيراد.

### مكوّنات مشتركة (`shared/`)
`Theme.qml` (ألوان/مسافات/خطوط، singleton)، `Card.qml` (سطح بظل)، `KpiCard.qml`، `MoneyText.qml` (مبلغ ملوّن)، `TransactionDialog.qml` (نافذة الإضافة — تُستخدم في الواجهتين).

---

## 9) طريقة حساب الميزانية والمصروفات

كل الحسابات في `BudgetService` (C++ قابل للاختبار)، عبر SQL تجميعي:

**المتبقي الشهري** (المنفَّذ):
```
income(M)    = SUM(amount) WHERE type=1 AND substr(occurred_on,1,7)=M
expense(M)   = SUM(amount) WHERE type=0 AND substr(occurred_on,1,7)=M
remaining(M) = income(M) − expense(M)
```

**المتبقي مقابل الراتب المخطّط** (اختياري):
```
remainingVsPlan(M) = planned_salary(M) − expense(M)
```

**حسب التصنيف** (للتقارير): `GROUP BY category_id` على مصروفات الشهر، مرتّبة تنازليًا.

**يومي**: `GROUP BY occurred_on` مع فصل دخل/مصروف عبر `CASE WHEN`.

**حدود التصنيف** (لاحقًا): لكل `budget(category, month)` احسب `spent` ثم النسبة `spent / planned_amount` لعرض شريط تقدّم/تنبيه.

> **قاعدة ذهبية:** كل الحسابات على أعداد صحيحة (minor units). التحويل لعرض فقط: `value/100.0` بخانتين عشريتين.

---

## 10) خطة المزامنة بدون سيرفر (المرحلة الأولى)

### أ) تصدير/استيراد JSON (المنفّذ في MVP)
- `ImportExportService::exportToJson(path)` يكتب كل الجداول إلى ملف JSON مُنسّق (نسخة احتياطية كاملة).
- `importFromJson(path, replaceExisting=true)` يقرأ الملف، يمسح الجداول، ويعيد الإدخال داخل Transaction واحدة.
- في الواجهة: زرّان في `SettingsPage` يفتحان `FileDialog`.
- **حالة الاستخدام:** نسخة احتياطية، نقل بين جهازين عبر USB/سحابة، أو "مزامنة يدوية".

### ب) مزامنة LAN محلية (خطوة لاحقة، بلا سيرفر خارجي)
- على الكمبيوتر: شغّل `QHttpServer` (وحدة `Qt::HttpServer`) على منفذ محلي يعرض `GET /export` و`POST /import`.
- الهاتف يتصل عبر عنوان الـ IP المحلي (نفس شبكة Wi-Fi) ويسحب/يدفع JSON.
- اكتشاف الجهاز اختياريًا عبر mDNS/Zeroconf، أو بإدخال الـ IP يدويًا (أبسط للبداية).
- يبقى **بلا سيرفر سحابي** — كل شيء داخل شبكتك.

> **نصيحة:** لجعل المزامنة (LAN أو REST لاحقًا) خالية من التعارضات، أضِف `uuid` لكل سجل و`updated_at`. عندها يمكن دمج آخر-كتابة-تفوز (last-write-wins) بدل الاستبدال الكامل.

---

## 11) خطة Backend REST API لاحقًا (دون إعادة كتابة المنطق)

المفتاح: **اجعل الـ Repository خلف واجهة (interface)**، فيصبح المصدر قابلًا للتبديل (محلي ↔ شبكي) دون لمس بقية الكود.

```cpp
// abstraction
class ITransactionSource {
public:
    virtual ~ITransactionSource() = default;
    virtual QVector<Transaction> list(const Filter&) = 0;
    virtual qint64 insert(const Transaction&) = 0;
    // ...
};
// محلي (موجود) و شبكي (لاحقًا)
class SqliteTransactionRepository : public ITransactionSource { /* الحالي */ };
class RemoteTransactionRepository : public ITransactionSource { /* QNetworkAccessManager */ };
```

**نمط مقترح: Offline-first + مزامنة:**
1. التطبيق يكتب دائمًا في SQLite المحلي (سريع، يعمل أوفلاين).
2. طابور مزامنة (`sync_queue`) يسجّل التغييرات المعلّقة.
3. عند توفّر الشبكة، تُرسَل للـ REST API وتُسحب التحديثات.

**نقاط النهاية المقترحة (الـ Backend محايد — Python/Node/أي شيء، لا Firebase):**
```
POST   /auth/login
GET    /transactions?since=<ts>
POST   /transactions
PUT    /transactions/{uuid}
DELETE /transactions/{uuid}
GET    /categories , /people , ...
```
- المصادقة عبر JWT.
- الحقول المطلوبة للمزامنة: `uuid`, `updated_at`, `is_deleted` (soft delete).
- على جانب C++: `QNetworkAccessManager` + `QJsonDocument` (نفس بنية JSON الحالية تقريبًا).

> ملاحظة: لأنك لا تريد Firebase الآن، أبسط Backend لاحقًا = **FastAPI (Python) + PostgreSQL** أو **Node/Express**. لا يؤثر على كود التطبيق طالما التزمنا بواجهة `ITransactionSource`.

---

## 12) دعم Android قديم وحديث + ABI

**الحقائق (Qt 6.8):**
- الحد الأدنى المدعوم: **Android 9 (API 28)**. أقدم من ذلك غير مدعوم بـ Qt 6.8.
- المعماريات المدعومة: `armeabi-v7a` (ARM 32-بت، أجهزة أقدم)، `arm64-v8a` (ARM 64-بت، الأجهزة الحديثة)، `x86`, `x86_64` (محاكيات غالبًا).
- **Google Play يفرض دعم 64-بت** (`arm64-v8a`) منذ 2019، لذا هو إلزامي.

**التهيئة (موجودة في `src/app/CMakeLists.txt`):**
```cmake
if(ANDROID)
    set_target_properties(BudgetTracker PROPERTIES
        QT_ANDROID_MIN_SDK_VERSION    28
        QT_ANDROID_TARGET_SDK_VERSION 34)
endif()
```

**لبناء ABIs متعددة** (سطر الأوامر):
```bat
:: إما تحديد قائمة
cmake -S . -B build-android -DQT_ANDROID_ABIS="armeabi-v7a;arm64-v8a" ...
:: أو بناء كل المتوفّر
cmake -S . -B build-android -DQT_ANDROID_BUILD_ALL_ABIS=ON ...
```

**APK مقابل AAB:**
- للنشر على Play → **AAB** (Android App Bundle): يحوي كل الـ ABIs لكن المستخدم يُنزّل فقط ما يناسب جهازه (حجم أصغر).
- للتجربة/التثبيت المباشر → **APK**.

**الأدوات المطلوبة:** Android SDK (Platform 34 + build-tools)، **NDK r26b أو r27c** (طابِق ما تبنيه Qt الرسمية لتجنّب أخطاء الرموز)، **JDK 17**، Gradle (يأتي مع Qt/Creator).

> **ملاحظة صريحة عن "الهواتف القديمة جدًا":** Qt 6.8 لن يعمل على أقدم من Android 9. إن كان دعم أجهزة أقدم ضرورة قصوى، فالخيار النظري هو Qt 6.5 (لكنه **انتهى دعمه في أبريل 2026**) — لذا لا أنصح به. عمليًا `armeabi-v7a` + `arm64-v8a` على Android 9+ يغطّي السوق الواقعي اليوم.

---

## 13) خطة التطوير خطوة بخطوة (Roadmap)

**المرحلة 0 — الإعداد** ✅ (الـ scaffold يغطّيها)
- ثبّت Qt 6.8 LTS + Qt Creator + CMake + مترجم (MSVC 2022 على Windows).
- افتح `CMakeLists.txt` في Qt Creator، اضبط Kit، Run → يجب أن يظهر التطبيق ويبني EXE.

**المرحلة 1 — Core + DB** ✅ (منفّذة)
- `domain` + `Database` + الهجرات + seed + `TransactionRepository` + `BudgetService`.
- شغّل اختبارات `tests/` للتأكد من الحسابات.

**المرحلة 2 — Desktop MVP UI** ✅ (منفّذة)
- `AppController` + النماذج + `Dashboard` + `Transactions` (إضافة/حذف) + `Categories` + `People`.

**المرحلة 3 — تقارير وصقل**
- أكمل `ReportsPage` (يومي + مقارنة)، أضِف **تعديل** العملية، تأكيد الحذف، الوضع الليلي عبر `Theme`.

**المرحلة 4 — نسخ احتياطي** ✅ (Export/Import JSON منفّذ) → أضِف LAN sync اختياريًا.

**المرحلة 5 — تغليف Windows**
- `windeployqt` لإنتاج مجلد قابل للتوزيع، ثم مُثبّت (Inno Setup / NSIS) اختياريًا. أضِف `WIN32` للـ exe لإخفاء نافذة الـ console في الإصدار النهائي.

**المرحلة 6 — واجهة الهاتف**
- أكمل `qml/mobile/*` (موجودة كـ stub) — أعد استخدام نفس `AppController` والنماذج. لا تلمس `bt_core`.

**المرحلة 7 — بناء Android**
- ثبّت SDK/NDK/JDK، اضبط Android Kit في Creator، ابنِ APK لمحاكي ثم جهاز، فعّل multi-ABI، ثم AAB للنشر.

**المرحلة 8 — Backend (اختياري)**
- أدخِل `ITransactionSource` + `RemoteTransactionRepository` + REST API + JWT + مزامنة offline-first.

---

## 14) تعليمات لـ Codex لبناء/إكمال المشروع

> انسخ هذا المقطع وأعطه لـ Codex. المشروع **مبدئيًا موجود** (scaffold)، فمهمة Codex غالبًا **الإكمال والتوسعة** ضمن نفس المعمارية.

**القواعد الثابتة (Conventions):**
- C++20، Qt 6.8، CMake، SQLite. لا تُدخِل مكتبات خارجية بلا داعٍ.
- **المال دائمًا `qint64` minor units.** لا تستخدم `float`/`double` للمال إلا للعرض.
- المنطق في `src/core` فقط (لا تضع SQL أو حسابات داخل QML أو ViewModels).
- ViewModels ترث `QObject` وتغلّف الـ core؛ تتواصل QML معها عبر `App` (context property).
- كل نوع QML جديد مشترك يوضع في `qml/shared/` ويُضاف إلى `QML_FILES` في `src/app/CMakeLists.txt`.
- لا تستخدم QtCharts (ترخيص GPL). ارسم المخططات بـ QML.
- استخدم `qsTr("...")` لكل النصوص الظاهرة (تدويل لاحق).
- لا تكسر بناء سطح المكتب عند العمل على الهاتف، والعكس.

**مهام مقترحة بالترتيب (أمثلة Prompts):**
1. "في `TransactionRepository` و`AppController`، أضِف **وضع تعديل** عملية: دالة `updateTransaction(...)` و`Q_INVOKABLE`، وعدّل `TransactionDialog.qml` ليعمل للإضافة والتعديل (مرّر `txId`)."
2. "أضِف تأكيدًا قبل الحذف في `TransactionsPage.qml` عبر `Dialog`."
3. "نفّذ `BudgetRepository` وصفحة تحديد **حدود التصنيفات الشهرية**، واعرض شريط تقدّم لكل تصنيف في `ReportsPage`."
4. "أكمل `ReportsPage` بمخطط يومي (أعمدة) مرسوم بـ QML من `BudgetService::dailyTotals`."
5. "أضِف أعمدة `uuid` و`is_deleted` عبر **هجرة v2** في `Database::migrate()` (حدّث `kTargetSchemaVersion`)، واملأ uuid عند الإدخال."
6. "أكمل واجهة الهاتف في `qml/mobile/` مع إعادة استخدام `AppController`."
7. "أضِف اختبارات Qt Test جديدة في `tests/` لكل دالة في `BudgetService`."

**معايير القبول لأي مهمة:** يبني المشروع بلا تحذيرات جديدة، الاختبارات تمر، وسطح المكتب يعمل كـ EXE.

---

## نصائح وبدائل أفضل (طلبتها صراحةً)

**اختيارك لـ C++/Qt — ممتاز لهدفك.** تريد تجربة بناء تطبيق بـ C++، وهذا أنسب مزيج: كود C++ واحد لسطح المكتب والهاتف، أداء عالٍ، وإحساس native. (بدائل مثل Flutter/Dart أو .NET MAUI أو Kotlin Multiplatform أسهل أحيانًا للهاتف، لكنها لا تخدم هدف "تعلّم C++" وتجعل سطح المكتب أقل أصالة. لذا Qt هو الصواب هنا.)

**نصائح تقنية مهمة:**

1. **Qt 6.8 LTS لا الأحدث.** استقرار + دعم 5 سنوات. (راجع جدول الملاحظات أعلى.)
2. **ربط ديناميكي (LGPL).** لا تربط Qt ساكنًا إلا إذا كنت ستفتح مصدرك أو توزّع object files.
3. **المال أعداد صحيحة.** أهم نصيحة عملية — تجنّب كوارث التقريب.
4. **لا QtCharts الآن.** رخصتها GPL ستُجبر تطبيقك كله على GPL. المخططات اليدوية كافية وأنظف ترخيصًا.
5. **بخصوص "واجهتان منفصلتان تمامًا":** نفّذنا طلبك (مجلدا desktop/mobile منفصلان)، لكن انتبه أنه **يضاعف الصيانة**. النصيحة: **عظّم المكوّنات المشتركة في `shared/`** (Theme, Card, MoneyText, الحوارات) واجعل الاختلاف في "الهيكل" فقط (Sidebar مقابل TabBar). هكذا تحصل على مظهرين مختلفين فعلًا دون تكرار المنطق أو المكوّنات الصغيرة. (بديل آخر: واجهة واحدة "متجاوبة" تتبدّل حسب العرض — أقل عملًا لكنها لا تعطي تجربتين أصيلتين كما تريد، لذا اخترنا الفصل.)
6. **أضِف `uuid` + `is_deleted` مبكرًا** إن كنت جادًّا بالمزامنة لاحقًا — يوفّر هجرة مؤلمة.
7. **Qt Creator** أفضل IDE للبداية (يولّد قوالب Android تلقائيًا). لا تحتاج vcpkg/conan.
8. **للجدول الكبير لاحقًا:** عند نموّ البيانات، انتقل من `ListView` إلى `TableView` + `HorizontalHeaderView` (موجود في Qt Quick Controls) لأداء أفضل مع آلاف الصفوف.
9. **اختبر الـ core دائمًا** بـ Qt Test (مجلد `tests/` يبيّن الطريقة) — المنطق منفصل عن الواجهة فيسهُل اختباره.

---

## المصادر (تحقّق تقني محدّث)

- Qt 6.8 LTS ودورة الإصدارات: https://www.qt.io/blog/commercial-lts-qt-6.8.7-released و https://www.qt.io/development/qt-framework/release-cycle
- نهاية دعم Qt 6.5 (أبريل 2026): https://www.qt.io/blog/qt-6.5-reaches-end-of-support
- بناء Android من المصدر / NDK: https://doc.qt.io/qt-6/android-building.html
- `QT_ANDROID_BUILD_ALL_ABIS` / `QT_ANDROID_ABIS`: https://doc.qt.io/qt-6/cmake-variable-qt-android-build-all-abis.html و https://doc.qt.io/qt-6/cmake-variable-qt-android-abis.html
- Multi-ABI للتطبيقات: https://www.qt.io/blog/android-multi-abi-builds-are-back
- النشر على Android (AAB/APK): https://doc.qt.io/qt-6/deployment-android.html
- الحد الأدنى لإصدار Android (API 28 لـ Qt 6.8): https://doc.qt.io/qt-6/android-supported-versions-selection-guidelines.html و https://doc.qt.io/qt-6.8/android-platform-notes.html
- التزامات LGPL: https://www.qt.io/development/open-source-lgpl-obligations و https://wiki.qt.io/Licensing-talk-about-mobile-platforms
```
