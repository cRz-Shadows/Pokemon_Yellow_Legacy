#!/usr/bin/env python3
"""Check that a PR label which relaxes a CI check was applied by a maintainer.

The save-layout-change label turns a failing save-layout check into a pass, so
it only counts when the person who last added it can push to the repository
(write, maintain or admin). Anyone with triage access can label a PR but can't
merge, so a label they add is ignored (issue #128).

Usage: label_check.py LABEL
Environment:
  GH_TOKEN           token for the gh CLI (read access is enough)
  GITHUB_REPOSITORY  e.g. technicks89/Pokemon_Yellow_Legacy
  PR_NUMBER          the pull request

Exits 0 if the label is on the PR and was added by a maintainer, 1 otherwise.
The reason is printed (for the step summary).
"""

import json
import os
import subprocess
import sys

MAINTAINER_PERMISSIONS = {'admin', 'maintain', 'write'}


def gh(*args):
    result = subprocess.run(['gh', *args], capture_output=True, text=True)
    if result.returncode:
        raise RuntimeError(f'gh {" ".join(args)} failed: {result.stderr.strip()}')
    return result.stdout


def last_labeler(events, label):
    """Login of whoever added `label` most recently, or None if it isn't on the PR now."""
    labeler = None
    for e in events:
        if (e.get('label') or {}).get('name') != label:
            continue
        if e.get('event') == 'labeled':
            labeler = (e.get('actor') or {}).get('login')
        elif e.get('event') == 'unlabeled':
            labeler = None
    return labeler


def check(label, events, permission_of):
    """(allowed, reason). permission_of(login) returns the user's permission
    (admin, maintain, write, triage, read or none)."""
    who = last_labeler(events, label)
    if who is None:
        return False, f'The `{label}` label is not on this PR.'
    perm = permission_of(who)
    if perm in MAINTAINER_PERMISSIONS:
        return True, f'The `{label}` label was added by @{who} ({perm} access).'
    return False, (f'The `{label}` label was added by @{who}, who has {perm} access; '
                   'only someone who can push to the repository can relax this check.')


def main():
    label = sys.argv[1]
    repo, pr = os.environ['GITHUB_REPOSITORY'], os.environ['PR_NUMBER']
    try:
        events = [e for page in json.loads(gh('api', '--paginate', '--slurp', f'repos/{repo}/issues/{pr}/events'))
                  for e in page]
        owner = repo.split('/')[0]

        def permission_of(login):
            if login == owner:          # the owner of a personal repository is always an admin
                return 'admin'
            return json.loads(gh('api', f'repos/{repo}/collaborators/{login}/permission'))['permission']
        allowed, reason = check(label, events, permission_of)
    except (RuntimeError, KeyError, ValueError) as e:
        allowed, reason = False, f'Could not check who added the `{label}` label, so it is ignored: {e}'
    print(reason)
    sys.exit(0 if allowed else 1)


if __name__ == '__main__':
    main()
