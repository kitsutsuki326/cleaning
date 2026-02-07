#!/bin/bash
set -euo pipefail

# Only run in remote (Claude Code on the web) environments
if [ "${CLAUDE_CODE_REMOTE:-}" != "true" ]; then
  exit 0
fi

# This is a static HTML project with CDN dependencies.
# No package manager or build tools to install.
# The hook ensures the working directory is valid.
cd "$CLAUDE_PROJECT_DIR"
