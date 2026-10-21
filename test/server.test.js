'use strict';

const { test, after } = require('node:test');
const assert = require('node:assert/strict');

process.env.HOST = '127.0.0.1';
process.env.PORT = '0';
const server = require('../server');

after(() => server.close());

test('health endpoint reports ok', async () => {
  await new Promise((resolve) => server.listening ? resolve() : server.once('listening', resolve));
  const address = server.address();
  const response = await fetch(`http://127.0.0.1:${address.port}/health`);
  assert.equal(response.status, 200);
  assert.deepEqual(await response.json(), { status: 'ok' });
});

test('serves the website and generated hero asset', async () => {
  const address = server.address();
  const page = await fetch(`http://127.0.0.1:${address.port}/`);
  assert.equal(page.status, 200);
  const html = await page.text();
  assert.match(html, /LOOPINITY/);
  assert.match(html, /AI 동반자/);
  assert.match(html, /href="\.\/styles\.css"/);

  const image = await fetch(`http://127.0.0.1:${address.port}/assets/loopinity-hero.png`);
  assert.equal(image.status, 200);
  assert.equal(image.headers.get('content-type'), 'image/png');
});

test('blocks traversal outside the public directory', async () => {
  const address = server.address();
  const response = await fetch(`http://127.0.0.1:${address.port}/%2e%2e/server.js`);
  assert.ok([403, 404].includes(response.status));
});
