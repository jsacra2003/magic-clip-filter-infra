variable "project_id"          { type = string }
variable "project_name"        { type = string }
variable "region"              { type = string }
variable "logs_bucket_name"    { type = string }
variable "feedback_logs_filter" {
  type    = string
  default = "jsonPayload.log_type=\"feedback\""
}
