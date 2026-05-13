import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

import 'app_language.dart';

class AppLanguageStore {
  static const _fileName = 'app_settings.json';
  static const _languageKey = 'language';

  Future<AppLanguage> loadLanguage() async {
    try {
      final file = await _settingsFile();

      if (!await file.exists()) {
        return AppLanguage.system;
      }

      final content = await file.readAsString();
      final decoded = jsonDecode(content);

      if (decoded is! Map<String, dynamic>) {
        return AppLanguage.system;
      }

      return appLanguageFromStorageValue(decoded[_languageKey]);
    } catch (_) {
      return AppLanguage.system;
    }
  }

  Future<void> saveLanguage(AppLanguage language) async {
    final file = await _settingsFile();
    await file.parent.create(recursive: true);

    final settings = await _readSettings(file);
    settings[_languageKey] = language.storageValue;

    await file.writeAsString(jsonEncode(settings));
  }

  Future<Map<String, dynamic>> _readSettings(File file) async {
    if (!await file.exists()) {
      return <String, dynamic>{};
    }

    try {
      final content = await file.readAsString();
      final decoded = jsonDecode(content);

      if (decoded is Map<String, dynamic>) {
        return decoded;
      }

      return <String, dynamic>{};
    } catch (_) {
      return <String, dynamic>{};
    }
  }

  Future<File> _settingsFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return File(path.join(directory.path, _fileName));
  }
}
