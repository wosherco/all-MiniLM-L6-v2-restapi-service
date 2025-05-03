# Build stage
FROM --platform=$BUILDPLATFORM rust:1.82-slim as builder

WORKDIR /usr/src/app

# Install required system dependencies
RUN apt-get update && apt-get install -y \
  pkg-config \
  libssl-dev \
  build-essential \
  wget \
  unzip \
  && rm -rf /var/lib/apt/lists/*

# Download and install libtorch for build
RUN wget https://download.pytorch.org/libtorch/cpu/libtorch-cxx11-abi-shared-with-deps-2.4.0%2Bcpu.zip \
  && unzip libtorch-cxx11-abi-shared-with-deps-2.4.0+cpu.zip \
  && rm libtorch-cxx11-abi-shared-with-deps-2.4.0+cpu.zip \
  && mv libtorch /usr/local/

# Set environment variables for libtorch
ENV LIBTORCH=/usr/local/libtorch
ENV LD_LIBRARY_PATH=/usr/local/libtorch/lib:$LD_LIBRARY_PATH

# Copy the source code
COPY Cargo.toml Cargo.lock ./
COPY src ./src

# Build the application
RUN cargo build --release

# Model download stage
FROM --platform=$BUILDPLATFORM debian:bookworm-slim as model-downloader

WORKDIR /app

# Install curl for downloading files
RUN apt-get update && apt-get install -y \
  curl \
  && rm -rf /var/lib/apt/lists/*

# Copy the download script
COPY download-model.sh .
RUN chmod +x download-model.sh

# Download the model
RUN ./download-model.sh

# Runtime stage
FROM debian:bookworm-slim

WORKDIR /app

# Install runtime dependencies
RUN apt-get update && apt-get install -y \
  ca-certificates \
  libssl3 \
  wget \
  unzip \
  libgomp1 \
  && rm -rf /var/lib/apt/lists/*

# Download and install libtorch
RUN wget https://download.pytorch.org/libtorch/cpu/libtorch-cxx11-abi-shared-with-deps-2.4.0%2Bcpu.zip \
  && unzip libtorch-cxx11-abi-shared-with-deps-2.4.0+cpu.zip \
  && rm libtorch-cxx11-abi-shared-with-deps-2.4.0+cpu.zip \
  && mv libtorch /usr/local/

# Set environment variables for libtorch
ENV LIBTORCH=/usr/local/libtorch
ENV LD_LIBRARY_PATH=/usr/local/libtorch/lib:$LD_LIBRARY_PATH

# Copy the binary from the builder stage
COPY --from=builder /usr/src/app/target/release/all-MiniLM-L6-v2-restapi-service .

# Copy the model from the model-downloader stage
COPY --from=model-downloader /app/models/all-MiniLM-L6-v2 /app/models/all-MiniLM-L6-v2

# Expose the port the app runs on
EXPOSE 3000

# Run the application
CMD ["./all-MiniLM-L6-v2-restapi-service"] 