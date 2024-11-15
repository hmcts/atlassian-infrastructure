resource "azurerm_application_gateway" "ag" {

  name                = "atlasssian-${var.env}-app-gateway"
  resource_group_name = azurerm_resource_group.atlassian_rg.name
  location            = var.location
  tags                = module.ctags.common_tags

  sku {
    name = var.sku_name
    tier = var.sku_tier
  }

  autoscale_configuration {
    min_capacity = var.min_capacity
    max_capacity = var.max_capacity
  }

  gateway_ip_configuration {
    name      = "gateway"
    subnet_id = module.networking.subnet_ids["atlassian-dmz-${var.env}-vnet-atlassian-dmz-subnet-appgw"]
  }

  frontend_port {
    name = "http"
    port = 80
  }

  frontend_port {
    name = "https"
    port = 443
  }

  frontend_ip_configuration {
    name                 = "appGwPublicFrontendIp"
    public_ip_address_id = azurerm_public_ip.app_gw.id
  }

  waf_configuration {
    enabled          = var.enable_waf
    firewall_mode    = var.waf_mode
    rule_set_type    = "OWASP"
    rule_set_version = "3.2"
  }

  dynamic "backend_address_pool" {
    for_each = var.backend_address_pools
    content {
      name         = backend_address_pool.value.name
      ip_addresses = backend_address_pool.value.backend_pool_ip_addresses
      fqdns        = backend_address_pool.value.backend_pool_fqdns
    }
  }

  dynamic "probe" {
    for_each = var.probes
    content {
      interval                                  = probe.value.interval
      name                                      = probe.value.name
      path                                      = probe.value.path
      protocol                                  = "Http"
      timeout                                   = probe.value.timeout
      unhealthy_threshold                       = probe.value.unhealthy_threshold
      pick_host_name_from_backend_http_settings = probe.value.pick_host_name_from_backend_http_settings
    }
  }

  dynamic "backend_http_settings" {
    for_each = var.backend_http_settings
    content {
      name                                = backend_http_settings.value.name
      probe_name                          = backend_http_settings.value.probe_name
      cookie_based_affinity               = backend_http_settings.value.cookie_based_affinity
      port                                = 80
      protocol                            = "Http"
      request_timeout                     = backend_http_settings.value.request_timeout
      pick_host_name_from_backend_address = backend_http_settings.value.pick_host_name_from_backend_address
      dynamic "connection_draining" {
        for_each = backend_http_settings.value.connection_draining == null ? [] : [backend_http_settings.value.connection_draining]
        content {
          drain_timeout_sec = connection_draining.value.drain_timeout_sec
          enabled           = connection_draining.value.enabled
        }
      }
    }
  }

  identity {
    identity_ids = [azurerm_user_assigned_identity.identity.id]
    type         = "UserAssigned"
  }



  dynamic "http_listener" {
    for_each = var.http_listeners

    content {
      name                           = http_listener.value.name
      frontend_ip_configuration_name = http_listener.value.frontend_ip_name
      frontend_port_name             = http_listener.value.ssl_enabled ? "https" : "http"
      protocol                       = http_listener.value.ssl_enabled ? "Https" : "Http"
      host_name                      = http_listener.value.ssl_enabled ? coalesce(http_listener.value.listener_ssl_host_name, http_listener.value.ssl_host_name) : http_listener.value.exclude_env_in_app_name ? coalesce(http_listener.value.listener_host_name_exclude_env, http_listener.value.host_name_exclude_env) : coalesce(http_listener.value.listener_host_name_include_env, http_listener.value.host_name_include_env)
      ssl_certificate_name           = http_listener.value.ssl_enabled ? http_listener.value.ssl_certificate_name : ""

    }
  }


  dynamic "redirect_configuration" {
    for_each = [for app in local.gateways[count.index].app_configuration : {
      name        = "${app.product}-${app.component}-redirect"
      target_name = "${app.product}-${app.component}"
      }
      if lookup(app, "http_to_https_redirect", false) == true
    ]

    content {
      name                 = redirect_configuration.value.name
      redirect_type        = "Permanent"
      include_path         = true
      include_query_string = true
      target_listener_name = redirect_configuration.value.target_name
    }
  }

  dynamic "request_routing_rule" {
    for_each = [for i, app in local.gateways[count.index].app_configuration : {
      name               = "${app.product}-${app.component}"
      address_pool_name  = "${app.product}-${app.component}-address-pool"
      http_settings_name = "${app.product}-${app.component}-http-settings"
      rewrite_rule_name  = "${app.product}-${app.component}-rewriterule"
      priority           = ((i + 1) * 10)
      add_rewrite_rule   = contains(keys(app), "add_rewrite_rule") ? app.add_rewrite_rule : false
    }]

    content {
      name                       = request_routing_rule.value.name
      priority                   = request_routing_rule.value.priority
      rule_type                  = "Basic"
      http_listener_name         = request_routing_rule.value.name
      backend_address_pool_name  = request_routing_rule.value.address_pool_name
      backend_http_settings_name = request_routing_rule.value.http_settings_name
      rewrite_rule_set_name      = request_routing_rule.value.add_rewrite_rule ? request_routing_rule.value.rewrite_rule_name : null
    }
  }

  dynamic "request_routing_rule" {
    for_each = [for app in local.gateways[count.index].app_configuration : {
      name = "${app.product}-${app.component}-redirect"
      }
      if lookup(app, "http_to_https_redirect", false) == true
    ]

    content {
      name                        = request_routing_rule.value.name
      rule_type                   = "Basic"
      http_listener_name          = request_routing_rule.value.name
      redirect_configuration_name = request_routing_rule.value.name
    }
  }

  dynamic "trusted_client_certificate" {
    for_each = flatten([
      for app in local.gateways[count.index].app_configuration : [
        for cert in(contains(keys(app), "rootca_certificates") ? app.rootca_certificates : []) : {
          name                         = "${app.product}-${app.component}-${cert.rootca_certificate_name}"
          verify_client_cert_issuer_dn = contains(keys(app), "verify_client_cert_issuer_dn") ? app.verify_client_cert_issuer_dn : false
          data                         = contains(keys(cert), "rootca_certificate_name") ? var.trusted_client_certificate_data[cert.rootca_certificate_name].path : false
        }
        if lookup(app, "add_ssl_profile", false) == true && contains(keys(app), "rootca_certificates")
      ]
    ])
    content {
      name = trusted_client_certificate.value.name
      data = trusted_client_certificate.value.data
    }
  }



  dynamic "rewrite_rule_set" {
    for_each = [for app in local.gateways[count.index].app_configuration : {
      name          = "${app.product}-${app.component}-rewriterule"
      rewrite_rules = "${app.rewrite_rules}"
      }
      if lookup(app, "add_rewrite_rule", false) == true
    ]
    content {
      name = rewrite_rule_set.value.name

      dynamic "rewrite_rule" {
        for_each = [for rule in rewrite_rule_set.value.rewrite_rules : {
          name             = "${rule.name}"
          sequence         = "${rule.sequence}"
          conditions       = lookup(rule, "conditions", [])
          request_headers  = lookup(rule, "request_headers", [])
          url              = contains(keys(rule), "url") ? [rule.url] : []
          response_headers = lookup(rule, "response_headers", [])
        }]

        content {
          name          = rewrite_rule.value.name
          rule_sequence = rewrite_rule.value.sequence

          dynamic "condition" {
            for_each = [for cond in rewrite_rule.value.conditions : {
              variable    = "${cond.variable}"
              pattern     = "${cond.pattern}"
              ignore_case = lookup(cond, "ignore_case", false)
              negate      = lookup(cond, "negate", false)
            }]

            content {
              variable    = condition.value.variable
              pattern     = condition.value.pattern
              ignore_case = condition.value.ignore_case
              negate      = condition.value.negate
            }
          }

          dynamic "request_header_configuration" {
            for_each = [for request_header in rewrite_rule.value.request_headers : {
              header_name  = "${request_header.header_name}"
              header_value = "${request_header.header_value}"
            }]

            content {
              header_name  = request_header_configuration.value.header_name
              header_value = request_header_configuration.value.header_value
            }
          }

          dynamic "url" {
            for_each = [for the_url in rewrite_rule.value.url : {
              components   = lookup(the_url, "components", null)
              path         = lookup(the_url, "path", null)
              reroute      = lookup(the_url, "reroute", false)
              query_string = lookup(the_url, "query_string", null)
            }]

            content {
              components   = url.value.components
              path         = url.value.path
              reroute      = url.value.reroute
              query_string = url.value.query_string
            }
          }

          dynamic "response_header_configuration" {
            for_each = [for response_header in rewrite_rule.value.response_headers : {
              header_name  = "${response_header.header_name}"
              header_value = "${response_header.header_value}"
            }]

            content {
              header_name  = response_header_configuration.value.header_name
              header_value = response_header_configuration.value.header_value
            }
          }

        }
      }
    }
  }

  depends_on = [azurerm_role_assignment.identity]
}



resource "azurerm_user_assigned_identity" "identity" {
  name                = "atlasssian-${var.env}-app-gateway-identity"
  resource_group_name = azurerm_resource_group.atlassian_rg.name
  location            = var.location

  tags = module.ctags.common_tags
}

resource "azurerm_role_assignment" "identity" {
  principal_id = azurerm_user_assigned_identity.identity.principal_id
  scope        = azurerm_key_vault.atlasssian_kv.id

  role_definition_name = "Key Vault Secrets User"
}
