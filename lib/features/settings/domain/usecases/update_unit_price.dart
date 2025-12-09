import 'package:water_billing_app/features/settings/data/data_source/settings_local_data_source.dart';

class UpdateUnitPrice {
  final SettingsLocalDataSource dataSource;

  UpdateUnitPrice({required this.dataSource});

  Future<void> call(double unitPrice) async {
    await dataSource.setUnitPrice(unitPrice);
  }
}