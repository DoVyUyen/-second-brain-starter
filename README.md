# Second Brain Starter

A personal, persistent memory system for working with Claude Code. One
command scaffolds a `~/brain` folder that Claude reads **automatically at the
start of every session, in every project** — so Claude remembers who you are,
what you're working on, and where you left off.

This repo is the *scaffolding only*. Your brain content
stays on your machine (and in your own **private** backup repo if you want
one). **Never commit your personal brain content to a shared repo.**

## What you get

```
~/brain/
  CLAUDE.md              ← rules Claude follows when working in the brain
  brain/
    index.md             ← who you are, active projects (Claude reads first)
    log.md               ← session-by-session log (via /wrap-up)
    topics/              ← one concept per file
  work/active/           ← one file per active project = where sessions resume
  decisions/             ← immutable decision records
  .claude/commands/
    standup.md           ← /standup — morning context load
    dump.md              ← /dump — file notes fast, Claude routes them
    wrap-up.md           ← /wrap-up — end-of-session save
```

Plus a **SessionStart hook**: a script Claude Code runs automatically when a
session starts, injecting your index, recent log, and the active-work file
matching the current project. This is what makes the memory *reliable* — it's
done by the harness, not by asking the model to remember to read files.

## Install

```bash
git clone <this repo> && cd second-brain-starter
./setup.sh
```

Then edit `~/brain/brain/index.md` (who you are, active projects) and restart
Claude Code. The setup is idempotent and never overwrites existing files; if
`jq` is installed it wires the hook into `~/.claude/settings.json`
automatically (with a backup), otherwise it prints the snippet to add.

## Conventions that make it work

- **Name active files after project folders** — `work/active/my-project.md`
  auto-loads when you open Claude Code in `.../my-project`.
- **End sessions with `/wrap-up`** — the hook guarantees Claude always
  *reads* the brain; `/wrap-up` is what keeps it *written*.
- **Route knowledge to the right store**:
  | Fact | Home |
  |---|---|
  | Team/product knowledge others need | **your team's shared knowledge base** (reviewed, versioned) |
  | Your preferences & workflow | Claude's built-in auto-memory |
  | Open threads, project state, decisions | **~/brain** (this system) |

## Backup

Your brain is personal. If you want history/sync, push it to a **private**
repo under your own namespace — never to a shared team repo:

```bash
cd ~/brain && git remote add origin <private-repo-url> && git push -u origin master
```
