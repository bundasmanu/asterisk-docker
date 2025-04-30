FROM debian:latest

ARG ASTERISK_BRANCH
ARG ASTERISK_MODULES_ENABLE
ARG ASTERISK_MODULES_DISABLE
ARG ASTERISK_CATEGORY_DISABLE
ARG ASTERISK_USER
ARG ASTERISK_GROUP

WORKDIR /root

RUN apt-get update && apt-get install -y \
    git \
    wget \
    gzip

RUN set -eux; \
    if ! getent group "$ASTERISK_GROUP" > /dev/null; then \
        groupadd --system "$ASTERISK_GROUP"; \
    fi; \
    if ! id "$ASTERISK_USER" > /dev/null 2>&1; then \
        useradd --system --gid "$ASTERISK_GROUP" "$ASTERISK_USER"; \
    fi

##RUN git clone https://github.com/asterisk/asterisk.git --branch ${ASTERISK_BRANCH}

RUN wget https://github.com/asterisk/asterisk/releases/download/22.3.0/asterisk-22.3.0.tar.gz && \
    tar -xzf asterisk-22.3.0.tar.gz

## install pre-reqs
RUN cd asterisk-22.3.0 && \
    contrib/scripts/install_prereq install

## RUN configure
RUN cd asterisk-22.3.0 && \
    ./configure --enable-libsamplerate

RUN cd asterisk-22.3.0 && \
    make menuselect && \
    menuselect/menuselect --category-list && \
    menuselect/menuselect --list-category MENUSELECT_ADDONS && \
    menuselect/menuselect --list-category MENUSELECT_APPS && \
    menuselect/menuselect --list-category MENUSELECT_BRIDGES && \
    menuselect/menuselect --list-category MENUSELECT_CDR && \
    menuselect/menuselect --list-category MENUSELECT_CEL && \
    menuselect/menuselect --list-category MENUSELECT_CHANNELS && \
    menuselect/menuselect --list-category MENUSELECT_CODECS && \
    menuselect/menuselect --list-category MENUSELECT_FORMATS && \
    menuselect/menuselect --list-category MENUSELECT_FUNCS && \
    menuselect/menuselect --list-category MENUSELECT_RES && \
    menuselect/menuselect --list-category MENUSELECT_CFLAGS && \
    menuselect/menuselect --list-category MENUSELECT_UTILS && \
    menuselect/menuselect --list-category MENUSELECT_AGIS && \
    menuselect/menuselect --list-category MENUSELECT_CORE_SOUNDS && \
    menuselect/menuselect --list-category MENUSELECT_MOH && \
    menuselect/menuselect --list-category MENUSELECT_EXTRA_SOUNDS

RUN cd asterisk-22.3.0 && \
    menuselect/menuselect \
    $(for MODULE in $(echo "$ASTERISK_MODULES_ENABLE" | tr ',' ' '); do echo --enable $MODULE; done;) \
    $(for MODULE in $(echo "$ASTERISK_MODULES_DISABLE" | tr ',' ' '); do echo --disable $MODULE; done;) \
    $(for CATEGORY in $(echo "$ASTERISK_CATEGORY_DISABLE" | tr ',' ' '); do echo --disable-category $CATEGORY; done;) \
    menuselect.makeopts

RUN cd asterisk-22.3.0 && \
    make -j "$(nproc)" && \
    make install && \
    make basic-pbx && \
    make samples && \
    make config

COPY entrypoint.sh ./

ENTRYPOINT [ "./entrypoint.sh" ]
CMD ["run"]
