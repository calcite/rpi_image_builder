# RPi SD image builder
This tool able to customize any RPi image (ARM arch) by ansible playbooks on (x86_64 host).

### Requirements:
- Linux host system
- Docker with enabling of [multiarch containers](https://github.com/multiarch/qemu-user-static)

### Setup docker
- The older docker versions require to enable "experimental" mode. 
  ```shell
  $ cat /etc/docker/daemon.json
  {
      "experimental": true
  }   
  systemctl restart docker.service
  ```
- Run multiarch setup 
  ```shell
    $ sudo docker run --rm --privileged multiarch/qemu-user-static --reset -p yes
  ```
- Test configuration
  ```shell
    $ docker run --rm -t arm32v7/alpine uname -m
    ...
    armv7l
  ```

### Prepare source image
Download RPi image and unpack it.
```shell
$ mkdir -p output && cd output 
$ wget https://downloads.raspberrypi.org/raspios_lite_armhf/images/raspios_lite_armhf-2021-05-28/2021-05-07-raspios-buster-armhf-lite.zip
$ unzip 2021-05-07-raspios-buster-armhf-lite.zip
$ cd ..
```

### Customize SD image
This demo profile `kiosk` creates SD image for kiosk box.

```shell
$ sudo docker build -t sd_builder:local .
$ sudo docker run -it --rm --privileged \
   -e "IMAGE=2021-05-07-raspios-buster-armhf-lite.img" \
   -e "PROFILE=kiosk" \
   -e "IMAGE_RESIZE=7G" \
   -v $(pwd):/app -v /dev:/dev sd_builder:local
```

#### Options:
The options are setup by docker environment variables.
- `IMAGE` - filename of SD image (required)
- `PROFILE` - profile name (required)
- `IMAGE_RESIZE` - resize SD image (optional)
- `NO_BOOT_PARTITION` - No. boot partition (optional, default 1)
- `NO_ROOT_PARTITION` - No. root partition (optional, default 2)

Unfortunately, the progress of customizing is not shown in the main console. We can check the output by
```shell
$ tail -f ansible-log.txt 
```
Sometimes, the script can not unmount all folders, this error can be ignored. But we can clean up this manually by
```shell
$ sudo losetup -D  
```


## structure of the profile
The profiles are stored in `profiles` folder.
Important files:
- `profiles/myprofile/playbook.yml` - The main ansible playbook (required). This playbook is run inside SD image. In this file, we should install packages and setup configuration.
- `profiles/myprofile/pre_tasks.yml` - The file with ansible tasks (optional). Here we can manipulate with partitions or prepare external resources.
- `profiles/myprofile/post_tasks.yml` - The file with ansible tasks (optional). Here we can cleanup or get data from prepared SD image (package list, ...)
- `profiles/myprofile/requirements.yml` - The list for [ansible roles](https://docs.ansible.com/ansible/latest/galaxy/user_guide.html#installing-multiple-roles-from-a-file) (optional). They will be automatically installed. 
