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

variable "insecure_trust_all_tls" {
  description = "Skip TLS certificate verification (use only in dev/lab environments)"
  type        = bool
  default     = false
}

# ─── OAuth Clients ─────────────────────────────────────────────────────────────

variable "oauth_clients" {
  description = "Map of OAuth/OIDC clients to create"
  type = map(object({
    name                       = string
    grant_types                = list(string) # e.g. ["authorization_code", "refresh_token"]
    redirect_uris              = optional(list(string), [])
    allowed_scopes             = optional(list(string), [])
    client_secret              = optional(string, null)  # null = PF generates one
    token_endpoint_auth_method = optional(string, "CLIENT_SECRET_BASIC")
    require_pkce               = optional(bool, false)
    bypass_approval_page       = optional(bool, false)
    description                = optional(string, "")
  }))
  default = {}
}

# ─── OAuth Scopes ──────────────────────────────────────────────────────────────

variable "oauth_scopes" {
  description = "Map of custom OAuth scopes to register"
  type = map(object({
    description  = string
    dynamic      = optional(bool, false)
  }))
  default = {}
}

variable "oauth_scope_groups" {
  description = "Map of OAuth scope groups"
  type = map(object({
    description = string
    scopes      = list(string)
  }))
  default = {}
}

# ─── Access Token Managers ─────────────────────────────────────────────────────

variable "access_token_managers" {
  description = "Map of access token managers to configure"
  type = map(object({
    name          = string
    plugin_descriptor_ref = string  # e.g. "com.pingidentity.pf.access.token.management.plugins.JwtBearerAccessTokenManagementPlugin"
    token_lifetime = optional(number, 120) # minutes
    jwks_endpoint = optional(string, null)
    issuer        = optional(string, null)
  }))
  default = {}
}

# ─── Authentication Policy Contracts ──────────────────────────────────────────

variable "authn_policy_contracts" {
  description = "Map of authentication policy contracts"
  type = map(object({
    name             = string
    core_attributes  = optional(list(string), ["subject"])
    extended_attributes = optional(list(string), [])
  }))
  default = {}
}
