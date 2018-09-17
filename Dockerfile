# First we build Go executable
FROM golang:alpine as builder
RUN apk update && apk add ca-certificates
# Creating non-privileged user to run the container with
RUN adduser -D -g '' appuser
RUN mkdir /build
ADD main.go /build
WORKDIR /build
RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -ldflags '-extldflags "-static"' -o main .

# Now we build a smallest container possible
FROM scratch
# Copy certificates over from build container needed for https
COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
# Copy /etc/passwd over from build container in order to have non-privileged user present
COPY --from=builder /etc/passwd /etc/passwd
WORKDIR /appdir
COPY --from=builder /build/main /appdir/
EXPOSE 8080
USER appuser
ENTRYPOINT ["./main"]