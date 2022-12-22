FROM cypress/base:18.12.0

USER root

# Install dependencies
RUN apt-get update && \
  apt-get install -y \
  fonts-liberation \
  git \
  libcurl4 \
  libcurl3-gnutls \
  libcurl3-nss \
  xdg-utils \
  wget \
  curl \
  # firefox dependencies
  bzip2 \
  # add codecs needed for video playback in firefox
  # https://github.com/cypress-io/cypress-docker-images/issues/150
  mplayer \
  \
  # clean up
  && rm -rf /var/lib/apt/lists/* \
  && apt-get clean

# Fetch the Node.js 19.x installation script
RUN curl -fsSL https://deb.nodesource.com/setup_19.x | bash 

# Install the latest stable Node.js 19.x release
RUN apt install -y nodejs

# Remove the old Node.js's directory
RUN rm -rf /usr/local/bin/node

# Update it with the new Node.js's directory
RUN cp -r /usr/bin/node /usr/local/bin/node

# Check the current Node.js version (Should be 19.x.x)
RUN node --version

# Install libappindicator3-1 - not included with Debian 11
RUN wget --no-verbose /usr/src/libappindicator3-1_0.4.92-7_amd64.deb "http://ftp.us.debian.org/debian/pool/main/liba/libappindicator/libappindicator3-1_0.4.92-7_amd64.deb" && \
  dpkg -i /usr/src/libappindicator3-1_0.4.92-7_amd64.deb ; \
  apt-get install -f -y && \
  rm -f /usr/src/libappindicator3-1_0.4.92-7_amd64.deb

# Install Chrome browser
RUN node -p "process.arch === 'arm64' ? 'Not downloading Chrome since we are on arm64: https://crbug.com/677140' : process.exit(1)" || \
  (wget --no-verbose -O /usr/src/google-chrome-stable_current_amd64.deb "http://dl.google.com/linux/chrome/deb/pool/main/g/google-chrome-stable/google-chrome-stable_106.0.5249.91-1_amd64.deb" && \
  dpkg -i /usr/src/google-chrome-stable_current_amd64.deb ; \
  apt-get install -f -y && \
  rm -f /usr/src/google-chrome-stable_current_amd64.deb)

# "fake" dbus address to prevent errors
# https://github.com/SeleniumHQ/docker-selenium/issues/87
ENV DBUS_SESSION_BUS_ADDRESS=/dev/null

# Install Firefox browser
RUN node -p "process.arch === 'arm64' ? 'Not downloading Firefox since we are on arm64: https://bugzilla.mozilla.org/show_bug.cgi?id=1678342' : process.exit(1)" || \
  (wget --no-verbose -O /tmp/firefox.tar.bz2 https://download-installer.cdn.mozilla.net/pub/firefox/releases/106.0.2/linux-x86_64/en-US/firefox-106.0.2.tar.bz2 && \
  tar -C /opt -xjf /tmp/firefox.tar.bz2 && \
  rm /tmp/firefox.tar.bz2 && \
  ln -fs /opt/firefox/firefox /usr/bin/firefox)



# Versions of local tools
RUN echo  " node version:    $(node -v) \n" \
  "npm version:     $(npm -v) \n" \
  "yarn version:    $(yarn -v) \n" \
  "debian version:  $(cat /etc/debian_version) \n" \
  "Chrome version:  $(google-chrome --version) \n" \
  "Firefox version: $(firefox --version) \n" \
  "Edge version:    n/a \n" \ 
  "git version:     $(git --version) \n" \
  "whoami:          $(whoami) \n"

# A few environment variables to make NPM installs easier
# Good colors for most applications
ENV TERM=xterm

# avoid million NPM install messages
ENV npm_config_loglevel=warn

# allow installing when the main user is root
ENV npm_config_unsafe_perm=true