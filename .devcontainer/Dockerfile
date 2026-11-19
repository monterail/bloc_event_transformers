FROM node:26.13.1-trixie-slim
# Instance apt mirror and download cache, passed by Montecito; unset elsewhere.
ARG MONTECITO_DOWNLOAD_CACHE MONTECITO_APT_MIRROR_UBUNTU MONTECITO_APT_MIRROR_DEBIAN
COPY --chmod=0755 montecito-mirrors.sh /usr/local/bin/montecito-mirrors
RUN montecito-mirrors setup && if [ -r /etc/profile.d/montecito-mirrors.sh ]; then . /etc/profile.d/montecito-mirrors.sh; fi \
    && apt-get update && apt-get install -y --no-install-recommends git ca-certificates unzip curl \
    && rm -rf /var/lib/apt/lists/* \
    && npm install --global pnpm@12.21.0 \
    && PNPM_HOME=/usr/local pnpm add --global --allow-build=@anthropic-ai/claude-code \
       @openai/codex@0.169.0 @anthropic-ai/claude-code@2.1.325

# Dart SDK (pinned, checksum-verified); the package is pure Dart (bloc, rxdart).
ARG DART_VERSION=3.7.2
RUN if [ -r /etc/profile.d/montecito-mirrors.sh ]; then . /etc/profile.d/montecito-mirrors.sh; fi \
    && case "$(dpkg --print-architecture)" in amd64) A=x64;; arm64) A=arm64;; *) exit 1;; esac \
    && url="$(montecito-mirrors url "https://storage.googleapis.com/dart-archive/channels/stable/release/${DART_VERSION}/sdk/dartsdk-linux-${A}-release.zip")" \
    && curl -fsSL -o /tmp/dart.zip "$url" \
    && curl -fsSL "$url.sha256sum" | awk '{print $1"  /tmp/dart.zip"}' | sha256sum -c - \
    && unzip -q /tmp/dart.zip -d /usr/lib && mv /usr/lib/dart-sdk /usr/lib/dart \
    && rm /tmp/dart.zip
ENV PATH="/usr/lib/dart/bin:/home/node/.pub-cache/bin:${PATH}"
