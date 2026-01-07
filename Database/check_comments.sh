#!/bin/bash

SUPABASE_URL="https://dweqabfjfqlhaoomlkwq.supabase.co"
SERVICE_KEY="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImR3ZXFhYmZqZnFsaGFvb21sa3dxIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc2NzYwNDMwNywiZXhwIjoyMDgzMTgwMzA3fQ.T07bE2QhpEOZ2OXLx4thMqqPlegUcHSAOYPJ8Ww-2g0"

echo "=== 评论总数 ==="
curl -s "${SUPABASE_URL}/rest/v1/comments?select=id" \
  -H "apikey: ${SERVICE_KEY}" \
  -H "Authorization: Bearer ${SERVICE_KEY}" | jq 'length'

echo -e "\n=== 所有评论详情 ==="
curl -s "${SUPABASE_URL}/rest/v1/comments?select=id,content,likes,depth,parent_id&order=created_at.asc" \
  -H "apikey: ${SERVICE_KEY}" \
  -H "Authorization: Bearer ${SERVICE_KEY}" | jq '.[] | {content: .content[0:40], likes, depth, has_parent: (.parent_id != null)}'
