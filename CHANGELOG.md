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
