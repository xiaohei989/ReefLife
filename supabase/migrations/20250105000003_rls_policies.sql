-- ============================================
-- ReefLife Row Level Security 策略
-- ============================================

-- 启用 RLS
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE channels ENABLE ROW LEVEL SECURITY;
ALTER TABLE channel_members ENABLE ROW LEVEL SECURITY;
ALTER TABLE posts ENABLE ROW LEVEL SECURITY;
ALTER TABLE post_votes ENABLE ROW LEVEL SECURITY;
ALTER TABLE post_bookmarks ENABLE ROW LEVEL SECURITY;
ALTER TABLE comments ENABLE ROW LEVEL SECURITY;
ALTER TABLE comment_likes ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_follows ENABLE ROW LEVEL SECURITY;
ALTER TABLE species ENABLE ROW LEVEL SECURITY;
ALTER TABLE species_favorites ENABLE ROW LEVEL SECURITY;
ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE reports ENABLE ROW LEVEL SECURITY;
ALTER TABLE view_history ENABLE ROW LEVEL SECURITY;
ALTER TABLE media ENABLE ROW LEVEL SECURITY;

-- ============================================
-- Users 表策略
-- ============================================

-- 所有人可以查看用户公开信息
CREATE POLICY "Users are viewable by everyone"
    ON users FOR SELECT
    USING (NOT is_banned);

-- 用户只能更新自己的信息
CREATE POLICY "Users can update own profile"
    ON users FOR UPDATE
    USING (auth.uid() = id)
    WITH CHECK (auth.uid() = id);

-- ============================================
-- Channels 表策略
-- ============================================

-- 所有人可以查看活跃的频道
CREATE POLICY "Active channels are viewable by everyone"
    ON channels FOR SELECT
    USING (is_active = TRUE);

-- 只有管理员可以创建频道
CREATE POLICY "Admins can create channels"
    ON channels FOR INSERT
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM users
            WHERE id = auth.uid()
            AND (settings->>'is_admin')::boolean = true
        )
    );

-- 管理员可以更新频道
CREATE POLICY "Admins can update channels"
    ON channels FOR UPDATE
    USING (
        EXISTS (
            SELECT 1 FROM users
            WHERE id = auth.uid()
            AND (settings->>'is_admin')::boolean = true
        )
    );

-- ============================================
-- Channel Members 表策略
-- ============================================

-- 所有人可以查看频道成员
CREATE POLICY "Channel members are viewable by everyone"
    ON channel_members FOR SELECT
    USING (TRUE);

-- 登录用户可以加入频道
CREATE POLICY "Users can join channels"
    ON channel_members FOR INSERT
    WITH CHECK (auth.uid() = user_id);

-- 用户可以离开频道
CREATE POLICY "Users can leave channels"
    ON channel_members FOR DELETE
    USING (auth.uid() = user_id);

-- ============================================
-- Posts 表策略
-- ============================================

-- 所有人可以查看未删除的帖子
CREATE POLICY "Non-deleted posts are viewable by everyone"
    ON posts FOR SELECT
    USING (is_deleted = FALSE);

-- 登录用户可以创建帖子
CREATE POLICY "Authenticated users can create posts"
    ON posts FOR INSERT
    WITH CHECK (auth.uid() = author_id);

-- 作者可以更新自己的帖子
CREATE POLICY "Authors can update own posts"
    ON posts FOR UPDATE
    USING (auth.uid() = author_id)
    WITH CHECK (auth.uid() = author_id);

-- 作者可以软删除自己的帖子
CREATE POLICY "Authors can delete own posts"
    ON posts FOR DELETE
    USING (auth.uid() = author_id);

-- ============================================
-- Post Votes 表策略
-- ============================================

-- 所有人可以查看投票
CREATE POLICY "Post votes are viewable by everyone"
    ON post_votes FOR SELECT
    USING (TRUE);

-- 登录用户可以投票
CREATE POLICY "Authenticated users can vote"
    ON post_votes FOR INSERT
    WITH CHECK (auth.uid() = user_id);

-- 用户可以更改自己的投票
CREATE POLICY "Users can update own votes"
    ON post_votes FOR UPDATE
    USING (auth.uid() = user_id);

-- 用户可以删除自己的投票
CREATE POLICY "Users can delete own votes"
    ON post_votes FOR DELETE
    USING (auth.uid() = user_id);

-- ============================================
-- Post Bookmarks 表策略
-- ============================================

-- 用户只能查看自己的收藏
CREATE POLICY "Users can view own bookmarks"
    ON post_bookmarks FOR SELECT
    USING (auth.uid() = user_id);

-- 登录用户可以收藏
CREATE POLICY "Authenticated users can bookmark"
    ON post_bookmarks FOR INSERT
    WITH CHECK (auth.uid() = user_id);

-- 用户可以删除自己的收藏
CREATE POLICY "Users can delete own bookmarks"
    ON post_bookmarks FOR DELETE
    USING (auth.uid() = user_id);

-- ============================================
-- Comments 表策略
-- ============================================

-- 所有人可以查看未删除的评论
CREATE POLICY "Non-deleted comments are viewable by everyone"
    ON comments FOR SELECT
    USING (is_deleted = FALSE);

