---
name: taskfolio-log
description: Fill the Taskfolio timesheet of the QA running it for this week from evidence of what they actually did each day (Jira changes, Slack, Calendar). Reads the week page, proposes one table per day, and saves only after the user confirms. Never submits the week. Use when the user types /taskfolio-log or says ลง taskfolio, ลง timesheet, ลงเวลางาน, fill taskfolio. Do NOT use for leave requests, for other people's timesheets, or for clicking Submit week.
argument-hint: "[this week | day range]   default: this week up to today"
metadata:
  proactive_triggers:
    - /taskfolio-log
    - ลง taskfolio
    - ลง timesheet
    - ลงเวลางาน
---

# /taskfolio-log — fill the Taskfolio week

Reply in the user's language (Thai). Write to Taskfolio **only after the user confirms the table**. **Never click Submit week.** Never fill a day from memory: if an evidence source fails, say so instead of treating it as "no work".

## Settings (Tracking sheet `Config` tab, same place as the other warden skills)

Team-private values stay out of this public repo. Keys: `TASKFOLIO_URL` (URL of the Taskfolio week page; its host is also the URL fragment `tf.sh` uses to find the Chrome tab), `WORK_START` and `WORK_END` (the working day, e.g. `09:30` and `18:30`), `LUNCH` (e.g. `12:00-13:00`), `WEEK_HOURS` (e.g. `40`). Missing key → ask once.

Helpers (`scripts/`):
- `vpn_check.sh` → `VPN_ON` / `VPN_OFF`.
- `tf.sh <file.js> [url-fragment]` → runs JS in the Taskfolio Chrome tab. Write the JS file to the scratchpad; escape Thai as `\uXXXX`. `execute` does not await promises: act in one call, read in the next.
- `tf-lib.sh` → `do_edit`, `do_add`, `del_entry`: fill one entry, read it back, compare with the confirmed row, save only on a match. UI recipe and gotchas: `references/apply.md`.

Prerequisite (once per machine): Chrome *View → Developer → Allow JavaScript from Apple Events* must be on.

## 1. Prepare

1. Run `vpn_check.sh`. `VPN_ON` → stop and ask the user to turn the VPN off (Taskfolio only works with it off). Do not continue.
2. The Taskfolio tab must be open and signed in, else ask the user to open it.
3. Click **This week**, then **Refresh from Calendar**, and read the page again. If it says "Could not read Google Calendar", read Calendar with the connector instead and plan the missing meetings as `+ Add`.

## 2. Read the week

From `document.body.innerText`, per day column (MON … FRI with date): drafts and saved entries.
- Jira draft: key + title.
- Meeting draft: `Meeting · <subcategory>`, title, `HH:MM–HH:MM · duration`.

Only days up to **today** (Asia/Bangkok). Future days stay untouched. Take today's date from `TZ=Asia/Bangkok date`.

## 3. Evidence per day

For each day, collect what the user did. All sources are read-only.

**Jira** (Atlassian connector; `atlassianUserInfo` for the user's account id). Candidates:
```
("QA Owner[People]" = currentUser() OR reporter = currentUser() OR commenter = currentUser()) AND updated >= "<day>" AND updated < "<next day>" ORDER BY updated DESC
```
For each candidate read the changelog and comments (`getJiraIssue` with `expand=changelog`, fields `summary,comment`; large results are saved to a file, so filter with `jq` or python). Keep only the **user's own** actions inside the day (Asia/Bangkok), each with its time: `TC Status` change (DONE = TC written, QA-REVIEWED = TC reviewed), `Test Result Approval by QA` change, workflow status move, a comment (what it is in ≤ 12 words), bugs they created (`reporter = currentUser() AND issuetype = Bug AND created >= … AND created < …`). A card whose only change came from someone else is not evidence.

**Slack** (Slack connector, user id from the tool description): `from:<@ME> on:<YYYY-MM-DD>`. Read a thread only when the hit alone does not say what it is about.

**Calendar** (Calendar connector, primary calendar): events with start/end. Skip events the user declined. Mark events they never answered `(ยังไม่ตอบรับ)`.

## 4. Propose (show, do not save)

Show one table per day:

| Entry | Action | Subcategory | Time | Evidence |
|---|---|---|---|---|

with a day total, then wait for the user's changes or "ยืนยัน". Rules:

- **Working day:** `WORK_START`–`WORK_END` with the lunch break = 8 h. Log slots continuously from `WORK_START` to `WORK_END`; evidenced work beyond `WORK_END` is overtime after it. 8 h is a minimum, not a cap: never cut evidenced work to fit 8 h.
- **Lunch:** morning slots end by the lunch start, afternoon slots start at its end. Put an entry inside lunch only when there is real evidence of work then.
- **Lunch deduction:** Taskfolio takes 1 h off any entry whose Start–End overlaps the lunch (10:00–12:30 logs 1 h 30 m). For a meeting running into lunch, show the options with totals — (a) end at the lunch start and note the real end in Description, (b) keep the span and accept the deducted value, (c) raise Logged time by hand — and wait for the pick. Never save a guess.
- **15-minute steps:** Start and End are selectable only in 15 m steps (a meeting starting 11:40 → 11:45, real time in Description).
- **Meetings:** keep with Calendar time; remove a draft whose meeting is declined or not on the Calendar. Attended meetings count even if the invite was never answered; ask when unsure. Whether to log recurring ceremonies (daily stand-up etc.) varies by team and week: ask when unsure, never assume.
- **Jira drafts:** keep a card only if that day has evidence for it. Otherwise propose **Delete** and say "ไม่พบหลักฐานวันนี้".
- **Hours:** working hours minus meetings, split across kept cards by amount of evidence, 15 m steps. A bug the user opened that day gets its own time (reproduce, write steps/evidence), more than a status move.
- **Same card on several days:** each day's entry must show a different event (TC written → TC reviewed → test started → blocked → done). Put the event in Description. No new event that day → no entry.
- **Evidence with no draft** (a card not in the list) → **+ Add**. Work with no Jira card (test-data prep, tooling, internal tasks) → **+ Add** with the Jira field empty and the work named in Description.
- **Every entry needs a Project, always** — meetings and no-card work too, never "No project". Derive it from the key or title (`PYR-*`, NCBS, Pyrite → PYRITE; `OLS-*`, OLS work → OLS; any other project key → that project). If it cannot be derived, ask before saving.
- **Subcategory** (category Testing): TC written → Test case design; TC reviewed → Review test case; test run or retest result → Test execution; reviewing a bug or a test result → Review test result; data setup → Prepare test data; smoke / regression → the matching name. Unsure → ask.
- **Support work** (customer or dev help in Slack/Discord, release deployment) → category Support & Operations.
- Show every open question next to the table (unanswered invite, unclear project, lunch options). Do not save a row whose question is unanswered; save the rest and ask again afterwards.

## 5. Apply (after the user confirms)

Source `scripts/tf-lib.sh` and save one entry at a time (`references/apply.md` has the dialog fields and the gotchas). After each batch of `+ Add`, **reload the page and check for duplicates** before going on: delete a second identical copy through its dialog, never re-submit because an entry "looks missing".

Then read the page again: each day's `WORKED` must equal the confirmed total. Report any mismatch; do not retry blindly.

## Output

Short Thai summary: per day saved / deleted / total, week total vs `WEEK_HOURS`, and anything left for the user (open questions, "กด Submit week เองเมื่อพร้อม").
