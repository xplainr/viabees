// _worker.js
import * as entry from './dist/_worker.js/index.js';

export default {
  async fetch(request, env, ctx) {
    try {
      // Try static asset first (e.g., index.html, viabees-logo.png)
      return await env.ASSETS.fetch(request);
    } catch {
      // Fallback to Astro SSR Worker
      return entry.default.fetch(request, env, ctx);
    }
  }
};
