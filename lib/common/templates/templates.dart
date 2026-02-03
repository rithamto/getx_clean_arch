import 'package:recase/recase.dart';

class Templates {
  static String binding(String name, String importPrefix) {
    final rc = ReCase(name);
    return '''
import 'package:get/get.dart';
import 'package:${importPrefix}/features/${rc.snakeCase}/controllers/${rc.snakeCase}_controller.dart';

class ${rc.pascalCase}Binding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<${rc.pascalCase}Controller>(
      () => ${rc.pascalCase}Controller(),
    );
  }
}
''';
  }

  static String controller(String name) {
    final rc = ReCase(name);
    return '''
import 'package:get/get.dart';

class ${rc.pascalCase}Controller extends GetxController {
  // TODO: Implement ${rc.pascalCase}Controller
}
''';
  }

  static String page(String name, String importPrefix) {
    final rc = ReCase(name);
    return '''
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:${importPrefix}/features/${rc.snakeCase}/controllers/${rc.snakeCase}_controller.dart';

class ${rc.pascalCase}Page extends GetView<${rc.pascalCase}Controller> {
  const ${rc.pascalCase}Page({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('${rc.pascalCase}Page'),
      ),
      body: const Center(
        child: Text(
          '${rc.pascalCase}Page is working',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
''';
  }

  static String barrel(String name) {
    final rc = ReCase(name);
    return '''
export 'bindings/${rc.snakeCase}_binding.dart';
export 'controllers/${rc.snakeCase}_controller.dart';
export 'pages/${rc.snakeCase}_page.dart';
// export 'models/model.dart';
// export 'widgets/widget.dart';
// export 'dialog/dialog.dart';
''';
  }

  static String get appRoutes => '''
part of 'app_pages.dart';
// DO NOT EDIT. This is code generated via package:get_cli/get_cli.dart

abstract class Routes {
  Routes._();
  // static const HOME = _Paths.HOME;
}

abstract class _Paths {
  _Paths._();
  // static const HOME = '/home';
}
''';

  static String get appPages => '''
import 'package:get/get.dart';
part 'app_routes.dart';

class AppPages {
  AppPages._();

  // static const INITIAL = Routes.HOME;

  static final routes = [
    // GetPage(
    //   name: _Paths.HOME,
    //   page: () => const HomePage(),
    //   binding: HomeBinding(),
    // ),
  ];
}
''';

  static String main(String importPrefix) {
    return '''
import 'package:${importPrefix}/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'package:get/get.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Services
  // await Get.putAsync(() => StorageService().init());
  _hideSystemUI();
  runApp(const App());
}

void _hideSystemUI() {
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarBrightness: Brightness.light,
      systemStatusBarContrastEnforced: true,
    ),
  );

  SystemChrome.setPreferredOrientations(<DeviceOrientation>[
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  SystemChrome.setSystemUIChangeCallback((systemOverlaysAreVisible) async {
    if (systemOverlaysAreVisible) {
      await Future.delayed(const Duration(seconds: 3));
      SystemChrome.restoreSystemUIOverlays();
    }
  });
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
}
''';
  }

  static String app(String importPrefix) {
    return '''
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:${importPrefix}/routes/app_pages.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => AppState();
}

class AppState extends State<App> with WidgetsBindingObserver {
  // final languageCtrl = Get.put(LanguageController());

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // if (_state == AppLifecycleState.paused) {}
    } else if (state == AppLifecycleState.paused) {}
    super.didChangeAppLifecycleState(state);
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      initialRoute: AppPages.INITIAL, // Ensure this maps to a valid route
      getPages: AppPages.routes,
      navigatorKey: Get.key,
      // locale: Locale(languageCtrl.currentLanguage.value),
      // translations: LanguageUtil(),
      title: "App Name", // GlobalConstants.kAppName
      // supportedLocales: GlobalConstants.supportedLocales,
      theme: ThemeData.light(), // MTheme.light
      darkTheme: ThemeData.dark(), // MTheme.dark
      // themeMode: StorageService.to.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      // fallbackLocale: LanguageUtil.fallbackLocale,
    );
  }
}
''';
  }

