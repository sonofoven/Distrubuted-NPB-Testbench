variable "ssh_user" {
  description = "Admin user able to connect to container via ssh"
  type        = string
  default     = "ubuntu"
}

variable "instance_type" {
  description = "The VM's instance type"
  type        = string
  default     = "e2-standard-4"
}

variable "ssh_key_name" {
  description = "The name of the ssh key present within the keys dir"
  type        = string
  default     = "clientkey.pub"
}
