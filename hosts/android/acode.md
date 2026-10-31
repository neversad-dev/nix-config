# Acode: git for the Git SCM plugin

[Acode](https://acode.app)'s Git SCM plugin runs `git` in Acode's own Alpine
sandbox. It has no Nix and can't see nix-on-droid's home, so set it up by hand
once per Acode install. Values below mirror the Nix config; the source of truth
is `home/base/core/git/` and `home/base/core/ssh.nix`.

## 1. Android (GrapheneOS)

- Install the **F-Droid build** of Acode. The normal build can't request
  "All files access", so its terminal sees shared storage as empty.
- Settings → Apps → Acode:
  - **All files access**: allow, with Storage Scopes off. A scope doesn't
    cover folders nix-on-droid's git creates later (`.git/objects/xx`), so
    pulls in Acode fail with "unable to write file ... No such file".
  - **Exploit protection → Native code debugging**: allow (proot needs `ptrace`).
- Open Acode's terminal once so it installs its sandbox.

## 2. Packages

In Acode's terminal:

```sh
apk del dropbear-ssh dropbear-scp dropbear-dbclient dropbear 2> /dev/null
apk add git git-lfs delta openssh-client-default openssh-keygen
```

Dropbear's `ssh` breaks git authentication, so it's replaced by OpenSSH.

## 3. Git

```sh
git config --global user.name "neversad-dev"
git config --global user.email "7419136+neversad-dev@users.noreply.github.com"
git config --global safe.directory '*'   # shared storage belongs to another user
git config --global init.defaultBranch main
git config --global pull.rebase true
git config --global push.autoSetupRemote true
git config --global core.pager delta
# Acode runs proot with --link2symlink, which breaks hard links on shared
# storage ("unable to write file .git/objects/..."): rename objects instead.
git config --global core.createObject rename

# Conventional-commit check and commit template, from this repo:
R=/sdcard/code/projects/nix-config
mkdir -p ~/.config/git/hooks
cp $R/home/base/core/git/commit-msg ~/.config/git/hooks/
chmod +x ~/.config/git/hooks/commit-msg
cp $R/home/base/core/git/commit-template ~/.config/git/message
git config --global core.hooksPath ~/.config/git/hooks
git config --global commit.template ~/.config/git/message
```

Re-copy the hook and template if they change in the repo.

## 4. SSH

Use a separate key for Acode (one key per machine) and pin GitHub's host key:

```sh
ssh-keygen -t ed25519 -a 256 -C "acode@pixel6" -f ~/.ssh/id_ed25519
cat ~/.ssh/id_ed25519.pub   # add to GitHub as an Authentication key

printf '%s\n' 'github.com ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOMqqnkVzrm0SdG6UOoqKLsabgH5C9okWi0dh2l9GKJl' >> ~/.ssh/known_hosts

cat > ~/.ssh/config << 'EOF'
Host github.com
  User git
  IdentityFile ~/.ssh/id_ed25519
  IdentitiesOnly yes
EOF
chmod 600 ~/.ssh/config ~/.ssh/known_hosts
```

## 5. Check

```sh
ssh -T git@github.com   # "Hi neversad-dev! ..."
```

Then open `/sdcard/code/projects/nix-config` as a folder in Acode; Git SCM
should detect the repo and ask for the key's passphrase when it needs it.
