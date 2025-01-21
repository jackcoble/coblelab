# cloudflared

I use Cloudflare Tunnels to allow access to my self-hosted services, from the outside world. Previously I would have achieved such setup with a A record pointing towards my reverse proxy, but I feel that its the right time to embrace Cloudflare Tunnels! I've been a Cloudflare user for over 5 years now, and have always been happy with their services.

## First time configuration

If we are spinning up this module for the first time, we must create a new Cloudflare tunnel.

```
nix-shell -p cloudflared
cloudflared tunnel login
cloudflared tunnel create <host>

# encrypt the json string via sops-nix and append to the secrets.yaml as "cloudflare-tunnel"
# then set tunnelId = "<id>"
# remove ~/.cloudflared/
# rebuild system configuration
```

## Managing services

When creating a Tunnel via the CLI, it will be considered "locally managed" - meaning all configuration happens in the YAML file which resides on our system. I do not want this however, so in the Zero Trust dashboard, I navigate to my tunnel and migrate it to be managed by the web.

If I need to expose services on my server to the outside world, I will do it through the Zero Trust dashboard and creating a public hostname record.
