-- ReefLife 初始测试数据
-- 用于填充频道和物种百科

-- ============================================
-- 1. 插入频道数据
-- ============================================

INSERT INTO channels (id, name, description, category, icon_name, color_hex, is_hot, member_count, post_count) VALUES
-- 海洋生物频道
('ch-fish', '观赏鱼', '讨论各种海水观赏鱼的饲养、繁殖和疾病防治', 'marine_life', 'fish.fill', '#FF6B6B', true, 1250, 3420),
('ch-sps', 'SPS珊瑚', '硬骨珊瑚爱好者的交流天地，分享养护经验', 'marine_life', 'leaf.fill', '#4ECDC4', true, 890, 2150),
('ch-lps', 'LPS珊瑚', '软骨珊瑚的养护技巧、品种鉴赏', 'marine_life', 'sparkles', '#45B7D1', false, 720, 1680),
('ch-invert', '无脊椎动物', '虾蟹、海星、海参等无脊椎动物专区', 'marine_life', 'ladybug.fill', '#96CEB4', false, 560, 980),

-- 设备技术频道
('ch-light', '灯光照明', 'LED、T5等灯光设备讨论', 'equipment', 'lightbulb.fill', '#FFEAA7', true, 680, 1520),
('ch-filter', '过滤系统', '蛋分、滤材、活石等过滤话题', 'equipment', 'drop.fill', '#74B9FF', false, 590, 1340),
('ch-tank', '缸体造景', '鱼缸选择、造景设计分享', 'equipment', 'square.stack.3d.up.fill', '#A29BFE', false, 820, 2100),
('ch-controller', '智能控制', 'Neptune、GHL等控制器讨论', 'equipment', 'cpu.fill', '#FD79A8', false, 340, 680),

-- 交易市场频道
('ch-sell', '出售转让', '出售闲置设备和生物', 'marketplace', 'tag.fill', '#00B894', true, 1560, 4200),
('ch-buy', '求购征集', '发布求购需求', 'marketplace', 'cart.fill', '#E17055', false, 890, 1850),
('ch-group', '团购拼单', '组织团购活动', 'marketplace', 'person.3.fill', '#6C5CE7', false, 450, 720),

-- 综合讨论频道
('ch-newbie', '新手入门', '新手问题解答，入坑指南', 'general', 'questionmark.circle.fill', '#FDCB6E', true, 2340, 5600),
('ch-show', '晒缸专区', '分享你的海水缸美图', 'general', 'photo.fill', '#E84393', true, 1890, 4100),
('ch-science', '科普知识', '海洋生物科普文章', 'general', 'book.fill', '#00CEC9', false, 670, 890)

ON CONFLICT (id) DO UPDATE SET
    name = EXCLUDED.name,
    description = EXCLUDED.description,
    category = EXCLUDED.category,
    icon_name = EXCLUDED.icon_name,
    color_hex = EXCLUDED.color_hex,
    is_hot = EXCLUDED.is_hot,
    member_count = EXCLUDED.member_count,
    post_count = EXCLUDED.post_count;

-- ============================================
-- 2. 插入物种数据 - 观赏鱼
-- ============================================

INSERT INTO species (id, common_name, scientific_name, category, difficulty, description, care_guide, image_url, tank_size_min, temperature_min, temperature_max, ph_min, ph_max, salinity_min, salinity_max, lighting, flow, placement, growth_rate, aggression, is_reef_safe) VALUES

-- 小丑鱼系列
('sp-ocellaris', '公子小丑', 'Amphiprion ocellaris', 'fish', 'easy',
 '最受欢迎的海水观赏鱼之一，橙色身体配以白色条纹，性格温和，适合新手饲养。',
 '• 建议配对饲养\n• 可与海葵共生\n• 接受各种饵料\n• 适应力强',
 'https://pub-5279f11f5a334321a5d0156e2a00cb46.r2.dev/species/ocellaris.jpg',
 75, 24.0, 28.0, 8.1, 8.4, 1.020, 1.025, NULL, NULL, NULL, NULL, 'peaceful', true),

