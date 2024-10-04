FROM debian:stable-slim

ENV SERVER_NAME="DaGarage Jamulus Server - Private"
ENV TZ=America/New_York

# Update system packages
RUN echo "*** updating system packages ***"; \
    apt-get -qq update

# Install necessary build dependencies
RUN echo "*** prepare build environment ***"; \
    apt-get -y install --no-install-recommends wget devscripts build-essential qtbase5-dev qttools5-dev-tools

WORKDIR /tmp
RUN echo "*** fetch jamulus source ***"; \
    wget https://github.com/jamulussoftware/jamulus/archive/latest.tar.gz; \
    tar xzf latest.tar.gz
    git clone https://github.com/Cimlah/jamulus-setup-scripts.git && \
    cp -a jamulus-setup-scripts/into-usr-local-bin/. /usr/local/bin/
    
WORKDIR /tmp/jamulus-latest
RUN echo "*** compile jamulus ***"; \
    qmake "CONFIG+=nosound headless serveronly" Jamulus.pro; \
    make clean; \
    make; \
    cp Jamulus /usr/local/bin/Jamulus; \
    chmod +x /usr/local/bin/Jamulus

# Clean up the build environment
RUN echo "*** clean up build environment ***"; \
    rm -rf /tmp/*; \
    apt-get --purge -y remove wget devscripts build-essential qtbase5-dev qttools5-dev-tools; \
    apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false

# Prepare the runtime environment
RUN echo "*** prepare run environment ***"; \
    apt-get -y install --no-install-recommends tzdata procps libqt5core5a libqt5network5 libqt5xml5

# Expose the default Jamulus server port
EXPOSE 22125/udp

ENTRYPOINT ["nice", "-n", "-20", "ionice", "-c", "1", "Jamulus"]

CMD ["-d", "-e", "127.0.0.1", "-F", "-n", "-o", "├ DaGarage Online ┤;Asbury Park, NJ;us", "-P", "-R", "/Jamulus/Recordings/Private", "-s", "-T", "-u", "12", "-w", "/Jamulus/Web/motd-jamulus-private.htm", "-Q", "46", "-p", "22125"]
