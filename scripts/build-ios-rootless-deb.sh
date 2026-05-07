#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PYTHON="${PYTHON:-python3}"
PKG_NAME="${PKG_NAME:-com.korboy.yt-dlp}"
PKG_ARCH="${PKG_ARCH:-iphoneos-arm64}"
IOS_PYTHON="${IOS_PYTHON:-/var/jb/usr/local/bin/python3.14}"
VERSION="$("$PYTHON" - <<'PY'
from yt_dlp.version import __version__
print(__version__)
PY
)"

BUILD_DIR="$ROOT/build/ios-rootless"
STAGE="$BUILD_DIR/stage"
PAYLOAD="$STAGE/var/jb/usr/share/yt-dlp"
VENDOR="$PAYLOAD/vendor"
DEBIAN="$STAGE/DEBIAN"
OUT_DIR="$ROOT/dist/ios-rootless"

rm -rf "$BUILD_DIR"
mkdir -p "$PAYLOAD" "$VENDOR" "$DEBIAN" "$STAGE/var/jb/usr/bin" "$STAGE/var/jb/etc/yt-dlp" "$OUT_DIR"

cp -R "$ROOT/yt_dlp" "$PAYLOAD/"
find "$PAYLOAD" -type d -name __pycache__ -prune -exec rm -rf {} +
find "$PAYLOAD" -type f \( -name '*.pyc' -o -name '*.pyo' \) -delete

"$PYTHON" -m pip install \
  --disable-pip-version-check \
  --no-compile \
  --only-binary=:all: \
  --target "$VENDOR" \
  certifi==2026.4.22 \
  charset-normalizer==3.4.7 \
  idna==3.13 \
  mutagen==1.47.0 \
  requests==2.33.1 \
  urllib3==2.6.3 \
  websockets==16.0 \
  yt-dlp-ejs==0.8.0

find "$VENDOR" -type d -name __pycache__ -prune -exec rm -rf {} +
find "$VENDOR" -type f \( -name '*.pyc' -o -name '*.pyo' \) -delete
find "$VENDOR" -type f -name '*.so' -delete

cat > "$STAGE/var/jb/usr/bin/yt-dlp" <<EOF
#!/var/jb/usr/bin/sh
export YT_DLP_ROOTLESS_PREFIX=/var/jb
export PATH=/var/jb/usr/bin:/var/jb/usr/local/bin:\${PATH:-/usr/bin:/bin:/usr/sbin:/sbin}
export PYTHONPATH=/var/jb/usr/share/yt-dlp/vendor:/var/jb/usr/share/yt-dlp\${PYTHONPATH:+:\$PYTHONPATH}
exec "$IOS_PYTHON" -c 'import sys; sys.argv[0] = "yt-dlp"; import yt_dlp; yt_dlp.main()' "\$@"
EOF
chmod 0755 "$STAGE/var/jb/usr/bin/yt-dlp"

cat > "$STAGE/var/jb/etc/yt-dlp/config" <<'EOF'
--js-runtimes quickjs
EOF

cat > "$DEBIAN/control" <<EOF
Package: $PKG_NAME
Name: yt-dlp
Version: $VERSION
Architecture: $PKG_ARCH
Maintainer: Korboy <korboybeats@gmail.com>
Section: Multimedia
Priority: optional
Depends: xyz.cypwn.python314, ffmpeg, com.korboy.quickjs-ng
Provides: yt-dlp
Conflicts: yt-dlp
Replaces: yt-dlp
Icon: https://repository-images.githubusercontent.com/307260205/b6a8d716-9c7b-40ec-bc44-6422d8b741a0
Description: yt-dlp for jailbroken rootless iOS
EOF

cat > "$DEBIAN/postinst" <<'EOF'
#!/var/jb/usr/bin/sh
set -e
chmod 0755 /var/jb/usr/bin/yt-dlp
exit 0
EOF
chmod 0755 "$DEBIAN/postinst"

dpkg-deb --root-owner-group --build "$STAGE" "$OUT_DIR/${PKG_NAME}_${VERSION}_${PKG_ARCH}.deb"
