FROM python:3.11-slim

# Backwards compatible defaults
ENV USER=root
ENV GROUPNAME=root
ENV UID=0
ENV GID=0

SHELL ["/bin/bash", "-ec"]

RUN apt update && apt install --no-install-recommends -y \
    bluez \
    build-essential \
    libssl-dev \
    libffi-dev \
    python3-dev \
    cmake

RUN python3 -m venv /opt/venv && \
    source /opt/venv/bin/activate && \
    pip install --upgrade pip setuptools==70.0.0 && \
    pip install --prefer-binary --extra-index-url=https://www.piwheels.org/simple TheengsGateway==1.7.5

COPY chroot /
CMD (getent group "${GROUPNAME}" || groupadd -g "${GID}" "${GROUPNAME}") && \
    (getent passwd "${USER}" || useradd -u "${UID}" -g "${GID}" -m "${USER}") && \
    su -l -s "/bin/bash" -c "source /opt/venv/bin/activate && exec /opt/venv/start.sh" "${USER}"
