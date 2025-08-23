#!/bin/sh
# POSIX installer for serverscamp/scli
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/serverscamp/scli/main/install.sh | sh
#   VERSION=v1.0.9.4 curl -fsSL https://raw.githubusercontent.com/serverscamp/scli/main/install.sh | sh

set -e

REPO="serverscamp/scli"
GH_API="https://api.github.com/repos/${REPO}"
GH_DL="https://github.com/${REPO}/releases/download"

# --- detect version ---
if [ -n "${VERSION:-}" ]; then
  TAG="$VERSION"
else
  echo ">> Fetching latest release tag..."
  TAG="$(curl -fsSL "${GH_API}/releases/latest" | grep -o '"tag_name":[[:space:]]*"[^"]\+"' | head -n1 | cut -d'"' -f4)"
  if [ -z "$TAG" ]; then
    echo "!! Failed to obtain latest tag from GitHub API."
    echo "   Try setting VERSION=vX.Y.Z explicitly."
    exit 1
  fi
fi
echo "Version: ${TAG}"

# --- detect platform ---
OS="$(uname | tr '[:upper:]' '[:lower:]')"
ARCH="$(uname -m)"
case "$OS" in
  linux|darwin) ;;
  *)
    echo "!! Unsupported OS: $OS"
    exit 1
    ;;
esac
case "$ARCH" in
  x86_64|amd64) ARCH="amd64" ;;
  aarch64|arm64) ARCH="arm64" ;;
  *)
    echo "!! Unsupported ARCH: $ARCH"
    exit 1
    ;;
esac

ASSET="scli-${OS}-${ARCH}"
[ "$OS" = "windows" ] && ASSET="scli-windows-amd64.exe"
URL_BIN="${GH_DL}/${TAG}/${ASSET}"
URL_CHK="${GH_DL}/${TAG}/checksums.txt"

# --- choose install dir ---
TARGET_DIR="/usr/local/bin"
USE_SUDO=""
if [ ! -w "$TARGET_DIR" ]; then
  if command -v sudo >/dev/null 2>&1; then
    USE_SUDO="sudo"
  else
    # fallback to user-local bin
    TARGET_DIR="${HOME}/.local/bin"
    mkdir -p "$TARGET_DIR"
  fi
fi

# --- download to temp file ---
TMPDIR="${TMPDIR:-/tmp}"
TMPBIN="${TMPDIR}/scli.$$"
TMPCHK="${TMPDIR}/scli_checksums.$$"

echo ">> Downloading binary: ${URL_BIN}"
curl -fsSL -o "$TMPBIN" "$URL_BIN" || {
  echo "!! Download failed: $URL_BIN"
  exit 1
}
chmod +x "$TMPBIN"

# --- optional checksum verification ---
echo ">> Downloading checksums: ${URL_CHK} (optional)"
if curl -fsSL -o "$TMPCHK" "$URL_CHK" ; then
  if command -v sha256sum >/dev/null 2>&1; then
    echo ">> Verifying checksum..."
    # find the line with our asset name
    SUM_LINE="$(grep -E "  (bin/)?${ASSET}\$" "$TMPCHK" || true)"
    if [ -n "$SUM_LINE" ]; then
      EXPECTED="$(printf "%s" "$SUM_LINE" | awk '{print $1}')"
      ACTUAL="$(sha256sum "$TMPBIN" | awk '{print $1}')"
      if [ "$EXPECTED" != "$ACTUAL" ]; then
        echo "!! Checksum mismatch!"
        echo "   expected: $EXPECTED"
        echo "     actual: $ACTUAL"
        rm -f "$TMPBIN" "$TMPCHK"
        exit 1
      fi
      echo ">> Checksum OK."
    else
      echo "!! checksums.txt does not contain ${ASSET}; skipping verification."
    fi
  else
    echo "!! sha256sum not found; skipping checksum verification."
  fi
else
  echo "!! checksums.txt not found; skipping checksum verification."
fi

# --- install ---
echo ">> Installing to ${TARGET_DIR}/scli"
$USE_SUDO mv "$TMPBIN" "${TARGET_DIR}/scli"
rm -f "$TMPCHK" 2>/dev/null || true

# --- ensure PATH contains target dir (for local install) ---
case ":$PATH:" in
  *:"$TARGET_DIR":*) : ;;
  *)
    echo ">> NOTE: ${TARGET_DIR} is not in your PATH."
    echo "   Add this line to your shell profile:"
    echo "     export PATH=\"${TARGET_DIR}:\$PATH\""
    ;;
esac

echo ">> Installed: $(command -v scli || echo "${TARGET_DIR}/scli")"
echo ">> Version:"
scli version || true

echo "Done."