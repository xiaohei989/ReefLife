-- ============================================
-- ReefLife 触发器和函数
-- ============================================

-- ============================================
-- 统计字段自动更新触发器
-- ============================================

-- 更新帖子统计
CREATE OR REPLACE FUNCTION update_post_stats()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_TABLE_NAME = 'post_votes' THEN
        IF TG_OP = 'INSERT' THEN
            IF NEW.vote_type = 1 THEN
                UPDATE posts SET upvotes = upvotes + 1 WHERE id = NEW.post_id;
            ELSE
                UPDATE posts SET downvotes = downvotes + 1 WHERE id = NEW.post_id;
            END IF;
        ELSIF TG_OP = 'DELETE' THEN
            IF OLD.vote_type = 1 THEN
                UPDATE posts SET upvotes = upvotes - 1 WHERE id = OLD.post_id;
            ELSE
                UPDATE posts SET downvotes = downvotes - 1 WHERE id = OLD.post_id;
            END IF;
        ELSIF TG_OP = 'UPDATE' THEN
            -- 改变投票类型
            IF OLD.vote_type = 1 AND NEW.vote_type = -1 THEN
                UPDATE posts SET upvotes = upvotes - 1, downvotes = downvotes + 1 WHERE id = NEW.post_id;
            ELSIF OLD.vote_type = -1 AND NEW.vote_type = 1 THEN
                UPDATE posts SET upvotes = upvotes + 1, downvotes = downvotes - 1 WHERE id = NEW.post_id;
            END IF;
        END IF;
    ELSIF TG_TABLE_NAME = 'post_bookmarks' THEN
        IF TG_OP = 'INSERT' THEN
            UPDATE posts SET bookmark_count = bookmark_count + 1 WHERE id = NEW.post_id;
            UPDATE users SET favorite_count = favorite_count + 1 WHERE id = NEW.user_id;
        ELSIF TG_OP = 'DELETE' THEN
            UPDATE posts SET bookmark_count = bookmark_count - 1 WHERE id = OLD.post_id;
            UPDATE users SET favorite_count = favorite_count - 1 WHERE id = OLD.user_id;
        END IF;
    ELSIF TG_TABLE_NAME = 'comments' THEN
        IF TG_OP = 'INSERT' AND NOT NEW.is_deleted THEN
            UPDATE posts SET
                comment_count = comment_count + 1,
                last_activity_at = NOW()
            WHERE id = NEW.post_id;
            UPDATE users SET reply_count = reply_count + 1 WHERE id = NEW.author_id;
            -- 更新父评论的回复数
            IF NEW.parent_id IS NOT NULL THEN
                UPDATE comments SET reply_count = reply_count + 1 WHERE id = NEW.parent_id;
            END IF;
        ELSIF TG_OP = 'UPDATE' AND OLD.is_deleted = FALSE AND NEW.is_deleted = TRUE THEN
            UPDATE posts SET comment_count = comment_count - 1 WHERE id = NEW.post_id;
            UPDATE users SET reply_count = reply_count - 1 WHERE id = NEW.author_id;
            IF NEW.parent_id IS NOT NULL THEN
                UPDATE comments SET reply_count = reply_count - 1 WHERE id = NEW.parent_id;
            END IF;
        END IF;
    END IF;

    RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_post_votes_stats
    AFTER INSERT OR UPDATE OR DELETE ON post_votes
    FOR EACH ROW EXECUTE FUNCTION update_post_stats();

CREATE TRIGGER trigger_post_bookmarks_stats
    AFTER INSERT OR DELETE ON post_bookmarks
    FOR EACH ROW EXECUTE FUNCTION update_post_stats();

CREATE TRIGGER trigger_comments_stats
    AFTER INSERT OR UPDATE OF is_deleted ON comments
    FOR EACH ROW EXECUTE FUNCTION update_post_stats();

-- 更新用户帖子统计
CREATE OR REPLACE FUNCTION update_user_post_count()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' AND NOT NEW.is_deleted THEN
        UPDATE users SET post_count = post_count + 1 WHERE id = NEW.author_id;
        UPDATE channels SET post_count = post_count + 1 WHERE id = NEW.channel_id;
    ELSIF TG_OP = 'UPDATE' AND OLD.is_deleted = FALSE AND NEW.is_deleted = TRUE THEN
        UPDATE users SET post_count = post_count - 1 WHERE id = NEW.author_id;
        UPDATE channels SET post_count = post_count - 1 WHERE id = NEW.channel_id;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_user_post_count
    AFTER INSERT OR UPDATE OF is_deleted ON posts
    FOR EACH ROW EXECUTE FUNCTION update_user_post_count();

