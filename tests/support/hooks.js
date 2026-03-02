const { AfterAll } = require('@cucumber/cucumber');

AfterAll(async function () {
  if (this.close) {
    await this.close();
  }
});