-- 登录用户可以创建评论
CREATE POLICY "Authenticated users can create comments"
    ON comments FOR INSERT
    WITH CHECK (auth.uid() = author_id);

-- 作者可以更新自己的评论
CREATE POLICY "Authors can update own comments"
    ON comments FOR UPDATE
    USING (auth.uid() = author_id)
    WITH CHECK (auth.uid() = author_id);

-- 作者可以软删除自己的评论
CREATE POLICY "Authors can delete own comments"
    ON comments FOR DELETE
    USING (auth.uid() = author_id);

-- ============================================
-- Comment Likes 表策略
-- ============================================

-- 所有人可以查看点赞
CREATE POLICY "Comment likes are viewable by everyone"
    ON comment_likes FOR SELECT
    USING (TRUE);

-- 登录用户可以点赞
CREATE POLICY "Authenticated users can like comments"
    ON comment_likes FOR INSERT
    WITH CHECK (auth.uid() = user_id);

-- 用户可以取消自己的点赞
CREATE POLICY "Users can unlike comments"
    ON comment_likes FOR DELETE
    USING (auth.uid() = user_id);

-- ============================================
-- User Follows 表策略
-- ============================================

-- 所有人可以查看关注关系
CREATE POLICY "Follows are viewable by everyone"
    ON user_follows FOR SELECT
    USING (TRUE);

-- 登录用户可以关注
CREATE POLICY "Authenticated users can follow"
    ON user_follows FOR INSERT
    WITH CHECK (auth.uid() = follower_id);

-- 用户可以取消关注
CREATE POLICY "Users can unfollow"
    ON user_follows FOR DELETE
    USING (auth.uid() = follower_id);

-- ============================================
-- Species 表策略
-- ============================================

-- 所有人可以查看物种
CREATE POLICY "Species are viewable by everyone"
    ON species FOR SELECT
    USING (TRUE);

-- 只有认证用户可以添加物种（需要审核）
CREATE POLICY "Authenticated users can suggest species"
    ON species FOR INSERT
    WITH CHECK (auth.uid() = created_by AND is_verified = FALSE);

-- 管理员可以更新物种
CREATE POLICY "Admins can update species"
    ON species FOR UPDATE
    USING (
        EXISTS (
            SELECT 1 FROM users
            WHERE id = auth.uid()
            AND (settings->>'is_admin')::boolean = true
        )
    );

-- ============================================
-- Species Favorites 表策略
-- ============================================

-- 用户只能查看自己的收藏
CREATE POLICY "Users can view own species favorites"
    ON species_favorites FOR SELECT
    USING (auth.uid() = user_id);

-- 登录用户可以收藏物种
CREATE POLICY "Authenticated users can favorite species"
    ON species_favorites FOR INSERT
    WITH CHECK (auth.uid() = user_id);

-- 用户可以删除自己的收藏
CREATE POLICY "Users can delete own species favorites"
    ON species_favorites FOR DELETE
    USING (auth.uid() = user_id);

-- ============================================
-- Notifications 表策略
-- ============================================

-- 用户只能查看自己的通知
CREATE POLICY "Users can view own notifications"
    ON notifications FOR SELECT
    USING (auth.uid() = user_id);

-- 系统可以创建通知（通过服务角色）
CREATE POLICY "System can create notifications"
    ON notifications FOR INSERT
    WITH CHECK (TRUE);

-- 用户可以更新自己的通知（标记已读）
CREATE POLICY "Users can update own notifications"
    ON notifications FOR UPDATE
    USING (auth.uid() = user_id);

-- 用户可以删除自己的通知
CREATE POLICY "Users can delete own notifications"
    ON notifications FOR DELETE
    USING (auth.uid() = user_id);

-- ============================================
-- Reports 表策略
-- ============================================

-- 用户只能查看自己提交的举报
CREATE POLICY "Users can view own reports"
    ON reports FOR SELECT
    USING (auth.uid() = reporter_id);

-- 登录用户可以提交举报
CREATE POLICY "Authenticated users can create reports"
    ON reports FOR INSERT
    WITH CHECK (auth.uid() = reporter_id);

-- ============================================
-- View History 表策略
-- ============================================

-- 用户只能查看自己的浏览历史
CREATE POLICY "Users can view own history"
    ON view_history FOR SELECT
    USING (auth.uid() = user_id);

-- 登录用户可以记录浏览历史
CREATE POLICY "Authenticated users can record history"
    ON view_history FOR INSERT
    WITH CHECK (auth.uid() = user_id);

-- 用户可以删除自己的浏览历史
CREATE POLICY "Users can delete own history"
    ON view_history FOR DELETE
    USING (auth.uid() = user_id);

-- ============================================
-- Media 表策略
-- ============================================

-- 所有人可以查看媒体
CREATE POLICY "Media are viewable by everyone"
    ON media FOR SELECT
    USING (TRUE);

-- 登录用户可以上传媒体
CREATE POLICY "Authenticated users can upload media"
    ON media FOR INSERT
    WITH CHECK (auth.uid() = user_id);

-- 用户可以删除自己的媒体
CREATE POLICY "Users can delete own media"
    ON media FOR DELETE
    USING (auth.uid() = user_id);
