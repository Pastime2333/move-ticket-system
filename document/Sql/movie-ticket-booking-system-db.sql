CREATE TABLE `user` (
    user_id        INT PRIMARY KEY AUTO_INCREMENT COMMENT '用户唯一ID',
    username       VARCHAR(50) UNIQUE NOT NULL COMMENT '登录用户名（唯一）',
    nickname       VARCHAR(50) COMMENT '用户昵称',
    phone          VARCHAR(20) UNIQUE COMMENT '绑定手机号（唯一，用于登录/找回）',
    password_hash  VARCHAR(255) NOT NULL COMMENT '密码哈希值（使用BCrypt加密存储）',
    avatar_url     VARCHAR(255) COMMENT '头像图片URL',
    status         TINYINT NOT NULL DEFAULT 0 COMMENT '账号状态：0-正常，1-封禁',
    created_at     DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '账户创建时间'
) COMMENT = '用户基本信息表';


CREATE TABLE `admin` (
    admin_id       INT PRIMARY KEY AUTO_INCREMENT COMMENT '管理员唯一ID',
    username       VARCHAR(50) NOT NULL UNIQUE COMMENT '登录账号（唯一，如 admin_zhang）',
    password_hash  VARCHAR(255) NOT NULL COMMENT '密码哈希值（使用BCrypt等强加密算法存储）',
    real_name      VARCHAR(50) NOT NULL COMMENT '真实姓名（用于后台显示）',
    email          VARCHAR(100) UNIQUE COMMENT '联系邮箱（可用于找回密码或通知）',
    phone          VARCHAR(20) COMMENT '联系电话（可选）',
    role           ENUM('super_admin', 'film_manager', 'hall_operator', 'customer_service') 
                   NOT NULL DEFAULT 'customer_service' COMMENT '角色类型：
                   - super_admin：超级管理员（全权限）
                   - film_manager：影片与排片管理员
                   - hall_operator：影厅与场次操作员
                   - customer_service：客服（仅可处理订单/用户问题）',
    status         TINYINT NOT NULL DEFAULT 0 COMMENT '账号状态：0-正常，1-已禁用（封禁）',
    last_login_at  DATETIME NULL COMMENT '最后成功登录时间',
    last_login_ip  VARCHAR(45) COMMENT '最后登录IP地址（IPv4/IPv6）',
    created_at     DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '账号创建时间',
    updated_at     DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '信息最后更新时间'
) COMMENT = '系统管理员账户信息表';


#=====================================================================================================================


CREATE TABLE `movie` (
    movie_id        INT PRIMARY KEY AUTO_INCREMENT COMMENT '影片唯一ID',
    title           VARCHAR(150) NOT NULL COMMENT '影片中文名称',
    original_title  VARCHAR(150) COMMENT '原始语言片名（如英文原名）',
    tmdb_id         INT UNIQUE COMMENT 'The Movie Database (TMDb) 唯一ID，用于对接第三方API',
    duration        INT COMMENT '片长（分钟）',
    release_date    DATE COMMENT '中国大陆正式上映日期',
    language        VARCHAR(50) DEFAULT 'Chinese' COMMENT '主要对白语言',
    country         VARCHAR(100) COMMENT '制片国家或地区',
    rating          VARCHAR(20) COMMENT '内容分级（如 PG-13、R、G 等）',
    synopsis        TEXT COMMENT '剧情简介',
    poster_url      VARCHAR(255) COMMENT '主海报图片URL',
    backdrop_url    VARCHAR(255) COMMENT '背景图URL（用于详情页横幅）',
    status          ENUM('upcoming', 'released', 'removed') 
                    NOT NULL DEFAULT 'upcoming' COMMENT '影片状态：
                    - upcoming：即将上映（release_date 未来）
                    - released：已上映（release_date <= 当前日期）
                    - removed：已下架（因版权/违规等原因不再展示）',
    created_at      DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '记录创建时间',
    updated_at      DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '记录最后更新时间'
) COMMENT = '影片主信息表（仅含三种业务状态，符合3NF）';


-- 类型字典
CREATE TABLE `genre` (
    genre_id INT PRIMARY KEY AUTO_INCREMENT,
    name     VARCHAR(50) NOT NULL UNIQUE COMMENT '类型名称'
) COMMENT = '影片类型表';

-- 演员表
CREATE TABLE `actor` (
    actor_id   INT PRIMARY KEY AUTO_INCREMENT,
    name       VARCHAR(100) NOT NULL UNIQUE COMMENT '演员姓名',
    avatar_url VARCHAR(255) COMMENT '头像URL'
) COMMENT = '演员信息表';

-- 多对多关联
CREATE TABLE `movie_genre` (
    movie_id INT,
    genre_id INT,
    PRIMARY KEY (movie_id, genre_id),
    FOREIGN KEY (movie_id) REFERENCES movie(movie_id) ON DELETE CASCADE,
    FOREIGN KEY (genre_id) REFERENCES genre(genre_id)
) COMMENT = '影片-类型关联表';

CREATE TABLE `movie_actor` (
    movie_id   INT,
    actor_id   INT,
    role_name  VARCHAR(100) COMMENT '饰演角色名（可选）',
    PRIMARY KEY (movie_id, actor_id),
    FOREIGN KEY (movie_id) REFERENCES movie(movie_id) ON DELETE CASCADE,
    FOREIGN KEY (actor_id) REFERENCES actor(actor_id)
) COMMENT = '影片-演员关联表';


#=====================================================================================================================


