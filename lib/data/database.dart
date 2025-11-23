import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../utils/constants.dart';

class AppDatabase {
  static final AppDatabase instance = AppDatabase._internal();
  static Database? _database;

  AppDatabase._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final Directory documentsDirectory =
        await getApplicationDocumentsDirectory();
    final String path = join(
      documentsDirectory.path,
      AppConstants.databaseName,
    );

    return await openDatabase(
      path,
      version: AppConstants.databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
      onConfigure: _onConfigure,
    );
  }

  // Habilitar foreign keys
  Future<void> _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  // Criar tabelas iniciais
  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        color_hex TEXT NOT NULL,
        created_at INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE categories (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        type TEXT CHECK(type IN ('INCOME','OUTCOME','BOTH')) NOT NULL,
        color_hex TEXT UNIQUE NOT NULL,
        created_at INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE transactions (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        category_id TEXT NOT NULL,
        type TEXT CHECK(type IN ('INCOME','OUTCOME')) NOT NULL,
        amount REAL NOT NULL,
        date INTEGER NOT NULL,
        note TEXT,
        created_at INTEGER NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
        FOREIGN KEY (category_id) REFERENCES categories(id) ON DELETE RESTRICT
      )
    ''');

    // Criar índices para otimização
    await db.execute(
      'CREATE INDEX idx_transactions_date ON transactions(date)',
    );
    await db.execute(
      'CREATE INDEX idx_transactions_user ON transactions(user_id)',
    );
    await db.execute(
      'CREATE INDEX idx_transactions_category ON transactions(category_id)',
    );
    await db.execute(
      'CREATE INDEX idx_transactions_type ON transactions(type)',
    );

    // Inserir dados iniciais (opcional)
    await _seedInitialData(db);
  }

  // Migração de versões futuras
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Implementar migrations aqui quando necessário
    // Exemplo:
    // if (oldVersion < 2) {
    //   await db.execute('ALTER TABLE users ADD COLUMN email TEXT');
    // }
  }

  // Dados iniciais para facilitar testes
  Future<void> _seedInitialData(Database db) async {
    // Inserir categorias padrão
    final now = DateTime.now().millisecondsSinceEpoch;

    await db.insert('categories', {
      'id': 'cat-1',
      'name': 'Salário',
      'type': 'INCOME',
      'color_hex': '#4A90E2',
      'created_at': now,
    });

    await db.insert('categories', {
      'id': 'cat-2',
      'name': 'Alimentação',
      'type': 'OUTCOME',
      'color_hex': '#50C878',
      'created_at': now,
    });

    await db.insert('categories', {
      'id': 'cat-3',
      'name': 'Transporte',
      'type': 'OUTCOME',
      'color_hex': '#E67E22',
      'created_at': now,
    });

    await db.insert('categories', {
      'id': 'cat-4',
      'name': 'Freelance',
      'type': 'INCOME',
      'color_hex': '#9B59B6',
      'created_at': now,
    });
  }

  // Fechar database
  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }

  // Resetar database (útil para desenvolvimento/testes)
  Future<void> deleteDatabase() async {
    final Directory documentsDirectory =
        await getApplicationDocumentsDirectory();
    final String path = join(
      documentsDirectory.path,
      AppConstants.databaseName,
    );

    await databaseFactory.deleteDatabase(path);
    _database = null;
  }
}
