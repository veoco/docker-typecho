# Typecho for CI

The Typecho in docker has been configured for CI system.

## Feature

- Alpine based
- Caddy+PHP7
- Typecho development version

## Example

Default account is **admin/admin**.

```
docker pull veoco/typecho:latest
docker run -d --name=blog -p 80:80 veoco/typecho
```