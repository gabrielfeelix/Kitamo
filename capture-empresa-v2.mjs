import { chromium } from 'playwright';

(async () => {
    const browser = await chromium.launch({
        headless: false,
        args: ['--disable-web-security']
    });

    const context = await browser.newContext({
        viewport: { width: 1920, height: 1080 }
    });

    const page = await context.newPage();

    try {
        // Bypass CSP
        await page.route('**/*', async (route) => {
            const response = await route.fetch();
            const headers = { ...response.headers() };
            delete headers['content-security-policy'];
            delete headers['content-security-policy-report-only'];
            await route.fulfill({ response, headers });
        });

        // Navigate
        console.log('Opening page...');
        await page.goto('http://localhost:8000/empresa', {
            waitUntil: 'networkidle',
            timeout: 30000
        });
        await page.waitForTimeout(2000);

        // Scroll to bottom to load animations
        console.log('Scrolling to load all content...');
        const scrollHeight = await page.evaluate(() => document.body.scrollHeight);
        const viewportHeight = await page.evaluate(() => window.innerHeight);
        const scrollSteps = Math.ceil(scrollHeight / viewportHeight);

        for (let i = 0; i < scrollSteps; i++) {
            await page.evaluate((step) => {
                window.scrollTo(0, step * window.innerHeight);
            }, i);
            await page.waitForTimeout(500);
        }

        console.log('At bottom, waiting...');
        await page.waitForTimeout(2000);

        // Scroll back to top
        console.log('Scrolling back to top...');
        await page.evaluate(() => window.scrollTo({ top: 0, behavior: 'smooth' }));
        await page.waitForTimeout(2000);

        // Inject capture script
        console.log('Injecting Figma capture script...');
        const captureScript = await page.context().request.get(
            'https://mcp.figma.com/mcp/html-to-design/capture.js'
        );
        const scriptContent = await captureScript.text();

        await page.addScriptTag({ content: scriptContent });
        await page.waitForTimeout(1500);

        // Trigger capture
        console.log('Triggering capture...');
        const captureResult = await page.evaluate(() => {
            if (typeof window.figma === 'undefined' || !window.figma.captureForDesign) {
                return { success: false, error: 'Figma capture script not loaded' };
            }

            return window.figma.captureForDesign({
                captureId: '9697184d-1de9-442a-9909-a8cc23df175f',
                endpoint: 'https://mcp.figma.com/mcp/capture/9697184d-1de9-442a-9909-a8cc23df175f/submit',
                selector: 'body'
            });
        });

        console.log('Capture result:', JSON.stringify(captureResult, null, 2));

        // Keep browser open to show toolbar
        console.log('Keeping browser open for 20 seconds...');
        await page.waitForTimeout(20000);

    } catch (error) {
        console.error('Error during capture:', error.message);
    } finally {
        await browser.close();
        console.log('Browser closed.');
    }
})();
