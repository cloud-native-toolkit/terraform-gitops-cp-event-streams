locals {
  name               = var.service_name
  yaml_dir           = "${path.cwd}/.tmp/${local.name}/chart/${local.name}"
  service_url        = "http://${local.name}.${var.namespace}"
  layer              = "services"
  type               = "base"
  application_branch = "main"
  namespace          = var.namespace
  layer_config       = var.gitops_config[local.layer]
  values_file        = "values.yaml"
  # kafka_listeners_insecure = [
  #   {
  #     name = plain
  #     port = 9092
  #     type = internal
  #     tls  = false
  #   }
  # ]
  kafka_listeners_secure = [
    {
      name = "external"
      port = 9094
      type = "route"
      tls  = true
      authentication = {
        type = "scram-sha-512"
      }
    },
    {
      name = "tls"
      port = 9093
      type = "internal"
      tls  = true
      authentication = {
        type = "tls"
      }
    }
  ]
  #kafka_listeners_locals = var.kafka_listener_type == "secure" ? local.kafka_listeners_secure : local.kafka_listeners_insecure
  kafka_listeners = length(var.kafka_listeners) > 0 ? var.kafka_listeners : local.kafka_listeners_secure
  values_content = {
    apiVersion = var.es_apiVersion
    name       = var.service_name
    #namespace                     = var.namespace
    version                       = var.es_version
    license_use                   = var.license_use
    kafka_replicas                = var.kafka_replicas
    zookeeper_replicas            = var.zookeeper_replicas
    requestIbmServices_iam        = var.requestIbmServices_iam
    requestIbmServices_monitoring = var.requestIbmServices_monitoring
    kafka_config = {
      inter_broker_protocol_version = var.kafka_inter_broker_protocol_version
      log_message_format_version    = var.kafka_log_message_format_version
    }
    storage_kafka = {
      type  = var.kafka_storagetype
      class = var.kafka_storageclass
      size  = var.kafka_storagesize
    }
    storage_zookeeper = {
      type  = var.zookeeper_storagetype
      class = var.zookeeper_storageclass
      size  = var.zookeeper_storagesize
    }
    resources = {
      requests = {
        cpu    = var.cpurequests
        memory = var.memoryrequests
      }
      limits = {
        cpu    = var.cpulimits
        memory = var.memorylimits
      }
    }
    listeners = local.kafka_listeners
  }
}

resource gitops_pull_secret cp_icr_io {
  name = "ibm-entitlement-key"
  namespace = local.namespace
  server_name = var.server_name
  branch = local.application_branch
  layer = local.layer
  credentials = yamlencode(var.git_credentials)
  config = yamlencode(var.gitops_config)
  kubeseal_cert = var.kubeseal_cert


  secret_name = "ibm-entitlement-key"
  registry_server = "cp.icr.io"
  registry_username = "cp"
  registry_password = var.entitlement_key
}

resource null_resource create_yaml {
  provisioner "local-exec" {
    command = "${path.module}/scripts/create-yaml.sh '${local.name}' '${local.yaml_dir}'"

    environment = {
      VALUES_CONTENT = yamlencode(local.values_content)
    }
  }
}

resource gitops_module setup_gitops {
  depends_on = [null_resource.create_yaml]

  name = local.name
  namespace = var.namespace
  content_dir = local.yaml_dir
  server_name = var.server_name
  layer = local.layer
  type = local.type
  branch = local.application_branch
  config = yamlencode(var.gitops_config)
  credentials = yamlencode(var.git_credentials)
}

