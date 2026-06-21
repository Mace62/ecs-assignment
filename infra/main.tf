module "networking" {
  source = "./modules/networking"
}

module "ecr" {
  source = "./modules/ecr"
}

module "acm" {
  source = "./modules/acm"
}

module "security" {
  source = "./modules/security"

  vpc_id = module.networking.vpc_id
}

module "alb" {
  source                = "./modules/alb"
  vpc_id                = module.networking.vpc_id
  public_subnet_ids     = module.networking.public_subnet_ids
  alb_security_group_id = module.security.alb_security_group_id
  certificate_arn       = module.acm.certificate_arn
}

module "ecs" {
  source = "./modules/ecs"

  vpc_id                = module.networking.vpc_id
  private_subnet_ids    = module.networking.private_subnet_ids
  ecr_repository_url    = module.ecr.repository_url
  target_group_arn      = module.alb.target_group_arn
  ecs_security_group_id = module.security.ecs_security_group_id
}