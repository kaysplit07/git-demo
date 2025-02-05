kubectl get secrets --all-namespaces -o json | jq -r '.items[] | select(.type=="kubernetes.io/tls") | .metadata.namespace + "/" + .metadata.name'



#!/bin/bash

# Get all TLS secrets
secrets=$(kubectl get secrets --all-namespaces -o json | jq -r '.items[] | select(.type=="kubernetes.io/tls") | .metadata.namespace + "/" + .metadata.name')

for secret in $secrets; do
    namespace=$(echo $secret | cut -d'/' -f1)
    name=$(echo $secret | cut -d'/' -f2)

    # Extract the certificate
    cert=$(kubectl get secret -n $namespace $name -o jsonpath='{.data.tls\.crt}' | base64 --decode)

    # Get the expiry date
    expiry_date=$(echo "$cert" | openssl x509 -enddate -noout | cut -d'=' -f2)
    expiry_epoch=$(date -d "$expiry_date" +%s)
    current_epoch=$(date +%s)

    # Check if the certificate is expired
    if [ $expiry_epoch -lt $current_epoch ]; then
        echo "Certificate in secret $name in namespace $namespace is EXPIRED. Expiry date: $expiry_date"
    else
        echo "Certificate in secret $name in namespace $namespace is valid. Expiry date: $expiry_date"
    fi
done
