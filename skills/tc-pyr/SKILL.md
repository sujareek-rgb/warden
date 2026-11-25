---
name: tc-pyr
description: Prepare test cases for a Pyrite ticket — `/tc-pyr 783` means PYR-783. Writes the TCs from the ticket's AC/EC, creates them in Qase project Pyrite, builds the Qase Test plan "PYR-xxx + ticket name", shows an HTML draft for approval first, then fills the Drive TC sheet and the tracking sheet. Also `/tc-pyr 783 update` (updateTCSheet) and `/tc-pyr 783 run` (manual execution). Use when the user types /tc-pyr, gives a PYR-xxx ticket and wants TCs, says "เขียน TC PYR-xxx" or "updateTCSheet". Do NOT use for OLS tickets (tc-ols), plain TC review (Helix tc-review), filing bugs, retest or test data.
argument-hint: "<number> [update | run]   e.g. 783"
metadata:
  proactive_triggers:
    - /tc-pyr
    - เขียน TC PYR
    - updateTCSheet
    - write test cases PYR
---

# /tc-pyr — TC prep for one Pyrite ticket

`/tc-pyr 783` = prepare the test cases of **PYR-783**. Pyrite only. OLS has its own skill, `tc-ols`.

**Session start:** follow Helix `references/session-start-context.md` (installed with Helix).

## Step 1 — Read the command

| Input | Meaning |
|---|---|
| `/tc-pyr 783` | Ticket `PYR-783`, job **create** |
| `/tc-pyr 783 update` or `updateTCSheet` | Job **update**: apply changed TCs everywhere |
| `/tc-pyr 783 run` | Job **run**: manual execution, [references/execute.md](references/execute.md) |
| `/tc-pyr 783 review` | Job **review**: Helix `tc-review-workflow` + the profile's "Review-TC overlay": TCs checked against the **prototype for layout and flow**, and the **ticket for all wording**, plus PYR format rules |
| `/tc-pyr PYR-783` | Same as `783` |
| Number missing | Ask one line: `PYR-?` |
| Another project's key (OLS-xxx …) | Refuse in one line, route to `tc-ols` |

Read [references/pyr.md](references/pyr.md). Its rules override the generic Helix defaults wherever they differ.

## Step 2 — Create (default job)

1. Announce one line: `Using **tc-pyr** → PYR-783 · create.`
2. Fetch the ticket from Jira (summary = the **ticket name**, AC/EC, Jira link). Run the profile's "Ticket review": compare the ticket with the prototype (and Figma / PRD only if linked; absent = absent). Also run the profile's **Scope check**: AC/EC listed in the ticket's "ไม่อยู่ใน ticket นี้:" section are cut (no TC, no question); AC/EC beyond the ticket scope become questions for the PO, every question starting with its AC/EC. Keep both lists for the HTML gate.
3. Reuse check (profile "Reuse rule"): existing Drive subfolder + sheet, Qase cases / suite, Qase Test plan for this key. Update in place; never duplicate.
4. Delegate TC writing to Helix `tc-fe-prep-workflow` (UI story) or `tc-api-prep-workflow` (API / Swagger) and follow it completely, with the profile as overlay. **Wording:** every button name and UI text in the TCs comes from the ticket only; the prototype informs layout and flow (step order, which elements exist), never wording. A button or text the ticket does not name is not borrowed from the prototype: write the action in the ticket's words and put a `ticket ไม่ระบุชื่อปุ่ม …` bullet in the gate's **ต้องถาม PO** section.
5. **Review gate (HTML).** Write the drafted TCs to a local file `PYR-783-tc-draft.html` (scratchpad, not published) and open it for the user. Show: ticket key + name, TC count per Type, every TC in final order with ID, Title, Type, Precondition, Test Data, Steps, Expected Result, and the a section **ต้องถาม PO** (the scope-check bullets, each with include / exclude for the user to pick; flagged items get no TC until included), ticket-vs-prototype mismatches (`ticket says` vs `prototype shows`), the sign-off actions (Jira `TC Status` = `DONE`, the Discord thread name, the randomly picked reviewer and the exact first message), and the planned targets (Qase suite, the Jira web links (file name + URL), Test plan title `PYR-783 <ticket name>`, Drive folder, tracking row). Then ask once: `Approve / แก้ไข?`
   - **Approve** → go to step 6. Nothing was written to Qase, Drive or the tracking sheet before this point.
   - **แก้ไข** → apply the user's changes to the draft, regenerate the HTML, ask again. Loop until approved.
   - No approval = no write. Silence or a question is not approval.
