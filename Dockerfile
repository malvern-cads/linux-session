FROM debian:10

# Set the folder to start the container inside
WORKDIR /root/

# Install stuff
RUN apt-get update && apt-get install -y openssh-server openssl lynx nano man

# ======================= SETUP SSH =======================
RUN mkdir /var/run/sshd
# Open port 22 on the container
EXPOSE 22

# ======================= SETUP ROOT USER =======================
# Set password to cads
RUN echo "cads\ncads" | passwd root
# Allow root SSH login
RUN echo "PermitRootLogin yes" >> /etc/ssh/sshd_config

# ======================= CREATE EXTRA USERS =======================
RUN useradd proflewis

# ======================= SETUP LEVELS =======================
# Instructions
COPY ./instructions /root/instructions/
COPY ./instructions /etc/skel/instructions/

# Level 1, 2 and 3
COPY ./level_files/animals /root/animals/

# Level 4
RUN mkdir /home/research
RUN groupadd research
COPY ./level_files/research /home/research
RUN chown -R proflewis:research /home/research

COPY motd.txt /etc/motd

# Run SSH in the foreground
CMD ["/usr/sbin/sshd", "-D"]
