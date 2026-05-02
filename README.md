# OpenCart 4 Setup Action

This action provides a high-speed, pre-configured OpenCart 4 environment for CI/CD. It eliminates the standard overhead of installing PHP extensions and unzipping source files on every run by utilizing a library of pre-packaged images from the GitHub Container Registry (GHCR).

## Technical Rationale
Most OpenCart setup actions rely on on-the-fly provisioning, which consumes significant GitHub Action minutes for repetitive tasks (APT updates, PHP extension compilation, and ZIP extraction). This action shifts that workload to a pre-build factory. It pulls a version-specific image and executes the CLI installer directly against your database, typically achieving a ready state in under 15 seconds.

## Usage
A MariaDB/MySQL service is required. The action handles orchestration and health checks automatically.

```yaml
jobs:
  test:
    runs-on: ubuntu-latest
    services:
      mysql:
        image: mariadb:10.6
        env:
          MYSQL_ROOT_PASSWORD: root_password
          MYSQL_DATABASE: opencart
        ports: ["3306:3306"]
        options: --health-cmd="mysqladmin ping"

    steps:
      - uses: actions/checkout@v6

      - name: Setup OpenCart 4
        uses: stasiuk/setup-opencart@v1
        with:
          oc-version: '4.0.2.3'
          db-password: 'root_password'

      - name: Test
        run: npx playwright test
```

## Configuration

| Input | Description | Default |
| :--- | :--- | :--- |
| `oc-version` | Target OpenCart 4 version (e.g., 4.0.2.3) | `4.0.2.3` |
| `db-hostname` | Database host (use 127.0.0.1 for host network) | `127.0.0.1` |
| `db-username` | Database user | `root` |
| `db-password` | **Required.** Database root password | — |
| `db-port` | Database port | `3306` |
| `admin-password` | Password for the OpenCart admin user | `admin_pass` |