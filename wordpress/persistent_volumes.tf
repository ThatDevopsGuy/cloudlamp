resource "kubernetes_storage_class" "slow" {
  metadata {
    name = "slow"
  }

  storage_provisioner = "kubernetes.io/gce-pd"

  parameters {
    type = "pd-standard"
  }
}

resource "kubernetes_persistent_volume" "vol_1" {
  metadata {
    name = "${var.vol_1}"
  }

  spec {
    access_modes = ["ReadWriteMany"]

    capacity {
      storage = "${var.vol_1_size}"
    }

    storage_class_name = "${kubernetes_storage_class.slow.metadata.0.name}"

    persistent_volume_source {
      nfs {
        server = "${google_compute_instance.nfs_server.network_interface.0.address}"
        path   = "${var.export_path}"
      }
    }
  }
}

resource "kubernetes_persistent_volume_claim" "pvc_1" {
  metadata {
    name = "${var.vol_1}-claim"
  }

  spec {
    access_modes       = ["ReadWriteMany"]
    storage_class_name = "${kubernetes_storage_class.slow.metadata.0.name}"

    resources {
      requests {
        storage = "${var.vol_1_size}"
      }
    }

    volume_name = "${kubernetes_persistent_volume.vol_1.metadata.0.name}"
  }
}
