# Dockerfile
FROM python:2.7.17-alpine

# Minimal runtime
RUN apk add --no-cache bash ca-certificates libpcap

# Build + install, then clean
RUN apk add --no-cache --virtual .build-deps \
      build-base python2-dev libffi-dev openssl-dev libpcap-dev git \
  && (python -m ensurepip || true) \
  && pip install --no-cache-dir --upgrade pip setuptools wheel \
  && { \
       echo 'pyip==0.7'; \
       echo 'scapy==2.4.5'; \
       echo 'pycrypto==2.6.1'; \
       echo 'cryptography==2.9.2'; \
       echo 'pyOpenSSL==16.2.0'; \
       echo 'pexpect==4.8.0'; \
     } > /tmp/requirements.txt \
  && pip install --no-cache-dir -r /tmp/requirements.txt \
  && git clone --depth 1 https://github.com/SpiderLabs/ikeforce.git /opt/ikeforce \
  && chmod +x /opt/ikeforce/ikeforce.py \
  && ln -s /opt/ikeforce/ikeforce.py /usr/local/bin/ikeforce \
  && apk del .build-deps \
  && rm -rf /var/cache/apk/* /root/.cache/pip /tmp/requirements.txt

WORKDIR /opt/ikeforce

ENTRYPOINT ["python", "/opt/ikeforce/ikeforce.py"]
CMD ["-h"]
