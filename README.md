# yt-dlp-ios

Rootless jailbroken iOS packaging fork of [yt-dlp](https://github.com/yt-dlp/yt-dlp).

This fork keeps yt-dlp's upstream downloader behavior and adds the pieces needed to run it cleanly from NewTerm or another terminal on rootless arm64/arm64e iOS devices.

## What This Fork Adds

* rootless install layout under `/var/jb`
* `/var/jb/usr/bin/yt-dlp` terminal launcher
* rootless system config lookup through `/var/jb/etc/yt-dlp/config`
* vendored pure-Python runtime dependencies inside the package payload
* ffmpeg/ffprobe discovery through rootless PATH entries
* QuickJS runtime selection for YouTube player JavaScript challenges
* rootless `.deb` build script at `scripts/build-ios-rootless-deb.sh`

## Package

Package ID: `com.korboy.yt-dlp`

Sileo repo:

```text
https://korboybeats.github.io
```

The package installs yt-dlp to:

```text
/var/jb/usr/share/yt-dlp
```

The launcher is installed to:

```text
/var/jb/usr/bin/yt-dlp
```

The default config is installed to:

```text
/var/jb/etc/yt-dlp/config
```

## Requirements

* jailbroken rootless iOS on arm64/arm64e
* terminal access, such as NewTerm
* Python 3.14 available at `/var/jb/usr/local/bin/python3.14`
* `ffmpeg` and `ffprobe` available from `/var/jb/usr/bin`
* QuickJS available as `qjs` for full YouTube JavaScript challenge support

The current package depends on:

```text
xyz.cypwn.python314, ffmpeg, com.korboy.quickjs-ng
```

## Usage

Run yt-dlp normally from a terminal:

```sh
yt-dlp "https://www.youtube.com/watch?v=VIDEO_ID"
```

List formats:

```sh
yt-dlp -F "https://www.youtube.com/watch?v=VIDEO_ID"
```

Force MP4 output when compatible formats are available:

```sh
yt-dlp -f "bv*[ext=mp4]+ba[ext=m4a]/b[ext=mp4]/b" --merge-output-format mp4 "https://www.youtube.com/watch?v=VIDEO_ID"
```

Download subtitles:

```sh
yt-dlp --write-subs --write-auto-subs --sub-langs en "https://www.youtube.com/watch?v=VIDEO_ID"
```

Use a cookies file:

```sh
yt-dlp --cookies /path/to/cookies.txt "https://www.youtube.com/watch?v=VIDEO_ID"
```

## Configuration

System config lives at:

```text
/var/jb/etc/yt-dlp/config
```

This fork sets:

```text
--js-runtimes quickjs
```

That tells yt-dlp to use QuickJS when it needs to execute extractor JavaScript, including YouTube player challenge code.

## Building The Rootless Deb

From the repo root:

```sh
scripts/build-ios-rootless-deb.sh
```

The output is written to:

```text
dist/ios-rootless/
```

Useful build overrides:

```sh
PKG_NAME=com.korboy.yt-dlp \
PKG_ARCH=iphoneos-arm64 \
IOS_PYTHON=/var/jb/usr/local/bin/python3.14 \
scripts/build-ios-rootless-deb.sh
```

## Notes

This fork does not replace upstream yt-dlp documentation. For the full command reference, extractor options, format selection syntax, and supported sites, use the upstream docs:

* [yt-dlp README](https://github.com/yt-dlp/yt-dlp#readme)
* [yt-dlp wiki](https://github.com/yt-dlp/yt-dlp/wiki)
* [Supported sites](supportedsites.md)

Upstream yt-dlp is maintained by the yt-dlp project. This fork only carries the rootless iOS packaging changes.

## License

yt-dlp is released into the public domain under the [Unlicense](LICENSE). See [THIRD_PARTY_LICENSES.txt](THIRD_PARTY_LICENSES.txt) for bundled third-party license notices.
