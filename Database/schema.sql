-- ============================================
-- ReefLife 数据库架构设计
-- 版本: 1.0.0
-- 数据库: PostgreSQL (Supabase)
-- ============================================

-- 启用必要的扩展
CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA extensions;
CREATE EXTENSION IF NOT EXISTS "pg_trgm";  -- 用于模糊搜索

-- ============================================
-- 枚举类型定义
-- ============================================

-- 帖子标签枚举
CREATE TYPE post_tag AS ENUM (
    'show_tank',      -- 晒缸
    'discussion',     -- 讨论
    'help',           -- 求助
    'encyclopedia',   -- 百科
    'fun_facts'       -- 趣闻
);

-- 频道分类枚举
CREATE TYPE channel_category AS ENUM (
    'marine_life',    -- 海水生物
    'equipment',      -- 器材讨论
    'marketplace',    -- 交易市场
    'general'         -- 综合讨论
);

-- 物种分类枚举
CREATE TYPE species_category AS ENUM (
    'fish',           -- 鱼类
    'sps',            -- SPS珊瑚
    'lps',            -- LPS珊瑚
    'invertebrate'    -- 无脊椎动物
);

-- 难度等级枚举
CREATE TYPE difficulty_level AS ENUM (
    'easy',           -- 简单
    'medium',         -- 中等
    'hard'            -- 困难
);

-- 珊瑚安全性枚举
CREATE TYPE coral_safety AS ENUM (
    'safe',           -- 安全
    'caution',        -- 需注意
    'unsafe'          -- 不安全
);

-- 举报类型枚举
CREATE TYPE report_type AS ENUM (
    'spam',           -- 垃圾信息
    'harassment',     -- 骚扰
    'inappropriate',  -- 不当内容
    'misinformation', -- 虚假信息
    'other'           -- 其他
);

-- 通知类型枚举
CREATE TYPE notification_type AS ENUM (
    'like',           -- 点赞
    'comment',        -- 评论
    'reply',          -- 回复
    'follow',         -- 关注
    'mention',        -- @提及
    'system'          -- 系统通知
);

-- ============================================
-- 用户表
-- ============================================
CREATE TABLE users (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    username VARCHAR(50) NOT NULL UNIQUE,
    avatar_url TEXT,
    title VARCHAR(100) DEFAULT '新手鱼友',  -- 称号
    bio TEXT DEFAULT '',

    -- 统计字段（使用触发器维护）
    post_count INTEGER DEFAULT 0 CHECK (post_count >= 0),
    favorite_count INTEGER DEFAULT 0 CHECK (favorite_count >= 0),
    reputation INTEGER DEFAULT 0,
    reply_count INTEGER DEFAULT 0 CHECK (reply_count >= 0),
    followers_count INTEGER DEFAULT 0 CHECK (followers_count >= 0),
    following_count INTEGER DEFAULT 0 CHECK (following_count >= 0),

    -- 时间戳
    joined_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    last_active_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),

    -- 账户状态
    is_verified BOOLEAN DEFAULT FALSE,
    is_banned BOOLEAN DEFAULT FALSE,
    ban_reason TEXT,

    -- 设置
    settings JSONB DEFAULT '{
        "push_notifications": true,
        "email_notifications": true,
        "show_online_status": true,
        "allow_direct_messages": true
    }'::jsonb
);

-- 用户名索引（用于搜索）
CREATE INDEX idx_users_username_trgm ON users USING gin (username gin_trgm_ops);
CREATE INDEX idx_users_joined_at ON users (joined_at DESC);
CREATE INDEX idx_users_reputation ON users (reputation DESC);

-- ============================================
-- 频道表
-- ============================================
CREATE TABLE channels (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(100) NOT NULL,
    description TEXT,
    image_url TEXT,
    icon_name VARCHAR(50),  -- SF Symbol 名称
    category channel_category NOT NULL,

    -- 统计
    member_count INTEGER DEFAULT 0 CHECK (member_count >= 0),
    post_count INTEGER DEFAULT 0 CHECK (post_count >= 0),

    -- 状态
    is_hot BOOLEAN DEFAULT FALSE,
    is_official BOOLEAN DEFAULT FALSE,
    is_active BOOLEAN DEFAULT TRUE,

    -- 时间戳
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),

    -- 管理
    created_by UUID REFERENCES users(id) ON DELETE SET NULL,
    rules TEXT[]  -- 频道规则列表
);

