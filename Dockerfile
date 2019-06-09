FROM ubuntu:18.04
MAINTAINER Brandon Barker <brandon.barker@cornell.edu>
# Derived in part from:
# - Alexej Bondarenko's Dockerfile at:
#   https://raw.githubusercontent.com/ersocon/docker-purescript/master/Dockerfile
# - The Macaulay2 Dockerfile for the InteractiveShell at
#   https://github.com/fhinkel/InteractiveShell/blob/master/docker-m2-container/Dockerfile

ARG PS_VERSION
ARG PS_NATIVE_COMMIT
ENV PURESCRIPT_DOWNLOAD_SHA1 1969df7783f1e95b897f5b36ab1e12ab9cbc9166
ENV PSC_PACKAGE_DOWNLOAD_SHA1 09e033708f412e25ff049e5a9de42438b4696a33
ENV SPAGO_DOWNLOAD_SHA1 310d2e37d459481a133df4c6d719a817f56934d6

#
#   Macaulay2 binary installation
#

# For ssh server and up-to-date ubuntu.
RUN apt update && apt install -yq openssh-server wget gnupg && apt clean

# gfan
RUN apt install -yq gfan libglpk40 && apt clean

# Installing M2
RUN echo "deb http://www.math.uiuc.edu/Macaulay2/Repositories/Ubuntu bionic main" >> /etc/apt/sources.list
RUN wget http://www.math.uiuc.edu/Macaulay2/PublicKeys/Macaulay2-key
RUN apt-key add Macaulay2-key

RUN apt update && apt install -y macaulay2 && apt clean

# RUN apt install -y polymake    ## too long and big
RUN apt install -yq graphviz && apt clean

# M2 userland, part 1.    
RUN useradd -m -d /home/m2user m2user
RUN mkdir /custom
#RUN chown -R m2user:m2user /usr/share/Macaulay2
RUN chown -R m2user:m2user /custom
RUN chmod -R 775 /custom

# Bertini and PHCpack
ENV PHC_VERSION 24
# Temporarily commenting out; may need to install PHCpack from a different source
# RUN (cd /custom; wget http://www.math.uic.edu/~jan/x86_64phcv${PHC_VERSION}p.tar.gz)
# RUN (cd /custom; tar zxf x86_64phcv${PHC_VERSION}p.tar.gz; mv phc /usr/bin; rm x86_64phcv${PHC_VERSION}p.tar.gz)
#
# This is the only way extracting Bertini gives the right permissions.
ENV BERTINI_VERSION 1.5.1
RUN apt install -yq libmpfr6 && apt clean
RUN su m2user -c "/bin/bash;\
   cd /custom;\
   wget https://bertini.nd.edu/BertiniLinux64_v${BERTINI_VERSION}.tar.gz;\ 
   tar xzf BertiniLinux64_v${BERTINI_VERSION}.tar.gz;"
RUN ln -s /custom/BertiniLinux64_v${BERTINI_VERSION}/bin/bertini /usr/bin/
RUN cp -a /custom/BertiniLinux64_v${BERTINI_VERSION}/lib/* /usr/lib/

#
#  PureScript (JavaScript) installation - useful for tests and experimentation
#

RUN apt update -yq \
  && apt install curl gnupg -yq \
  && curl -sL https://deb.nodesource.com/setup_8.x | bash \
  && apt install git nodejs -yq \
  && apt clean

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

RUN mkdir -p /spagoex && cd /spagoex && spago init && spago build && \
  chown -R m2user:m2user /spagoex && \
  chmod -R 775 /spagoex


#
# Now adding PureScript Native and dependencies
#

RUN apt install build-essential libtinfo-dev -yq && apt clean
ENV PATH /root/.local/bin:$PATH
RUN curl -sSL https://get.haskellstack.org/ | sh

RUN chown -R m2user:m2user /opt
RUN chmod -R 775 /opt

USER m2user

# Used for debugging:
#
# RUN cd /opt && git clone https://github.com/andyarvanitis/purescript-native.git && \
#   git checkout ${PS_NATIVE_COMMIT}
# RUN cd /opt/purescript-native && stack build --prefetch --dry-run
# RUN cd /opt/purescript-native && stack build
#
# One-shot, lighter alternative
#
RUN cd /opt && git clone https://github.com/andyarvanitis/purescript-native.git && \
  cd purescript-native && git checkout ${PS_NATIVE_COMMIT} && \
  stack build && stack install pscpp --local-bin-path /opt/bin && \
  stack clean --full

#
# Note that we do not delete the source files as these may be useful for perusal, etc.
#

RUN echo "#!/usr/bin/env bash\n\$@\n" > /opt/entrypoint && \
  chmod a+x /opt/entrypoint

ENTRYPOINT ["/opt/entrypoint"]
