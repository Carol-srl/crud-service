
variable "image" {
  description = "Docker image URL for the Carol Nest service"
  type        = string
  default     = "nginx:latest"
}

variable "port" {
    description = "Port exposed by the docker image to redirect traffic to"
    default = 3000
}

variable "task_count" {
    description = "Number of docker containers to run"
    default = 1
}

variable "health_check_path" {
  default = "/bff/services/health"
}

variable "fargate_cpu" {
    description = "Fargate instance CPU units to provision (1 vCPU = 1024 CPU units)"
    default = "256"
}

variable "fargate_memory" {
    description = "Fargate instance memory to provision (in MiB)"
    default = "1024"
}

variable "env" {
  type    = string
  default = "development"
}

variable "log_level" { 
  type    = string 
  default = "debug"
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

variable "MONGODB_URL" { 
  type    = string 
  default = "mongodb://localhost:27017/crud-local"
}
