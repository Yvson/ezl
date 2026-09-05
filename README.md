# ezl — WSL Ubuntu 24.04 Dev Environment Bootstrap

[![Release](https://github.com/Yvson/ezl/workflows/Release/badge.svg)](https://github.com/Yvson/ezl/releases)
[![CI](https://github.com/Yvson/ezl/workflows/CI/badge.svg)](https://github.com/Yvson/ezl/actions)
[![semantic-release: angular](https://img.shields.io/badge/semantic--release-angular-e10079?logo=semantic-release)](https://github.com/semantic-release/semantic-release)

One command to set up a complete developer environment inside a fresh Ubuntu 24.04 WSL instance.

## Quickstart

```bash
curl -fsSL https://raw.githubusercontent.com/Yvson/ezl/main/install.sh | bash
```

Then restart WSL from PowerShell:

```powershell
wsl --shutdown
wsl -d Ubuntu-24.04
```

## What gets installed

| Module | Tools |
|--------|-------|
| `00-system` | build-essential, curl, jq, vim, htop |
| `10-git` | git, GitHub CLI (`gh`) |
| `20-shell` | zsh, oh-my-zsh, autosuggestions, syntax-highlighting, tmux |
| `30-docker` | native Docker Engine, compose plugin, lazydocker |
| `40-java` | SDKMAN!, Java 21 (Temurin), Maven, Gradle |
| `50-node` | nvm, Node LTS, corepack (pnpm/yarn) |
| `60-python` | pyenv, Python 3.12, pipx |
| `70-dotnet` | .NET LTS SDK |
| `80-go` | Go 1.23 |
| `90-extras` | fzf, ripgrep, bat, direnv, httpie, btop, ncdu |

## Usage

```bash
# after install
ezl update          # pull latest and re-run everything (idempotent)
ezl install 40-java # re-run a specific module
ezl verify          # smoke-test all tools
ezl list            # show modules
```

### Install options

```bash
./install.sh --list                 # show modules
./install.sh --only 40-java,50-node # run only these
./install.sh --skip 30-docker       # skip docker
./install.sh --dry-run              # see what would happen
./install.sh --force                # re-run all regardless of state
```

## Customizing

Edit [config/versions.env](config/versions.env) to change versions, then:

```bash
ezl install 40-java --force
```

Edit [config/zshrc](config/zshrc) or [config/tmux.conf](config/tmux.conf) to customize your shell.

## Versioning

This project uses [semantic-release](https://semantic-release.gitbook.io/) — versions and changelogs are generated automatically from [conventional commits](https://www.conventionalcommits.org/). See [CONTRIBUTING.md](CONTRIBUTING.md) for the commit format that triggers each bump.

| Release | Triggered by |
|---------|--------------|
| patch | `fix:` commits |
| minor | `feat:` commits |
| major | `feat!:` or `BREAKING CHANGE:` footer |

Releases are published automatically on every merge to `main`.

## Notes

- Docker runs **natively** inside WSL (not Docker Desktop). The installer enables systemd in `/etc/wsl.conf`, but you must run `wsl --shutdown` once from Windows for it to take effect.
- Git config is installed as a template ([config/gitconfig](config/gitconfig)) — update your name and email.
- Everything is idempotent: safe to re-run `ezl update` anytime.

## License

MIT