('sp-percula', '真透红小丑', 'Amphiprion percula', 'fish', 'easy',
 '与公子小丑相似但颜色更鲜艳，黑边更明显，是海水缸的经典选择。',
 '• 需要稳定水质\n• 喜欢与海葵共生\n• 可接受人工饲料\n• 寿命可达20年',
 'https://pub-5279f11f5a334321a5d0156e2a00cb46.r2.dev/species/percula.jpg',
 75, 24.0, 27.0, 8.1, 8.4, 1.020, 1.025, NULL, NULL, NULL, NULL, 'peaceful', true),

('sp-maroon', '番茄小丑', 'Premnas biaculeatus', 'fish', 'medium',
 '体型较大的小丑鱼，深红色身体配以金色条纹，具有领地意识。',
 '• 需要较大空间\n• 可能攻击其他小丑鱼\n• 与泡泡海葵共生最佳\n• 雌鱼可长到17cm',
 'https://pub-5279f11f5a334321a5d0156e2a00cb46.r2.dev/species/maroon.jpg',
 150, 24.0, 28.0, 8.1, 8.4, 1.020, 1.025, NULL, NULL, NULL, NULL, 'semi-aggressive', true),

-- 吊类
('sp-yellow-tang', '黄金吊', 'Zebrasoma flavescens', 'fish', 'easy',
 '最受欢迎的吊类之一，亮黄色身体极为醒目，是优秀的除藻帮手。',
 '• 需要大量游泳空间\n• 以藻类为主食\n• 可与其他鱼和平共处\n• 需要稳定水质',
 'https://pub-5279f11f5a334321a5d0156e2a00cb46.r2.dev/species/yellow-tang.jpg',
 300, 24.0, 28.0, 8.1, 8.4, 1.020, 1.025, NULL, NULL, NULL, NULL, 'peaceful', true),

('sp-blue-tang', '蓝吊', 'Paracanthurus hepatus', 'fish', 'medium',
 '电影《海底总动员》中多莉的原型，蓝色身体配以黑色花纹和黄色尾鳍。',
 '• 需要大型鱼缸\n• 易患白点病\n• 需要隐藏空间\n• 杂食性',
 'https://pub-5279f11f5a334321a5d0156e2a00cb46.r2.dev/species/blue-tang.jpg',
 400, 24.0, 28.0, 8.1, 8.4, 1.020, 1.025, NULL, NULL, NULL, NULL, 'peaceful', true),

-- 神仙鱼
('sp-flame-angel', '火焰神仙', 'Centropyge loricula', 'fish', 'medium',
 '小型神仙鱼中最受欢迎的品种，火红色身体配以黑色条纹。',
 '• 可能啃食珊瑚\n• 需要活石觅食\n• 每缸只养一只\n• 需要良好水质',
 'https://pub-5279f11f5a334321a5d0156e2a00cb46.r2.dev/species/flame-angel.jpg',
 250, 24.0, 27.0, 8.1, 8.4, 1.020, 1.025, NULL, NULL, NULL, NULL, 'semi-aggressive', false),

('sp-coral-beauty', '蓝闪电神仙', 'Centropyge bispinosa', 'fish', 'easy',
 '适应力强的小型神仙鱼，蓝紫色身体配以橙色条纹。',
 '• 相对珊瑚安全\n• 适应力强\n• 杂食性\n• 适合新手',
 'https://pub-5279f11f5a334321a5d0156e2a00cb46.r2.dev/species/coral-beauty.jpg',
 200, 24.0, 28.0, 8.1, 8.4, 1.020, 1.025, NULL, NULL, NULL, NULL, 'peaceful', true),

-- 狐狸鱼
('sp-foxface', '狐狸鱼', 'Siganus vulpinus', 'fish', 'easy',
 '优秀的除藻鱼，黄色身体配以黑白相间的头部花纹，背鳍有毒刺。',
 '• 出色的藻类清洁工\n• 背鳍有毒需小心\n• 胆小易惊\n• 需要藏身处',
 'https://pub-5279f11f5a334321a5d0156e2a00cb46.r2.dev/species/foxface.jpg',
 300, 24.0, 28.0, 8.1, 8.4, 1.020, 1.025, NULL, NULL, NULL, NULL, 'peaceful', true)

