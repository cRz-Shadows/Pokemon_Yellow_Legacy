#!/usr/bin/env python3
"""Open or update an issue when the upstream repository has commits the fork
doesn't have.

The issue (label "upstream-sync") lists the upstream commits missing from the
fork's main branch. It records the upstream head it was written for, so:
- if upstream hasn't moved since the last issue, nothing happens, even if that
  issue was closed (closing it means "seen, not merging these");
- if upstream has new commits, the open issue is updated (with a comment), or a
  new issue is opened if the last one was closed.

Environment:
  GH_TOKEN    token for the gh CLI (issues: write on the fork)
  REPO        the fork, e.g. technicks89/Pokemon_Yellow_Legacy
  UPSTREAM    the upstream repository, e.g. cRz-Shadows/Pokemon_Yellow_Legacy
  DRY_RUN=1   print what would happen instead of changing issues
"""

import json
import os
import re
import subprocess
import sys

LABEL = 'upstream-sync'
MARKER = re.compile(r'<!-- upstream-head: ([0-9a-f]{40}) -->')


def gh(*args, data=None):
    result = subprocess.run(['gh', *args], input=data, capture_output=True, text=True)
    if result.returncode:
        sys.exit(f'gh {" ".join(args)} failed:\n{result.stderr}')
    return result.stdout


def gh_json(*args):
    return json.loads(gh(*args))


def main():
    repo, upstream = os.environ['REPO'], os.environ['UPSTREAM']
    dry_run = os.environ.get('DRY_RUN') == '1'
    up_owner = upstream.split('/')[0]
    up_branch = gh_json('api', f'repos/{upstream}')['default_branch']
    fork_branch = gh_json('api', f'repos/{repo}')['default_branch']

    # Commits on upstream's branch that the fork's branch doesn't contain
    compare = gh_json('api', f'repos/{repo}/compare/{fork_branch}...{up_owner}:{up_branch}')
    missing = compare['commits']
    up_head = gh_json('api', f'repos/{upstream}/commits/{up_branch}')['sha']
    print(f'{upstream}@{up_branch} head {up_head[:7]}: {len(missing)} commit(s) not in {repo}@{fork_branch}')

    issues = gh_json('issue', 'list', '-R', repo, '--label', LABEL, '--state', 'all',
                     '--limit', '20', '--json', 'number,state,body')
    latest = max(issues, key=lambda i: i['number']) if issues else None
    latest_head = None
    if latest:
        m = MARKER.search(latest['body'] or '')
        latest_head = m[1] if m else None

    if not missing:
        print('Up to date with upstream.')
        if latest and latest['state'] == 'OPEN':
            act(dry_run, f'close #{latest["number"]}', 'issue', 'close', str(latest['number']), '-R', repo,
                '--comment', f'The fork now contains everything up to upstream {up_head[:7]}. Closing.')
        return
    if latest_head == up_head:
        print(f'#{latest["number"]} ({latest["state"].lower()}) already covers upstream {up_head[:7]}; '
              'nothing to do.')
        return

    lines = [
        f'Upstream [{upstream}](https://github.com/{upstream}) has **{len(missing)}** commit(s) on '
        f'`{up_branch}` that this fork\'s `{fork_branch}` doesn\'t have:',
        '',
        '| Commit | Date | Author | Message |',
        '|---|---|---|---|',
    ]
    for c in missing[-50:]:
        message = c['commit']['message'].split('\n')[0].replace('|', '\\|')
        author = (c.get('author') or {}).get('login') or c['commit']['author']['name']
        url = f'https://github.com/{upstream}/commit/{c["sha"]}'
        lines.append(f'| [`{c["sha"][:7]}`]({url}) | {c["commit"]["author"]["date"][:10]} '
                     f'| {author} | {message} |')
    if len(missing) > 50:
        lines.append(f'| … | | | and {len(missing) - 50} older commits |')
    lines += [
        '',
        f'[Compare on GitHub](https://github.com/{repo}/compare/{fork_branch}...{up_owner}:{up_branch})',
        '',
        'To bring them in, merge or cherry-pick on a new branch and open a PR (CI checks the result). '
        'Close this issue if you don\'t want them. It won\'t be reopened until upstream has new commits.',
        '',
        f'<!-- upstream-head: {up_head} -->',
    ]
    body = '\n'.join(lines)

    if latest and latest['state'] == 'OPEN':
        n = str(latest['number'])
        act(dry_run, f'update #{n}', 'issue', 'edit', n, '-R', repo, '--body-file', '-', data=body)
        act(dry_run, f'comment on #{n}', 'issue', 'comment', n, '-R', repo,
            '--body', f'Upstream has new commits (now at {up_head[:7]}); the list above is updated.')
    else:
        act(dry_run, 'open a new issue', 'issue', 'create', '-R', repo, '--label', LABEL,
            '--title', f'Upstream has {len(missing)} new commit(s)', '--body-file', '-', data=body)
    if dry_run:
        print('--- issue body ---')
        print(body)


def act(dry_run, what, *args, data=None):
    if dry_run:
        print(f'[dry run] would {what}')
        return
    print(gh(*args, data=data).strip() or what)


if __name__ == '__main__':
    main()
