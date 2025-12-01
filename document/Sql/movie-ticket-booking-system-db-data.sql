-- ===========================
-- 基础用户 / 管理员 / 影厅 / 影片 数据
-- ===========================

/* ---------------------- USERS（2个） ---------------------- */
INSERT INTO `user` (username, nickname, phone, password_hash, avatar_url, status)
VALUES
('alice', 'Alice', '13800138000', '$2a$10$abcd1234testhashalice', 'https://example.com/avatar/alice.jpg', 0),
('bob',   'Bob',   '13800138001', '$2a$10$abcd1234testhashbob',   'https://example.com/avatar/bob.jpg',   0);

/* ---------------------- ADMIN（1个 super_admin） ---------------------- */
INSERT INTO `admin` (username, password_hash, real_name, email, phone, role, status)
VALUES
('superadmin', '$2a$10$adminsuperhashedpwd12345', '系统管理员', 'admin@cinema.com', '13900001111', 'super_admin', 0);

/* ---------------------- HALL（4个影厅） ---------------------- */
INSERT INTO `hall` (hall_name, total_seats, hall_type, status)
VALUES
('1号厅',      120, 'standard', 0),
('IMAX厅',     260, 'imax',     0),
('VIP厅',       60, 'vip',      0),
('4D体验厅',    80, '4dx',      0);

/* ---------------------- MOVIE（3部电影） ---------------------- */
INSERT INTO `movie` (title, original_title, tmdb_id, duration, release_date, language, country, rating, synopsis, poster_url, backdrop_url, status)
VALUES
('流浪地球2', 'The Wandering Earth II', 842675, 173, '2023-01-22', 'Chinese', 'China', 'PG-13',
 '人类启动移山计划的前传故事。',
 'https://example.com/poster/wandering_earth2.jpg',
 'https://example.com/backdrop/wandering_earth2.jpg',
 'released'),

('孤注一掷', 'No More Bets', 123456, 130, '2023-08-08', 'Chinese', 'China', 'PG-13',
 '揭露海外诈骗集团内幕的犯罪题材电影。',
 'https://example.com/poster/no_more_bets.jpg',
 'https://example.com/backdrop/no_more_bets.jpg',
 'released'),

('你好，李焕英', 'Hi, Mom', 644479, 128, '2021-02-12', 'Chinese', 'China', 'PG',
 '喜剧与亲情交织，讲述穿越回妈妈年轻时代的故事。',
 'https://example.com/poster/hi_mom.jpg',
 'https://example.com/backdrop/hi_mom.jpg',
 'released');

-- ===========================
-- 类型（genre）与演员（actor）
-- ===========================

/* ---------------------- GENRE（几个常见类型） ---------------------- */
INSERT INTO `genre` (name) VALUES
('科幻'),
('剧情'),
('犯罪'),
('喜剧'),
('家庭');

/* ---------------------- ACTOR（若干演员测试数据） ---------------------- */
INSERT INTO `actor` (name, avatar_url) VALUES
('吴京', 'https://example.com/actor/wujing.jpg'),
('张译', 'https://example.com/actor/zhangyi.jpg'),
('沈腾', 'https://example.com/actor/shenteng.jpg'),
('贾玲', 'https://example.com/actor/jialing.jpg'),
('李一桐', 'https://example.com/actor/liyitong.jpg');

-- ===========================
-- 影片-类型 与 影片-演员 关联（使用子查询以确保 ID 一致）
-- ===========================

/* ---------------------- movie_genre ---------------------- */
/* 流浪地球2 -> 科幻, 剧情 */
INSERT INTO `movie_genre` (movie_id, genre_id)
VALUES
((SELECT movie_id FROM movie WHERE title='流浪地球2'), (SELECT genre_id FROM genre WHERE name='科幻')),
((SELECT movie_id FROM movie WHERE title='流浪地球2'), (SELECT genre_id FROM genre WHERE name='剧情'));

/* 孤注一掷 -> 犯罪, 剧情 */
INSERT INTO `movie_genre` (movie_id, genre_id)
VALUES
((SELECT movie_id FROM movie WHERE title='孤注一掷'), (SELECT genre_id FROM genre WHERE name='犯罪')),
((SELECT movie_id FROM movie WHERE title='孤注一掷'), (SELECT genre_id FROM genre WHERE name='剧情'));