-- 更新评论点赞统计
CREATE OR REPLACE FUNCTION update_comment_likes()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        UPDATE comments SET likes = likes + 1 WHERE id = NEW.comment_id;
    ELSIF TG_OP = 'DELETE' THEN
        UPDATE comments SET likes = likes - 1 WHERE id = OLD.comment_id;
    END IF;
    RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_comment_likes
    AFTER INSERT OR DELETE ON comment_likes
    FOR EACH ROW EXECUTE FUNCTION update_comment_likes();

-- 更新关注统计
CREATE OR REPLACE FUNCTION update_follow_counts()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        UPDATE users SET following_count = following_count + 1 WHERE id = NEW.follower_id;
        UPDATE users SET followers_count = followers_count + 1 WHERE id = NEW.following_id;
    ELSIF TG_OP = 'DELETE' THEN
        UPDATE users SET following_count = following_count - 1 WHERE id = OLD.follower_id;
        UPDATE users SET followers_count = followers_count - 1 WHERE id = OLD.following_id;
    END IF;
    RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_follow_counts
    AFTER INSERT OR DELETE ON user_follows
    FOR EACH ROW EXECUTE FUNCTION update_follow_counts();

-- 更新频道成员统计
CREATE OR REPLACE FUNCTION update_channel_member_count()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        UPDATE channels SET member_count = member_count + 1 WHERE id = NEW.channel_id;
    ELSIF TG_OP = 'DELETE' THEN
        UPDATE channels SET member_count = member_count - 1 WHERE id = OLD.channel_id;
    END IF;
    RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_channel_member_count
    AFTER INSERT OR DELETE ON channel_members
    FOR EACH ROW EXECUTE FUNCTION update_channel_member_count();

-- 评论层级路径维护
CREATE OR REPLACE FUNCTION maintain_comment_path()
RETURNS TRIGGER AS $$
DECLARE
    parent_path TEXT[];
    parent_depth INTEGER;
BEGIN
    IF NEW.parent_id IS NULL THEN
        NEW.path := ARRAY[NEW.id::TEXT];
        NEW.depth := 0;
    ELSE
        SELECT path, depth INTO parent_path, parent_depth
        FROM comments WHERE id = NEW.parent_id;

        NEW.path := parent_path || NEW.id::TEXT;
        NEW.depth := parent_depth + 1;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_comment_path
    BEFORE INSERT ON comments
    FOR EACH ROW EXECUTE FUNCTION maintain_comment_path();

