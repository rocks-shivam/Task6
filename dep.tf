
provider "kubernetes" {
  config_context_cluster = "minikube"
}

resource "kubernetes_deployment" "wordpress" {
  metadata {
    name = "wordpress"
    
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        env = "production"
        region = "IN"
        App = "wordpress"
      }
       match_expressions {
              key      = "env"
              operator = "In"
              values   = ["production", "webserver"]
            }
    }
    

    template {
      metadata {
        labels = {
          env = "production"
          region = "IN"
          App = "wordpress"
        }
      }

         
      spec {
       container {
      image = "wordpress"
      name  = "mywordpress-cont"
     

          
        }
      }
    }
  }
}

resource "kubernetes_service" "wordpress" {
  metadata {
    name = "wordpress"
  }
   spec {
        selector = {
      App = kubernetes_deployment.wordpress.spec.0.template.0.metadata[0].labels.App
    }
    port {
      node_port   = 30201
      port        = 80
      target_port = 80
    }

    type = "NodePort"
  }
}

