import 'package:shared_preferences_web/shared_preferences_web.dart';

/// Registers Flutter Web plugin implementations omitted by tree shaking.
void registerAppWebPlugins() {
  SharedPreferencesPlugin.registerWith(null);
}
