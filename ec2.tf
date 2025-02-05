kubectl exec -it <pod-name> -n <namespace> -- cat /path/to/certificate.crt | openssl x509 -noout -text



kubectl exec -it <pod-name> -n <namespace> -- cat /path/to/certificate.crt | openssl x509 -noout -enddate




