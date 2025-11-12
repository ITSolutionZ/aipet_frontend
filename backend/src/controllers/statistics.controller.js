import pool from '../config/database.js';

/**
 * 통계 컨트롤러
 *
 * 사용자 및 펫의 통합 통계 데이터를 제공합니다.
 */

/**
 * 대시보드 통계 조회
 * GET /statistics/dashboard
 */
export const getDashboardStatistics = async (req, res) => {
  const userId = req.user.uid;

  try {
    // 1. 펫 요약
    const [pets] = await pool.query(
      'SELECT COUNT(*) as total FROM pets WHERE user_id = ?',
      [userId]
    );

    // 2. 오늘의 산책 통계
    const today = new Date();
    today.setHours(0, 0, 0, 0);
    const tomorrow = new Date(today);
    tomorrow.setDate(tomorrow.getDate() + 1);

    const [todayWalks] = await pool.query(
      `SELECT
        COUNT(*) as count,
        COALESCE(SUM(distance), 0) as total_distance,
        COALESCE(SUM(duration), 0) as total_duration
      FROM walks
      WHERE user_id = ? AND start_time >= ? AND start_time < ?`,
      [userId, today, tomorrow]
    );

    // 3. 이번 주 산책 통계
    const weekStart = new Date(today);
    weekStart.setDate(today.getDate() - today.getDay());
    const weekEnd = new Date(weekStart);
    weekEnd.setDate(weekStart.getDate() + 7);

    const [weekWalks] = await pool.query(
      `SELECT
        COALESCE(SUM(distance), 0) as weekly_distance
      FROM walks
      WHERE user_id = ? AND start_time >= ? AND start_time < ?`,
      [userId, weekStart, weekEnd]
    );

    // 4. 다가오는 예약 (7일 이내)
    const nextWeek = new Date(today);
    nextWeek.setDate(today.getDate() + 7);

    const [appointments] = await pool.query(
      `SELECT COUNT(*) as count
      FROM schedules
      WHERE user_id = ? AND start_datetime >= NOW() AND start_datetime < ?
        AND status != 'cancelled'`,
      [userId, nextWeek]
    );

    // 5. 건강 알림 (최근 예방접종 만료 예정)
    const [healthAlerts] = await pool.query(
      `SELECT
        p.name as pet_name,
        v.vaccine_name,
        v.next_due_date
      FROM vaccinations v
      JOIN pets p ON v.pet_id = p.id
      WHERE v.user_id = ? AND v.next_due_date IS NOT NULL
        AND v.next_due_date BETWEEN NOW() AND DATE_ADD(NOW(), INTERVAL 30 DAY)
      ORDER BY v.next_due_date ASC
      LIMIT 5`,
      [userId]
    );

    // 6. 오늘의 급식 횟수
    const [todayFeedings] = await pool.query(
      `SELECT COUNT(*) as count
      FROM feedings
      WHERE user_id = ? AND feeding_time >= ? AND feeding_time < ?`,
      [userId, today, tomorrow]
    );

    return res.json({
      success: true,
      message: 'ダッシュボード統計を取得しました',
      data: {
        pets: {
          total: pets[0].total,
        },
        walks: {
          today: {
            count: todayWalks[0].count,
            distance: parseFloat(todayWalks[0].total_distance),
            duration: parseInt(todayWalks[0].total_duration),
          },
          weekly: {
            distance: parseFloat(weekWalks[0].weekly_distance),
            goal: 10.0, // 기본 목표: 10km
            progress:
              (parseFloat(weekWalks[0].weekly_distance) / 10.0) * 100,
          },
        },
        appointments: {
          upcoming: appointments[0].count,
        },
        health: {
          alerts: healthAlerts.map((alert) => ({
            petName: alert.pet_name,
            message: `${alert.vaccine_name}の接種期限が近づいています`,
            dueDate: alert.next_due_date,
          })),
        },
        feedings: {
          today: todayFeedings[0].count,
        },
      },
    });
  } catch (error) {
    console.error('❌ Error getting dashboard statistics:', error);
    return res.status(500).json({
      success: false,
      message: 'ダッシュボード統計の取得に失敗しました',
      error: error.message,
    });
  }
};

