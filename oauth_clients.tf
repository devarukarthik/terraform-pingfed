# ─── OAuth / OIDC Clients ──────────────────────────────────────────────────────
#
# Driven by var.oauth_clients. Add entries to terraform.tfvars to create clients.
#
# Supported grant_types values:
#   authorization_code | implicit | client_credentials | password |
#   refresh_token | urn:ietf:params:oauth:grant-type:jwt-bearer |
#   urn:openid:params:grant-type:ciba
#
# token_endpoint_auth_method values:
#   CLIENT_SECRET_BASIC | CLIENT_SECRET_POST | PRIVATE_KEY_JWT | NONE

resource "pingfederate_oauth_client" "clients" {
  for_each = var.oauth_clients

  client_id = each.key
  name      = each.value.name

  grant_types = each.value.grant_types

  # Redirect URIs — required for authorization_code / implicit
  dynamic "redirect_uris" {
    for_each = length(each.value.redirect_uris) > 0 ? [1] : []
    content {
      # The provider expects redirect_uris as a top-level list field
    }
  }

  redirect_uris = each.value.redirect_uris

  # Restrict allowed scopes
  restrict_scopes      = length(each.value.allowed_scopes) > 0
  restricted_scopes    = each.value.allowed_scopes

  # Auth method
  client_auth {
    type   = each.value.token_endpoint_auth_method
    secret = each.value.client_secret
  }

  require_proof_key_for_code_exchange = each.value.require_pkce
  bypass_approval_page                = each.value.bypass_approval_page

  description = each.value.description

  # Default token manager is inherited from the global server settings.
  # Override per-client by adding default_access_token_manager_ref here.
}
