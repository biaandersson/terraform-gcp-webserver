resource "google_compute_instance" "web-server" {
  name         = "web-server"
  machine_type = "f1-micro"
  zone         = "europe-north1-a"

  tags = ["nginx-webserver"]

  boot_disk {
    initialize_params {
      image = "debian-11-bullseye-v20220920"
    }
  }

  metadata_startup_script = <<EOT
  curl -fsSL https://get.docker.com -o get-docker.sh &&
  sudo sh get-docker.sh &&
  sudo service docker start &&
  sudo docker run -p 8080:80 -d nginxdemos/hello
 EOT

  network_interface {
    network    = google_compute_network.vpc_network.self_link
    subnetwork = google_compute_subnetwork.quickstart_subnet.name
  }
}

resource "google_compute_instance" "web-server2" {
  name         = "web-server2"
  machine_type = "f1-micro"
  zone         = "europe-north1-a"

  tags = ["nginx-webserver"]

  boot_disk {
    initialize_params {
      image = "debian-11-bullseye-v20220920"
    }
  }

  metadata_startup_script = <<EOT
  curl -fsSL https://get.docker.com -o get-docker.sh &&
  sudo sh get-docker.sh &&
  sudo service docker start &&
  sudo docker run -p 8080:80 -d nginxdemos/hello
 EOT

  network_interface {
    network    = google_compute_network.vpc_network.self_link
    subnetwork = google_compute_subnetwork.quickstart_subnet.name
  }
}
