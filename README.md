# Kubernetes-aws-devops-project
In this project I will be building and deploying  a scalable, secure, and highly available application on AWS EKS. I used terraform to deploy the required infrastructure. 
Stage 1: Infrastructure Provisioning 
1.	VPC and more
    a.	3 web public subnets
  
    b.	3 app private subnets
    
    c.	3 db private subnets
    
    d.	1 public route table
    
    e.	6 private route tables
    
    f.	Internet Gateway
    
    g.	NAT gateway
  
Stage 2: IAM

In this stage I used terraform to create roles and granted appropriate access to each role.

  a.	Roles
  -   EKS Cluster role
  -      AmazonEKSClusterPolicy
  -    Eks Node Group role
  -      EKS_CNI_Policy
  -      CloudwatchAgentServerPolicy
 -      AWSXrayWriteOnlyAccess
-      AmazonEKSWorkerNodePolicy
   -      AmazonEC2ContainerRegistryReadOnly
- Linux Jump Server Role
  Jenkins Slave 
-      AmazonEC2ContainerRegistryFullAccess

3.Key Pairs

  a. Windows jump server
  
  b. Linux jump server
  
  c. EKS node group
  
  d. Jenkins master

4.Security Groups
  a. Windows jump server
  
  b. Linux jump server
  
  c. EKS cluster
  
  d. EKS node group
  
  e.  Jenkins master
  
  f. Jenkins slave

5. EC2 – Windows jump server
6. EC2 – Linux jump server
7. EKS cluster
8. EKS node group
9. ECR
10. EC2 – Jenkins master
11. EC2 – Jenkins slave
12. Configure Access to EKS cluster
13. Configure Jenkins Master
14. Configure Jenkins Slave
15. Configure access to EKS from Jenkins Slave
## Installation and Configuration
1.	EC2 - Linux jump server
i.	kubectl - https://docs.aws.amazon.com/eks/latest/userguide/install-kubectl.html
2.	EC2 - Jenkins master
i.	git - sudo yum install git -y
ii.	jenkins - https://www.jenkins.io/doc/tutorials/tutorial-for-installing-jenkins-on-AWS/
3.	EC2 - Jenkins slave
i.	git - sudo yum install git -y
ii.	maven - https://docs.aws.amazon.com/neptune/latest/userguide/iam-auth-connect-prerq.html
iii.	docker - https://docs.aws.amazon.com/serverless-application-model/latest/developerguide/install-docker.html#install-docker-instructions
iv.	kubectl - https://docs.aws.amazon.com/eks/latest/userguide/install-kubectl.html
v.	helm - https://docs.aws.amazon.com/eks/latest/userguide/helm.html
vi.	java - sudo dnf install java-17-amazon-corretto -y

