# All-MiniLM-L6-v2 REST API Service

A lightweight REST API service that provides sentence embeddings using the `all-MiniLM-L6-v2` model.

## Features

- Fast and efficient sentence embeddings
- Async REST API using Axum
- Multi-architecture support (x86_64 and ARM)
- Health check endpoint
- Containerized deployment
- Pre-downloaded model for faster startup

## Installation

You have a docker image available on [GitHub Container Registry](https://github.com/users/wosherco/packages/container/all-MiniLM-L6-v2-restapi-service).

You can pull it using the following command:

```bash
docker pull ghcr.io/wosherco/all-minilm-l6-v2-restapi-service:latest
```

Checkout the example [docker-compose.yml](./docker-compose.yml) file to see how to use it.

## API Endpoints

### POST /embed

Generate embeddings for a given text.

Request:

```json
{
  "text": "This is a sample sentence to embed"
}
```

Response:

```json
{
    "embedding": [0.123, -0.456, ...] // 384-dimensional vector
}
```

### GET /health

Check the service health status.

Response:

```json
{
  "status": "ok",
  "version": "0.1.0"
}
```

## Running with Docker

### Building and Running

1. Build the image (this will download the model during build):

```bash
docker build -t embedding-service .
```

2. Run the container:

```bash
docker run -p 3000:3000 embedding-service
```

The container will start immediately with the model pre-loaded, no need to download it on first run.

## Testing the Service

You can test the service using curl:

```bash
# Health check
curl http://localhost:3000/health

# Response:
# {
#   "status": "ok",
#   "version": "0.1.0"
# }

# Generate embeddings
curl -X POST http://localhost:3000/embed \
  -H "Content-Type: application/json" \
  -d '{"text": "This is a sample sentence to embed"}'

# Response:
# {
#   "embedding": [0.123, -0.456, ...]
# }
```

## Development

### Prerequisites

- Rust 1.75 or later
- Docker (for containerized deployment)

### Building from Source

```bash
cargo build --release
```

### Running Tests

```bash
cargo test
```

## GitHub Actions Workflow

This repository includes a GitHub Actions workflow to automatically build and push the Docker image to GitHub Container Registry (ghcr.io) when changes are pushed to the main branch.

### Setup Requirements

1. Ensure your repository has the appropriate permissions:

   - Go to Settings > Actions > General > Workflow permissions
   - Select "Read and write permissions"

2. To use the published Docker image:

   ```bash
   # Latest version
   docker pull ghcr.io/<username>/all-MiniLM-L6-v2-restapi-service:latest

   # Specific version (from Cargo.toml)
   docker pull ghcr.io/<username>/all-MiniLM-L6-v2-restapi-service:0.1.0

   # Run the container
   docker run -p 3000:3000 ghcr.io/<username>/all-MiniLM-L6-v2-restapi-service:latest
   ```

## Manual Docker Build

```bash
docker build -t embedding-service .
docker run -p 3000:3000 embedding-service
```
