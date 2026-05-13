import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import '../l10n/app_localizations.dart';
import 'app_shell.dart';
import 'settings/app_language.dart';
import 'settings/app_language_store.dart';

class GoalPlannerApp extends StatefulWidget {
  const GoalPlannerApp({super.key});

  @override
  State<GoalPlannerApp> createState() => _GoalPlannerAppState();
}

class _GoalPlannerAppState extends State<GoalPlannerApp> {
  final _languageStore = AppLanguageStore();

  AppLanguage _language = AppLanguage.system;

  @override
  void initState() {
    super.initState();

    unawaited(_loadLanguage());
  }

  Future<void> _loadLanguage() async {
    final language = await _languageStore.loadLanguage();

    if (!mounted) {
      return;
    }

    setState(() {
      _language = language;
    });
  }

  Future<void> _setLanguage(AppLanguage language) async {
    setState(() {
      _language = language;
    });

    await _languageStore.saveLanguage(language);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      locale: _language.locale,
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: AppShell(
        selectedLanguage: _language,
        onLanguageChanged: (language) {
          unawaited(_setLanguage(language));
        },
      ),
    );
  }
}
