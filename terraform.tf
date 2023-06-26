terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "4.69.1"
    }
  }
}


provider "google" {
  #credentials = gcloud util was used to authorize with my GCP account 
  project = var.project_id
  region  = var.region
}

