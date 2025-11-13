import pool from '../config/database.js';

/**
 * @desc    게시글 목록 조회
 * @route   GET /api/v1/board/posts
 * @access  Private
 */
export const getPosts = async (req, res) => {
  try {
    const userId = req.user.uid;
    const { category, page = 1, limit = 20, search } = req.query;

    const offset = (page - 1) * limit;
    let query = `
      SELECT
        p.*,
        u.display_name as author_name,
        u.photo_url as author_profile_image
      FROM posts p
      LEFT JOIN users u ON p.user_id = u.firebase_uid
      WHERE 1=1
    `;
    const params = [];

    // 카테고리 필터
    if (category && category !== 'all') {
      query += ' AND p.category = ?';
      params.push(category);
    }

    // 검색 필터
    if (search) {
      query += ' AND (p.title LIKE ? OR p.content LIKE ?)';
      params.push(`%${search}%`, `%${search}%`);
    }

    query += ' ORDER BY p.created_at DESC LIMIT ? OFFSET ?';
    params.push(parseInt(limit), offset);

    const [posts] = await pool.query(query, params);

    console.log(`✅ [Board] 게시글 목록 조회: ${posts.length}개`);
    res.json({
      success: true,
      message: '게시글 목록을 가져왔습니다.',
      data: posts,
    });
  } catch (error) {
    console.error('❌ [Board] 게시글 목록 조회 실패:', error);
    res.status(500).json({
      success: false,
      message: '게시글 목록 조회에 실패했습니다.',
      error: error.message,
    });
  }
};

/**
 * @desc    게시글 상세 조회
 * @route   GET /api/v1/board/posts/:postId
 * @access  Private
 */
export const getPostById = async (req, res) => {
  try {
    const { postId } = req.params;
    const userId = req.user.uid;

    // 조회수 증가
    await pool.query(
      'UPDATE posts SET view_count = view_count + 1 WHERE id = ?',
      [postId]
    );

    // 게시글 조회
    const [posts] = await pool.query(
      `
      SELECT
        p.*,
        u.display_name as author_name,
        u.photo_url as author_profile_image
      FROM posts p
      LEFT JOIN users u ON p.user_id = u.firebase_uid
      WHERE p.id = ?
      `,
      [postId]
    );

    if (posts.length === 0) {
      return res.status(404).json({
        success: false,
        message: '게시글을 찾을 수 없습니다.',
      });
    }

    console.log(`✅ [Board] 게시글 조회: ${postId}`);
    res.json({
      success: true,
      message: '게시글을 가져왔습니다.',
      data: posts[0],
    });
  } catch (error) {
    console.error('❌ [Board] 게시글 조회 실패:', error);
    res.status(500).json({
      success: false,
      message: '게시글 조회에 실패했습니다.',
      error: error.message,
    });
  }
};

/**
 * @desc    게시글 생성
 * @route   POST /api/v1/board/posts
 * @access  Private
 */
