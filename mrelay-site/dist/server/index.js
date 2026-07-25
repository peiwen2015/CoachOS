import { createServer } from "node:http";
import { readFileSync, statSync, existsSync, createReadStream } from "node:fs";
import { extname, join, normalize } from "node:path";
import { fileURLToPath } from "node:url";

const __filename = fileURLToPath(import.meta.url);
const __dirname = new URL(".", import.meta.url).pathname;
const root = normalize(join(__dirname, ".."));

const mimeTypes = {
  ".html": "text/html; charset=utf-8",
  ".css": "text/css; charset=utf-8",
  ".js": "application/javascript; charset=utf-8",
  ".jpg": "image/jpeg",
  ".jpeg": "image/jpeg",
  ".png": "image/png",
  ".svg": "image/svg+xml",
  ".webp": "image/webp",
};

function sendFile(res, filePath) {
  const type = mimeTypes[extname(filePath)] || "application/octet-stream";
  res.statusCode = 200;
  res.setHeader("Content-Type", type);
  createReadStream(filePath).pipe(res);
}

createServer((req, res) => {
  const url = new URL(req.url || "/", "http://localhost");
  let pathname = decodeURIComponent(url.pathname);
  if (pathname === "/") pathname = "/index.html";

  const filePath = normalize(join(root, pathname));
  if (!filePath.startsWith(root) || !existsSync(filePath)) {
    res.statusCode = 404;
    res.setHeader("Content-Type", "text/plain; charset=utf-8");
    res.end("Not found");
    return;
  }

  if (statSync(filePath).isDirectory()) {
    const indexPath = join(filePath, "index.html");
    if (existsSync(indexPath)) {
      sendFile(res, indexPath);
      return;
    }
  }

  sendFile(res, filePath);
}).listen(process.env.PORT || 3000);
