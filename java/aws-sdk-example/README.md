# AWS SDK example
This example utilizes the standard aws sdk with symphony.
Best to run it from an IDE, but in any case, the it's the code example itself that matters

## Prerequisites
1. Make sure to modify the explicit parameters required in EC2Example.java file
2. Make sure you have jre/jdk (1.8+) installed.
3. Make sure you have gradle installed on your system

## Run
1. gradle clean build
2. java -jar -Dcom.amazonaws.sdk.disableCertChecking <path to jar-all file, located in ./build/lib/>

## SSL Verification
By default, Symphony arrives with self signed certificates. In order to avoid SSL verification, add
`-Dcom.amazonaws.sdk.disableCertChecking` to your JVM parameters.
