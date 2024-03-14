# CIQ Tools - Cryptography

(c)2022-2024 Douglas Robertson

Author: Douglas Robertson (GitHub: [douglasr](https://github.com/douglasr); Garmin Connect: dbrobert)

## Overview
Access to built-in cryptography libraries was included in the Connect IQ SDK 3.0.0.
However, the code for a simple encryption/decryption is not necessarily easy due to
the nature of cryptography. This barrel is an attempt to streamline the use of the
Connect IQ Cryptography library.

## License
This Connect IQ barrel is licensed under the "MIT License", which essentially means that
while the original author retains the copyright to the original code, you are free to do
whatever you'd like with this code (or any derivative of it). See the LICENSE.txt file
for complete details.

## Using the Barrel
This project cannot be used on it's own; it is designed to be included in existing projects.

### Include the Barrel
Download the barrel file (and associated debug.xml) and include it in your project.
See [Shareable Libraries](https://developer.garmin.com/connect-iq/core-topics/shareable-libraries/) on the Connect IQ Developer site for more details.

### Encrypting & Decrypting
The barrel currently only supports encrypting/decrypting with the AES128 cipher using ECB mode (additional functionally to be added to the barrel at some point); this necessitates a cipher of 16 bytes in length.

#### Cipher Key
The process of encrypting and then decrypting requires a cipher key. If the encrypt/decrypt
is done solely on the Garmin device, then the easiest, and perhaps safest, cipher key to use
is the device's unique identifier. The encryption function expects the cipher to be a ByteArray so the library includes a function to convert the cipher string to a properly sized ByteArray.

```
var uniqueID = System.getDeviceSettings().uniqueIdentifier
var cipherKey = CIQToolsCryptography.stringToCipherKey(uniqueID);
```

NOTE: The stringToCipherKey() function will truncate the cipher string as needed but will not pad the string if it is too short.

### Encrypt
A string is easily encrypted, using the cipher key ByteArray.

```
var plainText = "Monkey C is great!";
var encryptedString = CIQToolsCryptography.encrypt(plainText, cipherKey);
```

### Decrypt
The process of decrypting is equally simple.

```
var plainText = CIQToolsCryptography.decrypt(encryptedString, cipherKey);
```

## Contributing
Please see the CONTRIBUTING.md file for details on how contribute.

### Contributors
* [Douglas Robertson](https://github.com/douglasr)