  // ==================== THEME TEMPLATES ====================

  static String mColors() {
    return '''
import 'package:flutter/material.dart';

/// Color palette for the application.
/// Access colors via `MColors.primary`, `MColors.secondary`, etc.
class MColors {
  MColors._();

  // Primary Palette
  static const Color primary = Color(0xFF4CAF50);
  static const Color primaryDark = Color(0xFF388E3C);
  static const Color primaryLight = Color(0xFFC8E6C9);
  static const Color primaryForDark = Color(0xFF81C784);

  // Secondary Palette
  static const Color secondary = Color(0xFF03A9F4);
  static const Color secondaryDark = Color(0xFF0288D1);
  static const Color secondaryLight = Color(0xFFB3E5FC);

  // Neutral Colors
  static const Color backgroundLight = Color(0xFFF5F5F5);
  static const Color backgroundDark = Color(0xFF121212);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF1E1E1E);

  // Text Colors
  static const Color textLight = Color(0xFF212121);
  static const Color textDark = Color(0xFFE0E0E0);
  static const Color textSecondaryLight = Color(0xFF757575);
  static const Color textSecondaryDark = Color(0xFFBDBDBD);

  // Status Colors
  static const Color error = Color(0xFFD32F2F);
  static const Color success = Color(0xFF388E3C);
  static const Color warning = Color(0xFFFFA000);
  static const Color info = Color(0xFF1976D2);
}
''';
  }

  static String mTextTheme(String importPrefix) {
    return '''
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:$importPrefix/common/themes/m_color.dart';

/// Text theme configuration using Google Fonts.
class MTextTheme {
  MTextTheme._();

  static final fontFamily = GoogleFonts.inter().fontFamily;

  static TextTheme get lightTextTheme => _baseTextTheme(MColors.textLight);
  static TextTheme get darkTextTheme => _baseTextTheme(MColors.textDark);

  static TextTheme _baseTextTheme(Color color) {
    return TextTheme(
      displayLarge: TextStyle(fontSize: 57, fontWeight: FontWeight.w400, color: color),
      displayMedium: TextStyle(fontSize: 45, fontWeight: FontWeight.w400, color: color),
      displaySmall: TextStyle(fontSize: 36, fontWeight: FontWeight.w400, color: color),
      headlineLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.w400, color: color),
      headlineMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.w400, color: color),
      headlineSmall: TextStyle(fontSize: 24, fontWeight: FontWeight.w400, color: color),
      titleLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.w500, color: color),
      titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: color),
      titleSmall: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: color),
      bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: color),
      bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: color),
      bodySmall: TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: color),
      labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: color),
      labelMedium: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: color),
      labelSmall: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: color),
    );
  }
}
''';
  }

  static String mTheme(String importPrefix) {
    return '''
import 'package:flutter/material.dart';
import 'package:$importPrefix/common/themes/m_color.dart';
import 'package:$importPrefix/common/themes/m_text_theme.dart';

/// Application theme configuration.
/// Use `MTheme.light` and `MTheme.dark` for theme data.
class MTheme {
  MTheme._();

  // Light Theme
  static ThemeData get light => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: MColors.primary,
    scaffoldBackgroundColor: MColors.backgroundLight,
    cardColor: Colors.white,
    canvasColor: MColors.surfaceLight,
    colorScheme: const ColorScheme(
      brightness: Brightness.light,
      primary: MColors.primary,
      onPrimary: Colors.white,
      secondary: MColors.secondary,
      onSecondary: Colors.white,
      surface: Colors.white,
      onSurface: MColors.textLight,
      error: MColors.error,
      onError: Colors.white,
    ),
    fontFamily: MTextTheme.fontFamily,
    textTheme: MTextTheme.lightTextTheme,
    appBarTheme: const AppBarTheme(
      backgroundColor: MColors.backgroundLight,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      iconTheme: IconThemeData(color: MColors.textLight),
      titleTextStyle: TextStyle(
        color: MColors.textLight,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
    ),
  );

  // Dark Theme
  static ThemeData get dark => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: MColors.primaryForDark,
    scaffoldBackgroundColor: MColors.backgroundDark,
    cardColor: MColors.surfaceDark,
    canvasColor: MColors.surfaceDark,
    colorScheme: const ColorScheme(
      brightness: Brightness.dark,
      primary: MColors.primaryForDark,
      onPrimary: Colors.black,
      secondary: MColors.secondaryLight,
      onSecondary: Colors.black,
      surface: MColors.surfaceDark,
      onSurface: MColors.textDark,
      error: MColors.error,
      onError: Colors.white,
    ),
    fontFamily: MTextTheme.fontFamily,
    textTheme: MTextTheme.darkTextTheme,
    appBarTheme: const AppBarTheme(
      backgroundColor: MColors.backgroundDark,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      iconTheme: IconThemeData(color: MColors.textDark),
      titleTextStyle: TextStyle(
        color: MColors.textDark,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
    ),
  );
}
''';
  }

