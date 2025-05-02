import { createClient } from '@supabase/supabase-js';

export interface Env {
  CLAIM_KV: KVNamespace;
  SUPABASE_URL: string;
  SUPABASE_SERVICE_ROLE: string;
  SHARE_HMAC_SECRET: string;
}

type TokenMetadata = {
  redeemed: boolean;
  ttl?: number;
  campaign_id: string;
  business_id: string;
  sharer_id?: string;
  campaign: string;
};

type ShareRequest = {
  sharer_id: string;
  campaign_id: string;
};

export default {
  async fetch(request: Request, env: Env, ctx: ExecutionContext): Promise<Response> {
    const url = new URL(request.url);
    const pathname = url.pathname;

    const supabase = createClient(env.SUPABASE_URL, env.SUPABASE_SERVICE_ROLE);

    // 🧩 Claim token route: /api/claim/:token
    if (pathname.startsWith('/api/claim/')) {
      const token = pathname.split('/').pop() ?? '';

      if (!token || token.length !== 22) {
        return new Response('Invalid token format', { status: 400 });
      }

      const metadata = await env.CLAIM_KV.get<TokenMetadata>(token, { type: 'json' });

      if (!metadata) {
        return new Response('Token not found or expired', { status: 404 });
      }

      const { redeemed, ttl } = metadata;
      const now = Date.now();

      if (redeemed) return new Response('Token already redeemed', { status: 409 });
      if (ttl && now > ttl) return new Response('Token expired', { status: 410 });

      await env.CLAIM_KV.put(token, JSON.stringify({ ...metadata, redeemed: true }));

      await fetch(`${env.SUPABASE_URL}/rest/v1/rpc/insert_redemption`, {
        method: 'POST',
        headers: {
          apikey: env.SUPABASE_SERVICE_ROLE,
          Authorization: `Bearer ${env.SUPABASE_SERVICE_ROLE}`,
          'Content-Type': 'application/json'
        },
        body: JSON.stringify({
          _claim_token: token,
          _business_id: metadata.business_id,
          _campaign_id: metadata.campaign_id,
          _sharer_id: metadata.sharer_id || null,
          _status: 'redeemed',
          _ip_address: request.headers.get('cf-connecting-ip') || 'unknown',
          _user_agent: request.headers.get('user-agent') || 'unknown',
          _event: {}
        })
      });

      return new Response(JSON.stringify({ status: 'valid', campaign: metadata.campaign }), {
        headers: { 'Content-Type': 'application/json' }
      });
    }

    // base62urlencode definition
    const base62chars = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz';
    function base62urlEncode(bytes: Uint8Array): string {
      let bigint = BigInt('0x' + [...bytes].map((b) => b.toString(16).padStart(2, '0')).join(''));
      const base = BigInt(base62chars.length);
      let output = '';
      while (bigint > 0) {
        output = base62chars[Number(bigint % base)] + output;
        bigint = bigint / base;
      }
      return output.padStart(22, '0'); // ensure fixed length just in case
    }

    // 🔐 Token generation route: /api/share
    if (pathname === '/api/share' && request.method === 'POST') {
      const { sharer_id, campaign_id } = (await request.json()) as ShareRequest;

      if (!sharer_id || !campaign_id) {
        return new Response('Missing sharer_id or campaign_id', { status: 400 });
      }

      const encoder = new TextEncoder();
      const key = await crypto.subtle.importKey(
        'raw',
        Uint8Array.from(atob(env.SHARE_HMAC_SECRET), (c) => c.charCodeAt(0)),
        { name: 'HMAC', hash: 'SHA-256' },
        false,
        ['sign']
      );

      const data = encoder.encode(`${sharer_id}:${campaign_id}`);
      const signature = await crypto.subtle.sign('HMAC', key, data);
      const base62 = base62urlEncode(new Uint8Array(signature));
      const claim_token = base62.slice(0, 22);

      const campaignRes = await fetch(
        `${env.SUPABASE_URL}/rest/v1/campaign?id=eq.${campaign_id}&select=business_id,recipient_offer_text`,
        {
          headers: {
            apikey: env.SUPABASE_SERVICE_ROLE,
            Authorization: `Bearer ${env.SUPABASE_SERVICE_ROLE}`
          }
        }
      );
      type CampaignRow = {
        business_id: string;
        recipient_offer_text: string;
      };

      const campaign = ((await campaignRes.json()) as CampaignRow[])[0];
      if (!campaign) {
        return new Response('Invalid campaign', { status: 404 });
      }

      await env.CLAIM_KV.put(
        claim_token,
        JSON.stringify({
          business_id: campaign.business_id,
          campaign_id,
          sharer_id,
          redeemed: false,
          campaign: campaign.recipient_offer_text
        })
      );

      await fetch(`${env.SUPABASE_URL}/rest/v1/sharer_campaign`, {
        method: 'POST',
        headers: {
          apikey: env.SUPABASE_SERVICE_ROLE,
          Authorization: `Bearer ${env.SUPABASE_SERVICE_ROLE}`,
          'Content-Type': 'application/json',
          Prefer: 'resolution=merge-duplicates'
        },
        body: JSON.stringify({
          sharer_id,
          campaign_id,
          shares_count: 1
        })
      });

      return new Response(
        JSON.stringify({
          claim_token,
          share_url: `https://viabees.com/claim/${claim_token}`
        }),
        {
          headers: { 'Content-Type': 'application/json' }
        }
      );
    }

    return new Response('Not found', { status: 404 });
  }
};
