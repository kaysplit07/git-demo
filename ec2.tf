
C5392450@KTWJ124QK9 ~ % kubectl exec -it buyer-cms-content-management-64db69d9f8-hds5v -n family-buyer-cms -- cat /path/to/certificate.crt | openssl x509 -noout -text
command terminated with exit code 1
unable to load certificate
8321322816:error:09FFF06C:PEM routines:CRYPTO_internal:no start line:/AppleInternal/Library/BuildRoots/4ff29661-3588-11ef-9513-e2437461156c/Library/Caches/com.apple.xbs/Sources/libressl/libressl-3.3/crypto/pem/pem_lib.c:694:Expecting: TRUSTED CERTIFICATE
