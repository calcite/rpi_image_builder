FROM arm32v7/debian
WORKDIR /app
RUN apt-get update && apt-get install -y --no-install-recommends ansible udev parted git qemu-utils
CMD ansible-playbook playbook_builder.yaml
