output "load_balancer_ingress_ip" {
  value = { for key, value in kubernetes_service_v1.movies_api : key => value.status[0].load_balancer[0].ingress[0].ip }  
}

output "load_balancer_ingress_hostname" {
  value = { for key, value in kubernetes_service_v1.movies_api : key => value.status[0].load_balancer[0].ingress[0].hostname }  
}