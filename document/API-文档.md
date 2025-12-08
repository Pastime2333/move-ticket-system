# 电影票销售管理系统 API 文档

## 1. 接口基础信息

### 1.1 基本 URL
```
http://localhost:8080/api/v1
```

### 1.2 请求/响应格式
- **请求格式**：JSON
- **响应格式**：JSON
- **编码**：UTF-8

### 1.3 响应状态码
| 状态码 | 描述 |
| ---- | ---- |
| 200 | 请求成功 |
| 400 | 请求参数错误 |
| 401 | 未授权 |
| 403 | 禁止访问 |
| 404 | 资源不存在 |
| 500 | 服务器内部错误 |

### 1.4 认证方式
- **用户认证**：JWT Token
- **管理员认证**：JWT Token
- **Token 传递方式**：Authorization Header，格式为 `Bearer {token}`

## 2. 用户认证模块

### 2.1 用户注册

**URL**：`/auth/register`
**方法**：`POST`
**请求体**：
```json
{
  "username": "string",
  "nickname": "string",
  "phone": "string",
  "password": "string",
  "avatarUrl": "string"
}
```
**响应**：
```json
{
  "code": 200,
  "message": "注册成功",
  "data": {
    "userId": 1,
    "username": "string",
    "nickname": "string",
    "phone": "string",
    "avatarUrl": "string"
  }
}
```

### 2.2 用户登录

**URL**：`/auth/login`
**方法**：`POST`
**请求体**：
```json
{
  "phone": "string",
  "password": "string"
}
```
**响应**：
```json
{
  "code": 200,
  "message": "登录成功",
  "data": {
    "token": "string",
    "user": {
      "userId": 1,
      "username": "string",
      "nickname": "string",
      "phone": "string",
      "avatarUrl": "string"
    }
  }
}
```

### 2.3 管理员登录

**URL**：`/auth/admin/login`
**方法**：`POST`
**请求体**：
```json
{
  "username": "string",
  "password": "string"
}
```
**响应**：
```json
{
  "code": 200,
  "message": "登录成功",
  "data": {
    "token": "string",
    "admin": {
      "adminId": 1,
      "username": "string",
      "realName": "string",
      "role": "string"
    }
  }
}
```

### 2.4 管理员注册

**URL**：`/auth/admin/register`
**方法**：`POST`
**认证**：需要超级管理员 Token
**请求体**：
```json
{
  "username": "string",
  "password": "string",
  "realName": "string",
  "email": "string",
  "phone": "string",
  "role": "string"
}
```
**响应**：
```json
{
  "code": 200,
  "message": "注册成功",
  "data": {
    "adminId": 1,
    "username": "string",
    "realName": "string",
    "email": "string",
    "phone": "string",
    "role": "string"
  }
}
```

## 3. 用户管理模块

### 3.1 获取用户信息

**URL**：`/users/me`
**方法**：`GET`
**认证**：需要用户 Token
**响应**：
```json
{
  "code": 200,
  "message": "获取成功",
  "data": {
      "userId": 1,
      "username": "string",
      "nickname": "string",
      "phone": "string",
      "avatarUrl": "string",
      "createdAt": "string"
    }
}
```

### 3.2 更新用户信息

**URL**：`/users/me`
**方法**：`PUT`
**认证**：需要用户 Token
**请求体**：
```json
{
  "username": "string",
  "nickname": "string",
  "avatarUrl": "string",
  "currentPassword": "string",
  "newPassword": "string"
}
```
**说明**：
- 当需要更改密码时，必须同时提供`currentPassword`（当前密码）和`newPassword`（新密码）
- 如果仅更新其他信息，无需提供密码相关字段

**响应**：
```json
{
  "code": 200,
  "message": "更新成功",
  "data": {
      "userId": 1,
      "username": "string",
      "nickname": "string",
      "phone": "string",
      "avatarUrl": "string",
      "createdAt": "string"
    }
}
```

## 4. 影片管理模块

