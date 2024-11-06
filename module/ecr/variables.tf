variable "ecr_name" {
    description = "AWS ECR Name"
    type = string
}

variable "image_tag_mutability" {
    description = "Tag mutability setting for the repository"
    type = string
    default = "MUTABLE"
}

variable "scan_on_push" {
    description = "Configuration block that defines image scanning configuration for the repository"
    type = bool
    default = false
}

variable "encryption_type" {
    description = "encryption type to use for the repository"
    type = string
    default = "AES256"
}

variable "kms_key" {
    description = "ARN of the KMS key to use when encryption_type is KMS"
    type = string
    default = null
}