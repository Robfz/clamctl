# clamctl

Keep a MacBook awake with the lid closed while it's plugged in. No external display, keyboard or mouse needed.

`clamctl` is a small headless LaunchDaemon plus a CLI, intended for MacBooks used as lid-closed servers or build machines that you reach over SSH.

```console
$ clamctl status
daemon=running mode=auto disablesleep=1 power=ac lid=closed

$ clamctl thermal
cpu=43.3C gpu=43.0C fans=0,0rpm pressure=nominal
```

## Why

macOS only stays awake with the lid closed in "clamshell mode", which requires AC power **and** an external display. Tools like `caffeinate` or `pmset sleep 0` prevent idle sleep but not lid-close sleep.

The undocumented `pmset disablesleep 1` setting does prevent lid-close sleep, but it is global. Leave it on and a closed MacBook in a bag stays awake on battery. `clamctl` turns it on only while the Mac is on AC power.

## How it works

A LaunchDaemon running as root checks the power source every 10 seconds and acts only when the desired state changes:

| Situation | Action |
| --- | --- |
| On AC power | `pmset -a disablesleep 1` |
| On battery | `pmset -a disablesleep 0`, plus `pmset sleepnow` if the lid is closed |
| Daemon stopped | `pmset -a disablesleep 0` |

The `pmset sleepnow` is needed because re-enabling sleep doesn't put an already-closed Mac to sleep.

The default `auto` mode can be overridden with `on` (always awake) or `off` (never block sleep).

## Requirements

- macOS on a MacBook. Developed and tested on Apple Silicon.
- [macmon](https://github.com/vladkens/macmon) for `clamctl thermal` only: `brew install macmon`. This also requires `jq`, which ships with recent macOS releases.

## Install

```sh
git clone https://github.com/Robfz/clamctl.git
cd clamctl
sudo ./install.sh
```

On a remote Mac:

```sh
ssh -t mac 'git clone https://github.com/Robfz/clamctl.git /tmp/clamctl && sudo /tmp/clamctl/install.sh'
```

This installs:

- `/usr/local/bin/clamctl`: the CLI and daemon
- `/Library/LaunchDaemons/com.robfz.clamctl.plist`: starts the daemon at boot and restarts it if it exits

## Usage

```
clamctl status        Daemon state, mode, disablesleep, power source and lid state
clamctl thermal       CPU/GPU temperature, fan speeds and thermal pressure (needs macmon)
clamctl log [-f]      Last 50 log lines; -f to follow
sudo clamctl on       Always stay awake, even on battery
sudo clamctl off      Never block sleep, even on AC power
sudo clamctl auto     Stay awake only on AC power (default)
clamctl help          Show help
```

- `on`, `off` and `auto` take effect immediately and persist across reboots. The mode is stored in `/var/db/clamctl/mode`.
- `status`, `thermal` and `log` don't need sudo.
- `/usr/local/bin` may not be on `PATH` in non-interactive SSH sessions. Use the full path there, e.g. `ssh mac /usr/local/bin/clamctl status`.

### Thermal output

- `cpu` / `gpu`: average temperatures reported by macmon.
- `fans`: each fan's speed in RPM, or `none` on fanless models.
- `pressure`: the macOS thermal pressure level (`nominal`, `moderate`, `heavy`, `trapping` or `sleeping`). Levels above `nominal` mean macOS is under thermal load and may throttle.

The log is at `/var/log/clamctl.log`.

## Uninstall

```sh
sudo ./uninstall.sh
```

This stops the daemon, removes the installed files and the stored mode, and resets `disablesleep` to 0.

## Limitations

- `disablesleep` is an undocumented `pmset` setting and may change in future macOS releases.
- `on` mode skips the battery safety net: a closed Mac on battery stays awake until you run `auto` or `off`.
- `off` with the lid already closed on AC power doesn't force sleep; the Mac sleeps on its normal idle schedule.
- Unplugging power while the lid is closed in `auto` mode puts the Mac to sleep, even if an external display is attached.
- The display still sleeps on its normal schedule.
- A closed MacBook dissipates heat less effectively. Keep an eye on `clamctl thermal` under sustained load.

## License

[MIT](LICENSE)
