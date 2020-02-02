FROM debian:10

# Set the folder to start the container inside
WORKDIR /root/

# Install stuff
RUN apt-get update && apt-get install -y openssh-server openssl lynx nano

# ======================= SETUP SSH =======================
RUN mkdir /var/run/sshd
# Open port 22 on the container
EXPOSE 22

# ======================= SETUP ROOT USER =======================
# Set password to cads
RUN echo "cads\ncads" | passwd root
# Allow root SSH login
RUN echo "PermitRootLogin yes" >> /etc/ssh/sshd_config

# ======================= COPY CHALLENGE FILES =======================
COPY ./home /etc/skel/
COPY ./home /root/

COPY motd.txt /etc/motd

# Run SSH in the foreground
CMD ["/usr/sbin/sshd", "-D"]