import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:varavu_selavu/core/constants/app_constants.dart';
import 'package:varavu_selavu/core/database/database_tables.dart';

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
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, AppConstants.databaseName);

    return await openDatabase(
      path,
      version: AppConstants.databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
      onConfigure: _onConfigure,
    );
  }

  Future<void> _onConfigure(Database db) async {
    // Enable foreign keys
    await db.execute('PRAGMA foreign_keys = ON');
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute(DatabaseTables.createCategoriesTable);
    await db.execute(DatabaseTables.createTransactionsTable);
    await db.execute(DatabaseTables.createMonthlyConfigsTable);

    for (final indexQuery in DatabaseTables.createIndexes) {
      await db.execute(indexQuery);
    }

    // Seed default categories
    await _seedDefaultCategories(db);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Safe migration: Add Snacks category without touching existing categories or transactions
      final now = DateTime.now().toIso8601String();
      await db.execute('''
        INSERT OR IGNORE INTO ${DatabaseTables.categories} 
        (id, name, icon, color, type, is_default, created_at)
        VALUES ('exp_snacks', 'Snacks', 'fastfood', 4294677052, 'expense', 1, '$now');
      ''');
    }
  }

  Future<void> _seedDefaultCategories(Database db) async {
    final now = DateTime.now().toIso8601String();

    final defaultCategories = [
      // Expense categories
      {
        'id': 'exp_food',
        'name': 'Food & Dining',
        'icon': 'restaurant',
        'color': 0xFFEF4444, // Red
        'type': 'expense',
        'is_default': 1,
        'created_at': now,
      },
      {
        'id': 'exp_snacks',
        'name': 'Snacks',
        'icon': 'fastfood',
        'color': 0xFFFB923C, // Vibrant Orange
        'type': 'expense',
        'is_default': 1,
        'created_at': now,
      },
      {
        'id': 'exp_travel',
        'name': 'Travel & Transit',
        'icon': 'directions_car',
        'color': 0xFF3B82F6, // Blue
        'type': 'expense',
        'is_default': 1,
        'created_at': now,
      },
      {
        'id': 'exp_shopping',
        'name': 'Shopping',
        'icon': 'shopping_bag',
        'color': 0xFF8B5CF6, // Purple
        'type': 'expense',
        'is_default': 1,
        'created_at': now,
      },
      {
        'id': 'exp_bills',
        'name': 'Bills & Utilities',
        'icon': 'receipt_long',
        'color': 0xFFF59E0B, // Amber
        'type': 'expense',
        'is_default': 1,
        'created_at': now,
      },
      {
        'id': 'exp_entertainment',
        'name': 'Entertainment',
        'icon': 'movie',
        'color': 0xFFEC4899, // Pink
        'type': 'expense',
        'is_default': 1,
        'created_at': now,
      },
      {
        'id': 'exp_health',
        'name': 'Health & Medical',
        'icon': 'local_hospital',
        'color': 0xFF10B981, // Emerald
        'type': 'expense',
        'is_default': 1,
        'created_at': now,
      },
      {
        'id': 'exp_education',
        'name': 'Education',
        'icon': 'school',
        'color': 0xFF6366F1, // Indigo
        'type': 'expense',
        'is_default': 1,
        'created_at': now,
      },
      {
        'id': 'exp_other',
        'name': 'Other Expense',
        'icon': 'more_horiz',
        'color': 0xFF64748B, // Slate
        'type': 'expense',
        'is_default': 1,
        'created_at': now,
      },

      // Income categories
      {
        'id': 'inc_salary',
        'name': 'Salary',
        'icon': 'account_balance_wallet',
        'color': 0xFF059669, // Emerald
        'type': 'income',
        'is_default': 1,
        'created_at': now,
      },
      {
        'id': 'inc_freelance',
        'name': 'Freelance',
        'icon': 'laptop_chromebook',
        'color': 0xFF0EA5E9, // Sky
        'type': 'income',
        'is_default': 1,
        'created_at': now,
      },
      {
        'id': 'inc_investment',
        'name': 'Investments & Returns',
        'icon': 'trending_up',
        'color': 0xFF14B8A6, // Teal
        'type': 'income',
        'is_default': 1,
        'created_at': now,
      },
      {
        'id': 'inc_gift',
        'name': 'Gift / Refund',
        'icon': 'card_giftcard',
        'color': 0xFFF97316, // Orange
        'type': 'income',
        'is_default': 1,
        'created_at': now,
      },
      {
        'id': 'inc_other',
        'name': 'Other Money Added',
        'icon': 'savings',
        'color': 0xFF10B981, // Emerald
        'type': 'income',
        'is_default': 1,
        'created_at': now,
      },
    ];

    final batch = db.batch();
    for (final cat in defaultCategories) {
      batch.insert(DatabaseTables.categories, cat);
    }
    await batch.commit(noResult: true);
  }

  Future<void> close() async {
    final db = _database;
    if (db != null && db.isOpen) {
      await db.close();
      _database = null;
    }
  }
}
