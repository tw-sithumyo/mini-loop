variable "ml-ami" {
  description = "the AMI to use"
  type        = string
}

variable "ml-instance-type" {
  description = "the instance shape "
  type        = string
}

variable "ml-keyname" {
    description = "the ssh keyname to use "
    type        = string 
}

variable "ml-instance-name1" {
    description = "the name of the mini-loop instance"
    type        = string 
}