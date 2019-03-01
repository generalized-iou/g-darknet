# runs rails and angular

# ruby 2.5 alpine base
FROM ruby:2.5-alpine

# args/env
ARG appdir=/app
ENV APPDIR=$appdir

# user info
ARG UID
ARG GID
ARG UNAME
ENV UNAME=$UNAME

# rails deps
RUN gem install bundler

# apk deps (for angular and nokogiri)
RUN apk upgrade --update \
    && apk add libatomic readline readline-dev \
      libxml2 libxml2-dev libxml2-utils \
      libgcrypt-dev \
      ncurses-terminfo-base ncurses-terminfo \
      libxslt libxslt-dev zlib-dev zlib ruby yaml \
      yaml-dev libffi-dev build-base git nodejs \
      ruby-io-console ruby-irb ruby-json ruby-rake \
      imagemagick imagemagick-dev make \
      gcc g++ libffi-dev ruby-dev \
      sqlite-dev tzdata \
      sudo busybox \
    && apk add --no-cache python py-pygments \
    && python -m ensurepip \
    && rm -r /usr/lib/python*/ensurepip \
    && pip install --upgrade pip setuptools \
    && apk add py-pygments bash nodejs yarn

RUN addgroup -g $GID $UNAME && \
    adduser -D -u $UID -G wheel $UNAME

RUN sed -e 's/# %wheel ALL=(ALL) NOPASSWD: ALL/%wheel ALL=(ALL) NOPASSWD: ALL/g' \
      -i /etc/sudoers

# install a cron to keep
RUN echo "*/1 * * * * cd \"${APPDIR}/darkboard\" && flock -n /tmp/update_charts.lockfile bundle exec rake charts:update > \"${APPDIR}/batch/out/update_charts.out\"" > /etc/crontabs/$UNAME

EXPOSE 4200:4200

ENTRYPOINT $appdir/darkboard/scripts/web.sh
