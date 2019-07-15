Used public/private keys generated from openssl in node-rsa and Java/Kotlin
======

Generate keys in openssl
------
```sh 
#!/bin/bash
rm -rf private.pem public.pem private-pkcs8.pem file.client file.enc file.server
openssl genrsa -out private.pem 2048
openssl pkcs8 -in private.pem -topk8 -nocrypt -out private-pkcs8.pem
openssl rsa -pubout -in private.pem -out public.pem
echo 'hello world' > file.client
openssl rsautl -encrypt -inkey public.pem -pubin -in file.client -out file.enc
openssl rsautl -decrypt -inkey private.pem -in file.enc -out file.server
cat file.server
```

We need to convert the key to pkcs8 to use in Java.

Encrypt data in JavaScript
------
Use public.pem as key of node-rsa to encrypt data in React.

```javascript
handleSubmit = (event) => {
        event.preventDefault();

        const user = ReactDOM.findDOMNode(this.refs.username);
        const pass = ReactDOM.findDOMNode(this.refs.password);

        const params = user.name + '=' + user.value + '&' +
            pass.name + '=' + pass.value;
        const keyData = '-----BEGIN PUBLIC KEY-----\n' +
            'MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAwd6yXuAW1SuMJXSNHwUd\n' +
            'h6YJI5sVfeahs8EGwxLbvsAbX4SCNIWZ8k/x3L/kxE9mZg15qktW3qo2vaa2vZ9V\n' +
            'JB6H+HPAaqtgOLiPzsLb3NZbwtLPaaDt1oWQITPdOY1TrmA3uM2c/FikVpDvi7Sa\n' +
            '5DPRGhsDqsTP+aPowgwBBDqTxR80c/uUH7nzCBE2eoc//cykceEYIQgjJ+x67R04\n' +
            'MUMeSOAXS1th3oHqyz4g3SHcXyXjqyQkI29QWGaiB59pHRjQqU+TxWcEe9yq+EQq\n' +
            'zLuRYr9tdXZPqba5yWEMuvJupIKYU2qu/azp9fYRGenrQlhAp6MEAvJ4Gt2bKB/D\n' +
            'OQIDAQAB\n' +
            '-----END PUBLIC KEY-----';

        const key = new NodeRSA(keyData);
        key.setOptions({
            encryptionScheme: 'pkcs1'
        });
        const encryptedData = key.encrypt(params, 'base64');
        fetch('/login', {
            method: 'POST',
            body: encryptedData
        }).then((res) => {
            console.log(res)
        }).catch((err) => {
            console.log(err)
        })
    };
```

Decrypt data in Spring Java/Kotlin
------
Use the content of file `private-pkcs8.pem` with head, tail, whitespace and newline removed as input private key.