export const createPost = async (req, res) => {
  try {
    const userId = req.user.uid;
    const { title, content, category, imageUrls, tags } = req.body;

    // posts 테이블이 없으면 생성
    await pool.query(`
      CREATE TABLE IF NOT EXISTS posts (
        id INT AUTO_INCREMENT PRIMARY KEY,
        user_id VARCHAR(255) NOT NULL,
        title VARCHAR(255) NOT NULL,
        content TEXT NOT NULL,
        category VARCHAR(50) NOT NULL,
        view_count INT DEFAULT 0,
        like_count INT DEFAULT 0,
        comment_count INT DEFAULT 0,
        image_urls JSON,
        tags JSON,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
        INDEX idx_user_id (user_id),
        INDEX idx_category (category),
        INDEX idx_created_at (created_at)
      ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
    `);

    // users 테이블도 없으면 생성 (작성자 정보 저장용)
    await pool.query(`
      CREATE TABLE IF NOT EXISTS users (
        id INT AUTO_INCREMENT PRIMARY KEY,
        firebase_uid VARCHAR(255) UNIQUE NOT NULL,
        email VARCHAR(255),
        display_name VARCHAR(255),
        photo_url TEXT,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
        INDEX idx_firebase_uid (firebase_uid)
      ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
    `);

    // 사용자 정보 upsert
    await pool.query(
      `
      INSERT INTO users (firebase_uid, email, display_name, photo_url)
      VALUES (?, ?, ?, ?)
      ON DUPLICATE KEY UPDATE
        email = VALUES(email),
        display_name = VALUES(display_name),
        photo_url = VALUES(photo_url),
        updated_at = CURRENT_TIMESTAMP
      `,
      [
        userId,
        req.user.email || null,
        req.user.name || req.user.email?.split('@')[0] || '익명',
        req.user.picture || null,
      ]
    );

    // 게시글 생성
    const [result] = await pool.query(
      `
      INSERT INTO posts (user_id, title, content, category, image_urls, tags)
      VALUES (?, ?, ?, ?, ?, ?)
      `,
      [
        userId,
        title,
        content,
        category,
        JSON.stringify(imageUrls || []),
        JSON.stringify(tags || []),
      ]
    );

    // 생성된 게시글 조회
    const [posts] = await pool.query(
      `
      SELECT
        p.*,
        u.display_name as author_name,
        u.photo_url as author_profile_image
      FROM posts p
      LEFT JOIN users u ON p.user_id = u.firebase_uid
      WHERE p.id = ?
      `,
      [result.insertId]
    );

    console.log(`✅ [Board] 게시글 생성: ${result.insertId}`);
    res.status(201).json({
      success: true,
      message: '게시글을 작성했습니다.',
      data: posts[0],
    });
  } catch (error) {
    console.error('❌ [Board] 게시글 생성 실패:', error);
    res.status(500).json({
      success: false,
      message: '게시글 작성에 실패했습니다.',
      error: error.message,
    });
  }
};

/**
 * @desc    게시글 수정
 * @route   PUT /api/v1/board/posts/:postId
 * @access  Private
 */
export const updatePost = async (req, res) => {
  try {
    const { postId } = req.params;
    const userId = req.user.uid;
    const { title, content, category, imageUrls, tags } = req.body;

    // 게시글 소유권 확인
    const [posts] = await pool.query(
      'SELECT * FROM posts WHERE id = ? AND user_id = ?',
      [postId, userId]
    );

    if (posts.length === 0) {
      return res.status(404).json({
        success: false,
        message: '게시글을 찾을 수 없거나 수정 권한이 없습니다.',
      });
    }

    // 게시글 수정
    await pool.query(
      `
      UPDATE posts
      SET title = ?, content = ?, category = ?, image_urls = ?, tags = ?
      WHERE id = ? AND user_id = ?
      `,
      [
        title,
        content,
        category,
        JSON.stringify(imageUrls || []),
        JSON.stringify(tags || []),
        postId,
        userId,
      ]
    );

    // 수정된 게시글 조회
    const [updatedPosts] = await pool.query(
      `
      SELECT
        p.*,
        u.display_name as author_name,
        u.photo_url as author_profile_image
      FROM posts p
      LEFT JOIN users u ON p.user_id = u.firebase_uid
      WHERE p.id = ?
      `,
      [postId]
    );

    console.log(`✅ [Board] 게시글 수정: ${postId}`);
    res.json({
      success: true,
      message: '게시글을 수정했습니다.',
      data: updatedPosts[0],
    });
  } catch (error) {
    console.error('❌ [Board] 게시글 수정 실패:', error);
    res.status(500).json({
      success: false,
      message: '게시글 수정에 실패했습니다.',
      error: error.message,
    });
  }
};

/**
 * @desc    게시글 삭제
 * @route   DELETE /api/v1/board/posts/:postId
 * @access  Private
 */
