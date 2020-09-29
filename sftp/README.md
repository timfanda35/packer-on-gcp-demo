# SFTP DEMO

**Be care security.**

This setup turn the sshd config to `PasswordAuthentication yes`.

A better way is that generate the credentials for sftp users instead of password.

```
export GCP_PROJECT_ID=$(gcloud config get-value core/project)
export EXPORTER_PASS='!12AAbbCCdd90'
export VIEWER_PASS='@12AAbbCCdd90'

packer build \
  -var "logexporter_pass=$EXPORTER_PASS" \
  -var "logviewer_pass=$VIEWER_PASS" \
  packer.json
```
