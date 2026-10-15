# Core Logic/Mechanics

Provide the DFA data and execution behavior that make transition-editing puzzles work. The player selects destinations for preset state/input pairs, and the machine evaluates complete strings against those choices. Puzzle correctness depends on satisfying the prescribed outcomes, not matching one particular transition arrangement.

Sprint 3 commits to one puzzle with two or three states and inputs `0` and `1`. States, inputs, start state, and accepting states are fixed. Defer graphical arrows, dragging, state editing, animation, progression, saving player progress, and general DFA validation.

Implementation and testing finish October 23, 2026. October 24–25 are reserved for documentation. Effort throughout this backlog is estimated person-hours, including learning and verification.

## Edit and Evaluate a Preset DFA

Owner: Brian

Priority: High

Effort: 8

As a player, I want my transition choices to determine the results of prescribed strings so that I can revise my machine until every puzzle requirement is satisfied.

Acceptance Criteria:

- The integrated scene runs on two team computers with zero debugger errors during the tests below.
- Every state/input pair has one destination dropdown containing only existing states, including itself. Initial selections match the initial table.
- A selection changes exactly one transition used by execution. All preset state and input properties remain fixed.
- Each string is evaluated independently from the start state, with acceptance determined after consuming the entire string.
- A requirement passes when actual acceptance matches expected acceptance. Expected rejection with actual rejection is a pass. The puzzle is solved only when all prescribed requirements pass; unspecified strings impose no constraints.
- Editing clears previous results. Restore Puzzle restores every initial destination and clears results without removing requirements.
- Player edits never modify the authored puzzle or initial table resources.

Test Scenarios:

| ID | Scenario | Acceptance criteria |
|---|---|---|
| B-T1 | Launch the same build on Brian's and Laney's computers and inspect the table. | Zero debugger errors; one dropdown per cell; options and initial selections match the resource. |
| B-T2 | Change a cell used by a known input path, then select a self-transition. | Exactly the selected destination changes; execution follows it. No UI permits changing states, inputs, start state, or accepting states. |
| B-T3 | Evaluate all strings twice, then reverse their order in a test fixture. | Each string returns the same result in all runs and matches its manual full-string trace. |
| B-T4 | Check the documented solution and an incorrect configuration. | The solution passes every requirement. The incorrect configuration fails at least one. Successful rejection is counted as a pass. |
| B-T5 | Check, edit, restore, and compare the authored data with its original values. | Editing clears results; restore resets all selections and clears results; requirements remain; authored data is unchanged. |

Risks and Mitigation:

| Risk | Likelihood | Impact | Owner | Action and monitoring |
|---|---|---|---|---|
| Mixed old/new state code prevents launch. | High | High | Brian | Repair through B1 and verify the baseline before integration. Record unresolved launch blockers immediately. |
| Shared resources let player edits alter the puzzle definition. | Medium | High | Brian | Create independent runtime table and row data in B3; verify isolation and restoration in B-T5. |
| Interface mismatches or late handoffs stall integration. | Medium | High | Brian | Publish the B3 schema/sample in the first work session; integrate rough components by October 20 using the interfaces below. Assign blockers an owner and next action. |

### B1: Restore the DFA Baseline and Fixed State Settings

Owner: Brian

Effort: 1.5

Description:

Repair `automata_2d.gd`, `state_2d.gd`, and `state_2d.tscn`. Remove obsolete condition-enum and missing-member references, correct the unresolved scene resource reference, and use `label_name`, `is_start`, and `is_accepting`. Disable controls and help text for changing start or accepting states. Retain fixed state positions and simple existing rendering.

Dependencies: None.

Completion Criteria:

- Automata loads with no script or scene-loading errors.
- Names and indicators match the table, including a state that is both start and accepting.
- Known valid strings can be stepped through.
- Fixed state properties cannot be changed through player controls.

Verification: Record the build, sample trace, and debugger outcome for B-T1/B-T2.

### B2: Implement Destination Dropdowns

Owner: Brian

Effort: 2

