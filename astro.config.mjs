import cloudflare from '@astrojs/cloudflare';
import { defineConfig } from 'astro/config';

export default defineConfig({
  adapter: cloudflare(),
  output: 'server',
  vite: {
    resolve: {
      alias: {
        '@components': new URL('./src/components', import.meta.url).pathname
      }
    }
  }
});
