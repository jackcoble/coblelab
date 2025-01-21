# pocket-id

[Pocket ID](https://github.com/stonith404/pocket-id) is a simple OIDC provider that works exclusively with passkeys, meaning passwords are a thing of the past. This is great as I'm a believer in a passkey future, and love to adopt them wherever I can.

Currently, this service is being exposed on Cloudflare, at [auth.coblelabs.net](https://auth.coblelabs.net).

A caveat when running this with Podman, I had to change the default Caddy port from 80, to 8081. Due to 80 being a privileged port, and Podman does not run as root! This was the easiest workaround.