ON CONFLICT (id) DO UPDATE SET
    common_name = EXCLUDED.common_name,
    scientific_name = EXCLUDED.scientific_name,
    category = EXCLUDED.category,
    difficulty = EXCLUDED.difficulty,
    description = EXCLUDED.description,
    care_guide = EXCLUDED.care_guide,
    image_url = EXCLUDED.image_url,
    tank_size_min = EXCLUDED.tank_size_min,
    temperature_min = EXCLUDED.temperature_min,
    temperature_max = EXCLUDED.temperature_max,
    ph_min = EXCLUDED.ph_min,
    ph_max = EXCLUDED.ph_max,
    salinity_min = EXCLUDED.salinity_min,
    salinity_max = EXCLUDED.salinity_max,
    is_reef_safe = EXCLUDED.is_reef_safe;

-- ============================================
-- 3. 插入物种数据 - SPS珊瑚
-- ============================================

INSERT INTO species (id, common_name, scientific_name, category, difficulty, description, care_guide, image_url, temperature_min, temperature_max, ph_min, ph_max, salinity_min, salinity_max, calcium_min, calcium_max, alkalinity_min, alkalinity_max, magnesium_min, magnesium_max, lighting, flow, placement, growth_rate, aggression, is_reef_safe) VALUES

('sp-acropora', '鹿角珊瑚', 'Acropora spp.', 'sps', 'hard',
 'SPS珊瑚的代表，枝状生长，色彩丰富，对水质要求极高。',
 '• 需要强光照\n• 需要强水流\n• 定期添加钙镁\n• 监控微量元素',
 'https://pub-5279f11f5a334321a5d0156e2a00cb46.r2.dev/species/acropora.jpg',
 24.0, 26.0, 8.1, 8.4, 1.024, 1.026, 420, 450, 8.0, 11.0, 1280, 1350, 'high', 'high', 'top', 'medium', 'peaceful', true),

('sp-montipora', '薄皮珊瑚', 'Montipora spp.', 'sps', 'medium',
 '相对容易饲养的SPS，可呈片状或枝状生长，适合SPS入门。',
 '• 中等光照即可\n• 适中水流\n• 生长速度快\n• 色彩多样',
 'https://pub-5279f11f5a334321a5d0156e2a00cb46.r2.dev/species/montipora.jpg',
 24.0, 27.0, 8.1, 8.4, 1.024, 1.026, 400, 450, 7.5, 11.0, 1280, 1350, 'medium-high', 'medium', 'middle', 'fast', 'peaceful', true),

('sp-stylophora', '猫爪珊瑚', 'Stylophora pistillata', 'sps', 'medium',
 '枝状生长的SPS，常见粉色和绿色，相对强健。',
 '• 适合SPS入门\n• 生长迅速\n• 需要中强水流\n• 易于断枝繁殖',
 'https://pub-5279f11f5a334321a5d0156e2a00cb46.r2.dev/species/stylophora.jpg',
 24.0, 27.0, 8.1, 8.4, 1.024, 1.026, 400, 450, 7.5, 11.0, 1280, 1350, 'medium-high', 'medium-high', 'middle', 'fast', 'peaceful', true)

ON CONFLICT (id) DO UPDATE SET
    common_name = EXCLUDED.common_name,
    scientific_name = EXCLUDED.scientific_name,
    category = EXCLUDED.category,
    difficulty = EXCLUDED.difficulty,
    description = EXCLUDED.description,
    care_guide = EXCLUDED.care_guide,
    image_url = EXCLUDED.image_url,
    temperature_min = EXCLUDED.temperature_min,
    temperature_max = EXCLUDED.temperature_max,
    calcium_min = EXCLUDED.calcium_min,
    calcium_max = EXCLUDED.calcium_max,
    alkalinity_min = EXCLUDED.alkalinity_min,
    alkalinity_max = EXCLUDED.alkalinity_max,
    magnesium_min = EXCLUDED.magnesium_min,
    magnesium_max = EXCLUDED.magnesium_max,
    lighting = EXCLUDED.lighting,
    flow = EXCLUDED.flow,
    placement = EXCLUDED.placement,
    growth_rate = EXCLUDED.growth_rate,
    is_reef_safe = EXCLUDED.is_reef_safe;

-- ============================================
-- 4. 插入物种数据 - LPS珊瑚
-- ============================================

INSERT INTO species (id, common_name, scientific_name, category, difficulty, description, care_guide, image_url, temperature_min, temperature_max, ph_min, ph_max, salinity_min, salinity_max, calcium_min, calcium_max, alkalinity_min, alkalinity_max, magnesium_min, magnesium_max, lighting, flow, placement, growth_rate, aggression, is_reef_safe) VALUES

