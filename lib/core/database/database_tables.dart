class DatabaseTables {
  DatabaseTables._();

  static const String categories = 'categories';
  static const String transactions = 'transactions';
  static const String monthlyConfigs = 'monthly_configs';

  // Category columns
  static const String colCatId = 'id';
  static const String colCatName = 'name';
  static const String colCatIcon = 'icon';
  static const String colCatColor = 'color';
  static const String colCatType = 'type'; // 'expense' or 'income'
  static const String colCatIsDefault = 'is_default'; // 1 or 0
  static const String colCatCreatedAt = 'created_at';

  // Transaction columns
  static const String colTxId = 'id';
  static const String colTxType = 'type'; // 'expense' or 'income'
  static const String colTxAmount = 'amount'; // REAL
  static const String colTxCategoryId = 'category_id';
  static const String colTxDate = 'date'; // ISO-8601 string: YYYY-MM-DD
  static const String colTxNote = 'note';
  static const String colTxCreatedAt = 'created_at'; // ISO-8601
  static const String colTxUpdatedAt = 'updated_at'; // ISO-8601

  // Monthly Configuration columns (for starting balance and budget)
  static const String colMonthKey = 'month_key'; // e.g. "2026-09"
  static const String colStartingBalance = 'starting_balance'; // REAL
  static const String colBudget = 'budget'; // REAL
  static const String colMonthUpdatedAt = 'updated_at';

  static const String createCategoriesTable = '''
    CREATE TABLE $categories (
      $colCatId TEXT PRIMARY KEY,
      $colCatName TEXT NOT NULL,
      $colCatIcon TEXT NOT NULL,
      $colCatColor INTEGER NOT NULL,
      $colCatType TEXT NOT NULL,
      $colCatIsDefault INTEGER NOT NULL DEFAULT 1,
      $colCatCreatedAt TEXT NOT NULL
    );
  ''';

  static const String createTransactionsTable = '''
    CREATE TABLE $transactions (
      $colTxId TEXT PRIMARY KEY,
      $colTxType TEXT NOT NULL,
      $colTxAmount REAL NOT NULL,
      $colTxCategoryId TEXT NOT NULL,
      $colTxDate TEXT NOT NULL,
      $colTxNote TEXT,
      $colTxCreatedAt TEXT NOT NULL,
      $colTxUpdatedAt TEXT NOT NULL,
      FOREIGN KEY ($colTxCategoryId) REFERENCES $categories ($colCatId) ON DELETE RESTRICT
    );
  ''';

  static const String createMonthlyConfigsTable = '''
    CREATE TABLE $monthlyConfigs (
      $colMonthKey TEXT PRIMARY KEY,
      $colStartingBalance REAL NOT NULL DEFAULT 0.0,
      $colBudget REAL NOT NULL DEFAULT 0.0,
      $colMonthUpdatedAt TEXT NOT NULL
    );
  ''';

  static const List<String> createIndexes = [
    'CREATE INDEX idx_transactions_date ON $transactions ($colTxDate);',
    'CREATE INDEX idx_transactions_category ON $transactions ($colTxCategoryId);',
    'CREATE INDEX idx_transactions_type ON $transactions ($colTxType);',
  ];
}
