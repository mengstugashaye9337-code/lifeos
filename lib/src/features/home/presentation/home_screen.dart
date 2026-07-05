import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lifeos/src/core/routing/router.dart';
import 'package:lifeos/src/features/auth/application/auth_provider.dart';
import 'package:lifeos/src/features/home/application/ai_briefing_provider.dart';
import 'package:lifeos/src/features/home/application/dashboard_provider.dart';
import 'package:lifeos/src/features/home/domain/dashboard_summary.dart';
import 'package:lifeos/src/services/permission_handler.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      requestNotificationPermissionsIfNeeded(context, ref);

      // Auto-generate briefing on first load if not cached
      ref.read(aiBriefingProvider.notifier).generate();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final user = authState.value;

    return Scaffold(
      appBar: AppBar(
        title: const Text('LifeOS'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push(AppRoutes.settings),
          ),
        ],
      ),
      body: RefreshIndicator(
        // Pull to refresh — regenerates AI briefing and refreshes dashboard
        onRefresh: () async {
          ref.invalidate(dashboardProvider);
          // Force regenerate AI briefing on manual refresh
          ref.invalidate(aiBriefingProvider);
          await Future.delayed(const Duration(milliseconds: 300));
          if (mounted) {
            ref.read(aiBriefingProvider.notifier).generate();
          }
        },
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          children: [
            // ── Greeting ───────────────────────────────────────────────
            _GreetingSection(displayName: user?.displayName ?? 'there'),
            const SizedBox(height: 16),

            // ── AI Briefing ────────────────────────────────────────────
            const _AiBriefingCard(),
            const SizedBox(height: 16),

            // ── Dashboard summary ──────────────────────────────────────
            const _DashboardSection(),
            const SizedBox(height: 24),

            // ── Navigation tiles ───────────────────────────────────────
            const _SectionLabel('Quick Access'),
            const SizedBox(height: 8),
            _FeatureTile(
              icon: Icons.check_circle_outline,
              title: 'Tasks',
              subtitle: 'Manage your to-dos',
              onTap: () => context.push(AppRoutes.tasks),
            ),
            _FeatureTile(
              icon: Icons.loop_rounded,
              title: 'Habits',
              subtitle: 'Build streaks, track consistency',
              onTap: () => context.push(AppRoutes.habits),
            ),
            _FeatureTile(
              icon: Icons.notes_outlined,
              title: 'Notes',
              subtitle: 'Capture your thoughts',
              onTap: () => context.push(AppRoutes.notes),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Greeting section
// ---------------------------------------------------------------------------

class _GreetingSection extends StatelessWidget {
  final String displayName;
  const _GreetingSection({required this.displayName});

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$_greeting, $displayName 👋',
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          DateFormat('EEEE, MMMM d').format(DateTime.now()),
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.outline,
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// AI Briefing card
// ---------------------------------------------------------------------------

class _AiBriefingCard extends ConsumerWidget {
  const _AiBriefingCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final briefingState = ref.watch(aiBriefingProvider);
    // final color = Theme.of(context).colorScheme.surfaceContainerHighest;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: briefingState.when(
          loading: () => const _BriefingLoadingState(),
          error: (_, __) => _BriefingErrorState(
            onRetry: () => ref.read(aiBriefingProvider.notifier).generate(),
          ),
          data: (briefing) {
            // Empty string = user dismissed today
            if (briefing != null && briefing.isEmpty) {
              return const SizedBox.shrink();
            }

            // null = not yet generated (shouldn't happen — initState generates)
            if (briefing == null) {
              return _BriefingEmptyState(
                onGenerate: () =>
                    ref.read(aiBriefingProvider.notifier).generate(),
              );
            }

            // Has briefing — show it
            return _BriefingContent(
              briefing: briefing,
              onDismiss: () => ref.read(aiBriefingProvider.notifier).dismiss(),
            );
          },
        ),
      ),
    );
  }
}

class _BriefingLoadingState extends StatelessWidget {
  const _BriefingLoadingState();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          'Getting your daily briefing...',
          style: TextStyle(color: Theme.of(context).colorScheme.outline),
        ),
      ],
    );
  }
}

class _BriefingErrorState extends StatelessWidget {
  final VoidCallback onRetry;
  const _BriefingErrorState({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          Icons.wifi_off_outlined,
          color: Theme.of(context).colorScheme.outline,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            'Could not load briefing.',
            style: TextStyle(color: Theme.of(context).colorScheme.outline),
          ),
        ),
        TextButton(onPressed: onRetry, child: const Text('Retry')),
      ],
    );
  }
}

class _BriefingEmptyState extends StatelessWidget {
  final VoidCallback onGenerate;
  const _BriefingEmptyState({required this.onGenerate});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.auto_awesome_outlined, color: Colors.deepPurple),
        const SizedBox(width: 12),
        const Expanded(child: Text('Get your AI daily briefing')),
        TextButton(onPressed: onGenerate, child: const Text('Generate')),
      ],
    );
  }
}

