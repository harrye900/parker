packer {
  required_plugins {
    amazon = {
      source  = "github.com/hashicorp/amazon"
      version = ">= 1.3.0"
    }
  }
}

source "amazon-ebs" "webserver" {
  region        = "us-east-2"
  instance_type = "t3.micro"
  ssh_username  = "ec2-user"

  source_ami_filter {
    filters = {
      name                = "al2023-ami-2023.*-x86_64"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }

    owners      = ["amazon"]
    most_recent = true
  }

  ami_name        = "packer-nginx-docker-{{timestamp}}"
  ami_description = "Amazon Linux 2023 with Nginx and Docker"

  tags = {
    Name        = "packer-nginx-docker"
    Environment = "Learning"
    BuiltBy     = "Packer"
  }
}

build {
  sources = ["source.amazon-ebs.webserver"]

  provisioner "shell" {
    inline = [
      "sudo dnf update -y",
      "sudo dnf install nginx docker -y",
      "sudo systemctl enable nginx",
      "sudo systemctl enable docker",
      "sudo systemctl start nginx",
      "sudo systemctl start docker",
      "echo '<h1>This AMI was created automatically with Packer</h1>' | sudo tee /usr/share/nginx/html/index.html",
      "sudo systemctl status nginx --no-pager",
      "docker --version"
    ]
  }
}