
resource null_resource write_outputs {
  provisioner "local-exec" {
    command = "echo \"$${OUTPUT}\" > gitops-output.json"

    environment = {
      OUTPUT = jsonencode({
        name        = module.es_instance.name
        branch      = module.es_instance.branch
        namespace   = module.es_instance.namespace
        server_name = module.es_instance.server_name
        layer       = module.es_instance.layer
        layer_dir   = module.es_instance.layer == "infrastructure" ? "1-infrastructure" : (module.es_instance.layer == "services" ? "2-services" : "3-applications")
        type        = module.es_instance.type
      })
    }
  }
}