CREATE TABLE `hall` (
    hall_id        INT PRIMARY KEY AUTO_INCREMENT COMMENT '影厅唯一ID',
    hall_name      VARCHAR(50) NOT NULL COMMENT '影厅名称（如：1号厅、IMAX巨幕厅、VIP厅）',
    total_seats    INT NOT NULL COMMENT '座位总数（可用于快速展示，也可由seat表统计得出）',
    hall_type      VARCHAR(30) DEFAULT 'standard' COMMENT '影厅类型：standard-普通厅, imax-IMAX厅, vip-VIP厅, 4dx-4D厅等',
    status         TINYINT NOT NULL DEFAULT 0 COMMENT '状态：0-正常可用，1-暂停使用（如维修中）',
    created_at     DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '记录创建时间'
) COMMENT = '影院内影厅信息表（系统仅服务于单一影院）';


#=====================================================================================================================


CREATE TABLE `schedule` (
    schedule_id    INT PRIMARY KEY AUTO_INCREMENT COMMENT '场次唯一ID',
    movie_id       INT NOT NULL COMMENT '关联的影片ID',
    hall_id        INT NOT NULL COMMENT '放映影厅ID',
    start_time     DATETIME NOT NULL COMMENT '放映开始时间',
    price          DECIMAL(10,2) NOT NULL COMMENT '该场次票价（单位：元）',
    FOREIGN KEY (movie_id) REFERENCES movie(movie_id),
    FOREIGN KEY (hall_id) REFERENCES hall(hall_id),
    INDEX idx_movie_time (movie_id, start_time) COMMENT '按影片和时间查询索引',
    INDEX idx_hall_time (hall_id, start_time) COMMENT '按影厅和时间查询索引'
) COMMENT = '影片排片场次表';


CREATE TABLE `seat` (
    seat_id        INT PRIMARY KEY AUTO_INCREMENT COMMENT '座位唯一ID',
    hall_id        INT NOT NULL COMMENT '所属影厅ID',
    row_label      CHAR(2) NOT NULL COMMENT '座位行标识（如：A, B, AA）',
    col_number     INT NOT NULL COMMENT '座位列号（如：1, 2, 3）',
    is_available   BOOLEAN DEFAULT TRUE COMMENT '是否可用（false表示维修/拆除）',
    UNIQUE (hall_id, row_label, col_number) COMMENT '确保同一影厅内座位位置唯一',
    FOREIGN KEY (hall_id) REFERENCES hall(hall_id)
) COMMENT = '影厅座位物理布局表';


#=====================================================================================================================


CREATE TABLE `orders` (
    order_id       INT PRIMARY KEY AUTO_INCREMENT COMMENT '订单唯一ID',
    user_id        INT NOT NULL COMMENT '下单用户ID',
    schedule_id    INT NOT NULL COMMENT '关联的场次ID',
    total_amount   DECIMAL(10,2) NOT NULL COMMENT '订单总金额（单位：元）',
    status         ENUM('pending', 'paid', 'cancelled', 'refunded') DEFAULT 'pending' COMMENT '订单状态：待支付 / 已支付 / 已取消 / 已退款',
    qr_code        VARCHAR(255) UNIQUE COMMENT '电子票二维码唯一标识（用于核验入场）',
    created_at     DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '订单创建时间',
    paid_at        DATETIME NULL COMMENT '支付完成时间（未支付则为NULL）',
    FOREIGN KEY (user_id) REFERENCES user(user_id),
    FOREIGN KEY (schedule_id) REFERENCES schedule(schedule_id)
) COMMENT = '用户购票订单主表';


CREATE TABLE `order_item` (
    item_id        INT PRIMARY KEY AUTO_INCREMENT COMMENT '订单项唯一ID',
    order_id       INT NOT NULL COMMENT '所属订单ID',
    seat_id        INT NOT NULL COMMENT '所选座位ID',
    schedule_id    INT NOT NULL COMMENT '冗余字段：用于快速校验座位与场次匹配（提升查询效率）',
    FOREIGN KEY (order_id) REFERENCES orders(order_id) ON DELETE CASCADE,
    FOREIGN KEY (seat_id) REFERENCES seat(seat_id),
    FOREIGN KEY (schedule_id) REFERENCES schedule(schedule_id),
    UNIQUE (schedule_id, seat_id) COMMENT '确保同一场次的同一座位不被重复售出（防止超卖核心约束）'
) COMMENT = '订单座位明细表（支持一张订单购买多个座位）';


#=====================================================================================================================


CREATE TABLE `review` (
    review_id      INT PRIMARY KEY AUTO_INCREMENT COMMENT '评论唯一ID',
    user_id        INT NOT NULL COMMENT '评论用户ID',
    movie_id       INT NOT NULL COMMENT '被评论的影片ID',
    rating         TINYINT CHECK (rating BETWEEN 1 AND 10) COMMENT '评分（1-10分）',
    comment_text   TEXT COMMENT '文字评论内容',
    created_at     DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '评论发布时间',
    likes_count    INT DEFAULT 0 COMMENT '点赞数（可由异步任务或触发器更新）',
    FOREIGN KEY (user_id) REFERENCES user(user_id),
    FOREIGN KEY (movie_id) REFERENCES movie(movie_id),
    UNIQUE (user_id, movie_id) COMMENT '限制每位用户对每部影片只能评论一次'
) COMMENT = '用户对影片的评分与评论表';


CREATE TABLE `review_reply` (
    reply_id       INT PRIMARY KEY AUTO_INCREMENT COMMENT '回复唯一ID',
    review_id      INT NOT NULL COMMENT '被回复的评论ID',
    user_id        INT NOT NULL COMMENT '回复者用户ID',
    reply_text     TEXT NOT NULL COMMENT '回复内容',
    created_at     DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '回复时间',
    FOREIGN KEY (review_id) REFERENCES review(review_id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES user(user_id)
) COMMENT = '对评论的回复（支持互动讨论）';