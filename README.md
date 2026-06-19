# terraform-pingfed

Terraform project for managing PingFederate resources via the [pingidentity/pingfederate](https://registry.terraform.io/providers/pingidentity/pingfederate/latest/docs) provider.

## Covered resources

| File | Resource |
|---|---|
| `oauth_clients.tf` | `pingfederate_oauth_client` |
| `oauth_scopes.tf` | `pingfederate_oauth_server_settings_scopes_common_scope` / `…_scope_group` |
| `access_token_managers.tf` | `pingfederate_access_token_manager` |
| `auth_policies.tf` | `pingfederate_authentication_policy_contract` |

## Quick start

```bash
# 1. Copy and fill in your values
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars — set PF host, credentials, and desired resources

# 2. Initialize
terraform init

# 3. Preview changes
terraform plan

# 4. Apply
terraform apply
```

## Credentials

Credentials are read from `terraform.tfvars` (git-ignored). For CI/CD, export them as environment variables instead:

```bash
export TF_VAR_pingfederate_host="https://pingfed.example.com:9999"
export TF_VAR_pingfederate_username="administrator"
export TF_VAR_pingfederate_password="..."
```

## Adding an OAuth client

In `terraform.tfvars`, add an entry under `oauth_clients`:

```hcl
oauth_clients = {
  "my-new-client" = {
    name        = "My New Client"
    grant_types = ["client_credentials"]
    allowed_scopes = ["api:read"]
  }
}
```

Run `terraform apply` — PingFederate will create the client and generate a secret if none is provided.

## Provider version

The provider is pinned to `~> 1.0` in `versions.tf`. Check the [Terraform Registry](https://registry.terraform.io/providers/pingidentity/pingfederate/latest) for the latest version and update the constraint as needed.

## Remote state

Uncomment the `backend` block in `versions.tf` to store state in S3, Terraform Cloud, or another backend. This is strongly recommended for team use.
