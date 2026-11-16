---
name: house-rules
description: Build a team's review rules from its own history. Reads the review comments on merged pull requests, groups the ones that ask for the same thing, and proposes them as rules that the review skill applies. Use when the user says "learn our review rules", "build house rules", "what do our reviewers ask for", or to refresh the rules after a few months.
---

# House rules

Every team has rules that are written nowhere. They live in review comments:
the same request, made again and again, to different people.

Collect those comments, find the ones that repeat, and write them down as
rules. Then a change can meet the team's standard before a person has to ask.

## What you need

- A repo with merged pull requests and review comments, and a tool that can
  read them. For GitHub that is the `gh` command, used read-only.
- If there is no review history, the result is `could-not-run`. Do not invent
  rules from general good practice.

## Steps

1. **Collect.** Read the review comments of merged pull requests. Start with
   the last 200, or since the date in `.flow/house-rules.md` on a refresh. Use
   a script for this, not your own reading: it is cheaper and it does not skip.
   Keep the script and its output in a temporary directory.

2. **Clean.** Drop comments from bots, approvals, thanks, and one-word replies.
   Keep the comments that ask for a change.

3. **Group.** Put together the comments that ask for the same thing, even in
   different words.

4. **Keep what repeats.** A group becomes a rule when it has three or more
   comments on at least two different pull requests. One comment is an opinion.

5. **Write each rule** with:
   - the rule, as one instruction
   - the reason, in the team's own terms
   - where it applies: the folders or file types
   - the count: how many comments, on how many pull requests
   - one short code example of the wrong and the right form, written by you

6. **Propose.** Show the change to `.flow/house-rules.md` as a diff. The user
   accepts or rejects each rule. Write only what the user accepts.

## What must never go in the file

This file is committed and may become public. It holds rules, not people.

- No name, handle, or email of a reviewer or an author.
- No quote of a comment. Rewrite the rule in your own words.
- No link to a pull request, no ticket id.
- No code copied from the repo. Write a small new example.
- No customer name and no real data.

Counts are fine. "14 comments on 9 pull requests" tells the reader how strong
the rule is, and says nothing about a person.

## Rules for the rules

- A rule must be checkable on a diff. "Write clean code" is not a rule.
  "Return 404, not 403, when the resource belongs to another user" is a rule.
- Keep the file short: 30 rules at most. When it is full, a new rule replaces
  the weakest one.
- On a refresh, mark a rule `stale` when no comment asked for it in the new
  period. Propose to remove it. A linter may enforce it now.
- When two groups conflict, do not pick one. Show both to the user.

## Output

`.flow/house-rules.md`:

```
# House rules
Built from <n> review comments on <n> merged pull requests, up to <date>.

## Access
1. Return 404 when a resource belongs to another user.
   Why: a 403 tells the caller that the id exists.
   Applies to: src/routes/**
   Seen: 14 comments on 9 pull requests.
   Wrong: `if (note.owner !== user.id) return forbidden()`
   Right: `if (note.owner !== user.id) return notFound()`
```

Report: how many comments you read, how many groups you found, how many rules
you proposed, and how many the user accepted.
