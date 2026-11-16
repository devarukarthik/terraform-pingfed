# ─── OAuth / OIDC Clients ──────────────────────────────────────────────────────
#
# Driven by var.oauth_clients. Add entries to terraform.tfvars to create clients.
#
# grant_types supported values (must be UPPERCASE):
#   AUTHORIZATION_CODE | IMPLICIT | CLIENT_CREDENTIALS | RESOURCE_OWNER_CREDENTIALS |
#   REFRESH_TOKEN | DEVICE_CODE | ACCESS_TOKEN_VALIDATION | CIBA | TOKEN_EXCHANGE | EXTENSION
#
# client_auth.type values:
#   NONE | SECRET | CERTIFICATE | PRIVATE_KEY_JWT

resource "pingfederate_oauth_client" "clients" {
  for_each = var.oauth_clients

  client_id = each.key
  name      = each.value.name
  enabled   = true

  grant_types   = each.value.grant_types
  redirect_uris = each.value.redirect_uris

  # Restrict allowed scopes when list is non-empty
  restrict_scopes   = length(each.value.allowed_scopes) > 0
  restricted_scopes = each.value.allowed_scopes

  # Consistent object shape required for Terraform ternary.
  # secret is ignored by PF when type=NONE; required (non-null) when type=SECRET.
  client_auth = {
    type   = each.value.client_auth_type
    secret = each.value.client_secret
  }

  require_proof_key_for_code_exchange = each.value.require_pkce
  bypass_approval_page                = each.value.bypass_approval_page
  description                         = each.value.description
}
