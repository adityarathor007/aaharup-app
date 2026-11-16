# Aaharup — AI Meal Planner (Flutter)

> An AI-powered meal planning app built for Indian households. Plan your weekly meals, get intelligent dish suggestion, and generate grocery lists — all in one place.

## Demo

https://github.com/user-attachments/assets/019a1c89-4e8d-4a1c-83d4-4de2e485ed55
---

## What the app does

Most working adults in Indian households spend unnecessary time deciding what to cook, forget ingredients mid-week, and default to the same five dishes. Aaharup solves this by letting users plan meals a day or week in advance. An AI assistant suggests dishes based on natural language queries, generates full recipes on demand.

---

## Key features

- **Weekly meal calendar** — Plan breakfast, lunch, and dinner across a 7-day calendar. Each slot is independently assignable and persists across sessions.
- **AI dish discovery** — Natural language search over 6000+ Indian recipes powered by a RAG pipeline. Type *"something spicy and quick"* and get ranked suggestions with per-dish reasoning in 2–4 seconds.
- **Conversational search** — Follow-up queries like *"show me something lighter"* work within the same session without re-explaining preferences. Session memory is scoped to the screen and cleared on exit.

---

## Tech stack

| Layer | Technology |
|---|---|
| Framework | Flutter 3.x |
| State management | Riverpod (`NotifierProvider`, `AsyncNotifier`) |
| Navigation | `go_router` |
| HTTP client | `dio` with JWT interceptor + refresh logic |
| Local cache | `hive_flutter` |
| Charts | `fl_chart` |
| Unique IDs | `uuid` |
| Fonts | Google Fonts — Plus Jakarta Sans |

---

## Project structure

```
lib/
├── main.dart                         # App entry point, ProviderScope root
│
├── core/
│   ├── network/                      # Dio client, interceptors, base API config
│   ├── routing/                      # go_router route definitions and guards
│   └── theme/                        # AppColors, AppTextStyles, AppSpacing,
│                                     # ThemeData for light and dark mode
│
├── shared/
│   ├── providers/                    # Cross-feature Riverpod providers
│   └── widgets/                      # Reusable UI components used across features
│
└── features/
    ├── auth/
    │   ├── data/                     # AuthRepository, login/register API calls
    │   └── presentation/             # Login screen, Register screen
    │
    ├── meal_planner/
    │   ├── data/                     # MealPlanRepository, slot scheduling API
    │   └── presentation/             # Weekly calendar UI, meal slot widgets,
    │                                 # dish detail bottom sheet
    │
    ├── ai_search/
    │   ├── data/                     # AiSearchRepository, RAG search API calls,
    │   │                             # session management
    │   └── presentation/             # Discovery feed, swipe card UI, chat input,
    │                                 # conversation history view
    │
    └── profile/
        ├── data/                     # UserRepository, preferences API
        └── presentation/             # Profile screen, dietary preferences,
                                      # weekly nutrition dashboard
```

---


## State management pattern

All features follow the same Riverpod pattern:

```
Repository  →  NotifierProvider  →  Widget (ConsumerWidget / ConsumerStatefulWidget)
```

- **Repositories** handle all API calls via `dio` and return typed Dart models
- **Notifiers** hold screen state and expose methods (`sendAiQuery`, `scheduleMeal`, etc.)
- **Widgets** watch providers via `ref.watch` and trigger actions via `ref.read(...).notifier`
- **`autoDispose`** is used on all screen-level providers to clean up state and backend sessions when the user navigates away

---

## Getting started

### Prerequisites

- Flutter 3.x (`flutter doctor` should pass)
- Backend API running — see [aaharup-api](https://github.com/adityarathor007/aaharup-api)
### Setup

```bash
# Clone the repo
git clone https://github.com/your-org/aaharup-app.git
cd aaharup-app

# Install dependencies
flutter pub get

# Create environment config
cp .env.example .env
# Set API_BASE_URL in .env to your backend URL

# Run on device or emulator
flutter run
```

### Environment variables

```env
API_BASE_URL=http://localhost:8000
```

---
