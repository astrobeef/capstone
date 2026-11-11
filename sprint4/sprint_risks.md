# Sprint 4 risk register

**Project:** Educational Theory of Computation Puzzle Game (Godot)
**Sprint:** Sprint 4
**Last updated:** November 10, 2026

Likelihood and impact are Low, Medium, or High. The monitoring contact is the person who should notice if it happens. The trigger is when it comes back to the team, usually at standup.

| ID | Risk | Likelihood | Impact | Monitoring contact | Mitigation | Trigger |
|---|---|---|---|---|---|---|
| S4-R1 | The four-state puzzles (Even 0s and even 1s, Contains 101) crowd the diagram or the transition table on a 1280×720 window. The diagram only had A–C routes until the D routes were added, and those curves are copied from the C ones. | Medium | High | Ryan | Keep the table tall enough for four state rows, and keep state D on screen. Check both puzzles in `sprint3/dfa_puzzle.tscn` at 1280×720 and 1920×1080. | A state label or dropdown sits outside the window, or a D arrow is missing or unreadable. Bring it to the next standup before a playtest. |
| S4-R2 | Edited transitions live on the table object in `PuzzleProgression.working_tables`. Previous, Next, and Return reuse that object. Replacing it, or calling `create_user_table()` on a visit, throws away the edit. Completion is the `completed` flags, separate from the result text, which clears when the panel is configured again. | Medium | High | Ryan | `select_puzzle` keeps the existing working table. The sprint 4 check edits a puzzle, leaves, and comes back. | A revisited puzzle shows the starting destinations, or Next locks again after a puzzle was already solved. Stop and talk it through at standup that day. |
| S4-R3 | Puzzle resources drift from `difficulty_tiers.md`. Advanced is four or more states and at least ten requirements after Brian's Nov 5 note. An old three-state "advanced" puzzle would not match the tier. | Medium | High | Ryan | `solutions.md` lists the file, the solution cells, and the Accept/Reject rows. The check loads each resource and runs `Eval` on the start and the solution. | The check fails, or a resource's state count does not match its tier. Leave it out of `PuzzleProgression` until the next standup. |
| S4-R4 | Navigation and the selection screen already exist on this scene. A second navigation scene or a second place that stores the working tables would get out of date. | Medium | Medium | Ryan | Use `sprint4/puzzle_navigation.tscn`, `puzzle_progression.gd`, and `puzzle_selection.tscn`. Return calls `_show_selection` and does not change scene. | A new scene starts handling Previous, Next, or Return on its own. Discuss it before merging that scene. |
| S4-R5 | The layout check has only been run headless on one machine. A laptop scale or a shorter window can still clip the nav row (it sits near y=700). | High | Medium | Laney | Ryan records the local UI-T1 / UI-T4 result. Laney runs the same scene at 1280×720 and 1920×1080 and adds what she saw. | A playtest is on the calendar and Laney's row is still empty. Put it on that day's standup. |
| S4-R6 | The feedback form and `session_notes.md` ask about the same session. If the buttons change, the form still says Check, Restore, Previous, Next, and Return to puzzles. | Medium | Medium | Ryan | The form uses those labels and a participant code, which is the code on the observation notes. Read it against the session notes before the first session. | A button label changes after the form is handed out. Re-read both with the team before the next session. |

## Review

- RK-T1: each row has likelihood, impact, a monitoring contact, a mitigation, and a trigger.
- RK-T2: S4-R1, S4-R2, and S4-R3 are high impact. Each trigger says when the team should talk about it.
- Team review (Laney facilitating): not held yet.
- Date:
- Notes:
