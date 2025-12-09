import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:water_billing_app/core/database/database_helper.dart';
import 'package:water_billing_app/features/settings/data/data_source/settings_local_data_source.dart';
import 'package:water_billing_app/features/settings/domain/usecases/update_unit_price.dart';

/// ✅ مزود مصدر البيانات للإعدادات
final settingsDataSourceProvider = Provider<SettingsLocalDataSource>((ref) {
  return SettingsLocalDataSource(databaseHelper: DatabaseHelper.instance);
});

/// ✅ مزود use case لتحديث سعر الوحدة
final updateUnitPriceProvider = Provider<UpdateUnitPrice>((ref) {
  return UpdateUnitPrice(dataSource: ref.read(settingsDataSourceProvider));
});

/// ✅ المزود الرئيسي للإعدادات
final settingsProvider = StateNotifierProvider<SettingsNotifier, AsyncValue<double>>(
  (ref) => SettingsNotifier(ref),
);

class SettingsNotifier extends StateNotifier<AsyncValue<double>> {
  final Ref ref;

  SettingsNotifier(this.ref) : super(const AsyncValue.loading()) {
    loadUnitPrice();
  }

  Future<void> loadUnitPrice() async {
    try {
      final dataSource = ref.read(settingsDataSourceProvider);
      final unitPrice = await dataSource.getUnitPrice();
      state = AsyncValue.data(unitPrice);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updateUnitPrice(double unitPrice) async {
    try {
      state = const AsyncValue.loading();
      await ref.read(updateUnitPriceProvider)(unitPrice);
      state = AsyncValue.data(unitPrice);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}