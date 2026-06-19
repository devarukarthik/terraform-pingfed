# ─── Authentication Policy Contracts ──────────────────────────────────────────
#
# Policy contracts define the attributes that flow out of an authentication
# policy into SP connections, OAuth token mapping, etc.
#
# core_attributes: always includes "subject" — add others as needed
# extended_attributes: any additional user attributes (e.g. "email", "groups")

resource "pingfederate_authentication_policy_contract" "contracts" {
  for_each = var.authn_policy_contracts

  name = each.value.name

  core_attributes = [
    for attr in each.value.core_attributes : {
      name = attr
    }
  ]

  extended_attributes = [
    for attr in each.value.extended_attributes : {
      name = attr
    }
  ]
}
