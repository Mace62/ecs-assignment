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
  source = "./modules/alb"
  vpc_id                = module.networking.vpc_id
  public_subnet_ids     = module.networking.public_subnet_ids
  alb_security_group_id = module.security.alb_security_group_id
  certificate_arn       = module.acm.certificate_arn
}