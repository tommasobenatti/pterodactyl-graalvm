# Pterodactyl Java yolks

![build java yolks](https://github.com/tommasobenatti/pterodactyl-graalvm/actions/workflows/docker-image.yml/badge.svg)
![license mit](https://img.shields.io/badge/license-MIT-green)

Java runtime images for Pterodactyl. All published tags target `linux/amd64` and `linux/arm64`, except legacy `CE-8`, whose upstream release is available only for `linux/amd64`.

All images explicitly install the runtime tools required by the Leaf, Velocity and Canvas boot updaters: `bash`, `curl`, `jq`, `sed`, `sha256sum` (from `coreutils`), and `unzip`. Installing a package in the egg's Alpine installation container does not add it to the Debian runtime image. Containers run as the unprivileged `container` user in `/home/container`.

## Amazon Corretto tags

These images are built directly from the official Amazon Corretto archives. Every archive is verified against Amazon's SHA-256 checksum before extraction.

| Java | Image |
|------|-------|
| 8 | `ghcr.io/tommasobenatti/pterodactyl-graalvm:CORRETTO-8` |
| 11 | `ghcr.io/tommasobenatti/pterodactyl-graalvm:CORRETTO-11` |
| 15 | `ghcr.io/tommasobenatti/pterodactyl-graalvm:CORRETTO-15` |
| 16 | `ghcr.io/tommasobenatti/pterodactyl-graalvm:CORRETTO-16` |
| 17 | `ghcr.io/tommasobenatti/pterodactyl-graalvm:CORRETTO-17` |
| 18 | `ghcr.io/tommasobenatti/pterodactyl-graalvm:CORRETTO-18` |
| 19 | `ghcr.io/tommasobenatti/pterodactyl-graalvm:CORRETTO-19` |
| 20 | `ghcr.io/tommasobenatti/pterodactyl-graalvm:CORRETTO-20` |
| 21 | `ghcr.io/tommasobenatti/pterodactyl-graalvm:CORRETTO-21` |
| 22 | `ghcr.io/tommasobenatti/pterodactyl-graalvm:CORRETTO-22` |
| 23 | `ghcr.io/tommasobenatti/pterodactyl-graalvm:CORRETTO-23` |
| 24 | `ghcr.io/tommasobenatti/pterodactyl-graalvm:CORRETTO-24` |
| 25 | `ghcr.io/tommasobenatti/pterodactyl-graalvm:CORRETTO-25` |
| 26 | `ghcr.io/tommasobenatti/pterodactyl-graalvm:CORRETTO-26` |

Amazon does not publish official Corretto builds for Java 9, 10, 12, 13, or 14.

For production Minecraft servers, prefer supported LTS releases such as Corretto 21 or Corretto 25. Non-LTS tags are retained for compatibility testing and legacy workloads.

## Oracle GraalVM JDK tags

| Java | Image |
|------|-------|
| 17 | `ghcr.io/tommasobenatti/pterodactyl-graalvm:JDK-17` |
| 20 | `ghcr.io/tommasobenatti/pterodactyl-graalvm:JDK-20` |
| 21 | `ghcr.io/tommasobenatti/pterodactyl-graalvm:JDK-21` |
| 22 | `ghcr.io/tommasobenatti/pterodactyl-graalvm:JDK-22` |
| 23 | `ghcr.io/tommasobenatti/pterodactyl-graalvm:JDK-23` |
| 24 | `ghcr.io/tommasobenatti/pterodactyl-graalvm:JDK-24` |
| 25 | `ghcr.io/tommasobenatti/pterodactyl-graalvm:JDK-25` |

There is no `JDK-19` build in this repository.

`JDK-17` tracks Oracle's supported official container image. `JDK-20`, `JDK-22`, `JDK-23`, and `JDK-24` are end-of-life compatibility images and should not be selected for new production servers. Oracle archive downloads are verified with the published SHA-256 checksum.

## GraalVM Community Edition tags

Community Edition images are available as `CE-8`, `CE-11`, `CE-17`, and `CE-19` through `CE-25`.

Every CE archive is verified against its official SHA-256 checksum. `CE-25` uses GraalVM 25.5.5.0.3 with Java 25.0.5.0.3. Legacy `CE-8` uses its last published Java 8 archive (GraalVM 21.3.1). The remaining pins use the latest archives available for their Java majors. [Upstream CE releases](https://github.com/graalvm/graalvm-ce-builds/releases)

## Oracle GraalVM Early Access tags

The workflow builds one image per upstream EA line for Linux amd64 and arm64. Tags are `EA-22`, `EA-23`, `EA-24`, `EA-25`, `EA-25e1`, `EA-25i1` through `EA-25i6`, and `EA-26`. Each pins the latest snapshot of its line at the time of the refresh in `.github/workflows/docker-image.yml`. Oracle provides these builds for development and testing. [Upstream EA releases](https://github.com/graalvm/oracle-graalvm-ea-builds/releases)

To build any published snapshot, pass its full upstream tag as `GRAALVM_EA_RELEASE`. The installer verifies the SHA-256 published with the matching Linux archive.

```bash
docker buildx build --pull --no-cache --platform linux/amd64 --load \
  --file JDK/25/Dockerfile \
  --build-arg GRAALVM_EA_RELEASE=jdk-25i6-25.0.4.1.1-ea.02 \
  --tag pterodactyl-graalvm:EA-25i6 .
```

## Oracle GraalVM Enterprise Edition

Use `EE/11/Dockerfile` or `EE/17/Dockerfile` to build an image from the matching Linux Enterprise Edition Core archive. Download the archive for your Java version and architecture from Oracle under the applicable license. The legacy binaries are restricted under the Oracle Technology Network license, so build locally under your own entitlement. [Oracle Downloads](https://www.oracle.com/downloads/graalvm-downloads.html) · [OTN license](https://www.oracle.com/downloads/licenses/graalvm-otn-license.html)

Put the archive in a directory outside the repository as `graalvm.tar.gz`. Set `GRAALVM_SHA256` to Oracle's published checksum for that archive. This example builds the Java 17 amd64 image.

```bash
docker buildx build --pull --platform linux/amd64 --load \
  --file EE/17/Dockerfile \
  --build-context graalvm=/path/to/oracle-download \
  --build-arg "GRAALVM_SHA256=$GRAALVM_SHA256" \
  --tag pterodactyl-graalvm:EE-17 .
bash scripts/smoke-test-image.sh pterodactyl-graalvm:EE-17 linux/amd64
```

## Building locally

Build a Corretto image for one platform:

```bash
docker buildx build \
  --platform linux/amd64 \
  --file CORRETTO/25/Dockerfile \
  --tag pterodactyl-corretto:25 \
  --load \
  .
```

The GitHub Actions workflow refreshes every configured GraalVM and Corretto tag on pushes to `master`, or through its manual Run workflow action. Builds pull current base images and bypass Docker's build cache so "latest" Java archives are actually downloaded again. Oracle JDK and Corretto images already use their official latest-release URLs; no new major version is substituted for a tag.

Each build first publishes a commit-specific candidate tag. The workflow runs Java, checks the updater tools, tests a JAR archive and exercises the Pterodactyl entrypoint on every supported architecture before promoting the candidate to its normal tag. A failed check leaves the normal tag unchanged. Pull requests test the local amd64 image without publishing.

Run `python3 scripts/test-yolks.py` to check the Dockerfiles, generated Corretto files, Oracle download handling and CI refresh gates. To use a refreshed image on an existing Pterodactyl server, stop and start it after publication so Wings pulls the new tag. If the egg installation never produced a JAR, correct its settings and reinstall it as well (`MINECRAFT_VERSION=26.3`, `INCLUDE_EXPERIMENTAL=1` for Canvas alpha).

Run `node scripts/generate-corretto-dockerfiles.mjs` after changing `CORRETTO/Dockerfile.template` to regenerate every version-specific Dockerfile.
