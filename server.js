import { createServer } from 'node:http';
import { readFile, stat } from 'node:fs/promises';
import { dirname, extname, join, normalize, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';
import { spawn } from 'node:child_process';
import figlet from 'figlet';

const root = dirname(fileURLToPath(import.meta.url));
const port = Number(process.env.PORT) || 4173;
const types = { '.css': 'text/css', '.html': 'text/html', '.js': 'text/javascript', '.json': 'application/json' };
const fontPath = join(root, 'fonts');
figlet.defaults({ fontPath });
const fonts = figlet.fontsSync().sort((a, b) => a.localeCompare(b));

export const listFonts = () => fonts;
export function renderText(text, font = 'Graffiti') {
  const safeFont = fonts.includes(font) ? font : 'Graffiti';
  return figlet.textSync(String(text ?? ''), { font: safeFont, horizontalLayout: 'default', verticalLayout: 'default', width: 10000, whitespaceBreak: false });
}
function json(res, status, value) { res.writeHead(status, { 'Content-Type': 'application/json; charset=utf-8' }); res.end(JSON.stringify(value)); }
async function requestJson(req) {
  let data = '';
  for await (const chunk of req) { data += chunk; if (data.length > 100000) throw new Error('Request is too large'); }
  return JSON.parse(data || '{}');
}
export const app = createServer(async (req, res) => {
  const url = new URL(req.url, `http://${req.headers.host || 'localhost'}`);
  if (req.method === 'GET' && url.pathname === '/api/fonts') return json(res, 200, { fonts });
  if (req.method === 'POST' && url.pathname === '/api/render-all') {
    try {
      const { text } = await requestJson(req);
      return json(res, 200, { results: fonts.map((font) => ({ font, art: renderText(text, font) })) });
    } catch (error) { return json(res, 400, { error: error.message }); }
  }
  if (req.method === 'POST' && url.pathname === '/api/render') {
    try { const { text, font } = await requestJson(req); return json(res, 200, { art: renderText(text, font) }); }
    catch (error) { return json(res, 400, { error: error.message }); }
  }
  const file = normalize(join(root, url.pathname === '/' ? 'index.html' : url.pathname.slice(1)));
  if (!file.startsWith(root)) return res.writeHead(403).end('Forbidden');
  try { if (!(await stat(file)).isFile()) throw new Error(); res.writeHead(200, { 'Content-Type': `${types[extname(file)] || 'application/octet-stream'}; charset=utf-8` }); res.end(await readFile(file)); }
  catch { res.writeHead(404).end('Not found'); }
});
export function startServer(startPort = port, openBrowser = true) {
  const tryPort = (candidate) => {
    const onError = (error) => {
      app.off('listening', onListening);
      if (error.code === 'EADDRINUSE') return tryPort(candidate + 1);
      throw error;
    };
    const onListening = () => {
      app.off('error', onError);
      const url = `http://localhost:${candidate}`;
      console.log(`ASCII Art Studio: ${url}`);
      if (openBrowser) { const browser = spawn('cmd.exe', ['/c', 'start', '', url], { detached: true, stdio: 'ignore', windowsHide: true }); browser.unref(); }
    };
    app.once('error', onError);
    app.once('listening', onListening);
    app.listen(candidate);
  };
  tryPort(startPort);
}
if (process.pkg || process.argv[1]?.endsWith('server.js') || (process.argv[1] && resolve(process.argv[1]) === fileURLToPath(import.meta.url))) startServer(port, process.env.NO_BROWSER !== '1');