/**
 * 펫별 통계 조회
 * GET /statistics/pets/:petId
 */
export const getPetStatistics = async (req, res) => {
  const userId = req.user.uid;
  const { petId } = req.params;

  try {
    // 펫 소유권 확인
    const [petRows] = await pool.query(
      'SELECT name FROM pets WHERE id = ? AND user_id = ?',
      [petId, userId]
    );

    if (petRows.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'ペットが見つかりません',
      });
    }

    // 1. 산책 통계
    const [walkStats] = await pool.query(
      `SELECT
        COUNT(*) as total_walks,
        COALESCE(SUM(distance), 0) as total_distance,
        COALESCE(SUM(duration), 0) as total_duration,
        COALESCE(AVG(distance), 0) as avg_distance,
        COALESCE(AVG(duration), 0) as avg_duration
      FROM walks
      WHERE pet_id = ?`,
      [petId]
    );

    // 2. 급식 통계
    const [feedingStats] = await pool.query(
      `SELECT
        COUNT(*) as total_feedings,
        COALESCE(SUM(amount), 0) as total_amount
      FROM feedings
      WHERE pet_id = ?`,
      [petId]
    );

    // 3. 건강 기록 통계
    const [healthStats] = await pool.query(
      `SELECT
        (SELECT COUNT(*) FROM vaccinations WHERE pet_id = ?) as vaccinations,
        (SELECT COUNT(*) FROM medical_records WHERE pet_id = ?) as medical_records,
        (SELECT COUNT(*) FROM weight_history WHERE pet_id = ?) as weight_records
      `,
      [petId, petId, petId]
    );

    // 4. 활동 기록 통계
    const [activityStats] = await pool.query(
      `SELECT
        COUNT(*) as total_activities
      FROM activities
      WHERE pet_id = ?`,
      [petId]
    );

    // 5. 스케줄 통계
    const [scheduleStats] = await pool.query(
      `SELECT
        COUNT(*) as total_schedules,
        SUM(CASE WHEN status = 'completed' THEN 1 ELSE 0 END) as completed,
        SUM(CASE WHEN status = 'pending' THEN 1 ELSE 0 END) as pending,
        SUM(CASE WHEN status = 'cancelled' THEN 1 ELSE 0 END) as cancelled
      FROM schedules
      WHERE pet_id = ?`,
      [petId]
    );

    // 6. 최근 30일 활동 트렌드
    const thirtyDaysAgo = new Date();
    thirtyDaysAgo.setDate(thirtyDaysAgo.getDate() - 30);

    const [recentWalks] = await pool.query(
      `SELECT
        DATE(start_time) as date,
        COUNT(*) as count,
        SUM(distance) as distance
      FROM walks
      WHERE pet_id = ? AND start_time >= ?
      GROUP BY DATE(start_time)
      ORDER BY date DESC`,
      [petId, thirtyDaysAgo]
    );

    return res.json({
      success: true,
      message: 'ペット統計を取得しました',
      data: {
        petName: petRows[0].name,
        walks: {
          total: walkStats[0].total_walks,
          totalDistance: parseFloat(walkStats[0].total_distance),
          totalDuration: parseInt(walkStats[0].total_duration),
          avgDistance: parseFloat(walkStats[0].avg_distance),
          avgDuration: parseInt(walkStats[0].avg_duration),
        },
        feedings: {
          total: feedingStats[0].total_feedings,
          totalAmount: parseFloat(feedingStats[0].total_amount),
        },
        health: {
          vaccinations: healthStats[0].vaccinations,
          medicalRecords: healthStats[0].medical_records,
          weightRecords: healthStats[0].weight_records,
        },
        activities: {
          total: activityStats[0].total_activities,
        },
        schedules: {
          total: scheduleStats[0].total_schedules || 0,
          completed: scheduleStats[0].completed || 0,
          pending: scheduleStats[0].pending || 0,
          cancelled: scheduleStats[0].cancelled || 0,
        },
        recentTrend: recentWalks.map((row) => ({
          date: row.date,
          walks: row.count,
          distance: parseFloat(row.distance),
        })),
      },
    });
  } catch (error) {
    console.error('❌ Error getting pet statistics:', error);
    return res.status(500).json({
      success: false,
      message: 'ペット統計の取得に失敗しました',
      error: error.message,
    });
  }
};

