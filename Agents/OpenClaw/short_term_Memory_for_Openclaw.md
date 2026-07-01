# A Simple `shorttermem/` Pattern For AI Agents And Operator Workflows

Temporary memory is a weird problem.

If an agent keeps everything in chat, useful context disappears after a restart.
If it writes everything down forever, your workspace turns into a junk drawer.

This pattern is the middle ground:

- keep a small `shorttermem/` folder for active working notes
- keep a tiny registry so you can see what is in there
- use soft-delete instead of immediate deletion
- purge old deleted notes automatically after a short retention window
- promote anything important into durable storage when it is worth keeping

It is simple, file-based, and boring in the good way.

## The Core Idea

Treat `shorttermem/` like a working tray, not an archive.

That means notes in it should be:

- easy to create
- easy to inspect
- easy to delete one at a time
- easy to clear in bulk
- easy to promote somewhere more permanent

The lifecycle is:

1. Capture fast
2. Work from it
3. Promote if durable
4. Delete when done

## Example Layout

```text
shorttermem/
├── memory_registry.md
├── 2026-07-01-some-topic.md
├── 2026-07-01-another-topic.md
└── .softdel/
    └── 2026-07-01/
        └── some-topic--deleted-20260701T030811Z.md
```

## What Lives There

Good candidates for `shorttermem/`:

- reboot handoff notes
- temporary research threads
- “come back to this later” context
- working assumptions that might become durable later
- notes that matter for a few days, not forever

Bad candidates:

- secrets
- long-term memory
- formal docs
- project documentation that should live in a real home

## The Registry

A small `memory_registry.md` keeps the folder understandable.

It does not need to be fancy. It just needs to answer:

- what active notes exist right now
- what was soft-deleted but not yet purged
- how to refresh, delete, restore, or sweep the area

Example:

```md
# Short Term Memory Registry

- Generated UTC: `2026-07-01T03:11:17Z`
- Active notes: `2`
- Soft-deleted notes waiting for purge: `0`

## Active Notes
- `2026-07-01-some-topic.md`
- `2026-07-01-another-topic.md`

## Soft-Deleted Queue
- None
```

## Why Soft Delete Beats Immediate Delete

Hard delete is clean until it is stupid.

Soft delete gives you:

- reversible cleanup
- less fear around deleting temporary notes
- a retention window for second thoughts
- easier bulk cleanup without regret

Instead of deleting immediately, move notes into a dated bucket like:

```text
.softdel/YYYY-MM-DD/
```

Then purge old buckets automatically after a retention threshold.

Example policy:

- soft-delete now
- keep recoverable for 14 days
- purge anything 15 days old or older

## Piecewise Cleanup And Total Cleanup

The pattern should support both:

### Piecewise cleanup

Delete one note when it is no longer useful.

Example:

```bash
shorttermem-tool soft-delete 2026-07-01-some-topic.md
```

### Total cleanup

Clear the whole active tray when the working set is done.

Example:

```bash
shorttermem-tool soft-delete-all
```

That gives you a clean workspace without losing recoverability.

## Restore Matters Too

If delete is reversible, restore should be easy.

Useful commands usually look like:

```bash
shorttermem-tool restore some-topic--deleted-20260701T030811Z.md
shorttermem-tool restore-all
```

If you do not support restore, soft delete is just theater.

## Promotion Is The Real Win

The best part of a short-term memory system is not deletion.
It is promotion.

When a temporary note turns out to matter, move the durable part somewhere real:

- long-term memory
- a reusable skill
- a project doc
- a design note
- a runbook

That keeps `shorttermem/` temporary by default.

In other words:

- `shorttermem/` is the working tray
- durable storage is the filing cabinet

Do not confuse the two.

## Why Files Work Well Here

This could all live in a database.
It could also turn into a small compliance religion.

Plain files are usually enough because they are:

- human-readable
- scriptable
- easy to diff
- easy to move
- easy to back up
- easy to understand without special tooling

For a lightweight agent workflow, that is often the right trade.

## Automation Helps

This pattern gets better when a small scheduled cleanup exists.

For example:

- rebuild the registry
- purge expired soft-deleted notes
- run once per day

The goal is not sophistication.
The goal is that temporary notes do not quietly become permanent clutter.

## Why I Like This Pattern

It solves a real annoyance without overbuilding:

- the agent does not pretend it will remember everything
- the human can inspect the state easily
- temporary notes stay temporary
- cleanup becomes safe enough to actually use

That is usually what good tooling looks like:
small, legible, and useful under mild stress.

## If You Want To Build One

Start with just this:

1. a `shorttermem/` folder
2. one generated registry file
3. soft-delete into dated folders
4. a simple purge policy
5. a promotion mindset

That is enough to get most of the benefit.

You can always add more later.
You usually do not need to.