('sp-hammer', '锤子珊瑚', 'Euphyllia ancora', 'lps', 'medium',
 '触手末端呈锤状，摆动优美，是LPS的经典品种。',
 '• 中等光照\n• 温和水流\n• 可喂食肉类\n• 注意触手攻击范围',
 'https://pub-5279f11f5a334321a5d0156e2a00cb46.r2.dev/species/hammer.jpg',
 24.0, 27.0, 8.1, 8.4, 1.024, 1.026, 400, 450, 8.0, 11.0, 1280, 1350, 'medium', 'low-medium', 'middle', 'medium', 'aggressive', true),

('sp-torch', '火炬珊瑚', 'Euphyllia glabrescens', 'lps', 'medium',
 '长触手随水流飘动如火炬，荧光色非常吸睛。',
 '• 需要足够空间\n• 触手有毒刺\n• 可喂食虾肉\n• 避免强水流直吹',
 'https://pub-5279f11f5a334321a5d0156e2a00cb46.r2.dev/species/torch.jpg',
 24.0, 27.0, 8.1, 8.4, 1.024, 1.026, 400, 450, 8.0, 11.0, 1280, 1350, 'medium', 'low-medium', 'middle', 'medium', 'aggressive', true),

('sp-frogspawn', '蛙卵珊瑚', 'Euphyllia divisa', 'lps', 'medium',
 '触手末端呈分叉状如蛙卵，与锤子火炬为近亲。',
 '• 中等养护难度\n• 生长相对迅速\n• 定期喂食\n• 注意攻击性',
 'https://pub-5279f11f5a334321a5d0156e2a00cb46.r2.dev/species/frogspawn.jpg',
 24.0, 27.0, 8.1, 8.4, 1.024, 1.026, 400, 450, 8.0, 11.0, 1280, 1350, 'medium', 'low-medium', 'middle', 'medium', 'aggressive', true),

('sp-brain', '脑珊瑚', 'Lobophyllia spp.', 'lps', 'easy',
 '外形如大脑的褶皱，肉质厚实，色彩艳丽。',
 '• 适合新手\n• 低光照即可\n• 喜欢投喂\n• 放置底部沙床',
 'https://pub-5279f11f5a334321a5d0156e2a00cb46.r2.dev/species/brain.jpg',
 24.0, 28.0, 8.1, 8.4, 1.024, 1.026, 380, 450, 7.5, 11.0, 1280, 1350, 'low-medium', 'low', 'bottom', 'slow', 'semi-aggressive', true),

('sp-acan', '澳洲脑', 'Acanthastrea spp.', 'lps', 'easy',
 '色彩丰富的群体珊瑚，多种颜色组合极具观赏性。',
 '• 容易饲养\n• 中低光照\n• 定期喂食生长快\n• 注意夜间触手',
 'https://pub-5279f11f5a334321a5d0156e2a00cb46.r2.dev/species/acan.jpg',
 24.0, 28.0, 8.1, 8.4, 1.024, 1.026, 380, 450, 7.5, 11.0, 1280, 1350, 'low-medium', 'low', 'bottom', 'medium', 'aggressive', true)

ON CONFLICT (id) DO UPDATE SET
    common_name = EXCLUDED.common_name,
    scientific_name = EXCLUDED.scientific_name,
    category = EXCLUDED.category,
    difficulty = EXCLUDED.difficulty,
    description = EXCLUDED.description,
    care_guide = EXCLUDED.care_guide,
    image_url = EXCLUDED.image_url,
    temperature_min = EXCLUDED.temperature_min,
    temperature_max = EXCLUDED.temperature_max,
    calcium_min = EXCLUDED.calcium_min,
    calcium_max = EXCLUDED.calcium_max,
    alkalinity_min = EXCLUDED.alkalinity_min,
    alkalinity_max = EXCLUDED.alkalinity_max,
    magnesium_min = EXCLUDED.magnesium_min,
    magnesium_max = EXCLUDED.magnesium_max,
    lighting = EXCLUDED.lighting,
    flow = EXCLUDED.flow,
    placement = EXCLUDED.placement,
    growth_rate = EXCLUDED.growth_rate,
    is_reef_safe = EXCLUDED.is_reef_safe;

