FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Set container hostname
ENV HOSTNAME=testnode
RUN echo "$HOSTNAME" > /etc/hostname

# Install dependencies
RUN apt-get update && apt-get install -y \
    software-properties-common \
    git \
    curl \
    python3 \
    python3-pip \
    ssh \
    sudo

# Install Ansible via pip
RUN pip3 install ansible

# Create a non-root user for testing (optional but good practice)
RUN useradd -m tester && echo "tester ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
USER tester
WORKDIR /home/tester

# Run ansible-pull by default (can be overridden in docker run)
CMD ["/bin/bash"]
