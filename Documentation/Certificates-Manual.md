# Generate Certificates Manually

## Using CFSSL:
    - Install CFSSL.
    - Generate certificates:
        ```bash
        cfssl gencert -initca ca-csr.json | cfssljson -bare ca
        ```
        ```bash
        cfssl gencert -ca=ca.pem -ca-key=ca-key.pem -config=ca-config.json \
            -hostname="densify-webhook-server,densify-automation" \
            server-csr.json | cfssljson -bare server
        ```
    - Create a Kubernetes Secret:
        ```bash
        kubectl create secret tls webhook-cert --cert=server.pem --key=server-key.pem \
            -n densify-automation
        ```

## Using OpenSSL:
    - Generate certificates manually:
        ```bash
        openssl req -x509 -newkey rsa:4096 -keyout key.pem -out cert.pem -days 365 -nodes
        ```
    - Create a Kubernetes Secret:
        ```bash
        kubectl create secret tls webhook-cert --cert=cert.pem --key=key.pem \
            -n densify-automation
        ```

