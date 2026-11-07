# mise: dev tool manager. Versions pinned in ~/.config/mise/config.toml
export PATH="$HOME/.local/bin:$PATH"
case ":$PATH:" in
  *":$HOME/.local/share/mise/shims:"*) ;;
  *) export PATH="$HOME/.local/share/mise/shims:$PATH" ;;
esac
command -v mise >/dev/null 2>&1 && eval "$(mise activate bash)"

# gws: no keyring daemon in this container — pin the file backend explicitly
export GOOGLE_WORKSPACE_CLI_KEYRING_BACKEND=file
