resource "google_storage_bucket" "gcp-bucket-tf" {
    name = "gcp85-bucket-tf"
    location = "us"
    storage_class = "standard"

    website {
    main_page_suffix = "index.html"
    not_found_page   = "404.html"
    }

    uniform_bucket_level_access = true
}

resource "google_storage_bucket_iam_binding" "binding" {
  bucket = google_storage_bucket.gcp-bucket-tf.name
  role = "roles/storage.admin"
  members = [
    "allUsers",
      ]
}

resource "google_storage_bucket_object" "html" {
  name   = "index.html"
  source = "index.html"
  bucket = google_storage_bucket.gcp-bucket-tf.name
} 

output "website_url" {
  value = "https://storage.googleapis.com/${google_storage_bucket.gcp-bucket-tf.name}/index.html"
}