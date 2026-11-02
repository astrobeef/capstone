# Difficulty tiers (Sprint 4, task L1 #135)

Draft for team review. Every puzzle below was checked by script: the documented solution passes every requirement, the starting table fails at least one, and each solution matches its stated rule on every string up to length 7. Resource format follows `sprint3/puzzle_resource.gd` (title, source table, test inputs, expected acceptance) and the current puzzle "Find the Double 1" is the reference.

Notation: the start state is always A, inputs are 0 and 1, and a requirement is a string with an expected Accept or Reject.

## Tier definitions

| | Beginner | Intermediate | Advanced |
|---|---|---|---|
| Concept introduced | One simple idea: where the machine must finish, or a self-loop | Remembering something about the input so far (previous symbol, a count) | Overlapping patterns: choosing the right fall-back state after a mismatch |
| States | 2 | 2 to 3 | 3 (4 only if the team agrees) |
| Rule shown to player | Stated in plain words in the title or instructions | Stated in plain words | Stated in plain words; the requirement strings are what check the fall-back behavior |
| Cells the player must change | 1 to 2 | 2 | 3 or more |
| Requirements | At least 4 (at least 1 reject) | At least 6, including a trap string | At least 8, including near-miss rejects |
| Expected reasoning | Trace one or two strings and fix the wrong cell | Ask "what does the machine need to remember?" and trace several strings | Trace overlapping strings and find where a wrong fall-back transition breaks a near-miss |
| Trap or near-miss | None | A one-cell fix that still fails a requirement, or a start state that is also accepting | Strings that match the pattern's start and then fail, so a 0 or 1 sends the machine to the wrong state |

## Planned order

| # | Puzzle | Tier | What it adds |
|---|---|---|---|
| P1 | Ends in 1 | Beginner | States, transitions, and that the string must finish in the accepting state |
| P2 | At least one 1 | Beginner | Self-loops: once a 1 is seen the machine stays accepting |
| P3 | Find the Double 1 | Intermediate | Remembering the previous symbol (3 states, one fix is not enough) |
| P4 | Even number of 1s | Intermediate | Counting by parity; the start state also accepts the empty string |
| P5 | Ends in 01 | Advanced | Overlapping patterns: falling back to the right middle state after a mismatch |

The sequence has two Beginner puzzles (P1, P2), two Intermediate (P3, P4), and one Advanced (P5), so the three later puzzles span both later tiers.

## P1 Ends in 1 (Beginner)

**Rule:** Accept every string that ends in 1.

**What it adds:** The first puzzle. Introduces states, transitions, and that the accepting state is where the string must finish.

**Accepting state:** B. **Cells to change from the starting table:** 2 (B on 0: B -> A, B on 1: A -> B).

**Requirements:**

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

**Starting table (unsolved):**

| state | on 0 | on 1 |
|---|---|---|
| A (start) | A | B |
| B (accepting) | B | A |

Starting table fails: "11", "101", "10".

**Solution table:**

| state | on 0 | on 1 |
|---|---|---|
| A (start) | A | B |
| B (accepting) | A | B |

## P2 At least one 1 (Beginner)

**Rule:** Accept every string that contains at least one 1.

**What it adds:** Self-loops. Once the machine has seen a 1 it stays in the accepting state, and 0 on the start state loops back.

**Accepting state:** B. **Cells to change from the starting table:** 1 (B on 0: A -> B).

**Requirements:**

| input | expected |
|---|---|
| "1" | Accept |
| "01" | Accept |
| "10" | Accept |
| "010" | Accept |
| "" | Reject |
| "0" | Reject |
| "00" | Reject |

**Starting table (unsolved):**

| state | on 0 | on 1 |
|---|---|---|
| A (start) | A | B |
| B (accepting) | A | B |

Starting table fails: "10", "010".

**Solution table:**

| state | on 0 | on 1 |
|---|---|---|
| A (start) | A | B |
| B (accepting) | B | B |

