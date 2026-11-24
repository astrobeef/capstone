# Sprint 5 puzzle solutions

Order loaded by `sprint3/dfa_puzzle.tscn`: `beginner_01`, `beginner_02`, then `sprint3/puzzles/first_puzzle.tres`.

Start state is A. Inputs are `0` and `1`. `""` is the empty string. A trace lists the state before each symbol and the state after it. Acceptance is the final state only.

The later tier files are still in `sprint4/puzzles/`. They are not part of this sequence.

## beginner_01

- Resource: `res://sprint4/puzzles/beginner_01.tres`
- Title: Ends in 1
- Accepting state: B
- What this step adds: the string has to finish in the accepting state. A `0` after a `1` must leave B, or `"10"` would be accepted.

Starting table: A on 0 is A, A on 1 is B, B on 0 is B, B on 1 is A. It already fails `"11"`, `"101"`, and `"10"`.

### Solution transitions

| state | on 0 | on 1 |
|---|---|---|
| A | A | B |
| B | A | B |

Cells changed from the start: B on 0 (B to A), B on 1 (A to B).

### Expected results

| input | expected |
|---|---|
| "1" | Accept |
| "01" | Accept |
| "11" | Accept |
| "101" | Accept |
| "" | Reject |
| "0" | Reject |
| "10" | Reject |
| "110" | Reject |

### Accepted trace: "1"

| step | read | state before | state after |
|---|---|---|---|
| 1 | 1 | A | B |

Final state B is accepting. Result: Accept.

### Rejected trace: "10"

| step | read | state before | state after |
|---|---|---|---|
| 1 | 1 | A | B |
| 2 | 0 | B | A |

Final state A is not accepting. Result: Reject.

## beginner_02

- Resource: `res://sprint4/puzzles/beginner_02.tres`
- Title: At least one 1
- Accepting state: B
- What this step adds: a self-loop. Once a `1` has been seen, both inputs stay in B. The starting table sends B on 0 back to A, so `"10"` and `"010"` fail.

Starting table: A on 0 is A, A on 1 is B, B on 0 is A, B on 1 is B.

### Solution transitions

| state | on 0 | on 1 |
|---|---|---|
| A | A | B |
| B | B | B |

Cell changed from the start: B on 0 (A to B).

### Expected results

| input | expected |
|---|---|
| "1" | Accept |
| "01" | Accept |
| "10" | Accept |
| "010" | Accept |
| "" | Reject |
| "0" | Reject |
| "00" | Reject |

### Accepted trace: "01"

| step | read | state before | state after |
|---|---|---|---|
| 1 | 0 | A | A |
| 2 | 1 | A | B |

Final state B is accepting. Result: Accept.

### Rejected trace: "00"

| step | read | state before | state after |
|---|---|---|---|
| 1 | 0 | A | A |
| 2 | 0 | A | A |

Final state A is not accepting. Result: Reject. The empty string also rejects, because A is not accepting and no symbol is read.

## first_puzzle

- Resource: `res://sprint3/puzzles/first_puzzle.tres`
- Title: Find the Double 1
- Accepting state: C
- What this step adds: the machine has to remember that the previous symbol was `1`. B on 1 goes to C, and C on 0 stays in C. Changing only one of those two cells still fails `"110"`.

Starting table: A on 0 is A, A on 1 is B, B on 0 is A, B on 1 is A, C on 0 is A, C on 1 is C. It fails `"11"`, `"011"`, and `"110"`.

### Solution transitions

| state | on 0 | on 1 |
|---|---|---|
| A | A | B |
| B | A | C |
| C | C | C |

Cells changed from the start: B on 1 (A to C), C on 0 (A to C).

### Expected results

| input | expected |
|---|---|
| "11" | Accept |
| "011" | Accept |
| "110" | Accept |
| "" | Reject |
| "1" | Reject |
| "101" | Reject |
| "0101" | Reject |

### Accepted trace: "110"

| step | read | state before | state after |
|---|---|---|---|
| 1 | 1 | A | B |
| 2 | 1 | B | C |
| 3 | 0 | C | C |

Final state C is accepting. Result: Accept. Step 2 is B on 1 to C. Step 3 is C on 0 to C.

### Rejected trace: "101"

| step | read | state before | state after |
|---|---|---|---|
| 1 | 1 | A | B |
| 2 | 0 | B | A |
| 3 | 1 | A | B |

Final state B is not accepting. Result: Reject. The `0` clears the single `1`, so the last `1` does not complete a pair.

## Integrated review

`sprint5/tests/sequence_checks.gd` loads these three resources through the scene's `PuzzleProgression` and checks:

- each starting table fails at least one requirement, and each solution passes every requirement
- the traces above end in the same Accept or Reject result as `Eval`
- Check on the unsolved Ends in 1 table leaves Next disabled
- solving the three in order unlocks only the next puzzle
- setting At least one 1's A on 0 to B, leaving, and coming back keeps that edit
- Next stays disabled on Find the Double 1 after it is solved

Headless run on November 24, 2026, from commit `01959fa` plus these edits:

- Failed Check on Ends in 1 left the puzzle unsolved and left Next disabled.
- Solving Ends in 1, At least one 1, and Find the Double 1 unlocked only the next puzzle.
- At least one 1 kept A on 0 set to B after leaving and coming back.
- Next stayed disabled after Find the Double 1 was solved.
- `sequence_checks`, `sprint4_checks`, and `trace_panel_checks` exited with no failures.

Another teammate still needs to read this order before that review line is closed.
