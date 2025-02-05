kubectl get secrets --all-namespaces -o json | jq -r '
.items[] |
select(.type=="kubernetes.io/tls") |
[.metadata.namespace, .metadata.name, .data["tls.crt"]]
' | while read -r namespace name cert; do
    if [ -n "$cert" ]; then
        echo "🔍 Checking certificate in $namespace/$name..."
        echo "$cert" | base64 --decode | openssl x509 -noout -dates
    fi
done



#################

kubectl get secrets --all-namespaces -o json | jq -r '
.items[] |
select(.type=="kubernetes.io/tls") |
[.metadata.namespace, .metadata.name, .data["tls.crt"]]
' | while read -r namespace name cert; do
    if [ -n "$cert" ]; then
        expiry_date=$(echo "$cert" | base64 --decode | openssl x509 -noout -enddate | cut -d= -f2)
        expiry_timestamp=$(date -d "$expiry_date" +%s)
        current_timestamp=$(date +%s)
        days_remaining=$(( (expiry_timestamp - current_timestamp) / 86400 ))

        if [ "$expiry_timestamp" -lt "$current_timestamp" ]; then
            echo "❌ EXPIRED: $namespace/$name - Expired on $expiry_date"
        elif [ "$days_remaining" -lt 30 ]; then
            echo "⚠️  EXPIRING SOON: $namespace/$name - Expires in $days_remaining days ($expiry_date)"
        else
            echo "✅ VALID: $namespace/$name - Expires on $expiry_date"
        fi
    fi
done




