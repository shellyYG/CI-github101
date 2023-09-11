terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 4.47"
    }
  }
}

provider "google" {
  project = local.project
  region  = local.region
}

locals {
  project  = "terraform-github-actions"
  region   = "europe-west2"
}

resource "google_storage_bucket" "gcs_bucket" {
  name = "test-bucket-random-001123"
  location = "europe-west2"
  project = local.project
}