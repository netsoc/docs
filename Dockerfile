FROM python:3.8-alpine AS builder

RUN apk --no-cache add build-base git
RUN pip install pipenv

WORKDIR /build
COPY Pipfile Pipfile.lock ./
RUN pipenv install

COPY mkdocs.yml ./
COPY docs/ ./docs/
COPY .git/ ./.git/
RUN pipenv run mkdocs build


FROM nginx:stable-alpine

RUN rm /etc/nginx/conf.d/*
COPY nginx.conf /etc/nginx/conf.d/site.conf

COPY --from=builder /build/site /srv/site
