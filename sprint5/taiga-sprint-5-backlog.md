# Core Logic/Mechanics

Provide the DFA data and execution behavior that make transition-editing puzzles work. The player selects destinations for preset state/input pairs, and the machine evaluates complete strings against those choices. Puzzle correctness depends on satisfying the prescribed outcomes, not matching one particular transition arrangement.

Sprint 5 goal: A player can solve a short sequence of three-state puzzles and manually step through a listed input while the diagram identifies the current state and the interface shows execution progress.

Sprint deadline: November 24, 2026. Planning allocation: 10 hours each, totaling 30 hours. Brian has 10 hours of implementation and verification. Ryan has approximately 4 hours of core work plus 6 hours of learning and contingency allowance; Laney has approximately 6 hours of core work plus 4 hours of allowance. Task effort values include those allowances. Brian is Scrum Master; shared Scrum activities are handled outside these implementation tasks.

The sprint retains preset A/B/C states, inputs `0` and `1`, destination dropdowns, and the existing nine diagram routes. Automatic playback, moving tokens, animated arrows, dragging transitions, arbitrary graph layouts, designer-data validation, saved progress across restarts, dedicated external playtesting, and broader accessibility work remain in the product backlog. Basic feature checks and the risks below are part of this commitment.

## Step Through the Player's DFA

Owner: Brian

Priority: High

Effort: 10 hours

As a player, I want to process a listed input one symbol at a time so that I can understand how my transition choices produce acceptance or rejection.

Dependencies:

- Existing Automata2D, transition table, evaluator, and puzzle controller.
- Laney's trace panel and State2D visuals.
- Ryan's final ordered puzzle resources.

Acceptance Criteria:

- Running the project opens `sprint3/dfa_puzzle.tscn`.
- Beginning a trace starts at the preset start state with zero symbols consumed. Each Step consumes exactly one symbol and follows the current working table.
- The current state and consumed/total counts agree between the diagram and trace panel. Exactly one state is marked current during an active trace.
- Acceptance/rejection is displayed only after the complete input is consumed. An empty input finishes immediately at the start state.
- Step has no effect after completion. Reset Trace returns the loaded string to its beginning without changing transitions or puzzle completion.
- Editing a transition, restoring the puzzle, selecting another puzzle, or returning to selection clears the previous trace. A new trace uses the latest working table.
- Trace execution does not unlock puzzles. Check remains the action that evaluates all requirements and earns completion.
- Return hides the table along with the other puzzle controls. Selecting a puzzle restores them.
- The three-puzzle sequence supports correct unlocking, retained session edits, and the final boundary without debugger errors.

Test Scenarios:

| ID | Scenario | Acceptance criteria |
|---|---|---|
| S-T1 | Launch through project startup and begin `101` on a manually documented table. | The integrated puzzle opens; initial state/count match the table; each press consumes one symbol and reaches the manually traced destination. |
| S-T2 | Trace an accepted string, a rejected string, and an empty string. Press Step again after each completion. | Final outcomes match Eval; empty input uses start-state acceptance; additional presses make no changes. |
| S-T3 | Trace partially, Reset Trace, then edit, Restore, navigate, and Return in separate attempts. | Reset restarts the loaded string; the other actions clear stale tracing; subsequent traces use current data; selection has no leftover table. |
| S-T4 | Trace a successful string, then solve and Check each puzzle in the final sequence. Revisit an edited puzzle and repeat Check. | Tracing alone earns no completion; successful Check unlocks exactly the successor; failed/repeated checks do not skip puzzles; session edits persist. |

Risks and Mitigation:

| Risk | Likelihood | Impact | Owner | Action and monitoring |
|---|---|---|---|---|
| Trace and evaluator disagree about when a string is accepted. | Medium | High | Brian | Use complete-string acceptance and compare the three S-T2 cases with Eval during B1. Resolve discrepancies before panel integration. |
| A trace continues using stale data after an edit or navigation. | Medium | High | Brian | Centralize trace clearing at those controller events in B2 and exercise S-T3 before final integration. |
| Panel and execution interfaces diverge during parallel work. | Medium | High | Brian | B1 and V1 use the contracts below. Share a minimal working trace early; review interface mismatches at the first integration. |
| New behavior exceeds the ten-hour allocation. | Medium | High | Brian | Keep execution manual and reuse current state/diagram components. At first integration, compare remaining work with available hours and raise any scope change with the team. |

