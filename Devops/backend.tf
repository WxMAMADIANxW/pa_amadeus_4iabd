terraform {
  backend "gcs" {
    bucket = "tf_bucket_amadeus"
    prefix = "amadeus_state/state"
  }
}

