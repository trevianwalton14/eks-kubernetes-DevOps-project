provider "aws" {
    region = "us-east-1"
    access_key = "Access Key"
    secret_key = "Secret Key"
  
}
#Creating VPC
resource "aws_vpc" "myvpc" {
    cidr_block = "10.0.0.0/16"
  
  tags = {
    Name = "myterraformvpc"
  }
}

resource "aws_subnet" "subnet-1" {
    vpc_id = aws_vpc.myvpc.id
    cidr_block = "10.0.1.0/24"
    availability_zone = "us-east-1a"

    tags = {
      Name = "web-public-subnet-1a"
    }
  
}

resource "aws_subnet" "subnet-2" {
    vpc_id = aws_vpc.myvpc.id
    cidr_block = "10.0.2.0/24"
    availability_zone = "us-east-1a"

    tags = {
      Name = "app-private-subnet-1a"
    }
  
}

resource "aws_subnet" "subnet-3" {
    vpc_id = aws_vpc.myvpc.id
    cidr_block = "10.0.3.0/24"
    availability_zone = "us-east-1a"

    tags = {
      Name = "db-private-subnet-1a"
    }
  
}

resource "aws_subnet" "subnet-4" {
    vpc_id = aws_vpc.myvpc.id
    cidr_block = "10.0.4.0/24"
    availability_zone = "us-east-1b"

    tags = {
      Name = "web-public-subnet-1b"
    }
  
}

resource "aws_subnet" "subnet-5" {
    vpc_id = aws_vpc.myvpc.id
    cidr_block = "10.0.5.0/24"
    availability_zone = "us-east-1b"

    tags = {
      Name = "app-private-subnet-1b"
    }
  
}

resource "aws_subnet" "subnet-6" {
    vpc_id = aws_vpc.myvpc.id
    cidr_block = "10.0.6.0/24"
    availability_zone = "us-east-1b"

    tags = {
      Name = "db-private-subnet-1b"
    }
  
}

resource "aws_subnet" "subnet-7" {
    vpc_id = aws_vpc.myvpc.id
    cidr_block = "10.0.7.0/24"
    availability_zone = "us-east-1c"

    tags = {
      Name = "web-public-subnet-1c"
    }
  
}

resource "aws_subnet" "subnet-8" {
    vpc_id = aws_vpc.myvpc.id
    cidr_block = "10.0.8.0/24"
    availability_zone = "us-east-1c"

    tags = {
      Name = "app-private-subnet-1c"
    }
  
}

resource "aws_subnet" "subnet-9" {
    vpc_id = aws_vpc.myvpc.id
    cidr_block = "10.0.9.0/24"
    availability_zone = "us-east-1c"

    tags = {
      Name = "db-private-subnet-1c"
    }
  
}

resource "aws_internet_gateway" "myigw" {
    vpc_id = aws_vpc.myvpc.id

    tags = {
        Name = "p2igw"
    }

}

resource "aws_route_table" "private-rt" {
    count = 6
    vpc_id = aws_vpc.myvpc.id

    tags = {
        Name = "private-rt-${count.index + 1}"
  }
  
}

resource "aws_route_table_association" "private-association" {
    count = 6

     route_table_id = aws_route_table.private-rt[count.index].id
     subnet_id = element([

        aws_subnet.subnet-2.id, # app-private-subnet-1a
        aws_subnet.subnet-3.id, # db-private-subnet-1a
        aws_subnet.subnet-5.id, # app-private-subnet-1b
        aws_subnet.subnet-6.id, # db-private-subnet-1b
        aws_subnet.subnet-8.id, # app-private-subnet-1c
        aws_subnet.subnet-9.id  # db-private-subnet-1c
     ], count.index)
  
}

resource "aws_eip" "myeip" {
  depends_on = [ aws_internet_gateway.myigw ]
}

resource "aws_nat_gateway" "myngw" {
    allocation_id = aws_eip.myeip.id 
    subnet_id = aws_subnet.subnet-1.id

    tags = {
      Name = "nat-gw"
    }
    depends_on = [ aws_internet_gateway.myigw ]
}

