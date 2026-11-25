#!/usr/bin/env bash
# UserPromptSubmit hook: injects the prompt-challenger skill as context.
# Skips: slash commands, "!" shell lines, "go:" bypass, prompts under MIN_WORDS words.
# Single source of truth: ../skills/prompt-challenger/SKILL.md

MIN_WORDS=6
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL="$DIR/../skills/prompt-challenger/SKILL.md"

command -v jq >/dev/null 2>&1 || exit 0
[ -r "$SKILL" ] || exit 0

prompt=$(jq -r '.prompt // empty' 2>/dev/null)
[ -n "$prompt" ] || exit 0

trimmed="${prompt#"${prompt%%[![:space:]]*}"}"

case "$trimmed" in
  /*|\!*) exit 0 ;;
esac

lower=$(printf '%s' "$trimmed" | tr '[:upper:]' '[:lower:]')
case "$lower" in
  go:*) exit 0 ;;
esac

words=$(printf '%s' "$trimmed" | wc -w | tr -d ' ')
[ "$words" -ge "$MIN_WORDS" ] || exit 0

# Skill body without the YAML frontmatter
body=$(awk 'BEGIN{n=0} /^---[[:space:]]*$/ && n<2 {n++; next} n>=2' "$SKILL")

ctx="[prompt-challenger hook] Before doing anything, apply the gatekeeper process below to the user's latest prompt. If it is clear, trivial, or already clarified earlier in this conversation, print nothing about the check and just do the task as if this hook did not exist. Speak up only if something is wrong: then follow the output format and wait for answers. The user can bypass this by starting a prompt with 'go:'.

$body"

jq -n --arg ctx "$ctx" '{hookSpecificOutput: {hookEventName: "UserPromptSubmit", additionalContext: $ctx}}'