CREATE INDEX idx_channels_category ON channels (category);
CREATE INDEX idx_channels_is_hot ON channels (is_hot) WHERE is_hot = TRUE;
CREATE INDEX idx_channels_member_count ON channels (member_count DESC);

-- ============================================
-- 频道成员关系表
-- ============================================
CREATE TABLE channel_members (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    channel_id UUID NOT NULL REFERENCES channels(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    role VARCHAR(20) DEFAULT 'member',  -- member, moderator, admin
    joined_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),

    UNIQUE(channel_id, user_id)
);

CREATE INDEX idx_channel_members_user ON channel_members (user_id);
CREATE INDEX idx_channel_members_channel ON channel_members (channel_id);

-- ============================================
-- 帖子表
-- ============================================
CREATE TABLE posts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    author_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    channel_id UUID NOT NULL REFERENCES channels(id) ON DELETE CASCADE,

    -- 内容
    title VARCHAR(200) NOT NULL,
    content TEXT NOT NULL,
    image_urls TEXT[] DEFAULT '{}',
    tags post_tag[] DEFAULT '{}',

    -- 统计（使用触发器维护）
    upvotes INTEGER DEFAULT 0 CHECK (upvotes >= 0),
    downvotes INTEGER DEFAULT 0 CHECK (downvotes >= 0),
    comment_count INTEGER DEFAULT 0 CHECK (comment_count >= 0),
    view_count INTEGER DEFAULT 0 CHECK (view_count >= 0),
    bookmark_count INTEGER DEFAULT 0 CHECK (bookmark_count >= 0),

    -- 状态
    is_pinned BOOLEAN DEFAULT FALSE,
    is_featured BOOLEAN DEFAULT FALSE,
    is_locked BOOLEAN DEFAULT FALSE,  -- 锁定后不能评论
    is_deleted BOOLEAN DEFAULT FALSE,

    -- 时间戳
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    last_activity_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),

    -- 搜索向量
    search_vector TSVECTOR
);

-- 帖子索引
CREATE INDEX idx_posts_author ON posts (author_id);
CREATE INDEX idx_posts_channel ON posts (channel_id);
CREATE INDEX idx_posts_created_at ON posts (created_at DESC);
CREATE INDEX idx_posts_upvotes ON posts (upvotes DESC);
CREATE INDEX idx_posts_tags ON posts USING gin (tags);
CREATE INDEX idx_posts_search ON posts USING gin (search_vector);
CREATE INDEX idx_posts_not_deleted ON posts (id) WHERE is_deleted = FALSE;

-- 全文搜索触发器
CREATE OR REPLACE FUNCTION posts_search_trigger()
RETURNS TRIGGER AS $$
BEGIN
    NEW.search_vector :=
        setweight(to_tsvector('simple', COALESCE(NEW.title, '')), 'A') ||
        setweight(to_tsvector('simple', COALESCE(NEW.content, '')), 'B');
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER posts_search_update
    BEFORE INSERT OR UPDATE OF title, content ON posts
    FOR EACH ROW
    EXECUTE FUNCTION posts_search_trigger();

-- ============================================
-- 帖子投票表
-- ============================================
CREATE TABLE post_votes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    post_id UUID NOT NULL REFERENCES posts(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    vote_type SMALLINT NOT NULL CHECK (vote_type IN (-1, 1)),  -- 1=upvote, -1=downvote
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),

    UNIQUE(post_id, user_id)
);

CREATE INDEX idx_post_votes_post ON post_votes (post_id);
CREATE INDEX idx_post_votes_user ON post_votes (user_id);

-- ============================================
-- 帖子收藏表
-- ============================================
CREATE TABLE post_bookmarks (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    post_id UUID NOT NULL REFERENCES posts(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),

    UNIQUE(post_id, user_id)
);

CREATE INDEX idx_post_bookmarks_user ON post_bookmarks (user_id);
CREATE INDEX idx_post_bookmarks_post ON post_bookmarks (post_id);

