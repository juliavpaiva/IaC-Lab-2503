module "resources" {
  source = "./modules/resources"
  instance_type = var.instance_type
  public_subnet_count = var.public_subnet_count
  private_subnet_count = var.private_subnet_count
  web_public_server_count = var.web_public_server_count
  web_private_server_count = var.web_private_server_count
  web_private_server_volume_size = var.web_private_server_volume_size
  rds_instance_volume_size = var.rds_instance_volume_size
}