# Build container
FROM alpine
LABEL maintainer="Coding <code@ongoing.today>"

USER root
WORKDIR /

RUN apk update && \
    apk add --no-cache \
		tshark

CMD ["/bin/sh"]
