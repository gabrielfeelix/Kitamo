import { chromium } from 'playwright';

(async () => {
    const browser = await chromium.launch({ headless: false });
    const context = await browser.newContext({
        viewport: { width: 1920, height: 1080 }
    });
    const page = await context.newPage();

    // Bypass CSP to inject Figma capture script
    await page.route('**/*', async (route) => {
        const response = await route.fetch();
        const headers = { ...response.headers() };
        delete headers['content-security-policy'];
        delete headers['content-security-policy-report-only'];
        await route.fulfill({ response, headers });
    });

    // Navigate to the page
    console.log('Opening page...');
    await page.goto('http://localhost:8000/empresa', { waitUntil: 'networkidle' });

    // Wait for initial load
    await page.waitForTimeout(2000);

    // Scroll to bottom slowly to trigger all animations
    console.log('Scrolling to load all content...');
    await page.evaluate(async () => {
        const distance = 100;
        const delay = 50;

        while (window.scrollY + window.innerHeight < document.body.scrollHeight) {
            window.scrollBy(0, distance);
            await new Promise(resolve => setTimeout(resolve, delay));
        }
    });

    // Wait at bottom
    await page.waitForTimeout(2000);

    // Scroll back to top
    console.log('Scrolling back to top...');
    await page.evaluate(() => window.scrollTo({ top: 0, behavior: 'smooth' }));
    await page.waitForTimeout(1500);

    // Inject Figma capture script
    console.log('Injecting Figma capture script...');
    const captureScriptResponse = await page.context().request.get(
        'https://mcp.figma.com/mcp/html-to-design/capture.js'
    );
    const captureScriptText = await captureScriptResponse.text();

    await page.evaluate((scriptContent) => {
        const scriptEl = document.createElement('script');
        scriptEl.textContent = scriptContent;
        document.head.appendChild(scriptEl);
    }, captureScriptText);

    // Wait for script to load
    await page.waitForTimeout(1000);

    // Wait for all animations to complete
    console.log('Waiting for animations to complete...');
    await page.waitForTimeout(3000);

    // Trigger capture
    console.log('Capturing page...');
    const result = await page.evaluate(() => {
        return window.figma.captureForDesign({
            captureId: '9697184d-1de9-442a-9909-a8cc23df175f',
            endpoint: 'https://mcp.figma.com/mcp/capture/9697184d-1de9-442a-9909-a8cc23df175f/submit',
            selector: 'body'
        });
    });

    console.log('Capture result:', result);

    if (result.success !== false) {
        console.log('✓ Capture successful! Browser will stay open for 30 seconds.');
        await page.waitForTimeout(30000);
    } else {
        console.log('✗ Capture failed:', result.error);
        await page.waitForTimeout(5000);
    }

    await browser.close();
    console.log('Done!');
})();
