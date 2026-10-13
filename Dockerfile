FROM python:3.11-slim

SHELL ["/bin/bash", "-ec"]

RUN apt update && apt install --no-install-recommends -y \
    bluez \
    build-essential \
    libssl-dev \
    libffi-dev \
    python3-dev \
    cmake

# TheengsDecoder is built without build isolation so it uses the system cmake:
# the pip cmake/ninja wheels from piwheels are armhf and cannot run on arm/v6 (armel).
# No --prefer-binary here, so pip takes the latest decoder rather than an older piwheels wheel.
RUN python3 -m venv /opt/venv && \
    source /opt/venv/bin/activate && \
    pip install --upgrade pip setuptools==70.0.0 wheel scikit-build setuptools_scm && \
    pip install --no-build-isolation --extra-index-url=https://www.piwheels.org/simple theengsdecoder && \
    pip install --prefer-binary --extra-index-url=https://www.piwheels.org/simple TheengsGateway==1.8.0

COPY chroot /
CMD source /opt/venv/bin/activate && exec /opt/venv/start.sh