/* 你好，李焕英 -> 喜剧, 家庭 */
INSERT INTO `movie_genre` (movie_id, genre_id)
VALUES
((SELECT movie_id FROM movie WHERE title='你好，李焕英'), (SELECT genre_id FROM genre WHERE name='喜剧')),
((SELECT movie_id FROM movie WHERE title='你好，李焕英'), (SELECT genre_id FROM genre WHERE name='家庭'));

/* ---------------------- movie_actor ---------------------- */
/* 为每部电影添加 2-3 位演员（示例 role_name 可为空或填写角色） */
INSERT INTO `movie_actor` (movie_id, actor_id, role_name)
VALUES
((SELECT movie_id FROM movie WHERE title='流浪地球2'), (SELECT actor_id FROM actor WHERE name='吴京'), '程心（示例）'),
((SELECT movie_id FROM movie WHERE title='流浪地球2'), (SELECT actor_id FROM actor WHERE name='张译'), '雷扬（示例）'),

((SELECT movie_id FROM movie WHERE title='孤注一掷'), (SELECT actor_id FROM actor WHERE name='张译'), '主角（示例）'),
((SELECT movie_id FROM movie WHERE title='孤注一掷'), (SELECT actor_id FROM actor WHERE name='李一桐'), '配角（示例）'),

((SELECT movie_id FROM movie WHERE title='你好，李焕英'), (SELECT actor_id FROM actor WHERE name='沈腾'), '喜剧角色（示例）'),
((SELECT movie_id FROM movie WHERE title='你好，李焕英'), (SELECT actor_id FROM actor WHERE name='贾玲'), '母亲（示例）');

-- ===========================
-- 座位（seat）批量生成（使用递归 CTE，适用于 MySQL 8+）
-- 我已经将行/列组合设置为与 hall.total_seats 一致
-- 1号厅: 10 行 x 12 列 = 120
-- IMAX厅: 13 行 x 20 列 = 260
-- VIP厅: 6 行 x 10 列 = 60
-- 4D体验厅: 8 行 x 10 列 = 80
-- ===========================

-- 1号厅
INSERT INTO seat (hall_id, row_label, col_number, is_available)
WITH RECURSIVE nums AS (
  SELECT 1 AS n
  UNION ALL
  SELECT n + 1 FROM nums WHERE n < 20
)
SELECT h.hall_id, CHAR(64 + r.n) AS row_label, c.n AS col_number, TRUE
FROM (SELECT hall_id FROM hall WHERE hall_name = '1号厅') h
CROSS JOIN (SELECT n FROM nums WHERE n <= 10) r
CROSS JOIN (SELECT n FROM nums WHERE n <= 12) c
ORDER BY r.n, c.n;

-- IMAX厅
INSERT INTO seat (hall_id, row_label, col_number, is_available)
WITH RECURSIVE nums AS (
  SELECT 1 AS n
  UNION ALL
  SELECT n + 1 FROM nums WHERE n < 20
)
SELECT h.hall_id, CHAR(64 + r.n), c.n, TRUE
FROM (SELECT hall_id FROM hall WHERE hall_name = 'IMAX厅') h
CROSS JOIN (SELECT n FROM nums WHERE n <= 13) r
CROSS JOIN (SELECT n FROM nums WHERE n <= 20) c
ORDER BY r.n, c.n;

-- VIP厅
INSERT INTO seat (hall_id, row_label, col_number, is_available)
WITH RECURSIVE nums AS (
  SELECT 1 AS n
  UNION ALL
  SELECT n + 1 FROM nums WHERE n < 20
)
SELECT h.hall_id, CHAR(64 + r.n), c.n, TRUE
FROM (SELECT hall_id FROM hall WHERE hall_name = 'VIP厅') h
CROSS JOIN (SELECT n FROM nums WHERE n <= 6) r
CROSS JOIN (SELECT n FROM nums WHERE n <= 10) c
ORDER BY r.n, c.n;

