FROM debian:stable
MAINTAINER jano42 "https://github.com/jano42"
LABEL authors=jano42

ENV YADOMS_BUILD_BRANCH develop

RUN apt-get update \
	&& apt-get install -y g++ libbz2-dev python-dev wget build-essential libssl-dev \
	libopencv-gpu-dev autoconf automake libtool curl make g++ unzip \
	libudev-dev libpcre3 libpcre3-dev libpq5 \
	postgresql-server-dev-all git rpm zip

RUN wget https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-3.2.0.1227-linux.zip && unzip sonar-scanner-cli-3.2.0.1227-linux.zip
ENV PATH="$PWD/sonar-scanner-cli-3.2.0.1227-linux/bin:${PATH}"

RUN wget https://sonarcloud.io/static/cpp/build-wrapper-linux-x86.zip && unzip build-wrapper-linux-x86.zip
ENV PATH="$PWD/build-wrapper-linux-x86:${PATH}"

RUN echo "Path is : $PATH"
	
# Yadoms sources
RUN git clone git://github.com/Yadoms/yadoms.git

COPY entrypoint.sh /

#ensure entrypoint is executable (force flags update, because file flags may change if a commit is made under Windows)
RUN chmod +x /entrypoint.sh

CMD /entrypoint.sh

