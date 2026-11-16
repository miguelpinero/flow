#!/usr/bin/env bash
# Run one flow skill on one scenario in a clean, unattended session.
#
#   evals/run.sh <scenario> <skill> [model]
#
# model: a Claude model alias (default sonnet), or "codex" / "codex:<model>"
# to run the same scenario in the Codex CLI.
#
# It copies the demo API to a temporary repo, applies the scenario's change on a
# branch, installs the skills, and runs the agent with no user settings. The
# report lands in evals/results/. Compare it with the scenario's expected.md.
set -euo pipefail

scenario="${1:?usage: $0 <scenario> <skill> [model]}"
skill="${2:?usage: $0 <scenario> <skill> [model]}"
model="${3:-sonnet}"

root="$(cd "$(dirname "$0")/.." && pwd)"
dir="$root/evals/scenarios/$scenario"
[[ -f "$dir/change.patch" ]] || { echo "unknown scenario: $scenario" >&2; exit 2; }
[[ -d "$root/skills/$skill" ]] || { echo "unknown skill: $skill" >&2; exit 2; }

work="$(mktemp -d)/notes-api"
cp -R "$root/evals/demo/notes-api" "$work"
rm -rf "$work/data" "$work/node_modules"
cd "$work"
git init -q -b main
git add -A
git -c user.name=eval -c user.email=eval@example.test commit -q -m "base"
git checkout -q -b "change/$scenario"
git apply "$dir/change.patch"
git add -A
git -c user.name=eval -c user.email=eval@example.test commit -q -m "change"
# Claude Code reads project skills from .claude/skills, Codex from .agents/skills.
if [[ "$model" == codex* ]]; then skills_dir=".agents"; else skills_dir=".claude"; fi
mkdir -p "$skills_dir"
cp -R "$root/skills" "$skills_dir/skills"
echo "$skills_dir/" >> .git/info/exclude

prompt="Use the $skill skill on this branch. The base branch is main.
The change for the task below is already implemented and committed on this branch.

$(cat "$dir/task.md")

You run unattended. Nobody can answer a question, so do not wait for one.
You may start the dev server yourself on a free port. Stop it when you finish.
Run to the final report and print the full report as your last message."

results="$root/evals/results/${EVAL_ROUND:-latest}"
out="$results/$scenario.$skill.$model"
mkdir -p "$results"
if [[ "$model" == codex* ]]; then
  # "codex" uses the default Codex model, "codex:<name>" picks one.
  codex_model=()
  [[ "$model" == codex:* ]] && codex_model=(-m "${model#codex:}")
  # The sandbox allows writes in the work folder and local network, so the
  # agent can start the demo server and call it. The user's own Codex
  # instructions file still loads: Codex has no flag to skip it.
  codex exec --ephemeral -s workspace-write \
    -c sandbox_workspace_write.network_access=true \
    ${codex_model[@]+"${codex_model[@]}"} \
    -o "$out.md" "$prompt" < /dev/null > "$out.log" 2>&1 || echo "agent exited with an error" >&2
  echo "agent: codex"
else
claude -p "$prompt" \
  --model "$model" \
  --setting-sources project \
  --strict-mcp-config \
  --permission-mode acceptEdits \
  --allowedTools Bash Read Edit Write Glob Grep Skill Agent \
  --output-format json < /dev/null > "$out.json" || echo "agent exited with an error" >&2

python3 - "$out.json" "$out.md" <<'PY'
import json, sys
data = json.load(open(sys.argv[1]))
open(sys.argv[2], "w").write(data.get("result") or "(no result)")
print("turns:", data.get("num_turns"), "| cost USD:", round(data.get("total_cost_usd") or 0, 2),
      "| seconds:", round((data.get("duration_ms") or 0) / 1000))
PY
fi
git -C "$work" status --short | sed 's/^/left in tree: /'
echo "report: $out.md"
echo "work dir: $work"
