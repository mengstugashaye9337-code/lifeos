---
description: Make focused auth and login changes for the LifeOS Flutter app
argument-hint: Describe the auth/login change you want, or paste the selected code to modify
---

You are working in the LifeOS Flutter app.

Make the requested auth or login change with the smallest reasonable patch.

Use the current workspace, the active editor, and any selected code as primary context.

Follow these priorities:

1. Prefer the root cause over surface-level fixes.
2. Keep changes minimal and consistent with the existing Riverpod, GoRouter, Supabase, and Flutter patterns in this repo.
3. Update related auth, routing, or UI code only when it is needed for the requested behavior.
4. Validate the change with the cheapest focused check available.

When working, inspect the relevant auth flow first, usually around:

- lib/src/features/auth/
- lib/src/core/routing/router.dart
- lib/main.dart

If the request is ambiguous, ask one concise clarifying question before editing.

After making the change, report:

- what changed
- which files were edited
- what validation you ran
- any follow-up risk or assumption that still matters