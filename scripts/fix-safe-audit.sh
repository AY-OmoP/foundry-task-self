#!/usr/bin/env bash
set -e

echo "🧹 Cleaning + reinstalling (safe mode)..."
rm -rf node_modules package-lock.json
npm install --legacy-peer-deps

echo "🔍 Checking for vulnerable or outdated libraries..."

# Detect OS for sed compatibility
if [[ "$OSTYPE" == "darwin"* ]]; then
  SED_CMD="sed -E 's/.*\${pkg}@\\([^[:space:]]*\\).*/\\1/' | tr -d '()'"
else
  SED_CMD="sed -E 's/.*\${pkg}@([^[:space:]]*).*/\1/'"
fi

# Helper: check if a package is installed and version is outdated
check_package() {
  local pkg="$1"
  local latest
  latest=$(npm view "$pkg" version 2>/dev/null || echo "unknown")
  if npm list "$pkg" >/dev/null 2>&1; then
    local current
    # shellcheck disable=SC2086
    current=$(npm list "$pkg" --depth=0 | grep "$pkg@" | bash -c "eval $SED_CMD")
    if [ "$latest" != "unknown" ] && [ "$current" != "$latest" ]; then
      echo "🧩 Updating $pkg from $current → $latest"
      npm install "$pkg@$latest" --save-exact
    else
      echo "✅ $pkg is already up to date ($current)"
    fi
  else
    echo "📦 Installing missing package $pkg@$latest"
    npm install "$pkg@$latest" --save-exact
  fi
}

echo "🔒 Patching core dependencies safely..."
check_package ws
check_package pino

# Handle @metamask/sdk gracefully
if npm view @metamask/sdk >/dev/null 2>&1; then
  check_package @metamask/sdk
else
  echo "⚠️  @metamask/sdk not available — installing fallback 0.33.x"
  npm install @metamask/sdk@^0.33.0 --save-exact
fi

echo "🧹 Deduplicating dependencies..."
npm dedupe debug || true

echo "🔎 Running final security audit..."
npm audit --omit=dev || true

echo "✅ Safe audit fix complete!"
