data "aws_secretsmanager_secret_version" "db_secret" {
  secret_id = var.rds_secret_arn
}

locals {
  db_credentials = jsondecode(data.aws_secretsmanager_secret_version.db_secret.secret_string)
}

/******************************************************
  Get image digest
******************************************************/
data "external" "image_digest" {
  for_each = toset(var.service_repo)
  program  = ["bash", "../../utils/get-digest.sh", each.key]
}


# Define a Kubernetes deployment
resource "kubernetes_deployment" "movies_api" {
  for_each = toset(var.service_repo)

  metadata {
    name = element(split("/", each.key), 1)
    labels = {
      app = element(split("/", each.key), 1)
    }
  }

  spec {
    replicas = 3 # Number of replicas

    selector {
      match_labels = {
        app = element(split("/", each.key), 1)
      }
    }

    template {
      metadata {
        labels = {
          app = element(split("/", each.key), 1)
        }
      }

      spec {
        container {
          name  = element(split("/", each.key), 1)
          image = "${lookup(var.repository_urls, each.key, "Not found")}@${data.external.image_digest[each.key].result["digest"]}"

          port {
            container_port = 8080
          }
          env {
            name  = "DB_URL"
            value = "jdbc:mysql://${var.db_host}:3306/${var.db_name}"
          }

          env {
            name  = "DB_USERNAME"
            value = local.db_credentials["username"]
          }

          env {
            name  = "DB_PASSWORD"
            value = local.db_credentials["password"]
          }

          env {
            name  = "REDIS_HOST"
            value = var.redis_host
          }

          env {
            name  = "REDIS_PORT"
            value = var.redis_port
          }

          env {
            name  = "REDIS_PASSWORD"
            value = var.redis_password
          }
          
          env {
            name = "ENVIRONMENT"
            value = "AWS"
          }
        }

        affinity {
          node_affinity {
            required_during_scheduling_ignored_during_execution {
              node_selector_term {
                match_expressions {
                  key      = "topology.kubernetes.io/zone"
                  operator = "In"
                  values   = var.availability_zones
                }
              }
            }
          }

          pod_anti_affinity {
            preferred_during_scheduling_ignored_during_execution {
              weight = 100
              pod_affinity_term {
                label_selector {
                  match_expressions {
                    key      = "app"
                    operator = "In"
                    values   = [element(split("/", each.key), 1)]
                  }
                }
                topology_key = "kubernetes.io/hostname"
              }
            }
          }
        }
      }
    }
  }

  depends_on = [data.external.image_digest]
}


resource "kubernetes_service_v1" "movies_api" {
  for_each = toset(var.service_repo)
  metadata {
    name = element(split("/", each.key), 1)
    annotations = {
      "service.beta.kubernetes.io/aws-load-balancer-type": "nlb"
      "service.beta.kubernetes.io/aws-load-balancer-name" : element(split("/", each.key), 1)
      "service.beta.kubernetes.io/aws-load-balancer-internal" : "true"
      "service.beta.kubernetes.io/aws-load-balancer-nlb-target-type" : "instance"

      # Health Check Settings
      "service.beta.kubernetes.io/aws-load-balancer-healthcheck-protocol"            = "http"
      "service.beta.kubernetes.io/aws-load-balancer-healthcheck-port"                = "traffic-port"
      "service.beta.kubernetes.io/aws-load-balancer-healthcheck-path"                = "/"
      "service.beta.kubernetes.io/aws-load-balancer-healthcheck-healthy-threshold"   = 3
      "service.beta.kubernetes.io/aws-load-balancer-healthcheck-unhealthy-threshold" = 3
      "service.beta.kubernetes.io/aws-load-balancer-healthcheck-interval"            = 10 # The default timeout for TCP is 10s and HTTP is 6s

      # Access Control
      "service.beta.kubernetes.io/load-balancer-source-ranges" = "10.0.0.0/16" # CIDRs that are allowed to access the NLB
      "service.beta.kubernetes.io/aws-load-balancer-scheme"    = "internal"    # Internet-facing or internal

      # AWS Resource Tags
      "service.beta.kubernetes.io/aws-load-balancer-additional-resource-tags" = "Environment=dev"
    }
  }
  spec {
    selector = {
      app = kubernetes_deployment.movies_api[each.key].metadata.0.labels["app"]
    }
    port {
      port        = 8080
      target_port = 8080
    }
    # load_balancer_class = "service.k8s.aws/nlb"
    type = "LoadBalancer"
  }

  depends_on = [kubernetes_deployment.movies_api]
}

resource "kubernetes_pod" "kali" {
  metadata {
    name = "kali"
    labels = {
      app = "kali"
    }
  }

  spec {
    container {
      image = "kalilinux/kali-rolling"
      name  = "kali"

      # This command will keep the container running
      command = ["sleep", "infinity"]

     env {
        name  = "DB_URL"
        value = "jdbc:mysql://${var.db_host}:3306/${var.db_name}"
      }

      env {
        name  = "DB_USERNAME"
        value = local.db_credentials["username"]
      }

      env {
        name  = "DB_PASSWORD"
        value = local.db_credentials["password"]
      }
      env {
        name  = "REDIS_PASSWORD"
        value = var.redis_password
      }
      env {
        name  = "REDIS_HOST"
        value = var.redis_host
      }

      env {
        name  = "REDIS_PORT"
        value = var.redis_port
      }
    }
  }
}

