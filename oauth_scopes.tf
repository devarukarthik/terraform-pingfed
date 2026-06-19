# ─── OAuth Server Settings (Scopes & Scope Groups) ────────────────────────────
#
# In provider v1.8.0, scopes are NOT standalone resources — they are managed
# as inline sets within the singleton pingfederate_oauth_server_settings resource.
#
# This resource manages the OAuth authorization server settings including
# common scopes and scope groups. Required server-level fields are exposed
# as variables with sensible defaults.
#
# NOTE: This is a singleton resource. Importing it on an existing PF instance:
#   terraform import pingfederate_oauth_server_settings.main id

resource "pingfederate_oauth_server_settings" "main" {
  # ── Required server settings ──────────────────────────────────────────────
  authorization_code_entropy = var.oauth_server_settings.authorization_code_entropy
  authorization_code_timeout = var.oauth_server_settings.authorization_code_timeout
  refresh_rolling_interval   = var.oauth_server_settings.refresh_rolling_interval
  refresh_token_length       = var.oauth_server_settings.refresh_token_length

  # ── Common scopes ─────────────────────────────────────────────────────────
  scopes = [
    for k, v in var.oauth_scopes : {
      name        = k
      description = v.description
      dynamic     = v.dynamic
    }
  ]

  # ── Common scope groups ───────────────────────────────────────────────────
  scope_groups = [
    for k, v in var.oauth_scope_groups : {
      name        = k
      description = v.description
      scopes      = v.scopes
    }
  ]
}
