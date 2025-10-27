# Smart Task Manager - Clean Architecture Guide

## Overview

This project follows **Clean Architecture** with a **feature-first** structure. This architecture separates the application into distinct layers with clear responsibilities, making the codebase maintainable, testable, and scalable.

## Folder Structure

```
lib/
├── core/                    # Shared, reusable code across features
│   ├── network/            # HTTP client setup
│   ├── constants/          # App-wide constants
│   └── utils/              # Utility functions
├── features/               # Business features organized by domain
│   └── tasks/             # Task management feature
│       ├── data/          # Data layer (API, DB, cache)
│       ├── domain/        # Business logic layer
│       └── presentation/  # UI layer
├── app/                    # App-level configuration
└── l10n/                   # Localization
```

---

## Core Layer (`lib/core/`)

The core layer contains code that is shared across multiple features and is framework-agnostic.

### `core/network/`

**Purpose:** Network-related configurations and abstractions.

**Files:**
- `dio_client.dart` - Centralized HTTP client with interceptors
- `network_exceptions.dart` - Custom exception handling for network errors

**How it supports scalability:**
- **Single Point of Configuration:** All HTTP client settings (timeouts, headers, base URL) are configured in one place
- **Reusability:** The Dio client can be used by any feature without code duplication
- **Easy Testing:** Can be easily mocked for unit tests
- **Error Handling:** Centralized exception handling ensures consistent error messages throughout the app

### `core/constants/`

**Purpose:** Application-wide constants and configuration values.

**Files:**
- `api_constants.dart` - API endpoint URLs
- `app_constants.dart` - App-wide settings (timeouts, pagination, formats)

**How it supports scalability:**
- **Centralized Configuration:** Update a value once, and it changes everywhere
- **Environment Management:** Easy to maintain different constants for dev/staging/prod
- **Type Safety:** Constants are compile-time, preventing typos and runtime errors

### `core/utils/`

**Purpose:** Utility functions used across the application.

**Files:**
- `logger.dart` - Centralized logging utility

**How it supports scalability:**
- **Consistent Logging:** All features use the same logging format
- **Debugging:** Centralized logging makes it easy to add analytics or remote logging
- **Maintainability:** Easy to modify logging behavior app-wide

---

## Features Layer (`lib/features/tasks/`)

Each feature is self-contained with its own data, domain, and presentation layers. This **feature-first** approach:

### Benefits for Scalability:

1. **Team Scalability:** Multiple teams can work on different features simultaneously without conflicts
2. **Code Organization:** Easy to find feature-specific code
3. **Independent Deployment:** Features can be developed, tested, and maintained independently
4. **Easy Removal:** Removing a feature doesn't affect others

---

### Feature: Tasks (`lib/features/tasks/`)

#### Data Layer (`data/`)

**Responsibility:** How data is fetched and stored.

**Structure:**
```
data/
├── datasources/     # API calls, database operations
├── models/          # Data transfer objects (JSON serialization)
└── repositories/    # Repository implementations
```

**Files:**
- `datasources/task_remote_datasource.dart` - Handles HTTP API calls using Dio
- `models/task_model.dart` - JSON serialization for Task data
- `repositories/task_repository_impl.dart` - Implements repository interface

**How it supports scalability:**
- **Separation of Concerns:** Data fetching logic is isolated from business logic
- **Easy to Mock:** Can be easily mocked for testing without making actual API calls
- **Multiple Data Sources:** Can easily add caching (local DB) without changing domain logic
- **API Changes:** Changes to API endpoints only affect the data layer

#### Domain Layer (`domain/`)

**Responsibility:** Business logic independent of UI and data sources.

**Structure:**
```
domain/
├── entities/      # Business objects
├── repositories/  # Repository interfaces (contracts)
└── usecases/      # Business operations
```

