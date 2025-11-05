import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


import '../../../../../shared/shared.dart';
import '../../../../../../features/scheduling/scheduling.dart';
import '../../controllers/alarm_time_settings_controller.dart';


/// アラーム時間設定セクション
///
/// カテゴリ別とイベントタイプ別の時間設定を提供
class AlarmTimeSettingsSection extends ConsumerWidget {
  final Function(BuildContext, String, TimeOfDay, Function(TimeOfDay))
      onSelectTime;

  const AlarmTimeSettingsSection({
    super.key,
    required this.onSelectTime,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final alarmState = ref.watch(alarmTimeSettingsControllerProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeaderComponent(title: 'アラーム時間設定'),
        const SizedBox(height: AppSpacing.lg),

        // ローディング状態
        if (alarmState.isLoading)
          _buildLoadingState()
        // エラー状態
        else if (alarmState.error != null)
          _buildErrorState(ref)
        // データ未ロード状態
        else if (alarmState.morningTime.hour == 0 &&
            alarmState.morningTime.minute == 0)
          _buildNotLoadedState()
        // 正常状態 - カテゴリ別セクション表示
        else
          ..._buildCategorySections(context, ref, alarmState),
      ],
    );
  }

  /// ローディング状態
  Widget _buildLoadingState() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: const Center(
        child: CircularProgressIndicator(
          color: AppColors.pointBrown,
        ),
      ),
    );
  }

  /// エラー状態
  Widget _buildErrorState(WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        children: [
          const Icon(
            Icons.error_outline,
            color: Colors.red,
            size: 48,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'アラーム時間設定の読み込みに失敗しました',
            style: AppFonts.bodyMedium.copyWith(
              color: Colors.red,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          ActionButton.secondary(
            text: '再試行',
            isEnabled: true,
            onPressed: () {
              ref
                  .read(alarmTimeSettingsControllerProvider.notifier)
                  .loadAlarmTimes('default_user_id');
            },
          ),
        ],
      ),
    );
  }

  /// データ未ロード状態
  Widget _buildNotLoadedState() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        children: [
          const Icon(
            Icons.schedule,
            color: AppColors.pointGray,
            size: 48,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'アラーム時間設定を読み込み中...',
            style: AppFonts.bodyMedium.copyWith(
              color: AppColors.pointGray,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          const CircularProgressIndicator(
            color: AppColors.pointBrown,
          ),
        ],
      ),
    );
  }

  /// カテゴリ別セクション構築
  List<Widget> _buildCategorySections(
    BuildContext context,
    WidgetRef ref,
    AlarmTimeSettingsState state,
  ) {
    return AlarmCategory.values.map(
      (category) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCategoryHeader(category),
            const SizedBox(height: AppSpacing.md),
            ..._buildEventTypeTimeTiles(context, ref, category, state),
            const SizedBox(height: AppSpacing.lg),
          ],
        );
      },
    ).toList();
  }

  /// カテゴリヘッダー
  Widget _buildCategoryHeader(AlarmCategory category) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          category.displayName,
          style: AppFonts.bodyLarge.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.pointBrown,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          category.description,
          style: AppFonts.bodySmall.copyWith(
            color: AppColors.pointGray,
            height: 1.3,
          ),
        ),
      ],
    );
  }

  /// イベントタイプ別時間タイル構築
  List<Widget> _buildEventTypeTimeTiles(
    BuildContext context,
    WidgetRef ref,
    AlarmCategory category,
    AlarmTimeSettingsState state,
  ) {
    return CalendarEventType.values
        .where((type) => type.alarmCategory == category)
        .map(
          (type) => Column(
            children: [
              _buildEventTypeTimeSettingTile(
                context,
                ref,
                type,
                state,
              ),
              const SizedBox(height: AppSpacing.md),
            ],
          ),
        )
        .toList();
  }

  /// イベントタイプ別時間設定タイル
  Widget _buildEventTypeTimeSettingTile(
    BuildContext context,
    WidgetRef ref,
    CalendarEventType eventType,
    AlarmTimeSettingsState state,
  ) {
    // デフォルト時間設定
    final defaultTime = _getDefaultTime(eventType, state);

    return _buildTimeSettingTile(
      title: '${eventType.emoji} ${eventType.displayName}',
      subtitle: '${eventType.displayName}アラーム時間',
      time: defaultTime,
      onTap: () => onSelectTime(
        context,
        '${eventType.displayName}時間',
        defaultTime,
        (time) {
          ref
              .read(alarmTimeSettingsControllerProvider.notifier)
              .selectTime(eventType.name, time);
        },
      ),
    );
  }

  /// デフォルト時間取得
  TimeOfDay _getDefaultTime(
    CalendarEventType eventType,
    AlarmTimeSettingsState state,
  ) {
    switch (eventType) {
      case CalendarEventType.feeding:
        return state.morningTime;
      case CalendarEventType.medication:
        return const TimeOfDay(hour: 9, minute: 0);
      case CalendarEventType.walking:
        return state.walkTime;
      case CalendarEventType.exercise:
        return const TimeOfDay(hour: 17, minute: 0);
      case CalendarEventType.system:
        return const TimeOfDay(hour: 10, minute: 0);
      default:
        return const TimeOfDay(hour: 9, minute: 0);
    }
  }

  /// 時間設定タイル
  Widget _buildTimeSettingTile({
    required String title,
    required String subtitle,
    required TimeOfDay time,
    required VoidCallback onTap,
  }) {
    return GlassCard(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: AppColors.pointBrown,
            borderRadius: BorderRadius.circular(AppSpacing.sm),
          ),
          child: Text(
            '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
        ),
        onTap: onTap,
      ),
    );
  }
}

