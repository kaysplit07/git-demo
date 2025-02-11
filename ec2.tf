pip install pandas kubernetes cryptography pyopenssl

###################
import json
import base64
import subprocess
import pandas as pd
from kubernetes import client, config
from cryptography import x509
from cryptography.hazmat.backends import default_backend

# Load Kubernetes config
config.load_kube_config()  # Use this if running locally; use config.load_incluster_config() if running inside a cluster

# Define namespace
NAMESPACE = "your-namespace"  # Change to your desired namespace

# Initialize Kubernetes API client
v1 = client.CoreV1Api()

# Get all secrets in the namespace
secrets = v1.list_namespaced_secret(NAMESPACE)

# List to store certificate details
certs_list = []

for secret in secrets.items:
    if secret.type == "kubernetes.io/tls":
        cert_name = secret.metadata.name
        cert_data = secret.data.get("tls.crt")

        if cert_data:
            # Decode base64 certificate
            cert_bytes = base64.b64decode(cert_data)

            try:
                # Load certificate using cryptography library
                cert = x509.load_pem_x509_certificate(cert_bytes, default_backend())

                # Extract certificate details
                cert_info = {
                    "Secret Name": cert_name,
                    "Subject": cert.subject.rfc4514_string(),
                    "Issuer": cert.issuer.rfc4514_string(),
                    "Valid From": cert.not_valid_before.strftime("%Y-%m-%d %H:%M:%S"),
                    "Valid Until": cert.not_valid_after.strftime("%Y-%m-%d %H:%M:%S"),
                    "Serial Number": hex(cert.serial_number),
                    "Signature Algorithm": cert.signature_hash_algorithm.name
                }

                certs_list.append(cert_info)

            except Exception as e:
                print(f"❌ Error processing certificate in secret {cert_name}: {e}")

# Convert to DataFrame
df = pd.DataFrame(certs_list)

# Save to Excel file
output_file = "kubernetes_certificates.xlsx"
df.to_excel(output_file, index=False)

print(f"✅ Certificate details saved to {output_file}")


#############################

python list_k8s_certs.py

#################


