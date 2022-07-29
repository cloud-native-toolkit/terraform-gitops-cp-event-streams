
variable "gitops_config" {
  type = object({
    boostrap = object({
      argocd-config = object({
        project = string
        repo    = string
        url     = string
        path    = string
      })
    })
    infrastructure = object({
      argocd-config = object({
        project = string
        repo    = string
        url     = string
        path    = string
      })
      payload = object({
        repo = string
        url  = string
        path = string
      })
    })
    services = object({
      argocd-config = object({
        project = string
        repo    = string
        url     = string
        path    = string
      })
      payload = object({
        repo = string
        url  = string
        path = string
      })
    })
    applications = object({
      argocd-config = object({
        project = string
        repo    = string
        url     = string
        path    = string
      })
      payload = object({
        repo = string
        url  = string
        path = string
      })
    })
  })
  description = "Config information regarding the gitops repo structure"
}

variable "git_credentials" {
  type = list(object({
    repo     = string
    url      = string
    username = string
    token    = string
  }))
  description = "The credentials for the gitops repo(s)"
  sensitive   = true
}

variable "namespace" {
  type        = string
  description = "The namespace where the application should be deployed"
}

variable "kubeseal_cert" {
  type        = string
  description = "The certificate/public key used to encrypt the sealed secrets"
  default     = ""
}

variable "server_name" {
  type        = string
  description = "The name of the server"
  default     = "default"
}

variable "entitlement_key" {
  type        = string
  description = "The entitlement key required to access Cloud Pak images"
  sensitive   = true
}

variable "license_use" {
  type        = string
  description = "Usage for Production or Non-Production"
  default     = "CloudPakForIntegrationNonProduction"
}

variable "requestIbmServices_iam" {
  type        = bool
  description = "IAM services"
  default     = true
}
variable "requestIbmServices_monitoring" {
  type        = bool
  description = "Monitoring services"
  default     = true
}

variable "kafka_replicas" {
  type        = number
  description = "Number of kafka replicas"
  default     = "3"
}

variable "zookeeper_replicas" {
  type        = number
  description = "Number of zookeeper replicas"
  default     = "3"
}
variable "es_version" {
  type        = string
  description = "Version of Event streams to be installed"
  default     = "11.0.2"
}
variable "cpulimits" {
  type        = string
  description = "CPU limits for the kafka instance"
  default     = "1"
}

variable "cpurequests" {
  type        = string
  description = "CPU requests for the kafka instance"
  default     = "100m"
}

variable "memorylimits" {
  type        = string
  description = "Memory limits for the kafka instance"
  default     = "2Gi"
}

variable "memoryrequests" {
  type        = string
  description = "Memory requests for the kafka instance"
  default     = "128Mi"
}

variable "kafka_storageclass" {
  type        = string
  description = "Storage class for kafka - applicable only for persistent storage type"
  default     = "ibmc-vpc-block-10iops-tier"
}

variable "zookeeper_storageclass" {
  type        = string
  description = "Storage class for zookeeper - applicable only for persistent storage type"
  default     = "ibmc-vpc-block-10iops-tier"
}

variable "kafka_storagetype" {
  type        = string
  description = "Storage type for kafka"
  default     = "persistent-claim"
}

variable "zookeeper_storagetype" {
  type        = string
  description = "Storage type for zookeeper"
  default     = "persistent-claim"
}

variable "kafka_storagesize" {
  type        = string
  description = "Storage size - applicable only for persistent storage type"
  default     = "10Gi"
}

variable "zookeeper_storagesize" {
  type        = string
  description = "Storage size - applicable only for persistent storage type"
  default     = "4Gi"
}

variable "service_name" {
  type        = string
  description = "Event stream instance name"
  default     = "es-instance"
}

variable "es_apiVersion" {
  type        = string
  description = "Event stream API version"
  default     = "v1beta2"
}

variable "kafka_inter_broker_protocol_version" {
  type        = string
  description = "Kafka config inter broker protocol version"
  default     = "3.2"
}
variable "kafka_log_message_format_version" {
  type        = string
  description = "Kafka config loag message format version"
  default     = "3.2"
}

variable "kafka_listeners" {
  type        = list
  description = "Kafka listerners defaults to secure - override to provide light-insecure"
  default     = []
}
