module "ctags" {
  source = "github.com/hmcts/terraform-module-common-tags"

  builtFrom    = var.builtFrom
  environment  = var.env
  product      = var.product
  autoShutdown = var.autoShutdown
}

locals {
  sendgrid_config = {
    # This is the default IP address provided by Sendgrid, visible on the main account
    # More IP addresses with a specific locations can be added and used on individual subusers if needed
    ips = ["167.89.58.18"]
  }
}