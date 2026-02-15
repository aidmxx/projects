# Extreme Programming (XP) Summary

## Overview
Extreme Programming is a set of values, principles and practices for rapidly developing high-quality software that provides the highest value for the customer in the fastest way possible.
XP is the practice and pursuit of effective simplicity, as applied to software development. Moreover, it is a repeatable process for developing software, it is in fact a methodology, although a lightweight one.

## 12 Core Practices of XP

- **The Planning Game** - Business and development cooperate to produce the maximum business value as rapidly as possible.
- **Small Releases** - Start with the smallest useful feature set. Release early and often, adding a few features each time.
- **System Metaphor** - Each project has an organizing metaphor, which provides an easy to remember naming convention.
- **Simple Design** - Always use the simplest possible design that gets the job done. The requirements will change tomorrow, so only do what's needed to meet today's requirements.
- **Continuous Testing** - Before programmers add a feature, they write a test for it. When the suite runs, the job is done. Tests in XP come in two basic flavors.
- **Refactoring** - Refactor out any duplicate code generated in a coding session. You can do this with confidence that you didn't break anything because you have the tests.
- **Pair Programming** - All production code is written by two programmers sitting at one machine. Essentially, all code is reviewed as it is written.
- **Collective Code Ownership** - No single person "owns" a module. Any developer is expect to be able to work on any part of the codebase at any time.
- **Continuous Integration** - All changes are integrated into the codebase at least daily. The tests have to run 100% both before and after integration.
- **40-Hour Work Week** - Programmers go home on time. In crunch mode, up to one week of overtime is allowed. But multiple consecutive weeks of overtime are treated as a sign that something is very wrong with the process.
- **On-site Customer** - Development team has continuous access to a real live customer, that is, someone who will actually be using the system. For commercial software with lots of customers, a customer proxy (usually the product manager) is used instead.
- **Coding Standards** - Everyone codes to the same standards.

##  Brief outline of project's technical side
- **UserStories** - specify all the desirable features of the system as Stories
- **Iteration and IterationPlanning** - Within a release, pick the most valuable stories to work on for the next few weeks.
- **ReleasePlan and Release Scope** - Choose the smallest scope with the most immediate BusinessValue for each Release of the system, and put it into production as quickly as possible
- **StoryEstimates and LoadFactor** - Estimate each story, and at the end of an iteration will rate the estimates against calendar days. This tracks our progress in implementing stories
- **AcceptanceTests** - Write automated tests that demonstrate to the satisfaction that the code implementing that Story works.
- **ContinuousIntegration** - At the end of each Iteration produce a system where the features that are implemented are ready for production
- **UnitTests** - Write tests according to the code
- **Refactoring** - Continually evolve the design of the system -- adding flexibility where it is needed, removing complexity where it doesn't help, unifying duplicated code.


## Roles in XP

- **Coach** - Watches everything, sends obscure signals, makes sure the project continues to StayExtreme. Helps with anything. 
- **Tracker** - Checks progress weekly with programmers and take actions.
- **Customer** - Writes UserStories and specifies FunctionalTests. Sets priorities, explains stories, views CRC sessions.
- **Programmer** - Estimates stories, defines EngineeringTasks from stories, estimates how long stories and tasks will take, implements stories and UnitTests
- **Tester** - Implements and runs FunctionalTests.
- **Doomsayer** - Predict the risks and point out when.
- **Manager** - Schedules meeting and bring back useful information.

---

## References

[1]https://jera.com/techinfo/xpfaq

[2]https://wiki.c2.com/?ExtremeProgramming

[3]https://wiki.c2.com/?UserStories

[4]https://wiki.c2.com/?ExtremeRoles

[5]https://wiki.c2.com/?ExtremeProgrammingSummary

