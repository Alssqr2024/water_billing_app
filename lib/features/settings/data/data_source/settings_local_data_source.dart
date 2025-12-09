import 'package:water_billing_app/core/database/database_helper.dart';

class SettingsLocalDataSource {
  final DatabaseHelper databaseHelper;

  SettingsLocalDataSource({required this.databaseHelper});

  Future<String?> getSetting(String key) async {
    final db = await databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'settings',
      where: 'key = ?',
      whereArgs: [key],
    );
    
    if (maps.isEmpty) return null;
    return maps.first['value'] as String;
  }

  Future<void> setSetting(String key, String value) async {
    final db = await databaseHelper.database;
    
    // Check if setting exists
    final existing = await getSetting(key);
    
    if (existing == null) {
      // Insert new setting
      await db.insert('settings', {
        'key': key,
        'value': value,
      });
    } else {
      // Update existing setting
      await db.update(
        'settings',
        {'value': value},
        where: 'key = ?',
        whereArgs: [key],
      );
    }
  }

  Future<double> getUnitPrice() async {
    final unitPrice = await getSetting('unit_price');
    return double.tryParse(unitPrice ?? '2.0') ?? 2.0;
  }

  Future<void> setUnitPrice(double unitPrice) async {
    await setSetting('unit_price', unitPrice.toString());
  }
}