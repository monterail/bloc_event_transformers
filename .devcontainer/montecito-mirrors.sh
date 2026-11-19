#!/bin/sh
# Points package managers at the Montecito instance mirrors. Montecito passes
# these Docker build arguments; outside Montecito they are unset and this script
# changes nothing, so the image still builds anywhere.
#   MONTECITO_APT_MIRROR_UBUNTU / MONTECITO_APT_MIRROR_DEBIAN  operator apt mirror
#   MONTECITO_DOWNLOAD_CACHE  allowlisted cache for language registries and SDKs
# Docker Hub base images already come through the sandbox's registry mirror.
#
# Dockerfile usage (see the onboarding Dockerfile):
#   ARG MONTECITO_DOWNLOAD_CACHE MONTECITO_APT_MIRROR_UBUNTU MONTECITO_APT_MIRROR_DEBIAN
#   COPY montecito-mirrors.sh /usr/local/bin/montecito-mirrors
#   RUN montecito-mirrors setup && . /etc/profile.d/montecito-mirrors.sh && apt-get update ...
# Start every later RUN step that downloads with `. /etc/profile.d/montecito-mirrors.sh &&`,
# and wrap direct HTTPS downloads: curl -fsSLO "$(montecito-mirrors url https://...)".
# Agents get the same environment at runtime through the login-shell profile.
set -eu
profile=/etc/profile.d/montecito-mirrors.sh

url() {
  cache=${MONTECITO_DOWNLOAD_CACHE:-}
  if [ -z "$cache" ] && [ -r "$profile" ]; then cache=$(. "$profile" && printf '%s' "${MONTECITO_DOWNLOAD_CACHE:-}"); fi
  case $1 in https://*) [ -n "$cache" ] && { printf '%s/%s\n' "$cache" "${1#https://}"; return; };; esac
  printf '%s\n' "$1"
}

# Writes a file into root's and each existing user's home (Maven, Gradle).
homes() {
  for home in /root /home/*; do
    [ -d "$home" ] || continue
    install -d "$home/$1"
    printf '%s\n' "$3" > "$home/$1/$2"
    owner=$(stat -c %u:%g "$home"); chown -R "$owner" "$home/${1%%/*}"
  done
}

setup() {
  cache=${MONTECITO_DOWNLOAD_CACHE:-}
  ubuntu=${MONTECITO_APT_MIRROR_UBUNTU:-}
  debian=${MONTECITO_APT_MIRROR_DEBIAN:-}
  for value in "$cache" "$ubuntu" "$debian"; do
    case $value in ''|http://[A-Za-z0-9.:/_-]*) ;; *) echo "montecito-mirrors: unexpected mirror URL" >&2; exit 1;; esac
  done

  # apt: one-line and deb822 sources. The Ubuntu archive mirror covers x86_64 only.
  for f in /etc/apt/sources.list /etc/apt/sources.list.d/*.list /etc/apt/sources.list.d/*.sources; do
    [ -f "$f" ] || continue
    if [ -n "$ubuntu" ] && [ "$(uname -m)" = x86_64 ]; then
      sed -E -i "s#https?://(archive|security)\.ubuntu\.com/ubuntu/?([[:space:]]|\$)#$ubuntu/\2#g" "$f"
    fi
    if [ -n "$debian" ]; then sed -E -i "s#https?://deb\.debian\.org/debian/?([[:space:]]|\$)#$debian/\1#g" "$f"; fi
    # The DigitalOcean mirror has no debian-security; it comes through the cache.
    if [ -n "$cache" ]; then sed -E -i "s#https?://(deb|security)\.debian\.org/debian-security/?([[:space:]]|\$)#$cache/deb.debian.org/debian-security/\2#g" "$f"; fi
  done
  [ -n "$cache" ] || { rm -f "$profile"; return; }

  host=${cache#http://}
  cat > "$profile" <<EOF
# Montecito download cache (written by montecito-mirrors setup).
export MONTECITO_DOWNLOAD_CACHE='$cache'
export npm_config_registry='$cache/registry.npmjs.org/'
export PIP_INDEX_URL='$cache/pypi.org/simple/' PIP_TRUSTED_HOST='$host'
export UV_DEFAULT_INDEX='$cache/pypi.org/simple/' UV_INSECURE_HOST='$host'
export GOPROXY='$cache/proxy.golang.org' GOSUMDB='sum.golang.org $cache/sum.golang.org'
export RUSTUP_DIST_SERVER='$cache/static.rust-lang.org' RUSTUP_UPDATE_ROOT='$cache/static.rust-lang.org/rustup'
export PUB_HOSTED_URL='$cache/pub.dev' FLUTTER_STORAGE_BASE_URL='$cache/storage.googleapis.com'
EOF
  # npm/pnpm also read the global npmrc in RUN steps that skip the profile.
  install -d /usr/local/etc
  printf 'registry=%s/registry.npmjs.org/\n' "$cache" >> /usr/local/etc/npmrc
  printf '[global]\nindex-url = %s/pypi.org/simple/\ntrusted-host = %s\n' "$cache" "$host" > /etc/pip.conf
  # Cargo reads /.cargo/config.toml for every project below /.
  install -d /.cargo
  printf '[source.crates-io]\nreplace-with = "montecito"\n[source.montecito]\nregistry = "sparse+%s/index.crates.io/"\n' "$cache" > /.cargo/config.toml
  homes .m2 settings.xml "<settings><mirrors><mirror><id>montecito</id><mirrorOf>central</mirrorOf><url>$cache/repo.maven.apache.org/maven2</url><blocked>false</blocked></mirror>
<mirror><id>maven-default-http-blocker</id><mirrorOf>external:dummy:*</mirrorOf><url>http://0.0.0.0/</url></mirror></mirrors></settings>"
  homes .gradle/init.d montecito-mirrors.gradle "def mirrors = [
  'https://repo.maven.apache.org/maven2': '$cache/repo.maven.apache.org/maven2',
  'https://repo1.maven.org/maven2': '$cache/repo1.maven.org/maven2',
  'https://dl.google.com/dl/android/maven2': '$cache/dl.google.com/dl/android/maven2',
  'https://plugins.gradle.org/m2': '$cache/plugins.gradle.org/m2',
]
def redirect = { repositories ->
  repositories.withType(MavenArtifactRepository).configureEach { repository ->
    def target = mirrors[repository.url.toString().replaceAll('/+\$', '')]
    if (target) { repository.url = target; repository.allowInsecureProtocol = true }
  }
}
beforeSettings { settings -> redirect(settings.pluginManagement.repositories); redirect(settings.dependencyResolutionManagement.repositories) }
allprojects { redirect(buildscript.repositories); redirect(repositories) }"
}

case ${1:-} in
  setup) setup ;;
  url) [ $# -eq 2 ] || { echo 'usage: montecito-mirrors url https://...' >&2; exit 2; }; url "$2" ;;
  *) echo 'usage: montecito-mirrors setup | url https://...' >&2; exit 2 ;;
esac
