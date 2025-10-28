
variable "image" {
  description = "Docker image URL for the Carol Nest service"
  type        = string
  default     = "972096737302.dkr.ecr.eu-west-3.amazonaws.com/carol/crud-service:6.5.0"
}

variable "port" {
  description = "Port exposed by the docker image to redirect traffic to"
  default     = 3000
}

variable "task_count" {
  description = "Number of docker containers to run"
  default     = 2
}

variable "health_check_path" {
  default = "/bff/services/health"
}

variable "COLLECTION_DEFINITION_FOLDER" {
  type    = string
  default = "/home/node/app/collections"
}

variable "VIEWS_DEFINITION_FOLDER" {
  type    = string
  default = "/home/node/app/views"
}

variable "USER_ID_HEADER_KEY" {
  type    = string
  default = "miauserid"
}

variable "CRUD_LIMIT_CONSTRAINT_ENABLED" {
  type    = string
  default = true
}

variable "CRUD_MAX_LIMIT" {
  type    = string
  default = 200
}

variable "ENV" {
  description = "(lowercase) deployment environment (e.g., dev, staging, prod)"
  type        = string
}

variable "LOG_LEVEL" {
  type = map(string)
  default = {
    dev     = "debug"
    staging = "info"
    prod    = "debug"
  }
}

variable "SERVICE_ENV" {
  type = map(string)
  default = {
    dev     = "development"
    staging = "preprod"
    prod    = "production"
  }
}
