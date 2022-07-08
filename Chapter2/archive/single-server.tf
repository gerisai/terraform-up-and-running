provider "aws" {
    region = "us-west-1"
}

variable "server_port" {
  description = "The port the server will use for HTTP requests"
  type = number
  default = 8080
}

resource "aws_security_group" "instance" {
  name = "terraform-example-instance"

  ingress {
    from_port = var.server_port # Variable reference
    to_port = var.server_port
    protocol = "tcp"
    cidr_blocks = [ "0.0.0.0/0" ]
  }
}

resource "aws_instance" "example" {
    ami = "ami-0487b1fe60c1fd1a2"
    instance_type = "t2.micro"
    vpc_security_group_ids = [aws_security_group.instance.id] # Resource attribute reference
    # Using interpolation to embed a variable into a string
    user_data = <<-EOF
                #!/bin/bash
                echo "Hello, World" > index.html
                nohup busybox httpd -f -p ${var.server_port} & 
                EOF

    tags = {
        Name = "terraform-example"
    }
}

output "public_ip" {
  value = aws_instance.example.public_ip
  description = "The public IP address of the web server"
}