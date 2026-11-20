# Taskfolio week page — how to fill it

Verified on a real week. If the page changes, trust the live DOM over this file and update it.

## Page structure
- Day column = `.day` (its text starts with `MON`…`FRI`); entries = `.ent`.
- Draft (from Jira or Calendar): an **Edit** button inside its `.ent`. Saved entry: its `.entbtn`. The dialog button reads **Add entry** for a draft or new entry and **Save** for a saved one.
- New entry: the day column's `+ Add` (`button.addbtn[data-add=YYYY-MM-DD]`).
- Match an entry by the **exact first line** of its text (the Jira key, e.g. `PYR-123`) or, for a meeting, the second line starting with the title. Never use `includes`: `OLS-10` also matches `OLS-1049`.
- A saved entry's text starts with its category (e.g. `TESTING`), not the key, so match saved entries by key with `includes` only after you have confirmed the key is unique in that day.
- The list reorders after saving (saved entries first).

## Dialog fields
Ids: `#c` Category, `#i` Subcategory, `#pj` Project, `#ts` Start, `#te` End, `#j` Jira issue, `#d` Description. A saved entry also has `#dy` (date). Selects have no `name`.
- **Read the option values first.** Category, Subcategory and Project are selects whose option *values* differ per team (some are readable like `test-exec`, some are opaque ids). Dump them once:
  `[...document.getElementById('i').options].map(o=>o.value+'='+o.text)` and use the values, never the labels.
- Subcategory lists differ per Category, and **Project only fills after a Subcategory is set**. Subcategory must be set, or the form drops the project. Set Category, wait, Subcategory, wait, then Project and Start, wait, then End.
- Set selects with the native setter and a `change` event:
  `Object.getOwnPropertyDescriptor(HTMLSelectElement.prototype,'value').set.call(el,v); el.dispatchEvent(new Event('change',{bubbles:true}))`.
  Inputs (`#d`, `#j`) use `HTMLInputElement.prototype` and an `input` event. Check that the value exists in the select's options before setting; stop on a missing option.
- **Start and End are required**: without them *Add entry* silently keeps the dialog open. Times are 15 m steps. Setting both fills **Logged time** automatically.
- Logged time: read it from the dialog text between the `15m 30m 1h 2h 4h 8h −` buttons and `+` (with the selects removed). Compare it with the confirmed row **before** saving and stop on any mismatch. Preset buttons *set* the value; `−` / `+` move 5 m, and only one click per `execute` call counts.
- Meetings keep their title in `#d` (the Jira field is empty). Changing `#d` renames the meeting entry.
- `+ Add` for a Jira card with no draft: type the key into `#j`, **then set Project again** (typing the key can reset it; it never fills from the key).
- To add a Description to a saved entry, open it with `.entbtn`, set only `#d`, check Start and End are unchanged, then **Save**.

## Deleting
- Draft: the entry's **Delete** on the week page, then confirm **Delete draft** (a draft deleted from a Calendar sync does not come back).
- Saved entry: open it with `.entbtn`, **Delete** in the dialog, then confirm **Delete entry**.

## Gotchas
- "Refresh from Calendar" may fail ("Could not read Google Calendar"); read Calendar with the connector and `+ Add` the missing meetings.
- Reloading drops injected helpers and may pull new Jira drafts. Re-inject after every reload.
- The list may not refresh after a `+ Add` save. **Reload before checking**, and check for duplicate pairs afterwards (a batch of six `+ Add` once produced six identical pairs; the second copy of each was deleted through its dialog). Never re-submit.
- Helper files in the scratchpad can disappear between turns; recreate them.
- Taskfolio takes 1 h off any entry whose Start–End overlaps the lunch hour; `scripts/tf-lib.sh` (`fmt`) predicts the logged value, so a lunch-crossing row fails the read-back instead of saving a wrong value.
- Never click **Submit week**.
