FROM dart:3.9.4 AS dart-sdk

FROM node:26.13.1-trixie-slim
RUN apt-get update && apt-get install -y --no-install-recommends git ca-certificates \
    && rm -rf /var/lib/apt/lists/* \
    && npm install --global pnpm@12.21.0 \
    && PNPM_HOME=/usr/local pnpm add --global --allow-build=@anthropic-ai/claude-code \
       @openai/codex@0.169.0 @anthropic-ai/claude-code@2.1.325
# Dart SDK pinned to 3.9.4 (pure Dart package; no Flutter needed for tests)
COPY --from=dart-sdk /usr/lib/dart /usr/lib/dart
ENV DART_SDK=/usr/lib/dart PATH=/usr/lib/dart/bin:$PATH
