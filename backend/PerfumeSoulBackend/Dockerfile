FROM swift:6.0-jammy AS build

WORKDIR /build

COPY Package.swift Package.resolved ./
RUN swift package resolve

RUN mkdir -p Tests/PerfumeSoulBackendTests
COPY Sources ./Sources

RUN swift build -c release --static-swift-stdlib \
    && BIN_PATH="$(swift build -c release --static-swift-stdlib --show-bin-path)" \
    && mkdir -p /staging \
    && cp "$BIN_PATH/PerfumeSoulBackend" /staging/ \
    && find "$BIN_PATH/" -maxdepth 1 -name "*.resources" -exec cp -R {} /staging/ \;

FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    tzdata \
    && rm -rf /var/lib/apt/lists/*

RUN useradd --user-group --create-home --system --skel /dev/null --home-dir /app vapor

WORKDIR /app

COPY --from=build /staging /app
RUN chown -R vapor:vapor /app
USER vapor:vapor

EXPOSE 8080

CMD ["./PerfumeSoulBackend", "serve", "--hostname", "0.0.0.0", "--port", "8080"]
