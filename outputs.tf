# ─── OAuth Clients ─────────────────────────────────────────────────────────────

output "oauth_client_ids" {
  description = "Map of client key → client_id for all created OAuth clients"
  value       = { for k, v in pingfederate_oauth_client.clients : k => v.client_id }
}

# ─── OAuth Scopes ──────────────────────────────────────────────────────────────

output "oauth_scope_names" {
  description = "List of registered custom OAuth scope names"
  value       = [for k, v in pingfederate_oauth_server_settings_scopes_common_scope.scopes : v.name]
}

# ─── Access Token Managers ─────────────────────────────────────────────────────

output "access_token_manager_ids" {
  description = "Map of ATM key → ID for all created access token managers"
  value       = { for k, v in pingfederate_access_token_manager.atms : k => v.id }
}

# ─── Authentication Policy Contracts ──────────────────────────────────────────

output "authn_policy_contract_ids" {
  description = "Map of contract key → ID for all created authentication policy contracts"
  value       = { for k, v in pingfederate_authentication_policy_contract.contracts : k => v.id }
}
