FROM node:26.13.1-trixie-slim
RUN apt-get update && apt-get install -y --no-install-recommends git ca-certificates unzip curl \
    && rm -rf /var/lib/apt/lists/* \
    && npm install --global pnpm@12.21.0 \
    && PNPM_HOME=/usr/local pnpm add --global --allow-build=@anthropic-ai/claude-code \
       @openai/codex@0.169.0 @anthropic-ai/claude-code@2.1.325

# Dart SDK (pinned); the package is pure Dart (bloc, rxdart).
ARG DART_VERSION=3.7.2
RUN case "$(dpkg --print-architecture)" in amd64) A=x64;; arm64) A=arm64;; *) exit 1;; esac \
    && curl -fsSL -o /tmp/dart.zip "https://storage.googleapis.com/dart-archive/channels/stable/release/${DART_VERSION}/sdk/dartsdk-linux-${A}-release.zip" \
    && unzip -q /tmp/dart.zip -d /usr/lib && mv /usr/lib/dart-sdk /usr/lib/dart \
    && rm /tmp/dart.zip
ENV PATH="/usr/lib/dart/bin:/home/node/.pub-cache/bin:${PATH}"
