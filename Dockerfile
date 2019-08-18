FROM ubuntu:18.04

ENV SIAB_USERCSS="Solarized:+/etc/shellinabox/options-enabled/solarized.css,Normal:-/etc/shellinabox/options-enabled/00+Black-on-White.css,Reverse:-/etc/shellinabox/options-enabled/00_White-On-Black.css;Colors:+/etc/shellinabox/options-enabled/01+Color-Terminal.css,Monochrome:-/etc/shellinabox/options-enabled/01_Monochrome.css" \
    SIAB_PORT=4200 \
    SIAB_ADDUSER=true \
    SIAB_USER=guest \
    SIAB_USERID=1000 \
    SIAB_GROUP=guest \
    SIAB_GROUPID=1000 \
    SIAB_PASSWORD=putsafepasswordhere \
    SIAB_SHELL=/bin/bash \
    SIAB_HOME=/home/guest \
    SIAB_SUDO=false \
    SIAB_SSL=true \
    SIAB_SERVICE=/:LOGIN \
    SIAB_PKGS=none \
    SIAB_SCRIPT=none \
    SIAB_CERTS=/var/lib/shellinabox \
    SIAB_CERTS_WAIT=false \
    SIAB_LOCAL=false \
    SIAB_MESSAGES_ORIGIN=none

RUN apt-get update && \
    apt-get install --autoremove -y sudo git libssl-dev libpam0g-dev zlib1g-dev dh-autoreconf && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ARG repouser=shellinabox
ARG reponame=shellinabox
ARG repobranch=master

RUN git clone https://github.com/$repouser/$reponame.git && \
    cd $reponame && git checkout $repobranch && \
    autoreconf -i && ./configure --enable-selfsigned-cert && make && make install

RUN mkdir -p /etc/shellinabox/options-available /etc/shellinabox/options-enabled && \
    cp /$reponame/debian/README.available /etc/shellinabox/options-available/README && \
    cp /$reponame/debian/README.enabled /etc/shellinabox/options-enabled/README && \
    cp /$reponame/shellinabox/black-on-white.css '/etc/shellinabox/options-available/00+Black on White.css' && \
    cp /$reponame/shellinabox/white-on-black.css '/etc/shellinabox/options-available/00_White On Black.css' && \
    cp /$reponame/shellinabox/color.css '/etc/shellinabox/options-available/01+Color Terminal.css' && \
    cp /$reponame/shellinabox/monochrome.css '/etc/shellinabox/options-available/01_Monochrome.css'
COPY solarized.css /etc/shellinabox/options-available/
RUN cd /etc/shellinabox/options-enabled; ln -s ../options-available/*.css . && \
    ln -sf '/etc/shellinabox/options-enabled/00+Black on White.css' /etc/shellinabox/options-enabled/00+Black-on-White.css && \
    ln -sf '/etc/shellinabox/options-enabled/00_White On Black.css' /etc/shellinabox/options-enabled/00_White-On-Black.css && \
    ln -sf '/etc/shellinabox/options-enabled/01+Color Terminal.css' /etc/shellinabox/options-enabled/01+Color-Terminal.css && \
    adduser --disabled-password  --quiet --system -home /var/lib/shellinabox --gecos "Shell In A Box" --group shellinabox && \
    chown shellinabox:shellinabox /var/lib/shellinabox

EXPOSE 4200

COPY assets/entrypoint.sh /usr/local/sbin/

VOLUME /etc/shellinabox /var/log/supervisor /home

ENTRYPOINT ["entrypoint.sh"]
CMD ["shellinabox"]
