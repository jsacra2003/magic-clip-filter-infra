locals {
  filter_config = {
    pi_and_jailbreak = {
      filter_enforcement = "ENABLED"
      confidence_level   = "LOW_AND_ABOVE"
    }
    rai_filters = [
      { filter_type = "DANGEROUS",         confidence_level = "HIGH" },
      { filter_type = "HATE_SPEECH",       confidence_level = "MEDIUM_AND_ABOVE" },
      { filter_type = "SEXUALLY_EXPLICIT", confidence_level = "MEDIUM_AND_ABOVE" },
      { filter_type = "HARASSMENT",        confidence_level = "MEDIUM_AND_ABOVE" },
    ]
  }
}

# Template in the deployment region — used by Agent Engine at runtime
resource "google_model_armor_template" "regional" {
  provider    = google-beta
  template_id = "${var.project_name}-safety"
  location    = var.region
  project     = var.project_id

  template_metadata {
    log_template_operations = false
    log_sanitize_operations = false
  }

  filter_config {
    pi_and_jailbreak_filter_settings {
      filter_enforcement = "ENABLED"
      confidence_level   = "LOW_AND_ABOVE"
    }
    rai_settings {
      rai_filters { filter_type = "DANGEROUS"         confidence_level = "HIGH" }
      rai_filters { filter_type = "HATE_SPEECH"       confidence_level = "MEDIUM_AND_ABOVE" }
      rai_filters { filter_type = "SEXUALLY_EXPLICIT" confidence_level = "MEDIUM_AND_ABOVE" }
      rai_filters { filter_type = "HARASSMENT"        confidence_level = "MEDIUM_AND_ABOVE" }
    }
  }
}

# Template in eu multi-region — required by Gemini Enterprise (location must match GE app)
resource "google_model_armor_template" "gemini_enterprise" {
  provider    = google-beta
  template_id = "${var.project_name}-safety"
  location    = "eu"
  project     = var.project_id

  template_metadata {
    log_template_operations = false
    log_sanitize_operations = false
  }

  filter_config {
    pi_and_jailbreak_filter_settings {
      filter_enforcement = "ENABLED"
      confidence_level   = "LOW_AND_ABOVE"
    }
    rai_settings {
      rai_filters { filter_type = "DANGEROUS"         confidence_level = "HIGH" }
      rai_filters { filter_type = "HATE_SPEECH"       confidence_level = "MEDIUM_AND_ABOVE" }
      rai_filters { filter_type = "SEXUALLY_EXPLICIT" confidence_level = "MEDIUM_AND_ABOVE" }
      rai_filters { filter_type = "HARASSMENT"        confidence_level = "MEDIUM_AND_ABOVE" }
    }
  }
}
