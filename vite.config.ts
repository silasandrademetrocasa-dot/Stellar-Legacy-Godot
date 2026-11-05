import { defineConfig } from 'vite';
export default defineConfig({base:process.env.BASE_PATH || './',server:{host:'0.0.0.0'},build:{target:'es2022',rollupOptions:{input:'app.html'}}});
