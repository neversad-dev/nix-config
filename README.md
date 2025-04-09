# Nix darwin config for MacOS

## Prerequisites

1. Log in to App Store for installing apps from it.

2. Install nix:

  ```
  sh <(curl -L https://nixos.org/nix/install)
  ```

  after nix installed restart terminal.

3. Clone the repo
   with nix installed:

  ```
  nix-shell -p git --run "git clone https://github.com/GiveNoCode/nix-config.git"
  ```

4. Change hostname if required:
   Apple menu  > System Settings > General > About > name

5. Install Xcode Command Line Tools

   ```
   xcode-select --install
   ```

6. Accept xcode license agreement:

   ```
   sudo xcodebuild -license accept
   ```

## Install

  ```
  cd nix-config
  nix  --extra-experimental-features "nix-command flakes" run nix-darwin -- switch --flake .
  ```

## App specific settings

#### Raycast

- record hotkey cmd + space
- enable "Open at Login" option

#### Bitwarden

- Unlock with Touch ID
- Show menu bar icon
- Minimie to menu bar
- Close to menu bar
- Start to menu bar
- Start automatically on login
- Allow browser integration

#### Itsycal

- Launch at login
- move closer to clock
- set format to YYYY-MM-dd
- hide

#### Stats

- start at login
- import settings from /nix-config/home/dotfiles/stats

#### MonitorControl

- Start at Login
- allow Accessibility permission

#### AltTab

- allow Screen Recording
- allow Accessibility permission
- change hotkey to cmd+tab

#### Chatgpt

- log in
- Launch at Login

#### Hidden Bar

- Start Hidden Bar when I log in
- uncheck Show preferences on launch
- move icons (ctrl + drag&drop)

## Apps that I use but not installed with nix

- Orca Slicer: <https://github.com/SoftFever/OrcaSlicer/releases>
- KDE Connect: <https://kdeconnect.kde.org>

## Update

```
just darwin
```
