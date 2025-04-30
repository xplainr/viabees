import { createClient } from '@supabase/postgrest-js';

export interface Env {
  CLAIM_KV: KVNamespace;
  SUPABASE_URL: string;
  SUPABASE_SERVICE_ROLE: string;
}

export default {
  async fetch(request: Request, env: Env, ctx: ExecutionContext): Promise<Response> {
    const url = new URL(request.url);
    const pathname = url.pathname;

    // ✅ Supabase Client: always create inside the fetch scope
    const supabase = createClient(
      env.SUPABASE_URL,
      env.SUPABASE_SERVICE_ROLE,
      { headers: { 'X-Client-Info': 'viabees-worker' } }
    );

    // 🧩 Claim token route: /api/claim/:token
    if (pathname.startsWith("/api/claim/")) {
      const token = pathname.split("/").pop();

      if (!token || token.length !== 22) {
        return new Response("Invalid token format", { status: 400 });
      }

      const metadata = await env.CLAIM_KV.get(token, { type: "json" });

      if (!metadata) {
        return new Response("Token not found or expired", { status: 404 });
      }

      const { redeemed, ttl } = metadata;
      const now = Date.now();

      if (redeemed) {
        return new Response("Token already redeemed", { status: 409 });
      }

      if (ttl && now > ttl) {
        return new Response("Token expired", { status: 410 });
      }

      await env.CLAIM_KV.put(token, JSON.stringify({ ...metadata, redeemed: true }));

      return new Response(JSON.stringify({ status: "valid", campaign: metadata.campaign }), {
        headers: { "Content-Type": "application/json" },
      });
    }

    // 🔐 [Placeholder] API route to issue tokens (WIP)
    if (pathname === "/api/share" && request.method === "POST") {
      return new Response("Share endpoint not yet implemented", { status: 501 });
    }

    return new Response("Not found", { status: 404 });
  }
};
