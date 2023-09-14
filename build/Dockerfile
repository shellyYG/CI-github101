FROM golang:1.20.2-alpine as builder

RUN apk update && apk add --no-cache ca-certificates && update-ca-certificates

# Create bis user
ENV USER=bis
ENV UID=10001

# See https://stackoverflow.com/a/55757473/12429735RUN
RUN adduser \
    # prevents prompt for a password
    --disabled-password \
    # circumvents the prompt for "Full Name" etc. on Debian-based systems
    --gecos "" \
    --home "/nonexistent" \
    --shell "/sbin/nologin" \
    --no-create-home \
    --uid "${UID}" \
    "${USER}"

# Begin final image
FROM alpine:latest

RUN apk add tzdata
RUN echo "Europe/Berlin" >  /etc/timezone

ARG APP

LABEL app=$APP

# Copy our static executable
COPY $APP /usr/local/bin/bis

# Import the user and group files from the builder
COPY --from=builder /etc/passwd /etc/passwd
COPY --from=builder /etc/group /etc/group

# Copy SSL certificates
COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/

# Use an unprivileged user
USER bis:bis

# Expose port 8080, allowed for none root users
# The default Cloud Run port
EXPOSE 8080

ENTRYPOINT ["/usr/local/bin/bis"]

ENV CONFIG=/etc/bis-config
