variable "project_id"{
  description = "GCP Project ID"
  type = string
  default = "cellular-smoke-352111"
}

variable "region" {
  description = "GCP Region"
  type = string
  default = "europe-west1"

}

variable "zone"{
  description = "GCP zone for project"
  type = string
  default = "europe-west1b"
}

variable "bucket_name_amadeus" {
  description = "GCP Bucket Name for JSON file"
  type = string
  default = "amadeus_bucket"
}
variable bucket-tfstate_amadeus {
  description = "GCP Bucket Name for TF"
  type = string
}
variable "storage_class"{
  description = "type of storage"
  type = string
  default = "STANDARD"
}
variable "amadeus_admin" {
  description = "amadeus username"
  type        = string
  sensitive   = true
}

variable "amadeus_password" {
  description = "amadeus password"
  type        = string
  sensitive   = true
}


variable "activate_apis" {
  type = set(string)
  default = [
    "iamcredentials.googleapis.com",
    "iam.googleapis.com",
    "secretmanager.googleapis.com",
    "storage-component.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "workflows.googleapis.com",
    "run.googleapis.com",
    "bigquery.googleapis.com"
  ]
}