# GetX Clean Architecture CLI

A powerful CLI tool for scaffolding and managing Flutter projects with **GetX** and **Clean Architecture**. This tool helps you maintain a scalable project structure, automate repetitive tasks, and enforce best practices.

## 🚀 Features

-   **Project Initialization**: Sets up the core structure (Network, Theme, Style) and Dependency Injection.
-   **Feature Generation**: Automatically creates Clean Architecture layers (`bindings`, `controllers`, `pages`, `models`, `widgets`) with a single command.
-   **Asset Generation**: Scans your `assets` folder and generates a type-safe `Assets` class.
-   **Utilities**: Shortcuts for common tasks like project refresh, git branching, and running specific flavors.
-   **Router Support**: Ready for GetX Router (and planned GoRouter support).

## 🛠 Installation & Usage

You can run the CLI directly from the source code or compile it.

### Run from Source
```bash
dart run bin/getxcli.dart <command>
```

### Compile to Executable
To run it globally as `getxcli`:
```bash
dart compile exe bin/getxcli.dart -o getxcli
# Add the current directory to your PATH or move the executable to /usr/local/bin
```

## 📚 Commands

### 1. Initialize Project
Sets up the foundation of your Clean Architecture project.
```bash
getxcli init
```
**What it does:**
-   Checks for Flutter and Git environment.
-   Creates `lib/core/` (network, theme, style).
-   Creates `lib/dependency_injection.dart` for centralized DI.

### 2. Create Feature
Generates a full feature module with all necessary files.
```bash
getxcli create:feature <feature_name> --router=<getx|go>
```
**Example:**
```bash
getxcli create:feature login --router=getx
```
**Generated Structure (`lib/features/login/`):**
-   `bindings/login_binding.dart`: Dependencies for the feature.
-   `controllers/login_controller.dart`: Business logic.
-   `pages/login_page.dart`: UI View.
-   `widgets/`: Local widgets.
-   `models/`: Feature-specific models.
-   `dialog/`: Feature-specific dialogs.
-   `login.dart`: Barrel file exporting public components.

### 3. Generate Assets
Auto-generates static constants for your assets.
```bash
getxcli generate:assets
```
**Input:** `assets/images/logo.png`
**Output (`lib/common/utils/assets.dart`):**
```dart
class Assets {
  static const String logoPng = 'assets/images/logo.png';
}
```

### 4. Utility Commands

-   **Refresh Project**: Runs `flutter clean` and `flutter pub get`.
    ```bash
    getxcli refresh
    ```
-   **Git Branch**: Shortcut to create and switch execution to a new branch.
    ```bash
    getxcli git:branch <branch_name>
    ```
-   **Run Flavor**: Shortcut to run a specific flavor (requires setup).
    ```bash
    getxcli run:flavor <flavor_name>
    # Runs: flutter run --flavor <flavor> -t lib/main_<flavor>.dart
    ```

## 📂 Project Structure

The CLI enforces a **Feature-First** Clean Architecture:

```
lib/
├── common/             # Shared utilities, widgets, templates
├── core/               # Core application logic (Network, Theme, Config)
├── features/           # Feature modules (Auth, Home, Profile...)
│   └── home/
│       ├── bindings/
│       ├── controllers/
│       ├── pages/
│       └── home.dart   # Barrel file
└── dependency_injection.dart
```

## 🤝 Contributing

Feel free to fork and submit PRs to improve the templates or add new commands!
