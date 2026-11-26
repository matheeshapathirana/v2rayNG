#!/usr/bin/env bash
# Builds libv2ray.aar from the AndroidLibXrayLite submodule against Xray-core with the
# patches in ./patches applied (restores the TLS `allowInsecure` option).
#
# Usage: build-libv2ray.sh <output-dir>
# Needs git, curl, jq, a Go toolchain, gomobile on PATH, ANDROID_HOME and ANDROID_NDK_HOME.
set -euo pipefail

OUT_DIR="$1"

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$HERE/../AndroidLibXrayLite"
XRAY_VERSION="$(tr -d '[:space:]' < "$HERE/XRAY_VERSION")"
SRC="${XRAY_SRC_DIR:-${RUNNER_TEMP:-/tmp}/xray-core-src}"

if [[ ! -d "$SRC/.git" ]]; then
  git clone --depth 1 --branch "$XRAY_VERSION" https://github.com/XTLS/Xray-core.git "$SRC"
  git -C "$SRC" apply "$HERE"/patches/*.patch
fi

mkdir -p "$OUT_DIR"
OUT_DIR="$(cd "$OUT_DIR" && pwd)"

cd "$LIB_DIR"
mkdir -p assets data
bash gen_assets.sh download
cp -v data/*.dat assets/

export GOTOOLCHAIN="${GOTOOLCHAIN:-auto}"
go mod edit -replace "github.com/xtls/xray-core=$SRC"
go mod tidy
gomobile init
gomobile bind -v -androidapi 24 -trimpath -ldflags='-s -w -buildid= -checklinkname=0' -o "$OUT_DIR/libv2ray.aar" ./
# The app adds every *.jar in libs/ as a dependency; the sources jar is not needed.
rm -f "$OUT_DIR/libv2ray-sources.jar"

echo "Built $OUT_DIR/libv2ray.aar (Xray $XRAY_VERSION + allowInsecure patch)"