### 4.1 获取正在热映影片列表

**URL**：`/movies/now-playing`
**方法**：`GET`
**请求参数**：
- `page`：页码，默认 1
- `limit`：每页数量，默认 10
**响应**：
```json
{
  "code": 200,
  "message": "获取成功",
  "data": {
    "total": 100,
    "page": 1,
    "limit": 10,
    "movies": [
      {
        "movieId": 1,
        "title": "沙丘2",
        "originalTitle": "Dune: Part Two",
        "tmdbId": 438631,
        "duration": 166,
        "releaseDate": "2024-03-01",
        "language": "English",
        "country": "United States",
        "rating": "PG-13",
        "synopsis": "保罗·厄崔迪与弗雷曼人联手，向背叛他家族的人复仇。",
        "posterUrl": "string",
        "backdropUrl": "string",
        "status": "released"
      }
    ]
  }
}
```

### 4.2 获取影片详情

**URL**：`/movies/{movieId}`
**方法**：`GET`
**响应**：
```json
{
  "code": 200,
  "message": "获取成功",
  "data": {
      "movieId": 1,
      "title": "沙丘2",
      "originalTitle": "Dune: Part Two",
      "tmdbId": 438631,
      "duration": 166,
      "releaseDate": "2024-03-01",
      "language": "English",
      "country": "USA",
      "rating": "PG-13",
      "synopsis": "string",
      "posterUrl": "string",
      "backdropUrl": "string",
      "status": "released",
      "genres": ["科幻", "冒险"],
      "actors": [
        {
          "actorId": 1,
          "name": "提莫西·查拉梅",
          "avatarUrl": "string"
        }
      ]
    }
}
```

### 4.3 新增影片（管理员）

**URL**：`/movies`
**方法**：`POST`
**认证**：需要管理员 Token
**请求体**：
```json
{
  "title": "string",
  "originalTitle": "string",
  "tmdbId": 123456,
  "duration": 120,
  "releaseDate": "2024-01-01",
  "language": "string",
  "country": "string",
  "rating": "string",
  "synopsis": "string",
  "posterUrl": "string",
  "backdropUrl": "string",
  "status": "upcoming",
  "genreIds": [1, 2],
  "actors": [
    {
      "actorId": 1,
      "roleName": "string"
    }
  ]
}
```
**响应**：
```json
{
  "code": 200,
  "message": "新增成功",
  "data": {
      "movieId": 1
    }
}
```

## 5. 影厅与座位模块

### 5.1 获取影厅列表

**URL**：`/halls`
**方法**：`GET`
**响应**：
```json
{
  "code": 200,
  "message": "获取成功",
  "data": [
    {
      "hallId": 1,
      "hallName": "3号厅",
      "totalSeats": 100,
      "hallType": "standard",
      "status": 0
    }
  ]
}
```

### 5.2 获取影厅座位信息

**URL**：`/halls/{hallId}/seats`
**方法**：`GET`
**响应**：
```json
{
  "code": 200,
  "message": "获取成功",
  "data": {
      "hallId": 1,
      "hallName": "3号厅",
      "seats": [
        {
          "seatId": 1,
          "rowLabel": "A",
          "colNumber": 1,
          "isAvailable": true
        }
      ]
    }
}
```

## 6. 排片与场次模块

### 6.1 获取影片排片列表

**URL**：`/schedules`
**方法**：`GET`
**请求参数**：
- `movieId`：影片 ID，必填
- `date`：日期，格式 YYYY-MM-DD，必填
**响应**：
```json
{
  "code": 200,
  "message": "获取成功",
  "data": [
      {
        "scheduleId": 1,
        "movieId": 1,
        "hallId": 1,
        "hallName": "3号厅",
        "startTime": "2024-12-01 19:30:00",
        "price": 45.00
      }
    ]
}
```

### 6.2 获取场次座位状态

