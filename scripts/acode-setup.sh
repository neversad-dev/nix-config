#!/bin/sh
# Set up git + ssh in Acode's built-in Alpine terminal, consistent with the
# nix-on-droid config (for the Git SCM plugin).
#
# Inputs come from the bundle that `just droid` exports to shared storage
# (home/android/acode.nix). Run inside Acode's terminal:
#
#   sh /sdcard/code/projects/nix-config/scripts/acode-setup.sh
#
# Idempotent. git settings are *included* from the bundle, so `just droid`
# alone updates them. Rerun after changing ssh settings or packages, or
# after Acode resets its sandbox.
set -eu

BUNDLE=${ACODE_BUNDLE:-/storage/emulated/0/nix-on-droid/acode}
MARK_BEGIN="# >>> acode-setup >>>"
MARK_END="# <<< acode-setup <<<"

say() { printf '\033[34;1m[*]\033[0m %s\n' "$*"; }

if [ ! -f "$BUNDLE/gitconfig" ]; then
  echo "No bundle at $BUNDLE." >&2
  echo "Run 'just droid' in nix-on-droid first, and make sure Acode has storage access." >&2
  exit 1
fi

say "Installing packages"
# Alpine ships Dropbear's ssh, which breaks git auth: use OpenSSH.
for p in dropbear-ssh dropbear-scp dropbear-dbclient dropbear; do
  if apk info -e "$p" > /dev/null 2>&1; then apk del -q "$p"; fi
done
apk add -q git git-lfs openssh-client-default openssh-keygen
# delta (pager in the shared config) is in Alpine's community repo.
apk add -q delta 2> /dev/null || say "delta unavailable, falling back to less"

say "Configuring git"
mkdir -p "$HOME/.config/git/hooks"
# Referenced by the shared config as ~/.config/git/{message,ignore,hooks}.
ln -sf "$BUNDLE/message" "$HOME/.config/git/message"
ln -sf "$BUNDLE/ignore" "$HOME/.config/git/ignore"
# Shared storage can't hold executables: exec the bundle's hook via bash.
cat > "$HOME/.config/git/hooks/commit-msg" << EOF
#!/bin/sh
exec bash "$BUNDLE/hooks/commit-msg" "\$@"
EOF
chmod 755 "$HOME/.config/git/hooks/commit-msg"

{
  echo "# Managed by scripts/acode-setup.sh; rerun it instead of editing."
  echo "[include]"
  printf '\tpath = %s\n' "$BUNDLE/gitconfig"
  # Overrides for Alpine (after the include, so they win):
  echo "[safe]"
  # Acode opens repos under /sdcard; nix-on-droid's entry is /storage/...
  printf '\tdirectory = /sdcard/*\n'
  # (No core.fileMode here: git sets it per repo at clone time, and the repo
  # value wins over this file.)
  if ! command -v delta > /dev/null 2>&1; then
    echo "[core]"
    printf '\tpager = less\n'
    echo "[interactive]"
    printf '\tdiffFilter = cat\n'
  fi
} > "$HOME/.gitconfig"

say "Configuring ssh"
mkdir -p "$HOME/.ssh"
chmod 700 "$HOME/.ssh"
# Copied, not included: ssh rejects config files owned by another user,
# which is how shared storage looks from here.
{
  echo "# Managed by scripts/acode-setup.sh; rerun it instead of editing."
  echo "# Fixed agent socket: the Git SCM plugin runs git without a shell env."
  echo "Host *"
  echo "  IdentityAgent ~/.ssh/agent.sock"
  echo
  cat "$BUNDLE/ssh_config"
} > "$HOME/.ssh/config"
chmod 600 "$HOME/.ssh/config"
touch "$HOME/.ssh/known_hosts"
while IFS= read -r line; do
  grep -qxF "$line" "$HOME/.ssh/known_hosts" || printf '%s\n' "$line" >> "$HOME/.ssh/known_hosts"
done < "$BUNDLE/known_hosts"
chmod 600 "$HOME/.ssh/known_hosts"

# Start one agent per Acode session on that socket.
touch "$HOME/.bashrc"
sed -i "/^$MARK_BEGIN\$/,/^$MARK_END\$/d" "$HOME/.bashrc"
cat >> "$HOME/.bashrc" << 'EOF'
# >>> acode-setup >>>
export SSH_AUTH_SOCK="$HOME/.ssh/agent.sock"
ssh-add -l > /dev/null 2>&1
if [ $? -eq 2 ]; then
  rm -f "$SSH_AUTH_SOCK"
  ssh-agent -a "$SSH_AUTH_SOCK" > /dev/null
fi
# <<< acode-setup <<<
EOF

if [ ! -f "$HOME/.ssh/id_ed25519" ]; then
  say "Generating this sandbox's own key (one key per machine)"
  ssh-keygen -t ed25519 -a 256 -C "acode@android" -f "$HOME/.ssh/id_ed25519"
  echo
  echo "Add this public key to GitHub (Settings > SSH keys, as Authentication key):"
  cat "$HOME/.ssh/id_ed25519.pub"
fi

echo
say "Done. Open a new Acode terminal, then once per session:"
echo "    ssh-add          # unlock the key, so the Git SCM plugin can push/pull"
echo "    ssh -T git@github.com"
