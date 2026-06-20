#!/usr/bin/env python3
"""Create (or find) a GitHub Project V2 and print its number, for use as
`project_number` in the backlog manifest. Field creation (Status/Backlog,
Sprint, Size, Estimate) is handled idempotently by create_issues.py.

Usage:
  python3 setup_project.py --owner rubentanahara --title "Acme Backlog"
  python3 setup_project.py --owner my-org --title "Acme" --owner-type org

Prints a line:  PROJECT_NUMBER=<n>  PROJECT_URL=<url>
"""
import argparse
import json
import subprocess
import sys


def run(args):
    p = subprocess.run(args, capture_output=True, text=True)
    if p.returncode != 0:
        sys.exit(f"command failed: {' '.join(args)}\n{p.stderr}")
    return p.stdout


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--owner", required=True, help="user or org login")
    ap.add_argument("--title", required=True)
    args = ap.parse_args()

    listing = json.loads(run(["gh", "project", "list", "--owner", args.owner,
                              "--format", "json"]))
    for p in listing.get("projects", []):
        if p.get("title") == args.title:
            print(f"PROJECT_NUMBER={p['number']}  PROJECT_URL={p.get('url', '')}  (existing)")
            return
    out = json.loads(run(["gh", "project", "create", "--owner", args.owner,
                          "--title", args.title, "--format", "json"]))
    print(f"PROJECT_NUMBER={out['number']}  PROJECT_URL={out.get('url', '')}  (created)")


if __name__ == "__main__":
    main()
