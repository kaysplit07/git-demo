✅ Steps to Decode and Store the Certificate Locally
Extract the Base64-encoded certificate (if it's from Kubernetes)
If the certificate is stored in a Kubernetes secret, retrieve it using:

sh
Copy
Edit
kubectl get secret <secret-name> -n <namespace> -o jsonpath="{.data.tls\.crt}" | base64 --decode > certificate.crt
Decode a Manually Provided Base64 Certificate If you already have the Base64-encoded string, decode it using:

sh
Copy
Edit
echo '<BASE64_ENCODED_CERT>' | base64 --decode > decoded_certificate.crt
Replace <BASE64_ENCODED_CERT> with your actual Base64 certificate string.

Verify the Decoded Certificate Check if the file was correctly decoded:

sh
Copy
Edit
openssl x509 -in decoded_certificate.crt -text -noout
If the certificate is valid, you should see the certificate details printed in the terminal.

💡 Fixed Command Based on Your Example
Your original command had a quote (quote>) issue. The correct command to decode your certificate is:

sh
Copy
Edit
echo "oxWXA4ZzdrYnl3ZzZqSEZoTk1aSwpSUFExcnI5..." | base64 --decode > cert_decoded.crt
Then verify:

sh
Copy
Edit
openssl x509 -in cert_decoded.crt -text -noout
🛠 Troubleshooting
If you get "invalid input" errors, ensure the Base64 string has no extra spaces or line breaks.
If the output file is empty, the Base64 string may be corrupted or incorrectly formatted.
If it's a Kubernetes secret, retrieve it using kubectl get secret before decoding.