```kotlin
const val PRIVATE_KEY = "-----BEGIN PRIVATE KEY-----\n" +
        "MIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQDB3rJe4BbVK4wl\n" +
        "dI0fBR2HpgkjmxV95qGzwQbDEtu+wBtfhII0hZnyT/Hcv+TET2ZmDXmqS1beqja9\n" +
        "pra9n1UkHof4c8Bqq2A4uI/Owtvc1lvC0s9poO3WhZAhM905jVOuYDe4zZz8WKRW\n" +
        "kO+LtJrkM9EaGwOqxM/5o+jCDAEEOpPFHzRz+5QfufMIETZ6hz/9zKRx4RghCCMn\n" +
        "7HrtHTgxQx5I4BdLW2HegerLPiDdIdxfJeOrJCQjb1BYZqIHn2kdGNCpT5PFZwR7\n" +
        "3Kr4RCrMu5Fiv211dk+ptrnJYQy68m6kgphTaq79rOn19hEZ6etCWECnowQC8nga\n" +
        "3ZsoH8M5AgMBAAECggEBAJQpAj45mZl991Pkl7j+KswxGsjoS2t1Z1y9htJsRh2o\n" +
        "KQM9fFhxRe6GJDvlNwrD92jEoZeAjjoK8VzM3NlbvDCnWJiKtaGPqTCP8+86wdYq\n" +
        "x+PDQhnikAEi/7wwK8BA/pPEGrGUCYZco/M4PqmQ89K0uvftb0cBtEN/fXFWxSwZ\n" +
        "1njA/6/E93VQYPkEJDsgFuaDVbwnnjtwnnPF+Qgg9IpLiFVB3NyH2vnO8OJRPc2v\n" +
        "/BoP/l0LK5fk+YFCFukViiNSttGQ5zk3UKNTNHJXvQrsx6Q8srEMuxrje2wbSfcu\n" +
        "ud0zBjHoCQklZN2o6uq3euF8qKXtfB0lrHP2ssWBiPUCgYEA8odOW13hEluJ40ii\n" +
        "+a+e7+GzsDnPvb+8lUlx8a69Bn8vTgUtnfZCRJisFC2y2zfkeTMks4+P1+dX41AX\n" +
        "ecx2urD0zBPL2z0y1GsfRXbZwcqlb1u2xG1XkQqsJ6Rz1Qzh9H5Ryd0nW7GzOYoR\n" +
        "uLUHCAIYVa3cCn9QClQoJ1NjVgsCgYEAzKN6NYKfoTw6SvsRnTiirSHto7QBSpSo\n" +
        "0iDsbBaVkr92qw4f4DdKVrsS6Ow8tJoniaEQOnPs8fK9xX9yGjHNi6fu/hDQ7FMI\n" +
        "gylsU8GaQVStCU8gi7mJYY/CtZkwoqRVgVIbi+m93T65gaCLcPnre1vP7alHTduZ\n" +
        "6liHUwFPaksCgYBTkkpu83eWMtLd7e6y6VB0Sqr3g8RRF1vteWR5KoRaU8NCOEiS\n" +
        "0QPezVkmjuS945GoLfZspYCknkRLwRKF1u3mwQlptTye7ISya8NX1W+N9r1xFQJy\n" +
        "x1bQVQQjmOiNNqY58LlQPRPN5frjTe9zXXXxzX8DLyjOuTYkiQFZI8PsJwKBgH9c\n" +
        "+9HUE7ARQSKrsqHMvwrMhBAQF4Golo35qcv4Hm2wNpZt+w7cuqrSUgmgBoRNMXBq\n" +
        "SyRmREGt18jU8lo1Rv21rnx4UN/VKgYgQOi8JVql7fBOTC5KcqPDCudliaygZQtQ\n" +
        "5A4nk2DhCioQltjg41vqn7YGVnexxtDg+pCBz0CTAoGAI5lFesosCaOuPkkoHuz2\n" +
        "pJwR1AfQeXg4kT/Tu+w9evIFYnJ2j47EFxBAVp533zDxUaq19DJtNwOSmdLv2RCF\n" +
        "cJaSW5XsIowSke9qf9sSg2antNpUDgPudvNMsUspfnMhhRvOHbfSO4iYEEu2qT4m\n" +
        "Nq9qp9nRV3V5tpuPUzj4nXA=\n" +
        "-----END PRIVATE KEY-----"

@RestController
class HelloController {

    @PostMapping("/login")
    fun login(@RequestBody requestBody: String): String {
        val decodeString = Cipher.getInstance("RSA/ECB/PKCS1Padding")
                .also { cipher ->
                    KeyFactory.getInstance("RSA").generatePrivate(
                            PKCS8EncodedKeySpec(Base64Utils.decodeFromString(PRIVATE_KEY
                                    .replace("-----BEGIN PRIVATE KEY-----", "")
                                    .replace("-----END PRIVATE KEY-----", "")
                                    .replace(Regex("\\s"), ""))
                            )
                    ).also { privateKey ->
                        cipher.init(Cipher.DECRYPT_MODE, privateKey)
                    }
                }.doFinal(Base64Utils.decodeFromString(requestBody)).toString(Charset.defaultCharset())
        println(decodeString)

        return "ok"
    }
}
```

Reference
------
* [node-rsa](https://www.npmjs.com/package/node-rsa)
* [openssl-rsa-java](https://adangel.org/2016/08/29/openssl-rsa-java/)
* [RSA Encryption and Decryption in Java](https://www.devglan.com/java8/rsa-encryption-decryption-java)
