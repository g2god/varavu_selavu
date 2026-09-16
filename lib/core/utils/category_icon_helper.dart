import 'package:flutter/material.dart';

class CategoryIconHelper {
  CategoryIconHelper._();

  static IconData getIconData(String? iconName) {
    switch (iconName?.toLowerCase()) {
      case 'restaurant':
      case 'food':
        return Icons.restaurant_rounded;
      case 'fastfood':
      case 'snacks':
        return Icons.fastfood_rounded;
      case 'local_cafe':
      case 'coffee':
        return Icons.local_cafe_rounded;
      case 'directions_car':
      case 'travel':
        return Icons.directions_car_rounded;
      case 'shopping_bag':
      case 'shopping':
        return Icons.shopping_bag_outlined;
      case 'receipt_long':
      case 'bills':
        return Icons.receipt_long_outlined;
      case 'movie':
      case 'entertainment':
        return Icons.movie_creation_outlined;
      case 'local_hospital':
      case 'health':
        return Icons.favorite_border_rounded;
      case 'school':
      case 'education':
        return Icons.school_outlined;
      case 'fitness_center':
      case 'gym':
        return Icons.fitness_center_rounded;
      case 'pets':
        return Icons.pets_rounded;
      case 'flight':
        return Icons.flight_takeoff_rounded;
      case 'home':
        return Icons.home_rounded;
      case 'local_grocery_store':
      case 'groceries':
        return Icons.local_grocery_store_rounded;
      case 'account_balance_wallet':
      case 'salary':
        return Icons.account_balance_wallet_outlined;
      case 'laptop_chromebook':
      case 'freelance':
        return Icons.laptop_chromebook_rounded;
      case 'trending_up':
      case 'investment':
        return Icons.trending_up_rounded;
      case 'card_giftcard':
      case 'gift':
        return Icons.card_giftcard_rounded;
      case 'savings':
        return Icons.savings_outlined;
      default:
        return Icons.category_outlined;
    }
  }

  static const List<Map<String, dynamic>> availableIcons = [
    {'name': 'fastfood', 'icon': Icons.fastfood_rounded, 'label': 'Snacks'},
    {'name': 'restaurant', 'icon': Icons.restaurant_rounded, 'label': 'Food'},
    {'name': 'local_cafe', 'icon': Icons.local_cafe_rounded, 'label': 'Coffee'},
    {'name': 'local_grocery_store', 'icon': Icons.local_grocery_store_rounded, 'label': 'Groceries'},
    {'name': 'shopping_bag', 'icon': Icons.shopping_bag_outlined, 'label': 'Shopping'},
    {'name': 'directions_car', 'icon': Icons.directions_car_rounded, 'label': 'Travel'},
    {'name': 'receipt_long', 'icon': Icons.receipt_long_outlined, 'label': 'Bills'},
    {'name': 'movie', 'icon': Icons.movie_creation_outlined, 'label': 'Entertainment'},
    {'name': 'local_hospital', 'icon': Icons.favorite_border_rounded, 'label': 'Health'},
    {'name': 'fitness_center', 'icon': Icons.fitness_center_rounded, 'label': 'Fitness'},
    {'name': 'school', 'icon': Icons.school_outlined, 'label': 'Education'},
    {'name': 'home', 'icon': Icons.home_rounded, 'label': 'Home'},
    {'name': 'pets', 'icon': Icons.pets_rounded, 'label': 'Pets'},
    {'name': 'flight', 'icon': Icons.flight_takeoff_rounded, 'label': 'Travel/Flight'},
    {'name': 'savings', 'icon': Icons.savings_outlined, 'label': 'Savings'},
    {'name': 'card_giftcard', 'icon': Icons.card_giftcard_rounded, 'label': 'Gift'},
    {'name': 'account_balance_wallet', 'icon': Icons.account_balance_wallet_outlined, 'label': 'Income'},
    {'name': 'trending_up', 'icon': Icons.trending_up_rounded, 'label': 'Investment'},
    {'name': 'laptop_chromebook', 'icon': Icons.laptop_chromebook_rounded, 'label': 'Work'},
    {'name': 'category', 'icon': Icons.category_outlined, 'label': 'General'},
  ];
}
