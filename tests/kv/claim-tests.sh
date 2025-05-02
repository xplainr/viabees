
#!/bin/bash

# Ensure wrangler is on latest version
echo "Wrangler version:"
npx wrangler --version

echo ""
echo "Seeding test tokens into CLAIM_KV..."

# ✅ Valid token
npx wrangler kv key put --binding=CLAIM_KV "validTokenEXAMPLE12345" \
  '{"redeemed":false,"ttl":9999999999999,"campaign_id":"abc","business_id":"xyz","campaign":"Test Offer"}' \
  --config=wrangler.worker.toml

# ✅ Expired token
npx wrangler kv key put --binding=CLAIM_KV "expiredTokenEXAMPLE1A2" \
  '{"redeemed":false,"ttl":1,"campaign_id":"abc","business_id":"xyz","campaign":"Expired Test"}' \
  --config=wrangler.worker.toml

# ✅ Already redeemed token
npx wrangler kv key put --binding=CLAIM_KV "usedTokenEXAMPLE123456" \
  '{"redeemed":true,"ttl":9999999999999,"campaign_id":"abc","business_id":"xyz","campaign":"Already Used"}' \
  --config=wrangler.worker.toml

echo ""
echo "Running claim endpoint tests..."

# Test 1: Valid token
echo -e "\n--- VALID ---"
curl -s http://localhost:8787/api/claim/validTokenEXAMPLE12345 | jq

# Test 2: Expired token
echo -e "\n--- EXPIRED ---"
curl -s http://localhost:8787/api/claim/expiredTokenEXAMPLE1A2

# Test 3: Already redeemed token
echo -e "\n--- REDEEMED ---"
curl -s http://localhost:8787/api/claim/usedTokenEXAMPLE123456

# Test 4: Missing token
echo -e "\n--- MISSING ---"
curl -s http://localhost:8787/api/claim/

# Test 5: Malformed token
echo -e "\n--- MALFORMED ---"
curl -s http://localhost:8787/api/claim/short
