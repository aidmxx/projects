# Extreme Programming (XP) – Summary

## 1. Overview

Extreme Programming (XP) is a set of values, principles, and practices for rapidly developing high-quality software that delivers maximum value to the customer in the shortest time possible [1].  
It is a **lightweight methodology**—not heavy in process overhead but repeatable and disciplined.

A typical XP project involves all programmers working together in a shared space (often around a large table) with short, fixed-length iteration cycles.

---

## 2. Iterations

- **Iteration length**: Typically 1–3 weeks, with the same duration for all iterations [1].
- **Planning meeting** (start of each iteration):
  - Team meets with the customer to identify features for that iteration.
  - Features are broken down into **engineering tasks**.
  - Developers sign up for tasks and estimate them, limited by their past throughput.
- **Development** (during the iteration):
  - Pair programming on all production code.
  - **Test-first approach**: no code is written without a failing test case first.
  - Developers write unit tests for classes/subsystems.
  - Customer provides functional/acceptance tests.
- **Delivery** (end of iteration):
  - Working system is delivered to the customer, fully functional and bug-free.
  - Cycle repeats with planning for the next iteration.

**Product release** is nearly a non-event, as the system is kept close to release-ready at all times.

---

## 3. XP Practices

XP promotes 12 key practices [1]:

1. The Planning Game
2. Small Releases
3. System Metaphor
4. Simple Design
5. Continuous Testing (TDD + Acceptance Testing)
6. Refactoring
7. Pair Programming
8. Collective Code Ownership
9. Continuous Integration
10. 40-Hour Work Week
11. On-site Customer
12. Coding Standards

---

## 4. XP in Our Project

- **Short weekly iterations** → frequent demos to the client.
- **Customer involvement** → matches the client’s focus on UI feedback.
- **Rotating leadership roles** → shared responsibility and skill development.
- **User stories** → guide feature design (e.g., drop-down filters, data downloads).

---

## 5. Role Allocation (Weeks 2–5)

| Week | Tracker | Manager | Customer Liaison | Programmer | Tester | Doomsayer | Software Researcher |
| ---- | ------- | ------- | ---------------- | ---------- | ------ | --------- | ------------------- |
| 2    | Xinyu   | Yilin   | Aaron            | All        | All    | Aiko      | All                 |
| 3    | Aiko    | Aaron   | Nanami           | All        | All    | Nanami    | Aaron, Fox          |
| 4    | Nanami  | Aiko    | Yilin            | All        | All    | Fox       | Xinyu, Aiko         |
| 5    | Fox     | Nanami  | Aiko             | All        | All    | Xinyu     | Yilin, Nanami       |

---

## 6. Role Descriptions

- **Leader** – Hosts meetings and ensures deliverables are submitted.
- **Customer Liaison** – Communicates with the client, drafts and sends emails.
- **Manager** – Records meetings and prepares meeting minutes.
- **Tracker** – Prepares the URS and monitors programmers’ progress.
- **Programmer** – Writes, tests, and maintains source code.
- **Tester** – Designs and executes tests to ensure quality.
- **Doomsayer** – Identifies potential risks and raises early warnings.
- **Software Researcher** – Investigates relevant tools, technologies, and methods.

---

## References

[1] John Brewer, _Extreme Programming FAQ_, Jera Design. Available at: https://jera.com/techinfo/xpfaq
