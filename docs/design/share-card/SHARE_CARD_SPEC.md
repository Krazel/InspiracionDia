# Warm Words share card

Date: 2026-08-10
Status: **approved direction; app-side implementation in progress; public smart link blocked externally**

## Visual reference

- Approved reference: `warm-words-share-card-approved.png`.
- Approval basis: the owner requested a shareable card and had already authorized any additional image needed to finish the app without another approval round.
- The reference derives from the approved Today card rather than introducing a new visual language.

## Runtime contract

- Render a deterministic 1080 × 1350 PNG for the selected quote with `ImageRenderer`.
- Use the bundled `premium-mountains.png`, ivory background, gold details, serif quote, localized category and `Warm Words` signature.
- Share the PNG and one HTTPS destination through the native iOS share sheet.
- Do not share plain quote text as the primary item.
- English and Spanish quotes use the same composition; user-created quotes remain literal.

## Link behavior

- Planned public URL: `https://krazel.github.io/warm-words/share/`.
- The HTTPS item remains disabled in QA builds while that URL returns 404; no build may share a dead link.
- Installed app: the final signed App Store build should open Warm Words through Universal Links; the app also accepts the `warmwords` custom scheme for local/sideload QA.
- App absent: the public landing page should show the real App Store destination and Smart App Banner.
- A WhatsApp extension may place an attached image and URL separately. iOS cannot force third-party apps to make the image itself clickable.

## External gates

- Publish the Warm Words landing page and Apple App Site Association file.
- Obtain the real Apple Team ID and numeric App Store Apple ID.
- Enable Associated Domains on the registered App ID and final signing profile.
- Verify the AASA response, signed entitlements, installed/uninstalled routing and WhatsApp behavior.

No generated image is packaged in the app. The runtime recreates the approved composition with existing bundled assets so every quote remains accurate and local.
