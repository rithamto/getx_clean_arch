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
}
