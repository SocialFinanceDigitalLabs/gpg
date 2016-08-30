FROM alpine

RUN apk add --update --no-cache "gnupg<2" "dialog" "bash" && rm -rf /var/cache/apk/*

COPY run.sh run.sh

RUN chmod +x run.sh

CMD ["/bin/bash", "run.sh"]
