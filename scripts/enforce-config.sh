#!/usr/bin/env bash
set -euo pipefail

mkdir -p test

# Determine branch name (prefer GitHub Actions env; fallback to local)
branch="${GITHUB_REF_NAME:-$(git rev-parse --abbrev-ref HEAD)}"

case "$branch" in
  main)
    cat > test/config.json <<'JSON'
{
  "env": "main",
  "apiUrl": "https://api.example.com/main"
}
JSON
    ;;
  dev)
    cat > test/config.json <<'JSON'
{
  "env": "dev",
  "apiUrl": "https://api.example.com/dev",
  "debug": true
}
JSON
    ;;
  test)
    cat > test/config.json <<'JSON'
{
  "env": "test",
  "apiUrl": "https://api.example.com/test",
  "mock": true,
  "timeoutMs": 2000
}
JSON
    ;;
  *)
    echo "Unknown branch: $branch"
    exit 1
    ;;
esac

if ! git diff --quiet -- test/config.json; then
  git add -f test/config.json
  git -c user.name="github-actions[bot]" -c user.email="41898282+github-actions[bot]@users.noreply.github.com" commit -m "ci: enforce branch config for ${branch} [skip ci]"
  git push origin "${branch}"
else
  echo "Config matches ${branch}; no change needed."
fi
