# openwebrxplus-bg
Docker image for [OpenWebRX+](https://github.com/luarvique/openwebrx) customized for use in Bularia.
Added custom bookmarks and map features.
The image is based on [openwebrx-softmbe](https://hub.docker.com/r/slechev/openwebrxplus-softmbe),
hence includes codecserver-softmbe (mbelib), enabling DMR, D-Star, YSF, FreeDV, DRM, NXDN and other Digital modes.

This image has RTL-SDR device and profiles preconfigured. You will have to modify the General Settings in Admin Panel too.

# Running the container
```
# crete volumes
docker volume create owrxp-settings
docker volume create owrxp-etc

# run container in background
docker run -d --name owrxp-bg \
    --device /dev/bus/usb \
    -p 8073:8073 \
    -v owrxp-settings:/var/lib/openwebrx \
    -v owrxp-etc:/etc/openwebrx \
    --restart unless-stopped \
    slechev/openwebrxplus-bg
```
You can use ENV variable to specify the cities from which the repeaters will be extracted and added to the map and bookmarks.

Add ```-e DUMP_REPS="Варна:Каварна:Слънчев Бряг:Провадия"``` to the ```docker run``` command above.

# Admin user
Login with user ```admin``` and password ```admin```. You will be forced to change the password after the first login.


# Blacklisting device drivers on host
You should disable the kernel drivers for RTL, SDRPlay and HackRF devices on the host linux (where docker runs) before running OWRX+ and then reboot.
```
cat > /etc/modprobe.d/owrx-blacklist.conf << _EOF_
blacklist dvb_usb_rtl28xxu
blacklist sdr_msi3101
blacklist msi001
blacklist msi2500
blacklist hackrf
_EOF_
```

# SDRPlay devices
If you have problems with SDRPlay devices when the container is ran for the first time try to restart the container.
For more information see [the official wiki](https://github.com/jketterl/openwebrx/wiki/SDRPlay-device-notes#using-sdrplay-devices-in-docker-containers)
and a possible long-term [solution](https://github.com/pbelskiy/docker-usb-sync)


# More information on the official wiki
* [how to run the container](https://github.com/jketterl/openwebrx/wiki/Getting-Started-using-Docker)
* [adding admin user](https://github.com/jketterl/openwebrx/wiki/User-Management#special-information-for-docker-users)


# Docker Hub
Check the [Docker Hub](https://hub.docker.com/r/slechev/openwebrxplus-bg) page for the image.


# Github
Check the [Source code](https://github.com/0xAF/openwebrxplus-bg) for this image.
