import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/navigation/app_routes.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/app_scaffold.dart';
import '../../../shared/widgets/bottom_primary_button.dart';
import '../../../shared/widgets/hint_button.dart';
import '../../../shared/widgets/large_text_area.dart';
import '../../../shared/widgets/step_progress.dart';
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
  const CreateEntryStepScreen({required this.step, super.key});

  final CreateEntryStep step;

  @override
  State<CreateEntryStepScreen> createState() => _CreateEntryStepScreenState();
}

class _CreateEntryStepScreenState extends State<CreateEntryStepScreen> {
  late final TextEditingController _controller;
  bool _isSaving = false;
  bool _isConfirmedCanceling = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final value = _valueForStep();
    if (_controller.text != value) {
      _controller.text = value;
    }
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

    return PopScope(
      canPop: _isConfirmedCanceling || !_shouldConfirmCancel(),
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) {
          return;
        }
        final shouldCancel = await _confirmCancelCreation();
        if (shouldCancel && context.mounted) {
          setState(() => _isConfirmedCanceling = true);
          EntriesStateScope.of(context).resetDraft();
          Navigator.of(
            context,
          ).pushNamedAndRemoveUntil(AppRoutes.home, (route) => false);
        }
      },
      child: AppScaffold(
        title: 'Шаг ${step.number}',
        leading: BackButton(onPressed: _handleBack),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.screenPadding,
            12,
            AppSpacing.screenPadding,
            120,
          ),
          children: [
            StepProgress(currentStep: step.number),
            const SizedBox(height: 26),
            Text(
              step.title,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            Text(
              _descriptionForStep(step),
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 26),
            LargeTextArea(
              controller: _controller,
              label: 'Описание',
              hintText: _placeholderForStep(step),
              maxLength: step == CreateEntryStep.thoughts ? 1000 : null,
              onChanged: (value) {
                _saveValue(value);
                setState(() {});
              },
            ),
            const SizedBox(height: 18),
            Align(
              alignment: Alignment.centerRight,
              child: HintButton(onPressed: _showHint),
            ),
          ],
        ),
        bottomBar: BottomPrimaryButton(
          label: _isSaving
              ? 'Сохранение...'
              : step.nextRoute == null
              ? 'Завершить анализ'
              : 'Далее',
          icon: step.nextRoute == null
              ? Icons.check_circle_outline
              : Icons.arrow_forward,
          onPressed: canContinue && !_isSaving ? _handleNext : null,
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
        state.updateDraft(thoughts: value.characters.take(1000).toString());
      case CreateEntryStep.body:
        state.updateDraft(bodyFeelings: value);
      case CreateEntryStep.consequences:
        state.updateDraft(consequences: value);
      case CreateEntryStep.withoutProblem:
        state.updateDraft(withoutProblem: value);
    }
  }

  Future<void> _handleNext() async {
    HapticFeedback.lightImpact();
    final nextRoute = widget.step.nextRoute;
    if (nextRoute != null) {
      await Navigator.of(context).pushNamed(nextRoute);
      return;
    }

    if (_isSaving) {
      return;
    }
    setState(() => _isSaving = true);
    HapticFeedback.mediumImpact();

    try {
      await EntriesStateScope.of(context).saveDraftAsEntry();
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Запись успешно сохранена')));
      Navigator.of(context).popUntil(ModalRoute.withName(AppRoutes.home));
    } catch (_) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Не удалось сохранить запись')),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _handleBack() async {
    HapticFeedback.lightImpact();
    if (_shouldConfirmCancel()) {
      final shouldCancel = await _confirmCancelCreation();
      if (!shouldCancel || !mounted) {
        return;
      }
      setState(() => _isConfirmedCanceling = true);
      EntriesStateScope.of(context).resetDraft();
    }
    if (mounted) {
      if (_isConfirmedCanceling) {
        Navigator.of(
          context,
        ).pushNamedAndRemoveUntil(AppRoutes.home, (route) => false);
      } else {
        Navigator.of(context).maybePop();
      }
    }
  }

  bool _shouldConfirmCancel() {
    return widget.step == CreateEntryStep.situation &&
        EntriesStateScope.of(context).hasDraftChanges;
  }

  Future<bool> _confirmCancelCreation() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Отменить создание записи?'),
        content: const Text('Заполненный черновик будет потерян.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Продолжить'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Отменить'),
          ),
        ],
      ),
    );
    return confirmed == true;
  }

  void _showHint() {
    HapticFeedback.lightImpact();
    final hint = _hintForStep(widget.step);
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hint.title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                Text(
                  hint.content,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                if (hint.bullets.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  for (final bullet in hint.bullets)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Text(
                        '• $bullet',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ),
                ],
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Понятно'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

String _descriptionForStep(CreateEntryStep step) {
  return switch (step) {
    CreateEntryStep.situation =>
      'Опишите факты. Это может быть ситуация, когда вы хотите что-то начать, но не можете, или вам стало плохо просто сидя дома за смартфоном.',
    CreateEntryStep.thoughts =>
      'Постарайтесь быть честными с собой. Запишите всё, что приходит в голову.',
    CreateEntryStep.body =>
      'Оцените тонус мышц тела и лица, затем прислушайтесь к ощущениям внутри. Эмоции всегда отражаются в мышечном тонусе.',
    CreateEntryStep.consequences =>
      'Помеха — это потеря времени или препятствие к действию.',
    CreateEntryStep.withoutProblem =>
      'Представьте, что проблемы нет. Что бы вы делали?',
  };
}

String _placeholderForStep(CreateEntryStep step) {
  return switch (step) {
    CreateEntryStep.situation =>
      'Например: Начальник громко сказал, что отчет не готов, и бросил папку на стол...',
    CreateEntryStep.thoughts => 'Я думаю, что...',
    CreateEntryStep.body =>
      'Например: ком в горле, давящее чувство в груди, жар на лице, дрожь в руках...',
    CreateEntryStep.consequences =>
      'Например: я избегаю встреч с друзьями, я плохо сплю, я срываюсь на близких. Я чувствую постоянное напряжение в плечах...',
    CreateEntryStep.withoutProblem =>
      'Я бы чувствовал себя легче, занялся бы...',
  };
}

_StepHint _hintForStep(CreateEntryStep step) {
  return switch (step) {
    CreateEntryStep.situation => const _StepHint(
      title: 'Совет',
      content:
          'Опишите внешние обстоятельства. Например: "Сижу на диване, смотрю в телефон, нужно встать и пойти готовить, но не могу".',
    ),
    CreateEntryStep.thoughts => const _StepHint(
      title: 'Как описать мысли?',
      content: 'Если трудно осознать мысли:',
      bullets: [
        'Представьте, что объясняете другу причину своего состояния.',
        'Представьте себя героем комикса — что написано в "облачке" над вашей головой?',
      ],
    ),
    CreateEntryStep.body => const _StepHint(
      title: 'Как описать ощущения?',
      content:
          'Обратите внимание на напряжение в плечах, челюсти, лбу. Сжаты ли кулаки? Как дышится? Эмоции живут в теле.',
      bullets: [
        'Тонус (напряжение, расслабление)',
        'Текстура (колючее, мягкое)',
        'Движение (пульсация, вибрация)',
        'Вес (тяжесть, легкость)',
      ],
    ),
    CreateEntryStep.consequences => const _StepHint(
      title: 'Примеры заполнения',
      content: 'Можно описывать конкретные помехи:',
      bullets: [
        'Потерял 2 часа на тревогу',
        'Хотел пойти на встречу, но остался дома',
        'Не смог сосредоточиться на работе',
        'Сорвался на близких вместо разговора',
      ],
    ),
    CreateEntryStep.withoutProblem => const _StepHint(
      title: 'Пример',
      content:
          '"Если бы я не тревожился эти два часа, я бы почитал книгу или спокойно погулял".',
    ),
  };
}

class _StepHint {
  const _StepHint({
    required this.title,
    required this.content,
    this.bullets = const [],
  });

  final String title;
  final String content;
  final List<String> bullets;
}
