# Evidence: `save-layout-change` only counts from maintainers (#128)

**Issue:** anyone who can label a PR (triage access or higher) could add `save-layout-change` and turn a failing Save layout check into a pass.
**Change:** the Save layout job now asks `.github/scripts/label_check.py` who last added the label and honours it only for write, maintain or admin access. The repository owner counts as admin without an API call. If the lookup fails, the label is ignored and the job summary says why (fail closed).

Collected on 2026-10-14 on branch `ci-label-gate-check`.

## Repository state at the time

- Collaborators: `technicks89` (admin) only.
- `main` branch protection: 9 required checks (Build, Warnings, Tracked files, Smoke test, ROM changes, Save layout, Lint workflows, Lint Python, Scenario tests); no required reviews; not enforced for admins.
- Label events don't trigger CI; a re-run needs write access (unchanged).

## Unit tests (`test_ci_scripts.LabelCheckTest`)

```
check_warnings.py
compare_builds.py
label_check.py
__pycache__
scenario_tests.py
smoke_test.py
test_ci_scripts.py
test_data_tables.py
upstream_watch.py
test_last_labeler_decides (test_ci_scripts.LabelCheckTest.test_last_labeler_decides) ... ok
test_maintainer_label_counts (test_ci_scripts.LabelCheckTest.test_maintainer_label_counts) ... ok
test_other_labels_are_ignored (test_ci_scripts.LabelCheckTest.test_other_labels_are_ignored) ... ok
test_removed_label_does_not_count (test_ci_scripts.LabelCheckTest.test_removed_label_does_not_count) ... ok
test_triage_label_is_ignored (test_ci_scripts.LabelCheckTest.test_triage_label_is_ignored) ... ok
Ran 5 tests in 0.000s
OK
```

The full suite (`python3 -m unittest discover -s .github/scripts -p 'test_*.py'`) runs 23 tests, all passing, and `ruff check --config .github/ruff.toml .github/scripts` reports no problems.

## What the check reports per scenario

`label_check.check()` with simulated label history and access levels:

| Scenario | Result | Message in the job summary |
|---|---|---|
| added by a write collaborator | counts | The `save-layout-change` label was added by @dev (write access). |
| added by a triage collaborator | ignored | The `save-layout-change` label was added by @helper, who has triage access; only someone who can push to the repository can relax this check. |
| added by the owner, removed, re-added by triage | ignored | The `save-layout-change` label was added by @helper, who has triage access; only someone who can push to the repository can relax this check. |
| added then removed | ignored | The `save-layout-change` label is not on this PR. |

## Live run against the GitHub API

PR #104 has the `expect-identical-rom` label, added by `technicks89` (label events: `expect-identical-rom` by technicks89 at 2026-10-14T13:38:05Z). Run with the maintainer's own `gh` login:

```
$ PR_NUMBER=104 label_check.py expect-identical-rom
The `expect-identical-rom` label was added by @technicks89 (admin access).
exit 0
$ PR_NUMBER=104 label_check.py save-layout-change
The `save-layout-change` label is not on this PR.
exit 1
```

## Not covered locally

- The collaborator-permission lookup under CI's own `GITHUB_TOKEN`, for someone other than the owner. If GitHub refuses it, the label is ignored and the summary shows the error; the owner's labels never need the lookup. The first PR run of this branch exercises the job itself.
