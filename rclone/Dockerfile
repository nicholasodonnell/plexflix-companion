# base image
FROM tynor88/rclone-mount:dev

# copy files into image
COPY root/ /

RUN chmod 777 -R /etc/cont-finish.d && \
  chmod 777 -R /etc/cont-init.d && \
  chmod 777 -R /etc/services.d

# declare volume
VOLUME /config

# declare volume
VOLUME /data
