job "cgs-token-admin-static-stage" {
  datacenters = ["mb-hel"]
  type = "batch"

  reschedule {
    attempts = 0
  }

  group "cgs-token-admin-static-stage-group" {
    count = 1

    task "cgs-token-admin-static-stage-task" {
      driver = "docker"

      config {
        image = "ghcr.io/communitygrocerystore/token-admin:stage"
        force_pull = true
        entrypoint = ["npm"]
        command = "run"
        args = ["deploy:static"]
        mount {
          type = "bind"
          source = "secrets/rclone.conf"
          target = "/root/.config/rclone/rclone.conf"
          readonly = true
        }
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
        DEPLOY_BUCKET = "token-admin-staging-communitygrocerystore-com"
        VITE_EVM_NETWORK="sepolia"
      }

      vault { policies = [ "cgs-deployer" ] }

      template {
        data = <<-EOF
        {{ with secret "kv/cgs/cloudflare/cgs-deployer" }}
        CLOUDFLARE_API_TOKEN="{{ .Data.data.TOKEN }}"
        ACCESS_KEY_ID="{{ .Data.data.ACCESS_KEY_ID }}"
        SECRET_ACCESS_KEY="{{ .Data.data.SECRET_ACCESS_KEY }}"
        ENDPOINT="{{ .Data.data.ENDPOINT }}"
        {{ end }}
        EOF
        destination = "secrets/file.env"
        env         = true
      }

      template {
        data = <<-EOF
        {{ with secret "kv/cgs/cloudflare/cgs-deployer" }}[r2]
        type = s3
        provider = Cloudflare
        region = auto
        endpoint = {{ .Data.data.ENDPOINT }}
        access_key_id = {{ .Data.data.ACCESS_KEY_ID }}
        secret_access_key = {{ .Data.data.SECRET_ACCESS_KEY }}
        {{ end }}
        EOF
        destination = "secrets/rclone.conf"
      }
    }
  }
}
