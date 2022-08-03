variable "instance_id" {
  type = string
}
variable "droplet_names" {
  type    = set(string)
  default = ["first", "second", "third", "fourth"]
}
variable "create_droplet" {
  type = bool
  default = true
}
variable "company_name" {
  type = string
}
variable "schedule" {
  type = string
}
