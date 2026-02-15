# Contributing Guidelines

## Branch Structure

Our repository follows a structured branching model to ensure stability and organization of code.

### 1. `main` Branch
- **Purpose**: The `main` branch holds the release versions of the project.
- **Access**: Direct pushes to the `main` branch are **not allowed**.
- **Merging**: Code can only be merged into `main` from `dev` after proper testing and review.
- **Release-Ready**: Only fully tested and approved code that is ready for release should be merged into `main`.

### 2. Personal Branch
- **Purpose**: The personal branch is for active development. 
- **Branching Policy**: Any new feature or testing work must be done in a dedicated branch created from each member's branch.
  - For each memeber's work, name the branch `[name]_branch` (e.g. `abc_branch`).
- **Pushing**: Code should be pushed to the corresponding feature or test and merged into `main` only after review and testing.

### 3. `report` Branch (optional)
- **Purpose**: The `report` branch is dedicated to documenting the development process, challenges, solutions, and overall progress after a release version is ready.
- **Report Process**:
  - After a release has been merged into `main`, create or update the `report` branch.
  - The report should provide a detailed account of the work that led to the release, including:
    - **Features Added**: Description of new features and their implementation.
    - **Bug Fixes**: Explanation of resolved issues, including the root cause and the fix applied.
    - **Testing Summary**: Outline the tests performed and their results.
    - **Lessons Learned**: Highlight challenges faced and how they were overcome, as well as improvements for future releases.
  - The report is a living document and can be updated as further reflections or insights emerge throughout the project lifecycle.

## Merging Guidelines

- **Approval**: Open a pull request from personal branch to `main` once your code is fully tested and stable. Contributors will review the code, and at least one must approve before the merge.
  
## Branch Protection Rules

- **Main**: Protected; direct pushes are disabled. All merges must go through a pull request and be reviewed.

## Additional Guidelines

- **Commit Messages**: Ensure commit messages are meaningful and describe the changes made.
- **Pull Requests**: When submitting a pull request, provide a detailed description of what the feature or fix involves and the testing done.