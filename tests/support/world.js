const { setWorldConstructor, World } = require('@cucumber/cucumber');
const { chromium } = require('playwright');
const path = require('path');

class PlaywrightWorld extends World {
  async openPage() {
    if (!this.browser) {
      this.browser = await chromium.launch({ headless: true });
    }
    this.page = await this.browser.newPage();
    const filePath = path.join(__dirname, '..', '..', 'docs', 'index.html');
    const url = `file://${filePath}`;
    await this.page.goto(url);
  }

  async close() {
    if (this.browser) {
      await this.browser.close();
      this.browser = null;
    }
  }
}

setWorldConstructor(PlaywrightWorld);