-- 4D体验厅
INSERT INTO seat (hall_id, row_label, col_number, is_available)
WITH RECURSIVE nums AS (
  SELECT 1 AS n
  UNION ALL
  SELECT n + 1 FROM nums WHERE n < 20
)
SELECT h.hall_id, CHAR(64 + r.n), c.n, TRUE
FROM (SELECT hall_id FROM hall WHERE hall_name = '4D体验厅') h
CROSS JOIN (SELECT n FROM nums WHERE n <= 8) r
CROSS JOIN (SELECT n FROM nums WHERE n <= 10) c
ORDER BY r.n, c.n;

-- ===========================
-- 排片 schedule（示例：为每部电影在不同影厅创建若干场次）
-- 使用子查询避免 ID 假设
-- times 使用明确的日期时间（示例日期：接下来几天），可根据需要调整
-- ===========================

/* 流浪地球2 在 IMAX厅 与 1号厅 的场次 */
INSERT INTO `schedule` (movie_id, hall_id, start_time, price)
VALUES
((SELECT movie_id FROM movie WHERE title='流浪地球2'), (SELECT hall_id FROM hall WHERE hall_name='IMAX厅'),  '2025-12-01 14:00:00', 150.00),
((SELECT movie_id FROM movie WHERE title='流浪地球2'), (SELECT hall_id FROM hall WHERE hall_name='IMAX厅'),  '2025-12-01 19:30:00', 180.00),
((SELECT movie_id FROM movie WHERE title='流浪地球2'), (SELECT hall_id FROM hall WHERE hall_name='1号厅'),     '2025-12-02 16:00:00',  68.00);

/* 孤注一掷 在 1号厅 与 4D体验厅（示例）*/
INSERT INTO `schedule` (movie_id, hall_id, start_time, price)
VALUES
((SELECT movie_id FROM movie WHERE title='孤注一掷'), (SELECT hall_id FROM hall WHERE hall_name='1号厅'),     '2025-12-01 18:00:00',  58.00),
((SELECT movie_id FROM movie WHERE title='孤注一掷'), (SELECT hall_id FROM hall WHERE hall_name='4D体验厅'), '2025-12-02 20:00:00',  88.00);

/* 你好，李焕英 在 VIP厅 与 1号厅 */
INSERT INTO `schedule` (movie_id, hall_id, start_time, price)
VALUES
((SELECT movie_id FROM movie WHERE title='你好，李焕英'), (SELECT hall_id FROM hall WHERE hall_name='VIP厅'), '2025-12-01 12:30:00', 120.00),
((SELECT movie_id FROM movie WHERE title='你好，李焕英'), (SELECT hall_id FROM hall WHERE hall_name='1号厅'), '2025-12-02 10:00:00',  48.00);

-- ===========================
-- 评论（review）与回复（review_reply）
-- 注意：review 表上有 UNIQUE(user_id,movie_id)，所以每个用户对同一影片只插入一次
-- 我们让 alice、bob 各对不同影片留言，示例 rating 在 1-10 之间
-- ===========================

/* alice 对 流浪地球2 的评论 */
INSERT INTO `review` (user_id, movie_id, rating, comment_text)
VALUES
(
  (SELECT user_id FROM `user` WHERE username='alice'),
  (SELECT movie_id FROM `movie` WHERE title='流浪地球2'),
  9,
  '特效和世界观极具冲击力，适合科幻迷观赏。'
);

/* bob 对 你好，李焕英 的评论 */
INSERT INTO `review` (user_id, movie_id, rating, comment_text)
VALUES
(
  (SELECT user_id FROM `user` WHERE username='bob'),
  (SELECT movie_id FROM `movie` WHERE title='你好，李焕英'),
  8,
  '非常感人的喜剧，笑中带泪。'
);

/* review_reply：对 alice 的评论做一个回复（由 admin 或另一个用户回复均可） */
/* 我这里用 superadmin 作为回复者示例（superadmin 也是 admin 表，不在 user 表；review_reply 外键 user_id 指向 user 表，因此此处用另一个用户回复（bob）示例） */
INSERT INTO `review_reply` (review_id, user_id, reply_text)
VALUES
(
  (SELECT r.review_id FROM review r JOIN `user` u ON r.user_id = u.user_id WHERE u.username='alice' AND r.movie_id = (SELECT movie_id FROM movie WHERE title='流浪地球2')),
  (SELECT user_id FROM `user` WHERE username='bob'),
  '同意你的观点，片中很多细节很棒。'
);

-- 结束
