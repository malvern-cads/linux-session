FROM debian:10

# Set the folder where future commands are run from
WORKDIR /root/

# Install required software using apt-get (Debian's package manager)
RUN apt-get update && apt-get install -y openssh-server openssl lynx nano man zip unzip sudo

# ======================= SETUP SSH =======================
# Create the SSH folder
RUN mkdir /var/run/sshd
# Open port 22 on the container
EXPOSE 22

# ======================= SETUP ROOT USER =======================
# Set root user password to cads
RUN echo "cads\ncads" | passwd root
# Allow root SSH login
RUN echo "PermitRootLogin yes" >> /etc/ssh/sshd_config

# ======================= CREATE EXTRA USERS =======================
# Create a user for proflewis (level 5)
RUN useradd proflewis

# ======================= SETUP LEVELS =======================
# Copy the MOTD message that is shown when you begin an SSH session
COPY motd.txt /etc/motd

# Copy instructions into the container
COPY ./instructions /root/instructions/
COPY ./instructions /etc/skel/instructions/

# Setup level 1, 2 and 3
# Copy level files to the relevent place
COPY ./level_files/animals /root/animals/

# Setup level 4, 5 and 6
# Create a new folder for the research
RUN mkdir /root/research
# Create a new user group called research
RUN groupadd research
# Copy the research files into the container
COPY ./level_files/research /root/research
# Set the permissions on the research files so that they are owned by proflewis (not root)
RUN chown -R proflewis:research /root/research

# Setup level 7
# Create a new folder for the research backup
RUN mkdir -p /var/backups/research
# Copy the alkenes.txt file into the research backup folder
COPY ./level_files/alkenes.txt /var/backups/research/alkenes.txt

# Set a coloured prompt
RUN echo 'PS1="\e[0;31m[\u@\h \W]\$ \e[m "' > /etc/profile

# Run SSH in the foreground
CMD ["/usr/sbin/sshd", "-D"]
