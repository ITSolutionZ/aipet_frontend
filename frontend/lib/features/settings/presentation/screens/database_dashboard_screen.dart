import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


import '../../../../shared/shared.dart';
/// 데이터베이스 시각화 대시보드 화면
class DatabaseDashboardScreen extends ConsumerStatefulWidget {
  const DatabaseDashboardScreen({super.key});

  @override
  ConsumerState<DatabaseDashboardScreen> createState() =>
      _DatabaseDashboardScreenState();
}

class _DatabaseDashboardScreenState
    extends ConsumerState<DatabaseDashboardScreen> {
  final DatabaseVisualizationService _dbService =
      DatabaseVisualizationService.instance;

  Map<String, dynamic>? _databaseStats;
  Map<String, dynamic>? _petDataStats;
  List<Map<String, dynamic>> _recentActivities = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDatabaseInfo();
  }

  Future<void> _loadDatabaseInfo() async {
    setState(() => _isLoading = true);

    try {
      final stats = await _dbService.getDatabaseStats();
      final petStats = await _dbService.getPetDataStats();
      final activities = await _dbService.getRecentActivities();

      setState(() {
        _databaseStats = stats;
        _petDataStats = petStats;
        _recentActivities = activities;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('データベース情報の読み込みに失敗しました: $e')));
      }
    }
  }

  /// 메뉴 액션 처리
  void _handleMenuAction(String action) async {
    switch (action) {
      case 'cleanup':
        await _performDataCleanup();
        break;
      case 'delete_all':
        await _deleteAllData();
        break;
    }
  }

  /// 데이터 정리 실행
  Future<void> _performDataCleanup() async {
    // 확인 다이얼로그 표시
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('データクリーンアップ'),
        content: const Text(
          '깨진 펫 이름과 중복 데이터를 정리하시겠습니까?\n'
          '이 작업은 되돌릴 수 없습니다.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('キャンセル'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
            child: const Text('実行'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      // 로딩 표시
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      try {
        final success = await DataCleanupService().performFullCleanup();

        if (mounted) {
          Navigator.pop(context); // 로딩 다이얼로그 닫기

          if (success) {
            // ✅ Shared SnackBarService 사용
            SnackBarService.showSuccess(context, 'データクリーンアップが完了しました');
            // 데이터 새로고침
            _loadDatabaseInfo();
          } else {
            // ✅ Shared SnackBarService 사용
            SnackBarService.showError(context, 'データクリーンアップ中にエラーが発生しました');
          }
        }
      } catch (e) {
        if (mounted) {
          Navigator.pop(context); // 로딩 다이얼로그 닫기
          // ✅ Shared SnackBarService 사용
          SnackBarService.showError(context, 'エラー: $e');
        }
      }
    }
  }

  /// 모든 데이터 삭제
  Future<void> _deleteAllData() async {
    // 확인 다이얼로그 표시
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('全データ削除'),
        content: const Text(
          'SQLiteデータベースとSharedPreferencesの全てのデータを削除しますか?\n'
          'この操作は元に戻せません。',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('キャンセル'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('削除'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      // 로딩 표시
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      try {
        // 1. SQLite 데이터베이스 모든 테이블 데이터 삭제
        final database = await LocalDatabaseService.instance.database;
        await database.delete('pets');
        await database.delete('user_profiles');
        await database.delete('walk_records');
        await database.delete('health_records');
        await database.delete('schedules');
        await database.delete('activities');
        await database.delete('pet_user_relations');
        await database.delete('ai_categories');
        await database.delete('ai_keywords');

        // 2. SharedPreferences 모든 데이터 삭제
        await LocalDataManager.instance.clearAllLocalData();

        if (mounted) {
          Navigator.pop(context); // 로딩 다이얼로그 닫기

          // ✅ Shared SnackBarService 사용
          SnackBarService.showSuccess(context, '全てのデータを削除しました');

          // 데이터 새로고침
          _loadDatabaseInfo();
        }
      } catch (e) {
        if (mounted) {
          Navigator.pop(context); // 로딩 다이얼로그 닫기
          // ✅ Shared SnackBarService 사용
          SnackBarService.showError(context, 'データ削除中にエラーが発生しました: $e');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pointOffWhite,
      appBar: AppBar(
        title: const Text('データベースダッシュボード'),
        backgroundColor: AppColors.pointBrown,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDatabaseInfo,
          ),
          PopupMenuButton<String>(
            onSelected: _handleMenuAction,
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'cleanup',
                child: Row(
                  children: [
                    Icon(Icons.cleaning_services, color: Colors.orange),
                    SizedBox(width: 8),
                    Text('データクリーンアップ'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'delete_all',
                child: Row(
                  children: [
                    Icon(Icons.delete_forever, color: Colors.red),
                    SizedBox(width: 8),
                    Text('全データ削除'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDatabaseInfoCard(),
                  const SizedBox(height: AppSpacing.lg),
                  _buildPetDataStatsCard(),
                  const SizedBox(height: AppSpacing.lg),
                  _buildTablesCard(),
                  const SizedBox(height: AppSpacing.lg),
                  _buildRecentActivitiesCard(),
                ],
              ),
            ),
    );
  }

  /// 데이터베이스 기본 정보 카드
  Widget _buildDatabaseInfoCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'データベース情報',
              style: AppFonts.titleLarge.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.pointDark,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            FutureBuilder<bool>(
              future: _dbService.databaseExists(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Row(
                    children: [
                      Icon(
                        snapshot.data! ? Icons.check_circle : Icons.error,
                        color: snapshot.data! ? Colors.green : Colors.red,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        snapshot.data!
                            ? 'データベースファイルが存在します'
                            : 'データベースファイルが見つかりません',
                        style: AppFonts.bodyMedium,
                      ),
                    ],
                  );
                }
                return const CircularProgressIndicator();
              },
            ),
            const SizedBox(height: AppSpacing.sm),
            FutureBuilder<int>(
              future: _dbService.getDatabaseSize(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  final sizeKB = (snapshot.data! / 1024).toStringAsFixed(2);
                  return Text(
                    'ファイルサイズ: $sizeKB KB',
                    style: AppFonts.bodyMedium,
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
      ),
    );
  }

  /// 펫 데이터 통계 카드
  Widget _buildPetDataStatsCard() {
    if (_petDataStats == null) return const SizedBox.shrink();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'ペットデータ統計',
              style: AppFonts.titleLarge.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.pointDark,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            _buildStatRow('総ペット数', '${_petDataStats!['totalPets']}'),
            _buildStatRow('アクティブペット数', '${_petDataStats!['activePets']}'),
            _buildStatRow('給餌記録数', '${_petDataStats!['totalFeedings']}'),
            _buildStatRow('散歩記録数', '${_petDataStats!['totalWalks']}'),
            _buildStatRow('健康記録数', '${_petDataStats!['totalHealthRecords']}'),
            _buildStatRow('AIチャット数', '${_petDataStats!['totalChats']}'),
            const SizedBox(height: AppSpacing.md),
            if (_petDataStats!['petTypes'] != null &&
                (_petDataStats!['petTypes'] as List).isNotEmpty) ...[
              Text(
                'ペットタイプ別統計',
                style: AppFonts.titleMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.pointDark,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              ...(_petDataStats!['petTypes'] as List).map<Widget>((type) {
                return _buildStatRow('${type['type']}', '${type['count']}匹');
              }),
            ],
          ],
        ),
      ),
    );
  }

  /// 테이블 정보 카드
  Widget _buildTablesCard() {
    if (_databaseStats == null) return const SizedBox.shrink();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'テーブル情報',
              style: AppFonts.titleLarge.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.pointDark,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            ..._databaseStats!.entries.map<Widget>((entry) {
              final tableName = entry.key;
              final tableData = entry.value as Map<String, dynamic>;
              final rowCount = tableData['rowCount'] as int;
              final columns = tableData['columns'] as int;

              return ExpansionTile(
                title: Text(
                  tableName,
                  style: AppFonts.titleMedium.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text('行数: $rowCount, 列数: $columns'),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'スキーマ情報',
                          style: AppFonts.titleSmall.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        ...(tableData['schema'] as List).map<Widget>((column) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2),
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 100,
                                  child: Text(
                                    column['name'],
                                    style: AppFonts.bodySmall.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.sm),
                                Text(column['type'], style: AppFonts.bodySmall),
                                const SizedBox(width: AppSpacing.sm),
                                if (column['notnull'] == 1)
                                  const Text(
                                    'NOT NULL',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.red,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                if (column['pk'] == 1)
                                  const Text(
                                    'PRIMARY KEY',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.blue,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  /// 최근 활동 카드
  Widget _buildRecentActivitiesCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '最近の活動',
              style: AppFonts.titleLarge.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.pointDark,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            if (_recentActivities.isEmpty)
              const Text('最近の活動がありません')
            else
              ..._recentActivities.take(10).map<Widget>((activity) {
                final type = activity['type'] as String;
                final timestamp =
                    activity['created_at'] ?? activity['timestamp'] ?? '';

                return ListTile(
                  leading: Icon(
                    _getActivityIcon(type),
                    color: _getActivityColor(type),
                  ),
                  title: Text(
                    _getActivityTitle(activity, type),
                    style: AppFonts.bodyMedium,
                  ),
                  subtitle: Text(
                    timestamp,
                    style: AppFonts.bodySmall.copyWith(
                      color: AppColors.pointGray,
                    ),
                  ),
                  dense: true,
                );
              }),
          ],
        ),
      ),
    );
  }

  /// 통계 행 위젯
  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppFonts.bodyMedium),
          Text(
            value,
            style: AppFonts.bodyMedium.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.pointBrown,
            ),
          ),
        ],
      ),
    );
  }

  /// 활동 타입별 아이콘
  IconData _getActivityIcon(String type) {
    switch (type) {
      case 'feeding':
        return Icons.restaurant;
      case 'walk':
        return Icons.directions_walk;
      case 'health':
        return Icons.medical_services;
      case 'chat':
        return Icons.chat;
      default:
        return Icons.info;
    }
  }

  /// 활동 타입별 색상
  Color _getActivityColor(String type) {
    switch (type) {
      case 'feeding':
        return Colors.orange;
      case 'walk':
        return Colors.green;
      case 'health':
        return Colors.red;
      case 'chat':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  /// 활동 제목 생성
  String _getActivityTitle(Map<String, dynamic> activity, String type) {
    switch (type) {
      case 'feeding':
        return '給餌記録: ${activity['amount']}g';
      case 'walk':
        return '散歩記録: ${activity['duration']}分';
      case 'health':
        return '健康記録: ${activity['title']}';
      case 'chat':
        return 'AIチャット: ${(activity['message'] as String).substring(0, 20)}...';
      default:
        return '不明な活動';
    }
  }
}
