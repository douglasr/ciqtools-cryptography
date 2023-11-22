/*
MIT License

Copyright (c) 2022-2023 Douglas Robertson (douglas@edgeoftheearth.com)

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

Author: Douglas Robertson (GitHub: [douglasr](https://github.com/douglasr); Garmin Connect: dbrobert)
License: MIT License
*/

import Toybox.Cryptography;
import Toybox.Lang;
import Toybox.StringUtil;
import Toybox.System;

module CIQToolsCryptography {

    //! TODO - describe function here
    function getCipherKey() as ByteArray {
        var uniqueID = System.getDeviceSettings().uniqueIdentifier;
        return (getStringAsByteArray(uniqueID.substring(0,16), StringUtil.REPRESENTATION_STRING_PLAIN_TEXT));
    }

    //! TODO - describe function here
    function encrypt(plainText as String) as String {
        var key = getCipherKey();
        var cipher = new Cryptography.Cipher( {
            :algorithm => Cryptography.CIPHER_AES128,
            :mode => Cryptography.MODE_ECB,
            :key => key
        });

        var idx = 0;
        var encryptedByteArray = null as ByteArray;
        while (idx < plainText.length()) {
            var plainTextBlock = plainText.substring(idx, idx+16);
            var byteArray = padByteArray(getStringAsByteArray(plainTextBlock, StringUtil.REPRESENTATION_STRING_PLAIN_TEXT), 16);
            var tmpCipher = cipher.encrypt(byteArray);
            if (encryptedByteArray == null) {
                encryptedByteArray = tmpCipher;
            } else {
                encryptedByteArray.addAll(tmpCipher);
            }
            idx = idx + 16;
        }

        var encryptedText = getByteArrayAsString(encryptedByteArray, StringUtil.REPRESENTATION_STRING_HEX);
        return (encryptedText);
    }

    //! TODO - describe function here
    function decrypt(encryptedText as String) as String {
        // decrypt using the unique ID of the device
        var cipher = new Cryptography.Cipher( {
            :algorithm => Cryptography.CIPHER_AES128,
            :mode => Cryptography.MODE_ECB,
            :key => getCipherKey()
        });

        var decryptedByteArray = null as ByteArray;
        var idx = 0;
        var encryptedByteArray = getStringAsByteArray(encryptedText, StringUtil.REPRESENTATION_STRING_HEX);
        while (idx < encryptedByteArray.size()) {
            var blockSizedEncryptedByteArray = encryptedByteArray.slice(idx, idx+16);
            var tmpByteArray = cipher.decrypt(blockSizedEncryptedByteArray);
            if (decryptedByteArray == null) {
                decryptedByteArray = tmpByteArray;
            } else {
                decryptedByteArray.addAll(tmpByteArray);
            }
            idx = idx + 16;
        }

        return (getByteArrayAsString(decryptedByteArray, StringUtil.REPRESENTATION_STRING_PLAIN_TEXT));
    }

    //! TODO - describe function here
    function getStringAsByteArray(str as String, fromRepresentation as StringUtil.Representation) as ByteArray {
        var convertOptions = {
            :fromRepresentation => fromRepresentation,
            :toRepresentation => StringUtil.REPRESENTATION_BYTE_ARRAY
        };
        return (StringUtil.convertEncodedString(str, convertOptions));
    }

    //! TODO - describe function here
    function getByteArrayAsString(byteArray as ByteArray, toRepresentation as StringUtil.Representation) as String {
        var convertOptions = {
            :fromRepresentation => StringUtil.REPRESENTATION_BYTE_ARRAY,
            :toRepresentation => toRepresentation
        };
        var convertedString = "";
        try {
            convertedString = StringUtil.convertEncodedString(byteArray, convertOptions);
        }
        catch (ex) {
        }
        return (convertedString);
    }

    //! TODO - describe function here
    function padByteArray(byteArray as ByteArray, paddedSize as Number) as ByteArray {
        var newByteArray = byteArray;
        while (newByteArray.size() < paddedSize) {
            newByteArray.add(0);
        }
        return (newByteArray);
    }

}
