---
description: "Use when editing contact, forms, email delivery, public/index.html, src/worker.js, or deployment code for 63 S. Morrell. Covers the existing direct FormSubmit contact form and required markers."
name: "63 S. Morrell Contact Form Protection"
---
# 63 S. Morrell Contact Form Protection

Apply these instructions whenever editing the contact section, form handling, `public/index.html`, `src/worker.js`, or deployment code.

- Preserve the existing direct FormSubmit architecture in `public/index.html` unless Pryce explicitly approves a replacement.
- Before merge or deploy, confirm the source contains:
  - `formsubmit` or `formsubmit.co`
  - the `prycemandel@gmail.com` recipient marker (plain or URL-encoded)
  - the honeypot field
- Do not infer contact health from deployment success alone.
- Patch the contact block only; do not rewrite unrelated property content.
