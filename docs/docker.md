# Run the Hub with Docker

The Hub image is published to `ghcr.io/johannes7k75/token-hub`. It runs the Node Hub without the desktop widget or collector.

From a checkout, create a `.env` file with your shared secret and the Hub URL devices will use:

```dotenv
TOKEN_MONITOR_SECRET=replace-with-a-private-secret
TOKEN_MONITOR_HUB_URL=http://your-hub-host:17321
```

Start the Hub:

```bash
docker compose pull
docker compose up -d
```

Compose maps host port `17321` to container port `17321` and stores Hub data in the `token-monitor-data` volume. Configure each device with the Hub URL and the same secret.

## Publish a Hub release

Push an app version tag (`v<version>`) to trigger `.github/workflows/release-hub.yml` alongside the desktop release workflow. For example:

```bash
git tag v0.86.1
git push origin v0.86.1
```

This builds the tagged checkout and publishes both `ghcr.io/johannes7k75/token-hub:0.86.1` and `ghcr.io/johannes7k75/token-hub:latest`. The workflow authenticates with the repository's `GITHUB_TOKEN` and package write permission.

Compose uses `latest` by default. To pin a deployment, change its image to a published version, such as `ghcr.io/johannes7k75/token-hub:0.86.1`.
