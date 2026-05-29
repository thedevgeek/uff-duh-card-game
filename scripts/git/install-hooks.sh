#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$repo_root"

chmod +x .githooks/pre-push scripts/git/pre-push-large-files.sh scripts/git/install-hooks.sh

git config core.hooksPath .githooks

echo "Git hooks installed. core.hooksPath is now set to .githooks"
echo "Pre-push large-file guard is active for this clone."