### B1: Add Manual Trace Execution to Automata2D

Owner: Brian

Effort: 2 hours

Extend `automata_2d.gd` using its existing table and stepping behavior. Add:

- `begin_trace(input_string: String) -> void`
- `advance_trace() -> void`
- `reset_trace() -> void`
- `clear_trace() -> void`
- `trace_changed(current_state: String, consumed: int, total: int, finished: bool, accepted: bool)` signal.

Beginning stores the string and resets execution. Advancing processes its next symbol. Reset restarts the loaded string; clear ends the trace and removes current-state highlighting. The `accepted` value is meaningful when `finished` is true. Trace strings come from the authored requirement list.

Use `State2D.set_current(value)` to update state indicators after beginning, stepping, and resetting. Preserve `step(input: String)` for its existing callers.

Completion Criteria:

- Execution follows the working table and handles empty inputs and completed traces.
- The signal describes the state after each execution action.
- Trace operations leave authored resources and completion flags unchanged.

Verification: S-T1/S-T2 using a manual trace and Eval comparison.

### B2: Connect the Trace Panel to the Puzzle Controller

Owner: Brian

Effort: 3 hours

Instance Laney's `sprint5/trace_panel.tscn` as `CanvasLayer/TracePanel` in the integrated puzzle. Connect its requests to Automata2D and `trace_changed` to the panel's display method. Configure its input list from `puzzle.test_inputs` on selection.

In `_on_puzzle_selected()`, call `configure_inputs(puzzle.test_inputs)`. Connect `begin_requested` to `begin_trace`, `step_requested` to `advance_trace`, `reset_requested` to `reset_trace`, and `trace_changed` to `show_trace`. Clear the execution and panel together after transition edits, Restore, puzzle selection, and Return. Update `_set_puzzle_visible()` to include `CanvasLayer/MarginContainer` and `CanvasLayer/TracePanel`. Check continues through the existing evaluator/progression flow.

Dependencies: B1 and V1. The panel can be integrated as soon as its nodes and signals exist.

Completion Criteria:

- The panel operates on the displayed working table.
- All clearing/reset cases meet the story criteria.
- Checking all requirements and manually tracing one requirement remain distinct actions.

Verification: S-T2/S-T3, including a trace after editing a used transition.

### TASK | #147 B3: Synchronize the Diagram with Puzzle Editing and Restore

Owner: Brian

Effort: 2

Description:

Instance the diagram under the existing Automata2D node, at local position zero. In sprint3/dfa_puzzle.gd, call refresh_from_table(_user_table) after initial child setup, after a dropdown handler updates its table cell, and after Restore creates and assigns the fresh working table.

Retain the existing transition_selected(origin_state, input_index, new_destination, previous_destination) signal and PuzzlePanel methods. Diagram refresh is additional display behavior; evaluation continues through PuzzleRes and Eval. Set the project main scene to the integrated puzzle if it still points to the standalone Automata scene.

Dependencies: B2. This integration and Ryan's layout work share dfa_puzzle.tscn. Changes to component locations may also require updates to the controller's node paths; Brian and Ryan can coordinate those changes as the layout takes shape.

Completion Criteria:

Initial load, edits, and Restore all refresh from the current working table.
Editing clears stale check results; Restore updates the table, diagram, and panel consistently.
Check results are unchanged by the presence of the diagram.
Running the project opens the integrated puzzle.

Verification: Run V-T3/V-T4 and the current puzzle's known solution. Record the tested build for Ryan and Laney.

### TASK | #138 L4: Implement Unlock Logic

Owner: Brian

Effort: 3 hours

Create progression logic controlling puzzle availability.

Create sprint4/puzzle_progression.gd to hold the ordered Array[PuzzleRes], current puzzle index, completion flags, and working table for each visited puzzle. The first puzzle starts available. Passing all requirements marks the current puzzle complete and unlocks its successor. Revisiting a puzzle uses its retained working table.

Provide is_unlocked(index: int) -> bool, select_puzzle(index: int) -> void, and mark_current_complete() -> void. Emit puzzle_selected(puzzle: PuzzleRes, working_table: TTableRes) when a puzzle is selected and progression_changed when completion changes availability. UI4 connects selection to the puzzle controller; UI3's navigation requests use this same progression data.

