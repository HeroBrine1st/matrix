FROM python:3.9-slim as builder

COPY pip.conf /etc/pip.conf

RUN pip install --prefix="/install" --no-warn-script-location matrix-synapse[all]==1.48.0

FROM python:3.9-slim

RUN apt-get update && apt-get install -y \
    curl \
    gosu \
    libjpeg62-turbo \
    libpq5 \
    libwebp6 \
    xmlsec1 \
    libjemalloc2 \
    libssl-dev \
    openssl \
    libopenjp2-7 \
    libtiff5 \
    libxcb1 \
    libjemalloc2 \
    && rm -rf /var/lib/apt/lists/*

COPY --from=builder /install /usr/local
COPY start.py /start.py
COPY conf /conf

VOLUME ["/data"]

EXPOSE 8008/tcp 8009/tcp 8448/tcp

ENTRYPOINT ["/start.py"]

HEALTHCHECK --start-period=5s --interval=15s --timeout=5s \
    CMD curl -fSs http://localhost:8008/health || exit 1
