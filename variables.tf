variable "project_id" {
  description = "Google Cloud project for Toggl"
  type        = string
}

variable "region" {
  description = "Google Cloud region for hosting Toggl project"
  type        = string
}

variable "primary_zone" {
  description = "Zone for primary instance"
}

variable "standby_zone" {
  description = "Zone for standby instance"
}

variable "private_key_path" {
  description = "Key path for private key"
  default     = "./privatekey.ppk"
  type        = string

}
variable "primary_instance_name" {
  default = "primary-postgres-instance"
  type    = string

}

variable "secondary_instance_name" {
  default = "primary-postgres-instance"
  type    = string

}
