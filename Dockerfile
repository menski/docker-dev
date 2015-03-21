FROM ubuntu:utopic

# set version
ENV JDK_VERSION=8 \
    MAVEN_VERSION=3.3.1 \
    GRADLE_VERSION=2.3 \
    NVM_VERSION=0.24.0 \
    NODE_VERSION=0.10

# set timezone
RUN ln -sf /usr/share/zoneinfo/Europe/Berlin /etc/localtime && \
    echo "Europe/Berlin" > /etc/timezone

# add oracle jdk ppa
RUN echo "deb  http://ppa.launchpad.net/webupd8team/java/ubuntu utopic main" > /etc/apt/sources.list.d/jdk.list && \
    apt-key adv --recv-keys --keyserver keyserver.ubuntu.com EEA14886 && \
    echo oracle-java7-installer shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections

# add git ppa
RUN echo "deb http://ppa.launchpad.net/git-core/ppa/ubuntu utopic main" > /etc/apt/sources.list.d/git.list && \
    apt-key adv --recv-keys --keyserver keyserver.ubuntu.com E1DF1F24

# install packages
RUN apt-get update && \
    apt-get -y install --no-install-recommends git vim tree silversearcher-ag curl wget ca-certificates unzip \
       openssh-client bash-completion libfreetype6 libfontconfig \
       oracle-java${JDK_VERSION}-installer && \
    apt-get clean && \
    rm -rf /var/cache/* /var/lib/apt/lists/* /var/tmp/*

# install maven
RUN mkdir -p /opt/maven && \
    curl -L http://ftp.halifax.rwth-aachen.de/apache/maven/maven-3/${MAVEN_VERSION}/binaries/apache-maven-${MAVEN_VERSION}-bin.tar.gz | tar xzf - -C /opt/maven --strip 1 && \
    echo 'export PATH=/opt/maven/bin:$PATH' >> /etc/profile.d/maven.sh

# install gradle
RUN curl -L https://services.gradle.org/distributions/gradle-${GRADLE_VERSION}-bin.zip > /tmp/gradle.zip && \
    unzip /tmp/gradle.zip -d /opt/gradle && \
    echo 'export PATH=/opt/gradle/gradle-${GRADLE_VERSION}/bin:$PATH' >> /etc/profile.d/gradle.sh && \
    rm /tmp/gradle.zip

# create user
RUN useradd -m -u 1000 -U dev && \
    echo "dev ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/dev

USER dev
WORKDIR /home/dev

# install nvm and grunt
RUN curl https://raw.githubusercontent.com/creationix/nvm/v${NVM_VERSION}/install.sh | bash && \
    bash -c "source ~/.nvm/nvm.sh && nvm install ${NODE_VERSION} && nvm alias default ${NODE_VERSION} && npm install -g grunt-cli"

CMD ["/bin/bash", "-l"]
