"""Offline regression for the Leaf Fill v3 installer and launcher."""
import hashlib
import json
import os
from pathlib import Path
import subprocess
import sys
from tempfile import TemporaryDirectory

egg_file = Path(sys.argv[1]) if len(sys.argv) > 1 else Path(__file__).parents[1] / "eggs/egg-leaf.json"
installation = json.loads(egg_file.read_text())["scripts"]["installation"]
installer = installation.get("content", installation.get("script"))
launcher = installer.split("<<'PTERO_LEAF_START'\n", 1)[1].split("\nPTERO_LEAF_START", 1)[0]
origin = "https://dl.leafmc.one/v3/projects/leaf"
asset = "https://dl-data.leafmc.one/leaf/26.3/28/leaf-26.3-28.jar"
jar = b"offline Leaf test JAR"
build = {"id": 28, "channel": "ALPHA", "downloads": {"server:default": {
    "url": asset, "checksums": {"sha256": hashlib.sha256(jar).hexdigest()},
}}}

with TemporaryDirectory() as directory:
    work = Path(directory)
    tools = work / "bin"
    tools.mkdir()
    (work / "fixture.jar").write_bytes(jar)
    (work / "server.properties").touch()
    (tools / "curl").write_text(f"#!{sys.executable}\n" + '''
import json, os, pathlib, shutil, sys
args = sys.argv[1:]
url = args[-1]
with open("requests.log", "a") as log:
    log.write(url + "\\n")
if url == "https://dl.leafmc.one/v3/projects/leaf":
    print(json.dumps({"versions": {"1.21": ["1.21.11"], "26.3": ["26.3"], "26.2": ["26.2"]}}))
elif url == "https://dl.leafmc.one/v3/projects/leaf/versions/26.3/builds/latest":
    if os.environ.get("TEST_OFFLINE"):
        sys.exit(22)
    print(pathlib.Path("build.json").read_text())
elif url == "https://dl-data.leafmc.one/leaf/26.3/28/leaf-26.3-28.jar":
    shutil.copyfile("fixture.jar", args[args.index("-o")+1])
else:
    sys.exit(22)
''')
    for name in ("java", "apk"):
        (tools / name).write_text("#!/bin/sh\nexit 0\n")
    for executable in tools.iterdir():
        executable.chmod(0o755)
    env = dict(os.environ, PATH=f"{tools}:{os.environ['PATH']}",
               MINECRAFT_VERSION="26.3", SERVER_JARFILE="server.jar", AUTO_UPDATE="1")

    def run(script=launcher, metadata=build, **settings):
        (work / "build.json").write_text(json.dumps(metadata))
        (work / "requests.log").write_text("")
        container_dir = "/mnt/server" if script == installer else "/home/container"
        script = script.replace(f"cd {container_dir}", f'cd "{work}"')
        return subprocess.run(["bash"], input=script, text=True, cwd=work, env=dict(env, **settings),
                              capture_output=True)

    result = run()
    assert result.returncode == 0, result.stdout + result.stderr
    assert (work / "server.jar").read_bytes() == jar
    assert (work / ".leaf-build").read_text().strip() == "26.3-28"
    assert (work / "requests.log").read_text().splitlines() == [f"{origin}/versions/26.3/builds/latest", asset]
    assert run(MINECRAFT_VERSION="latest").returncode == 0
    assert (work / "requests.log").read_text().splitlines() == [origin, f"{origin}/versions/26.3/builds/latest"]
    (work / "server.jar").write_bytes(b"existing JAR")
    (work / ".leaf-build").write_text("26.3-22\n")
    for metadata, settings in [
        (build, {"TEST_OFFLINE": "1"}),
        ({"id": 28, "downloads": {"server:default": {"url": asset, "checksums": {"sha256": "0" * 64}}}}, {}),
        ({"id": 28, "downloads": {"server:default": {
            "url": "https://example.invalid/leaf.jar", "checksums": {"sha256": "0" * 64},
        }}}, {}),
    ]:
        result = run(metadata=metadata, **settings)
        assert result.returncode == 0 and "starting the existing JAR" in result.stdout
        assert (work / "server.jar").read_bytes() == b"existing JAR"
        assert (work / ".leaf-build").read_text() == "26.3-22\n"
        assert not (work / "server.jar.download").exists()
        assert "example.invalid" not in (work / "requests.log").read_text()
    assert run(AUTO_UPDATE="0").returncode == 0 and not (work / "requests.log").read_text()
    (work / "server.jar").unlink()
    assert run(TEST_OFFLINE="1").returncode != 0
    assert run(script=installer).returncode == 0
    assert (work / ".pterodactyl/leaf-start.sh").read_text() == launcher + "\n"
    assert (work / "server.jar").read_bytes() == jar

print(f"PASS: Fill v3 selection, checksum, fallback and installer ({egg_file.name})")
