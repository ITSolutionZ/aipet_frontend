import { sendScheduledNotifications } from '../controllers/notification.controller.js';

/**
 * 예약된 알림 자동 전송 스케줄러
 * 매 1분마다 실행되어 전송 예정 알림을 확인하고 전송합니다.
 */
export const startNotificationScheduler = () => {
  console.log('📬 [Scheduler] 알림 스케줄러 시작');

  // 1분마다 실행
  setInterval(async () => {
    try {
      const result = await sendScheduledNotifications();
      if (result.sent > 0) {
        console.log(`📬 [Scheduler] ${result.sent}개의 예약 알림 전송 완료`);
      }
    } catch (error) {
      console.error('❌ [Scheduler] 알림 스케줄러 에러:', error);
    }
  }, 60000); // 60초 = 1분

  // 초기 실행
  sendScheduledNotifications().catch((error) => {
    console.error('❌ [Scheduler] 초기 알림 전송 에러:', error);
  });
};

/**
 * 예방접종 알림 자동 생성
 * 예방접종 다음 접종일이 7일 이내인 경우 알림 생성
 */
export const createVaccinationReminders = async (pool) => {
  try {
    // 다음 접종일이 7일 이내인 예방접종 조회
    const [vaccinations] = await pool.query(
      `SELECT v.*, p.name as pet_name, p.owner_id
       FROM vaccinations v
       JOIN pets p ON v.pet_id = p.id
       WHERE v.next_due_date BETWEEN NOW() AND DATE_ADD(NOW(), INTERVAL 7 DAY)
       AND NOT EXISTS (
         SELECT 1 FROM notifications n
         WHERE n.pet_id = p.id
         AND n.notification_type = 'vaccination'
         AND n.title LIKE CONCAT('%', v.vaccine_name, '%')
         AND n.scheduled_at >= NOW()
       )`
    );

    for (const vacc of vaccinations) {
      await pool.query(
        `INSERT INTO notifications (
          id, user_id, pet_id, title, body, notification_type, scheduled_at
        ) VALUES (?, ?, ?, ?, ?, ?, ?)`,
        [
          `notif_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`,
          vacc.owner_id,
          vacc.pet_id,
          `${vacc.pet_name}의 ${vacc.vaccine_name} 접종일이 다가왔습니다`,
          `다음 접종 예정일: ${new Date(vacc.next_due_date).toLocaleDateString('ko-KR')}`,
          'vaccination',
          new Date(vacc.next_due_date).setHours(9, 0, 0, 0), // 오전 9시에 알림
        ]
      );
    }

    if (vaccinations.length > 0) {
      console.log(`✅ [Scheduler] ${vaccinations.length}개의 예방접종 알림 생성`);
    }
  } catch (error) {
    console.error('❌ [Scheduler] 예방접종 알림 생성 에러:', error);
  }
};

/**
 * 급식 시간 알림 자동 생성
 * 매일 설정된 급식 시간에 알림 생성
 */
export const createFeedingReminders = async (pool) => {
  try {
    // 활성화된 모든 펫 조회
    const [pets] = await pool.query(
      'SELECT id, name, owner_id FROM pets WHERE is_active = true'
    );

    const now = new Date();
    const feedingTimes = [
      { type: 'breakfast', hour: 8, label: '아침' },
      { type: 'dinner', hour: 18, label: '저녁' },
    ];

    for (const pet of pets) {
      for (const feeding of feedingTimes) {
        const scheduledTime = new Date(now);
        scheduledTime.setHours(feeding.hour, 0, 0, 0);

        // 이미 오늘 해당 시간 알림이 있는지 확인
        const [existing] = await pool.query(
          `SELECT id FROM notifications
           WHERE user_id = ? AND pet_id = ?
           AND notification_type = 'feeding'
           AND DATE(scheduled_at) = CURDATE()
           AND HOUR(scheduled_at) = ?`,
          [pet.owner_id, pet.id, feeding.hour]
        );

        if (existing.length === 0) {
          await pool.query(
            `INSERT INTO notifications (
              id, user_id, pet_id, title, body, notification_type, scheduled_at
            ) VALUES (?, ?, ?, ?, ?, ?, ?)`,
            [
              `notif_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`,
              pet.owner_id,
              pet.id,
              `${pet.name}의 ${feeding.label} 식사 시간입니다`,
              `사료를 챙겨주세요!`,
              'feeding',
              scheduledTime,
            ]
          );
        }
      }
    }
  } catch (error) {
    console.error('❌ [Scheduler] 급식 알림 생성 에러:', error);
  }
};

/**
 * 매일 실행되는 알림 생성 작업
 */
export const startDailyReminderScheduler = (pool) => {
  console.log('⏰ [Scheduler] 일일 알림 스케줄러 시작');

  // 매일 자정에 실행
  const runDailyTasks = async () => {
    console.log('⏰ [Scheduler] 일일 알림 생성 시작');
    await createVaccinationReminders(pool);
    await createFeedingReminders(pool);
    console.log('✅ [Scheduler] 일일 알림 생성 완료');
  };

  // 다음 자정까지의 시간 계산
  const now = new Date();
  const tomorrow = new Date(now);
  tomorrow.setDate(tomorrow.getDate() + 1);
  tomorrow.setHours(0, 0, 0, 0);
  const timeUntilMidnight = tomorrow - now;

  // 첫 실행은 다음 자정에
  setTimeout(() => {
    runDailyTasks();
    // 이후 24시간마다 실행
    setInterval(runDailyTasks, 24 * 60 * 60 * 1000);
  }, timeUntilMidnight);

  console.log(`⏰ [Scheduler] 다음 일일 알림 생성: ${tomorrow.toLocaleString('ko-KR')}`);
};
