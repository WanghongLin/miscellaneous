OpenSSL Self-signed certificate in MQTT server and client
======

Create and view self-signed certificate
------
```shell script
$ cd /tmp
$ openssl req -newkey rsa:2048 -nodes -keyout key.pem -x509 -days 365 -subj '/C=CN/ST=Guandong/L=Shenzhen/O=Company/OU=Tech/CN=*.company.com' -out cert.pem
$ openssl x509 -text -in cert.pem -noout
```

Load key/certificate in Java moquette MQTT server
------
```java
BasicConfigurator.configure();
Properties properties = new Properties();
properties.setProperty(BrokerConstants.HOST_PROPERTY_NAME, BrokerConstants.HOST);
properties.setProperty(BrokerConstants.PORT_PROPERTY_NAME, String.valueOf(BrokerConstants.PORT));
properties.setProperty(BrokerConstants.ALLOW_ANONYMOUS_PROPERTY_NAME, String.valueOf(true));
properties.setProperty(BrokerConstants.SSL_PORT_PROPERTY_NAME, "8883");
MemoryConfig config = new MemoryConfig(properties);

String key = new String(Files.readAllBytes(Paths.get("/tmp/key.pem")))
        .replace("-----BEGIN PRIVATE KEY-----", "")
        .replace("-----END PRIVATE KEY-----", "")
        .replaceAll("\\s", "");

PrivateKey privateKey =
        KeyFactory.getInstance("RSA").generatePrivate(new PKCS8EncodedKeySpec(Base64.getDecoder().decode(key)));

Certificate certificate = CertificateFactory.getInstance("X.509")
        .generateCertificate(new FileInputStream("/tmp/cert.pem"));

final SslContext sslContext =
        SslContextBuilder.forServer(privateKey, ((X509Certificate) certificate)).build();

Server server = new Server();
server.startServer(config, Collections.singletonList(new PublisherListener()),
        new ISslContextCreator() {
            @Override
            public SslContext initSSLContext() {
                return sslContext;
            }
        }, null, null);
```

Import certificate and connect via ssl in Android Paho MQTT client
------
```java
MqttConnectOptions connectOptions = new MqttConnectOptions();
connectOptions.setServerURIs(new String[]{"ssl://hostname:8883"});
connectOptions.setUserName("username");
connectOptions.setPassword("password".toCharArray());
connectOptions.setAutomaticReconnect(true);

try {
    Certificate certificate =
            CertificateFactory.getInstance("X.509").generateCertificate(getAssets().open("cert.pem"));

    KeyStore keyStore = KeyStore.getInstance(KeyStore.getDefaultType());
    keyStore.load(null);
    keyStore.setCertificateEntry("ca", certificate);

    TrustManagerFactory trustManagerFactory = TrustManagerFactory.getInstance("X509");
    trustManagerFactory.init(keyStore);

    SSLContext sslContext = SSLContext.getInstance("TLS");
    sslContext.init(null, trustManagerFactory.getTrustManagers(), null);

    connectOptions.setSocketFactory(sslContext.getSocketFactory());
} catch (Exception e) {
    e.printStackTrace();
}
```

Reference
------
* [ParseRSAKeys.java](https://gist.github.com/destan/b708d11bd4f403506d6d5bb5fe6a82c5)
* [Using openssl and java for RSA keys](https://adangel.org/2016/08/29/openssl-rsa-java/)
* [pkcs1与pkcs8格式RSA私钥互相转换](https://www.jianshu.com/p/08e41304edab)
* [convert private key to pkcs8 format](https://stackoverflow.com/questions/8290435/convert-pem-traditional-private-key-to-pkcs8-private-key)
* [How to create a self signed certificate with openssl](https://stackoverflow.com/questions/10175812/how-to-create-a-self-signed-certificate-with-openssl)
* [Generating a self-signed certificate using OpenSSL](https://www.ibm.com/support/knowledgecenter/en/SSMNED_5.0.0/com.ibm.apic.cmc.doc/task_apionprem_gernerate_self_signed_openSSL.html)
* [openssl-quick-reference-guide](https://www.digicert.com/ssl-support/openssl-quick-reference-guide.htm)
* [connect android device via mqtt with ssl](https://stackoverflow.com/questions/33696378/connect-android-device-via-mqtt-with-ssl)
* [Java SSLContext and the SSLSocketFactory self-signed certificate](https://sterl.org/2016/07/self-signed-certificate-java-sslcontext-and-sslsocketfactory/)
* [Everything About HTTPS and SSL (java)](https://dzone.com/articles/ssl-in-java)
