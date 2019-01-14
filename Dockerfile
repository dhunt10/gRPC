FROM golang:1.11
WORKDIR /go/src/helloworld

COPY ./greeter_server/ ./greeter_server/
COPY ./helloworld/ ./helloworld/
RUN go get ./...

EXPOSE 50051

CMD ["greeter_server"]
