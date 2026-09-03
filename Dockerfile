# ba0fde3d-bee7-4307-b97b-17d0d20aff50
# Allow build scripts to be referenced without being copied into the final image
# Build context — never becomes a layer in the final image
FROM scratch AS ctx
COPY files/system /system_files/
COPY --chmod=0755 files/scripts /build_files/
COPY files/branding /branding/
COPY *.pub /keys/

# Base Image
FROM quay.io/almalinuxorg/atomic-desktop-kde:10@sha256:b327d8443a2b27857a66549d0df30b61938653ab2b7f0892ee030eb863604911
ARG NAME=schloss
ARG IMAGE_REGISTRY=PROJECT-REBEL
ARG VARIANT=ALPHA
ARG NAME_CAP=Schloss

RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=tmpfs,dst=/tmp \
    bash /ctx/scripts/branding.sh

RUN bootc container lint
RUN --mount=type=tmpfs,dst=/opt \
    --mount=type=tmpfs,dst=/tmp \
    --mount=type=bind,from=ctx,source=/,target=/ctx \
    /ctx/build_files/build.sh

### LINTING
## Verify final image and contents are correct.
RUN bootc container lint
