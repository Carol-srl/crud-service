
# FILE SYSTEM
resource "aws_efs_file_system" "crudservice_config" {
  creation_token = "crudservice-config-efs"
  lifecycle_policy {
    transition_to_ia = "AFTER_30_DAYS"
  }
}

resource "aws_efs_mount_target" "crudservice" {
  count          = length(data.terraform_remote_state.main_infra.outputs.private_subnets)
  file_system_id = aws_efs_file_system.crudservice_config.id
  subnet_id      = data.terraform_remote_state.main_infra.outputs.private_subnets[count.index]
  security_groups = [data.terraform_remote_state.main_infra.outputs.ecs_security_group_id]
}

resource "aws_efs_access_point" "crudservice_config" {
  file_system_id = aws_efs_file_system.crudservice_config.id
  posix_user {
    gid = 0
    uid = 0
  }
  root_directory {
    path = "/home/node/app/disk"
    creation_info {
      owner_gid   = 0
      owner_uid   = 0
      permissions = "0777"
    }
  }
}
