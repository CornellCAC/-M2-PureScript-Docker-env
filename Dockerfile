FROM ubuntu:18.04
MAINTAINER Brandon Barker <brandon.barker@cornell.edu>
# Derived in part from:
# - Alexej Bondarenko's Dockerfile at:
#   https://raw.githubusercontent.com/ersocon/docker-purescript/master/Dockerfile
# - The Macaulay2 Dockerfile for the InteractiveShell at
#   https://github.com/fhinkel/InteractiveShell/blob/master/docker-m2-container/Dockerfile

ARG PS_VERSION
ENV PURESCRIPT_DOWNLOAD_SHA1 1969df7783f1e95b897f5b36ab1e12ab9cbc9166
ENV PSC_PACKAGE_DOWNLOAD_SHA1 09e033708f412e25ff049e5a9de42438b4696a33
ENV SPAGO_DOWNLOAD_SHA1 310d2e37d459481a133df4c6d719a817f56934d6

#
#   Macaulay2 binary installation
#

# For ssh server and up-to-date ubuntu.
RUN apt-get update && apt-get install -yq openssh-server wget gnupg

# gfan
RUN apt-get install -yq gfan libglpk40

# Installing M2
RUN echo "deb http://www.math.uiuc.edu/Macaulay2/Repositories/Ubuntu bionic main" >> /etc/apt/sources.list
RUN wget http://www.math.uiuc.edu/Macaulay2/PublicKeys/Macaulay2-key
RUN apt-key add Macaulay2-key
RUN apt-get update && apt-get install -y macaulay2

# RUN apt-get install -y polymake    ## too long and big
RUN apt-get install -yq graphviz

# M2 userland, part 1.    
RUN useradd -m -d /home/m2user m2user
RUN mkdir /custom
#RUN chown -R m2user:m2user /usr/share/Macaulay2
RUN chown -R m2user:m2user /custom
RUN chmod -R 775 /custom

# Bertini and PHCpack
ENV PHC_VERSION 24
RUN (cd /custom; wget http://www.math.uic.edu/~jan/x86_64phcv${PHC_VERSION}p.tar.gz)
RUN (cd /custom; tar zxf x86_64phcv${PHC_VERSION}p.tar.gz; mv phc /usr/bin; rm x86_64phcv${PHC_VERSION}p.tar.gz)
# This is the only way extracting Bertini gives the right permissions.
ENV BERTINI_VERSION 1.5.1
RUN apt-get install -yq libmpfr6
RUN su m2user -c "/bin/bash;\
   cd /custom;\
   wget https://bertini.nd.edu/BertiniLinux64_v${BERTINI_VERSION}.tar.gz;\ 
   tar xzf BertiniLinux64_v${BERTINI_VERSION}.tar.gz;"
RUN ln -s /custom/BertiniLinux64_v${BERTINI_VERSION}/bin/bertini /usr/bin/
RUN cp -a /custom/BertiniLinux64_v${BERTINI_VERSION}/lib/* /usr/lib/

#
#  PureScript (JavaScript) installation - useful for tests and experimentation
#

RUN apt-get update -yq \
  && apt-get install curl gnupg -yq \
  && curl -sL https://deb.nodesource.com/setup_8.x | bash \
  && apt-get install nodejs -yq

RUN npm install -g bower parcel-bundler pulp@12.4.2 yarn@1.15.2

RUN mkdir -p /opt/bin && cd /opt \
  && wget https://github.com/purescript/purescript/releases/download/v${PS_VERSION}/linux64.tar.gz \
  && echo "$PURESCRIPT_DOWNLOAD_SHA1 linux64.tar.gz" | sha1sum -c - \
  && tar -xvf linux64.tar.gz \
  && rm /opt/linux64.tar.gz \
  && wget https://github.com/purescript/psc-package/releases/download/v0.5.1/linux64.tar.gz \
  && echo "$PSC_PACKAGE_DOWNLOAD_SHA1 linux64.tar.gz" | sha1sum -c - \
  && tar -xvf linux64.tar.gz \
  && rm /opt/linux64.tar.gz \
  && wget https://github.com/spacchetti/spago/releases/download/0.8.0.0/linux.tar.gz \
  && echo "$SPAGO_DOWNLOAD_SHA1 linux.tar.gz" | sha1sum -c - \
  && tar -xvf linux.tar.gz -C bin/ \
  && rm /opt/linux.tar.gz

ENV PATH /opt/bin:/opt/purescript:/opt/psc-package:$PATH

RUN echo "#!/usr/bin/env bash\n\$@\n" > /opt/entrypoint && \
  chmod a+x /opt/entrypoint

ENTRYPOINT ["/opt/entrypoint"]
