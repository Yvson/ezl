# Contributing to ezl

## Commit Convention

This project uses [Conventional Commits](https://www.conventionalcommits.org/) to automate versioning and changelog generation.

### Format

```
<type>(<scope>): <description>

[optional body]

[optional footer(s)]
```

### Types and Version Bumps

| Type | Description | Bump |
|------|-------------|------|
| `feat` | New feature | minor |
| `fix` | Bug fix | patch |
| `perf` | Performance improvement | patch |
| `docs` | Documentation only | none |
| `style` | Formatting, missing semicolons, etc. | none |
| `refactor` | Code change that neither fixes a bug nor adds a feature | none |
| `test` | Adding missing tests | none |
| `chore` | Maintain | none |
| `ci` | CI configuration changes | none |

### Breaking Changes

Add `!` after the type or a `BREAKING CHANGE:` footer to trigger a **major** version bump:

```
feat!: drop support for Ubuntu 22.04
```

or

```
fix: correct docker daemon socket handling

BREAKING CHANGE: docker module now requires systemd inside WSL
```

### Examples

```
feat(java): add graalvm as optional JDK provider
fix(docker): use correct apt keyring permissions
docs: clarify WSL shutdown step
chore: bump go version to 1.23.2
```

### Pull Requests

Use conventional commit format for the PR title — it's linted in CI. Squash-merge will use the PR title as the final commit message.

## Versioning

Versions are determined automatically by [semantic-release](https://semantic-release.gitbook.io/) from the commit history. Never edit the version manually.

- `fix:` → `v0.0.1`
- `feat:` → `v0.1.0`
- `fix:` → `v0.1.1`
- `feat!:` or `BREAKING CHANGE:` → `v1.0.0`

The first release will be `v0.1.0` (or `v1.0.0` if the repo already has a `feat!` or `BREAKING CHANGE` commit).
