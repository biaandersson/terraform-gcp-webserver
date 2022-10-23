resource "google_compute_instance_group" "webservers" {
  name        = "webservers"
  description = "Terraform Web servers"
  zone        = "europe-north1-a"
  instances   = [google_compute_instance.web-server.self_link]

  named_port {
    name = "http"
    port = 8080
  }
}

# Global Health Check
resource "google_compute_health_check" "webserver-health-check" {
  name                = "webserver-health-check"
  check_interval_sec  = 3
  timeout_sec         = 3
  healthy_threshold   = 1
  unhealthy_threshold = 2

  tcp_health_check {
    port = "http"
  }

  depends_on = [
    google_project_service.compute_service
  ]
}


# Regional Backend Service
resource "google_compute_backend_service" "webserver-backend-service" {
  name                            = "webserver-backend-service"
  timeout_sec                     = 30
  connection_draining_timeout_sec = 10
  load_balancing_scheme           = "EXTERNAL"
  health_checks                   = [google_compute_health_check.webserver-health-check.self_link]
  port_name                       = "http"
  protocol                        = "HTTP"

  backend {
    group          = google_compute_instance_group.webservers.self_link
    balancing_mode = "UTILIZATION"
  }

  depends_on = [
    google_project_service.compute_service
  ]
}

resource "google_compute_url_map" "default" {
  name            = "nginx-url-map"
  default_service = google_compute_backend_service.webserver-backend-service.self_link
}

resource "google_compute_target_http_proxy" "default" {
  name        = "nginx-target-http-proxy"
  url_map     = google_compute_url_map.default.self_link
  description = "Terraform Target HTTP Proxy"
}

resource "google_compute_global_forwarding_rule" "webserver-loadbalancer" {
  name                  = "nginx-global-forwarding-rule"
  ip_protocol           = "TCP"
  port_range            = "80"
  load_balancing_scheme = "EXTERNAL"
  network_tier          = "STANDARD"
  target                = google_compute_target_http_proxy.default.self_link
}

resource "google_compute_firewall" "load_balancer_inbound" {
  name    = "nginx-load-balancer-inbound"
  network = google_compute_network.vpc_network.self_link

  allow {
    protocol = "tcp"
    ports    = ["8080"]
  }

  direction     = "INGRESS"
  source_ranges = ["130.211.0.0/22", "35.191.0.0/16"]
  target_tags   = ["nginx-webserver"]
}
