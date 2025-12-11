FROM alpine:latest
RUN apk add --update python3 py3-pip py3-flask
WORKDIR /app
COPY . .
EXPOSE 5000
CMD ["python3", "app.py"]