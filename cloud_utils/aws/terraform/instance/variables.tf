# variable "ml-ami" {
#   description = "the AMI to use"
#   type        = string
# }

variable "ami-map" {
  description = "map of linux distros to amis in the eu-west-2 region"
  type        = map(string)
  default = {
    "fedora36" = "ami-0f9e365442bcca2c2"
    "redhat8" = "ami-0ad8ecac8af5fc52b"
    "ubuntu20" =  "ami-00826bd51e68b1487"
  }
}


# #fedora 36 (eu-west-2)
# #ml-ami = "ami-0f9e365442bcca2c2"
# #redhat 64bit 8x6 (eu-west-2)
# #ml-ami = "ami-0ad8ecac8af5fc52b"
# # ubuntu x86 (eu-west-2)
# ml-ami = "ami-00826bd51e68b1487"

variable "linux-distro" {
  description = "which flavour of linux to use "
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

variable "git_user_name" {
    description = "the name of the git user for any git operations"
    type        = string 
}

variable "git_user_email" {
    description = "the email of the git user for any git operations"
    type        = string 
}