import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:global_experts/global_experts.dart';
import 'package:home/home.dart';
import 'package:rooms/rooms.dart';
import 'package:settings/settings.dart';
import 'package:whiteboard_planner/src/widget/dependencies_scope.dart';
import 'package:whiteboard_planner/src/widget/media_query_override.dart';

/// Entry point for the application that uses [MaterialApp].
class MaterialContext extends StatelessWidget {
  const MaterialContext({super.key});

  /// This global key is needed for Flutter to work properly
  /// when Widgets Inspector is enabled.
  static final _globalKey = GlobalKey(debugLabel: 'MaterialContext');

  @override
  Widget build(BuildContext context) {
    final dependencies = DependenciesScope.of(context);

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => RoomsBloc(
            repository: dependencies.roomRepository,
          )..add(const RoomsLoadRequested()),
        ),
        BlocProvider(
          create: (_) => GlobalExpertsBloc(
            repository: dependencies.globalExpertRepository,
          )..add(const GlobalExpertsLoadRequested()),
        ),
      ],
      child: SettingsBuilder(
        builder: (context, settings) {
          final themeMode = settings.general.themeMode;
          final seedColor = settings.general.seedColor;
          final locale = settings.general.locale;

          final materialThemeMode = switch (themeMode) {
            ThemeModeVO.system => ThemeMode.system,
            ThemeModeVO.light => ThemeMode.light,
            ThemeModeVO.dark => ThemeMode.dark,
          };

          final darkTheme = ThemeData(colorSchemeSeed: seedColor, brightness: Brightness.dark);
          final lightTheme = ThemeData(colorSchemeSeed: seedColor, brightness: Brightness.light);
          return MaterialApp(
            theme: lightTheme,
            darkTheme: darkTheme,
            themeMode: materialThemeMode,
            locale: locale,
            home: const HomeScreen(),
            builder: (context, child) {
              return KeyedSubtree(
                key: _globalKey,
                child: MediaQueryRootOverride(child: child!),
              );
            },
          );
        },
      ),
    );
  }
}
