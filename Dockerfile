FROM debian:buster
LABEL maintainer "notogawa <n.ohkawa@idein.jp>"

ARG RESOLVER

ENV DEBIAN_FRONTEND noninteractive

# install
RUN apt-get update \
 && apt-get upgrade -y \
 && apt-get install -y sudo wget locales \
 && wget -qO- https://get.haskellstack.org/ | sh \
 && apt-get autoclean \
 && apt-get autoremove -y \
 && rm -rf /var/cache/apt/archives/* /var/lib/apt/lists/*

# gen locale
RUN sed -i 's/^# en_US.UTF-8 UTF-8$/en_US.UTF-8 UTF-8/' /etc/locale.gen \
 && locale-gen en_US.UTF-8 \
 && update-locale LANG=en_US.UTF-8

# add idein user
RUN useradd -m idein \
 && echo idein:idein | chpasswd \
 && adduser idein sudo \
 && echo 'idein ALL=NOPASSWD: ALL' >> /etc/sudoers.d/idein

USER idein
WORKDIR /home/idein
ENV HOME /home/idein
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8
ENV PATH /home/idein/.local/bin:$PATH
CMD ["/bin/bash"]

# setup stack
RUN mkdir -p /home/idein/.stack/global-project/
ADD stack.yaml /home/idein/.stack/global-project/stack.yaml
RUN sudo chown idein:idein /home/idein/.stack/global-project/stack.yaml
RUN sudo chmod 644 /home/idein/.stack/global-project/stack.yaml
RUN stack config set resolver ${RESOLVER}
RUN stack setup
RUN stack install \
      singletons vector data-default constraints cereal bytestring attoparsec \
      hspec QuickCheck \
      messagepack containers text \
      optparse-applicative unordered-containers mtl hashable \
      haiji half
