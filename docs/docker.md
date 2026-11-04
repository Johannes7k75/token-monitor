# Run the Hub with Docker

The Hub image is published to `ghcr.io/johannes7k75/token-hub` and builds from `Dockerfile.hub`. It runs the Node Hub without the desktop widget or collector.

For a separate collector container, see [Run the headless agent with Docker](headless-agent.md#run-with-docker) and use `docker-compose.agent.yml`.

From a checkout, create a `.env` file with your shared secret and the Hub URL devices will use:

```dotenv
TOKEN_MONITOR_SECRET=replace-with-a-private-secret
TOKEN_MONITOR_HUB_URL=http://your-hub-host:17321
```

Start the Hub using the published image:

```bash
docker compose -f docker-compose.hub.yml pull
docker compose -f docker-compose.hub.yml up -d --no-build
```

Or build the Hub image from the checkout:

```bash
docker compose -f docker-compose.hub.yml up -d --build
```

Both Hub and agent Compose files support local builds and use `init: true` for signal forwarding and child-process cleanup. Select the desired file explicitly with `-f`.

Compose maps host port `17321` to container port `17321` and stores Hub data in the `token-monitor-data` volume. Configure each device with the Hub URL and the same secret.

## Publish a Hub release

Push an app version tag (`v<version>`) to trigger `.github/workflows/release-hub.yml` alongside the desktop release workflow. For example:

```bash
git tag v0.86.1
git push origin v0.86.1
```

This builds the tagged checkout and publishes both `ghcr.io/johannes7k75/token-hub:0.86.1` and `ghcr.io/johannes7k75/token-hub:latest`. The workflow authenticates with the repository's `GITHUB_TOKEN` and package write permission.

Compose uses `latest` by default. To pin a deployment, change its image to a published version, such as `ghcr.io/johannes7k75/token-hub:0.86.1`.

### GHCR publishing permissions

The release workflow needs `packages: write` and access to the container package. An existing package can be connected to this repository without granting its Actions workflows write access.

If publishing fails with `permission_denied: write_package`, open the container's **Package settings → Manage Actions access**, add `Johannes7k75/token-monitor` if missing, and give it the **Write** role. Then rerun the failed release workflow. Repeat for `token-agent` if it has the same error. Repository association and Actions access are separate settings; adding more workflow token permissions does not replace the package access grant.
