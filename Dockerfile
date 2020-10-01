FROM golang AS golangfwk

# Labels
LABEL "GO version"="1.12.4"
LABEL "Alpine version"="3.9"
LABEL "Usage"="Go base for carrefour"
ARG GOOSARG
ARG GOARCHARG
# Secure env vars settings
ENV GOLANG_VERSION 1.12.4
ENV GOPATH /go
WORKDIR /app
ADD helloworld.go .

#ENV PATH $GOPATH/bin:/usr/local/go/bin:$PATH
#RUN mkdir -p "$GOPATH/src" "$GOPATH/bin" "$GOPATH/src/connInARabbitMQ" "/appli" "/appli/conf" && chmod -R 777 "$GOPATH"
#WORKDIR $GOPATH

# Copy source to gopath
#ADD *.go $GOPATH/src/connInARabbitMQ/
#ADD *.json $GOPATH/src/connInARabbitMQ/
#RUN ls -ltr $GOPATH/src/carrefour/fr/

# Update dependency for framework and step
#RUN chmod +x $GOPATH/src/carrefour/fr/dependency.sh
#RUN $GOPATH/src/carrefour/fr/dependency.sh
#
#RUN go get github.com/mileusna/crontab
#RUN go get github.com/michaelklishin/rabbit-hole
#RUN go get github.com/streadway/amqp


RUN timeNow=$(date +"%Y%m%d%H%M%S")
RUN version=1.11

# Build and copy binaire to /appli
#RUN ls -ltr $GOPATH/src
#RUN cd $GOPATH/src/connInARabbitMQ
RUN env GOOS=$GOOSARG GOARCH=$GOARCHARG go build
#RUN go build -ldflags "-X main.vBuildTime=$timeNow -X main.vVersion=$version"
#RUN cp $GOPATH/src/connInARabbitMQ/connInARabbitMQ /appli
#RUN cp $GOPATH/src/connInARabbitMQ/*.json      /appli


# Build image with go exe
FROM alpine:3.9

RUN apk add --no-cache curl

## authority
#RUN apk update && apk add ca-certificates && rm -rf /var/cache/apk/*
#COPY ./chain_bundle.pem /usr/local/share/ca-certificates/chain_bundle.pem
#RUN update-ca-certificates
#
## c'est la zone
#RUN apk add tzdata
#RUN cp /usr/share/zoneinfo/Europe/Paris /etc/localtime
#RUN echo Europe/Paris > /etc/timezone
#
#RUN mkdir -p /appli
COPY --from=golangfwk /app /appli

# Create a group and user
RUN addgroup -g 30100 -S appflow && adduser --uid 30100 -S appflow -G appflow

RUN chown -R appflow:appflow /appli

# user for process
USER appflow

# Start service
#ENTRYPOINT /appli/connInARabbitMQ -p /appli/conf/connInARabbitMQParam.json
