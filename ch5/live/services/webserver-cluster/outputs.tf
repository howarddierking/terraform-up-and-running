# NOTE: after the output is displayed, remember that it still takes DNS a minute or so to propagate
output "elb_dns_name" {
  value = "${module.webserver_cluster.elb_dns_name}"
}