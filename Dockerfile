FROM --platform=$BUILDPLATFORM golang:alpine3.17

ARG BUILDPLATFORM
ARG TARGETARCH
ARG TARGETOS

ENV GO111MODULE=on
WORKDIR /

# Cache dependencies
COPY go.mod .
COPY go.sum .
RUN go mod download

COPY . ./

RUN CGO_ENABLED=0 GOARCH=${TARGETARCH} GOOS=${TARGETOS} go build -o /unbound-exporter -a -installsuffix cgo .

FROM alpine:3.17.2

COPY --from=0 /unbound-exporter /unbound-exporter
