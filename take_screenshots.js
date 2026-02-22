import { chromium } from 'playwright';
import fs from 'fs';

const BASE_URL = 'http://127.0.0.1:8000';
const SCREENSHOT_DIR = './screenshots_kitamo';

if (!fs.existsSync(SCREENSHOT_DIR)) {
    fs.mkdirSync(SCREENSHOT_DIR);
}

const pages = [
    { name: '01_Login', url: '/login' },
    { name: '02_Dashboard', url: '/dashboard' },
    { name: '03_Contas', url: '/accounts/overview' },
    { name: '04_Cartoes', url: '/meus-cartoes' },
    { name: '05_Metas', url: '/goals' },
    { name: '06_Notificacoes', url: '/notifications' },
    { name: '07_Settings_About', url: '/settings/about' },
    { name: '08_Settings_Appearance', url: '/settings/appearance' },
    { name: '09_Admin_News', url: '/admin/news' },
];

(async () => {
    const browser = await chromium.launch();
    const context = await browser.newContext();
    const page = await context.newPage();

    console.log('🚀 Iniciando captura de telas...');

    // Login
    await page.goto(`${BASE_URL}/login`);
    await page.fill('input[type="email"]', 'test@example.com');
    await page.fill('input[type="password"]', 'password');
    await page.click('button[type="submit"]');
    await page.waitForNavigation();

    for (const p of pages) {
        // Desktop
        await page.setViewportSize({ width: 1440, height: 900 });
        await page.goto(`${BASE_URL}${p.url}`);
        await page.waitForTimeout(2000); // Espera carregar animações
        await page.screenshot({ path: `${SCREENSHOT_DIR}/desktop_${p.name}.png`, fullPage: true });
        console.log(`✅ Desktop: ${p.name}`);

        // Mobile
        await page.setViewportSize({ width: 375, height: 812 });
        await page.goto(`${BASE_URL}${p.url}`);
        await page.waitForTimeout(2000);
        await page.screenshot({ path: `${SCREENSHOT_DIR}/mobile_${p.name}.png`, fullPage: true });
        console.log(`✅ Mobile: ${p.name}`);
    }

    await browser.close();
    console.log(`✨ Pronto! Todos os prints estão na pasta ${SCREENSHOT_DIR}`);
})();