Create sprint4/puzzle_selection.tscn with a Control root, a MarginContainer, and a VBoxContainer containing one Button per puzzle title. Availability controls which buttons are enabled. This is the destination for Return and the entry point for selecting an available puzzle.

Dependencies: L1's order, L2/L3's resources, and UI3's navigation signals. Temporary references to existing content can support integration before the full set is ready.

Completion Criteria:

Unlock system functional for the full ordered sequence.
Successful checks unlock exactly the next puzzle; unsuccessful checks preserve availability.
Selection and navigation use the same availability state.
Session edits and completion survive navigation between puzzles.
Verified by another team member.

Verification: Run LP-T1–LP-T4, including locked selection, a repeated successful check, and the final-puzzle boundary.

# EPIC | #3 Visual Simulation Engine

Make machine behavior and puzzle results understandable to the player. Present the puzzle requirements, provide controls for checking and restoring an attempt, and distinguish a machine accepting or rejecting a string from a puzzle requirement passing or failing.

For Sprint 3, deliver a fixed panel with readable instructions, expected/actual outcomes, and an overall solved indication. Text and keyboard access must make the interaction usable without relying on color or mouse input alone. Animated traversal and graphical transition highlighting are deferred; they are not prerequisites for this sprint's checking loop.

## Display Manual Execution on the Puzzle Screen

Owner: Laney

Priority: High

Effort: 10 hours

As a player, I want to see the current state and input progress while stepping so that I can follow the machine's path through the diagram.

Dependencies: Brian's trace methods/signal and the existing State2D and puzzle scene.

Acceptance Criteria:

- The trace panel contains only the current puzzle's listed strings, including a recognizable `(empty)` label where applicable.
- Begin Trace, Step, and Reset Trace control the loaded trace. Step is unavailable before beginning and after completion; Reset is available after a trace begins.
- The panel shows current state, consumed/total symbol count, and either an in-progress message or final Accept/Reject outcome.
- Start, accepting, and current state indicators remain distinguishable when more than one applies to a state.
- Current-state indication is visible in the diagram; clearing a trace removes it.
- At 1280 × 720 and 1600 × 900, the trace panel, diagram, table, and controls are readable without overlap. Longer requirement/results content remains accessible through scrolling.

Test Scenarios:

| ID | Scenario | Acceptance criteria |
|---|---|---|
| V-T1 | Open the panel for each puzzle, including a puzzle with an empty-string requirement. | Options match its requirements; the empty string is labeled `(empty)`; controls begin in their cleared state. |
| V-T2 | Begin, step, reset, and finish a trace. | State and counts match execution; controls reflect whether stepping is possible; final acceptance is shown after consumption. |
| V-T3 | Inspect a state marked start/current, accepting/current, and start/accepting/current in a temporary Inspector configuration. | All applicable meanings remain readable; names and rings remain visible; clear removes current indication. |
| V-T4 | Display the longest instructions/results and run a trace at both target sizes. | Controls and diagram remain usable, text can be read, and no supported route or label is clipped. |

Risks and Mitigation:

| Risk | Likelihood | Impact | Owner | Action and monitoring |
|---|---|---|---|---|
| Status indicators obscure labels or arrow attachments. | Medium | High | Laney | Use the existing state component and fixed routes; inspect combined statuses in V2 before integrating. |
| New controls crowd the current fixed-offset layout. | High | High | Laney | Check a rough placement in V3 before styling, using maximum text and both sizes. Share any required controller path changes with Brian. |
| Godot signal/container work takes longer than estimated. | Medium | Medium | Laney | Start with standard OptionButton, Button, Label, and container nodes. Bring a minimal panel to the first integration and prioritize readable existing components. |

### V1: Create the Manual Trace Panel

Owner: Laney

Effort: 2.5 hours

Create `sprint5/trace_panel.tscn` and its script. Use a PanelContainer root, a VBoxContainer, an OptionButton named `InputSelector`, an HBoxContainer with `BeginButton`, `StepButton`, and `ResetButton`, and Labels named `StateLabel`, `ProgressLabel`, and `OutcomeLabel`.

Expose:

- `begin_requested(input_string: String)`, `step_requested`, and `reset_requested` signals.
- `configure_inputs(inputs: Array[String]) -> void`
- `show_trace(current_state: String, consumed: int, total: int, finished: bool, accepted: bool) -> void`
- `clear_trace() -> void`

