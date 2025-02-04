FROM rclone/rclone:1.64.2

ARG USER_NAME="m2mbackuptool"
ARG USER_ID="1100"

ENV LOCALTIME_FILE="/tmp/localtime"

COPY scripts/*.sh /app/

RUN chmod +x /app/*.sh \
  && apk add --no-cache 7zip bash s-nail supercronic tzdata wget \
  && ln -sf "${LOCALTIME_FILE}" /etc/localtime \
  && addgroup -g "${USER_ID}" "${USER_NAME}" \
  && adduser -u "${USER_ID}" -Ds /bin/sh -G "${USER_NAME}" "${USER_NAME}"

ENTRYPOINT ["/app/entrypoint.sh"]
