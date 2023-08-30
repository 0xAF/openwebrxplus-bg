ARG ARCH
FROM slechev/openwebrxplus-softmbe
LABEL OpenWebRX+ customized with bookmarks and map features for Bulgarian use.

COPY ./scripts /scripts/
COPY ./files /scripts/files/

ENV DUMP_REPS="Варна:Каварна:Слънчев Бряг:Провадия:Шумен:Царево:Ботев:Бузлуджа"
ENV S6_CMD_ARG0="/scripts/run.sh"

RUN set -x && \
  apt-get update && \
  apt-get install -y --no-install-recommends \
    curl \
    libjson-perl \
    # libdata-printer-perl \
  && \
  # Clean up
  # apt-get remove -y ${TEMP_PACKAGES[@]} && \
  apt-get autoremove -y && \
  apt-get clean && \
  rm -rf /src/* /tmp/* /var/lib/apt/lists/* && \
  true

WORKDIR /opt/openwebrx

VOLUME /etc/openwebrx
VOLUME /var/lib/openwebrx

EXPOSE 8073