export const deletePost = async (req, res) => {
  try {
    const { postId } = req.params;
    const userId = req.user.uid;

    // 게시글 소유권 확인
    const [posts] = await pool.query(
      'SELECT * FROM posts WHERE id = ? AND user_id = ?',
      [postId, userId]
    );

    if (posts.length === 0) {
      return res.status(404).json({
        success: false,
        message: '게시글을 찾을 수 없거나 삭제 권한이 없습니다.',
      });
    }

    // 관련 댓글 삭제
    await pool.query('DELETE FROM post_comments WHERE post_id = ?', [postId]);

    // 관련 좋아요 삭제
    await pool.query('DELETE FROM post_likes WHERE post_id = ?', [postId]);

    // 게시글 삭제
    await pool.query('DELETE FROM posts WHERE id = ?', [postId]);

    console.log(`✅ [Board] 게시글 삭제: ${postId}`);
    res.json({
      success: true,
      message: '게시글을 삭제했습니다.',
    });
  } catch (error) {
    console.error('❌ [Board] 게시글 삭제 실패:', error);
    res.status(500).json({
      success: false,
      message: '게시글 삭제에 실패했습니다.',
      error: error.message,
    });
  }
};

/**
 * @desc    게시글 댓글 목록 조회
 * @route   GET /api/v1/board/posts/:postId/comments
 * @access  Private
 */
export const getComments = async (req, res) => {
  try {
    const { postId } = req.params;

    const [comments] = await pool.query(
      `
      SELECT
        c.*,
        u.display_name as author_name,
        u.photo_url as author_profile_image
      FROM post_comments c
      LEFT JOIN users u ON c.user_id = u.firebase_uid
      WHERE c.post_id = ?
      ORDER BY c.created_at ASC
      `,
      [postId]
    );

    console.log(`✅ [Board] 댓글 목록 조회: ${comments.length}개`);
    res.json({
      success: true,
      message: '댓글 목록을 가져왔습니다.',
      data: comments,
    });
  } catch (error) {
    console.error('❌ [Board] 댓글 목록 조회 실패:', error);
    res.status(500).json({
      success: false,
      message: '댓글 목록 조회에 실패했습니다.',
      error: error.message,
    });
  }
};

/**
 * @desc    게시글 댓글 작성
 * @route   POST /api/v1/board/posts/:postId/comments
 * @access  Private
 */
export const createComment = async (req, res) => {
  try {
    const { postId } = req.params;
    const userId = req.user.uid;
    const { content } = req.body;

    // post_comments 테이블이 없으면 생성
    await pool.query(`
      CREATE TABLE IF NOT EXISTS post_comments (
        id INT AUTO_INCREMENT PRIMARY KEY,
        post_id INT NOT NULL,
        user_id VARCHAR(255) NOT NULL,
        content TEXT NOT NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
        INDEX idx_post_id (post_id),
        INDEX idx_user_id (user_id),
        FOREIGN KEY (post_id) REFERENCES posts(id) ON DELETE CASCADE
      ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
    `);

    // 댓글 생성
    const [result] = await pool.query(
      'INSERT INTO post_comments (post_id, user_id, content) VALUES (?, ?, ?)',
      [postId, userId, content]
    );

    // 게시글의 댓글 수 증가
    await pool.query(
      'UPDATE posts SET comment_count = comment_count + 1 WHERE id = ?',
      [postId]
    );

    // 생성된 댓글 조회
    const [comments] = await pool.query(
      `
      SELECT
        c.*,
        u.display_name as author_name,
        u.photo_url as author_profile_image
      FROM post_comments c
      LEFT JOIN users u ON c.user_id = u.firebase_uid
      WHERE c.id = ?
      `,
      [result.insertId]
    );

    console.log(`✅ [Board] 댓글 작성: ${result.insertId}`);
    res.status(201).json({
      success: true,
      message: '댓글을 작성했습니다.',
      data: comments[0],
    });
  } catch (error) {
    console.error('❌ [Board] 댓글 작성 실패:', error);
    res.status(500).json({
      success: false,
      message: '댓글 작성에 실패했습니다.',
      error: error.message,
    });
  }
};

/**
 * @desc    댓글 삭제
 * @route   DELETE /api/v1/board/posts/:postId/comments/:commentId
 * @access  Private
 */