-- ============================================
-- 评论表（支持嵌套）
-- ============================================
CREATE TABLE comments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    post_id UUID NOT NULL REFERENCES posts(id) ON DELETE CASCADE,
    author_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    parent_id UUID REFERENCES comments(id) ON DELETE CASCADE,  -- 父评论ID，用于嵌套

    -- 内容
    content TEXT NOT NULL,

    -- 统计
    likes INTEGER DEFAULT 0 CHECK (likes >= 0),
    reply_count INTEGER DEFAULT 0 CHECK (reply_count >= 0),

    -- 状态
    is_deleted BOOLEAN DEFAULT FALSE,

    -- 时间戳
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),

    -- 层级信息（优化嵌套查询）
    depth INTEGER DEFAULT 0 CHECK (depth >= 0 AND depth <= 3),  -- 最多3层嵌套
    path TEXT[]  -- 存储从根到当前的ID路径
);

CREATE INDEX idx_comments_post ON comments (post_id);
CREATE INDEX idx_comments_author ON comments (author_id);
CREATE INDEX idx_comments_parent ON comments (parent_id);
CREATE INDEX idx_comments_created_at ON comments (created_at DESC);
CREATE INDEX idx_comments_path ON comments USING gin (path);

-- ============================================
-- 评论点赞表
-- ============================================
CREATE TABLE comment_likes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    comment_id UUID NOT NULL REFERENCES comments(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),

    UNIQUE(comment_id, user_id)
);

CREATE INDEX idx_comment_likes_comment ON comment_likes (comment_id);
CREATE INDEX idx_comment_likes_user ON comment_likes (user_id);

-- ============================================
-- 用户关注关系表
-- ============================================
CREATE TABLE user_follows (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    follower_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    following_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),

    UNIQUE(follower_id, following_id),
    CHECK (follower_id != following_id)  -- 不能关注自己
);

CREATE INDEX idx_user_follows_follower ON user_follows (follower_id);
CREATE INDEX idx_user_follows_following ON user_follows (following_id);

-- ============================================
-- 物种百科表
-- ============================================
CREATE TABLE species (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    -- 基本信息
    common_name VARCHAR(100) NOT NULL,
    scientific_name VARCHAR(150),
    category species_category NOT NULL,
    difficulty difficulty_level NOT NULL,
    temperament VARCHAR(50),  -- 温和/半攻击/攻击
    coral_safe coral_safety,
    diet VARCHAR(100),  -- 杂食/草食/肉食

    -- 尺寸和水族箱要求
    size_range VARCHAR(50),   -- 例如: "5-8cm"
    min_tank_size INTEGER,    -- 最小缸体积（升）

    -- 水质参数
    temperature VARCHAR(50),  -- 例如: "24-26°C"
    ph VARCHAR(20),           -- 例如: "8.1-8.4"
    salinity VARCHAR(50),     -- 例如: "1.023-1.025"

    -- 详细描述
    description TEXT,
    care_tips TEXT,           -- 饲养建议
    image_urls TEXT[] DEFAULT '{}',
    origin VARCHAR(100),      -- 产地

    -- 珊瑚特有属性
    light_requirement VARCHAR(50),   -- 低/中/高
    flow_requirement VARCHAR(50),    -- 低/中/高
    calcium VARCHAR(50),             -- 例如: "400-450ppm"
    alkalinity VARCHAR(50),          -- 例如: "8-12dKH"
    magnesium VARCHAR(50),           -- 例如: "1250-1350ppm"

    -- 元数据
    is_verified BOOLEAN DEFAULT FALSE,
    created_by UUID REFERENCES users(id) ON DELETE SET NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),

    -- 搜索
    search_vector TSVECTOR
);

CREATE INDEX idx_species_category ON species (category);
CREATE INDEX idx_species_difficulty ON species (difficulty);
CREATE INDEX idx_species_coral_safe ON species (coral_safe);
CREATE INDEX idx_species_search ON species USING gin (search_vector);
CREATE INDEX idx_species_common_name ON species (common_name);