class _BriefingContent extends StatelessWidget {
  final String briefing;
  final VoidCallback onDismiss;
  const _BriefingContent({required this.briefing, required this.onDismiss});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.auto_awesome, color: Colors.deepPurple, size: 18),
            const SizedBox(width: 8),
            Text(
              'AI Briefing',
              style: Theme.of(
                context,
              ).textTheme.labelLarge?.copyWith(color: Colors.deepPurple),
            ),
            const Spacer(),
            GestureDetector(
              onTap: onDismiss,
              child: Icon(
                Icons.close,
                size: 18,
                color: Theme.of(context).colorScheme.outline,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Text(briefing, style: Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Dashboard section — watches dashboardProvider
// ---------------------------------------------------------------------------

class _DashboardSection extends ConsumerWidget {
  const _DashboardSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashAsync = ref.watch(dashboardProvider);

    return dashAsync.when(
      loading: () => const _DashboardSkeletonCard(),
      error: (_, __) => const SizedBox.shrink(),
      data: (summary) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionLabel('Today\'s Overview'),
          const SizedBox(height: 8),
          _TaskSummaryCard(summary: summary),
          const SizedBox(height: 12),
          _HabitSummaryCard(summary: summary),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Task summary card
// ---------------------------------------------------------------------------

class _TaskSummaryCard extends StatelessWidget {
  final DashboardSummary summary;
  const _TaskSummaryCard({required this.summary});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(
                  Icons.check_circle_outline,
                  color: colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Tasks',
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                if (summary.hasOverdueTasks)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme.errorContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${summary.overdueTasksCount} overdue',
                      style: TextStyle(
                        fontSize: 11,
                        color: colorScheme.onErrorContainer,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),

            // Stats row
            Row(
              children: [
                _StatChip(
                  label: 'Pending',
                  value: '${summary.pendingTasksCount}',
                  color: colorScheme.primary,
                ),
                const SizedBox(width: 8),
                _StatChip(
                  label: 'Done today',
                  value: '${summary.completedTodayTasksCount}',
                  color: Colors.green.shade600,
                ),
              ],
            ),

            // Due today list
            if (summary.dueTodayTaskTitles.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                'Due today:',
                style: Theme.of(
                  context,
                ).textTheme.labelSmall?.copyWith(color: colorScheme.outline),
              ),
              const SizedBox(height: 4),
              ...summary.dueTodayTaskTitles.map(
                (title) => Padding(
                  padding: const EdgeInsets.only(bottom: 2),
                  child: Row(
                    children: [
                      Icon(Icons.circle, size: 6, color: colorScheme.primary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          title,
                          style: Theme.of(context).textTheme.bodySmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Habit summary card
// ---------------------------------------------------------------------------

class _HabitSummaryCard extends StatelessWidget {
  final DashboardSummary summary;
  const _HabitSummaryCard({required this.summary});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final completionRate = summary.habitCompletionRate;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(Icons.loop_rounded, color: colorScheme.primary, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Habits',
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                if (summary.allHabitsDoneToday)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'All done! 🎉',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.green.shade800,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),

            // Progress bar
            if (summary.totalHabitsCount > 0) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: completionRate,
                  minHeight: 8,
                  backgroundColor: colorScheme.surfaceContainerHighest,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    summary.allHabitsDoneToday
                        ? Colors.green.shade600
                        : colorScheme.primary,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${summary.completedTodayHabitsCount} of '
                '${summary.totalHabitsCount} completed',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: colorScheme.outline),
              ),
            ],

            const SizedBox(height: 12),

            // Stats row
            Row(
              children: [
                _StatChip(
                  label: 'Remaining',
                  value: '${summary.pendingTodayHabitsCount}',
                  color: colorScheme.primary,
                ),
                const SizedBox(width: 8),
                if (summary.bestStreak > 0)
                  _StatChip(
                    label: 'Best streak',
                    value: '🔥 ${summary.bestStreak}d',
                    color: Colors.orange.shade700,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Skeleton loading card — shown while dashboard loads
// ---------------------------------------------------------------------------

class _DashboardSkeletonCard extends StatelessWidget {
  const _DashboardSkeletonCard();

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.surfaceContainerHighest;
    return Column(
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(height: 16, width: 80, color: color),
                const SizedBox(height: 12),
                Container(height: 12, width: 200, color: color),
                const SizedBox(height: 8),
                Container(height: 12, width: 150, color: color),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(height: 16, width: 80, color: color),
                const SizedBox(height: 12),
                Container(height: 8, width: double.infinity, color: color),
                const SizedBox(height: 8),
                Container(height: 12, width: 120, color: color),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Shared small widgets
// ---------------------------------------------------------------------------

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _StatChip({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color,
              fontSize: 16,
            ),
          ),
          Text(
            label,
            style: TextStyle(fontSize: 10, color: color.withValues(alpha: 0.8)),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.labelLarge?.copyWith(
        color: Theme.of(context).colorScheme.outline,
        letterSpacing: 0.5,
      ),
    );
  }
}

class _FeatureTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _FeatureTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icon, size: 28),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
