provider "pingfederate" {
  https_host      = var.pingfederate_host
  username        = var.pingfederate_username
  password        = var.pingfederate_password
  product_version = var.pingfederate_version

  # If using admin API token instead of username/password:
  # admin_api_key_header = "X-BypassExternalValidation"
  # admin_api_key_value  = var.pingfederate_admin_api_key

  # Set to true to skip TLS verification (dev/self-signed certs only)
  insecure_trust_all_tls = var.insecure_trust_all_tls
}
