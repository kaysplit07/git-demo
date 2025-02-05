kubectl exec -it buyer-cms-content-management-64db69d9f8-hds5v -n family-buyer-cms -- ls -l /path/to/


 Possible locations:

/etc/ssl/certs/
/etc/nginx/ssl/
/etc/pki/tls/certs/
/etc/letsencrypt/live/<domain>/fullchain.pem

kubectl exec -it buyer-cms-content-management-64db69d9f8-hds5v -n family-buyer-cms -- ls -l /etc/ssl/certs/


check the content

kubectl exec -it buyer-cms-content-management-64db69d9f8-hds5v -n family-buyer-cms -- cat /path/to/certificate.crt

decode

kubectl exec -it buyer-cms-content-management-64db69d9f8-hds5v -n family-buyer-cms -- sh -c "cat /path/to/certificate.crt | base64 -d | openssl x509 -noout -text"

