# prompt-challenger

Claude Code plugin that challenges a prompt **before** Claude executes it: finds ambiguities, asks only the blocking questions (with a proposed default each), then proposes a sharper prompt.

Two parts, installed together:

- **Skill** `/prompt-challenger`: run it manually on any prompt.
- **Hook** `UserPromptSubmit`: injects the same process on every non-trivial prompt, so Claude challenges it on its own.

## Install

```
/plugin marketplace add fridanco/prompt-challenger
/plugin install prompt-challenger@prompt-challenger
```

Requires `jq` (the hook does nothing without it).

## Hook behavior

Skipped when the prompt:

- starts with `/` (slash command) or `!` (shell line)
- starts with `go:` (bypass, case-insensitive)
- has fewer than 6 words (`MIN_WORDS` in `scripts/prompt-challenger.sh`)

The hook only adds context. Claude does the challenging, so it can read the repo to answer its own questions. Cost: about 1.2k tokens per challenged prompt.

## Disable only the hook

Keep the skill, drop the hook: delete `hooks/hooks.json` from your local plugin copy, or disable the plugin and copy `skills/prompt-challenger/` into `~/.claude/skills/`.