Description:

In `transition_table_gui.gd`, replace generated transition LineEdit controls with OptionButton controls. Keep state/input headers as Labels. Populate options from existing state names and select each configured destination.

Retain `table: TTableRes` and `rebuild_table()`. Emit `transition_requested(state_index: int, input_index: int, destination: String)` on player selection. The B4 controller updates the runtime data; the editor only reports the request.

Dependencies: Existing table resources; independent of Ryan's panel.

Completion Criteria:

- Every cell has a correctly initialized dropdown, with self-transitions available.
- Each player selection emits exactly one request with the correct indices and destination.
- Creating or rebuilding controls emits zero player-change requests.

Verification: Exercise every cell and rebuild once; record emitted arguments/counts for B-T1/B-T2.

### B3: Define Puzzle Data and Evaluate Requirements

Owner: Brian

Effort: 2

Description:

Create `sprint3/puzzle_resource.gd`, with `class_name PuzzleRes` and exported properties:

- `title: String`
- `initial_table: TTableRes`
- `test_inputs: Array[String]`
- `expected_acceptance: Array[bool]`

Matching array indices describe one requirement; `true` means accept the complete string and `false` means reject it. Supply Laney the schema and a sample during the first work session.

Reuse existing stepping logic. Start each string from the start state and return actual acceptance values in requirement order. Create independent runtime table and row data for the player's attempt. Do not add a general validator or save system.

Dependencies: B1 for execution. Deliver the schema/sample early to unblock L1.

Completion Criteria:

- Inspector-authored puzzle data loads with aligned input/expectation arrays.
- Evaluation supports both outcomes and consumes complete strings.
- Repeating or reordering cases does not affect results.
- Runtime edits leave authored data unchanged.

Verification: Compare known traces and check data isolation through B-T3–B-T5.

### B4: Assemble and Verify the Playable Puzzle

Owner: Brian

Effort: 2.5

Description:

Create `sprint3/dfa_puzzle.tscn` and its script. Use a Node2D root with an Automata instance and a CanvasLayer containing the transition table and Ryan's PuzzlePanel. Avoid overlapping displays and set this as the main scene.

Assign the same independent runtime table to execution and the editor before initialization that consumes it. Connect:

- `transition_requested` to a one-cell update and `clear_results()`.
- `check_requested()` to evaluation and `show_results(results_text, solved)`.
- `restore_requested()` to restoring initial destinations, rebuilding the table, and clearing results.

Call `configure_puzzle(title, requirements_text)` on load. Format each result with input string, expected outcome, actual outcome, and requirement pass/fail. Ryan's panel displays this text without evaluating it.

Dependencies: B1–B3, R1–R3, and L1. Start rough integration by October 20.

Completion Criteria:

- The edit/check/revise/restore loop satisfies all story acceptance criteria.
- B-T1–B-T5 pass, including the second-computer run assisted by Laney.
- A teammate can run the main scene without code changes.

Verification: Record the build, actual test results, defects, and retests in Taiga. Use reserve time for blocking integration fixes.

# Visual Simulation Engine

Make machine behavior and puzzle results understandable to the player. Present the puzzle requirements, provide controls for checking and restoring an attempt, and distinguish a machine accepting or rejecting a string from a puzzle requirement passing or failing.

For Sprint 3, deliver a fixed panel with readable instructions, expected/actual outcomes, and an overall solved indication. Text and keyboard access must make the interaction usable without relying on color or mouse input alone. Animated traversal and graphical transition highlighting are deferred; they are not prerequisites for this sprint's checking loop.

## Read Requirements and Check a Puzzle Attempt

Owner: Ryan

Priority: High

Effort: 6.5

As a player, I want clear requirements and checking results so that I understand whether my transition choices satisfy the puzzle and can try again.

Acceptance Criteria:

- At 1280 × 720, the supplied title, instructions, requirements, buttons, and results are readable without clipping or overlap.
- Check Solution and Restore Puzzle each emit exactly one matching signal per activation.
- Results distinguish expected outcome, actual outcome, and requirement pass/fail through text, including successful rejection.
- The summary displays `Puzzle solved` when supplied `solved = true`, and `Requirements not yet met` when false.
- Clearing results removes outcomes and summary while preserving requirements and instructions. Configuring a puzzle clears stale results.
- Both buttons have visible keyboard focus and can be activated without a mouse. Meaning does not depend on color alone.

Test Scenarios:

| ID | Scenario | Acceptance criteria |
|---|---|---|
| R-T1 | Display the authored requirements and sample results at 1280 × 720. | All text and controls are readable without clipping or overlap. |
| R-T2 | Activate each button three times. | Exactly three matching signals and no signals for the other action are received. |
| R-T3 | Supply successful acceptance, successful rejection, and mismatch examples; exercise both solved values. | All cases are distinguishable in text and both exact summaries display correctly. |
| R-T4 | Display results, clear them, then configure a different example. | Outcomes and summary clear; the appropriate requirements remain visible. |
| R-T5 | Reach and activate both buttons by keyboard in standalone and integrated scenes. | Focus is visible and activation performs the same action as clicking. |

Risks and Mitigation:

| Risk | Likelihood | Impact | Owner | Action and monitoring |
|---|---|---|---|---|
| Godot learning exceeds the panel estimate. | High | Medium | Ryan | Use the fixed hierarchy and simple methods in R1/R2; test with literal text. Share a rough component and review remaining effort by October 20. |
| Feedback confuses rejection with failure. | Medium | High | Ryan | Display explicit expected/actual/pass-fail text; verify R-T3 and Laney's walkthrough. Correct and retest blocking wording. |

### R1: Build the Fixed Puzzle Panel

Owner: Ryan

Effort: 3

Description:

Create `sprint3/puzzle_panel.tscn` and its script using:

- `PuzzlePanel` (PanelContainer)
  - `Layout` (VBoxContainer)
    - `TitleLabel` (Label)
    - `InstructionsLabel` (Label)
    - `RequirementsLabel` (Label)
    - `Buttons` (HBoxContainer)
      - `CheckButton` (Button)
      - `RestoreButton` (Button)
    - `ResultsLabel` (Label)
    - `SummaryLabel` (Label)

Button text: `Check Solution` and `Restore Puzzle`.

Instructions: “Choose a destination for each transition. Check Solution tests all listed strings. Change your choices and check again. Restore Puzzle returns transitions to their starting values.”

Use readable contrast, suitable wrapping, and visible keyboard focus. Work with literal sample text; do not implement resources, table generation, or DFA logic.

Dependencies: R2 defines the public interface; no evaluator is needed for layout.

Completion Criteria:

- The scene runs independently with the named nodes.
- Sample requirements/results fit at 1280 × 720.
- Both buttons are clearly labeled and keyboard-focusable.

Verification: Inspect the scene and record R-T1 results.

### R2: Connect Buttons and Implement Display Methods

Owner: Ryan

Effort: 1.5

Description:

Add `signal check_requested()` and `signal restore_requested()`. Each button's pressed callback emits only its matching signal.

Implement:

- `configure_puzzle(title: String, requirements_text: String) -> void`: update title/requirements and clear old results.
- `show_results(results_text: String, solved: bool) -> void`: display supplied results and the corresponding exact summary from the story criteria.
- `clear_results() -> void`: clear ResultsLabel and SummaryLabel only.

Brian supplies text and the solved flag. The panel does not locate Automata, inspect resources, or decide whether cases pass.

Dependencies: R1.

Completion Criteria:

- Each activation emits one correct signal.
- All three methods update the intended labels.
- Clearing/configuring follows the specified result lifecycle.

Verification: Exercise methods and signal counts through R-T2–R-T4.

### R3: Test the Panel Independently

Owner: Ryan

Effort: 2

Description:

Create `sprint3/test_puzzle_panel.tscn` and its script: a root Control with a PuzzlePanel instance. Configure literal requirements, count emitted signals, display sample results on Check, and clear results on Restore. Exercise both solved values and include an expected Reject/actual Reject/Pass example.