  static String get themesBarrel => '''
export 'm_color.dart';
export 'm_text_theme.dart';
export 'm_theme.dart';
''';

  // ==================== FIREBASE TEMPLATES ====================

  static String firebaseOptions(String importPrefix) {
    return '''
// File generated by getx_clean_arch CLI.
// Replace with actual Firebase configuration from FlutterFire CLI.

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    // Check flavor
    const flavor = String.fromEnvironment('FLAVOR', defaultValue: 'dev');
    
    if (kIsWeb) {
      throw UnsupportedError('Web is not supported.');
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return flavor == 'prod' ? androidProd : androidDev;
      case TargetPlatform.iOS:
        return flavor == 'prod' ? iosProd : iosDev;
      default:
        throw UnsupportedError('Unsupported platform.');
    }
  }

  // DEV - Android
  static const FirebaseOptions androidDev = FirebaseOptions(
    apiKey: 'YOUR_DEV_API_KEY',
    appId: 'YOUR_DEV_APP_ID',
    messagingSenderId: 'YOUR_DEV_SENDER_ID',
    projectId: 'YOUR_DEV_PROJECT_ID',
    storageBucket: 'YOUR_DEV_STORAGE_BUCKET',
  );

  // DEV - iOS
  static const FirebaseOptions iosDev = FirebaseOptions(
    apiKey: 'YOUR_DEV_API_KEY',
    appId: 'YOUR_DEV_APP_ID',
    messagingSenderId: 'YOUR_DEV_SENDER_ID',
    projectId: 'YOUR_DEV_PROJECT_ID',
    storageBucket: 'YOUR_DEV_STORAGE_BUCKET',
    iosBundleId: 'com.example.app.dev',
  );

  // PROD - Android
  static const FirebaseOptions androidProd = FirebaseOptions(
    apiKey: 'YOUR_PROD_API_KEY',
    appId: 'YOUR_PROD_APP_ID',
    messagingSenderId: 'YOUR_PROD_SENDER_ID',
    projectId: 'YOUR_PROD_PROJECT_ID',
    storageBucket: 'YOUR_PROD_STORAGE_BUCKET',
  );

  // PROD - iOS
  static const FirebaseOptions iosProd = FirebaseOptions(
    apiKey: 'YOUR_PROD_API_KEY',
    appId: 'YOUR_PROD_APP_ID',
    messagingSenderId: 'YOUR_PROD_SENDER_ID',
    projectId: 'YOUR_PROD_PROJECT_ID',
    storageBucket: 'YOUR_PROD_STORAGE_BUCKET',
    iosBundleId: 'com.example.app',
  );
}
''';
  }

  static String googleServicesJson(String flavor) {
    final suffix = flavor == 'dev' ? '.dev' : '';
    return '''
{
  "project_info": {
    "project_number": "YOUR_PROJECT_NUMBER",
    "project_id": "your-$flavor-project-id",
    "storage_bucket": "your-$flavor-project-id.appspot.com"
  },
  "client": [
    {
      "client_info": {
        "mobilesdk_app_id": "1:YOUR_PROJECT_NUMBER:android:YOUR_APP_HASH",
        "android_client_info": {
          "package_name": "com.example.app$suffix"
        }
      },
      "oauth_client": [],
      "api_key": [
        {
          "current_key": "YOUR_API_KEY_HERE"
        }
      ],
      "services": {
        "appinvite_service": {
          "other_platform_oauth_client": []
        }
      }
    }
  ],
  "configuration_version": "1"
}
''';
  }

