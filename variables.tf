# ─── PingFederate Connection ───────────────────────────────────────────────────

variable "pingfederate_host" {
  description = "Base URL of the PingFederate admin API, e.g. https://pingfed.example.com:9999"
  type        = string
}

variable "pingfederate_username" {
  description = "PingFederate admin username"
  type        = string
  sensitive   = true
}

variable "pingfederate_password" {
  description = "PingFederate admin password"
  type        = string
  sensitive   = true
}

variable "pingfederate_version" {
  description = "PingFederate product version, e.g. 12.1. Used by the provider to enable version-specific features."
  type        = string
  default     = "12.1"
}

variable "insecure_trust_all_tls" {
  description = "Skip TLS certificate verification (use only in dev/lab environments)"
  type        = bool
  default     = false
}

# ─── OAuth Server Settings ─────────────────────────────────────────────────────
# Required by pingfederate_oauth_server_settings (singleton resource for scopes).

variable "oauth_server_settings" {
  description = "Core OAuth authorization server settings"
  type = object({
    authorization_code_entropy = optional(number, 20)
    authorization_code_timeout = optional(number, 60)
    refresh_rolling_interval   = optional(number, 1)
    refresh_token_length       = optional(number, 40)
  })
  default = {}
}

# ─── OAuth Clients ─────────────────────────────────────────────────────────────

variable "oauth_clients" {
  description = "Map of OAuth/OIDC clients to create. The map key becomes the client_id."
  type = map(object({
    name           = string
    grant_types    = list(string) # UPPERCASE: AUTHORIZATION_CODE, CLIENT_CREDENTIALS, REFRESH_TOKEN, etc.
    redirect_uris  = optional(list(string), [])
    allowed_scopes = optional(list(string), [])

    # client_auth.type: NONE | SECRET | CERTIFICATE | PRIVATE_KEY_JWT
    client_auth_type = optional(string, "SECRET")
    client_secret    = optional(string, null) # null = PF generates one

    require_pkce         = optional(bool, false)
    bypass_approval_page = optional(bool, false)
    description          = optional(string, "")
  }))
  default = {}
}

# ─── OAuth Scopes ──────────────────────────────────────────────────────────────

variable "oauth_scopes" {
  description = "Map of common OAuth scopes. Key = scope name."
  type = map(object({
    description = string
    dynamic     = optional(bool, false)
  }))
  default = {}
}

variable "oauth_scope_groups" {
  description = "Map of OAuth scope groups. Key = group name."
  type = map(object({
    description = string
    scopes      = list(string)
  }))
  default = {}
}

# ─── Access Token Managers ─────────────────────────────────────────────────────

variable "access_token_managers" {
  description = "Map of OAuth access token managers. Key is a label; manager_id (alphanumeric only) is the actual PF ID."
  type = map(object({
    manager_id            = string  # must match [a-zA-Z0-9] only — no hyphens or underscores
    name                  = string
    plugin_descriptor_ref = string # plugin class ID
    token_lifetime        = optional(number, 120)
    issuer                = optional(string, null)
    jwks_endpoint         = optional(string, null)

    # Symmetric key for JWT signing (required if using symmetric key signing)
    active_symmetric_key_id    = optional(string, "")
    symmetric_key_id           = optional(string, null)
    symmetric_key_value        = optional(string, null) # sensitive — use TF_VAR or vault

    # Signing / encryption settings
    jws_algorithm                    = optional(string, "HS256") # e.g. HS256, RS256, "" for none
    jwe_algorithm                    = optional(string, "")      # e.g. "dir", "" to disable
    jwe_content_encryption_algorithm = optional(string, "")      # e.g. "A192CBC-HS384", "" to disable

    # Extended token attributes
    extended_attributes = optional(list(string), [])
  }))
  default = {}
}

# ─── Authentication Policy Contracts ──────────────────────────────────────────

variable "authn_policy_contracts" {
  description = "Map of authentication policy contracts. Key = contract key (used internally)."
  type = map(object({
    name                = string
    extended_attributes = optional(list(string), [])
    # Note: core_attributes (e.g. "subject") are read-only and set by PingFederate automatically
  }))
  default = {}
}
