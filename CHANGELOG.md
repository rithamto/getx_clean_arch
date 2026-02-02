## 0.0.4

*   **App Entry Point Generation**:
    *   `init` command now generates `lib/app.dart` with `GetMaterialApp` configuration.
    *   `init` command now overwrites `lib/main.dart` with proper service initialization template.
    *   Supports automatic package name detection from `pubspec.yaml`.

## 0.0.3

*   **Router Support**:
    *   `init` command now generates `lib/routes` with `app_routes.dart` and `app_pages.dart`.
    *   `create:feature` automatically registers new pages and routes in the Router files.

## 0.0.2

*   **Enhanced Init Command**:
    *   Added support for creating a new Flutter project from scratch: `getxcli init <project_name>`.
    *   Automatically adds `get`, `dio`, `flutter_flavorizr` dependencies.
    *   Configures Clean Architecture structure in the new project.

## 0.0.1

*   **Initial Release**:
    *   **Project Scaffolding**: `init` command to setup Clean Architecture structure (Core, DI, Theme).
    *   **Feature Generation**: `create:feature` command to generate Modules (Bindings, Controllers, Pages, Models, Widgets).
    *   **Asset Management**: `generate:assets` command to scan and generate type-safe asset constants.
    *   **Utilities**:
        *   `refresh`: Shortcut for `flutter clean && flutter pub get`.
        *   `git:branch`: Shortcut for creating new git branches.
        *   `run:flavor`: Shortcut for running specific environment flavors.
    *   **Router Support**: Integrated with GetX router.
