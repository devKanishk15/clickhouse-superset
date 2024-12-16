terraform {
  required_providers {
    kubernetes = {
      source = "hashicorp/kubernetes"
      version = "2.35.0"
    }
  }
}

provider "kubernetes" {
  config_path = "~/.kube/config" 
}

resource "kubernetes_persistent_volume" "clickhouse_pv" {
  metadata {
    name = "clickhouse-pv"
  }

spec {
    capacity = {
    storage = "5Gi"
    }

    access_modes = ["ReadWriteOnce"]
    persistent_volume_reclaim_policy = "Retain"

    persistent_volume_source {
    local {
        path = "/etc/clickhouse/data"
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
    namespace = "datazip"
  }

  spec {
    access_modes = ["ReadWriteOnce"]

    resources {
      requests = {
        storage = "5Gi"
      }
    }
  }
}

resource "kubernetes_deployment" "clickhouse" {
  metadata {
    name      = "clickhouse"
    namespace = "datazip"
  }

  spec {
    replicas = 1

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
          image = "clickhouse/clickhouse-server:latest"

          volume_mount {
            mount_path = "/etc/clickhouse/data"
            name       = "clickhouse-data"
          }

          resources {
            requests = {
              cpu    = "500m"
              memory = "1Gi"
            }
            limits = {
              cpu    = "1"
              memory = "2Gi"
            }
          }

          liveness_probe {
            http_get {
              path = "/ping"
              port = 8123
            }
            initial_delay_seconds = 30
            period_seconds        = 30
            timeout_seconds       = 5
            failure_threshold     = 3
          }

          readiness_probe {
            http_get {
              path = "/ping"
              port = 8123
            }
            initial_delay_seconds = 30
            period_seconds        = 30
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
    namespace = "datazip"
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
