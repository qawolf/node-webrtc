<h1 align="center">
  <img height="120px" src="https://upload.wikimedia.org/wikipedia/commons/d/d9/Node.js_logo.svg">&nbsp;&nbsp;&nbsp;&nbsp;
  <img height="120px" src="https://webrtc.github.io/webrtc-org/assets/images/webrtc-logo-vert-retro-dist.svg">
</h1>

[![NPM](https://img.shields.io/npm/v/@qawolf/wrtc.svg)](https://www.npmjs.com/package/@qawolf/wrtc)

node-webrtc is a Node.js Native Addon that provides bindings to [WebRTC
M98](https://webrtc.googlesource.com/src/+/branch-heads/4758). This project is
aiming for spec-compliance and will eventually be tested using the W3C's
[web-platform-tests](https://github.com/web-platform-tests/wpt) project. A
number of [nonstandard APIs](docs/nonstandard-apis.md) for testing are also
included.

## Install

```
npm install @qawolf/wrtc
```

Installing from NPM downloads a prebuilt binary for your operating system ×
architecture, based on optional dependency filters.

To install a debug build or cross-compile, you should [build from
source](docs/build-from-source.md).

## Supported Platforms

The following platforms are confirmed to work with node-webrtc and have
prebuilt binaries available. Since node-webrtc targets [N-API version
3](https://nodejs.org/api/n-api.html), there may be additional platforms
supported that are not listed here. If your platform is not supported, you may
still be able to [build from source](docs/build-from-source.md).

<table>
  <thead>
    <tr>
      <td colspan="2" rowspan="2"></td>
      <th colspan="2">Linux</th>
      <th colspan="2">macOS</th>
      <th>Windows</th>
    </tr>
    <tr>
      <th>x64</th>
      <th>arm64</th>
      <th>x64</th>
      <th>arm64</th>
      <th>x64</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th rowspan="2">Node</th>
      <th>20</th>
      <td align="center">✓</td>
      <td align="center">?</td>
      <td align="center">✓</td>
      <td align="center">✓</td>
      <td align="center">✓</td>
    </tr>
    <tr>
      <th>22</th>
      <td align="center">✓</td>
      <td align="center">?</td>
      <td align="center">✓</td>
      <td align="center">✓</td>
      <td align="center">✓</td>
    </tr>
  </tbody>
</table>

## Examples

See [node-webrtc/node-webrtc-examples](https://github.com/node-webrtc/node-webrtc-examples).

## Maintainer Guide: Building & Publishing

This fork (`@qawolf/wrtc`) includes custom scripts to facilitate building for Linux (via Docker) and macOS.

### Prerequisites

Ensure you are authenticated with the GitHub Package Registry. Your `~/.npmrc` should be configured with your PAT, or you can use the project-level `.npmrc` provided.

### 1. Build Linux Artifacts (x64 and arm64)

To build the Linux binaries (used in production environments), use the provided Docker scripts. These handle cross-compilation quirks and patch the binaries for portability.

**Parallel Build (Recommended):**
Builds both x64 and arm64 binaries in parallel.

```bash
./scripts/build-parallel-docker.sh
```

**Single Architecture Build:**
You can also build for a specific architecture by setting `TARGET_ARCH` (defaults to x64).

```bash
# Build for x64
./scripts/build-incremental-docker.sh

# Build for arm64
TARGET_ARCH=arm64 ./scripts/build-incremental-docker.sh
```

Artifacts will be placed in `prebuilds/linux-x64/` and `prebuilds/linux-arm64/`.

### 2. Publishing

Publishing must be done in a specific order: first the platform-specific binaries, then the main package.

**Step A: Publish Platform Binaries**

Navigate to each built platform folder in `prebuilds/` and publish them.

```bash
# Example for Linux x64
cd prebuilds/linux-x64
npm publish
cd ../..

# Example for Linux arm64
cd prebuilds/linux-arm64
npm publish
cd ../..
```

**Step B: Publish Main Package**
Once the platform binaries are published, publish the root package. It references the others as `optionalDependencies`.

```bash
npm publish
```
