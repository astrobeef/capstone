# Puzzle checks: first_puzzle

Draft design (verify each trace by hand before relying on it).

**Goal text:** Build a machine that accepts every string containing two 1s in a row ("11") and rejects every other string.

**Fixed settings:** states A, B, C; inputs 0 and 1; start state A; accepting state C.

**Requirements (index-aligned arrays):**

| index | test_inputs | expected_acceptance |
|---|---|---|
| 0 | "11" | true |
| 1 | "011" | true |
| 2 | "110" | true |
| 3 | "" | false |
| 4 | "1" | false |
| 5 | "101" | false |
| 6 | "0101" | false |

### Initial table (must fail at least one requirement)

| state | on 0 | on 1 |
|---|---|---|
| A | A | B |
| B | A | A |
| C | A | C |

| index | input | expected | visited states | final | actual | pass |
|---|---|---|---|---|---|---|
| 0 | "11" | accept | A → B → A | A | reject | FAIL |
| 1 | "011" | accept | A → A → B → A | A | reject | FAIL |
| 2 | "110" | accept | A → B → A → A | A | reject | FAIL |
| 3 | "" | reject | A | A | reject | PASS |
| 4 | "1" | reject | A → B | B | reject | PASS |
| 5 | "101" | reject | A → B → A → B | B | reject | PASS |
| 6 | "0101" | reject | A → A → B → A → B | B | reject | PASS |

Failures: 3

### Documented solution (must pass all)

| state | on 0 | on 1 |
|---|---|---|
| A | A | B |
| B | A | C |
| C | C | C |

| index | input | expected | visited states | final | actual | pass |
|---|---|---|---|---|---|---|
| 0 | "11" | accept | A → B → C | C | accept | PASS |
| 1 | "011" | accept | A → A → B → C | C | accept | PASS |
| 2 | "110" | accept | A → B → C → C | C | accept | PASS |
| 3 | "" | reject | A | A | reject | PASS |
| 4 | "1" | reject | A → B | B | reject | PASS |
| 5 | "101" | reject | A → B → A → B | B | reject | PASS |
| 6 | "0101" | reject | A → A → B → A → B | B | reject | PASS |

Failures: 0

### Known incorrect configuration (must fail at least one)

| state | on 0 | on 1 |
|---|---|---|
| A | A | B |
| B | A | B |
| C | C | C |

| index | input | expected | visited states | final | actual | pass |
|---|---|---|---|---|---|---|
| 0 | "11" | accept | A → B → B | B | reject | FAIL |
| 1 | "011" | accept | A → A → B → B | B | reject | FAIL |
| 2 | "110" | accept | A → B → B → A | A | reject | FAIL |
| 3 | "" | reject | A | A | reject | PASS |
| 4 | "1" | reject | A → B | B | reject | PASS |
| 5 | "101" | reject | A → B → A → B | B | reject | PASS |
| 6 | "0101" | reject | A → A → B → A → B | B | reject | PASS |

Failures: 3

**Changes from initial to solution:** B on 1: A → C, and C on 0: A → C (2 destination changes).
