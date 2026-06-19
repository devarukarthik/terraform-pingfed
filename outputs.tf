# ─── OAuth Clients ─────────────────────────────────────────────────────────────

output "oauth_client_ids" {
  description = "Map of client key → client_id for all created OAuth clients"
  value       = { for k, v in pingfederate_oauth_client.clients : k => v.client_id }
}

# ─── OAuth Server Settings (Scopes) ───────────────────────────────────────────

output "oauth_scope_names" {
  description = "List of registered common OAuth scope names"
  value       = [for s in pingfederate_oauth_server_settings.main.scopes : s.name]
}

# ─── Access Token Managers ─────────────────────────────────────────────────────

output "access_token_manager_ids" {
  description = "Map of ATM key → manager_id for all created access token managers"
  value       = { for k, v in pingfederate_oauth_access_token_manager.atms : k => v.manager_id }
}

# ─── Authentication Policy Contracts ──────────────────────────────────────────

output "authn_policy_contract_ids" {
  description = "Map of contract key → id for all created authentication policy contracts"
  value       = { for k, v in pingfederate_authentication_policy_contract.contracts : k => v.id }
}
