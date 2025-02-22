## https://github.com/astral-sh/uv-docker-example/blob/main/standalone.Dockerfile

# Using uv image with explicitly managed python
FROM ghcr.io/astral-sh/uv:bookworm-slim AS builder
ENV UV_COMPILE_BYTECODE=1 UV_LINK_MODE=copy

# Configure the Python directory so it is consistent
ENV UV_PYTHON_INSTALL_DIR /python

# Only use the managed Python version
ENV UV_PYTHON_PREFERENCE=only-managed

# Install Python before the project for caching
RUN uv python install 3.13

WORKDIR /app
RUN --mount=type=cache,target=/root/.cache/uv \
    --mount=type=bind,source=uv.lock,target=uv.lock \
    --mount=type=bind,source=pyproject.toml,target=pyproject.toml \
    uv sync --frozen --no-install-project --no-dev

COPY example_reflex/ example_reflex/
COPY pyproject.toml .
COPY uv.lock .
COPY rxconfig.py .

RUN --mount=type=cache,target=/root/.cache/uv \
    uv sync --frozen --no-dev

# Then, use a final image without uv (note this also doesn't include python)
FROM debian:bookworm-slim

# Copy the Python installed in the builder
COPY --from=builder --chown=python:python /python /python

# Copy the application from the builder
COPY --from=builder --chown=app:app /app /app

# Place executables in the environment at the front of the path
ENV PATH="/app/.venv/bin:$PATH"

##########
WORKDIR /app
COPY alembic /app/alembic
COPY alembic.ini /app/alembic.ini
COPY scripts/entrypoint.sh /app/entrypoint.sh
CMD ["/app/entrypoint.sh"]