export const deleteComment = async (req, res) => {
  try {
    const { postId, commentId } = req.params;
    const userId = req.user.uid;

    // 댓글 소유권 확인
    const [comments] = await pool.query(
      'SELECT * FROM post_comments WHERE id = ? AND user_id = ?',
      [commentId, userId]
    );

    if (comments.length === 0) {
      return res.status(404).json({
        success: false,
        message: '댓글을 찾을 수 없거나 삭제 권한이 없습니다.',
      });
    }

    // 댓글 삭제
    await pool.query('DELETE FROM post_comments WHERE id = ?', [commentId]);

    // 게시글의 댓글 수 감소
    await pool.query(
      'UPDATE posts SET comment_count = GREATEST(comment_count - 1, 0) WHERE id = ?',
      [postId]
    );

    console.log(`✅ [Board] 댓글 삭제: ${commentId}`);
    res.json({
      success: true,
      message: '댓글을 삭제했습니다.',
    });
  } catch (error) {
    console.error('❌ [Board] 댓글 삭제 실패:', error);
    res.status(500).json({
      success: false,
      message: '댓글 삭제에 실패했습니다.',
      error: error.message,
    });
  }
};

/**
 * @desc    게시글 좋아요/취소
 * @route   POST /api/v1/board/posts/:postId/like
 * @access  Private
 */
export const toggleLike = async (req, res) => {
  try {
    const { postId } = req.params;
    const userId = req.user.uid;

    // post_likes 테이블이 없으면 생성
    await pool.query(`
      CREATE TABLE IF NOT EXISTS post_likes (
        id INT AUTO_INCREMENT PRIMARY KEY,
        post_id INT NOT NULL,
        user_id VARCHAR(255) NOT NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        UNIQUE KEY unique_like (post_id, user_id),
        INDEX idx_post_id (post_id),
        INDEX idx_user_id (user_id),
        FOREIGN KEY (post_id) REFERENCES posts(id) ON DELETE CASCADE
      ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
    `);

    // 이미 좋아요 했는지 확인
    const [likes] = await pool.query(
      'SELECT * FROM post_likes WHERE post_id = ? AND user_id = ?',
      [postId, userId]
    );

    let liked = false;

    if (likes.length > 0) {
      // 좋아요 취소
      await pool.query(
        'DELETE FROM post_likes WHERE post_id = ? AND user_id = ?',
        [postId, userId]
      );
      await pool.query(
        'UPDATE posts SET like_count = GREATEST(like_count - 1, 0) WHERE id = ?',
        [postId]
      );
      liked = false;
    } else {
      // 좋아요 추가
      await pool.query(
        'INSERT INTO post_likes (post_id, user_id) VALUES (?, ?)',
        [postId, userId]
      );
      await pool.query(
        'UPDATE posts SET like_count = like_count + 1 WHERE id = ?',
        [postId]
      );
      liked = true;
    }

    // 현재 좋아요 수 조회
    const [posts] = await pool.query(
      'SELECT like_count FROM posts WHERE id = ?',
      [postId]
    );

    console.log(
      `✅ [Board] 좋아요 ${liked ? '추가' : '취소'}: ${postId}`
    );
    res.json({
      success: true,
      message: liked ? '좋아요를 눌렀습니다.' : '좋아요를 취소했습니다.',
      data: {
        liked,
        likeCount: posts[0]?.like_count || 0,
      },
    });
  } catch (error) {
    console.error('❌ [Board] 좋아요 처리 실패:', error);
    res.status(500).json({
      success: false,
      message: '좋아요 처리에 실패했습니다.',
      error: error.message,
    });
  }
};

/**
 * @desc    게시글 좋아요 여부 확인
 * @route   GET /api/v1/board/posts/:postId/like
 * @access  Private
 */
export const checkLikeStatus = async (req, res) => {
  try {
    const { postId } = req.params;
    const userId = req.user.uid;

    const [likes] = await pool.query(
      'SELECT * FROM post_likes WHERE post_id = ? AND user_id = ?',
      [postId, userId]
    );

    res.json({
      success: true,
      data: {
        liked: likes.length > 0,
      },
    });
  } catch (error) {
    console.error('❌ [Board] 좋아요 상태 확인 실패:', error);
    res.status(500).json({
      success: false,
      message: '좋아요 상태 확인에 실패했습니다.',
      error: error.message,
    });
  }
};