Run R-T1–R-T5 independently and share the test scene and interface with Brian. Laney repeats integrated panel checks in L4.

Dependencies: R1/R2; no evaluator required.

Completion Criteria:

- Every public method and signal is exercised.
- Standalone panel tests pass with recorded actual results.
- Another teammate can run the test scene independently.

Verification: Record tester, date, build, signal counts, and any defects/retests in Taiga.

# Level Progression & Puzzle Content

Create DFA puzzles that teach players to reason about transitions through explicit input-string requirements. Each puzzle fixes the states, alphabet, start state, and accepting states while allowing different valid transition configurations to satisfy its goal. Authored solutions and test cases establish that the content is solvable and its feedback is correct.

For Sprint 3, deliver and verify one initially unsolved puzzle containing both an acceptance and a rejection requirement. Test the complete player interaction and correct blocking instruction problems. Multiple levels, difficulty progression, unlocking, and saved progress remain future work within this epic.

## Solve a Puzzle with Known Acceptance and Rejection Requirements

Owner: Laney

Priority: High

Effort: 7.5

As a player, I want a solvable puzzle with explicit acceptance and rejection requirements so that I can determine whether my transition choices meet its stated goal.

Acceptance Criteria:

- One puzzle has two or three fixed states, inputs `0` and `1`, fixed start/accepting states, and an existing-state destination for every transition cell.
- At least two strings are prescribed, including at least one expected acceptance and one expected rejection. Input and expectation arrays have equal lengths and matching order.
- The documented solution passes every requirement. The initial configuration fails at least one, and at least one destination must change to reach the solution.
- Manual traces agree with execution for the initial table, known solution, and incorrect configuration. Repeated checks and restoration produce consistent results.
- One teammate can identify editable controls, check, interpret results, revise, and restore using on-screen instructions. Blocking confusion is corrected and rechecked.
- Integrated R-T1–R-T5 pass on Laney's computer, with zero debugger errors during the known-solution run.

Test Scenarios:

| ID | Scenario | Acceptance criteria |
|---|---|---|
| L-T1 | Inspect the authored puzzle and table resources. | 2–3 states; binary alphabet; fixed state settings; complete valid destinations; aligned requirements containing both expected outcomes. |
| L-T2 | Check the initial table, then apply the documented solution. | Initial configuration fails at least one requirement; changing at least one destination produces a solution passing all requirements. |
| L-T3 | Apply the known incorrect configuration and compare execution with manual traces. | At least one requirement fails, and every actual acceptance result agrees with its manual trace. |
| L-T4 | Solve, restore, and check twice. | Initial destinations/outcomes return and both repeated checks agree. |
| L-T5 | Ryan attempts the puzzle without step-by-step guidance. | Observe all five actions: identify controls, check, interpret, revise, restore. Record assistance and recheck any blocking instruction issue after correction. |
| L-T6 | Run the same integrated build on Laney's computer and execute panel tests and the known solution. | R-T1–R-T5 pass; known solution succeeds; zero debugger errors occur. |

Risks and Mitigation:

| Risk | Likelihood | Impact | Owner | Action and monitoring |
|---|---|---|---|---|
| Puzzle is unsolvable, already solved, or has incorrect expectations. | Medium | High | Laney | Work out a solution before authoring; compare manual traces with execution at first evaluator handoff. Mismatches block acceptance. |
| Missing schema or integration delays verification. | Medium | Medium | Brian | Supply B3's schema/sample in the first work session. Laney starts manual design independently; review blockers October 20. |
| Feedback or keyboard controls prevent independent use. | Medium | High | Laney | Perform L3/L4 before October 23. Report panel defects to Ryan and controller defects to Brian; retest corrected blockers. |

### L1: Author One Puzzle and Document Its Solution

Owner: Laney

Effort: 2

Description:

