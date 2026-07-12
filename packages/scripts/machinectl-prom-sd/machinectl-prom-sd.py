#!/usr/bin/env python3
"""Generate a Prometheus file_sd_config from running systemd-nspawn machines."""

import argparse
import json
import os
import socket
import subprocess
import sys

PROBE_TIMEOUT = 0.5


def port_open(host: str, port: int) -> bool:
    try:
        with socket.create_connection((host, port), timeout=PROBE_TIMEOUT):
            return True
    except OSError:
        return False


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("output", help="Path to write the file_sd JSON to")
    parser.add_argument(
        "--ports",
        required=True,
        type=lambda s: [int(p) for p in s.split(",")],
        help="Comma-separated list of TCP ports to probe on each machine",
    )
    args = parser.parse_args()

    raw = subprocess.check_output(["machinectl", "list", "-o", "json", "--no-pager"])
    machines = json.loads(raw)

    groups = []
    for m in machines:
        name = m["machine"]
        targets = [f"{name}:{p}" for p in args.ports if port_open(name, p)]
        if targets:
            groups.append({"targets": targets, "labels": {"instance": name}})

    tmp = f"{args.output}.tmp"
    with open(tmp, "w") as f:
        json.dump(groups, f, indent=2)
        f.write("\n")
    os.replace(tmp, args.output)
    return 0


if __name__ == "__main__":
    sys.exit(main())
