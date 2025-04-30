job "erc20-admin-stage" {
  datacenters = ["mb-hel"]
  type = "service"

  group "erc20-admin-stage-group" {
    count = 1

    update {
      stagger      = "30s"
      max_parallel = 1
      canary       = 1
      auto_revert  = true
      auto_promote = true
    }

    network {
      mode = "bridge"
      port "docker" {
        to = 3000
        host_network = "wireguard"
      }
    }

    task "erc20-admin-stage-task" {
      driver = "docker"

      config {
        image = "${CONTAINER_REGISTRY_ADDR}/memetic-block/erc20-admin:[[.image_tag]]"
        force_pull = true
      }

      restart {
        attempts = 0
        mode = "fail"
      }

      resources {
        cpu    = 4096
        memory = 4096
      }

      env {
        PHASE = "stage"
        VERSION = "[[.image_tag]]"
      }

      template {
        data = <<-EOF
        {{- range service "container-registry" }}
        CONTAINER_REGISTRY_ADDR="{{ .Address }}:{{ .Port }}"
        {{- end }}
        EOF
        env = true
        destination = "local/env"
      }

      service {
        name = "erc20-admin-stage"
        port = "docker"

        tags = [
          "traefik.enable=true",
          "traefik.http.routers.erc20-admin-stage.entrypoints=https",
          "traefik.http.routers.erc20-admin-stage.tls=true",
          "traefik.http.routers.erc20-admin-stage.tls.certresolver=memetic-block",
          "traefik.http.routers.erc20-admin-stage.rule=Host(`erc20-admin-stage.hel.memeticblock.net`)"
        ]
      }
    }
  }
}