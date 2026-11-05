import {defineConfig} from '@playwright/test';
const port=Number(process.env.STELLAR_TEST_PORT||4173),url=`http://127.0.0.1:${port}`;
export default defineConfig({testDir:'./e2e',timeout:180000,workers:1,use:{actionTimeout:15000,baseURL:url,viewport:{width:1280,height:800},trace:'retain-on-failure'},webServer:{command:`npm exec vite preview -- --host 0.0.0.0 --port ${port}`,url,reuseExistingServer:!process.env.STELLAR_TEST_PORT}});
