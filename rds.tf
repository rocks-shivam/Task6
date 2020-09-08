provider "aws" {
  region = "ap-south-1"
  profile = "shivam1"
}
data "aws_vpc" "default" {
  default = true
}

data "aws_subnet_ids" "all" {
  vpc_id = data.aws_vpc.default.id
}

data "aws_security_group" "default" {
  vpc_id = data.aws_vpc.default.id
  name   = "launch-wizard-1"
}

module "db" {
  source  = "terraform-aws-modules/rds/aws"
  version = "~> 2.0"

  identifier = "database-1"

  engine            = "mysql"
  engine_version    = "5.7.19"
  instance_class    = "db.t2.micro"
  storage_type = "gp2"
  allocated_storage = 20
  storage_encrypted = false

  username = "root"
  password = "rocksshivam"
  port     = "3306"

  vpc_security_group_ids = [data.aws_security_group.default.id]
  subnet_ids = data.aws_subnet_ids.all.ids
  publicly_accessible = true

  availability_zone = "ap-south-1a"

  maintenance_window = "Mon:00:00-Mon:03:00"
  backup_window      = "03:00-06:00"

  multi_az = false

   backup_retention_period = 0

  tags = {
    Owner       = "user"
    Environment = "dev"
  }

  enabled_cloudwatch_logs_exports = ["audit", "general"]
  
  iam_database_authentication_enabled = false
  

  # DB parameter group
  family = "mysql5.7"

  # DB option group
  major_engine_version = "5.7"

  # Snapshot name upon DB deletion
  final_snapshot_identifier = "demodb"

  # Database Deletion Protection
  deletion_protection = false

  parameters = [
    {
      name  = "character_set_client"
      value = "utf8"
    },
    {
      name  = "character_set_server"
      value = "utf8"
    }
  ]

  options = [
    {
      option_name = "MARIADB_AUDIT_PLUGIN"

      option_settings = [
        {
          name  = "SERVER_AUDIT_EVENTS"
          value = "CONNECT"
        },
        {
          name  = "SERVER_AUDIT_FILE_ROTATIONS"
          value = "37"
        },
      ]
    },
  ]
}

