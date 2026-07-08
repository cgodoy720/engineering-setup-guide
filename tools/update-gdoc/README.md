# update-gdoc

Update a Google Doc's content **in place** — the doc keeps its URL, ID, sharing
settings, and revision history. Fixes the "every edit mints a new link" problem
when generating docs programmatically (e.g. from Claude Code).

```
node update-gdoc.js <docId-or-docs-url> <content.html>
```

The HTML is converted by Google Drive into normal Doc formatting (headings,
lists, tables, `<pre>` code blocks, etc.). Anyone at Pursuit can use this tool;
each person authorizes as themselves and can only update docs they already have
edit access to. Edits show up in the Doc's revision history under your name.

## One-time setup (per user)

1. `cd tools/update-gdoc && npm install`
2. Get the OAuth client file `credentials.json` and place it in this directory
   (ask in #engineering — it's distributed via the team secrets channel, not
   committed to the repo). Alternatively set `GDOC_OAUTH_CLIENT=/path/to/credentials.json`.
3. Run the tool once. A browser window opens for Google consent (pursuit.org
   accounts only). After that, a token is cached at
   `~/.config/update-gdoc/token.json` and no browser is needed again.

## One-time setup (org — already done, for reference)

The shared OAuth client lives in the Pursuit Google Cloud project:

1. In the GCP console, enable the **Google Drive API**.
2. **APIs & Services → OAuth consent screen**: User type **Internal**
   (pursuit.org only — this is what keeps the tool org-restricted and avoids
   Google's app-verification process).
3. **APIs & Services → Credentials → Create credentials → OAuth client ID**,
   application type **Desktop app**. Download the JSON as `credentials.json`.
4. Distribute `credentials.json` via the team secrets channel.

## Safety

- The script verifies the target is a Google Doc (`application/vnd.google-apps.document`)
  before overwriting; it refuses to touch spreadsheets, PDFs, or anything else.
- The update replaces the doc's entire body with the HTML file's content —
  keep the source HTML for any doc you maintain this way, and edit that.
