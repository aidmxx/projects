# Extreme Programming (XP) Summary
## Overview
Extreme Programming (XP) is an agile software development method aimed at delivering high-quality software quickly and maximizing customer value. It uses short development iterations (typically 1 to 3 weeks) to release working software frequently and incorporate feedback. Teams practice continuous communication and adapt flexibly to changing requirements. XP is called “extreme” because it pushes known best practices to the extreme to enhance the quality of outcomes. 

## Core Idea
In XP, four activities are particularly important: coding (to produce working software), testing (to verify that the code runs as expected), listening (to understand the customer's true needs), and designing (to continuously optimize the system structure based on feedback).

## Practices

XP translates its values into a set of concrete practices. There are 12 primary practices in Extreme Programming, each reinforcing the others:

- Planning Game – A practice of shared planning where business (the customer) and development collaborate on what to implement next. The customer writes desired features as user stories, developers estimate each story, and then the customer prioritizes them and plans releases based on value and effort.
- Small Releases – Deliver small, functional pieces of the software early and often. Start with the simplest useful feature set, then add a few new features with each frequent release.
- System Metaphor – Use a simple shared metaphor or analogy for the system’s design. This metaphor guides naming and design, helping the team conceptualize the architecture with easy-to-remember terminology.
- Simple Design – Always implement the simplest design that meets the current requirements. Avoid over-engineering since requirements will evolve; build only what’s needed to solve today’s problem.
- Continuous Testing – Write tests continuously. Developers practice Test-Driven Development (TDD) by writing automated unit tests for each new piece of functionality before coding it. The customer (or tester) defines acceptance tests to validate that features work as expected at the system level. With a comprehensive test suite, the team can add or change code confidently, since failing tests will catch regressions.
- Refactoring – Continuously refactor the code to improve its structure and remove duplication. By refining code design in small steps and relying on tests to ensure behavior stays correct, the codebase is kept clean and maintainable.

## User Stories

In XP’s planning process, requirements are captured as user stories. A user story is a short narrative told from the end-user’s perspective – essentially a scenario describing something the user needs the software to do. Good user stories have a few key attributes:

- Testable – The story can be used to create clear, automated tests that verify its functionality.
- Progress – Completing the story delivers visible progress; the customer agrees it brings the product closer to the goal.
- Bite-sized – It is small enough to be completed within a single iteration (typically a few programming tasks).
- Estimable – The development team can estimate the effort required to implement the story with reasonable accuracy.

## Roles
- Coach – The Coach mentors the team in XP process and practices.
- Developer (Programmer) – Developers estimate the effort for stories and turn them into working software.
- Tracker – The Tracker monitors the team’s progress and the accuracy of estimates.
- Tester – The Tester focuses on testing and quality assurance at the acceptance level.
- Manager – The Manager coordinates the overall project logistics.
- Doomsayer – This is an informal XP role for risk management.

## References
[1] https://jera.com/techinfo/xpfaq
[2] http://www.extremeprogramming.org/
[3] http://wiki.c2.com/?ExtremeProgramming
[4] http://wiki.c2.com/?UserStory
[5] http://wiki.c2.com/?ExtremeRoles