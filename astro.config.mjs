// @ts-check
import { defineConfig } from 'astro/config';

export default defineConfig({
  vite: {
    resolve: {
      alias: {
        '@components': new URL('./src/components', import.meta.url).pathname
      }
    }
  }
});
