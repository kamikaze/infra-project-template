# Common RDS configuration

locals {
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  env              = local.environment_vars.locals.environment

  base_source_url = "tfr:///terraform-aws-modules/rds/aws"
}

inputs = {
  identifier = "db-${local.env}"

  engine               = "postgres"
  engine_version       = "16.3"
  family               = "postgres16"
  major_engine_version = "16"
  instance_class       = "db.t4g.micro"

  allocated_storage     = 20
  max_allocated_storage = 100

  db_name  = "myapp"
  username = "dbadmin"
  port     = 5432

  multi_az = true # High availability with standby replica

  maintenance_window      = "Mon:00:00-Mon:03:00"
  backup_window           = "03:00-06:00"
  backup_retention_period = 7

  skip_final_snapshot = true
  deletion_protection = local.env == "prod" ? true : false

  performance_insights_enabled = true
}
