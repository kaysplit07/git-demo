import re

def extract_certificates(cert_file):
    """Extract individual certificates from a file."""
    with open(cert_file, "r") as file:
        content = file.read()

    # Find all certificate blocks using regex
    cert_pattern = re.findall(r"(-----BEGIN CERTIFICATE-----[\s\S]+?-----END CERTIFICATE-----)", content)

    return cert_pattern

def remove_duplicates(certificates):
    """Remove duplicate certificates based on content."""
    unique_certs = list(set(certificates))  # Convert list to a set to remove duplicates
    return unique_certs

def save_certificates(certificates, output_file):
    """Save unique certificates back to a file."""
    with open(output_file, "w") as file:
        file.write("\n\n".join(certificates))  # Separate certificates by new lines

    print(f"✅ Successfully saved unique certificates to {output_file}")

# Input and output file names
input_cert_file = "certificate.pem"  # Replace with your actual certificate file
output_cert_file = "unique_certificate.pem"

# Extract, deduplicate, and save
certs = extract_certificates(input_cert_file)
unique_certs = remove_duplicates(certs)
save_certificates(unique_certs, output_cert_file)


######
python remove_duplicate_pem.py


python3 remove_duplicate_pem.py
/Library/Developer/CommandLineTools/usr/bin/python3: can't open file '/Users/C5392450/remove_duplicate_pem.py': [Errno 2] No such file or directory


echo "BASE64_ENCODED_CERT" | base64 --decode > certificate.pem