6. Create the TCs in Qase project Pyrite.
7. **Create / update the Qase Test plan** named `PYR-783 <ticket name>` with exactly these cases (profile "Qase Test plan"). Always, not on request. Verify the case count.
8. Create the Drive subfolder + TC sheet, formatted per the profile "Drive TC sheet format" (Calibri 10, wrap, set column widths); update the tracking sheet row.
9. **Jira web link** (profile "Jira web link"): add every TC file of the ticket to the Jira card as a Web link, link text = the file name exactly; skip a URL that is already linked.
10. **Create sign-off** (profile "Create sign-off"): Jira `TC Status` = `DONE`; then create the Discord thread `PYR-783 <Jira name>` in the QA channel (Forum post through the webhook, link saved on the ticket's Summary row), first message = one randomly picked reviewer (Samorn / Nipit / Sujaree, never the creator) + `need review tc` + `TC: Link` to the Drive TC sheet. Stop at the first failure and say which step failed.
10. **Question comment** (profile "Question comment"): only if open PO questions remain, ask `comment ใน Jira ไหม? (ใช่ / ไม่)`. ใช่ → Jira comment that tags the PO and lists the questions as short bullets (each starting with its AC/EC), then post `<PO> มี comment <Jira comment link>` in the question channel on Discord. ไม่ → post nothing.
11. Stop at the definition of done. No CSV attach.

## Step 2b — Review

`/tc-pyr 783 review`:

1. Announce one line: `Using **tc-pyr** → PYR-783 · review.`
2. Load the ticket's TCs (Qase suite / Drive sheet) and the ticket (AC/EC, business rules, "ไม่อยู่ใน ticket นี้:").
3. Open the prototype headless (profile "Targets") and walk every TC's steps in it.
4. Run Helix `tc-review-workflow` with the profile's "Review-TC overlay": **prototype for layout and flow, ticket for all wording (button names and UI text) and rules**; classify findings as the overlay says.
5. Report Good vs Need Improve in chat, short, findings quoted; every question to PO or others carries its AC/EC / Business Rule label. Nothing is written yet.
6. **Sign-off gate (always after the review).** One HTML review gate, one question. It shows:
   - the **fix proposal**, only if some finding is fixable by changing TCs: improved TCs per the findings (TC vs prototype, wording, coverage gap, format / plan; "Not in prototype" only when the user decided), changed / added / removed rows marked with their finding. Findings that need the PO (prototype vs ticket, open "not in prototype", "ต้องถาม PO") are listed, not changed. **Every question starts with its source label** (`AC_xx:`, `EC_xx:` or `Business Rule: <name>`; profile "Findings"), in the chat report and the gate.
   - the **sign-off actions** with the Summary column F, the Jira `TC Status`, and the exact text that will be posted (profile "Review sign-off"): the Discord reply `Passed`.
   Ask once: `Approve / แก้ไข?`
   - **Approve** → in this order, stopping at the first failure and saying which step failed: (a) if there are fixes, Step 3 for all four places; (b) Summary column F = `QA-REVIEWED`; (c) Jira card field `TC Status` = `QA-REVIEWED`; (d) reply `Passed` in the ticket's existing Discord thread. Do not ask again.
   - **แก้ไข** → change the draft, regenerate the HTML, ask again.
   - No approval = no write and no post.
7. Report in a few lines: what was updated (four places if fixes), column F, Jira `TC Status`, the Discord `Passed` reply (link), open PO questions.

## Step 3 — Update (full sync, always all four)

`/tc-pyr 783 update` updates **everything**. First show the changed TCs in the same HTML review gate (changed / added / removed rows marked) and wait for **Approve** (when coming from `review`, that Approve already given in step 6 counts; do not ask twice). Then, in this order, no skipping:

1. **Qase TCs** — change / add / remove cases in place (same ids; reorder by overwriting slots, never delete + recreate).
2. **Qase Test plan** `PYR-783 <ticket name>` — re-sync cases and title; verify count.
3. **Drive TC sheet** — same rows, IDs renumbered `TC-01…` after sorting; re-apply the profile "Drive TC sheet format" (font, wrap, widths, row heights).
4. **Tracking sheet** — update the ticket's row (TC count, links, status).

Finish with one report line per step. If one step fails, say which, and do not report done. Qase, plan, sheet and tracking row must end identical.

## Rules

- MUST start every question to the PO or anyone else with its source label: `AC_xx:`, `EC_xx:` or `Business Rule: <name>` (several sources: list each; none, e.g. prototype only: `Prototype: <screen>`). Same text in chat, gate and any post. Never ask an unlabelled question.
- MUST take the ticket key from the command. Never guess it.
- MUST take every button name and UI text from the ticket only. The prototype is a rough picture for developers (layout and flow); never copy its wording.
- MUST show the HTML review gate and get explicit Approve before the first write to Qase, Drive or the tracking sheet (create, update and review fixes).
- MUST create or update the Test plan after every create / update, titled `PYR-xxx <ticket name>`.
- MUST keep Qase cases, Test plan, Drive sheet and any other artifact of one ticket identical.
- MUST NOT write secrets (Qase token, prototype password, other passwords) into sheet, Qase, Jira, repo or chat. Token comes from `QASE_API_TOKEN`.
- MUST NOT invent a rule that is not in the profile. If the profile is silent on something that changes the output, ask once and propose the answer for the team to add to the profile.
- Automation (Playwright) is not part of this flow: do not offer to write or run it unless asked.
- Discord, the Summary column F and the Jira `TC Status` are touched only by the create sign-off (create step 10) and the review sign-off (review step 6), each after Approve. No other step posts to Discord.
- Plain `/tc-review` (Helix) knows neither the PYR rules nor the prototype. To review against them, use `/tc-pyr 783 review`. Review itself writes nothing; changes happen only after the Approve in review step 6.

## Communication (shortest possible)

- **Language:** explain, ask and answer in Thai, always (questions, options, reports, confirmations). Code, commands, paths, error text and ticket terms stay exact. Text that a skill posts or writes (TC content, Jira comment, Discord messages, Qase results) follows the format and language that skill defines, not this rule.
- One question per turn, one line, options inline. No preamble.
- Never ask for what the profile, ticket or an earlier answer already gives.
- Report results in a few lines: counts, links (Qase suite, Test plan, sheet), open issues. No recap, no offers of follow-up work.
- Tables only when the user must decide something. The brevity rule applies to chat, not to TC content.

## Refusal-first

| Request | Do |
|---|---|
| OLS key or no key | Refuse, one line: `tc-ols` for OLS, ask for the number otherwise. |
| Review TCs without the PYR rules | Use Helix `tc-review`; for PYR rules use `/tc-pyr 783 review`. |
| Post a Jira comment | Refuse, except the question comment the user approved with ใช่ in create (profile "Question comment"). Any other Jira comment only if the user explicitly asks. |
| File bug, retest, test data | Route to `create-bug-workflow`, `retest-bug-workflow`, `test-data-prep-workflow`. |

## QA closing (mandatory before "done")

Follow Helix `references/qa-closing-shared.md`, plus:

- [ ] Ticket key came from the command; profile read; ticket compared with the prototype (layout / flow), mismatches shown in the gate; all wording taken from the ticket.
- [ ] Scope check done; AC/EC listed under "ไม่อยู่ใน ticket นี้:" cut without questions; beyond-scope AC/EC have no TC unless included; every question starts with its AC/EC.
- [ ] Jira comment and Discord post only if the user answered ใช่, with the comment link in the Discord message.
- [ ] HTML draft shown and explicitly approved before any write.
- [ ] Output follows the profile (Type values, ID format, wording, ordering).
- [ ] Test plan exists once, titled `PYR-xxx <ticket name>`, holds exactly the ticket's cases, count verified.
- [ ] Qase cases, Test plan, sheet and tracking row match each other.
- [ ] Review: sign-off posts matched the approved text; column F and Jira `TC Status` set to `QA-REVIEWED`; nothing else posted.
- [ ] Create: every TC file is a Jira Web link titled with its file name, none duplicated; Jira `TC Status` = `DONE`; one Discord thread named `PYR-xxx <Jira name>` with one reviewer who is not the creator.
- [ ] Nothing posted outside the definition of done (and the sign-offs); no secret written anywhere.
