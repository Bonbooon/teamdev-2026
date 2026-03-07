# ADR 0006: Use darkaonline/l5-swagger for OpenAPI Generation

- Status: Accepted
- Date: 2026-03-06

## Context

The project requires OpenAPI (v3.0) contract generation from Laravel controller annotations, as defined in `specs/api/openapi-contracts.md`. The generated `openapi.json` serves as:
1. Source of truth for API structure
2. Input for frontend type generation via aspida (`mise codegen-openapi`)
3. Documentation via Swagger UI (already running at port 8080 in Docker)

We evaluated two approaches:

### Option A: `darkaonline/l5-swagger` (wraps `zircote/swagger-php`)

- Most popular Laravel OpenAPI package (~3.5M downloads)
- Provides `php artisan l5-swagger:generate` for OpenAPI generation
- Built-in Swagger UI at `/api/docs` (matches spec's requirement for `GET /api/docs`)
- Auto-discovers annotations across all controller directories
- Supports both docblock annotations (`@OA\*`) and PHP 8 Attributes (`#[OA\*]`)
- Active maintenance, supports Laravel 10
- Has its own config file with many tunable options

### Option B: `zircote/swagger-php` directly

- The core library that l5-swagger wraps — lighter, fewer moving parts
- Same annotation/attribute syntax
- No built-in artisan command — requires custom CLI setup or `./vendor/bin/openapi`
- No Swagger UI bundled
- Slightly more manual setup for scan paths, output paths, etc.

## Decision

We adopt **Option A: `darkaonline/l5-swagger`** with **PHP 8 Attributes** (not docblock annotations).

### Why PHP 8 Attributes over Docblock Annotations

```php
// Docblock (traditional) — no IDE type checking, error-prone
/** @OA\Get(path="/api/users") */

// PHP 8 Attribute (chosen) — type-safe, IDE autocomplete, future-proof
#[OA\Get(path: '/api/users')]
```

## Consequences

### Positive

- Seamless integration with existing `mise codegen-openapi` workflow via artisan command
- Swagger UI available out of the box (complements existing Docker swagger-ui service)
- PHP 8 Attributes provide IDE autocomplete and compile-time type checking
- Community standard — minimal onboarding friction
- Configurable output path to match `teamdev-2026-api/docs/openapi/openapi.json`

### Trade-offs

- Heavier than raw `zircote/swagger-php` (pulls in Swagger UI assets and config)
- OpenAPI annotations can be verbose (40-60 lines per endpoint in docblocks)
- Config file (`config/l5-swagger.php`) has many options that need initial tuning
- Tightly coupled to `zircote/swagger-php` version — occasionally breaks on upgrades

## Configuration Notes

- Output path: configured to generate to `docs/openapi/openapi.json` (relative to Laravel root, maps to `teamdev-2026-api/docs/openapi/openapi.json` in Docker)
- Scan paths: `app/Interfaces/Http/Controllers/` (clean architecture controller location)
- PHP 8 Attributes mode enabled

## References

- OpenAPI contracts spec: `specs/api/openapi-contracts.md`
- l5-swagger: `https://github.com/DarkaOnLine/L5-Swagger`
- zircote/swagger-php: `https://github.com/zircote/swagger-php`
- Existing Swagger UI: Docker service at port 8080
