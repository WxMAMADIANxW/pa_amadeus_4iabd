resource "google_project_service" "project_apis" {
  for_each = var.activate_apis
  project  = var.project_id
  service  = each.value
}

resource "google_service_account" "amadeus_account" {
  account_id   = "amadeus-id"
  display_name = "Service Account"
}


resource "google_project_iam_member" "amadeus_bucket_acces" {
  project = var.project_id
  for_each = toset([
    "roles/storage.admin",
    "roles/secretmanager.admin",
    "roles/run.admin",
    "roles/connectors.admin",
    "roles/pubsub.admin",
    "roles/workflows.admin",
    "roles/storage.objectAdmin",
    "roles/bigquery.admin",
    "roles/logging.privateLogViewer",
    "roles/artifactregistry.admin"
  ])
  role = each.key
  member  = "serviceAccount:${google_service_account.amadeus_account.email}"
}


resource "google_secret_manager_secret" "amadeus-admin" {

  secret_id   = "admin"
  replication {
    user_managed {
      replicas {
        location = "europe-west1"
      }
    }
  }
}
resource "google_secret_manager_secret" "amadeus-password" {

  secret_id   = "password"
  replication {
    user_managed {
      replicas {
        location = "europe-west1"
      }
    }
  }
}

resource "google_secret_manager_secret_version" "admin" {
  secret = google_secret_manager_secret.amadeus-admin.id
  secret_data = var.amadeus_admin

}

resource "google_secret_manager_secret_version" "password" {
  secret = google_secret_manager_secret.amadeus-password.id
  secret_data = var.amadeus_password
}

resource "google_storage_bucket" "amadeus_bucket"{
  name     = var.bucket_name_amadeus
  location = var.region
  force_destroy = true
  storage_class = var.storage_class
  uniform_bucket_level_access = true
  lifecycle_rule {
    condition {
      age = 1
    }
    action {
      type = "Delete"
    }
  }
  versioning {
    enabled = false
  }
}

resource "google_bigquery_dataset" "dataset" {
  dataset_id                  = "amadeus_dataset"
  description                 = "Amadeus dataset to store table"
  location                    = var.region
  project                     = var.project_id


  access {
    role          = "OWNER"
    user_by_email = google_service_account.amadeus_account.email
  }

}

