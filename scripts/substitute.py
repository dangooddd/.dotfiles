#!/usr/bin/env python

import json
from argparse import ArgumentParser
from pathlib import Path


def mix(base: str, overlay: str, alpha: float) -> str:
    channels = []

    for index in (0, 2, 4):
        start = int(base[index : index + 2], 16)
        end = int(overlay[index : index + 2], 16)
        channels.append(int(start + (end - start) * alpha + 0.5))

    return "".join(f"{channel:02X}" for channel in channels)

if __name__ == "__main__":
    parser = ArgumentParser("Substitute json into template file.")
    parser.add_argument("--json", type=Path)
    parser.add_argument("--template", type=Path)
    args = parser.parse_args()

    json_data = json.loads(args.json.read_text())
    template_text = args.template.read_text()
    result = eval(
        "f" + repr(template_text),
        {"__builtins__": {}},
        {**json_data, "name": args.json.stem, "mix": mix},
    )
    print(result, end="")
