# syntax=docker/dockerfile:1
# Keep this syntax directive! It's used to enable Docker BuildKit

# Builder will install uv to do the installation of requirements
FROM python:3.12 AS builder

# Install uv and requirements (note: requirements.txt should be updated prior to docker build via poetry export)
ENV VIRTUAL_ENV=/venv
ENV UV_INSTALL_DIR=/root/bin
ENV PATH="$UV_INSTALL_DIR:$PATH"
RUN curl -LsSf https://astral.sh/uv/0.5.22/install.sh | sh

# Setup virtual environment
RUN uv venv $VIRTUAL_ENV

# Install dependencies
COPY requirements.txt /requirements.txt
RUN uv pip install --no-cache -r requirements.txt

# Runtime only copies the already installed dependencies (not requiring uv or curl etc.)
FROM python:3.12-slim AS runtime

COPY --from=builder /venv /venv
# Add /venv/bin to the path so that the installed packages are available
ENV PATH="/venv/bin:$PATH" \
    PYTHONUNBUFFERED=1

# Copy app source code into the container
COPY ./backend /app
COPY ./reflex-run.sh /app

# Expose backend port (frontend run by caddy)
EXPOSE 8000

# Allow stopping the container (e.g. with docker-compose down)
STOPSIGNAL SIGKILL

WORKDIR /app

# Run reflex in production mode
# CMD ["reflex", "run", "--env", "prod", "--backend-only"]
# Run the run.sh script instead
CMD ["sh", "reflex-run.sh"]
