#!/bin/bash
# Runs merge-gate.sh against a table of commands. 0 = must allow, 2 = must block.
# Needs `gh` signed in. Usage: bash test-merge-gate.sh <org>/<repo> <green-pr-number>
# (exits 1 if any case fails)
HOOK="$(cd "$(dirname "$0")" && pwd)/merge-gate.sh"
REPO=${1:?usage: test-merge-gate.sh <org>/<repo> <green-pr>}
GREEN=${2:?usage: test-merge-gate.sh <org>/<repo> <green-pr>}
fail=0

run() { # expected-exit command label
  jq -n --arg c "$2" '{tool_input:{command:$c}}' | /bin/bash "$HOOK" >/dev/null 2>&1
  local got=$?
  [[ $got == "$1" ]] && echo "ok   $3" || { echo "FAIL (want $1, got $got): $3"; fail=1; }
}

M="gh pr"" merge"   # split so a hook reading this file's command line doesn't fire
run 0 "ls" "non-merge command"
run 0 "gh pr create --body \"It blocks \`$M\` unless green\"" "words inside a PR body"
run 0 $'cat > x <<EOF\nIt blocks `'"$M"$'` unless\nEOF' "words inside a heredoc"
run 0 "$M $GREEN -R $REPO --squash" "green PR"
run 0 "$M $GREEN --repo '$REPO' --squash" "green PR, quoted repo"
run 2 "$M 999999 -R $REPO --squash" "missing PR"
run 2 "git fetch && $M 999999 --repo $REPO" "merge after &&"
exit $fail
