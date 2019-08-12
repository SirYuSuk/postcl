#!/usr/bin/env python3
from plyer import notification as ntf
from typing import Any, List
import requests
import sys


def_cmd = "check"


def request_status(b_code: str, p_code: str) -> Any:
    url = f"https://jouw.postnl.nl/web/api/" \
          f"default/shipmentStatus/{b_code}-NL-{p_code}"
    print(url)


def parse_cmd_check(args: List[str]) -> None:
    print(args)
    status = request_status(args[0], args[1])


def parse_argv(argv: List[str]) -> None:
    """
    Parse given user arguments
    """
    # TEMP
    print(argv)

    # Check if a command is given. If not, default is set.
    if len(argv) == 1:
        print("Geen commando gegeven")
        return

    cmd = argv[1]
    args = argv[2:]
    if cmd in cmds:
        globals().get(f"parse_cmd_{cmd}")(args)
    else:
        print("Ongeldig commando")


# Valid user commands
cmds = [c[10:] for c in globals().keys() if c.startswith("parse_cmd")]
print(cmds)

if __name__ == "__main__":
    parse_argv(sys.argv)
