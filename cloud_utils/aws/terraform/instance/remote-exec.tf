resource "null_resource" "remote-exec" {
    depends_on = [aws_instance.mini-loop]
    provisioner "remote-exec" {
      connection {
        agent = false
        timeout = "5m"
        host = "${aws_instance.mini-loop.public_ip}"
        user = "ubuntu"
        private_key = "${file("/home/aws/.ssh/tdaly-user.pem")}" 
    }
      inline = [
        "git clone https://github.com/tdaly61/mini-loop.git",
        "cd mini-loop",
        "git config --global user.name ${var.git_user_name}", 
        "git config --global user.email ${var.git_user_email}", 
        "sudo touch /tom-was-here" 
      ]
    }
}
