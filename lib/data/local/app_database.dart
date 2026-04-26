import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

part 'app_database.g.dart';

class Goals extends Table {
  TextColumn get id => text()();

  TextColumn get title => text()();

  TextColumn get description => text().withDefault(const Constant(''))();

  TextColumn get status => text()();

  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class Milestones extends Table {
  TextColumn get id => text()();

  TextColumn get goalId => text().references(Goals, #id)();

  TextColumn get title => text()();

  TextColumn get description => text().withDefault(const Constant(''))();

  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class Tasks extends Table {
  TextColumn get id => text()();

  TextColumn get goalId => text().nullable().references(Goals, #id)();

  TextColumn get milestoneId => text().nullable().references(Milestones, #id)();

  TextColumn get title => text()();

  TextColumn get description => text().withDefault(const Constant(''))();

  DateTimeColumn get scheduledDate => dateTime().nullable()();

  BoolColumn get isCompleted => boolean().withDefault(const Constant(false))();

  DateTimeColumn get completedAt => dateTime().nullable()();

  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(tables: [Goals, Milestones, Tasks])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(path.join(dbFolder.path, 'goal_planner.sqlite'));

    return NativeDatabase.createInBackground(file);
  });
}
