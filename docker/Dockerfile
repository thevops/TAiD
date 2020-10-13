FROM debian:10

ENV LC_ALL C
ENV DEBIAN_FRONTEND noninteractive

# install systemd, SSH and python3 (for ansible)
RUN apt-get update \
    && apt-get install -y \
        systemd systemd-sysv \
        net-tools \
        openssh-server \
        python3 \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
    && rm -f /lib/systemd/system/multi-user.target.wants/* \
             /etc/systemd/system/*.wants/* \
             /lib/systemd/system/local-fs.target.wants/* \
             /lib/systemd/system/sockets.target.wants/*udev* \
             /lib/systemd/system/sockets.target.wants/*initctl* \
             /lib/systemd/system/sysinit.target.wants/systemd-tmpfiles-setup* \
             /lib/systemd/system/systemd-update-utmp*


COPY docker/files/key.pub /root/.ssh/authorized_keys

EXPOSE 22

VOLUME [ "/sys/fs/cgroup" ]

CMD ["/lib/systemd/systemd"]
