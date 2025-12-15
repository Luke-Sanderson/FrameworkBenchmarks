FROM alpine:latest

RUN apk update && apk add stress-ng && rm -rf /var/cache/apk/*

CMD ["stress-ng", "--cpu", "62", "--cpu-method", "matrixprod", "-l", "100", "-t", "0"]