In `_ready()`, connect BeginButton to a handler that emits `begin_requested` with the selected string, and connect StepButton/ResetButton to their respective request signals. In `configure_inputs()`, clear InputSelector, add each string, and store the original value with `set_item_metadata()`. Read it with `get_item_metadata(InputSelector.selected)` when Begin is pressed.

References: [OptionButton](https://docs.godotengine.org/en/4.3/classes/class_optionbutton.html) and [Button](https://docs.godotengine.org/en/4.3/classes/class_button.html).

Keep the actual strings associated with selector items; `(empty)` is display text for `""`. Choosing another option takes effect on Begin Trace, so an unfinished trace remains tied to its loaded string. Disable input selection while tracing; clear or completion makes it available again. Configure/clear leaves Step and Reset disabled until Begin.

Completion Criteria:

- Signals carry the actual input string and each button produces one request.
- Display methods update labels and button availability from supplied execution data.
- The panel can be exercised before the execution code is ready using sample method calls.

Verification: V-T1/V-T2 with sample display values, then Brian's live signal.

### V2: Clarify State Status Visuals

Owner: Laney

Effort: 2.5 hours

Update `state_2d.gd` and `state_2d.tscn` so `set_current(value)` visibly distinguishes the current state. Retain `label_name`, `is_start`, and `is_accepting`, including the accepting ring. In `set_current(value)`, set the InnerRing2D stroke color to yellow when true and white when false, and update the existing current label visibility. Keep the accepting ring controlled by `is_accepting`.

Completion Criteria:

- Start, accepting, and current status remain distinguishable in combination.
- State names and arrow attachments remain readable.
- Existing `set_current(value)` callers control the appearance.

Verification: V-T3; restore temporary authored settings after inspection.

### V3: Fit the Trace Panel into the Existing Layout

Owner: Laney

Effort: 2.5 hours

Place TracePanel below the diagram at offsets left 600, top 540, right 1240, bottom 710. Move the transition-table MarginContainer to left 20, top 500, right 300, bottom 655; reduce PanelScroll bottom to 480. Check this initial arrangement with the actual panel minimum sizes. Apply these scene changes in `sprint3/dfa_puzzle.tscn` alongside the existing diagram, table, and puzzle panel. Set `window/size/viewport_width` to 1280, `window/size/viewport_height` to 720, and `window/stretch/mode` to `canvas_items` in Project Settings. The diagram's internal state positions remain the existing horizontal layout.

B2 and V3 share the integrated scene: the TracePanel path is their agreed connection point. Changes to other component paths also affect the controller getters.

Completion Criteria:

- V-T4 passes at both target sizes with results shown.
- Trace and puzzle controls remain usable together.
- Selection/puzzle visibility works with #147.

Verification: Record both viewport sizes and any layout findings on the integrated build.

### V4: Complete the Visual Execution Pass

Owner: Laney

Effort: 2.5 hours

Run V-T1–V-T4 on the integrated scene and correct panel/state/layout issues found in those cases. Share execution/controller findings with Brian, including the input and transition configuration that produced them.

Completion Criteria:

- Visual scenarios pass with live execution.
- The reviewed build and any corrections/retests are recorded.
- No blocking panel, status, or overlap issues remain in the supported layout.

Verification: One accepting trace, one rejecting trace, empty input, reset, and trace clearing, followed by a size check.

# EPIC | #5 Level Progression & Puzzle Content

Create DFA puzzles that teach players to reason about transitions through explicit input-string requirements. Each puzzle fixes the states, alphabet, start state, and accepting states while allowing different valid transition configurations to satisfy its goal. Authored solutions and test cases establish that the content is solvable and its feedback is correct.

For Sprint 3, deliver and verify one initially unsolved puzzle containing both an acceptance and a rejection requirement. Test the complete player interaction and correct blocking instruction problems. Multiple levels, difficulty progression, unlocking, and saved progress remain future work within this epic.

## Play Three Puzzles with Increasing Requirements

Owner: Ryan

Priority: High

Effort: 10 hours

As a player, I want a short sequence with increasingly demanding input requirements so that I can practice transition reasoning and use the execution diagram to understand my attempts.

Dependencies: Existing PuzzleRes/evaluator/progression and Brian's final sequence integration.

Acceptance Criteria:

- The sequence contains two new puzzles followed by the existing Find the Double 1 puzzle.
- All three use preset A/B/C states, inputs `0` and `1`, start A, and accepting C, fitting the existing diagram.
- Each puzzle starts with at least one unmet requirement and has a documented solution that satisfies every listed requirement.
- Puzzle 1 accepts `1` and rejects the empty string. Puzzle 2 accepts `01` and rejects `00` and the empty string. Puzzle 3 retains its existing seven requirements.
- Resources, order, solutions, and manual traces are available for integration. These finite requirements define success; the checker does not claim correctness for unlisted strings.
- The final sequence is completed in the running scene; a failed attempt does not unlock its successor, and revisiting a puzzle preserves session edits.

Test Scenarios:

| ID | Scenario | Acceptance criteria |
|---|---|---|
| C-T1 | Check each initial table and documented solution. | The initial table fails at least one requirement; every solution outcome matches its expected value. |
| C-T2 | Compare one accepted and one rejected input per puzzle with a manual state trace. | Traces match the existing evaluator, including empty input; authored resources remain unchanged by attempts. |
| C-T3 | Solve the three integrated puzzles in order and revisit one. | Success unlocks the next; failure does not; session edits persist; the final puzzle has no next destination. |

Risks and Mitigation:

| Risk | Likelihood | Impact | Owner | Action and monitoring |
|---|---|---|---|---|
| A puzzle is already solved or its solution is inconsistent. | Medium | High | Ryan | Check initial and solution tables during #136, then record outcomes before handing resources to Brian. |
| Content needs more states than the diagram supports. | Low | High | Ryan | Keep the three-state resource contract above and inspect each resource's state/input settings during authoring. |
| Increasing requirements do not clearly explain the progression. | Medium | Medium | Ryan | Document the added constraint for each puzzle in C3 and review the order with the team during C4. External playtesting remains future work. |
| Integration arrives too late for the final sequence check. | Medium | High | Ryan | Share each working resource as it is completed, allowing Brian to integrate before the final content pass. |

### TASK | #136 L2: Create Beginner Puzzle Set

Owner: Ryan

Effort: 2

Develop beginner puzzles focused on basic DFA concepts.

Create at least two PuzzleRes resources under sprint4/puzzles/, named beginner_01.tres and beginner_02.tres. Each contains its title, source table, test inputs, and corresponding expected acceptance values. States and inputs are preset; transitions are the player's editable choices.

Document a solution transition table and expected results for each puzzle in sprint4/puzzles/solutions.md.

Dependencies: L1 tier definitions and the existing PuzzleRes/TTableRes resource workflow.

Completion Criteria:

Minimum two puzzles implemented.
Correct solution documented for each.
Each starting configuration leaves at least one requirement unsatisfied.
Each documented solution passes all listed requirements through the existing evaluator.

Verification: Record starting and solved results for both resources; include the empty string when it is part of an authored requirement.

### C3: Document the Sequence and Solution Traces

Owner: Ryan

Effort: 4 hours

Create `sprint4/puzzles/solutions.md` with the order: beginner_01, beginner_02, then the existing `sprint3/puzzles/first_puzzle.tres`.

For each puzzle, record its solved transition table and expected outcomes. Record one accepted and one rejected state trace per puzzle. Note the additional reasoning introduced at each step. For the existing puzzle, verify the known B-on-1 → C and C-on-0 → C solution through its seven requirements.

Completion Criteria:

- All three puzzles have reproducible solutions and two example traces.
- Initial/solved outcomes are recorded.
- Input strings and expected outcomes match the actual resources.

Verification: C-T2 using the evaluator; flag any mismatch before integration.

### C4: Review Content in the Integrated Progression

Owner: Ryan

Effort: 4 hours

Load the three resources through Brian's integrated progression and complete them in order using the documented solutions. Review the title, requirements, table initialization, and retained edits on revisiting a puzzle. Share concrete content or integration findings and correct resource/documentation mismatches.

Brian can begin #138 using the resource paths before this final review; the two tasks provide an initial integration followed by content review and any corrections.

Completion Criteria:

- C-T1–C-T3 pass in the integrated version.
- Another team member has reviewed the puzzle order and solutions.
- Content findings and retests identify the reviewed build.

Verification: Record one failed attempt, the full solved sequence, and one revisit with retained edits.
