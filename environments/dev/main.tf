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
  name = "test2"
  location = "europe-west2"
  project = local.project
}

module "chicargo_carlo_disposition" {
  image           = "europe-west4-docker.pkg.dev/data-integration-development/chicargo-carlo-disposition-docker/chicargo-carlo-disposition@sha256:15026af29ca4694dffc43227ff790d9552f2247f0a313f839df927d93bb5deec"
}