# Risk Log

**Project:** Educational Theory of Computation Puzzle Game (Godot)
**Sprint:** Sprint 2 (Sep 25 to Oct 9, 2026)
**Last updated:** Oct 14, 2026
**Related board items:** Sprint 2 Risks and Mitigation Checks (Technical Risk Review, UI Risk Review)

## How to read this log

- **Likelihood** and **Impact** are rated Low, Medium, or High.
- **Rating** is the combined priority. High means High and High, High and Medium, or Medium and High. Medium means Medium and Medium, or High and Low. Low means anything else.
- **Status** is Open (needs action) or Mitigated (action taken, still watching).

## Technical risks

| ID | Risk | Likelihood | Impact | Rating | Mitigation | Owner | Status |
|----|------|-----------|--------|--------|------------|-------|--------|
| T1 | State visuals drift from the transition table. States are built from the table, so a start or accepting flag set in two places could disagree. | Medium | High | High | The table is the single source of truth. Automata2D sets each state's start and accepting flags from the table when it builds states. | Brian | Mitigated |
| T2 | Breaking change from removing the condition enum and signal in State2D. Any code still using them would fail. | Medium | Medium | Medium | Searched the project for remaining uses before merging and ran the test scene and Automata2D scene to confirm they load. Keep new code on the is_start and is_accepting properties. | Laney | Mitigated |
| T3 | Demo DFA is too simple. It accepts every input, so it never exercises rejection paths and could hide bugs in acceptance checking. | High | Medium | High | Add a second demo table with rejecting inputs and a matching expected results table. | Laney | Open |
| T4 | No automated tests. Checks are manual, by running scenes in the editor. | High | Medium | High | Keep test scenes (state display, input panel) in the repo, and add a small headless check script that loads scenes and asserts expected results. | Brian | Open |
| T5 | Merge conflicts in shared Godot scene files. Scene files are text but merge poorly when two people edit the same one. | Medium | Medium | Medium | Pull main before branching, keep branches short, give each scene one owner at a time, and review pull requests quickly. | Brian | Mitigated |

## UI risks

| ID | Risk | Likelihood | Impact | Rating | Mitigation | Owner | Status |
|----|------|-----------|--------|--------|------------|-------|--------|
| U1 | The simplified state visual removed hover tooltips and the start arrow, so new players get less explanation of what start and accepting mean. | Medium | Medium | Medium | Keep the labels clear, and add back an explanation (tooltip or help text) in a later sprint. | Laney | Open |
| U2 | The input panel is not yet connected to the demo, so the demo cannot be driven by a user. | Medium | High | High | Connect the panel's input and reset signals to Automata2D and show status after each step. | Ryan | Open |

## Process risks

| ID | Risk | Likelihood | Impact | Rating | Mitigation | Owner | Status |
|----|------|-----------|--------|--------|------------|-------|--------|
| P1 | Board status drifts from reality. After the board was remade, some demo tasks overlap finished ones, and a story can show as New when its tasks are closed. | High | Low | Medium | Review the board at each standup, close or merge duplicates, and update story status when tasks finish. | Laney | Open |
| P2 | Missed standup posts. A missing post earns a zero for that assignment. | Low | Medium | Low | Post the three answers on the discussion board before each meeting, and set a reminder. | Ryan, Laney, Brian | Mitigated |

## Sprint 2 summary

- **Mitigated this sprint:** T1, T2, T5, P2.
- **Carried into Sprint 3:** T3, T4, U1, U2, P1.

## Changes to the backlog suggested by this log

- Add a task for a second demo DFA with rejecting inputs and expected results (T3).
- Add a task for a headless check script that runs the test scenes (T4).
- Add a task to bring back start and accepting explanations for players (U1).
- Add a task to connect the input panel to the demo (U2).
- Add a task to clean up duplicate demo tasks and stale story status (P1).
