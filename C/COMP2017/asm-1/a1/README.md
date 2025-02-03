5 significant submissions
Submissions #7:
    git commit -m "searcher more details"
    Updated: more written on searcher and format both Python and C files. Also adding comments on Python file

Submissions #8:
    git commit -m "a bit change on searcher"
    Updated: checking testcase and finding problem that needs to modify

Submissions #18:
    git commit -m "modify searcher"
    Updated: first reach up to pass all testcases and added a collinear test for 3 float points

Submissions #30:
    git commit -m "final update for 3 types test"
    Updated: the final modfication for searcher and generator with comments, also the test for E2E modification

Sumbissions #31:
    git commit -m "delete useless files"
    Updated: delete some useless files from /tests

Tests explaination
In the self-writing testcase, I wrote testcase for Generator, Searcher, and E2E. Given that Generator's stdout contains randomly produced floating points, the majority of the tests are of type error and have a normal case constructed by controlling the rseed value. The stdin for E2E tests is quite similar to Generator, with the exception that the stdout for the two tests differs. Because Searcher can enter stdin thousands of times, an EOF is added to each.in file to cause it to terminate. Additionally, all tests stored in the test.sh file will be run automatically.