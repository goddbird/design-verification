# Traceability Matrix (Baseline)

## Status Key
- Planned: Requirement is defined but not implemented
- In Progress: Partial implementation or checking exists
- Done: Implemented, tested, and checked by coverage/assertion
- Blocked: Cannot close due to known dependency

## AXI VIP Traceability

| Req ID | Requirement | Verification Method | Main Test/Sequence | Checker/Coverage | Status | Notes |
|---|---|---|---|---|---|---|
| AXI-F01 | Basic write transaction is supported | Directed + scoreboard | axi_write_seq | axi_scoreboard | In Progress | Confirm reset and single-beat test coverage |
| AXI-F02 | Burst write behavior is correct | Random + directed | axi_write_seq burst cases | checker for beat counting | In Progress | WLAST and beat length alignment needed in report |
| AXI-F03 | Multiple outstanding writes are handled | Constrained-random stress | outstanding write sequence | monitor outstanding table + scoreboard | In Progress | Current model supports in-flight tracking |
| AXI-F04 | WLAST is asserted on final beat only | Assertion + directed | burst edge cases | axi_assertions | In Progress | Add assertion coverage reporting |
| AXI-F05 | Basic read transaction is supported | Directed + scoreboard | read sequence | scoreboard compare | Planned | Add deterministic read sanity test |
| AXI-F06 | Out-of-order response handling by ID | Constrained-random + checker | multi-ID stress sequence | ID-aware scoreboard/assertions | Planned | Listed as TODO in project notes |

## AHB VIP Traceability

| Req ID | Requirement | Verification Method | Main Test/Sequence | Checker/Coverage | Status | Notes |
|---|---|---|---|---|---|---|
| AHB-F01 | Basic write transaction is supported | Directed + scoreboard | AHB_write_seq | AHB_scoreboard | In Progress | Add fixed-seed smoke case |
| AHB-F02 | Basic read transaction is supported | Directed + scoreboard | AHB_read_seq | AHB_scoreboard | In Progress | Add data integrity summary in report |
| AHB-F03 | Burst type operation (FIXED/INCR/WRAP) | Constrained-random + coverpoints | burst scenario seq | burst-type coverpoint | In Progress | Mentioned in README feature table |
| AHB-F04 | Burst length handling is correct | Constrained-random + coverpoints | variable-length burst seq | burst-length coverpoint | In Progress | Add corner length bins |
| AHB-F05 | Transfer size handling is correct | Directed + random + coverpoints | transfer-size seq | transfer-size coverpoint | In Progress | Verify legal size/address combinations |
| AHB-F06 | Address alignment behavior is checked | Directed + negative tests | aligned/unaligned seq | alignment coverpoint + checks | Planned | Define expected behavior for illegal alignment |

## APB VIP Traceability

| Req ID | Requirement | Verification Method | Main Test/Sequence | Checker/Coverage | Status | Notes |
|---|---|---|---|---|---|---|
| APB-F01 | Basic write transaction is supported | Directed + scoreboard | APB_seq | APB_scoreboard | In Progress | Add smoke list entry |
| APB-F02 | Basic read transaction is supported | Directed + scoreboard | APB_read_seq | APB_scoreboard | In Progress | Add reset-to-read transition test |
| APB-F03 | Setup and access phase timing is correct | Directed + assertion | protocol timing seq | APB timing checks/assertions | Planned | Add PENABLE timing property |
| APB-F04 | Wait-state handling with PREADY is correct | Directed + random delays | wait-state seq | monitor checks + coverage | Planned | Add delay bins in coverage |
| APB-F05 | Error signaling with PSLVERR is checked | Negative directed tests | error injection seq | scoreboard + protocol checks | Planned | Define expected error response policy |

## Closure Checklist
- Each Req ID has at least one deterministic directed test.
- Each Req ID has at least one randomized or corner-case stimulus, if applicable.
- Each Req ID maps to checker, assertion, or scoreboard evidence.
- Each Req ID maps to at least one coverage item (functional and/or assertion coverage).
- Status changes to Done only after passing regression and coverage review.

## Change Log
- 2026-04-30: Initial baseline created.