-- 物种搜索触发器
CREATE OR REPLACE FUNCTION species_search_trigger()
RETURNS TRIGGER AS $$
BEGIN
    NEW.search_vector :=
        setweight(to_tsvector('simple', COALESCE(NEW.common_name, '')), 'A') ||
        setweight(to_tsvector('simple', COALESCE(NEW.scientific_name, '')), 'A') ||
        setweight(to_tsvector('simple', COALESCE(NEW.description, '')), 'B');
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER species_search_update
    BEFORE INSERT OR UPDATE OF common_name, scientific_name, description ON species
    FOR EACH ROW
    EXECUTE FUNCTION species_search_trigger();

-- ============================================
-- 物种收藏表
-- ============================================
CREATE TABLE species_favorites (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    species_id UUID NOT NULL REFERENCES species(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),

    UNIQUE(species_id, user_id)
);

CREATE INDEX idx_species_favorites_user ON species_favorites (user_id);
CREATE INDEX idx_species_favorites_species ON species_favorites (species_id);

-- ============================================
-- 通知表
-- ============================================
CREATE TABLE notifications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    type notification_type NOT NULL,

    -- 关联实体
    actor_id UUID REFERENCES users(id) ON DELETE CASCADE,  -- 触发者
    post_id UUID REFERENCES posts(id) ON DELETE CASCADE,
    comment_id UUID REFERENCES comments(id) ON DELETE CASCADE,

    -- 内容
    title VARCHAR(200),
    body TEXT,
    data JSONB DEFAULT '{}',  -- 额外数据

    -- 状态
    is_read BOOLEAN DEFAULT FALSE,

    -- 时间戳
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_notifications_user ON notifications (user_id);
CREATE INDEX idx_notifications_unread ON notifications (user_id, is_read) WHERE is_read = FALSE;
CREATE INDEX idx_notifications_created_at ON notifications (created_at DESC);

-- ============================================
-- 举报表
-- ============================================
CREATE TABLE reports (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    reporter_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    type report_type NOT NULL,
    reason TEXT,

    -- 被举报的实体（只有一个会被设置）
    reported_user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    reported_post_id UUID REFERENCES posts(id) ON DELETE CASCADE,
    reported_comment_id UUID REFERENCES comments(id) ON DELETE CASCADE,

    -- 处理状态
    status VARCHAR(20) DEFAULT 'pending',  -- pending, reviewed, resolved, dismissed
    resolved_by UUID REFERENCES users(id) ON DELETE SET NULL,
    resolution_note TEXT,

    -- 时间戳
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    resolved_at TIMESTAMP WITH TIME ZONE,

    -- 确保至少举报了一个实体
    CHECK (
        (reported_user_id IS NOT NULL)::INTEGER +
        (reported_post_id IS NOT NULL)::INTEGER +
        (reported_comment_id IS NOT NULL)::INTEGER = 1
    )
);

CREATE INDEX idx_reports_status ON reports (status);
CREATE INDEX idx_reports_reporter ON reports (reporter_id);

-- ============================================
-- 媒体记录表 (Cloudflare R2)
-- ============================================
CREATE TABLE media (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,

    -- 存储信息
    bucket VARCHAR(50) NOT NULL,          -- 'avatars', 'posts', 'species'
    key VARCHAR(500) NOT NULL UNIQUE,     -- R2 对象键
    url TEXT NOT NULL,                    -- CDN URL

    -- 文件信息
    filename VARCHAR(255),
    content_type VARCHAR(100),
    size_bytes BIGINT,
    width INTEGER,
    height INTEGER,

    -- 处理状态
    is_processed BOOLEAN DEFAULT FALSE,
    thumbnail_url TEXT,

    -- 元数据
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_media_user ON media (user_id);
CREATE INDEX idx_media_bucket ON media (bucket);

-- ============================================
-- 用户浏览历史表
-- ============================================
CREATE TABLE view_history (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    post_id UUID REFERENCES posts(id) ON DELETE CASCADE,
    species_id UUID REFERENCES species(id) ON DELETE CASCADE,
    viewed_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),

    CHECK (
        (post_id IS NOT NULL)::INTEGER +
        (species_id IS NOT NULL)::INTEGER = 1
    )
);

CREATE INDEX idx_view_history_user ON view_history (user_id);
CREATE INDEX idx_view_history_viewed_at ON view_history (viewed_at DESC);