resource "aws_route" "private_nat_route" {
    count = 6
    route_table_id = aws_route_table.private-rt[count.index].id
    destination_cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.myngw.id
}

resource "aws_iam_role" "eks_cluster_role" {
    name = "eks-cluster-role"

    assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                Effect = "Allow"
                Principal = {
                    Service = "eks.amazonaws.com"
                }
                Action = "sts:AssumeRole"
            }
        ]
    })
  
}

resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
    role = aws_iam_role.eks_cluster_role.name
    policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

resource "aws_iam_role" "eks_node_group_role" {
    name = "eks-node-group-role"

    assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                Effect = "Allow"
                Principal = {
                    Service = "ec2.amazonaws.com"
                }
                Action = "sts:AssumeRole"
            }
        ]
    })
  
}

resource "aws_iam_role_policy_attachment" "EKS_CNI_Policy" {
    role = aws_iam_role.eks_node_group_role.name
    policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

resource "aws_iam_role_policy_attachment" "ecr_read_only_policy" {
  role       = aws_iam_role.eks_node_group_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

resource "aws_iam_role_policy_attachment" "cloudwatch_agent_server_policy" {
  role = aws_iam_role.eks_node_group_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

resource "aws_iam_role_policy_attachment" "AWS_Xray_Write_Only_Access" {
  role = aws_iam_role.eks_node_group_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSXrayWriteOnlyAccess"
}

resource "aws_iam_role_policy_attachment" "eks_worker_node_policy" {
  role = aws_iam_role.eks_node_group_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role" "linux_jump_server" {
    name = "linux-jump-server"

    assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                Effect = "Allow"
                Principal = {
                    Service = "ec2.amazonaws.com"
                }
                Action = "sts:AssumeRole"
            }
        ]
    })
}

resource "aws_iam_role" "jenkins_slave_instance" {
    name = "jenkins-slave-instance"

    assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                Effect = "Allow"
                Principal = {
                    Service = "ec2.amazonaws.com"
                }
                Action = "sts:AssumeRole"
            }
        ]
    })
  
}

resource "aws_iam_role_policy_attachment" "ec2_container_registry_full_access" {
  role = aws_iam_role.jenkins_slave_instance.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryFullAccess"
}

#Create A Key Pair
resource "tls_private_key" "rsa" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "TF_key" {
  key_name   = "TF_key"
  public_key = tls_private_key.rsa.public_key_openssh
}

resource "local_file" "private_key_pem" {
  content  = tls_private_key.rsa.private_key_pem
  filename = "tfkey"
  file_permission = "0400"
}

#Create A Key Pair
resource "tls_private_key" "rsa_node" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "TF_key_node" {
  key_name   = "TF_key_node"
  public_key = tls_private_key.rsa_node.public_key_openssh
}

resource "local_file" "private_key_pem_node" {
  content  = tls_private_key.rsa_node.private_key_pem
  filename = "tfkey-node"
  file_permission = "0400"
}

#Create A Key Pair
resource "tls_private_key" "rsa_jenkins" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "TF_key_jenkins" {
  key_name   = "TF_key_jenkins"
  public_key = tls_private_key.rsa_jenkins.public_key_openssh
}

resource "local_file" "private_key_pem_jenkins" {
  content  = tls_private_key.rsa_jenkins.private_key_pem
  filename = "tfkey-jenkins"
  file_permission = "0400"
}
#Create A Key Pair
resource "tls_private_key" "rsa_jenkins_s" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "TF_key_jenkins_s" {
  key_name   = "TF_key_jenkins_s"
  public_key = tls_private_key.rsa_jenkins_s.public_key_openssh
}

resource "local_file" "private_key_pem_jenkins_s" {
  content  = tls_private_key.rsa_jenkins_s.private_key_pem
  filename = "tfkey-jenkins-s"
  file_permission = "0400"
}

#Create A Key Pair
resource "tls_private_key" "rsa_linux" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "TF_key_linux" {
  key_name   = "TF_key_linux"
  public_key = tls_private_key.rsa_linux.public_key_openssh
}

