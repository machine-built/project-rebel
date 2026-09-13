# ba0fde3d-bee7-4307-b97b-17d0d20aff50
# Allow build scripts to be referenced without being copied into the final image
FROM scratch AS ctx

COPY files/system /system_files/
COPY --chmod=0755 files/scripts /build_files/
COPY *.pub /keys/

# Base Image
FROM quay.io/almalinuxorg/atomic-desktop-kde:10

ARG IMAGE_NAME
ARG IMAGE_REGISTRY
ARG VARIANT

RUN --mount=type=tmpfs,dst=/opt \
    --mount=type=tmpfs,dst=/tmp \
    --mount=type=bind,from=ctx,source=/,target=/ctx \
    /ctx/build_files/build.sh

ARG BESZEL_HUB_URL
ARG BESZEL_TOKEN
ARG BESZEL_KEY

RUN --mount=type=bind,source=./build_files,target=/tmp/build_files \
    BESZEL_HUB_URL="${BESZEL_HUB_URL}" \
    BESZEL_TOKEN="${BESZEL_TOKEN}" \
    BESZEL_KEY="${BESZEL_KEY}" \
    /tmp/build_files/10-base.sh && \
    BESZEL_HUB_URL="${BESZEL_HUB_URL}" \
    BESZEL_TOKEN="${BESZEL_TOKEN}" \
    BESZEL_KEY="${BESZEL_KEY}" \
    /tmp/build_files/11-beszel-agent.sh

### LINTING
## Verify final image and contents are correct.
RUN bootc container lint
