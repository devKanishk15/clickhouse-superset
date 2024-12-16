resource "kubernetes_namespace" "clickhouse_namespace" {
  metadata {
    name = var.namespace
  }
}


resource "kubernetes_persistent_volume" "clickhouse_pv" {
  metadata {
    name = "clickhouse-pv"
  }

spec {
    capacity = {
    storage = var.pv_storage_size
    }

    access_modes = ["ReadWriteOnce"]
    persistent_volume_reclaim_policy = "Retain"

    persistent_volume_source {
    local {
        path = var.pv_host_path
    }
    }

    node_affinity {
    required {
        node_selector_term {
        match_expressions {
            key = "kubernetes.io/hostname"
            operator = "In"
            values = ["minikube"]
        }
        }
    }
    }
  }
}

resource "kubernetes_persistent_volume_claim" "clickhouse_pvc" {
  metadata {
    name      = "clickhouse-pvc"
    namespace = var.namespace
  }

  spec {
    access_modes = ["ReadWriteOnce"]

    resources {
      requests = {
        storage = var.pvc_storage_size
      }
    }
  }
}

resource "kubernetes_deployment" "clickhouse" {
  metadata {
    name      = "clickhouse"
    namespace = var.namespace
  }

  spec {
    replicas = var.deployment_replicas

    selector {
      match_labels = {
        app = "clickhouse"
      }
    }

    template {
      metadata {
        labels = {
          app = "clickhouse"
        }
      }

      spec {
        container {
          name  = "clickhouse"
          image = var.container_image

          volume_mount {
            mount_path = var.pv_mount_path
            name       = "clickhouse-data"
          }

          resources {
            requests = {
              cpu    = var.container_cpu_request
              memory = var.container_memory_request
            }
            limits = {
              cpu    = var.container_cpu_limit
              memory = var.container_memory_limit
            }
          }

          liveness_probe {
            http_get {
              path = "/ping"
              port = 8123
            }
            initial_delay_seconds = 30
            period_seconds        = 15
            timeout_seconds       = 5
            failure_threshold     = 3
          }

          readiness_probe {
            http_get {
              path = "/ping"
              port = 8123
            }
            initial_delay_seconds = 30
            period_seconds        = 15
            timeout_seconds       = 5
            failure_threshold     = 3
          }
        }

        volume {
          name = "clickhouse-data"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim.clickhouse_pvc.metadata[0].name
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "clickhouse" {
  metadata {
    name      = "clickhouse"
    namespace = var.namespace
  }

  spec {
    selector = {
      app = "clickhouse"
    }

    port {
      name       = "http"
      port       = 8123
      target_port = 8123
    }

    port {
      name       = "native"
      port       = 9000
      target_port = 9000
    }

    port {
      name       = "replication"
      port       = 9009
      target_port = 9009
    }

    type = "NodePort"
  }
}