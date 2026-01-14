-- 修复 trending_posts 视图缺失的 author_title 和 channel_icon 字段
-- 这些字段在 DBPostDetail Swift 模型中是必需的
-- 注意：需要先删除视图再重建，因为 PostgreSQL 不允许更改视图列顺序

DROP VIEW IF EXISTS trending_posts;

CREATE VIEW trending_posts AS
SELECT
    p.*,
    u.username AS author_name,
    u.avatar_url AS author_avatar,
    u.title AS author_title,
    ch.name AS channel_name,
    ch.icon_name AS channel_icon,
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
