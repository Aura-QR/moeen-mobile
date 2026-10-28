# Mobile task: the lesson's AI text through Hader (extension 10.1.18)

**For:** the mobile developer.
**Why:** the app's copy of the extension (`assets/hader/content.js`) calls n8n directly, with the n8n key written in the file. Anyone who unpacks the app can read the key. Extension 10.1.18 now asks Hader instead (`POST /api/extension/lesson-ai`, see `moeen-backend/docs/EXTENSION_LESSON_AI_API.md`), so the key can leave the code and then be changed.

## Steps
1. **Copy the new `content.js`** from `Moeen-Extension` (commit `fbc5c9d`, version 10.1.18) over `assets/hader/content.js`, the same way as previous updates.
2. **Add one action to `assets/hader/hader_shim.js`,** next to `LOG_LESSON_PREPARATION`:
   ```js
   // The lesson's AI text through Hader (content.js requestLessonAI).
   if (action === 'LESSON_AI') {
     return bridge('haderApi', {
       method: 'POST',
       path: '/extension/lesson-ai',
       body: msg.payload || {}
     });
   }
   ```
   It uses the existing `haderApi` handler, so no Dart changes are needed. The handler already adds the teacher's token.
3. **Nothing breaks if step 2 is missing:** an unknown action returns `undefined`, and `content.js` then calls n8n directly as before. But the key can't be changed until step 2 ships.

## Check on a real phone
- [ ] Prepare a lesson from the app. The lesson fields (تمهيد، أهداف، غلق…) are filled with AI text, as before.
- [ ] In the backend logs or the n8n executions, the request now comes through Hader.
- [ ] Sign out, then prepare. It still works (it falls back to the direct call).
- [ ] Release a new app version. **Tell the owner**, because the key is changed only after the extension and the app are both updated.
