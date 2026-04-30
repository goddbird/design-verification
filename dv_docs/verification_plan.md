# Verification Plan (Baseline)

## 1. Document Control
- Version: v0.1
- Date: 2026-04-30
- Repository: design-verification
- Owner: TBD
- Reviewers: TBD

## 2. Purpose
This document defines the verification strategy, scope, and closure criteria for protocol VIP projects in this repository.

## 3. Scope
In scope:
- 4_AXI_VIP
- 5_AHB_VIP
- 6_APB_VIP

Out of scope (for this baseline):
- Performance benchmarking beyond functional pass/fail
- Full SoC-level integration
- Gate-level timing verification

## 4. Verification Objectives
- Verify protocol-compliant stimulus generation in each VIP environment.
- Verify monitor and scoreboard data consistency.
- Verify key protocol rules with assertions where available.
- Achieve measurable closure using test pass rate and coverage metrics.

## 5. Testbench Architecture
Common structure target:
- Interface
- Transaction
- Sequence and virtual sequence
- Driver and monitor
- Agent and environment
- Scoreboard
- Top testbench

Current implementation:
- AXI: UVM testbench with checker and scoreboard
- AHB: UVM testbench with scoreboard
- APB: UVM testbench with scoreboard

## 6. Feature List by Project

### 6.1 AXI (4_AXI_VIP)
Feature IDs:
- AXI-F01: Basic write transaction
- AXI-F02: Burst write behavior
- AXI-F03: Outstanding write requests
- AXI-F04: WLAST correctness
- AXI-F05: Basic read transaction
- AXI-F06: Out-of-order return handling (planned)

### 6.2 AHB (5_AHB_VIP)
Feature IDs:
- AHB-F01: Basic write transaction
- AHB-F02: Basic read transaction
- AHB-F03: Burst type handling (FIXED/INCR/WRAP)
- AHB-F04: Burst length handling
- AHB-F05: Transfer size handling
- AHB-F06: Address alignment handling

### 6.3 APB (6_APB_VIP)
Feature IDs:
- APB-F01: Basic write transaction
- APB-F02: Basic read transaction
- APB-F03: Setup/Access two-phase timing
- APB-F04: Ready wait-state handling
- APB-F05: Error response handling (PSLVERR)

## 7. Verification Methods
- Directed tests for protocol bring-up and sanity
- Constrained-random sequences for transaction diversity
- Scoreboard checking for data correctness
- Assertions for critical protocol properties
- Functional coverage for feature closure

## 8. Coverage Plan
Target metrics (baseline):
- Test pass rate: 100% in smoke regression
- Functional coverage: >= 90% for in-scope coverpoints
- Assertion pass rate: 100% (no assertion failures)

Coverage categories:
- Protocol operation mode coverage
- Burst and transfer shape coverage
- Error and corner-case coverage
- Cross coverage where meaningful

## 9. Regression Strategy
Regression levels:
- Smoke: Basic write/read per protocol
- Nightly: Randomized sequences and corner cases
- Weekly: Extended stress and negative testing

Each regression run should archive:
- Seed list
- Test list
- Pass/fail summary
- Failure signature
- Coverage summary

## 10. Entry and Exit Criteria
Entry criteria:
- DUT compiles cleanly
- Testbench compiles cleanly
- Smoke tests are available

Exit criteria:
- All planned features mapped to tests and coverage
- No open critical bugs
- Coverage targets reached or justified exclusions documented
- Regression stability confirmed for at least 3 consecutive runs

## 11. Risks and Mitigations
- Risk: Incomplete ID return path in AXI model
  - Mitigation: Add explicit ID return-path checks and related assertions
- Risk: Coverage holes hidden by weak constraints
  - Mitigation: Add targeted constraints and directed corner tests
- Risk: Non-reproducible failures
  - Mitigation: Save seeds and command lines for all regressions

## 12. Deliverables
- Verification Plan
- Traceability Matrix
- Regression report
- Coverage report
- Known issue list

## 13. Open Items
- Define owner for each feature ID
- Finalize out-of-order AXI requirement details
- Add formal closure linkage for reusable assertions