/**
 * 활동 통계 조회 (기간별)
 * GET /statistics/activity
 */
export const getActivityStatistics = async (req, res) => {
  const userId = req.user.uid;
  const { period = 'week', type } = req.query; // period: day, week, month, year

  try {
    let dateFormat;
    let dateCondition;
    const now = new Date();

    switch (period) {
      case 'day':
        dateFormat = '%Y-%m-%d %H:00:00';
        dateCondition = 'DATE(start_time) = CURDATE()';
        break;
      case 'week':
        dateFormat = '%Y-%m-%d';
        const weekStart = new Date(now);
        weekStart.setDate(now.getDate() - now.getDay());
        dateCondition = `start_time >= '${weekStart.toISOString()}'`;
        break;
      case 'month':
        dateFormat = '%Y-%m-%d';
        const monthStart = new Date(now.getFullYear(), now.getMonth(), 1);
        dateCondition = `start_time >= '${monthStart.toISOString()}'`;
        break;
      case 'year':
        dateFormat = '%Y-%m';
        const yearStart = new Date(now.getFullYear(), 0, 1);
        dateCondition = `start_time >= '${yearStart.toISOString()}'`;
        break;
      default:
        dateFormat = '%Y-%m-%d';
        dateCondition = 'start_time >= DATE_SUB(NOW(), INTERVAL 7 DAY)';
    }

    const stats = {};

    // 산책 통계
    if (!type || type === 'walk') {
      const [walkStats] = await pool.query(
        `SELECT
          DATE_FORMAT(start_time, ?) as period,
          COUNT(*) as count,
          SUM(distance) as total_distance,
          SUM(duration) as total_duration,
          AVG(distance) as avg_distance
        FROM walks
        WHERE user_id = ? AND ${dateCondition}
        GROUP BY DATE_FORMAT(start_time, ?)
        ORDER BY period`,
        [dateFormat, userId, dateFormat]
      );

      stats.walks = walkStats.map((row) => ({
        period: row.period,
        count: row.count,
        totalDistance: parseFloat(row.total_distance),
        totalDuration: parseInt(row.total_duration),
        avgDistance: parseFloat(row.avg_distance),
      }));
    }

    // 급식 통계
    if (!type || type === 'feeding') {
      const feedingDateCondition = dateCondition.replace(
        'start_time',
        'feeding_time'
      );
      const [feedingStats] = await pool.query(
        `SELECT
          DATE_FORMAT(feeding_time, ?) as period,
          COUNT(*) as count,
          SUM(amount) as total_amount
        FROM feedings
        WHERE user_id = ? AND ${feedingDateCondition}
        GROUP BY DATE_FORMAT(feeding_time, ?)
        ORDER BY period`,
        [dateFormat, userId, dateFormat]
      );

      stats.feedings = feedingStats.map((row) => ({
        period: row.period,
        count: row.count,
        totalAmount: parseFloat(row.total_amount),
      }));
    }

    // 활동 통계
    if (!type || type === 'activity') {
      const activityDateCondition = dateCondition.replace(
        'start_time',
        'activity_date'
      );
      const [activityStats] = await pool.query(
        `SELECT
          DATE_FORMAT(activity_date, ?) as period,
          activity_type,
          COUNT(*) as count,
          SUM(duration_minutes) as total_duration
        FROM activities
        WHERE user_id = ? AND ${activityDateCondition}
        GROUP BY DATE_FORMAT(activity_date, ?), activity_type
        ORDER BY period`,
        [dateFormat, userId, dateFormat]
      );

      // 활동 타입별로 그룹화
      const activityByPeriod = {};
      activityStats.forEach((row) => {
        if (!activityByPeriod[row.period]) {
          activityByPeriod[row.period] = {
            period: row.period,
            byType: {},
          };
        }
        activityByPeriod[row.period].byType[row.activity_type] = {
          count: row.count,
          totalDuration: parseInt(row.total_duration) || 0,
        };
      });

      stats.activities = Object.values(activityByPeriod);
    }

    return res.json({
      success: true,
      message: 'アクティビティ統計を取得しました',
      data: {
        period,
        ...stats,
      },
    });
  } catch (error) {
    console.error('❌ Error getting activity statistics:', error);
    return res.status(500).json({
      success: false,
      message: 'アクティビティ統計の取得に失敗しました',
      error: error.message,
    });
  }
};

