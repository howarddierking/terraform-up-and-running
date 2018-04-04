variable "server_port" {
  type = "string"
  description = "The port the server will use for HTTP requests"
  default = "8080"
}

variable "cluster_name" {
  description = "The name to use for all the cluster resources"
}

# Q: are these still useful when using terraform backend in the consuming core module?

# variable "db_remote_state_bucket" {
#   description = "The name of the S3 bucket for the database's remote state"
# }

# variable "db_remote_state_key" {
#   description = "The path for the database's remote state in S3"
# }