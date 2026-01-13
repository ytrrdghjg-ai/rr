import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ThemeState {
  final ThemeMode mode;
  final ThemeData light;
  final ThemeData dark;
  ThemeState({required this.mode, required this.light, required this.dark});
}

final themeProvider = StateNotifierProvider<ThemeController, ThemeState>((ref) {
  final seed = Colors.green;
  return ThemeController(seed);
});

class ThemeController extends StateNotifier<ThemeState> {
  ThemeController(Color seed)
      : super(
          ThemeState(
            mode: ThemeMode.system,
            light: ThemeData(useMaterial3: true, colorScheme: ColorScheme.fromSeed(seedColor: seed)),
            dark: ThemeData(useMaterial3: true, colorScheme: ColorScheme.fromSeed(seedColor: seed, brightness: Brightness.dark)),
          ),
        );

  void toggle() {
    state = ThemeState(
      mode: state.mode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark,
      light: state.light,
      dark: state.dark,
    );
  }
}
