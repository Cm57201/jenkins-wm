FROM jenkins/jenkins:lts
USER root
RUN apt-get update
RUN curl -sSL https://get.docker.com/ | sh
RUN git config --global url.”https://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:@github.com/".insteadOf “https://github.com/"
