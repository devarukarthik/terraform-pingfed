# ─── OAuth Access Token Managers ──────────────────────────────────────────────
#
# Resource: pingfederate_oauth_access_token_manager
#
# Built-in plugin descriptor IDs:
#   JWT Bearer:      com.pingidentity.pf.access.token.management.plugins.JwtBearerAccessTokenManagementPlugin
#   Reference Token: org.sourceid.oauth20.token.plugin.impl.ReferenceBearerAccessTokenManagementPlugin
#
# All attributes use object-style assignment (= { ... }), not block syntax.

resource "pingfederate_oauth_access_token_manager" "atms" {
  for_each = var.access_token_managers

  manager_id = each.key
  name       = each.value.name

  plugin_descriptor_ref = {
    id = each.value.plugin_descriptor_ref
  }

  configuration = {
    fields = concat(
      [
        {
          name  = "Token Lifetime"
          value = tostring(each.value.token_lifetime)
        },
        {
          name  = "Use Centralized Signing Key"
          value = "false"
        },
        {
          name  = "JWS Algorithm"
          value = ""
        },
        {
          name  = "Active Symmetric Key ID"
          value = each.value.active_symmetric_key_id
        },
        {
          name  = "Active Signing Certificate Key ID"
          value = ""
        },
        {
          name  = "JWE Algorithm"
          value = each.value.jwe_algorithm
        },
        {
          name  = "JWE Content Encryption Algorithm"
          value = each.value.jwe_content_encryption_algorithm
        },
        {
          name  = "Active Symmetric Encryption Key ID"
          value = each.value.active_symmetric_key_id
        },
        {
          name  = "Issuer Claim Value"
          value = coalesce(each.value.issuer, "")
        },
        {
          name  = "Audience Claim Value"
          value = ""
        },
        {
          name  = "JWKS Endpoint Path"
          value = coalesce(each.value.jwks_endpoint, "")
        },
        {
          name  = "Expand Scope Groups"
          value = "false"
        },
        {
          name  = "Space Delimit Scope Values"
          value = "true"
        },
        {
          name  = "Client ID Claim Name"
          value = "client_id"
        },
        {
          name  = "Scope Claim Name"
          value = "scope"
        },
        {
          name  = "JWT ID Claim Length"
          value = "22"
        },
        {
          name  = "Access Grant GUID Claim Name"
          value = ""
        },
        {
          name  = "JWKS Endpoint Cache Duration"
          value = "720"
        },
        {
          name  = "Include Key ID Header Parameter"
          value = "true"
        },
        {
          name  = "Default JWKS URL Cache Duration"
          value = "720"
        },
        {
          name  = "Include JWE Key ID Header Parameter"
          value = "true"
        },
        {
          name  = "Enable Token Revocation"
          value = "false"
        },
        {
          name  = "Type Header Value"
          value = ""
        },
        {
          name  = "Authorization Details Claim Name"
          value = "authorization_details"
        }
      ]
    )

    # Symmetric key table — required for JWT plugin with symmetric signing
    tables = [
      {
        name = "Symmetric Keys"
        rows = each.value.symmetric_key_id != null ? [
          {
            default_row = false
            fields = [
              { name = "Key ID", value = each.value.symmetric_key_id },
              { name = "Encoding", value = "b64u" }
            ]
            sensitive_fields = [
              { name = "Key", value = each.value.symmetric_key_value }
            ]
          }
        ] : []
      },
      {
        name = "Certificates"
        rows = []
      }
    ]
  }

  attribute_contract = {
    extended_attributes = [
      for attr in each.value.extended_attributes : {
        name         = attr
        multi_valued = false
      }
    ]
  }

  access_control_settings = {
    restrict_clients = false
  }

  session_validation_settings = {
    check_valid_authn_session       = false
    check_session_revocation_status = false
    update_authn_session_activity   = false
    include_session_id              = false
  }
}
