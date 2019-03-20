FROM alpine AS builder

LABEL maintainer="maxime@dreau.fr"

ENV RESTIC_VERSION=0.9.4

RUN wget -O /usr/local/bin/restic.bz2 https://github.com/restic/restic/releases/download/v0.9.4/restic_0.9.4_linux_amd64.bz2 \
 && bunzip2 /usr/local/bin/restic.bz2 \
 && chmod +x /usr/local/bin/restic

ENV RCLONE_VERSION=1.46

RUN wget -O /tmp/rclone.zip https://downloads.rclone.org/v${RCLONE_VERSION}/rclone-v${RCLONE_VERSION}-linux-amd64.zip \
 && unzip -j /tmp/rclone.zip rclone-v${RCLONE_VERSION}-linux-amd64/rclone -d /usr/local/bin

FROM mazzolino/restic:latest

COPY --from=builder /usr/local/bin/* /usr/local/bin/

VOLUME /root/.cache/restic