-- ============================================
-- 5. 插入物种数据 - 无脊椎动物
-- ============================================

INSERT INTO species (id, common_name, scientific_name, category, difficulty, description, care_guide, image_url, tank_size_min, temperature_min, temperature_max, ph_min, ph_max, salinity_min, salinity_max, is_reef_safe) VALUES

('sp-cleaner-shrimp', '医生虾', 'Lysmata amboinensis', 'invertebrate', 'easy',
 '会为鱼类清洁寄生虫的清洁虾，红白相间非常漂亮。',
 '• 温和无攻击性\n• 帮助清洁鱼体\n• 接受各种饵料\n• 可群养',
 'https://pub-5279f11f5a334321a5d0156e2a00cb46.r2.dev/species/cleaner-shrimp.jpg',
 75, 24.0, 28.0, 8.1, 8.4, 1.020, 1.025, true),

('sp-peppermint-shrimp', '薄荷虾', 'Lysmata wurdemanni', 'invertebrate', 'easy',
 '可以吃掉垃圾海葵的有益虾类，透明身体配以红色条纹。',
 '• 消灭垃圾海葵\n• 夜行性\n• 群养效果更好\n• 适应力强',
 'https://pub-5279f11f5a334321a5d0156e2a00cb46.r2.dev/species/peppermint-shrimp.jpg',
 75, 24.0, 28.0, 8.1, 8.4, 1.020, 1.025, true),

('sp-hermit-crab', '寄居蟹', 'Calcinus spp.', 'invertebrate', 'easy',
 '优秀的除藻清洁工，会随着生长更换贝壳。',
 '• 需要备用贝壳\n• 杂食性清洁工\n• 可能攻击蜗牛\n• 群养更有效',
 'https://pub-5279f11f5a334321a5d0156e2a00cb46.r2.dev/species/hermit-crab.jpg',
 40, 24.0, 28.0, 8.1, 8.4, 1.020, 1.025, true),

('sp-turbo-snail', '翻砂螺', 'Turbo fluctuosa', 'invertebrate', 'easy',
 '强力除藻蜗牛，可有效控制藻类生长。',
 '• 出色的除藻能力\n• 需要足够藻类\n• 翻倒后需帮助翻正\n• 对水质敏感',
 'https://pub-5279f11f5a334321a5d0156e2a00cb46.r2.dev/species/turbo-snail.jpg',
 40, 22.0, 26.0, 8.1, 8.4, 1.020, 1.025, true),

('sp-urchin', '海胆', 'Diadema setosum', 'invertebrate', 'medium',
 '长刺海胆，强力除藻，但可能推倒造景和珊瑚。',
 '• 超强除藻能力\n• 可能破坏造景\n• 刺有毒需小心\n• 适合裸缸除藻',
 'https://pub-5279f11f5a334321a5d0156e2a00cb46.r2.dev/species/urchin.jpg',
 150, 24.0, 28.0, 8.1, 8.4, 1.020, 1.025, false),

('sp-bta', '泡泡海葵', 'Entacmaea quadricolor', 'invertebrate', 'medium',
 '最适合与小丑鱼共生的海葵，触手末端呈泡状。',
 '• 需要强光照\n• 可能移动位置\n• 定期喂食\n• 与小丑鱼共生',
 'https://pub-5279f11f5a334321a5d0156e2a00cb46.r2.dev/species/bta.jpg',
 150, 24.0, 28.0, 8.1, 8.4, 1.020, 1.025, true)

ON CONFLICT (id) DO UPDATE SET
    common_name = EXCLUDED.common_name,
    scientific_name = EXCLUDED.scientific_name,
    category = EXCLUDED.category,
    difficulty = EXCLUDED.difficulty,
    description = EXCLUDED.description,
    care_guide = EXCLUDED.care_guide,
    image_url = EXCLUDED.image_url,
    tank_size_min = EXCLUDED.tank_size_min,
    temperature_min = EXCLUDED.temperature_min,
    temperature_max = EXCLUDED.temperature_max,
    is_reef_safe = EXCLUDED.is_reef_safe;

-- 确认插入成功
SELECT 'Channels: ' || COUNT(*) FROM channels;
SELECT 'Species: ' || COUNT(*) FROM species;
