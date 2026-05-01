import 'package:flutter/material.dart';

import 'core/navigation/app_routes.dart';
import 'core/theme/app_theme.dart';
import 'features/entries/data/shared_preferences_entries_repository.dart';
import 'features/entries/domain/entries_repository.dart';
import 'features/entries/presentation/create_entry_step_screen.dart';
import 'features/entries/presentation/edit_entry_screen.dart';
import 'features/entries/presentation/entries_app_state.dart';
import 'features/entries/presentation/entries_state_scope.dart';
import 'features/entries/presentation/home_screen.dart';
import 'features/instructions/presentation/instructions_screen.dart';

class ProblemApp extends StatefulWidget {
  const ProblemApp({super.key, this.repository});

  final EntriesRepository? repository;

  @override
  State<ProblemApp> createState() => _ProblemAppState();
}

class _ProblemAppState extends State<ProblemApp> {
  late final EntriesAppState _entriesState;

  @override
  void initState() {
    super.initState();
    _entriesState = EntriesAppState(
      repository: widget.repository ?? SharedPreferencesEntriesRepository(),
    );
    _entriesState.loadEntries();
  }

  @override
  void dispose() {
    _entriesState.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return EntriesStateScope(
      state: _entriesState,
      child: MaterialApp(
        title: 'Problem?',
        debugShowCheckedModeBanner: false,
        theme: buildAppTheme(),
        darkTheme: buildAppDarkTheme(),
        themeMode: ThemeMode.system,
        initialRoute: AppRoutes.home,
        onGenerateRoute: _onGenerateRoute,
      ),
    );
  }

  Route<void> _onGenerateRoute(RouteSettings settings) {
    final routeName = settings.name ?? AppRoutes.home;
    final screen = switch (routeName) {
      AppRoutes.home => const HomeScreen(),
      AppRoutes.createSituation => const CreateEntryStepScreen(
        step: CreateEntryStep.situation,
      ),
      AppRoutes.createThoughts => const CreateEntryStepScreen(
        step: CreateEntryStep.thoughts,
      ),
      AppRoutes.createBody => const CreateEntryStepScreen(
        step: CreateEntryStep.body,
      ),
      AppRoutes.createConsequences => const CreateEntryStepScreen(
        step: CreateEntryStep.consequences,
      ),
      AppRoutes.createWithoutProblem => const CreateEntryStepScreen(
        step: CreateEntryStep.withoutProblem,
      ),
      AppRoutes.instructions => const InstructionsScreen(),
      _ when routeName.startsWith('${AppRoutes.editEntry}/') => EditEntryScreen(
        entryId: routeName.substring(AppRoutes.editEntry.length + 1),
      ),
      _ => const HomeScreen(),
    };

    return MaterialPageRoute<void>(builder: (_) => screen, settings: settings);
  }
}
