FROM python:3.11-slim

SHELL ["/bin/bash", "-ec"]

RUN apt update && apt install --no-install-recommends -y \
    bluez \
    build-essential \
    libssl-dev \
    libffi-dev \
    pkg-config \
    python3-dev
RUN python3 -m venv /opt/venv && \
        source /opt/venv/bin/activate && \
        pip install --upgrade pip setuptools==70.0.0 && \
	pip install --upgrade --extra-index-url=https://www.piwheels.org/simple pip TheengsGateway==1.6.0

COPY chroot /
CMD source /opt/venv/bin/activate && exec /opt/venv/start.sh
