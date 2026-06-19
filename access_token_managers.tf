# ─── Access Token Managers (ATMs) ─────────────────────────────────────────────
#
# The most common plugin is the JWT Bearer ATM. The plugin_descriptor_ref for
# the built-in JWT plugin is:
#   com.pingidentity.pf.access.token.management.plugins.JwtBearerAccessTokenManagementPlugin
#
# You must deploy the plugin jar to PF before managing it with Terraform.
# The configuration fields below match the JWT Bearer plugin's expected fields.

resource "pingfederate_access_token_manager" "atms" {
  for_each = var.access_token_managers

  manager_id = each.key
  name       = each.value.name

  plugin_descriptor_ref {
    id = each.value.plugin_descriptor_ref
  }

  configuration {
    # ── JWT signing / verification ──────────────────────────────────────────
    fields {
      name  = "Token Lifetime"
      value = tostring(each.value.token_lifetime)
    }

    dynamic "fields" {
      for_each = each.value.issuer != null ? [each.value.issuer] : []
      content {
        name  = "Issuer Claim Value"
        value = fields.value
      }
    }

    dynamic "fields" {
      for_each = each.value.jwks_endpoint != null ? [each.value.jwks_endpoint] : []
      content {
        name  = "JWKS Endpoint Path"
        value = fields.value
      }
    }
  }

  # Standard attribute contract — extend as needed
  attribute_contract {
    extended_attributes {
      name         = "sub"
      multi_valued = false
    }
  }
}
