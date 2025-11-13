import express from 'express';
import { body, param, query } from 'express-validator';
import {
  getPosts,
  getPostById,
  createPost,
  updatePost,
  deletePost,
  getComments,
  createComment,
  deleteComment,
  toggleLike,
  checkLikeStatus,
} from '../controllers/board.controller.js';
import { authenticateFirebase } from '../middlewares/auth.middleware.js';
import { validate } from '../middlewares/validation.middleware.js';

const router = express.Router();

// 모든 게시판 라우트는 인증 필요
router.use(authenticateFirebase);

/**
 * @route   GET /api/v1/board/posts
 * @desc    게시글 목록 조회
 * @access  Private
 */
router.get(
  '/posts',
  [
    query('category').optional().isString(),
    query('page').optional().isInt({ min: 1 }),
    query('limit').optional().isInt({ min: 1, max: 100 }),
    query('search').optional().isString(),
  ],
  validate,
  getPosts
);

/**
 * @route   GET /api/v1/board/posts/:postId
 * @desc    게시글 상세 조회
 * @access  Private
 */
router.get(
  '/posts/:postId',
  [param('postId').notEmpty().isInt().withMessage('유효한 게시글 ID가 필요합니다.')],
  validate,
  getPostById
);

/**
 * @route   POST /api/v1/board/posts
 * @desc    게시글 작성
 * @access  Private
 */
router.post(
  '/posts',
  [
    body('title')
      .notEmpty()
      .trim()
      .isLength({ min: 1, max: 255 })
      .withMessage('제목은 1-255자 사이여야 합니다.'),
    body('content')
      .notEmpty()
      .trim()
      .withMessage('내용은 필수입니다.'),
    body('category')
      .notEmpty()
      .isIn(['question', 'tip', 'review', 'daily', 'medical', 'training'])
      .withMessage('유효한 카테고리가 필요합니다.'),
    body('imageUrls')
      .optional()
      .isArray()
      .withMessage('imageUrls는 배열이어야 합니다.'),
    body('tags')
      .optional()
      .isArray()
      .withMessage('tags는 배열이어야 합니다.'),
  ],
  validate,
  createPost
);

/**
 * @route   PUT /api/v1/board/posts/:postId
 * @desc    게시글 수정
 * @access  Private
 */
router.put(
  '/posts/:postId',
  [
    param('postId').notEmpty().isInt().withMessage('유효한 게시글 ID가 필요합니다.'),
    body('title')
      .notEmpty()
      .trim()
      .isLength({ min: 1, max: 255 })
      .withMessage('제목은 1-255자 사이여야 합니다.'),
    body('content')
      .notEmpty()
      .trim()
      .withMessage('내용은 필수입니다.'),
    body('category')
      .notEmpty()
      .isIn(['question', 'tip', 'review', 'daily', 'medical', 'training'])
      .withMessage('유효한 카테고리가 필요합니다.'),
    body('imageUrls')
      .optional()
      .isArray()
      .withMessage('imageUrls는 배열이어야 합니다.'),
    body('tags')
      .optional()
      .isArray()
      .withMessage('tags는 배열이어야 합니다.'),
  ],
  validate,
  updatePost
);

/**
 * @route   DELETE /api/v1/board/posts/:postId
 * @desc    게시글 삭제
 * @access  Private
 */
router.delete(
  '/posts/:postId',
  [param('postId').notEmpty().isInt().withMessage('유효한 게시글 ID가 필요합니다.')],
  validate,
  deletePost
);

/**
 * @route   GET /api/v1/board/posts/:postId/comments
 * @desc    게시글 댓글 목록 조회
 * @access  Private
 */
router.get(
  '/posts/:postId/comments',
  [param('postId').notEmpty().isInt().withMessage('유효한 게시글 ID가 필요합니다.')],
  validate,
  getComments
);

/**
 * @route   POST /api/v1/board/posts/:postId/comments
 * @desc    게시글 댓글 작성
 * @access  Private
 */
router.post(
  '/posts/:postId/comments',
  [
    param('postId').notEmpty().isInt().withMessage('유효한 게시글 ID가 필요합니다.'),
    body('content')
      .notEmpty()
      .trim()
      .withMessage('댓글 내용은 필수입니다.'),
  ],
  validate,
  createComment
);

/**
 * @route   DELETE /api/v1/board/posts/:postId/comments/:commentId
 * @desc    댓글 삭제
 * @access  Private
 */
router.delete(
  '/posts/:postId/comments/:commentId',
  [
    param('postId').notEmpty().isInt().withMessage('유효한 게시글 ID가 필요합니다.'),
    param('commentId').notEmpty().isInt().withMessage('유효한 댓글 ID가 필요합니다.'),
  ],
  validate,
  deleteComment
);

/**
 * @route   POST /api/v1/board/posts/:postId/like
 * @desc    게시글 좋아요/취소
 * @access  Private
 */
router.post(
  '/posts/:postId/like',
  [param('postId').notEmpty().isInt().withMessage('유효한 게시글 ID가 필요합니다.')],
  validate,
  toggleLike
);

/**
 * @route   GET /api/v1/board/posts/:postId/like
 * @desc    게시글 좋아요 상태 확인
 * @access  Private
 */
router.get(
  '/posts/:postId/like',
  [param('postId').notEmpty().isInt().withMessage('유효한 게시글 ID가 필요합니다.')],
  validate,
  checkLikeStatus
);

export default router;
