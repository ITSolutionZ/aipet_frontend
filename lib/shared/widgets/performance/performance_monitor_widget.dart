import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shared.dart';

/// 성능 모니터링 위젯
///
/// 실시간 성능 지표를 표시하는 위젯입니다.
class PerformanceMonitorWidget extends ConsumerStatefulWidget {
  final bool showDetails;
  final bool showChart;
  final VoidCallback? onIssueDetected;

  const PerformanceMonitorWidget({
    super.key,
    this.showDetails = false,
    this.showChart = false,
    this.onIssueDetected,
  });

  @override
  ConsumerState<PerformanceMonitorWidget> createState() =>
      _PerformanceMonitorWidgetState();
}

class _PerformanceMonitorWidgetState
    extends ConsumerState<PerformanceMonitorWidget> {
  PerformanceMonitorService? _monitorService;
  PerformanceMetric? _currentMetric;
  final List<PerformanceIssue> _recentIssues = [];

  @override
  void initState() {
    super.initState();
    _initializeMonitor();
  }

  void _initializeMonitor() {
    _monitorService = PerformanceMonitorService();
    _monitorService!.startMonitoring(interval: const Duration(seconds: 2));

    // 메트릭 스트림 구독
    _monitorService!.metricStream.listen((metric) {
      setState(() {
        _currentMetric = metric;
      });
    });

    // 이슈 스트림 구독
    _monitorService!.issueStream.listen((issue) {
      setState(() {
        _recentIssues.add(issue);
        if (_recentIssues.length > 5) {
          _recentIssues.removeAt(0);
        }
      });

      // 이슈 감지 콜백 호출
      widget.onIssueDetected?.call();

      // 심각한 이슈는 스낵바로 표시
      if (issue.severity == PerformanceIssueSeverity.critical) {
        _showIssueSnackBar(issue);
      }
    });
  }

  void _showIssueSnackBar(PerformanceIssue issue) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(issue.message),
        backgroundColor: _getIssueColor(issue.severity),
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: '확인',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  Color _getIssueColor(PerformanceIssueSeverity severity) {
    switch (severity) {
      case PerformanceIssueSeverity.info:
        return AppColors.pointBlue;
      case PerformanceIssueSeverity.warning:
        return AppColors.pointBrown;
      case PerformanceIssueSeverity.critical:
        return Colors.red;
    }
  }

  @override
  void dispose() {
    _monitorService?.stopMonitoring();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.medium),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeader(),
          const SizedBox(height: AppSpacing.sm),
          _buildMetrics(),
          if (widget.showDetails) ...[
            const SizedBox(height: AppSpacing.sm),
            _buildDetails(),
          ],
          if (_recentIssues.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            _buildIssues(),
          ],
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        const Icon(Icons.speed, color: AppColors.pointBrown, size: 20),
        const SizedBox(width: AppSpacing.xs),
        Text(
          '성능 모니터',
          style: AppFonts.bodyMedium.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.pointDark,
          ),
        ),
        const Spacer(),
        if (_currentMetric != null)
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xs,
              vertical: 2,
            ),
            decoration: BoxDecoration(
              color: _getPerformanceColor(),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              _getPerformanceStatus(),
              style: AppFonts.bodySmall.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildMetrics() {
    if (_currentMetric == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Row(
      children: [
        Expanded(
          child: _buildMetricCard(
            '메모리',
            '${_currentMetric!.memoryUsage.toStringAsFixed(1)}MB',
            Icons.memory,
            _getMemoryColor(),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _buildMetricCard(
            'FPS',
            _currentMetric!.frameRate.toStringAsFixed(0),
            Icons.speed,
            _getFrameRateColor(),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _buildMetricCard(
            'CPU',
            '${_currentMetric!.cpuUsage.toStringAsFixed(1)}%',
            Icons.memory_outlined,
            _getCpuColor(),
          ),
        ),
      ],
    );
  }

  Widget _buildMetricCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadius.small),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(height: AppSpacing.xs),
          Text(
            title,
            style: AppFonts.bodySmall.copyWith(
              color: AppColors.pointDark,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            value,
            style: AppFonts.bodyMedium.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '상세 정보',
          style: AppFonts.bodyMedium.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.pointDark,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          '위젯 리빌드: ${_currentMetric?.widgetRebuilds ?? 0}회',
          style: AppFonts.bodySmall.copyWith(color: AppColors.pointGray),
        ),
        Text(
          '마지막 업데이트: ${_currentMetric?.timestamp.toString().substring(11, 19) ?? 'N/A'}',
          style: AppFonts.bodySmall.copyWith(color: AppColors.pointGray),
        ),
      ],
    );
  }

  Widget _buildIssues() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '최근 이슈',
          style: AppFonts.bodyMedium.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.pointDark,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        ..._recentIssues.map((issue) => _buildIssueItem(issue)),
      ],
    );
  }

  Widget _buildIssueItem(PerformanceIssue issue) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.xs),
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: _getIssueColor(issue.severity).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadius.small),
        border: Border.all(
          color: _getIssueColor(issue.severity).withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            _getIssueIcon(issue.type),
            color: _getIssueColor(issue.severity),
            size: 16,
          ),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: Text(
              issue.message,
              style: AppFonts.bodySmall.copyWith(color: AppColors.pointDark),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIssueIcon(PerformanceIssueType type) {
    switch (type) {
      case PerformanceIssueType.highMemoryUsage:
        return Icons.memory;
      case PerformanceIssueType.lowFrameRate:
        return Icons.speed;
      case PerformanceIssueType.highCpuUsage:
        return Icons.memory_outlined;
      case PerformanceIssueType.excessiveWidgetRebuilds:
        return Icons.refresh;
    }
  }

  Color _getPerformanceColor() {
    if (_currentMetric == null) return AppColors.pointGray;

    if (_currentMetric!.memoryUsage > 100 || _currentMetric!.frameRate < 30) {
      return Colors.red;
    } else if (_currentMetric!.memoryUsage > 80 ||
        _currentMetric!.frameRate < 45) {
      return AppColors.pointBrown;
    } else {
      return AppColors.pointGreen;
    }
  }

  String _getPerformanceStatus() {
    if (_currentMetric == null) return '대기 중';

    if (_currentMetric!.memoryUsage > 100 || _currentMetric!.frameRate < 30) {
      return '위험';
    } else if (_currentMetric!.memoryUsage > 80 ||
        _currentMetric!.frameRate < 45) {
      return '주의';
    } else {
      return '정상';
    }
  }

  Color _getMemoryColor() {
    if (_currentMetric == null) return AppColors.pointGray;

    if (_currentMetric!.memoryUsage > 100) {
      return Colors.red;
    } else if (_currentMetric!.memoryUsage > 80) {
      return AppColors.pointBrown;
    } else {
      return AppColors.pointGreen;
    }
  }

  Color _getFrameRateColor() {
    if (_currentMetric == null) return AppColors.pointGray;

    if (_currentMetric!.frameRate < 30) {
      return Colors.red;
    } else if (_currentMetric!.frameRate < 45) {
      return AppColors.pointBrown;
    } else {
      return AppColors.pointGreen;
    }
  }

  Color _getCpuColor() {
    if (_currentMetric == null) return AppColors.pointGray;

    if (_currentMetric!.cpuUsage > 80) {
      return Colors.red;
    } else if (_currentMetric!.cpuUsage > 60) {
      return AppColors.pointBrown;
    } else {
      return AppColors.pointGreen;
    }
  }
}
