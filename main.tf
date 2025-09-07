resource "aws_key_pair" "main-key" {
    key_name = "main-key"
    public_key = file("singa-key.pub")
}
resource "aws_default_vpc" "singa-vpc" {
    tags = {
        Name = "singa-vpc"
    }
}
resource "aws_security_group" "singa-sg" {
    name = "singa-sg"
    description = "an automated sceurity group for singapore region"
    vpc_id = aws_default_vpc.singa-vpc.id
#in-bound-rules
    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
        description = "HTTP access"
   }
   ingress {
        from_port = 443
        to_port = 443
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
        description = "HTTPS access"
   }
    egress {
        from_port = 0
        to_port = 0
        protocol ="-1"
        cidr_blocks = ["0.0.0.0/0"] 
    }
}
resource "aws_instance" "singa-web" {
    ami = "ami-0933f1385008d33c4"
    instance_type = each.value
    for_each = tomap ({
        singa-web-1 = "t2.micro",
        singa-web-2 = "t2.medium",
        singa-web-3 = "t2.large"
    })
    key_name = aws_key_pair.main-key.key_name
    vpc_security_group_ids = [aws_security_group.singa-sg.id]
    tags = {
        Name = each.key
    }
    user_data = file("install_nginx.sh")
    root_block_device {
        volume_size = 10
        volume_type = "gp2"
        delete_on_termination = true
    }
}
