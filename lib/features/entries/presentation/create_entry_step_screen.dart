import 'package:flutter/material.dart';

import '../../../core/navigation/app_routes.dart';
import 'entries_state_scope.dart';

enum CreateEntryStep {
  situation(
    number: 1,
    route: AppRoutes.createSituation,
    title: 'Что происходит?',
    fieldLabel: 'Ситуация',
    nextRoute: AppRoutes.createThoughts,
  ),
  thoughts(
    number: 2,
    route: AppRoutes.createThoughts,
    title: 'О чем Вы думаете?',
    fieldLabel: 'Мысли',
    nextRoute: AppRoutes.createBody,
  ),
  body(
    number: 3,
    route: AppRoutes.createBody,
    title: 'Что Вы ощущаете в теле?',
    fieldLabel: 'Телесные ощущения',
    nextRoute: AppRoutes.createConsequences,
  ),
  consequences(
    number: 4,
    route: AppRoutes.createConsequences,
    title: 'Как это мешает жить?',
    fieldLabel: 'Последствия',
    nextRoute: AppRoutes.createWithoutProblem,
  ),
  withoutProblem(
    number: 5,
    route: AppRoutes.createWithoutProblem,
    title: 'Что бы Вы делали без проблемы?',
    fieldLabel: 'Без проблемы',
  );

  const CreateEntryStep({
    required this.number,
    required this.route,
    required this.title,
    required this.fieldLabel,
    this.nextRoute,
  });

  final int number;
  final String route;
  final String title;
  final String fieldLabel;
  final String? nextRoute;
}

class CreateEntryStepScreen extends StatefulWidget {
  const CreateEntryStepScreen({
    required this.step,
    super.key,
  });

  final CreateEntryStep step;

  @override
  State<CreateEntryStepScreen> createState() => _CreateEntryStepScreenState();
}

class _CreateEntryStepScreenState extends State<CreateEntryStepScreen> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _controller.text = _valueForStep();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final step = widget.step;
    final isFirstStep = step == CreateEntryStep.situation;
    final canContinue = !isFirstStep || _controller.text.trim().isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: _handleBack),
        title: Text('Шаг ${step.number}'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          LinearProgressIndicator(value: step.number / 5),
          const SizedBox(height: 24),
          Text(
            step.title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _controller,
            minLines: 6,
            maxLines: 10,
            decoration: InputDecoration(
              alignLabelWithHint: true,
              border: const OutlineInputBorder(),
              labelText: step.fieldLabel,
            ),
            onChanged: (value) {
              _saveValue(value);
              setState(() {});
            },
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.all(16),
        child: FilledButton(
          onPressed: canContinue ? _handleNext : null,
          child: Text(step.nextRoute == null ? 'Завершить анализ' : 'Далее'),
        ),
      ),
    );
  }

  String _valueForStep() {
    final draft = EntriesStateScope.of(context).draft;
    return switch (widget.step) {
      CreateEntryStep.situation => draft.situation,
      CreateEntryStep.thoughts => draft.thoughts,
      CreateEntryStep.body => draft.bodyFeelings,
      CreateEntryStep.consequences => draft.consequences,
      CreateEntryStep.withoutProblem => draft.withoutProblem,
    };
  }

  void _saveValue(String value) {
    final state = EntriesStateScope.of(context);
    switch (widget.step) {
      case CreateEntryStep.situation:
        state.updateDraft(situation: value);
      case CreateEntryStep.thoughts:
        state.updateDraft(thoughts: value);
      case CreateEntryStep.body:
        state.updateDraft(bodyFeelings: value);
      case CreateEntryStep.consequences:
        state.updateDraft(consequences: value);
      case CreateEntryStep.withoutProblem:
        state.updateDraft(withoutProblem: value);
    }
  }

  Future<void> _handleNext() async {
    final nextRoute = widget.step.nextRoute;
    if (nextRoute != null) {
      await Navigator.of(context).pushNamed(nextRoute);
      return;
    }

    await EntriesStateScope.of(context).saveDraftAsEntry();
    if (!mounted) {
      return;
    }
    Navigator.of(context).popUntil(ModalRoute.withName(AppRoutes.home));
  }

  void _handleBack() {
    if (widget.step == CreateEntryStep.situation) {
      EntriesStateScope.of(context).resetDraft();
    }
    Navigator.of(context).maybePop();
  }
}