Create `sprint3/puzzles/first_puzzle.tres` using Brian's PuzzleRes schema and `sprint3/puzzles/first_puzzle_table.tres` for its initial table. Use two or three states, binary inputs, at least one accept requirement, and at least one reject requirement. Fill every initial destination.

First calculate a solution manually. Record initial and solution tables in `sprint3/tests/puzzle_checks.md`. Ensure the initial table fails at least one requirement. Keep test strings and expected booleans aligned by index; do not modify shared resource scripts.

Dependencies: B3's schema/sample for resource creation; manual design can start immediately.

Completion Criteria:

- Resources open with the agreed fields and valid destinations.
- A manual solution meets every requirement.
- The initial configuration is unsolved and requires at least one destination change.

Verification: Inspect resources and document the tables for L-T1/L-T2.

### L2: Record Manual Traces and Verify Execution

Owner: Laney

Effort: 2

Description:

In `sprint3/tests/puzzle_checks.md`, record each prescribed string's visited states and final acceptance for the initial table, solution, and an incorrect configuration. Calculate expectations before comparing with code output.

Run L-T2–L-T4 when the evaluator is available and assist with B-T3's repeated/reordered cases. Report mismatches with the exact table, input, expected result, and actual result.

Dependencies: L1; B3/B4 for execution.

Completion Criteria:

- All three configurations have expected traces and recorded actual outcomes.
- Restore/repeat checks are recorded.
- Mismatches are assigned to Brian and corrected cases are retested.

Verification: Link trace notes and actual scenario results in Taiga.

### L3: Check Instructions Through a Teammate Walkthrough

Owner: Laney

Effort: 2

Description:

Have Ryan attempt the integrated puzzle using the on-screen instructions. Observe identification of dropdowns, interpretation of requirements, checking results, revision, and restoration. Record any assistance required.

Send specific wording improvements to Ryan, who owns panel files, and recheck blocking confusion after correction. Keep this a teammate usability check; do not describe it as external target-user testing or add new features.

Dependencies: B4, Ryan's panel, and L1's puzzle.

Completion Criteria:

- One walkthrough records all five actions and assistance required.
- Successful rejection is understood as a passing requirement.
- Blocking wording issues are corrected and the affected actions rechecked.

Verification: Record L-T5 observations, proposed changes, and retest results.

### L4: Verify Integrated Feedback and Keyboard Access

Owner: Laney

Effort: 1.5

Description:

On Laney's computer at 1280 × 720, run integrated R-T1–R-T5: text readability, button actions, expected/actual/pass-fail feedback, result clearing, restoration, and keyboard focus/activation. Check the known solution and debugger output.

Report panel defects to Ryan and controller defects to Brian; do not concurrently edit their files. Retest fixes and reuse these results for the second-computer check in B-T1.

Dependencies: B4 and R3's standalone handoff.

Completion Criteria:

- All five integrated panel scenarios have recorded actual results.
- Both buttons work through visible keyboard focus.
- The known solution passes with zero debugger errors.
- Any unresolved failure has an owner and reproduction steps.

Verification: Record L-T6 and R-T1–R-T5 outcomes with tester, machine, date, and build.

# Risks & Mitigation Strategies

Protect delivery of the agreed sprint goal by identifying technical, usability, integration, capacity, and external risks before they block the team. Each risk must have an owner, likelihood, impact, a concrete mitigation, and a point when the team checks whether that mitigation worked.

For Sprint 3, keep technical and usability risks alongside the affected product stories. Ryan, as Scrum Master, coordinates scope agreement, capacity review, cross-team dependencies, and risk follow-up. The outcome is a feasible, reviewed commitment with recorded decisions and actual approval evidence; this work does not add a player-facing feature.

## Sprint 3 Risks & Mitigation

Owner: Ryan

Priority: High

Effort: 2

As the Scrum Master, I want the team and product owner to agree on a feasible sprint scope and review delivery risks so that blockers and scope changes are addressed before they prevent completion.

Acceptance Criteria:

