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