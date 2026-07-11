# Pterodactyl Java yolks

![build java yolks](https://github.com/tommasobenatti/pterodactyl-graalvm/actions/workflows/docker-image.yml/badge.svg)
![license mit](https://img.shields.io/badge/license-MIT-green)

Java runtime images for Pterodactyl. All published tags target `linux/amd64` and `linux/arm64`, except legacy `CE-8`, whose upstream release is available only for `linux/amd64`.

All images include the runtime tools required by the Leaf and Velocity boot updaters: `bash`, `curl`, `jq`, `sed`, and `sha256sum`. Containers run as the unprivileged `container` user in `/home/container`.

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

## Building locally

Build a Corretto image for one platform:

```bash
docker buildx build \
  --platform linux/amd64 \
  --build-arg JAVA_VERSION=25 \
  --file CORRETTO/Dockerfile \
  --tag pterodactyl-corretto:25 \
  --load \
  .
```

The GitHub Actions workflow publishes every configured GraalVM and Corretto tag for both supported architectures on pushes to `master`.
