import 'package:flutter/widgets.dart';

enum AppLanguage { system, english, russian }

extension AppLanguageLocale on AppLanguage {
  String get storageValue {
    return switch (this) {
      AppLanguage.system => 'system',
      AppLanguage.english => 'en',
      AppLanguage.russian => 'ru',
    };
  }

  Locale? get locale {
    return switch (this) {
      AppLanguage.system => null,
      AppLanguage.english => const Locale('en'),
      AppLanguage.russian => const Locale('ru'),
    };
  }
}

AppLanguage appLanguageFromStorageValue(Object? value) {
  return switch (value) {
    'en' => AppLanguage.english,
    'ru' => AppLanguage.russian,
    'system' => AppLanguage.system,
    _ => AppLanguage.system,
  };
}
