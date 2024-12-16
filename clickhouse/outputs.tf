output "clickhouse_deployment_name" {
  description = "The name of the ClickHouse deployment"
  value       = kubernetes_deployment.clickhouse.metadata[0].name
}

output "clickhouse_pvc_name" {
  description = "The name of the PersistentVolumeClaim"
  value       = kubernetes_persistent_volume_claim.clickhouse_pvc.metadata[0].name
}