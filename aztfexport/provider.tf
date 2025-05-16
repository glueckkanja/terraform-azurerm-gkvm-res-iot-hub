provider "azapi" {
  skip_provider_registration = true
  subscription_id            = "dabee6fb-7ec1-41f8-bff3-be98be448af9"
  environment                = "public"
  use_msi                    = false
  use_cli                    = true
  use_oidc                   = false
}