**URL**：`/schedules/{scheduleId}/seats`
**方法**：`GET`
**响应**：
```json
{
  "code": 200,
  "message": "获取成功",
  "data": {
      "scheduleId": 1,
      "hallId": 1,
      "seats": [
        {
          "seatId": 1,
          "rowLabel": "A",
          "colNumber": 1,
          "isAvailable": true,
          "isSold": false
        }
      ]
    }
}
```

## 7. 订单管理模块

### 7.1 创建订单

**URL**：`/orders`
**方法**：`POST`
**认证**：需要用户 Token
**请求体**：
```json
{
  "scheduleId": 1,
  "seatIds": [1, 2, 3]
}
```
**响应**：
```json
{
  "code": 200,
  "message": "创建成功",
  "data": {
    "orderId": 1,
    "totalAmount": 135.00,
    "status": "pending"
  }
}
```

### 7.2 支付订单

**URL**：`/orders/{orderId}/pay`
**方法**：`POST`
**认证**：需要用户 Token
**响应**：
```json
{
  "code": 200,
  "message": "支付成功",
  "data": {
      "orderId": 1,
      "status": "paid",
      "qrCode": "string",
      "paidAt": "2024-12-01 19:30:00"
    }
}
```

### 7.3 获取用户订单列表

**URL**：`/orders`
**方法**：`GET`
**认证**：需要用户 Token
**请求参数**：
- `page`：页码，默认 1
- `limit`：每页数量，默认 10
- `status`：订单状态，可选
**响应**：
```json
{
  "code": 200,
  "message": "获取成功",
  "data": {
    "total": 10,
    "page": 1,
    "limit": 10,
    "orders": [
      {
        "orderId": 1,
        "movieTitle": "沙丘2",
        "startTime": "2024-12-01 19:30:00",
        "hallName": "3号厅",
        "seats": "A1,A2,A3",
        "totalAmount": 135.00,
        "status": "paid",
        "createdAt": "2024-12-01 18:00:00"
      }
    ]
  }
}
```

### 7.4 获取订单详情

**URL**：`/orders/{orderId}`
**方法**：`GET`
**认证**：需要用户 Token
**响应**：
```json
{
  "code": 200,
  "message": "获取成功",
  "data": {
      "orderId": 1,
      "userId": 1,
      "scheduleId": 1,
      "movieTitle": "沙丘2",
      "startTime": "2024-12-01 19:30:00",
      "hallName": "3号厅",
      "seats": [
        {
          "seatId": 1,
          "rowLabel": "A",
          "colNumber": 1
        }
      ],
      "totalAmount": 45.00,
      "status": "paid",
      "qrCode": "string",
      "createdAt": "2024-12-01 18:00:00",
      "paidAt": "2024-12-01 18:05:00"
    }
}
```

## 8. 评论管理模块

### 8.1 获取影片评论

**URL**：`/movies/{movieId}/reviews`
**方法**：`GET`
**请求参数**：
- `page`：页码，默认 1
- `limit`：每页数量，默认 10
**响应**：
```json
{
  "code": 200,
  "message": "获取成功",
  "data": {
    "total": 50,
    "page": 1,
    "limit": 10,
    "reviews": [
      {
        "reviewId": 1,
        "userId": 1,
        "username": "string",
        "rating": 8,
        "commentText": "非常好看！",
        "createdAt": "2024-12-01 19:30:00",
        "likesCount": 10,
        "replies": [
          {
            "replyId": 1,
            "userId": 2,
            "username": "string",
            "replyText": "同意！",
            "createdAt": "2024-12-01 20:00:00"
          }
        ]
      }
    ]
  }
}
```

### 8.2 添加评论

**URL**：`/movies/{movieId}/reviews`
**方法**：`POST`
**认证**：需要用户 Token
**请求体**：
```json
{
  "rating": 8,
  "commentText": "非常好看！"
}
```
**响应**：
```json
{
  "code": 200,
  "message": "添加成功",
  "data": {
      "reviewId": 1
    }
}
```

