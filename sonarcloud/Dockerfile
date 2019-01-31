FROM yadoms/build_for_ubuntu
MAINTAINER jano42 "https://github.com/jano42"
LABEL authors=jano42


RUN wget https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-3.2.0.1227-linux.zip && unzip sonar-scanner-cli-3.2.0.1227-linux.zip && rm -f sonar-scanner-cli-3.2.0.1227-linux.zip
ENV PATH="$PWD/sonar-scanner-cli-3.2.0.1227-linux/bin:${PATH}"

RUN wget https://sonarcloud.io/static/cpp/build-wrapper-linux-x86.zip && unzip build-wrapper-linux-x86.zip && rm -f build-wrapper-linux-x86.zip
ENV PATH="$PWD/build-wrapper-linux-x86:${PATH}"

	
COPY entrypoint.sh /

#ensure entrypoint is executable (force flags update, because file flags may change if a commit is made under Windows)
RUN chmod +x /entrypoint.sh

CMD /entrypoint.sh

