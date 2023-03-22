FROM alpine

ENV PATH="/container/scripts:${PATH}"

RUN apk add --no-cache git py3-pip \
 && pip3 install --upgrade radicale \
 && mkdir /data \
 \
 && adduser -S -D -h /data radicale radicale

EXPOSE 8000

COPY . /container/

HEALTHCHECK CMD ["/container/scripts/docker-healthcheck.sh"]
ENTRYPOINT ["/container/scripts/entrypoint.sh"]

CMD [ "/container/scripts/command.sh" ]
