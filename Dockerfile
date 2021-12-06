ARG SOURCE_IMAGE=arm32v7/debian
ARG PACKAGES=''
FROM $SOURCE_IMAGE
WORKDIR /app
RUN mkdir -p /app/profiles /app/output
ADD playbook_builder.yaml /app/playbook_builder.yaml
RUN apt-get update && apt-get install -y --no-install-recommends ansible udev parted git qemu-utils $PACKAGES
CMD ansible-playbook playbook_builder.yaml
