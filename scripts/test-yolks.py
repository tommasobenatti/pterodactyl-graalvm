"""Check the runtime and release configuration: python3 scripts/test-yolks.py."""
from hashlib import sha256
import os
from pathlib import Path
import re
import subprocess
from tempfile import TemporaryDirectory

root = Path(__file__).resolve().parent.parent
dockerfiles = sorted(root.glob('*/*/Dockerfile'))
required = {'bash', 'coreutils', 'curl', 'jq', 'sed', 'unzip'}
for dockerfile in dockerfiles:
    source = dockerfile.read_text()
    packages = set(re.search(r'apt-get install\s+(.+?)(?:&&|\n\s*RUN)', source, re.S)[1]
                   .replace('\\\n', ' ').split())
    assert required <= packages, f'{dockerfile.relative_to(root)} lacks {sorted(required - packages)}'
    assert 'USER' in source and 'container' in source
template = (root / 'CORRETTO/Dockerfile.template').read_text()
for dockerfile in root.glob('CORRETTO/*/Dockerfile'):
    assert dockerfile.read_text() == template.replace('@@JAVA_VERSION@@', dockerfile.parent.name)
workflow = (root / '.github/workflows/docker-image.yml').read_text()
assert workflow.count('no-cache: true') == 2, 'Both image builds must refresh downloaded Java releases'
assert workflow.count('pull: true') == 2, 'Both image builds must refresh base images'
assert workflow.count('run: bash scripts/smoke-test-image.sh') == 2, 'Every image must run its runtime checks'

with TemporaryDirectory() as directory:
    temp = Path(directory)
    log = temp / 'curl.log'
    curl = temp / 'curl'
    curl.write_text('''#!/usr/bin/env bash
set -eu
url=${!#}
printf '%s\\n' "$url" >> "$CURL_LOG"
output=${@: -2:1}
if [[ $url == *.sha256 ]]; then
  printf '%s\\n' "$TEST_SHA256" > "$output"
else
  printf 'test archive' > "$output"
fi
''')
    curl.chmod(0o755)
    env = dict(os.environ, TMPDIR=directory, CURL_LOG=str(log),
               PATH=f'{directory}:{os.environ["PATH"]}',
               TEST_SHA256=sha256(b'test archive').hexdigest())
    installer = ['bash', str(root / 'scripts/install-oracle-graalvm.sh'), '25']
    ea_base = 'https://github.com/graalvm/oracle-graalvm-ea-builds/releases/download'
    for arch, ea_tag, url in (
        ('x64', 'jdk-22.0.0-ea.07', f'{ea_base}/jdk-22.0.0-ea.07/graalvm-jdk-22.0.0-ea.07_linux-x64_bin.tar.gz'),
        ('x64', '', 'https://download.oracle.com/graalvm/25/latest/graalvm-jdk-25_linux-x64_bin.tar.gz'),
        ('x64', 'jdk-25e1-25.0.3-ea.32', f'{ea_base}/jdk-25e1-25.0.3-ea.32/graalvm-jdk-25e1-25.0.3-ea.32_linux-x64_bin.tar.gz'),
        ('aarch64', 'jdk-25i6-25.0.4.1.1-ea.02', f'{ea_base}/jdk-25i6-25.0.4.1.1-ea.02/graalvm-jdk-25i6-25.0.4.1.1-ea.02_linux-aarch64_bin.tar.gz'),
    ):
        log.write_text('')
        result = subprocess.run([*installer, arch, ea_tag], env=env, capture_output=True, text=True)
        assert result.returncode == 0, result.stderr
        assert log.read_text().splitlines() == [url, f'{url}.sha256'], f'Wrong Oracle archive for {ea_tag or "stable"}'
        assert (temp / 'graalvm.tar.gz').read_bytes() == b'test archive'

    log.write_text('')
    result = subprocess.run([*installer, 'x64', '../other-release'], env=env, capture_output=True)
    assert result.returncode != 0 and not log.read_text(), 'Malformed EA tags must fail before downloading'
    env['TEST_SHA256'] = '0' * 64
    result = subprocess.run([*installer, 'x64', 'jdk-26.0.0-ea.13'], env=env, capture_output=True)
    assert result.returncode != 0, 'EA archives with incorrect SHA-256 must be rejected'

ea_releases = re.findall(r'tag: EA-([\da-z]+)\s+ea_release: (jdk-[\w.-]+)', workflow)
assert {channel for channel, _ in ea_releases} == {'22', '23', '24', '25', '25e1', '25i1', '25i2', '25i3',
                                                 '25i4', '25i5', '25i6', '26'}, 'Incomplete EA release matrix'
assert len(ea_releases) == len({channel for channel, _ in ea_releases}), 'Duplicate EA image tags'
for channel, tag in ea_releases:
    assert re.match(rf'jdk-{channel}[.-]', tag), f'{tag} belongs to a different EA line'

for version in (11, 17):
    source = (root / f'EE/{version}/Dockerfile').read_text()
    assert '--mount=from=graalvm' in source and 'sha256sum -c' in source, 'EE must verify a supplied archive'
assert not re.search(r'\b(?:path: EE/|tag: EE-)', workflow), 'OTN binaries must stay out of the publishing matrix'

print(f'PASS: runtime dependencies and generated files for {len(dockerfiles)} yolks, CI gates, Oracle downloads and checksum checks')
