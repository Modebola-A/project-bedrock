variable "student_id" {
  type        = string
  description = "Student ID for unique bucket naming"
}

variable "dev_user_name" {
  type        = string
  description = "The bedrock-dev-view IAM username"
  default     = "bedrock-dev-view"
}