-- 新用户创建时的处理
CREATE OR REPLACE FUNCTION handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO public.users (id, username, avatar_url)
    VALUES (
        NEW.id,
        COALESCE(NEW.raw_user_meta_data->>'username', 'user_' || substr(NEW.id::TEXT, 1, 8)),
        COALESCE(NEW.raw_user_meta_data->>'avatar_url', '')
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 监听 auth.users 表的插入
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION handle_new_user();

-- updated_at 自动更新
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at := NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_users_updated_at
    BEFORE UPDATE ON users
    FOR EACH ROW EXECUTE FUNCTION update_updated_at();

CREATE TRIGGER trigger_posts_updated_at
    BEFORE UPDATE ON posts
    FOR EACH ROW EXECUTE FUNCTION update_updated_at();

CREATE TRIGGER trigger_comments_updated_at
    BEFORE UPDATE ON comments
    FOR EACH ROW EXECUTE FUNCTION update_updated_at();

CREATE TRIGGER trigger_channels_updated_at
    BEFORE UPDATE ON channels
    FOR EACH ROW EXECUTE FUNCTION update_updated_at();

CREATE TRIGGER trigger_species_updated_at
    BEFORE UPDATE ON species
    FOR EACH ROW EXECUTE FUNCTION update_updated_at();

-- ============================================
-- RPC 函数
-- ============================================

-- 增加帖子浏览量
CREATE OR REPLACE FUNCTION increment_view_count(p_post_id UUID)
RETURNS VOID AS $$
BEGIN
    UPDATE posts SET view_count = view_count + 1 WHERE id = p_post_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 获取用户统计摘要
CREATE OR REPLACE FUNCTION get_user_stats(p_user_id UUID)
RETURNS TABLE (
    total_posts BIGINT,
    total_comments BIGINT,
    total_likes_received BIGINT,
    total_bookmarks_received BIGINT
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        (SELECT COUNT(*) FROM posts WHERE author_id = p_user_id AND is_deleted = FALSE),
        (SELECT COUNT(*) FROM comments WHERE author_id = p_user_id AND is_deleted = FALSE),
        (SELECT COALESCE(SUM(upvotes), 0) FROM posts WHERE author_id = p_user_id),
        (SELECT COALESCE(SUM(bookmark_count), 0) FROM posts WHERE author_id = p_user_id);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 批量检查用户是否关注
CREATE OR REPLACE FUNCTION check_follows(p_follower UUID, p_following_ids UUID[])
RETURNS TABLE (following_id UUID, is_following BOOLEAN) AS $$
BEGIN
    RETURN QUERY
    SELECT
        u.id,
        EXISTS (SELECT 1 FROM user_follows WHERE follower_id = p_follower AND user_follows.following_id = u.id)
    FROM unnest(p_following_ids) AS u(id);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 创建通知
CREATE OR REPLACE FUNCTION create_notification(
    p_user_id UUID,
    p_type notification_type,
    p_actor_id UUID DEFAULT NULL,
    p_post_id UUID DEFAULT NULL,
    p_comment_id UUID DEFAULT NULL,
    p_title TEXT DEFAULT NULL,
    p_body TEXT DEFAULT NULL
)
RETURNS UUID AS $$
DECLARE
    notification_id UUID;
BEGIN
    -- 不要给自己发通知
    IF p_user_id = p_actor_id THEN
        RETURN NULL;
    END IF;

    INSERT INTO notifications (user_id, type, actor_id, post_id, comment_id, title, body)
    VALUES (p_user_id, p_type, p_actor_id, p_post_id, p_comment_id, p_title, p_body)
    RETURNING id INTO notification_id;

    RETURN notification_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 标记所有通知为已读
CREATE OR REPLACE FUNCTION mark_all_notifications_read(p_user_id UUID)
RETURNS INTEGER AS $$
DECLARE
    updated_count INTEGER;
BEGIN
    UPDATE notifications
    SET is_read = TRUE
    WHERE user_id = p_user_id AND is_read = FALSE;

    GET DIAGNOSTICS updated_count = ROW_COUNT;
    RETURN updated_count;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================
-- 视图定义
-- ============================================

-- 帖子详情视图（包含作者信息和频道信息）
CREATE OR REPLACE VIEW post_details AS
SELECT
    p.*,
    u.username AS author_name,
    u.avatar_url AS author_avatar,
    u.title AS author_title,
    c.name AS channel_name,
    c.icon_name AS channel_icon
FROM posts p
JOIN users u ON p.author_id = u.id
JOIN channels c ON p.channel_id = c.id
WHERE p.is_deleted = FALSE;

-- 评论详情视图
CREATE OR REPLACE VIEW comment_details AS
SELECT
    c.*,
    u.username AS author_name,
    u.avatar_url AS author_avatar,
    u.title AS author_title
FROM comments c
JOIN users u ON c.author_id = u.id
WHERE c.is_deleted = FALSE;

-- 热门帖子视图
CREATE OR REPLACE VIEW trending_posts AS
SELECT
    p.*,
    u.username AS author_name,
    u.avatar_url AS author_avatar,
    ch.name AS channel_name,
    -- 热度评分算法
    (p.upvotes - p.downvotes) +
    (p.comment_count * 2) +
    (p.bookmark_count * 3) +
    -- 时间衰减因子
    EXTRACT(EPOCH FROM (NOW() - p.created_at)) / -86400.0 * 10 AS trending_score
FROM posts p
JOIN users u ON p.author_id = u.id
JOIN channels ch ON p.channel_id = ch.id
WHERE p.is_deleted = FALSE
    AND p.created_at > NOW() - INTERVAL '7 days'
ORDER BY trending_score DESC;
