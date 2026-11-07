#!/usr/bin/env bash
# Mirror mise's shims into a directory that non-login shells actually see.
#
# Why: in this container PATH comes from the host's hermes-agent.nix and lists
# /opt/data/.local/bin, but neither ~/.local/bin nor mise's shims dir, and
# non-interactive shells never read ~/.bashrc. Mirroring the shims there keeps
# gh/gcloud/bun/... resolvable without exporting PATH by hand.
#
# Portable: an explicit argument wins, then $MISE_SHIM_MIRROR, then
# /opt/data/.local/bin when that dir is on PATH. On a normal machine (mise
# activate in the shell rc) no mirror is needed, so it exits quietly.
#
# Re-run after `mise install` / `mise use -g`.
set -euo pipefail

target="${1:-${MISE_SHIM_MIRROR:-}}"
if [ -z "$target" ]; then
  case ":$PATH:" in
    *":/opt/data/.local/bin:"*) target=/opt/data/.local/bin ;;
    *) echo "no shim mirror needed here" ; exit 0 ;;
  esac
fi

mise_bin="$HOME/.local/bin/mise"
shims="$HOME/.local/share/mise/shims"
[ -x "$mise_bin" ] || { echo "mise not found at $mise_bin" >&2; exit 1; }

mkdir -p "$target"
ln -sfn "$mise_bin" "$target/mise"

for shim in "$shims"/*; do
  [ -e "$shim" ] || continue
  ln -sfn "$mise_bin" "$target/$(basename "$shim")"
done

# drop links whose tool is no longer installed by mise
for link in "$target"/*; do
  [ -L "$link" ] || continue
  [ -e "$link" ] || rm -f "$link"
done

echo "synced $(ls -1 "$target" | wc -l) entries into $target"