- A planning agenda is shared before the review; meeting date, attendees, product-owner feedback, and responses to requested changes are recorded.
- The selected work fits the confirmed 30-hour team capacity: Brian 8 hours, Ryan 8.5 hours across his two stories, and Laney 7.5 hours, leaving 6 hours for corrections and documentation.
- Each team member has four individually assigned tasks; each product story has one owner and actionable acceptance tests.
- A signature or explicit approval email identifies the agreed Sprint 3 backlog. Missing approval is recorded as an unresolved follow-up, not treated as agreement.
- The October 20 and October 23 reviews record risk/mitigation outcomes, blockers, remaining effort, and an owner and next action for each unresolved issue.
- Scope changes are documented with their workload impact and product-owner agreement. Task and test records reflect actual work.

Test Scenarios:

| ID | Scenario | Acceptance criteria |
|---|---|---|
| R-C1 | Inspect planning records and the selected Taiga items. | Agenda precedes the meeting; attendees and feedback are recorded; each member has four tasks; planned effort totals 24 hours against 30 available. |
| R-C2 | Inspect product-owner agreement evidence. | A signature or explicit approval email identifies the reviewed backlog. Without it, the agreement criterion is unmet and has an assigned follow-up. |
| R-C3 | Inspect both checkpoint records and any scope changes. | Reviews cover the risks in all selected stories; unresolved blockers have owners and next actions; changes include effort impact and agreement evidence. |

Risks and Mitigation:

| Risk | Likelihood | Impact | Owner | Action and monitoring |
|---|---|---|---|---|
| Additional features or integration workload exceed available hours. | Medium | High | Ryan | Confirm estimates at planning and review remaining work October 20. Keep excluded features deferred and use reserve for blockers; obtain agreement before changing committed scope. |
| Product-owner availability delays approval. | Medium | High | Ryan | Request the review during the first work session; track follow-up dates and retain actual approval. Review missing evidence at both checkpoints. |
| Stale task/test records conceal unfinished work. | Medium | Medium | Ryan | Each owner records progress and test outcomes after work sessions. Compare evidence with Taiga at checkpoints and assign missing follow-ups. |
| The Canvas lock date prevents submission under the assumed schedule. | Medium | High | Ryan | Confirm the current submission arrangement early, record the response, and escalate any unresolved access issue before documentation days. |

### R4: Review Sprint Scope, Risks, and Product-Owner Agreement

Owner: Ryan

Effort: 2

Description:

As Scrum Master, share an agenda before the planning review: sprint goal and baseline; backlog priorities and excluded work; assignments and estimates; dependencies; risks and feasibility; revisions; product-owner agreement.

Review capacity with the team: Brian 8 planned hours, Ryan 8.5, Laney 7.5. Each has 10 hours available, leaving 6 team hours for corrections and final documentation. Estimates include beginner learning time. Each person has four individual tasks.

Record client feedback and responses to requested changes. Retain a signature or explicit approval email identifying the agreed backlog. Link the agenda, meeting record, and approval from this task.

At October 20 integration and October 23 completion checkpoints, review blockers, remaining estimates, and the risks listed in these stories. Assign each follow-up an owner and date. Confirm the current Canvas submission arrangement because the supplied assignment snapshot shows an October 14 lock.

Each developer updates their own Taiga task after work sessions. Record test results by scenario ID in comments/checklists with outcome, actual result, tester, date, build, and evidence. Ryan reviews accuracy; he does not reconstruct missing evidence.

Dependencies: Team and product-owner availability. Start before implementation is complete.

Completion Criteria:

- The agenda was shared before review; meeting date, attendees, and feedback are recorded.
- Requested changes and the team's responses are reflected in the backlog.
- Actual approval evidence is linked; absent approval remains an open follow-up.
- Both checkpoints record risk reviews, mitigation outcomes, and assigned next actions.
- Taiga assignments/estimates match the confirmed capacity, and the submission arrangement is confirmed or recorded as a blocker.

Verification: Review linked meeting/approval evidence and dated checkpoint records. This is Scrum support work, not a separate product feature.
