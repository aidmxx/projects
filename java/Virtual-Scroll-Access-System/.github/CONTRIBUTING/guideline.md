# Contributing Guidelines

## Branch Structure

Our repository follows a structured branching model to ensure stability and organization of code.

### 1. `main` Branch
- **Purpose**: The `main` branch holds the release versions of the project.
- **Access**: Direct pushes to the `main` branch are **not allowed**.
- **Merging**: Code can only be merged into `main` from `dev` after proper testing and review.
- **Release-Ready**: Only fully tested and approved code that is ready for release should be merged into `main`.

### 2. `dev` Branch
- **Purpose**: The `dev` branch is for active development. 
- **Branching Policy**: Any new feature or testing work must be done in a dedicated branch created from `dev`.
  - For features, name the branch `feature-[feature-name]` (e.g. `feature-login`).
  - For testing, name the branch `test-[testing-name]` (e.g. `test-login-form`).
- **Pushing**: Code should be pushed to the corresponding feature or test branch and merged into `dev` only after review and testing.

### 3. `report` Branch

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

- **Testing**: Before merging into `dev`, ensure the code is tested thoroughly.
- **Reviews**: Merges from `dev` to `main` require approval from **at least two other contributors**.
- **Approval**: Open a pull request from `dev` to `main` once your code is fully tested and stable. Contributors will review the code, and at least two must approve before the merge.
  
## Branch Protection Rules

- **Main**: Protected; direct pushes are disabled. All merges must go through a pull request and be reviewed.
- **Dev**: Always branch from `dev` for new work and submit a pull request for review before merging back into `dev`.

## Additional Guidelines

- **Commit Messages**: Ensure commit messages are meaningful and describe the changes made.
- **Pull Requests**: When submitting a pull request, provide a detailed description of what the feature or fix involves and the testing done.