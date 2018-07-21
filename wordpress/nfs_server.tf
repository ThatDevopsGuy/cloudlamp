
# CloudLAMP Terraform Files
# Copyright 2018, Google LLC
# Fernando Sanchez <fersanchez@google.com>
# Sebastian Weigand <tdg@google.com>


resource "google_compute_disk" "default" {
  name = "${var.nfs_disk_name}"
  type = "${var.nfs_raw_disk_type}"
  zone = "${var.gcp_zone}"
}

data "template_file" "nfs_startup_template" {
  template = "${file("nfs_startup_script.sh.tpl")}"

  vars {
    nfs_disk_name = "${var.nfs_disk_name}"
  }
}

resource "google_compute_instance" "nfs_server" {
  zone = "${var.gcp_zone}"
  name = "${var.nfs_server_name}"

  machine_type = "${var.nfs_machine_type}"

  boot_disk {
    initialize_params {
      image = "${var.nfs_server_os_image}"
    }
  }

  network_interface {
    network = "default"

    access_config {
      // Ephemeral IP
    }
  }

  attached_disk {
    source      = "${google_compute_disk.default.name}"
    device_name = "${var.nfs_disk_name}"
  }

  metadata_startup_script = "${data.template_file.nfs_startup_template.rendered}"
}
