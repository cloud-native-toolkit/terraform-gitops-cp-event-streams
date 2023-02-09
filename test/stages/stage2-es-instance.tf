module "es_instance" {
  source = "./module"

  depends_on = [
    module.gitops-cp-eventstreams
  ]

  gitops_config   = module.gitops.gitops_config
  git_credentials = module.gitops.git_credentials
  server_name     = module.gitops.server_name
  namespace       = module.gitops_namespace.name
  kubeseal_cert   = module.gitops.sealed_secrets_cert
  entitlement_key = module.cp_catalogs.entitlement_key
  license_use     = module.cp4i-dependencies.eventstreams.license_use
  es_version      = module.cp4i-dependencies.eventstreams.version
  kafka_storageclass = module.storage.block_storage_class
  zookeeper_storageclass = module.storage.block_storage_class
}
