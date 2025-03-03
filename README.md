# app-webhook-validate-registries


```
openssl genrsa -out webhook-server-key.pem 2048

openssl req -new -key webhook-server-key.pem -out webhook-server.csr -config webhook-server.conf

sudo openssl x509 -req -in webhook-server.csr -CA /etc/kubernetes/pki/ca.crt -CAkey /etc/kubernetes/pki/ca.key -CAcreateserial -out webhook-server-cert.pem -days 365 -extfile webhook-server.conf -extensions v3_req

sudo openssl x509 -in webhook-server-cert.pem -text -noout
cp webhook-server-key.pem tls.key
cp webhook-server-cert.pem tls.crt
```

```
openssl req -new -key webhook-server.key -subj "/CN=system:node:imagepolicywebhook/O=system:nodes" -addext "subjectAltName = DNS:imagepolicywebhook.imagepolicywebhook.svc.cluster.local,DNS:imagepolicywebhook.imagepolicywebhook.svc,DNS:imagepolicywebhook.imagepolicywebhook.pod.cluster.local,IP:$SERVICE_IP" -out webhook-server.csr 
```

```
kubectl create ns imagepolicywebhook
kubectl create secret tls tls-secret -n imagepolicywebhook --cert=tls.crt --key=tls.key
```

```
mkdir -p /etc/kubernetes/webhook
```
```
cat <<EOF >/etc/kubernetes/webhook/admissionConfig.yaml
apiVersion: apiserver.config.k8s.io/v1
kind: AdmissionConfiguration
plugins:
  - name: ImagePolicyWebhook
    configuration:
      imagePolicy:
        kubeConfigFile: /etc/kubernetes/webhook/webhook.yaml
        allowTTL: 50
        denyTTL: 50
        retryBackoff: 500
        defaultAllow: true
EOF
```

```
cat <<EOF >/etc/kubernetes/webhook/webhook.yaml
apiVersion: v1
clusters:
- cluster:
    certificate-authority: /etc/kubernetes/webhook/webhook-server.crt
    server: https://10.106.160.110
  name: webhook
contexts:
- context:
    cluster: webhook
    user: validate-registries.imagepolicywebhook.svc
  name: webhook
current-context: webhook
kind: Config
users:
- name: validate-registries.imagepolicywebhook.svc
  user:
    client-certificate: /etc/kubernetes/pki/apiserver.crt
    client-key: /etc/kubernetes/pki/apiserver.key
EOF
```