**Files:**
- `entities/task.dart` - Pure Dart class representing a Task
- `repositories/task_repository.dart` - Interface defining data operations
- `usecases/` - Individual business operations:
  - `get_tasks_usecase.dart` - Fetch all tasks
  - `get_task_usecase.dart` - Fetch single task
  - `create_task_usecase.dart` - Create task
  - `update_task_usecase.dart` - Update task
  - `delete_task_usecase.dart` - Delete task

**How it supports scalability:**
- **Business Logic Isolation:** Core business rules are independent of UI and data
- **Testability:** Can test business logic without UI or network
- **Reusability:** Same use cases can be used by different UIs (mobile, web, CLI)
- **Single Responsibility:** Each use case does one thing
- **Framework Independence:** No Flutter/Bloc dependencies = portable business logic

#### Presentation Layer (`presentation/`)

**Responsibility:** UI and state management.

**Structure:**
```
presentation/
├── cubit/        # State management
├── pages/        # UI screens
└── widgets/      # Reusable UI components
```

**Files:**
- `cubit/task_cubit.dart` - Manages task state using BLoC pattern
- `pages/task_list_page.dart` - UI for displaying tasks

**How it supports scalability:**
- **State Management:** Clear state transitions make UI predictable
- **Separation from Logic:** UI doesn't contain business logic
- **Easy Testing:** Cubit can be tested independently of UI
- **Reactive UI:** BLoC pattern provides reactive updates

---

## Architectural Principles

### 1. Dependency Rule

```
Presentation Layer → Domain Layer ← Data Layer
         ↓                ↓              ↓
    (Depends on)    (Independent)   (Depends on)
```

- **Domain layer** has NO dependencies on outer layers
- **Data layer** implements domain interfaces
- **Presentation layer** calls domain use cases

### 2. Single Responsibility

Each class/file has one clear purpose:
- Use cases = one business operation
- Data sources = one data source type
- Repositories = coordination between sources

### 3. Dependency Inversion

Domain layer defines interfaces (repositories), data layer implements them. This allows:
- Easy testing (mock repositories)
- Multiple implementations (API + cache)
- Switching implementations without changing domain code

---

## Data Flow Example

**Creating a Task:**

```
1. User taps "Add Task" button
   ↓
2. UI calls: TaskCubit.createTask(title, description)
   ↓
3. TaskCubit calls: CreateTaskUseCase.call(...)
   ↓
4. CreateTaskUseCase calls: TaskRepository.createTask(...)
   ↓
5. TaskRepositoryImpl calls: TaskRemoteDataSource.createTask(...)
   ↓
6. TaskRemoteDataSource makes HTTP POST request using Dio
   ↓
7. Response flows back through the layers
   ↓
8. TaskCubit emits new state
   ↓
9. UI rebuilds with the new task
```

---

## Benefits of This Architecture

### For Development:
- ✅ **Clear Organization:** Easy to find code
- ✅ **Parallel Development:** Multiple features simultaneously
- ✅ **Easy Onboarding:** New developers understand the structure quickly

### For Testing:
- ✅ **Unit Tests:** Each layer can be tested independently
- ✅ **Mocking:** Interfaces allow easy mocking
- ✅ **Business Logic Tests:** Test without UI or network

### For Maintenance:
- ✅ **Change Isolation:** Changes to one layer don't break others
- ✅ **Refactoring:** Easy to replace implementations
- ✅ **Code Reuse:** Shared code in core layer

### For Scalability:
- ✅ **Team Growth:** Multiple teams can work independently
- ✅ **Feature Addition:** New features follow the same pattern
- ✅ **Framework Swapping:** Can change UI or data frameworks without affecting domain

---

## Next Steps

1. **Implement Data Layer:** Connect to actual API
2. **Add Caching:** Implement local database for offline support
3. **Authentication:** Add auth interceptors and token management
4. **Error Handling:** Implement user-friendly error messages
5. **Testing:** Write unit tests for each layer
6. **More Features:** Add priority, categories, due dates, etc.

---

## Resources

- [Clean Architecture by Robert C. Martin](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
- [Very Good Analysis](https://pub.dev/packages/very_good_analysis)
- [Flutter BLoC Pattern](https://bloclibrary.dev/)

