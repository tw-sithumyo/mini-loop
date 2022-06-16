resource "null_resource" "remote-exec" {
    depends_on = [aws_instance.mini-loop-1]
    provisioner "remote-exec" {
      connection {
        agent = false
        timeout = "30m"
        host = "aws_instance.mini-loop-1"
        user = "ubuntu"
        private_key = file("/home/aws/.ssh/tdaly-user.pem")
    }
      inline = [
        "touch ~/IMadeAFile.Right.Here",
        "git clone https://github.com/tdaly61/mini-loop.git",
        "cd mini-loop; git fetch origin k3s22",
        "cd mini-loop; git checkout k3s22",
      ]
    }
}
