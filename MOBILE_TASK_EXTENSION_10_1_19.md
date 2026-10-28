# Mobile task: update the app's extension copy to 10.1.19

**For:** the mobile developer.
**Why:** when the teacher picks a lesson on a schedule card, the extension now sends the card's class («سادس», «أول بنات») with the lesson AI request. Hader uses it to tell the AI the right grade («الصف السادس الابتدائي»). Before, the grade was always empty and the AI guessed the stage. See `docs/EXTENSION_LESSON_AI_API.md` → `classroom`.

## Step
**Copy `content.js`** from `Moeen-Extension` (commit `f98aa83`, version 10.1.19) over `assets/hader/content.js`.
- The app's copy today is **exactly** 10.1.18 (checked on 2026-10-28), so this is a plain replace.
- **Nothing else changes:** `hader_shim.js` already has `LESSON_AI` (from 10.1.18), and the new `classroom` field goes through the same `haderApi` call. No Dart changes.

## Check on a real phone
- [ ] Pick a lesson on a schedule card and prepare it. The lesson fields are filled with AI text, as before.
- [ ] Tell the owner the time you prepared. Claude checks the n8n execution: the `grade` should now be filled (e.g. «الصف السادس الابتدائي»).
- [ ] Ship it with the next app release. It isn't urgent: until then the app works as today, only without the grade.
