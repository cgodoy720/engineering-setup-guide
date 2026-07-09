#!/usr/bin/env node
/**
 * update-gdoc — update a Google Doc's content in place, keeping its URL, doc ID,
 * and sharing settings intact.
 *
 * Usage:
 *   node update-gdoc.js <docId-or-docs-url> <content.html>
 *
 * The HTML file's body is converted by Google Drive into normal Google Doc
 * content (headings, lists, tables, code via <pre>, etc.).
 *
 * Auth: one-time browser consent per user (token cached in
 * ~/.config/update-gdoc/token.json). Requires a credentials.json OAuth client
 * file next to this script — see README.md for the one-time setup.
 */

const fs = require('fs');
const path = require('path');
const os = require('os');
const { authenticate } = require('@google-cloud/local-auth');
const { google } = require('googleapis');

const SCOPES = ['https://www.googleapis.com/auth/drive'];
const CREDENTIALS_PATH = process.env.GDOC_OAUTH_CLIENT || path.join(__dirname, 'credentials.json');
const TOKEN_DIR = path.join(os.homedir(), '.config', 'update-gdoc');
const TOKEN_PATH = path.join(TOKEN_DIR, 'token.json');

function usage(msg) {
  if (msg) console.error(`Error: ${msg}\n`);
  console.error('Usage: node update-gdoc.js <docId-or-docs-url> <content.html|content.md>');
  process.exit(1);
}

function parseDocId(input) {
  // Accept a bare ID or any docs.google.com URL
  const urlMatch = input.match(/\/document\/d\/([a-zA-Z0-9_-]+)/);
  if (urlMatch) return urlMatch[1];
  if (/^[a-zA-Z0-9_-]{20,}$/.test(input)) return input;
  usage(`"${input}" doesn't look like a Google Doc ID or URL`);
}

async function loadSavedClient() {
  try {
    const token = JSON.parse(fs.readFileSync(TOKEN_PATH, 'utf8'));
    return google.auth.fromJSON(token);
  } catch {
    return null;
  }
}

async function saveClient(client) {
  const keys = JSON.parse(fs.readFileSync(CREDENTIALS_PATH, 'utf8'));
  const key = keys.installed || keys.web;
  fs.mkdirSync(TOKEN_DIR, { recursive: true });
  fs.writeFileSync(
    TOKEN_PATH,
    JSON.stringify({
      type: 'authorized_user',
      client_id: key.client_id,
      client_secret: key.client_secret,
      refresh_token: client.credentials.refresh_token,
    }),
    { mode: 0o600 }
  );
}

async function getAuthClient() {
  const saved = await loadSavedClient();
  if (saved) return saved;

  if (!fs.existsSync(CREDENTIALS_PATH)) {
    console.error(
      `No OAuth client file found at ${CREDENTIALS_PATH}.\n` +
        'Follow the one-time setup in README.md (or set GDOC_OAUTH_CLIENT to its path).'
    );
    process.exit(1);
  }

  const client = await authenticate({ scopes: SCOPES, keyfilePath: CREDENTIALS_PATH });
  if (client.credentials) await saveClient(client);
  return client;
}

async function main() {
  const [docArg, htmlArg] = process.argv.slice(2);
  if (!docArg || !htmlArg) usage();

  const fileId = parseDocId(docArg);
  const htmlPath = path.resolve(htmlArg);
  if (!fs.existsSync(htmlPath)) usage(`content file not found: ${htmlPath}`);

  const auth = await getAuthClient();
  const drive = google.drive({ version: 'v3', auth });

  // Confirm the target is a Google Doc before overwriting anything
  const { data: meta } = await drive.files.get({ fileId, fields: 'id,name,mimeType' });
  if (meta.mimeType !== 'application/vnd.google-apps.document') {
    console.error(`Target file "${meta.name}" is ${meta.mimeType}, not a Google Doc — refusing to overwrite.`);
    process.exit(1);
  }

  // Markdown converts with native Docs checkboxes/tables; HTML for everything else
  const sourceMime = path.extname(htmlPath).toLowerCase() === '.md' ? 'text/markdown' : 'text/html';
  await drive.files.update({
    fileId,
    media: { mimeType: sourceMime, body: fs.createReadStream(htmlPath) },
  });

  console.log(`Updated "${meta.name}" in place: https://docs.google.com/document/d/${fileId}/edit`);
}

main().catch((err) => {
  console.error(err.response?.data?.error?.message || err.message);
  process.exit(1);
});
