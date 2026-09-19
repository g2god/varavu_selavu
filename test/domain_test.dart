import 'package:flutter_test/flutter_test.dart';
import 'package:varavu_selavu/core/extensions/date_extensions.dart';
import 'package:varavu_selavu/core/extensions/number_extensions.dart';
import 'package:varavu_selavu/features/categories/domain/entities/category.dart';
import 'package:varavu_selavu/features/dashboard/domain/entities/monthly_summary.dart';
import 'package:varavu_selavu/features/transactions/domain/entities/transaction.dart';

void main() {
  group('Domain Calculation & Formula Verification', () {
    test('Available Balance = Starting Balance + Money Added - Expenses', () {
      const startingBalance = 25000.0;
      const totalIncome = 3000.0;
      const totalExpense = 11000.0;

      final availableBalance = startingBalance + totalIncome - totalExpense;

      expect(availableBalance, equals(17000.0));
    });

    test('Zero starting balance calculation with transactions', () {
      const startingBalance = 0.0;
      const totalIncome = 50000.0;
      const totalExpense = 15450.0;

      final availableBalance = startingBalance + totalIncome - totalExpense;

      expect(availableBalance, equals(34550.0));
    });

    test('Negative balance when expenses exceed total balance', () {
      const startingBalance = 5000.0;
      const totalIncome = 0.0;
      const totalExpense = 7000.0;

      final availableBalance = startingBalance + totalIncome - totalExpense;

      expect(availableBalance, equals(-2000.0));
    });

    test('MonthlySummary entity properties correctly reflect values', () {
      final summary = MonthlySummary(
        monthKey: '2026-09',
        startingBalance: 10000,
        totalIncome: 5000,
        totalExpense: 2000,
        availableBalance: 13000,
        categorySpendings: const [
          CategorySpending(
            categoryId: 'exp_food',
            categoryName: 'Food & Dining',
            categoryIcon: 'restaurant',
            categoryColor: 0xFFEF4444,
            totalAmount: 2000,
            percentage: 100.0,
            transactionCount: 2,
          ),
        ],
      );

      expect(summary.monthKey, equals('2026-09'));
      expect(summary.availableBalance, equals(13000));
      expect(summary.categorySpendings.length, equals(1));
      expect(summary.categorySpendings.first.percentage, equals(100.0));
    });
  });

  group('Extensions Verification', () {
    test('Number currency formatting with Indian locale grouping', () {
      const num amount1 = 17000;
      expect(amount1.toCurrency(), contains('17,000'));

      const num amount2 = 450.50;
      expect(amount2.toCurrency(decimalDigits: 2), contains('450.50'));
    });

    test('Compact currency formatting', () {
      const num lakh = 150000;
      expect(lakh.toCompactCurrency(), equals('₹ 1.5L'));

      const num crore = 25000000;
      expect(crore.toCompactCurrency(), equals('₹ 2.5Cr'));

      const num thousands = 5000;
      expect(thousands.toCompactCurrency(), equals('₹ 5.0k'));
    });

    test('Date extensions formatting & month keys', () {
      final date = DateTime(2026, 9, 15);
      expect(date.toYearMonthKey(), equals('2026-09'));
      expect(date.toIsoDateString(), equals('2026-09-15'));
      expect(date.toMonthYearString(), equals('September 2026'));
      expect(date.toShortMonthYearString(), equals('Sep 2026'));
    });
  });

  group('Domain Entities Type Safety', () {
    test('TransactionType enum parsing and db string', () {
      expect(TransactionType.fromString('expense'), equals(TransactionType.expense));
      expect(TransactionType.fromString('income'), equals(TransactionType.income));
      expect(TransactionType.fromString('INCOME'), equals(TransactionType.income));
      expect(TransactionType.expense.toDbString(), equals('expense'));
    });

    test('CategoryType enum parsing and db string', () {
      expect(CategoryType.fromString('expense'), equals(CategoryType.expense));
      expect(CategoryType.fromString('income'), equals(CategoryType.income));
      expect(CategoryType.expense.toDbString(), equals('expense'));
    });

    test('AppTransaction equality via Equatable', () {
      final now = DateTime(2026, 9, 15, 10, 30);
      final tx1 = AppTransaction(
        id: '1',
        type: TransactionType.expense,
        amount: 450,
        categoryId: 'exp_food',
        date: now,
        createdAt: now,
        updatedAt: now,
      );

      final tx2 = AppTransaction(
        id: '1',
        type: TransactionType.expense,
        amount: 450,
        categoryId: 'exp_food',
        date: now,
        createdAt: now,
        updatedAt: now,
      );

      expect(tx1, equals(tx2));
    });
  });
}
