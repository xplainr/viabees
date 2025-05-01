import { defineConfig } from 'astro/config';
import cloudflare from '@astrojs/cloudflare';

export default defineConfig({
  adapter: cloudflare(),
  vite: {
    resolve: {
      alias: {
        '@components': new URL('./src/components', import.meta.url).pathname
      }
    },
    optimizeDeps: {
      exclude: ['tsconfig.json']
    }
  }
});
