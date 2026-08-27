FROM swift:6.0-jammy AS build

WORKDIR /build

COPY Package.swift Package.resolved ./
COPY Sources ./Sources
COPY Tests ./Tests

RUN swift build -c release --static-swift-stdlib
RUN mkdir -p /staging \
    && cp .build/release/PerfumeSoulBackend /staging/ \
    && find .build/release -maxdepth 1 -name "*.resources" -exec cp -R {} /staging/ \;

FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    libpq5 \
    tzdata \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY --from=build /staging /app
COPY scripts ./scripts

EXPOSE 8080

CMD ["./PerfumeSoulBackend", "serve", "--hostname", "0.0.0.0", "--port", "8080"]