resource "local_file" "private_key_pem_linux" {
  content  = tls_private_key.rsa_linux.private_key_pem
  filename = "tfkey-linux"
  file_permission = "0400"
}


#Security Group - window jump server
resource "aws_security_group" "window_jump_server_sg" {
  name        = "window_jump_server_sg"
  description = "Allow RDP access"
  vpc_id      = aws_vpc.myvpc.id

  ingress {
    from_port   = 3389
    to_port     = 3389
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "windows-jump-server-sg"
  }
}


# Secuirty Group - Linux jump server
resource "aws_security_group" "linux_jump_server_sg" {
  name        = "allow_web_traffic"
  description = "Allow SSH access"
  vpc_id      = aws_vpc.myvpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "linux-jump-server-sg"
  }
}



resource "aws_security_group" "eks_cluster_sg" {
  name        = "eks_cluster_sg"
  description = "Allow web and SSH access"
  vpc_id      = aws_vpc.myvpc.id

  tags = {
    Name = "eks-cluster-sg"
  }
}

resource "aws_security_group" "eks_node-group_sg" {
  name        = "eks_node-group_sg"
  description = "Allow web and SSH access"
  vpc_id      = aws_vpc.myvpc.id

  tags = {
    Name = "eks-node-group-sg"
  }
}

resource "aws_security_group" "jenkins_master_sg" {
  name        = "jenkins_master_sg"
  description = "Allow web and SSH access"
  vpc_id      = aws_vpc.myvpc.id

  tags = {
    Name = "jenkins-master-sg"
  }
}

resource "aws_security_group" "jenkins_slave_sg" {
  name        = "jenkins_slave_sg"
  description = "Allow web and SSH access"
  vpc_id      = aws_vpc.myvpc.id

  tags = {
    Name = "windows-jump-server"
  }
}

#Linux Instance
resource "aws_instance" "linux_instance" {
  ami                    = "ami-0e449927258d45bc4"
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.subnet-1.id
  vpc_security_group_ids = [aws_security_group.linux_jump_server_sg.id]
  key_name               = aws_key_pair.TF_key_linux.key_name
  associate_public_ip_address = true
}

#Windows Instance
resource "aws_instance" "window_instance" {
  ami                    = "ami-09cb80360d5069de4"
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.subnet-4.id
  vpc_security_group_ids = [aws_security_group.window_jump_server_sg.id]
  key_name               = aws_key_pair.TF_key.key_name
  associate_public_ip_address = true
}

#Provisioning EKS Cluster
resource "aws_eks_cluster" "eks_cluster" {
  name     = "eks_cluster-cluster"
  role_arn = aws_iam_role.eks_cluster_role.arn

  vpc_config {
    subnet_ids = [aws_subnet.subnet-2.id, aws_subnet.subnet-5.id, aws_subnet.subnet-8.id]
  }
}

# Ecr Provisioning
resource "aws_ecr_repository" "my_app" {
  name = "my-app"
}

# Jankins Master
#Linux Instance
resource "aws_instance" "jennkins_master_instance" {
  ami                    = "ami-0e449927258d45bc4"
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.subnet-5.id
  vpc_security_group_ids = [aws_security_group.jenkins_master_sg.id]
  key_name               = aws_key_pair.TF_key_jenkins.key_name
  associate_public_ip_address = true
}

# Jankins Slave
resource "aws_instance" "jennkins_slave_instance" {
  ami                    = "ami-0e449927258d45bc4"
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.subnet-5.id
  vpc_security_group_ids = [aws_security_group.jenkins_slave_sg.id]
  key_name               = aws_key_pair.TF_key_jenkins_s.key_name
  associate_public_ip_address = true
}

# Provision Node Group
resource "aws_eks_node_group" "eks_node_group" {
  cluster_name    = aws_eks_cluster.eks_cluster.name
  node_group_name = "eks-node-group"
  node_role_arn   = aws_iam_role.eks_cluster_role.arn
  subnet_ids      = [aws_subnet.subnet-2.id, aws_subnet.subnet-5.id, aws_subnet.subnet-8.id]


  scaling_config {
    desired_size = 2
    max_size     = 3
    min_size     = 1
  }
}
