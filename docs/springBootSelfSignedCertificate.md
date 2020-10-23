Spring boot self signed certificate
==========

This article briefly describe how to use certificate in spring boot server created by `openssl`.
Supposed you have openssl 1.1.1 version installed with option `-addext` support.

#### Generate keys and certificates
```shell script
#!/bin/bash

_COUNTRY=
_STATE=
_LOCALITY=
_ORGANIZATION=
_UNIT=
_EMAIL=
_COMMON_NAME=

openssl req -newkey rsa:2048 -nodes -x509 -keyout cakey.pem -out cacert.pem -days 365 \
        -subj "/C=$_COUNTRY/ST=$_STATE/L=$_LOCALITY/O=$_ORGANIZATION/OU=$_UNIT/emailAddress=$_EMAIL/CN=$_COMMON_NAME" \
        -addext 'subjectAltName = IP:10.0.0.2,DNS:localhost,IP:127.0.0.1' \
        -addext 'extendedKeyUsage = serverAuth, clientAuth, codeSigning, emailProtection'

# used in spring boot server
openssl pkcs12 -inkey cakey.pem -in cacert.pem -export -name expertall -password pass:password -out expertall.p12

# create a certificate file name used in Android device
hash_name=$(openssl x509 -inform pem -subject_hash_old -in cacert.pem |head -1)
openssl x509 -inform pem -text -in cacert.pem -out ${hash_name}.0
```

Fill all the subject info with your personal information, you can make your server support more IP or name by adding more
`IP:x.x.x.x` or `DNS:name` entry in subject alternative section.

#### Deploy in Spring boot web server

We need to copy the keystore `expertall.p12` into spring boot project `resources` directory, 
and the password is `password` we used in above shell openssl command.

```properties
server.port=8443
server.ssl.enabled=true
server.ssl.key-store=classpath:expertall.p12
server.ssl.key-alias=expertall
server.ssl.key-store-password=password
server.ssl.key-store-type=PKCS12
```
Now the server side is ready.

#### Tested with curl
Your https service is accessible via all the `IP` and `DNS` in the certificate.

```shell script
curl --cacert /path/to/cacert.pem https://10.0.0.2:8443/hello
curl --cacert /path/to/cacert.pem https://127.0.0.1:8443/hello
curl --cacert /path/to/cacert.pem https://localhost:8443/hello
```

#### Install certificate in Android (Optional)

If you have a rooted Android device, the generated `${hash_name}.0` can be push to `/system/etc/security/cacerts`, make
it as the system root certificate. A minor modification should be done before copy to device. The base64 hash content `-----BEGIN CERTIFICATE-----`
and `-----END CERTIFICATE-----` should move to the beginning of the file like the other certificates shipped in Android ROM.
Otherwise, your certificate cannot be recognized and loaded.

After then your https service is available from all the applications in your Android device.

#### Reference resources
* [Install System CA on Android](https://docs.mitmproxy.org/stable/howto-install-system-trusted-ca-android/)
* [Install a trusted CA in Android N](https://awakened1712.github.io/hacking/hacking-install-ca-android/)
* [Configure SSL Certificate with Spring Boot](https://medium.com/@JavaArchitect/configure-ssl-certificate-with-spring-boot-b707a6055f3)
* [Enable HTTPS with self-signed certificate in Spring Boot 2.0](https://stackoverflow.com/questions/49324700/enable-https-with-self-signed-certificate-in-spring-boot-2-0)
* [Steps to create a self-signed certificate using OpenSSL](https://blogs.oracle.com/blogbypuneeth/steps-to-create-a-self-signed-certificate-using-openssl)
* [How to create a self-signed certificate with OpenSSL](https://stackoverflow.com/questions/10175812/how-to-create-a-self-signed-certificate-with-openssl)
* [Generating a self-signed certificate using OpenSSL](https://www.ibm.com/support/knowledgecenter/SSMNED_5.0.0/com.ibm.apic.cmc.doc/task_apionprem_gernerate_self_signed_openSSL.html)
* [How to generate a self-signed SSL certificate for an IP address](https://medium.com/@antelle/how-to-generate-a-self-signed-ssl-certificate-for-an-ip-address-f0dd8dddf754)
* [Provide subjectAltName to openssl directly on the command line](https://security.stackexchange.com/questions/74345/provide-subjectaltname-to-openssl-directly-on-the-command-line)
* [OpenSSL CSR with Alternative Names one-line](https://www.endpoint.com/blog/2014/10/30/openssl-csr-with-alternative-names-one)
