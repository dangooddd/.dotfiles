#!/usr/bin/env python

import json
from argparse import ArgumentParser
from pathlib import Path
from string import Template

if __name__ == "__main__":
    parser = ArgumentParser("Substitute json into template file.")
    parser.add_argument("--json", type=Path)
    parser.add_argument("--template", type=Path)
    args = parser.parse_args()

    json_data = json.loads(args.json.read_text())
    template_text = args.template.read_text()
    print(Template(template_text).substitute(json_data))
