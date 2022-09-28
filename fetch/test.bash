#!/usr/bin/env bash

set -euo pipefail

die() {
  echo "$*" >&2
  exit 1
}

find . -name "*.html" -type f -print0 | xargs -0 -I{} rm -f {}
find . -name "*.html.d" -type d -print0 | xargs -0 -I{} rm -fr {}

./fetch 'https://google.com' 'https://github.com'

if [[ ! -f "google.com.html" ]]; then
  die "google.com.html is not found"
fi

if [[ ! -f "github.com.html" ]]; then
  die "github.com.html is not found"
fi

./fetch --metadata 'https://google.com' 'https://github.com'

./fetch --archive 'https://www.google.com'