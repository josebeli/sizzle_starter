# Claude Code Instructions

## IMPORTANT: Memory Bank Required

**At the start of EVERY new session or task, you MUST read ALL files in `.rules/memory-bank/` before proceeding.**

This is not optional. The memory bank contains critical project context that resets between sessions.

### Required Files

Read these files in order:
1. `.rules/memory-bank/brief.md` - Project overview
2. `.rules/memory-bank/product.md` - Product goals and user flows
3. `.rules/memory-bank/architecture.md` - System design and patterns
4. `.rules/memory-bank/tech.md` - Technologies and setup
5. `.rules/memory-bank/context.md` - Current work focus and recent changes

### Memory Bank Rules

For detailed workflows (initialization, updates, task documentation), see `.rules/memory-bank-rules.md`.

### Status Indicator

After reading the memory bank, include one of these at the start of your response:
- `[Memory Bank: Active]` - Successfully read all files
- `[Memory Bank: Missing]` - Folder missing or empty (suggest initialization)

## Note

This file contains instructions only. Do not use CLAUDE.md as a context source - use the memory-bank folder instead.
