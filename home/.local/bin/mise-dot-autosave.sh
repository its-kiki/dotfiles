#!/usr/bin/env bash
# Stand-in for mise's history-watch service.
#
# This container has no user systemd (PID 1 is s6-svscan), so
# `mise bootstrap services apply` cannot install the watcher that normally
# commits and publishes dotfile edits. A cron job runs this once a day
# instead: it commits a checkpoint only when a tracked file changed and
# publishes it to the origin repository (watch --once does both).
#
# Silent when there is nothing to report, so it is safe to deliver verbatim.
set -uo pipefail

mise_bin="$(command -v mise || true)"
[ -n "$mise_bin" ] || mise_bin="$HOME/.local/bin/mise"
[ -x "$mise_bin" ] || exit 0

out="$("$mise_bin" dot watch --once 2>&1)"
[ -n "$out" ] || exit 0

case "$out" in
  *"nothing changed"*|*"nothing new to publish"*) exit 0 ;;
esac

printf '%s\n' "$out" | grep -v 'files omitted from capture' || true
