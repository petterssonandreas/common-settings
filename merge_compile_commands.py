#!/usr/bin/env python
""" Merge multiple compile commands """

import argparse
import json
import sys
from typing import Dict, List


def main():
    """ main func """
    parser = argparse.ArgumentParser()
    parser.add_argument("output", type=str, help="The merged output file")
    parser.add_argument("input", type=str, nargs="+",
                        help="Input compile commands file")
    args = parser.parse_args()

    merged_json: List[Dict[str, str]] = []

    for input_filename in args.input:
        try:
            with open(input_filename, encoding="utf-8") as input_file:
                merged_json.extend(json.load(input_file))
        except FileNotFoundError:
            print(f"'{input_filename}: No such file, ignoring'")

    with open(args.output, mode="w", encoding="utf-8") as output_file:
        json.dump(merged_json, output_file, indent=2)

    return 0


if __name__ == "__main__":
    sys.exit(main())
