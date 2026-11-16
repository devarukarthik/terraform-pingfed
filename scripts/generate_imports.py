#!/usr/bin/env python3
"""
generate_imports.py
-------------------
Queries a PingFederate Admin API and generates a Terraform imports.tf file
containing `import` blocks for all discovered resources.

After running this script:
  1. Review imports.tf
  2. Run: terraform plan -generate-config-out=generated.tf
  3. Review generated.tf, clean up any read-only / computed fields
  4. Run: terraform apply

Usage:
  python3 scripts/generate_imports.py \
    --host https://localhost:9999 \
    --username administrator \
    --password 2Federate \
    --insecure            # skip TLS verification for self-signed certs
"""

import argparse
import json
import sys
import urllib.request
import urllib.error
import ssl
import base64
from pathlib import Path

# ── Resource definitions ────────────────────────────────────────────────────────
# Each entry: (api_path, items_key, id_field, tf_resource, label_field)
#   api_path    — PF Admin API path
#   items_key   — JSON key that holds the list (None = response IS the object)
#   id_field    — field in each item used as the Terraform import ID
#   tf_resource — Terraform resource type
#   label_field — field used to generate a readable Terraform label
RESOURCES = [
    (
        "/pf-admin-api/v1/oauth/clients",
        "items",
        "clientId",
        "pingfederate_oauth_client",
        "clientId",
    ),
    (
        "/pf-admin-api/v1/oauth/accessTokenManagers",
        "items",
        "id",
        "pingfederate_oauth_access_token_manager",
        "name",
    ),
    (
        "/pf-admin-api/v1/authenticationPolicyContracts",
        "items",
        "id",
        "pingfederate_authentication_policy_contract",
        "name",
    ),
    (
        "/pf-admin-api/v1/idp/adapters",
        "items",
        "id",
        "pingfederate_idp_adapter",
        "name",
    ),
    (
        "/pf-admin-api/v1/sp/idpConnections",
        "items",
        "entityId",
        "pingfederate_idp_sp_connection",
        "name",
    ),
    (
        "/pf-admin-api/v1/idp/spConnections",
        "items",
        "entityId",
        "pingfederate_sp_idp_connection",
        "name",
    ),
    (
        "/pf-admin-api/v1/passwordCredentialValidators",
        "items",
        "id",
        "pingfederate_password_credential_validator",
        "name",
    ),
    (
        "/pf-admin-api/v1/authenticationSelectors",
        "items",
        "id",
        "pingfederate_authentication_selector",
        "name",
    ),
    (
        "/pf-admin-api/v1/notificationPublishers",
        "items",
        "id",
        "pingfederate_notification_publisher",
        "name",
    ),
]

# Singleton resources (no list endpoint — import ID is a placeholder)
SINGLETONS = [
    (
        "/pf-admin-api/v1/oauth/authServerSettings",
        "pingfederate_oauth_server_settings",
        "oauthServerSettings",
        "main",
    ),
    (
        "/pf-admin-api/v1/serverSettings",
        "pingfederate_server_settings",
        "serverSettings",
        "main",
    ),
]


def make_label(value: str) -> str:
    """Convert an arbitrary string into a valid Terraform label."""
    return "".join(c if c.isalnum() or c in "-_" else "_" for c in value).strip("_")


def fetch(host: str, path: str, username: str, password: str, verify_tls: bool) -> dict | None:
    url = f"{host}{path}"
    credentials = base64.b64encode(f"{username}:{password}".encode()).decode()
    req = urllib.request.Request(
        url,
        headers={
            "Authorization": f"Basic {credentials}",
            "Accept": "application/json",
            "X-XSRF-Header": "PingFederate",
        },
    )
    ctx = ssl.create_default_context()
    if not verify_tls:
        ctx.check_hostname = False
        ctx.verify_mode = ssl.CERT_NONE

    try:
        with urllib.request.urlopen(req, context=ctx, timeout=10) as resp:
            return json.loads(resp.read().decode())
    except urllib.error.HTTPError as e:
        if e.code == 404:
            return None  # resource type not present/supported — skip
        print(f"  ⚠  HTTP {e.code} for {path} — skipping", file=sys.stderr)
        return None
    except Exception as ex:
        print(f"  ⚠  Error fetching {path}: {ex} — skipping", file=sys.stderr)
        return None


def generate_imports(host, username, password, verify_tls, out_path):
    blocks = []
    summary = []

    print("\nDiscovering PingFederate resources...\n")

    # ── List resources ──────────────────────────────────────────────────────────
    for api_path, items_key, id_field, tf_resource, label_field in RESOURCES:
        print(f"  Checking {api_path}...")
        data = fetch(host, api_path, username, password, verify_tls)
        if data is None:
            continue

        items = data.get(items_key, []) if items_key else [data]
        if not items:
            print(f"    → 0 items")
            continue

        print(f"    → {len(items)} item(s) found")
        for item in items:
            resource_id = item.get(id_field, "")
            label_raw = item.get(label_field, resource_id)
            label = make_label(label_raw)

            blocks.append(
                f'import {{\n'
                f'  to = {tf_resource}.{label}\n'
                f'  id = "{resource_id}"\n'
                f'}}\n'
            )
            summary.append(f"  {tf_resource}.{label}  (id={resource_id})")

    # ── Singleton resources ─────────────────────────────────────────────────────
    for api_path, tf_resource, import_id, label in SINGLETONS:
        print(f"  Checking {api_path} (singleton)...")
        data = fetch(host, api_path, username, password, verify_tls)
        if data is None:
            continue

        print(f"    → singleton found")
        blocks.append(
            f'import {{\n'
            f'  to = {tf_resource}.{label}\n'
            f'  id = "{import_id}"\n'
            f'}}\n'
        )
        summary.append(f"  {tf_resource}.{label}  (singleton)")

    # ── Write output ────────────────────────────────────────────────────────────
    out = Path(out_path)
    out.parent.mkdir(parents=True, exist_ok=True)

    header = (
        "# Auto-generated by generate_imports.py\n"
        "# \n"
        "# Next steps:\n"
        "#   1. Review this file\n"
        "#   2. Run: terraform plan -generate-config-out=generated.tf\n"
        "#   3. Review generated.tf — remove read-only/computed fields\n"
        "#   4. Rename/refactor generated.tf into your .tf files\n"
        "#   5. Run: terraform apply\n"
        "# \n"
        "# WARNING: generated.tf may contain sensitive values.\n"
        "#          Review before committing to source control.\n\n"
    )

    out.write_text(header + "\n".join(blocks))

    print(f"\n✅  Generated {len(blocks)} import block(s) → {out_path}")
    print("\nResources to import:")
    for line in summary:
        print(line)

    print(
        f"\nNext step:\n"
        f"  terraform plan -generate-config-out=generated.tf\n"
    )


def main():
    parser = argparse.ArgumentParser(description="Generate Terraform import blocks from PingFederate")
    parser.add_argument("--host", default="https://localhost:9999", help="PF Admin API base URL")
    parser.add_argument("--username", default="administrator")
    parser.add_argument("--password", required=True)
    parser.add_argument("--insecure", action="store_true", help="Skip TLS verification")
    parser.add_argument("--out", default="imports.tf", help="Output file path")
    args = parser.parse_args()

    generate_imports(
        host=args.host,
        username=args.username,
        password=args.password,
        verify_tls=not args.insecure,
        out_path=args.out,
    )


if __name__ == "__main__":
    main()
