# ─── OAuth Scopes ──────────────────────────────────────────────────────────────
#
# Custom scopes are added to the global OAuth server settings in PingFederate.
# Scope groups bundle multiple scopes under a single alias.

resource "pingfederate_oauth_server_settings_scopes_common_scope" "scopes" {
  for_each = var.oauth_scopes

  name        = each.key
  description = each.value.description
  dynamic     = each.value.dynamic
}

# ─── OAuth Scope Groups ────────────────────────────────────────────────────────

resource "pingfederate_oauth_server_settings_scopes_common_scope_group" "scope_groups" {
  for_each = var.oauth_scope_groups

  name        = each.key
  description = each.value.description
  scopes      = each.value.scopes

  depends_on = [
    pingfederate_oauth_server_settings_scopes_common_scope.scopes
  ]
}
