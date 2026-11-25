# Pyrite (PYR-xxx) profile

Applies to every ticket with key `PYR-xxx`. Used by the `tc-pyr` skill.

## Targets
- Qase project: https://app.qase.io/project/Pyrite — API project code is `Pyrite` (not `PYR` / `PYRITE`).
- Qase API token: read from the environment variable `QASE_API_TOKEN` (each person creates their own; setup in this repo's README, section "Qase token"). Send it as header `Token: $QASE_API_TOKEN`. Never print, copy or store the value anywhere (chat, sheet, Qase, Jira, repo). If the variable is empty or the API returns 401, tell the user to follow the README setup; do not ask them to paste the token.
- Tracking sheet ("Pyrite QA"): the one entry point. Its link is team-private and is NOT stored in this public repo. Each person gives it once; keep it in your own memory or local notes. If it is missing, ask once and remember it.
- Prototype: URL and username are in the `Config` tab of the Tracking sheet (keys `PROTOTYPE_URL`, `PROTOTYPE_USER`). The **password is never written in the repo, sheet, Qase, Jira or chat**: read it from the environment variable `PYR_PROTOTYPE_PASSWORD` (setup in this repo's README, section "Pyrite prototype login"). If a key or the variable is missing, ask once (never ask for the password in chat; point to the README).
- Drive output folder and TC sheet template: read them from the `Config` tab of the Tracking sheet (columns: Key, Value; keys `DRIVE_FOLDER` and `TC_TEMPLATE`). If the tab or a key is missing, ask once; never guess a link.

## Create-TC flow
1. Write the TCs with the wording rule below ("Wording source"), then create them in Qase project Pyrite (suite chosen per feature; e.g. Authentication › Register).
2. In the Drive folder, create subfolder `PYR-xxx` and put the TC sheet inside, copied from the template, then apply "Drive TC sheet format" below.
3. Create (or update) the Qase **Test plan** for the ticket — see "Qase Test plan" below.
4. Update the tracking sheet row for the ticket.
5. Keep Qase cases, Test plan, sheet and any CSV identical.

**Reuse rule:** before creating anything, check for an existing Drive subfolder `PYR-xxx` + sheet, Qase cases/suite and Qase Test plan for that ticket. If found, update in place (same ids/links). Create only what is missing.

**`updateTCSheet`:** after a review or change, update all four, in order: Qase TCs → Qase Test plan → Drive TC sheet → tracking sheet. Confirm the ticket if ambiguous.

**Definition of done (create):** Qase cases + Qase Test plan + Drive TC sheet + tracking sheet updated, the TC file(s) added as Jira Web links (see "Jira web link"), Jira `TC Status` = `DONE`, and the Discord thread created and its link saved (see "Create sign-off"). Then report done and stop. Do NOT attach CSVs to Jira. A Jira comment is posted only when the user answers ใช่ to the "Question comment" prompt; setting the `TC Status` field is not a comment.

## Jira web link
Part of create (SKILL.md step 9), after the Drive sheet and tracking row exist and before the Create sign-off. Links **every TC file of the ticket** (the TC sheet(s) in its Drive subfolder `PYR-xxx`) to the Jira card as **Web links**.
- **Link text (title)** = the file name exactly, as it is in Drive (the same name as the TC sheet file). **URL** = that file's Drive link.
- Tool: Atlassian `createJiraIssueRemoteIssueLink` (via `discover` → `executeWrite`), inputs `issueIdOrKey`, `url`, `title`. Not a comment, not an attachment, not a URL custom field.
- **No duplicates:** first `listJiraIssueRemoteIssueLinks` on the ticket. A link whose URL is already there is skipped (a Web link cannot be removed or edited through the tool, so never add one twice). Say in one line which were added and which already existed.
- Shown in the HTML gate under planned targets (title + URL per link) and covered by the Approve; nothing is added before it.
- This is not the "Question comment" and needs no extra question to the user. `/tc-pyr xxx update` adds a link only if its URL is missing on the card.

## Drive TC sheet format
Applies to every TC sheet this skill creates or updates (create, `update`, `updateTCSheet`, review fixes). The template (`TC_TEMPLATE`) keeps its colors, borders, header text, the 15 columns and the dropdowns (Test Case Type, Test Status, PO/BA - TC Review Status); the settings below replace its wrapping and set the widths. Apply them to the whole used range (header row and every TC row), in one `batchUpdate`, after the rows are written:

- **Font:** `Calibri`, size `10` on every cell (header included), as in the template. Header bold; body not bold.
- **Text wrapping:** `WRAP` on every cell, header and body. (The template's body rows are `OVERFLOW_CELL`: change them.)
- **Alignment:** every row vertical `TOP`; header horizontal `CENTER`. Body horizontal `CENTER` for `Test Case Type`, `QA Owner` and `PO/BA - TC Review Status`; everything else left.
- **Column widths (px)** = the widths of the template `TC_TEMPLATE` (tab `PRY-xx TC`), set explicitly, no auto-fit (auto-fit makes the long text columns thousands of pixels wide and the short ones too narrow):

| Col | Header | Width |
|---|---|---|
| A | Test Case ID | 100 |
| B | Mapping with AC in ticket | 155 |
| C | Module / Feature | 164 |
| D | Test Title | 274 |
| E | Test Case Type | 169 |
| F | Precondition | 302 |
| G | Test Data | 302 |
| H | Test Step | 302 |
| I | Expected Result | 302 |
| J | QA Owner | 158 |
| K | Test Status | 207 |
| L | Linked Bug | 146 |
| M | Remark | 229 |
| N | PO/BA - TC Review Status | 100 |
| O | PO/BA - Feedback | 100 |

  If the template has more or fewer columns, keep these widths for the columns that match by header and give any other column 150. Never leave a column under 80 or over 320. If the template's widths change, the template wins: read them from its column metadata and update this table.
- **Row heights:** after the widths are set, `autoResizeDimensions` on the TC rows (ROWS). Read one row with several numbered lines back: if its height is only one line (about 21 px), the resize did not take effect, so set each row's height by hand: lines × 15 + 8 px, where lines = the largest, over the row's cells, of the sum of ROUNDUP(characters in a line / ((column width − 10) / 7)) over its lines. Header row 32 px. Freeze row 1.
- **Check before reporting:** read the font, wrap and widths back from one header cell, one body row and the column metadata, and say in the report `Calibri 10, wrap, widths set` or what differs. Row heights are estimates when set by hand: say so.

## Ticket review (before writing TCs)
Early PYR tickets have a **prototype** instead of Figma. **The prototype is a rough picture for developers** (how the pages look and flow), not a wording source.

**Wording rule (always):** every button name, and every other UI text (labels, messages, headings), comes **from the ticket only**. Never copy wording from the prototype into a TC. A different wording in the prototype is **not** a mismatch and is not reported. If the ticket does not name a button or text that a TC needs, do not borrow it from the prototype: describe the action in the ticket's own words and list it as a question for the PO (`ticket ไม่ระบุชื่อปุ่ม …`).

Review the ticket against what exists:

1. **Prototype (always)**: open it in a headless browser, log in with `PYR_PROTOTYPE_USER` / `PYR_PROTOTYPE_PASSWORD`, walk the screens the ticket touches. Compare each AC/EC with the prototype for **layout and flow only**: which screens exist, their order, which fields / buttons / states are present and where. Ignore its wording.
2. **Figma / PRD**: if the ticket links one, review against it as usual. If it does not, it is absent: do not ask, record "no Figma" / "no PRD" in the pre-draft review and Remark.
3. **Findings**: list every mismatch in layout / flow / presence of elements as `ticket says` vs `prototype shows` (screen, element) (never wording), plus anything in the prototype the ticket does not mention and anything in the ticket the prototype lacks. Never silently pick one side.
4. **Source of truth for TCs**: ticket AC/EC first, and the ticket alone for all wording. A TC for behavior that only the prototype shows is marked "from prototype" in Remark. An open mismatch is shown in the HTML review gate for the user to decide; do not ask separately.
5. The prototype is not the test environment. Execution uses the testing env in the `Config` tab / memory, not the prototype.
6. Never print, store or screenshot the password. Do not attach prototype screenshots that show the login form.

### Scope check (AC/EC outside this ticket)
Every PYR ticket has a section titled **"ไม่อยู่ใน ticket นี้:"**. It lists work that belongs to other cards. Before writing TCs, check every AC and EC:

1. Read that section. Missing section → say so in one line and check scope from the summary and description only.
2. **Listed items are cut, no questions.** An AC/EC that matches an item in "ไม่อยู่ใน ticket นี้:" gets **no TC**, is **not** asked about and is **not** written in the Remark. Show one FYI line in the HTML gate: `ตัดแล้ว: AC_03 (ของ PYR-xxx)`. If only part of an AC/EC matches, keep the in-scope part and cut the rest.
3. **Beyond scope (not listed).** An AC/EC that is not in that section but describes behavior, screen or flow that the ticket's summary and description do not cover, or that obviously belongs to another feature, becomes a **question for the PO** (rule 4). It gets no TC until the user says include.
4. **Every question names its AC/EC.** Each question is one short line that starts with the AC/EC it is about, and quotes the ticket's wording:
   - `AC_03: เกิน scope? <สั้นๆ> — ขอ PO ยืนยันว่าอยู่ในการ์ดนี้ไหม`
   - `EC_02: ticket ไม่ระบุชื่อปุ่ม … — ขอ PO ระบุ`
   A question that concerns no AC/EC starts with `Business Rule:` (or the ticket section it comes from). Never a question without that label.
5. Questions go to the HTML gate under "ต้องถาม PO" (include / exclude per beyond-scope item). If any question is still open after sign-off, the skill asks whether to comment it in Jira (see "Question comment").
6. Beyond-scope items the user excluded are recorded in the Remark of the TC sheet: `AC_03 excluded: ask PO`. If the PO later says it is in scope, add the TCs via `/tc-pyr xxx update`.

## Qase Test plan
Always. As soon as the ticket's TCs exist in Qase, put them in a Test plan. One plan per ticket; never one plan for several tickets.

- **Title:** `PYR-xxx <ticket name>` — the ticket key, one space, the Jira summary exactly as written (e.g. `PYR-783 Register with email`). Always both parts. Never the key alone.
- **Description:** Jira link, one line. No secrets.
- **Cases:** every Qase case id of that ticket, in the final TC order (Happy Path → Failure Scenario → Edge Case → Exceptional Case). Nothing from other tickets.
- **API** (header `Token: $QASE_API_TOKEN`, project code `Pyrite`, base `https://api.qase.io/v1`):
  1. Find: `GET /plan/Pyrite?limit=100&offset=…` (page through). Match a plan whose title equals `PYR-xxx` or starts with `PYR-xxx ` (with the space, so PYR-78 never matches PYR-783).
  2. Missing → `POST /plan/Pyrite` with `{"title","description","cases":[ids]}`.
  3. Found → `PATCH /plan/Pyrite/{id}` with the same body (fixes the title if the ticket was renamed). `cases` replaces the whole list, so always send the full current list. Never create a second plan for the same key.
  4. Verify: `GET /plan/Pyrite/{id}`; case count must equal the ticket's TC count. Report plan id and link `https://app.qase.io/plan/Pyrite/{id}`.
- Any later add / remove / re-create of a case (`update`, `updateTCSheet`) re-syncs the plan in the same run.
- A Test plan is not a Test run. Do not start a run or set case results.

## TC format rules
- **Test Case ID:** `TC-01`, `TC-02`, … (prefix `TC-`, 2-digit padding; ask only if a ticket passes 99 TCs). Qase has no ID field (auto ids).
- **Test Case Type** (sheet column and Qase custom field id 4): `Happy Path`, `Failure Scenario`, `Edge Case`, `Exceptional Case` — never OLS Core/Edge.
  - Qase option ids: 1 Happy Path, 2 Failure Scenario, 3 Edge Case, 4 Exceptional Case.
  - Positive flow → Happy Path; rejected/invalid input or error → Failure Scenario; boundary/limit/unusual condition → Edge Case; unexpected state / system exception → Exceptional Case.
- **Ordering:** Happy Path → Failure Scenario → Edge Case → Exceptional Case; inside a type keep AC/EC order; renumber IDs 1..N after sorting. The Qase API cannot set case position, so reorder by overwriting existing case slots in place, not delete/recreate.
- **Test Data / Test Step / Expected Result:** equal item count, numbered 1, 2, 3 with no gaps, and **no `-` placeholder lines**. Merge or split steps so every step has its own data and expected result; if a count truly cannot match, flag it instead of padding.
- **Test Title:** start with "ตรวจสอบ". Describe what is being checked only; never put the expected result in the title.
- **Precondition and Test Data:** short sentences, one idea per line, no long explanations.
- **Writing style (every TC field):** natural Thai, semi-formal. No special symbols or unusual characters (no emoji, arrows, decorative bullets, odd quotes or brackets used as decoration). Plain numbers and normal punctuation only.
- **Wording source (create and review):** every button name and other UI text written in a TC (Title, Precondition, Test Data, Steps, Expected Result) is taken from the ticket only, exactly as the ticket writes it. The prototype supplies layout and flow only (which screens, in what order, which elements) and is never a wording source. If the ticket does not name a button or text, describe the action in the ticket's own words and add a `ticket ไม่ระบุชื่อปุ่ม …` line to "ต้องถาม PO" in the HTML gate; do not borrow the name.
- **Glossary:** English-term-first. Use the ticket's own wording (keep English where the ticket writes English: checkbox, badge, dropdown, permission, scope, role, account, login, tab, filter, status). Do not raise glossary-vs-ticket collisions as questions; still show the term table for information.
- **No Figma / PRD link in the ticket = absent.** Do not ask for them. Record "no Figma / no PRD" in the pre-draft review and Remark. The prototype (see "Ticket review") is still compared with the ticket.

## Thread webhook
The review thread is created and answered through a **webhook of the QA channel, which is a Forum channel**. A webhook can only post; it cannot read the channel, so the thread is tracked by a link saved on the ticket's row.
- **URL (secret):** `DISCORD_WEBHOOK_QA` from the environment, else from `~/.claude/channels/discord/.env`. Never print, log, quote or store it anywhere else (not in the Tracking sheet, Jira, Qase, repo or chat). Missing → say in one line `ยังไม่มี DISCORD_WEBHOOK_QA`, and give the thread title and message as ready-to-paste text.
- **Thread link column:** in the tab `Summary` of the Tracking sheet, the column whose header is `Discord Thread` holds the thread link of each ticket's row. No such column → ask once which column to use (propose the first empty column after the last header); never guess.
- **Thread link format:** `https://discord.com/channels/<guild_id>/<thread_id>`. `<guild_id>` from `GET <webhook url>` (field `guild_id`); `<thread_id>` is the `channel_id` of the `?wait=true` response. Check that both ids are present before saving.
- HTTP 404 → webhook deleted; 429 → wait `retry_after` and retry once. Say which in a line and stop at that step.

## Create sign-off
Runs only from `/tc-pyr xxx` (create), after the user's Approve and after Qase cases, Test plan, Drive sheet and tracking sheet were written. Values come from the `Config` tab of the Tracking sheet: `DISCORD_QA_CHANNEL`, and one entry per QA member: `MENTION_SAMORN`, `MENTION_NIPIT`, `MENTION_SUJAREE`. Each value is either a ready mention (`<@id>`) or the person's Discord **username**. A plain `@username` typed as text does not ping, so with a username, look the member up through the Discord MCP and use the real mention (`<@id>`) in the message. If the lookup fails or finds more than one match, ask once; never post a plain-text name as if it were a mention. A missing key → ask once, never guess. The thread itself is created through the **QA-channel webhook** (see "Thread webhook"). If a username cannot be resolved because the Discord MCP is not connected, ask once for the `<@id>`. If the webhook is missing or fails, do step 1, then give the thread title and body as ready-to-paste text and say Discord was not reachable. Never use another route.

1. **Jira field `TC Status` = `DONE`.** Atlassian MCP `editJiraIssue`, `fields: {"TC Status": {"value": "DONE"}}`. Set only this field: no status change, no comment. Read the card back once and confirm.
2. **Create a Discord thread in `DISCORD_QA_CHANNEL`** (a Forum post, through the webhook): `POST <DISCORD_WEBHOOK_QA>?wait=true`, `Content-Type: application/json`, body `{"thread_name": "<thread name>", "content": "<first message>", "allowed_mentions": {"users": ["<reviewer id>"]}}`. Then save the thread link (see "Thread webhook") in the `Discord Thread` column of the ticket's row, and show it in the report.
   - **Thread name** (the `thread_name` field): `PYR-xxx <Jira ticket name>` (the key, one space, the Jira summary exactly as in Jira; trim to Discord's 100-character limit only if it is longer).
   - **First message** (the `content` field):

```
<one mention> need review tc
TC: [Link](<Drive link of the ticket's TC sheet>)
```

   - **Reviewer: exactly one person, picked at random** from Samorn, Nipit and Sujaree, **excluding the person who created the TCs** (the person running this skill, identified from the Atlassian user and matched to one of the three; the creator is never tagged). Pick with real randomness (for example `python3 -c "import random,sys; print(random.choice(sys.argv[1:]))" A B`), not by choice. Tag one person only, never two. If the creator cannot be matched to one of the three, ask once who created them.
   - `Link` is the Drive link of the TC sheet inside the ticket's `PYR-xxx` Drive subfolder (the same link stored in the `TC` column of the Summary tab).
   - If the ticket's row already has a thread link in the `Discord Thread` column, do not create a second thread: say so, show the link and skip.
3. Show the thread name, the chosen reviewer and the exact body in the review gate before posting. Post nothing that was not shown and approved. The reviewer is picked when the gate is built, so the approved text is what gets posted. Never create two threads for one ticket in one run. A webhook cannot see the channel, so a thread created by hand is not known: the user tells you.

## Question comment
Runs only from `/tc-pyr xxx` (create), after the Create sign-off, and only if **open questions** for the PO remain. No open questions → skip silently. Uses `DISCORD_QUESTION_CHANNEL`, `POPYR_MENTIONS` (Discord) and `PO_JIRA_ACCOUNT` (Jira accountId or e-mail of the PO; an e-mail is resolved with `lookupJiraAccountId`) from the `Config` tab (missing → ask once, never guess). If the Discord MCP is not connected, post the Jira comment only if the user said yes, then give the Discord message as ready-to-paste text.

1. Show the exact comment text (below) and the Discord message, then ask once, in Thai: `comment ใน Jira ไหม? (ใช่ / ไม่)`. The answer covers both the Jira comment and the Discord post.
2. **ไม่** → post nothing. The questions stay in chat for the user to forward.
3. **ใช่** →
   - Post a Jira comment on `PYR-xxx` (Atlassian MCP `addOrEditJiraIssueComment`). The **PO is tagged** with a real Jira mention (accountId from `PO_JIRA_ACCOUNT`) on the first line, then **short bullets**, each starting with its AC/EC:
     ```
     <PO mention> คำถามสำหรับ PO (TC prep)
     • AC_03: <คำถามสั้นๆ ได้ใจความ>
     • EC_02: <คำถามสั้นๆ ได้ใจความ>
     ```
     Bullet rules: one line per question, one short sentence with only the ask (what is unclear, what the PO must decide). No quoted paragraphs, no background, no option lists. Only the PO is mentioned. No other text, no secrets.
   - Build the comment link from the result: `<Jira site>/browse/PYR-xxx?focusedCommentId=<comment id>`. Open check: the link must contain the new comment id.
   - Post in `DISCORD_QUESTION_CHANNEL`: `<POPYR_MENTIONS> มี comment <comment link>` (PO resolved to a real mention as in "Create sign-off").
4. Post once per run. If the Jira comment fails, do not post to Discord. Stop and say which step failed.

## Review sign-off
Runs only from `/tc-pyr xxx review`, after the user's Approve (and after the four-place update when there were fixes). Values come from the `Config` tab of the Tracking sheet: `DISCORD_QA_CHANNEL`. A missing key → ask once, never guess. The `Passed` reply (step 3) goes through the QA-channel webhook (see "Thread webhook"); There is no PO post in this sign-off. If the webhook is missing or fails, give the `Passed` text as ready-to-paste; steps 1 and 2 always run, and say so. Never use another route.

1. **Summary column F.** In the tab `Summary` of the Tracking sheet, find the row whose `Ticket No.` is `PYR-xxx` and set column F ("Review Test case by QA") to `QA-REVIEWED`. Change only that cell. Column G (PO/BA review) stays as it is.
2. **Jira field `TC Status`.** On the Jira card `PYR-xxx` set the select field **TC Status** to `QA-REVIEWED` (Atlassian MCP `editJiraIssue`, `fields: {"TC Status": {"value": "QA-REVIEWED"}}`; the field accepts TO DO, IN PROGRESS, BLOCKED, DONE, QA-REVIEWED, PO/BA-REVIEWED, NOT REQUIRED). Set only this field. Do not change the card's status, assignee or any other field, and do not post a Jira comment. Read the card back once and confirm the value.
3. **Reply `Passed` in the existing Discord thread.** Read the thread link from the `Discord Thread` column of the ticket's row in the `Summary` tab; `<thread_id>` is the number after the last `/`. Reply with exactly `Passed`: `POST <DISCORD_WEBHOOK_QA>?thread_id=<thread_id>&wait=true`, body `{"content": "Passed", "allowed_mentions": {"parse": []}}`. Check that the response holds a message `id`. If the cell is empty, do not create a thread: say so and give the text. If HTTP 404 (thread deleted, or the webhook is not of this channel), say so and give the text. An archived thread is reopened by the post; accept that.
4. Show the exact text of (3) in the sign-off gate before posting. Post nothing that was not shown and approved. Never post twice for the same ticket in one run.

## Review-TC overlay
Used by `/tc-pyr xxx review` (Helix `tc-review-workflow` with this overlay). Review the TCs of one ticket against **the prototype for layout and flow, and the ticket for all wording and rules**, plus the PYR format rules. The review itself writes nothing and posts no Jira comment. Fixable findings become a fix proposal; after the user's explicit Approve the fixes are applied to **all four places** (Qase TC → Test plan → Drive sheet → tracking sheet, the `update` flow). Findings that need the PO are never applied.

### Sources and precedence
1. **Prototype (primary for layout and flow).** Open it headless and log in as in "Ticket review". For which screens exist, their order, and which fields, buttons and states are present and where, the prototype wins over the ticket. It is a rough picture for developers.
2. **Ticket (the only source for wording, and for rules).** Every button name and every other UI text (labels, messages, headings) is judged against the ticket only. Prototype wording is never a reference: a TC that uses the ticket's wording is correct even if the prototype shows other words, and a TC that copies prototype wording the ticket does not state is a finding. Business rules, limits, permissions and server-side or data rules also come from the ticket.
3. **Figma / PRD**: review against them as usual if the ticket links them; absent = absent, never ask. Where they disagree with the prototype, list it as a mismatch, do not pick a winner.
4. Scope: a TC for an AC/EC that is listed in "ไม่อยู่ใน ticket นี้:" is a finding (cut it). A TC for a beyond-scope AC/EC without the user's include decision is a finding.

### What to check
For every TC, walk its Test Steps in the prototype and compare:
- **Steps doable**: each step can be done in the prototype in that order; the elements the step uses are present in the prototype (judge presence and place, not wording). Element names in the TC must match the ticket's wording.
- **Expected Result** matches what the prototype shows or does in state and navigation, and uses the ticket's wording for any text.
- **Test Data** is something the prototype accepts or rejects as the TC says.
- **Coverage**: every flow, field, state and message case in the prototype for this ticket has a TC; every in-scope AC/EC has a TC.
- **Format** (PYR rules above): ID `TC-01`, Type values and order, equal Test Data / Step / Expected counts, no `-`, English terms per ticket, Title starts with "ตรวจสอบ" with no expected result in it, short Precondition and Test Data, plain semi-formal wording with no special characters.
- **Plan**: the ticket's Qase Test plan exists once, is titled `PYR-xxx <ticket name>`, and holds exactly the ticket's cases; Qase cases, sheet and tracking row match.

### Findings
Classify each finding, one line each, with sources quoted:

| Class | Meaning | Fix |
|---|---|---|
| TC vs prototype | The TC contradicts or cannot be done in the prototype's layout or flow | Change the TC to follow the prototype |
| Wording | A TC button name or UI text differs from the ticket, or is copied from the prototype and not stated in the ticket | Change the TC to the ticket's wording; if the ticket is silent, ask the PO |
| Prototype vs ticket | Prototype and ticket disagree on layout, flow or presence of elements (never wording) | Not a TC defect. List for the PO. TC follows the prototype and Remark records the mismatch |
| Coverage gap | Prototype or AC/EC behavior has no TC | Add a TC |
| Not in prototype | TC covers something the prototype does not show | Keep only if the ticket states it as a rule the prototype cannot show; otherwise ask the PO |
| Cannot verify | The prototype cannot reach that state (e.g. server error) | Not a defect; say it was not checked against the prototype |
| Format / plan | Breaks a rule in "TC format rules" or the plan rules | Fix as the rule says |

**Source label on every question.** Every question to the PO or anyone else (class "Prototype vs ticket", "Not in prototype", "Wording" where the ticket is silent, open scope items, anything else needing an answer) starts with the label of the ticket item it comes from: `AC_03:`, `EC_02:` or `Business Rule:` (name the rule, e.g. `Business Rule: จำกัด 5 ครั้ง`). The label goes first, then the short question; the same text is used in the chat report and the HTML sign-off gate. If the question comes from several items, list each label. If it comes from none of them (e.g. prototype only), write `Prototype:` and name the screen. Never post an unlabelled question.

Each finding: TC ID, the quoted TC text, `prototype shows` (screen and element) for layout and flow findings, and the ticket quote for every wording finding. Report **Good** vs **Need Improve** as the Helix workflow does, with counts per class; keep it short. Never rewrite a TC silently to make it pass; every change goes through the Approve gate.
