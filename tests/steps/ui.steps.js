const { Given, Then, When } = require('@cucumber/cucumber');
const assert = require('assert');

Given('I open the docs page', async function () {
  await this.openPage();
});

Then('I see the heading {string}', async function (text) {
  const heading = await this.page.textContent('h1');
  assert(heading && heading.includes(text), `Heading did not include "${text}"`);
});

Then('I see a call-to-action button labeled {string}', async function (label) {
  const button = await this.page.locator('a.btn.primary', { hasText: label });
  const count = await button.count();
  assert(count > 0, `No primary CTA with label ${label}`);
});

Then('I see a secondary button labeled {string}', async function (label) {
  const button = await this.page.locator('a.btn.ghost', { hasText: label });
  const count = await button.count();
  assert(count > 0, `No secondary CTA with label ${label}`);
});

Then('I see a section titled {string}', async function (title) {
  const section = await this.page.locator('section h2', { hasText: title });
  const count = await section.count();
  assert(count > 0, `Section title missing: ${title}`);
});

When('I wait for the preview image', async function () {
  await this.page.waitForSelector('img[alt*="interface preview"]', { state: 'visible', timeout: 5000 });
});

Then('the preview image is visible', async function () {
  const img = await this.page.locator('img[alt*="interface preview"]');
  const visible = await img.isVisible();
  assert(visible, 'Preview image not visible');
});
