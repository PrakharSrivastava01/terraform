# key pair creation
resource "aws_key_pair" "my_key" {  # Added quotes around resource name
    key_name   = "terra-ec2-key"
    public_key = file("terra-ec2-key.pub")
}

# default vpc
resource "aws_default_vpc" "default" {  # Added quotes around resource name
    tags = {
        Name = "Default VPC"
    }
}

# security group creation
resource "aws_security_group" "my_security_group" {
    name        = "automate-sg"
    description = "this will create an automated sg for Terraform"
    vpc_id      = aws_default_vpc.default.id # interpolation
    
    # inbound rules
    ingress {
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]  # Fixed: removed extra dot "0..0.0.0/0" → "0.0.0.0/0"
        description = "SSH Open for all"
    }
    
    ingress {
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]  # Fixed: removed extra dot
        description = "HTTP Open for all"
    }
    
    ingress {
        from_port   = 8000
        to_port     = 8000
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]  # Fixed: removed extra dot "0.0.0.0./0" → "0.0.0.0/0"
        description = "Notes-app"
    }
    
    # outbound rules
    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]  # Fixed: removed extra dot
        description = "Allow all outbound traffic"
    }
}

# EC2 instance creation
resource "aws_instance" "my_instance" {
    key_name        = aws_key_pair.my_key.key_name
    vpc_security_group_ids = [aws_security_group.my_security_group.id]  # Changed to vpc_security_group_ids and .id
    instance_type   = "t2.micro"
    ami             = "ami-02d26659fd82cf299" # ubuntu 20.04 in ap-south-1

    root_block_device {
        volume_size           = 15
        volume_type           = "gp3"
        delete_on_termination = true
    }
    
    tags = {
        Name = "Terraform-EC2-automated"
    }
}
