# runs the cron in scripts/crontab as root
FROM nvidia/cuda:8.0-devel

# args/env
ARG appdir=/app
ENV APPDIR=$appdir

# user info
ARG UID
ARG GID
ARG UNAME
ENV UNAME=$UNAME

RUN apt-get update && \
    apt-get -y install python-pip && \
    apt-get -y install sudo && \
    apt-get -y install cron && \
    rm -rf /var/lib/apt/lists/*

RUN addgroup --gid $GID $UNAME && \
    adduser --disabled-password --gid $GID --uid $UID --gecos '' $UNAME && \
    adduser $UNAME sudo

RUN echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

# https://github.com/pypa/pip/issues/5240#issuecomment-383297088
RUN pip install --upgrade pip==9.0.3 && pip install scikit-image numpy

ENTRYPOINT $appdir/darkboard/scripts/crond.sh
