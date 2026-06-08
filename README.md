# 63smorrell.prycem.com

GitHub-backed source for the 63 S. Morrell / Geneva property website.

This repository is intended to be the editable source of truth for the Cloudflare-hosted site.

Structure:

- `public/index.html` — main site page
- `public/assets/` — photos and image assets
- `src/worker.js` — Cloudflare Worker code for static assets and contact form
- `wrangler.jsonc` — Cloudflare Workers deployment configuration
