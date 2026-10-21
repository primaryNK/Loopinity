'use strict';

const http = require('node:http');
const fs = require('node:fs');
const path = require('node:path');

const host = process.env.HOST || '0.0.0.0';
const port = Number(process.env.PORT) || 3000;
const publicDir = path.join(__dirname, 'public');

const mimeTypes = {
  '.html': 'text/html; charset=utf-8',
  '.css': 'text/css; charset=utf-8',
  '.js': 'text/javascript; charset=utf-8',
  '.json': 'application/json; charset=utf-8',
  '.png': 'image/png',
  '.svg': 'image/svg+xml',
  '.ico': 'image/x-icon'
};

function send(res, status, body, type = 'text/plain; charset=utf-8') {
  res.writeHead(status, {
    'Content-Type': type,
    'X-Content-Type-Options': 'nosniff',
    'Referrer-Policy': 'strict-origin-when-cross-origin'
  });
  res.end(body);
}

const server = http.createServer((req, res) => {
  const requestUrl = new URL(req.url, `http://${req.headers.host || 'localhost'}`);

  if (requestUrl.pathname === '/health') {
    return send(res, 200, JSON.stringify({ status: 'ok' }), mimeTypes['.json']);
  }

  let pathname;
  try {
    pathname = decodeURIComponent(requestUrl.pathname);
  } catch {
    return send(res, 400, 'Bad request');
  }

  const relativePath = pathname === '/' ? 'index.html' : pathname.replace(/^\/+/, '');
  const filePath = path.resolve(publicDir, relativePath);

  if (filePath !== publicDir && !filePath.startsWith(`${publicDir}${path.sep}`)) {
    return send(res, 403, 'Forbidden');
  }

  fs.stat(filePath, (statError, stats) => {
    if (statError || !stats.isFile()) return send(res, 404, 'Not found');

    const ext = path.extname(filePath).toLowerCase();
    const headers = {
      'Content-Type': mimeTypes[ext] || 'application/octet-stream',
      'X-Content-Type-Options': 'nosniff',
      'Referrer-Policy': 'strict-origin-when-cross-origin',
      'Cache-Control': ext === '.html' ? 'no-cache' : 'public, max-age=86400'
    };

    res.writeHead(200, headers);
    const stream = fs.createReadStream(filePath);
    stream.on('error', () => {
      if (!res.headersSent) send(res, 500, 'Internal server error');
      else res.destroy();
    });
    stream.pipe(res);
  });
});

server.listen(port, host, () => {
  console.log(`Loopinity is running at http://${host}:${port}`);
});

module.exports = server;
