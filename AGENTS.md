# Working on Pterodactyl Java yolks

- Dockerfiles build from the repository root. Published images share `entrypoint.sh` and run as `container` in `/home/container`.
- The Docker workflow owns the published tag list and platforms. Preserve the pull and no-cache flags, and promote only after the smoke tests pass. `CE-8` is amd64-only.
- Check upstream archives and SHA-256 files when changing GraalVM pins. For Oracle Early Access, match the full upstream release tag to its `EA-*` matrix entry. Legacy Enterprise Edition builds take licensed local archives and stay outside public CI.
- Regenerate the Corretto Dockerfiles with `node scripts/generate-corretto-dockerfiles.mjs` after editing their template.
- Run `python3 scripts/test-yolks.py` and `bash -n` on changed shell files. Run `actionlint` when editing the workflow. With a Docker daemon, run `bash scripts/smoke-test-image.sh IMAGE PLATFORMS` against the built image.
