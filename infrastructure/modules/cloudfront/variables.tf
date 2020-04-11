variable "project_name" {
  description = "Project Name"
  type        = string
  default     = null
}

variable "domain_name" {
  description = "Domain Name"
  type        = string
  default     = null
}
variable "certificate" {
}
variable "media" {
}

variable "web_acl_cf" {
  description = "Web ACL ID"
  type        = string
  default     = null
}

variable "compress" {
  description = "Whether you want CloudFront to automatically compress content for web requests that include Accept-Encoding: gzip in the request header."
  type        = bool
  default     = null
}