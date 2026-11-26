# Custom Xray-core build (allowInsecure)

Xray-core removed the TLS `allowInsecure` option (it errors out since 2026-06-01).
This fork builds `libv2ray.aar` itself, against Xray-core with the option restored, so
nodes with **Allow Insecure** turned on (and no certificate pin) connect again. The app
already writes `"allowInsecure": true` in `CoreOutboundBuilder.populateTlsSettings`.

- `XRAY_VERSION` – the upstream Xray-core tag the patch is applied to.
- `patches/` – patches applied on top of that tag (same patch as the v2rayN fork).
- `build-libv2ray.sh <out-dir>` – clones and patches Xray-core, points the
  `AndroidLibXrayLite` submodule at it with `go mod edit -replace`, and runs
  `gomobile bind` (all Android ABIs, `-androidapi 24`).

`.github/workflows/build.yml` runs the script instead of downloading the upstream
`libv2ray.aar` release.

## Moving to a newer Xray-core

1. Put the new tag in `XRAY_VERSION`.
2. Check out the matching `AndroidLibXrayLite` tag in the submodule (its `go.mod`
   should pin the same Xray-core commit) and commit the submodule change.
3. If the patch no longer applies, re-create it on the new tag (see the v2rayN fork's
   `xray-custom/README.md`).
4. Push. CI builds the AAR and APKs.

`allowInsecure` turns off server certificate checks, which leaves the connection
open to man-in-the-middle attacks. Prefer certificate pinning where you can.