  static String googleServiceInfoPlist(String flavor) {
    final suffix = flavor == 'dev' ? '.dev' : '';
    return '''
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CLIENT_ID</key>
    <string>YOUR_CLIENT_ID.apps.googleusercontent.com</string>
    <key>REVERSED_CLIENT_ID</key>
    <string>com.googleusercontent.apps.YOUR_CLIENT_ID</string>
    <key>API_KEY</key>
    <string>YOUR_API_KEY</string>
    <key>GCM_SENDER_ID</key>
    <string>YOUR_SENDER_ID</string>
    <key>PLIST_VERSION</key>
    <string>1</string>
    <key>BUNDLE_ID</key>
    <string>com.example.app$suffix</string>
    <key>PROJECT_ID</key>
    <string>your-$flavor-project-id</string>
    <key>STORAGE_BUCKET</key>
    <string>your-$flavor-project-id.appspot.com</string>
    <key>IS_ADS_ENABLED</key>
    <false></false>
    <key>IS_ANALYTICS_ENABLED</key>
    <false></false>
    <key>IS_APPINVITE_ENABLED</key>
    <true></true>
    <key>IS_GCM_ENABLED</key>
    <true></true>
    <key>IS_SIGNIN_ENABLED</key>
    <true></true>
    <key>GOOGLE_APP_ID</key>
    <string>YOUR_GOOGLE_APP_ID</string>
</dict>
</plist>
''';
  }

  static String get flavorizrConfig => '''

# Flutter Flavorizr Configuration
flavorizr:
  app:
    android:
      flavorDimensions: "flavor-type"
    ios:
  
  flavors:
    dev:
      app:
        name: "App Dev"
      android:
        applicationId: "com.example.app.dev"
        firebase:
          config: ".firebase/dev/google-services.json"
      ios:
        bundleId: "com.example.app.dev"
        firebase:
          config: ".firebase/dev/GoogleService-Info.plist"

    prod:
      app:
        name: "App"
      android:
        applicationId: "com.example.app"
        firebase:
          config: ".firebase/prod/google-services.json"
      ios:
        bundleId: "com.example.app"
        firebase:
          config: ".firebase/prod/GoogleService-Info.plist"
''';

  // ==================== GO ROUTER TEMPLATES ====================

  static String get appRoutesGoRouter => '''
/// Route names for the application.
/// Use these constants for navigation instead of hardcoded strings.
abstract class Routes {
  Routes._();

  static const String initial = '/';
  // static const String home = '/home';
}
''';

  static String appPagesGoRouter(String importPrefix) {
    return '''
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Application router configuration using GoRouter.
class AppRouter {
  AppRouter._();

  static final GoRouter router = GoRouter(
    initialLocation: Routes.initial,
    debugLogDiagnostics: true,
    routes: <RouteBase>[
      // GoRoute(
      //   path: Routes.home,
      //   name: 'home',
      //   builder: (context, state) => const HomePage(),
      // ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Page not found: \${state.uri}'),
      ),
    ),
  );
}

/// Route names for the application.
abstract class Routes {
  Routes._();

  static const String initial = '/';
  // static const String home = '/home';
}
''';
  }

  static String appGoRouter(String importPrefix) {
    return '''
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:$importPrefix/routes/app_pages.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => AppState();
}

class AppState extends State<App> with WidgetsBindingObserver {
  // final languageCtrl = Get.put(LanguageController());

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // if (_state == AppLifecycleState.paused) {}
    } else if (state == AppLifecycleState.paused) {}
    super.didChangeAppLifecycleState(state);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: AppRouter.router,
      title: "App Name", // GlobalConstants.kAppName
      // supportedLocales: GlobalConstants.supportedLocales,
      theme: ThemeData.light(), // MTheme.light
      darkTheme: ThemeData.dark(), // MTheme.dark
      // themeMode: StorageService.to.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      // fallbackLocale: LanguageUtil.fallbackLocale,
    );
  }
}
''';
  }
}
