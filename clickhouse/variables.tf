variable "pv_storage_size" {
  description = "Size of the PersistentVolume"
  type        = string
  default     = "5Gi"
}

variable "pv_host_path" {
  description = "Host path for the PersistentVolume"
  type        = string
  default     = "/etc/clickhouse/data"
}

variable "namespace" {
    description = "Name of the namespace"
    type = string
    default = "clickhouse"
}

variable "pvc_storage_size" {
  description = "Size of the PersistentVolumeClaim"
  type        = string
  default     = "5Gi"
}


variable "deployment_replicas" {
  description = "Number of replicas for the Deployment"
  type        = number
  default     = 1
}

variable "container_image" {
  description = "The container image for the ClickHouse deployment"
  type        = string
  default     = "clickhouse/clickhouse-server:latest"
}

variable "pv_mount_path" {
  description = "Path where the volume will be mounted in the container"
  type        = string
  default     = "/etc/clickhouse/data"
}

variable "container_cpu_request" {
  description = "CPU request for the container"
  type        = string
  default     = "500m"
}

variable "container_memory_request" {
  description = "Memory request for the container"
  type        = string
  default     = "1Gi"
}

variable "container_cpu_limit" {
  description = "CPU limit for the container"
  type        = string
  default     = "500m"
}

variable "container_memory_limit" {
  description = "Memory limit for the container"
  type        = string
  default     = "1Gi"
}