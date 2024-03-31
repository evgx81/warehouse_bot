FROM python:3.12-slim

ARG BOT_TOKEN \
  # Needed for fixing permissions of files created by Docker:
  UID=1002 \
  GID=1003

ENV BOT_TOKEN=${BOT_TOKEN} \
  # python:
  PYTHONFAULTHANDLER=1 \
  PYTHONUNBUFFERED=1 \
  PYTHONHASHSEED=random \
  PYTHONDONTWRITEBYTECODE=1 \
  # pip:
  PIP_NO_CACHE_DIR=1 \
  PIP_DISABLE_PIP_VERSION_CHECK=1 \
  PIP_DEFAULT_TIMEOUT=100 \
  PIP_ROOT_USER_ACTION=ignore \
  # poetry:
  POETRY_VERSION=1.8.2 \
  POETRY_NO_INTERACTION=1 \
  POETRY_VIRTUALENVS_CREATE=false \
  POETRY_CACHE_DIR='/var/cache/pypoetry' \
  POETRY_HOME='/usr/local'

# System deps:
RUN apt-get update && apt-get upgrade -y \
  && apt-get install --no-install-recommends -y \
    bash \
    curl \
  && curl -sSL https://install.python-poetry.org | python3 - \
  && poetry --version \
  # Cleaning cache:
  && apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false \
  && apt-get clean -y && rm -rf /var/lib/apt/lists/*

# Copy only requirements to cache them in docker layer
WORKDIR /code

# For static data
RUN groupadd -g "${GID}" -r www \
  && useradd -d '/code' -g www -l -r -u "${UID}" www \
  && chown www:www -R '/code' \
  # Static and media files:
  && mkdir -p '/var/www/bot/logs' \
  && chown www:www '/var/www/bot/logs'

# Copy only requirements, to cache them in docker layer
COPY --chown=web:web ./poetry.lock ./pyproject.toml /code/


# Project initialization:
RUN --mount=type=cache,target="$POETRY_CACHE_DIR" \
  echo poetry version \
  # Install deps:
  && poetry run pip install -U pip \
  && poetry install --no-interaction --no-ansi --sync

# Running as non-root user:
USER www

# Creating folders, and files for a project:
COPY --chown=www:www . /code