## 9. 管理员统计模块

### 9.1 获取仪表盘数据

**URL**：`/admin/dashboard`
**方法**：`GET`
**认证**：需要管理员 Token
**响应**：
```json
{
  "code": 200,
  "message": "获取成功",
  "data": {
    "todayOrders": 248,
    "todayRevenue": 12400.00,
    "occupancyRate": 68,
    "pendingRefunds": 3
  }
}
```

## 10. 错误码说明

| 错误码 | 描述 |
| ---- | ---- |
| 10001 | 用户名已存在 |
| 10002 | 手机号已存在 |
| 10003 | 手机号格式错误 |
| 10004 | 密码错误 |
| 10005 | 用户不存在 |
| 10006 | 新密码格式错误 |
| 20001 | 影片不存在 |
| 20002 | 影厅不存在 |
| 20003 | 场次不存在 |
| 20004 | 座位不可用 |
| 30001 | 订单不存在 |
| 30002 | 订单状态错误 |
| 40001 | 权限不足 |
| 50000 | 系统错误 |

## 11. 数据模型说明

### 11.1 用户模型 (User)
| 字段名 | 类型 | 描述 |
| ---- | ---- | ---- |
| userId | INT | 用户唯一ID |
| username | VARCHAR(50) | 用户名 |
| nickname | VARCHAR(50) | 昵称 |
| phone | VARCHAR(20) | 手机号 |
| passwordHash | VARCHAR(255) | 密码哈希 |
| avatarUrl | VARCHAR(255) | 头像URL |
| status | TINYINT | 状态：0-正常，1-封禁 |
| createdAt | DATETIME | 创建时间 |

### 11.2 影片模型 (Movie)
| 字段名 | 类型 | 描述 |
| ---- | ---- | ---- |
| movieId | INT | 影片唯一ID |
| title | VARCHAR(150) | 影片中文名称 |
| originalTitle | VARCHAR(150) | 原始语言片名 |
| tmdbId | INT | TMDb唯一ID，用于对接第三方API |
| duration | INT | 片长（分钟） |
| releaseDate | DATE | 上映日期 |
| language | VARCHAR(50) | 主要对白语言 |
| country | VARCHAR(100) | 制片国家或地区 |
| rating | VARCHAR(20) | 内容分级 |
| synopsis | TEXT | 剧情简介 |
| posterUrl | VARCHAR(255) | 主海报URL |
| backdropUrl | VARCHAR(255) | 背景图URL |
| status | ENUM | 状态：upcoming-即将上映，released-已上映，removed-已下架 |

### 11.3 订单模型 (Order)
| 字段名 | 类型 | 描述 |
| ---- | ---- | ---- |
| orderId | INT | 订单唯一ID |
| userId | INT | 下单用户ID |
| scheduleId | INT | 关联的场次ID |
| totalAmount | DECIMAL(10,2) | 订单总金额 |
| status | ENUM | 订单状态：pending-待支付，paid-已支付，cancelled-已取消，refunded-已退款 |
| qrCode | VARCHAR(255) | 电子票二维码 |
| createdAt | DATETIME | 订单创建时间 |
| paidAt | DATETIME | 支付完成时间 |

### 11.4 管理员模型 (Admin)
| 字段名 | 类型 | 描述 |
| ---- | ---- | ---- |
| adminId | INT | 管理员唯一ID |
| username | VARCHAR(50) | 登录账号（唯一） |
| passwordHash | VARCHAR(255) | 密码哈希 |
| realName | VARCHAR(50) | 真实姓名 |
| email | VARCHAR(100) | 联系邮箱 |
| phone | VARCHAR(20) | 联系电话 |
| role | ENUM | 角色类型：super_admin-超级管理员，film_manager-影片与排片管理员，hall_operator-影厅与场次操作员，customer_service-客服 |
| createdAt | DATETIME | 创建时间 |

---

**文档版本**：v1.0
**更新日期**：2024-12-01
**作者**：系统开发团队