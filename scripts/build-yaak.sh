#!/usr/bin/env bash
# Build Yaak (https://github.com/mountain-loop/yaak) from source and install it as a .deb on Ubuntu.
#
# Yaak's prebuilt binaries need a paid license for commercial use, but the MIT-licensed source
# "can be built and run for free, for both personal and commercial use" (Yaak README). This
# builds the release config without the `license` and `updater` features, so the app neither
# asks for a license nor updates itself to the prebuilt binary.
#
#   scripts/build-yaak.sh                 # latest release
#   scripts/build-yaak.sh v2026.9.1       # a specific tag
#   scripts/build-yaak.sh --no-install    # only build the .deb
#
# The checkout, node_modules and Rust build cache stay in $YAAK_SRC_DIR (default
# ~/.cache/yaak-src, ~5 GB) so rebuilding for a new release is incremental.
set -Eeuo pipefail

DOTFILES_DIR=${DOTFILES_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}
# shellcheck source=lib/common.sh
source "$DOTFILES_DIR/lib/common.sh"

REPO=mountain-loop/yaak
SRC_DIR=${YAAK_SRC_DIR:-${XDG_CACHE_HOME:-$HOME/.cache}/yaak-src}
APP_DIR=crates-tauri/yaak-app-client
# Tauri's Linux prerequisites plus what Yaak's release workflow installs: clang/llvm compile
# SQLite to wasm32, protoc builds the plugin runtime.
APT_DEPS=(
  build-essential pkg-config file cmake ninja-build clang llvm protobuf-compiler patchelf
  libwebkit2gtk-4.1-dev libayatana-appindicator3-dev librsvg2-dev libxdo-dev libssl-dev
  libnss3 xdg-utils
)

usage() {
  cat <<'EOF'
Usage: build-yaak.sh [--no-install] [TAG]

  TAG           release tag to build, e.g. v2026.9.1 (default: latest release)
  --no-install  build the .deb but do not install it
EOF
}

latest_tag() {
  curl -fsSL "https://api.github.com/repos/$REPO/releases/latest" |
    sed -n 's/.*"tag_name": *"\([^"]*\)".*/\1/p'
}

install_apt_deps() {
  local missing=() pkg
  for pkg in "${APT_DEPS[@]}"; do
    if ! dpkg-query -W -f='${Status}' "$pkg" 2>/dev/null | grep -q 'ok installed'; then
      missing+=("$pkg")
    fi
  done
  if ((${#missing[@]} == 0)); then
    return 0
  fi
  log "missing: ${missing[*]}"
  sudo apt-get update -qq
  sudo DEBIAN_FRONTEND=noninteractive apt-get install -y -qq "${missing[@]}"
}

install_rust() {
  if ! command -v rustup >/dev/null 2>&1; then
    curl --proto '=https' --tlsv1.2 -fsSL https://sh.rustup.rs |
      sh -s -- -y --no-modify-path --profile minimal
  fi
  # Installs or updates stable; Yaak tracks the latest stable Rust.
  rustup toolchain install stable --profile minimal --target wasm32-unknown-unknown
}

fetch_source() {
  local tag=$1
  if [[ ! -d $SRC_DIR/.git ]]; then
    git init -q "$SRC_DIR"
    git -C "$SRC_DIR" remote add origin "https://github.com/$REPO.git"
  fi
  git -C "$SRC_DIR" fetch -q --depth 1 origin "+refs/tags/$tag:refs/tags/$tag"
  git -C "$SRC_DIR" checkout -q --force "refs/tags/$tag"
}

# Put the Node version Yaak pins (.node-version) first on PATH.
use_node() {
  local version
  version=$(<"$SRC_DIR/.node-version")
  mise install "node@$version"
  PATH="$(mise where "node@$version")/bin:$PATH"
}

# Write Yaak's release Tauri config minus the license and updater pieces.
write_tauri_config() {
  node - "$SRC_DIR/$APP_DIR/tauri.release.conf.json" "$SRC_DIR/$APP_DIR/tauri.local.conf.json" "$1" <<'EOF'
const fs = require("fs");
const [src, dest, version] = process.argv.slice(2);
const conf = JSON.parse(fs.readFileSync(src, "utf8"));
conf.version = version;
conf.build = { ...conf.build, features: ["wry"] };
if (conf.plugins) delete conf.plugins.updater;
// The inline "release" capability only grants yaak-license permissions.
const caps = conf.app?.security?.capabilities;
if (caps) conf.app.security.capabilities = caps.filter((c) => typeof c === "string");
conf.bundle = { ...conf.bundle, createUpdaterArtifacts: false };
fs.writeFileSync(dest, JSON.stringify(conf, null, 2) + "\n");
EOF
}

build_deb() (
  local configs=()
  cd "$SRC_DIR"
  write_tauri_config "$1"
  # The Linux config names the package files like the official .deb (yaak, /usr/lib/yaak).
  if [[ -f $APP_DIR/tauri.linux.conf.json ]]; then
    configs+=(--config "$APP_DIR/tauri.linux.conf.json")
  fi
  configs+=(--config "$APP_DIR/tauri.local.conf.json")
  rm -rf target/release/bundle/deb
  npm ci --no-audit --no-fund
  # tauri build first runs `npm run bootstrap`: workspace builds, vendored node/protoc/plugins.
  npm run client:build -- --bundles deb "${configs[@]}"
)

# Tauri writes the builder's uid into the .deb's ar headers, which hold only 6 digits, so a
# large uid (e.g. a domain account) corrupts the file. Rewrap the same members with uid 0.
repack_deb() {
  local deb=$1 stage=${1%.deb}
  rm -f "$deb"
  (cd "$stage" && ar rcD "$deb" debian-binary control.tar.gz data.tar.gz)
  dpkg-deb --info "$deb" >/dev/null
}

main() {
  local install=true tag="" arg deb version
  for arg in "$@"; do
    case $arg in
      --no-install) install=false ;;
      -h | --help)
        usage
        return 0
        ;;
      -*)
        usage >&2
        return 1
        ;;
      *) tag=$arg ;;
    esac
  done

  command -v apt-get >/dev/null 2>&1 || die "only Ubuntu is supported"
  export PATH="$HOME/.cargo/bin:$HOME/.local/bin:$PATH" RUSTUP_TOOLCHAIN=stable
  command -v mise >/dev/null 2>&1 || die "mise not found; run bootstrap.sh first"
  if [[ -z $tag ]]; then
    tag=$(latest_tag)
    [[ -n $tag ]] || die "could not look up the latest Yaak release"
  fi
  version=${tag#v}
  trap 'die "step failed: $CURRENT_STEP"' ERR

  run_step "Installing build dependencies" install_apt_deps
  run_step "Installing Rust" install_rust
  run_step "Fetching Yaak $tag into $SRC_DIR" fetch_source "$tag"
  run_step "Installing Node" use_node
  run_step "Building Yaak $version (takes a while)" build_deb "$version"

  deb=$(find "$SRC_DIR/target/release/bundle/deb" -maxdepth 1 -name "*_${version}_*.deb" -print -quit)
  [[ -n $deb ]] || die "no .deb for $version in $SRC_DIR/target/release/bundle/deb"
  run_step "Repacking $deb" repack_deb "$deb"
  if [[ $install == false ]]; then
    log "Built $deb"
    return 0
  fi
  # --reinstall also replaces a prebuilt Yaak of the same version; both use the same app data.
  run_step "Installing $deb" sudo apt-get install -y -qq --reinstall "$deb"
  log "Done: Yaak $version built from source."
}

main "$@"