/**
 * 건강 통계 조회
 * GET /statistics/health
 */
export const getHealthStatistics = async (req, res) => {
  const userId = req.user.uid;

  try {
    // 1. 예방접종 통계
    const [vaccinationStats] = await pool.query(
      `SELECT
        COUNT(*) as total,
        SUM(CASE WHEN next_due_date < NOW() THEN 1 ELSE 0 END) as overdue,
        SUM(CASE WHEN next_due_date BETWEEN NOW() AND DATE_ADD(NOW(), INTERVAL 30 DAY) THEN 1 ELSE 0 END) as upcoming
      FROM vaccinations
      WHERE user_id = ? AND next_due_date IS NOT NULL`,
      [userId]
    );

    // 2. 의료 기록 통계 (최근 6개월)
    const [medicalStats] = await pool.query(
      `SELECT
        DATE_FORMAT(visit_date, '%Y-%m') as month,
        COUNT(*) as count,
        visit_type
      FROM medical_records
      WHERE user_id = ? AND visit_date >= DATE_SUB(NOW(), INTERVAL 6 MONTH)
      GROUP BY DATE_FORMAT(visit_date, '%Y-%m'), visit_type
      ORDER BY month DESC`,
      [userId]
    );

    // 3. 체중 추적 통계 (펫별 최근 체중)
    const [weightStats] = await pool.query(
      `SELECT
        p.id as pet_id,
        p.name as pet_name,
        wh.weight,
        wh.measured_at
      FROM pets p
      LEFT JOIN (
        SELECT pet_id, weight, measured_at,
          ROW_NUMBER() OVER (PARTITION BY pet_id ORDER BY measured_at DESC) as rn
        FROM weight_history
      ) wh ON p.id = wh.pet_id AND wh.rn = 1
      WHERE p.user_id = ?`,
      [userId]
    );

    return res.json({
      success: true,
      message: '健康統計を取得しました',
      data: {
        vaccinations: {
          total: vaccinationStats[0].total,
          overdue: vaccinationStats[0].overdue,
          upcoming: vaccinationStats[0].upcoming,
        },
        medicalRecords: medicalStats.map((row) => ({
          month: row.month,
          count: row.count,
          visitType: row.visit_type,
        })),
        weights: weightStats.map((row) => ({
          petId: row.pet_id,
          petName: row.pet_name,
          currentWeight: row.weight ? parseFloat(row.weight) : null,
          measuredAt: row.measured_at,
        })),
      },
    });
  } catch (error) {
    console.error('❌ Error getting health statistics:', error);
    return res.status(500).json({
      success: false,
      message: '健康統計の取得に失敗しました',
      error: error.message,
    });
  }
};
