# Start with Ubuntu base image
FROM ubuntu:18.04
MAINTAINER Chris Berthiaume <chrisbee@uw.edu>

# Install Samba
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install --no-install-recommends -y samba && \
    apt-get autoremove && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    service smbd stop

# Copy config files and runner
COPY run.sh smb_share_template.txt /

# Make samba data location
RUN mkdir /data

# Expose Samba ports
EXPOSE 137 138 139 445

# Run Samba in the foreground
CMD /run.sh