## P3 Find the Double 1 (Intermediate)

**Rule:** Accept every string that contains two 1s in a row.

**What it adds:** Remembering the previous symbol. Needs three states and a sticky accepting state; fixing only one cell still fails "110".

**Accepting state:** C. **Cells to change from the starting table:** 2 (B on 1: A -> C, C on 0: A -> C).

**Requirements:**

| input | expected |
|---|---|
| "11" | Accept |
| "011" | Accept |
| "110" | Accept |
| "" | Reject |
| "1" | Reject |
| "101" | Reject |
| "0101" | Reject |

**Starting table (unsolved):**

| state | on 0 | on 1 |
|---|---|---|
| A (start) | A | B |
| B | A | A |
| C (accepting) | A | C |

Starting table fails: "11", "011", "110".

**Solution table:**

| state | on 0 | on 1 |
|---|---|---|
| A (start) | A | B |
| B | A | C |
| C (accepting) | C | C |

## P4 Even number of 1s (Intermediate)

**Rule:** Accept every string with an even number of 1s (zero counts as even).

**What it adds:** Counting by parity. The start state is also accepting, so the empty string must be accepted, and 0 does not change the count.

**Accepting state:** A. **Cells to change from the starting table:** 2 (B on 0: A -> B, B on 1: B -> A).

**Requirements:**

| input | expected |
|---|---|
| "" | Accept |
| "0" | Accept |
| "11" | Accept |
| "101" | Accept |
| "0110" | Accept |
| "1" | Reject |
| "10" | Reject |
| "111" | Reject |
| "010" | Reject |

**Starting table (unsolved):**

| state | on 0 | on 1 |
|---|---|---|
| A (start), accepting | A | B |
| B | A | B |

Starting table fails: "11", "101", "10", "010".

**Solution table:**

| state | on 0 | on 1 |
|---|---|---|
| A (start), accepting | A | B |
| B | B | A |

## P5 Ends in 01 (Advanced)

**Rule:** Accept every string that ends in 01.

**What it adds:** Overlapping patterns. After a mismatch the machine must fall back to the right middle state instead of the start, so a 0 always goes to B and a 1 after 01 does not stay accepting.

**Accepting state:** C. **Cells to change from the starting table:** 4 (A on 0: A -> B, B on 0: A -> B, C on 0: C -> B, C on 1: C -> A).

**Requirements:**

| input | expected |
|---|---|
| "01" | Accept |
| "101" | Accept |
| "001" | Accept |
| "0101" | Accept |
| "" | Reject |
| "0" | Reject |
| "1" | Reject |
| "10" | Reject |
| "011" | Reject |
| "010" | Reject |
| "0110" | Reject |

**Starting table (unsolved):**

| state | on 0 | on 1 |
|---|---|---|
| A (start) | A | A |
| B | A | C |
| C (accepting) | C | C |

Starting table fails: "01", "101", "001", "0101".

**Solution table:**

| state | on 0 | on 1 |
|---|---|---|
| A (start) | B | A |
| B | B | C |
| C (accepting) | B | A |

## Review against tier criteria

| Puzzle | Tier | States | Cells to change | Requirements | Trap or near-miss | Meets criteria |
|---|---|---|---|---|---|---|
| P1 | Beginner | 2 | 2 | 8 | None needed | Yes |
| P2 | Beginner | 2 | 1 | 7 | None needed | Yes |
| P3 | Intermediate | 3 | 2 | 7 | One fix still fails "110" | Yes |
| P4 | Intermediate | 2 | 2 | 9 | Start state accepts "" | Yes |
| P5 | Advanced | 3 | 4 | 11 | Near-miss rejects "011", "010", "0110" | Yes |

## Team review

- Reviewed by Ryan (content author): [ ] date:
- Reviewed by Brian (progression): [ ] date:
- Agreement or requested changes:

Open question for Brian: do later sprints allow four states, and is a fixed state count per tier acceptable?
