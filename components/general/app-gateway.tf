resource "azurerm_application_gateway" "ag" {

  name                = "atlassian-${var.env}-app-gateway"
  resource_group_name = azurerm_resource_group.atlassian_rg.name
  location            = var.location
  tags                = module.ctags.common_tags
  enable_http2        = var.enable_http2
  firewall_policy_id  = azurerm_web_application_firewall_policy.waf_policy.id
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
      port                                = backend_http_settings.value.port
      protocol                            = "Http"
      request_timeout                     = backend_http_settings.value.request_timeout
      pick_host_name_from_backend_address = backend_http_settings.value.pick_host_name_from_backend_address
      dynamic "connection_draining" {
        for_each = [for conn in backend_http_settings.value.connection_draining : {
          drain_timeout_sec = conn.drain_timeout_sec
          enabled           = conn.enabled
        }]
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
      frontend_ip_configuration_name = "appGwPublicFrontendIp"
      frontend_port_name             = http_listener.value.ssl_enabled ? "https" : "http"
      protocol                       = http_listener.value.ssl_enabled ? "Https" : "Http"
      ssl_certificate_name           = http_listener.value.ssl_enabled ? http_listener.value.ssl_certificate_name : ""
    }
  }

  dynamic "ssl_certificate" {
    for_each = var.ssl_certificates
    content {
      name                = ssl_certificate.value.name
      key_vault_secret_id = ssl_certificate.value.key_vault_secret_id
    }

  }
  dynamic "request_routing_rule" {
    for_each = var.request_routing_rules
    content {
      name                       = request_routing_rule.value.name
      priority                   = request_routing_rule.value.priority
      rule_type                  = "PathBasedRouting"
      http_listener_name         = request_routing_rule.value.http_listener_name
      url_path_map_name          = "appgw-url-map-path"
      backend_address_pool_name  = request_routing_rule.value.backend_address_pool_name
      backend_http_settings_name = request_routing_rule.value.backend_http_settings_name
    }
  }
  dynamic "url_path_map" {
    for_each = var.url_path_map
    content {
      name                               = "appgw-url-map-path"
      default_backend_address_pool_name  = url_path_map.value.default_backend_address_pool_name
      default_backend_http_settings_name = url_path_map.value.default_backend_http_settings_name
      default_rewrite_rule_set_name      = var.enable_rewrite_rule_set ? "Test-Rewrites" : null
      dynamic "path_rule" {
        for_each = [for p in url_path_map.value.path_rule : {
          name                       = p.name
          paths                      = p.paths
          backend_address_pool_name  = p.backend_address_pool_name
          backend_http_settings_name = p.backend_http_settings_name

        }]
        content {
          name                       = path_rule.value.name
          paths                      = [path_rule.value.paths]
          backend_address_pool_name  = path_rule.value.backend_address_pool_name
          backend_http_settings_name = path_rule.value.backend_http_settings_name
        }
      }
    }
  }

dynamic "rewrite_rule_set" {
  for_each = var.enable_rewrite_rule_set ? [1] : []
  content {
    name = "Test-Rewrites"
    dynamic "rewrite_rule" {
      for_each = var.app_gw_rewrite_rules
      content {
        name          = rewrite_rule.value.name
        rule_sequence = rewrite_rule.value.rule_sequence
        condition {
          variable    = rewrite_rule.value.condition.variable
          pattern     = rewrite_rule.value.condition.pattern
          ignore_case = rewrite_rule.value.condition.ignore_case
          negate      = rewrite_rule.value.condition.negate
        }
        response_header_configuration {
          header_name  = rewrite_rule.value.response_header_configuration.header_name
          header_value = rewrite_rule.value.response_header_configuration.header_value
        }
        url {
          components = rewrite_rule.value.url.components
          path       = rewrite_rule.value.url.path
          reroute    = rewrite_rule.value.url.reroute
        }
      }
    }
  }
}

  depends_on = [azurerm_role_assignment.identity]
}



resource "azurerm_user_assigned_identity" "identity" {
  name                = "atlassian-${var.env}-app-gateway-identity"
  resource_group_name = azurerm_resource_group.atlassian_rg.name
  location            = var.location

  tags = module.ctags.common_tags
}

resource "azurerm_role_assignment" "identity" {
  principal_id = azurerm_user_assigned_identity.identity.principal_id
  scope        = azurerm_key_vault.atlassian_kv.id

  role_definition_name = "Key Vault Secrets User"
}


resource "azurerm_web_application_firewall_policy" "waf_policy" {

  name                = "atlassian-${var.env}-app-gateway-waf-policy"
  resource_group_name = azurerm_resource_group.atlassian_rg.name
  location            = var.location
  tags                = module.ctags.common_tags

  policy_settings {
    enabled                     = var.enable_waf
    mode                        = var.waf_mode
    request_body_check          = true
    file_upload_limit_in_mb     = 100
    max_request_body_size_in_kb = 2000
  }

  dynamic "managed_rules" {
    for_each = var.waf_managed_rules != null ? var.waf_managed_rules : []

    content {
      managed_rule_set {
        type    = managed_rules.value.type
        version = managed_rules.value.version

        dynamic "rule_group_override" {
          for_each = managed_rules.value.rule_group_override

          content {
            rule_group_name = rule_group_override.value.rule_group_name

            dynamic "rule" {
              for_each = rule_group_override.value.rule

              content {
                id      = rule.value.id
                enabled = rule.value.enabled
                action  = rule.value.action
              }
            }
          }
        }
      }
    }
  }

  dynamic "custom_rules" {
    for_each = var.waf_custom_rules != null ? var.waf_custom_rules : []

    content {
      name      = custom_rules.value.name
      priority  = custom_rules.value.priority
      rule_type = custom_rules.value.rule_type

      dynamic "match_conditions" {
        for_each = custom_rules.value.match_conditions

        content {
          dynamic "match_variables" {
            for_each = match_conditions.value.match_variables

            content {
              variable_name = match_variables.value.variable_name
              selector      = lookup(match_variables.value, "selector", null)
            }
          }

          operator           = match_conditions.value.operator
          negation_condition = match_conditions.value.negation_condition
          match_values       = match_conditions.value.match_values
        }
      }

      action = custom_rules.value.action
    }
  }
}

import {
  id = "/subscriptions/b7d2bd5f-b744-4acc-9c73-e068cec2e8d8/resourceGroups/atlassian-nonprod-rg/providers/Microsoft.Network/applicationGatewayWebApplicationFirewallPolicies/atlassian-nonprod-app-gateway-waf-policy"
  to = azurerm_web_application_firewall_policy.waf_policy
}
