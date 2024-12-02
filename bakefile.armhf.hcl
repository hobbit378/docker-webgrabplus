
variable "BUILD_DATE" {
  default = "${formatdate("DD MMM YYYY hh:mm ZZZ", timestamp())}"
}

variable "BASE_VER" {
  default = "3.20"
}

variable "APP_VER" {
  default = "5.3.0"
}

group "default" {
  targets = ["base","webgrabplus"]
}

target "base" {
  platform = ["linux/arm/v7"]
  contexts = {
    src = "./submodule/base-image/"
  }
  dockerfile = "./submodule/base-image/Dockerfile"
  args = {
    BUILD_DATE = "${BUILD_DATE}"
    VERSION = "${BASE_VER}"
  }
  labels = {
    "org.opencontainer.image.authors" = "MaWe <https://github.com/hobbit378>"
    "org.opencontainer.image.version" = "${BASE_VER}"
    "org.opencontainer.image.created" = "${BUILD_DATE}"
    "org.opencontainer.image.url" = "https://hub.docker.com/r/hobbit00378/baseimage-alpine"
    "org.opencontainer.image.source" = "https://github.com/hobbit378/docker-baseimage-alpine"
  }
  tags = [
            "docker.io/hobbit00378/baseimage-alpine:armhf-${BASE_VER}",
            "docker.io/hobbit00378/baseimage-alpine:armhf-latest",
            "ghcr.io/hobbit378/baseimage-alpine:armhf-${BASE_VER}",
            "ghcr.io/hobbit378/baseimage-alpine:armhf-latest"
          ]
}

target "webgrabplus" {
  platform = ["linux/arm/v7"]
  contexts = {
    base = "target:base"
    src = "./"
  }
  dockerfile = "Dockerfile"
  args = {
    BUILD_DATE = "${BUILD_DATE}"
    BASEIMG="docker.io/hobbit00378/baseimage-alpine:armhf-${BASE_VER}"
    VERSION = "${APP_VER}"
    WEBGRAB_VER = "5.3.0"
  }
  pull = false
  labels = {
    "org.opencontainer.image.authors" = "MaWe <https://github.com/hobbit378>"
    "org.opencontainer.image.version" = "${APP_VER}"
    "org.opencontainer.image.created" = "${BUILD_DATE}"
    "org.opencontainer.image.url" = "https://hub.docker.com/r/hobbit00378/webgrabplus"
    "org.opencontainer.image.source" = "https://github.com/hobbit378/docker-webgrabplus"
  }
  tags = [
            "docker.io/hobbit00378/webgrabplus:armhf-${APP_VER}",
            "docker.io/hobbit00378/webgrabplus:armhf-latest",
            "ghcr.io/hobbit378/webgrabplus:armhf-${APP_VER}",
            "ghcr.io/hobbit378/webgrabplus:armhf-latest"
          ]
}