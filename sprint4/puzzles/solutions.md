# Puzzle solutions

Same order as `difficulty_tiers.md`. Start state is A. `""` is the empty string. The starting table fails at least one row. The solution table passes every row.

## beginner_01

- Resource: res://sprint4/puzzles/beginner_01.tres
- Title: Ends in 1
- Tier: Beginner
- Starting failures: "11", "101", "10"

### Solution transitions

| state | on 0 | on 1 |
|---|---|---|
| A | A | B |
| B | A | B |

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

## beginner_02

- Resource: res://sprint4/puzzles/beginner_02.tres
- Title: At least one 1
- Tier: Beginner
- Starting failures: "10", "010"

### Solution transitions

| state | on 0 | on 1 |
|---|---|---|
| A | A | B |
| B | B | B |

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

## intermediate_01

- Resource: res://sprint4/puzzles/intermediate_01.tres
- Title: Find the Double 1
- Tier: Intermediate
- Starting failures: "11", "011", "110"

### Solution transitions

| state | on 0 | on 1 |
|---|---|---|
| A | A | B |
| B | A | C |
| C | C | C |

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

## intermediate_02

- Resource: res://sprint4/puzzles/intermediate_02.tres
- Title: Even number of 1s
- Tier: Intermediate
- Starting failures: "11", "101", "10", "010"

### Solution transitions

| state | on 0 | on 1 |
|---|---|---|
| A | A | B |
| B | B | A |

### Expected results

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

## advanced_01

- Resource: res://sprint4/puzzles/advanced_01.tres
- Title: Even 0s and even 1s
- Tier: Advanced
- Starting failures: "11", "0101", "0110", "1001", "001100", "0", "10", "0111", "000"

### Solution transitions

| state | on 0 | on 1 |
|---|---|---|
| A | B | C |
| B | A | D |
| C | D | A |
| D | C | B |

### Expected results

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

## advanced_02

- Resource: res://sprint4/puzzles/advanced_02.tres
- Title: Contains 101
- Tier: Advanced
- Starting failures: "101", "0101", "1101", "1011", "10101", "1", "10", "100", "0110", "110"

### Solution transitions

| state | on 0 | on 1 |
|---|---|---|
| A | A | B |
| B | C | B |
| C | A | D |
| D | D | D |

### Expected results

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
