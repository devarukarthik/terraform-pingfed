# ─── Authentication Policy Contracts ──────────────────────────────────────────
#
# core_attributes (e.g. "subject") are READ-ONLY — PF populates them automatically.
# Only set extended_attributes here.

resource "pingfederate_authentication_policy_contract" "contracts" {
  for_each = var.authn_policy_contracts

  name = each.value.name

  # extended_attributes is a set of objects with a required "name" field
  extended_attributes = [
    for attr in each.value.extended_attributes : {
      name = attr
    }
  ]
}
