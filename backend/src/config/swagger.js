import swaggerJsdoc from 'swagger-jsdoc';

const options = {
  definition: {
    openapi: '3.0.0',
    info: {
      title: 'AIPet Backend API',
      version: '1.0.0',
      description: 'AI 기반 반려동물 관리 애플리케이션 백엔드 API',
      contact: {
        name: 'AIPet Development Team',
        email: 'dev@aipet.com',
      },
    },
    servers: [
      {
        url: 'http://localhost:3000',
        description: '開発環境',
      },
      {
        url: 'https://api.aipet.com',
        description: '本番環境',
      },
    ],
    components: {
      securitySchemes: {
        BearerAuth: {
          type: 'http',
          scheme: 'bearer',
          bearerFormat: 'JWT',
          description: 'Firebase ID Token을 사용한 인증',
        },
      },
      schemas: {
        Error: {
          type: 'object',
          properties: {
            success: {
              type: 'boolean',
              example: false,
            },
            error: {
              type: 'string',
              example: 'エラーメッセージ',
            },
          },
        },
        User: {
          type: 'object',
          properties: {
            id: {
              type: 'string',
              description: 'Firebase UID',
              example: 'firebase-uid-123',
            },
            email: {
              type: 'string',
              format: 'email',
              example: 'user@example.com',
            },
            display_name: {
              type: 'string',
              example: '山田太郎',
            },
            photo_url: {
              type: 'string',
              format: 'uri',
              example: 'https://example.com/photo.jpg',
            },
            created_at: {
              type: 'string',
              format: 'date-time',
            },
            updated_at: {
              type: 'string',
              format: 'date-time',
            },
          },
        },
        Pet: {
          type: 'object',
          required: ['name', 'type'],
          properties: {
            id: {
              type: 'string',
              description: 'ペットID (UUID)',
              example: 'pet-uuid-123',
            },
            owner_id: {
              type: 'string',
              description: '所有者ID (Firebase UID)',
              example: 'firebase-uid-123',
            },
            name: {
              type: 'string',
              description: 'ペット名',
              example: 'ポチ',
            },
            type: {
              type: 'string',
              description: 'ペットの種類',
              enum: ['dog', 'cat', 'bird', 'rabbit', 'other'],
              example: 'dog',
            },
            breed: {
              type: 'string',
              description: '品種',
              example: '柴犬',
            },
            birth_date: {
              type: 'string',
              format: 'date',
              description: '生年月日',
              example: '2020-01-01',
            },
            gender: {
              type: 'string',
              enum: ['male', 'female', 'unknown'],
              example: 'male',
            },
            weight: {
              type: 'number',
              format: 'float',
              description: '体重 (kg)',
              example: 5.5,
            },
            photo_url: {
              type: 'string',
              format: 'uri',
              description: 'ペットの写真URL',
              example: 'https://example.com/pet.jpg',
            },
            microchip_number: {
              type: 'string',
              description: 'マイクロチップ番号',
              example: '123456789012345',
            },
            is_neutered: {
              type: 'boolean',
              description: '去勢/避妊手術の有無',
              example: true,
            },
            color: {
              type: 'string',
              description: '毛色',
              example: '茶色',
            },
            notes: {
              type: 'string',
              description: 'メモ',
              example: '元気な犬です',
            },
            is_active: {
              type: 'boolean',
              description: '有効フラグ',
              example: true,
            },
            created_at: {
              type: 'string',
              format: 'date-time',
            },
            updated_at: {
              type: 'string',
              format: 'date-time',
            },
          },
        },
        PetInput: {
          type: 'object',
          required: ['name', 'type'],
          properties: {
            name: {
              type: 'string',
              description: 'ペット名',
              example: 'ポチ',
            },
            type: {
              type: 'string',
              description: 'ペットの種類',
              enum: ['dog', 'cat', 'bird', 'rabbit', 'other'],
              example: 'dog',
            },
            breed: {
              type: 'string',
              example: '柴犬',
            },
            birth_date: {
              type: 'string',
              format: 'date',
              example: '2020-01-01',
            },
            gender: {
              type: 'string',
              enum: ['male', 'female', 'unknown'],
              example: 'male',
            },
            weight: {
              type: 'number',
              format: 'float',
              example: 5.5,
            },
            photo_url: {
              type: 'string',
              format: 'uri',
              example: 'https://example.com/pet.jpg',
            },
            microchip_number: {
              type: 'string',
              example: '123456789012345',
            },
            is_neutered: {
              type: 'boolean',
              example: true,
            },
            color: {
              type: 'string',
              example: '茶色',
            },
            notes: {
              type: 'string',
              example: '元気な犬です',
            },
          },
        },
      },
      responses: {
        UnauthorizedError: {
          description: '認証エラー',
          content: {
            'application/json': {
              schema: {
                $ref: '#/components/schemas/Error',
              },
              example: {
                success: false,
                error: 'Unauthorized - No token provided',
              },
            },
          },
        },
        ForbiddenError: {
          description: 'アクセス拒否',
          content: {
            'application/json': {
              schema: {
                $ref: '#/components/schemas/Error',
              },
              example: {
                success: false,
                error: 'Forbidden - Access denied',
              },
            },
          },
        },
        NotFoundError: {
          description: 'リソースが見つかりません',
          content: {
            'application/json': {
              schema: {
                $ref: '#/components/schemas/Error',
              },
              example: {
                success: false,
                error: 'Resource not found',
              },
            },
          },
        },
        ValidationError: {
          description: 'バリデーションエラー',
          content: {
            'application/json': {
              schema: {
                type: 'object',
                properties: {
                  success: {
                    type: 'boolean',
                    example: false,
                  },
                  errors: {
                    type: 'array',
                    items: {
                      type: 'object',
                      properties: {
                        field: {
                          type: 'string',
                          example: 'name',
                        },
                        message: {
                          type: 'string',
                          example: 'Name is required',
                        },
                      },
                    },
                  },
                },
              },
            },
          },
        },
      },
    },
    security: [
      {
        BearerAuth: [],
      },
    ],
    tags: [
      {
        name: 'Health',
        description: 'ヘルスチェック API',
      },
      {
        name: 'Auth',
        description: '認証 API',
      },
      {
        name: 'Users',
        description: 'ユーザー管理 API',
      },
      {
        name: 'Pets',
        description: 'ペット管理 API',
      },
      {
        name: 'Notifications',
        description: '通知管理 API',
      },
    ],
  },
  apis: [
    './src/server.js',
    './src/routes/*.js',
    './src/controllers/*.js',
  ],
};

const swaggerSpec = swaggerJsdoc(options);

export default swaggerSpec;
