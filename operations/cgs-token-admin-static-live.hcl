job "cgs-token-admin-static-live" {
  datacenters = [ "mb-hel" ]
  type = "batch"

  reschedule { attempts = 0 }

  group "cgs-token-admin-static-live-group" {
    count = 1

    task "cgs-token-admin-static-live-task" {
      driver = "docker"

      config {
        image = "ghcr.io/communitygrocerystore/token-admin:live"
        force_pull = true
        entrypoint = [ "/workdir/entrypoint.sh" ]
        mount {
          type = "bind"
          source = "local/entrypoint.sh"
          target = "/workdir/entrypoint.sh"
          readonly = true
        }
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
        PHASE = "live"
        DEPLOY_BUCKET = "token-admin-live-communitygrocerystore-com"
        VITE_EVM_NETWORK = "mainnet"
        VITE_USDC_CONTRACT_ADDRESS="0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48"
        VITE_USDT_CONTRACT_ADDRESS="0xdAC17F958D2ee523a2206206994597C13D831ec7"
        VITE_CGS_TOKEN_CONTRACT_ADDRESS="0xfb8e97De81a224D3CaC7421A19E798D25f0890EA"
        VITE_CGS_PRESALE_CONTRACT_ADDRESS="0xc34D2C9f983158529b44fdF00687bedaB5D2D644"
        VITE_CGS_VESTING_CONTRACT_ADDRESS="0x76BB927327dd6d7B9c0f40d60412977d9f82D7d4"
        VITE_CGS_MULTISIG_ADDRESS="0xE23aA5a2Fe770ae3e26fD838A723940A17d422F0"
      }

      vault { policies = [ "cgs-deployer" ] }

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

      template {
        data = <<-EOF
        #!/bin/sh

        echo "Building token-admin static files"
        npm run build

        echo "Syncing token-admin static files to cloudflare r2"
        rclone sync dist r2:${DEPLOY_BUCKET}/
        EOF
        destination = "local/entrypoint.sh"
        perms = "0755"
      }
    }
  }
}
