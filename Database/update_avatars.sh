#!/bin/bash

SUPABASE_URL="https://dweqabfjfqlhaoomlkwq.supabase.co"
SERVICE_KEY="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImR3ZXFhYmZqZnFsaGFvb21sa3dxIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc2NzYwNDMwNywiZXhwIjoyMDgzMTgwMzA3fQ.T07bE2QhpEOZ2OXLx4thMqqPlegUcHSAOYPJ8Ww-2g0"

echo "=== 当前用户头像 ==="
curl -s "${SUPABASE_URL}/rest/v1/users?select=id,username,avatar_url" \
  -H "apikey: ${SERVICE_KEY}" \
  -H "Authorization: Bearer ${SERVICE_KEY}" | jq '.'

echo -e "\n=== 更新用户头像 ==="

# 用户1: 海缸老司机 - 使用 UI Avatars (可靠的头像生成服务)
curl -s -X PATCH "${SUPABASE_URL}/rest/v1/users?id=eq.1d0b4bac-8c0b-474f-98c7-df0eb8e827dc" \
  -H "apikey: ${SERVICE_KEY}" \
  -H "Authorization: Bearer ${SERVICE_KEY}" \
  -H "Content-Type: application/json" \
  -d '{"avatar_url": "https://ui-avatars.com/api/?name=海缸老司机&background=0D8ABC&color=fff&size=200&font-size=0.33"}' && echo "用户1 更新完成"

# 用户2: 珊瑚控
curl -s -X PATCH "${SUPABASE_URL}/rest/v1/users?id=eq.99cd632d-0f86-4c05-b856-8b7b1cf181fb" \
  -H "apikey: ${SERVICE_KEY}" \
  -H "Authorization: Bearer ${SERVICE_KEY}" \
  -H "Content-Type: application/json" \
  -d '{"avatar_url": "https://ui-avatars.com/api/?name=珊瑚控&background=E91E63&color=fff&size=200&font-size=0.33"}' && echo "用户2 更新完成"

# 用户3: 新手小白
curl -s -X PATCH "${SUPABASE_URL}/rest/v1/users?id=eq.d68f2694-d6e1-43a8-9b26-3076c80eda63" \
  -H "apikey: ${SERVICE_KEY}" \
  -H "Authorization: Bearer ${SERVICE_KEY}" \
  -H "Content-Type: application/json" \
  -d '{"avatar_url": "https://ui-avatars.com/api/?name=新手小白&background=4CAF50&color=fff&size=200&font-size=0.33"}' && echo "用户3 更新完成"

echo -e "\n=== 验证更新后的头像 ==="
curl -s "${SUPABASE_URL}/rest/v1/users?select=id,username,avatar_url" \
  -H "apikey: ${SERVICE_KEY}" \
  -H "Authorization: Bearer ${SERVICE_KEY}" | jq '.'
