#!/usr/bin/env bash
# Run a multi-step conversation on the demo API in a clean session.
#
#   evals/run-chain.sh <chain> [model]
#
# model: a Claude model alias (default sonnet), or "codex" for the Codex CLI.
#
# Each step-N.md in evals/chains/<chain>/ is one user message. Step 2 and later
# continue the same session, so a chain can test a gate: step 1 must stop, and
# step 2 gives the approval. The state of the working tree is recorded after
# every step.
set -euo pipefail

chain="${1:?usage: $0 <chain> [model]}"
model="${2:-sonnet}"
root="$(cd "$(dirname "$0")/.." && pwd)"
dir="$root/evals/chains/$chain"
[[ -f "$dir/step-1.md" ]] || { echo "unknown chain: $chain" >&2; exit 2; }

work="$(mktemp -d)/notes-api"
cp -R "$root/evals/demo/notes-api" "$work"
rm -rf "$work/data" "$work/node_modules"
cd "$work"
git init -q -b main
git add -A
git -c user.name=eval -c user.email=eval@example.test commit -q -m "base"
git checkout -q -b "task/$chain"
# Claude Code reads project skills from .claude/skills, Codex from .agents/skills.
if [[ "$model" == codex* ]]; then skills_dir=".agents"; else skills_dir=".claude"; fi
mkdir -p "$skills_dir"
cp -R "$root/skills" "$skills_dir/skills"
echo "$skills_dir/" >> .git/info/exclude
session=""

results="$root/evals/results/${EVAL_ROUND:-latest}"
mkdir -p "$results"
n=1
while [[ -f "$dir/step-$n.md" ]]; do
  out="$results/$chain.$model.step-$n"
  if [[ "$model" == codex* ]]; then
    # Codex: the first step starts a saved session, later steps resume it by id.
    sandbox=(-c 'sandbox_mode="workspace-write"' -c sandbox_workspace_write.network_access=true)
    if [[ $n -eq 1 ]]; then
      codex exec --json "${sandbox[@]}" -o "$out.md" "$(cat "$dir/step-$n.md")" \
        < /dev/null > "$out.log" 2>&1 || echo "agent exited with an error" >&2
      session="$(grep -o '"thread_id":"[^"]*"' "$out.log" | head -1 | cut -d'"' -f4)"
      [[ -n "$session" ]] || { echo "no Codex session id found" >&2; exit 1; }
    else
      codex exec resume "${sandbox[@]}" -o "$out.md" "$session" "$(cat "$dir/step-$n.md")" \
        < /dev/null > "$out.log" 2>&1 || echo "agent exited with an error" >&2
    fi
    echo "agent: codex, step $n"
  else
  continue_flag=()
  [[ $n -gt 1 ]] && continue_flag=(--continue)
  claude -p "$(cat "$dir/step-$n.md")" ${continue_flag[@]+"${continue_flag[@]}"} \
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
  {
    echo "## Working tree after step $n"
    echo '```'
    git status --short
    git log --oneline
    echo '```'
  } > "$out.tree.md"
  n=$((n + 1))
done
echo "work dir: $work"
