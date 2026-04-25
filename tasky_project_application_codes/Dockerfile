# Building the binary of the App
FROM golang:1.26.1-alpine AS build

WORKDIR /go/src/tasky
COPY . .
RUN go mod tidy
RUN go mod download
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -o /go/src/tasky/tasky


FROM alpine:3.21 AS release

ARG APP_VERSION
LABEL version=$APP_VERSION

RUN apk update && apk upgrade --no-cache

WORKDIR /app
COPY --from=build  /go/src/tasky/tasky .
COPY --from=build  /go/src/tasky/assets ./assets
EXPOSE 8080
ENTRYPOINT ["/app/tasky"]