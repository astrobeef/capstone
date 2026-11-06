# Difficulty tiers (Sprint 4, task L1 #135)

Draft for team review. Every puzzle below was checked by script: the documented solution passes every requirement, the starting table fails at least one, every destination is a real state, and each solution matches its stated rule on every string up to length 8. Resource format follows `sprint3/puzzle_resource.gd` (title, source table, test inputs, expected acceptance) and the current puzzle "Find the Double 1" is the reference.

Brian confirmed (Nov 5) that puzzles may use four or more states, so Advanced is defined by 4 or more states.

Notation: the start state is always A, inputs are 0 and 1, and a requirement is a string with an expected Accept or Reject.

## Tier definitions

| | Beginner | Intermediate | Advanced |
|---|---|---|---|
| Concept introduced | One simple idea: where the machine must finish, or a self-loop | Remembering one thing about the input so far (previous symbol, a count) | Tracking two things at once, or overlapping patterns, across four or more states |
| States | 2 | 2 to 3 | 4 or more |
| Rule shown to player | Stated in plain words in the title or instructions | Stated in plain words | Stated in plain words; the requirement strings are what expose a wrong transition |
| Cells the player must change | 1 to 2 | 2 | 4 or more |
| Requirements | At least 4 (at least 1 reject) | At least 6, including a trap string | At least 10, including near-miss rejects |
| Expected reasoning | Trace one or two strings and fix the wrong cell | Ask "what does the machine need to remember?" and trace several strings | Work out what each state means, then trace near-miss strings to find which cells are wrong |
| Trap or near-miss | None | A one-cell fix that still fails a requirement, or a start state that is also accepting | Near-miss strings (right length, wrong counts; or a partial match that must fall back correctly) that a half-correct table still gets wrong |

## Planned order

| # | Puzzle | Tier | What it adds |
|---|---|---|---|
| P1 | Ends in 1 | Beginner | States, transitions, and that the string must finish in the accepting state |
| P2 | At least one 1 | Beginner | Self-loops: once a 1 is seen the machine stays accepting |
| P3 | Find the Double 1 | Intermediate | Remembering the previous symbol (3 states, one fix is not enough) |
| P4 | Even number of 1s | Intermediate | Counting by parity; the start state also accepts the empty string |
| P5 | Even 0s and even 1s | Advanced | Tracking two conditions at once: four states hold both parities, and each input flips exactly one of them |

The sequence has two Beginner puzzles (P1, P2), two Intermediate (P3, P4), and one Advanced (P5), so the three later puzzles span both later tiers. P5 builds on P4: one parity becomes two. An optional stretch puzzle ("Contains 101") is included at the end in case the team wants a second Advanced puzzle.

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
| A (start) (accepting) | A | B |
| B | A | B |

Starting table fails: "11", "101", "10", "010".

**Solution table:**

| state | on 0 | on 1 |
|---|---|---|
| A (start) (accepting) | A | B |
| B | B | A |

## P5 Even 0s and even 1s (Advanced)

**Rule:** Accept every string that has an even number of 0s and an even number of 1s (the empty string counts).

**What it adds:** Tracking two conditions at once. The four states are (even, even), (odd 0s, even 1s), (even 0s, odd 1s) and (odd, odd); each 0 flips the 0-parity and each 1 flips the 1-parity. A wrong cell in any one state breaks several strings.

**Accepting state:** A. **Cells to change from the starting table:** 4 (A on 0: A -> B, A on 1: B -> C, B on 1: C -> D, C on 0: C -> D).

**Requirements:**

| input | expected |
|---|---|
| "" | Accept |
| "00" | Accept |
| "11" | Accept |
| "0101" | Accept |
| "0110" | Accept |
| "1001" | Accept |
| "001100" | Accept |
| "0" | Reject |
| "1" | Reject |
| "01" | Reject |
| "10" | Reject |
| "001" | Reject |
| "0111" | Reject |
| "000" | Reject |

**Starting table (unsolved):**

| state | on 0 | on 1 |
|---|---|---|
| A (start) (accepting) | A | B |
| B | A | C |
| C | C | A |
| D | C | B |

Starting table fails: "11", "0101", "0110", "1001", "001100", "0", "10", "0111", "000".

**Solution table:**

| state | on 0 | on 1 |
|---|---|---|
| A (start) (accepting) | B | C |
| B | A | D |
| C | D | A |
| D | C | B |

## Optional: Contains 101 (Advanced stretch)

**Rule:** Accept every string that contains 101 anywhere.

**What it adds:** Overlapping patterns. After a partial match the machine must fall back to the right middle state (for example "1101" must still reach the accepting state), and the accepting state is sticky.

**Accepting state:** D. **Cells to change from the starting table:** 4 (A on 0: B -> A, A on 1: D -> B, B on 0: D -> C, D on 1: B -> D).

**Requirements:**

| input | expected |
|---|---|
| "101" | Accept |
| "0101" | Accept |
| "1101" | Accept |
| "1011" | Accept |
| "10101" | Accept |
| "" | Reject |
| "1" | Reject |
| "10" | Reject |
| "100" | Reject |
| "1001" | Reject |
| "0110" | Reject |
| "110" | Reject |

**Starting table (unsolved):**

| state | on 0 | on 1 |
|---|---|---|
| A (start) | B | D |
| B | D | B |
| C | A | D |
| D (accepting) | D | B |

Starting table fails: "101", "0101", "1101", "1011", "10101", "1", "10", "100", "0110", "110".

**Solution table:**

| state | on 0 | on 1 |
|---|---|---|
| A (start) | A | B |
| B | C | B |
| C | A | D |
| D (accepting) | D | D |

## Review against tier criteria

| Puzzle | Tier | States | Cells to change | Requirements | Trap or near-miss | Meets criteria |
|---|---|---|---|---|---|---|
| P1 Ends in 1 | Beginner | 2 | 2 | 8 | None needed | Yes |
| P2 At least one 1 | Beginner | 2 | 1 | 7 | None needed | Yes |
| P3 Find the Double 1 | Intermediate | 3 | 2 | 7 | One fix still fails "110" | Yes |
| P4 Even number of 1s | Intermediate | 2 | 2 | 9 | Start state accepts "" | Yes |
| P5 Even 0s and even 1s | Advanced | 4 | 4 | 14 | Even-length near-misses "01" and "10" must reject | Yes |
| Optional Contains 101 | Advanced (optional stretch) | 4 | 4 | 12 | Overlap: "1101" must accept | Yes |

## Team review

- Reviewed by Ryan (content author): [ ] date:
- Reviewed by Brian (progression): [ ] date:
- Agreement or requested changes:
