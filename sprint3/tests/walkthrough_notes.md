# L3 teammate walkthrough notes (L-T5)

This is a teammate usability check, not external target-user testing.

- Date: 10/26/2026
- Tester: Ryan
- Observer: Laney
- Build: sprint3/dfa_puzzle.tscn on main at commit: df6831350c7acf4f4fa5e0f252b383e556550348
- Screen size / machine: 1280×720, Windows 11

Setup: Ryan gets no step-by-step help. He uses only the on-screen instructions. Laney does not explain anything unless he is completely stuck, and then notes exactly what she said.

## The five actions

| # | Action | Did Ryan do it without help? (Y/N) | Time / hesitation | What he said or did | Help given (exact words) |
|---|---|---|---|---|---|
| 1 | Identify the editable controls (the dropdowns in the table) | Y | None | Found the table at the bottom right. Rows A, B, and C and columns 0 and 1, each cell a dropdown of A/B/C. Starting values were A→0 A, A→1 B, B→0 A, B→1 A, C→0 A, C→1 C. | None |
| 2 | Check the solution (Check Solution button) | Y | None | Pressed Check Solution on the starting table. | None |
| 3 | Interpret the results (Pass/Fail lines and the summary) | Y | None | Read seven lines of expected / actual / Pass or Fail, then the summary "Requirements not yet met". The three "must Accept" strings failed. The four "must Reject" strings passed. | None |
| 4 | Revise (change dropdowns, then check again) | Y | None | Changed B on 1 from A to C. The old Pass/Fail lines and the summary cleared immediately. Changed C on 0 from A to C, then pressed Check Solution again. | None |
| 5 | Restore (Restore Puzzle returns starting values) | Y | None | Pressed Restore Puzzle. Dropdowns returned to the starting values and the results cleared. Checked again and got the same failures as the first check. | None |

## Interpretation checks

- Did Ryan understand that a requirement marked "must Reject" with actual Reject counts as a Pass? (Y/N, his words): Y. The line reads `(empty): expected Reject, actual Reject - Pass` (same pattern for "1", "101", and "0101").
- Did he understand what "Requirements not yet met" means? (Y/N): Y. It is the summary while any requirement line says Fail. After the corrected table it changed to "Puzzle solved".
- Did he notice that editing a dropdown clears the old results? (Y/N): Y. The result lines and summary disappeared as soon as B on 1 changed, before the next check.
- Did he solve the puzzle? (Y/N) How many Checks did it take? Y. 2 checks. The first check failed. The second check, after B on 1 → C and C on 0 → C, passed all seven lines and showed "Puzzle solved".

## Blocking confusion (anything that stopped him)

| Issue | Where | Proposed wording / fix | Sent to Ryan (date) | Fixed? | Rechecked result |
|---|---|---|---|---|---|
| None | | | | | |

## Summary

- Total assistance required: None
- Blocking issues found: None
- Blocking issues fixed and rechecked: None
- Notes: On-screen instructions were enough for all five actions. Title "Find the Double 1", the requirement list, both buttons, and the result lines were readable at 1280×720. A reject that matches "must Reject" is labeled Pass, and the summary distinguishes "Requirements not yet met" from "Puzzle solved".
