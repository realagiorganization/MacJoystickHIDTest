const { chromium } = require("playwright");

const targetUrl = "http://127.0.0.1:4173/";
const outputPath = "images/gh-pages-screenshot.png";

(async () => {
  const browser = await chromium.launch();
  const page = await browser.newPage({
    viewport: { width: 1400, height: 900 },
  });

  await page.goto(targetUrl, { waitUntil: "networkidle" });
  await page.waitForTimeout(1000);
  await page.screenshot({ path: outputPath, fullPage: true });
  await browser.close();
})();
