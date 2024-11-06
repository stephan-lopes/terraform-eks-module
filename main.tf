module "iam" {
  source = "./modules/iam"

  roles = [
    {
      assign_as_cluster_role = true
      role_name              = "CustomEKSClusterRole"
      attached_policy_arns   = ["arn:aws:iam::aws:policy/AmazonEKSServicePolicy", "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"]
      assume_role_policy = {
        Version = "2012-10-17"
        Statement = [
          {
            Action = "sts:AssumeRole"
            Effect = "Allow"
            Principal = {
              Service = "eks.amazonaws.com"
            }
          }
        ]
      }
    },
    {
      role_name = "CustomNodeInstanceRole"
      attached_policy_arns = ["arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly", "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy",
        "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
      ]
      assume_role_policy = {
        Version = "2012-10-17",
        Statement = [
          {
            Effect = "Allow",
            Principal = {
              Service = "ec2.amazonaws.com"
            },
            Action = "sts:AssumeRole"
          }
        ]
      }
    }
  ]
}

module "vpc" {
  source = "./modules/vpc"

  template = {
    vpc = {
      name               = "eks-vpc-2"
      enable_dns_support = true
    }

    internet_gateway = {
      name = "eks-study-igw"
    }

    nat_gateway = {
      name = "eks-study-nat"
    }

    subnets = [
      {
        name              = "eks-public-01"
        cidr_block        = "10.0.0.0/19"
        availability_zone = "us-east-1a"
        public_subnet     = true
      },
      {
        name              = "eks-public-02"
        cidr_block        = "10.0.32.0/19"
        availability_zone = "us-east-1b"
        public_subnet     = true
      },
      {
        name              = "eks-public-03"
        cidr_block        = "10.0.64.0/19"
        availability_zone = "us-east-1c"
        public_subnet     = true
      },
      {
        name              = "eks-public-04"
        cidr_block        = "10.0.96.0/19"
        availability_zone = "us-east-1d"
        public_subnet     = true
      },
      {
        name              = "eks-private-01"
        cidr_block        = "10.0.128.0/19"
        availability_zone = "us-east-1a"
      },
      {
        name              = "eks-private-02"
        cidr_block        = "10.0.160.0/19"
        availability_zone = "us-east-1b"
      },
      {
        name              = "eks-private-03"
        cidr_block        = "10.0.192.0/19"
        availability_zone = "us-east-1c"
      },
      {
        name              = "eks-private-04"
        cidr_block        = "10.0.224.0/19"
        availability_zone = "us-east-1d"
      }
    ]

    security_groups = [
      {
        name        = "eks-study-control-plane-sg"
        description = "Security group for EKS control plane"
        ingress_rules = [
          {
            from_port   = 443
            to_port     = 443
            protocol    = "tcp"
            cidr_blocks = ["0.0.0.0/0"]
          }
        ]
        egress_rules = [
          {
            from_port   = 0
            to_port     = 0
            protocol    = "-1"
            cidr_blocks = ["0.0.0.0/0"]
          }
        ]
      },
      {
        name        = "eks-study-worker-nodes-sg"
        description = "Security group for EKS worker nodes"
        ingress_rules = [
          {
            description = "Inbound Rules (communication between nodes and with control plane)"
            from_port   = 0
            to_port     = 65535
            protocol    = "tcp"
            self        = true
          },
          {
            description = "Allow kubelet API (required for control plane to worker communication)"
            from_port   = 10250
            to_port     = 10250
            protocol    = "tcp"
            cidr_blocks = ["0.0.0.0/0"]
          },
          {
            description = "NodePort Services"
            from_port   = 30000
            to_port     = 32767
            protocol    = "tcp"
            cidr_blocks = ["0.0.0.0/0"]
          }
        ]
        egress_rules = [
          {
            description = "Allow all egress"
            from_port   = 0
            to_port     = 0
            protocol    = "-1"
            cidr_blocks = ["0.0.0.0/0"]
          }
        ]
      }
    ]

    route_table = {
      routes = [
        {
          route_table_type = "public"
          destination      = "0.0.0.0/0"
          target = {
            internet_gateway = true
          }
        },
        {
          route_table_type = "private"
          destination      = "0.0.0.0/0"
          target = {
            nat_gateway = true
          }
        }
      ]
    }
  }
}


module "eks" {
  source = "./modules/eks"

  template = {
    name     = "eks-study-lab"
    role_arn = module.iam.cluster_role_arn[0]
    version  = "1.31"
    irsa = {
      enable    = true
      role_name = "CustomEKSIamRoleforServiceAccounts"
    }
    vpc_config = {
      subnet_ids                 = module.vpc.public_subnets_ids
      endpoint_public_access     = true
      cluster_security_group_ids = module.vpc.security_groups_ids[0]
    }

    node_groups = [{
      name       = "study-ng-01"
      role_arn   = module.iam.node_group_role_arn[0]
      subnet_ids = module.vpc.private_subnets_ids
      scaling_config = {
        desired_size = 1
        max_size     = 1
        min_size     = 0
      }
      update_config = {
        max_unavailable = 1
      }
    }]
  }

}
