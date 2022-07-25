module gitops-cp-eventstreams {
  source = "github.com/cloud-native-toolkit/terraform-gitops-cp-es-operator.git"

  gitops_config   = module.gitops.gitops_config
  git_credentials = module.gitops.git_credentials
  server_name     = module.gitops.server_name
  catalog         = module.cp_catalogs.catalog_ibmoperators
  channel         = module.cp4i-dependencies.eventstreams.channel
}
