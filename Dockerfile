FROM golang:1.8-alpine AS BUILDER
RUN apk add -U --no-cache git
WORKDIR /go/src/
COPY vendor .
WORKDIR /go/src/filehost
COPY . .
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -ldflags="-w -s" -o main

FROM alpine:latest AS ALPINE
RUN apk add -U --no-cache ca-certificates

FROM scratch
WORKDIR /etc/ssl/certs
COPY --from=ALPINE /etc/ssl/certs/ca-certificates.crt .
WORKDIR /
COPY upload.html .
COPY --from=BUILDER /go/src/filehost/main .
CMD ["./main"]