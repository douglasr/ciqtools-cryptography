/*
MIT License

Copyright (c) 2022-2024 Douglas Robertson (douglas@edgeoftheearth.com)

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

Author: Douglas Robertson (GitHub: douglasr; Garmin Connect: dbrobert)
*/

import Toybox.Cryptography;
import Toybox.Lang;
import Toybox.StringUtil;
import Toybox.System;

// CIQTools - Cryptography
module CIQToolsCryptography {

    // Convert a cipher key string to a properly sized byte array.
    //   @param  cipherKey string (of appropriate length) to be used as a cipher key
    //   @return byte array of the cipher key
    function stringToCipherKey(cipherKey as String) as ByteArray {
        return (getStringAsByteArray((cipherKey.substring(0,16) as String), StringUtil.REPRESENTATION_STRING_PLAIN_TEXT));
    }

    // Encrypt a plain text string using the given cipher key.
    //   @param  plainText plain text string to be encrypted
    //   @param  cipherKey cipher key as a byte array
    //   @return encrypted string
    function encrypt(plainText as String, cipherKey as ByteArray) as String {
        var cipher = new Cryptography.Cipher( {
            :algorithm => Cryptography.CIPHER_AES128,
            :mode => Cryptography.MODE_ECB,
            :key => cipherKey
        });

        var idx = 0;
        var encryptedByteArray = null as ByteArray;
        while (idx < plainText.length()) {
            var plainTextBlock = plainText.substring(idx, idx+16) as String;
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

    // Decrypt an encrypted string using the given cipher key.
    //   @param  encryptedText encrypted text string to be decrypted
    //   @param  cipherKey     cipher key as a byte array
    //   @return decrypted (plain text) string
    function decrypt(encryptedText as String, cipherKey as ByteArray) as String {
        // decrypt using the unique ID of the device
        var cipher = new Cryptography.Cipher( {
            :algorithm => Cryptography.CIPHER_AES128,
            :mode => Cryptography.MODE_ECB,
            :key => cipherKey
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

    // Convert a string to a byte array.
    //   @param  str     string to be converted
    //   @param  fromRep representation to be converted from (typically REPRESENTATION_STRING_PLAIN_TEXT)
    //   @return byte array of the given string
    function getStringAsByteArray(str as String, fromRep as StringUtil.Representation) as ByteArray {
        var convertOptions = {
            :fromRepresentation => fromRep,
            :toRepresentation => StringUtil.REPRESENTATION_BYTE_ARRAY
        };
        // make sure that user didn't request conversion from a byte array; if so, assume from plain text string
        if (convertOptions[:fromRepresentation] == StringUtil.REPRESENTATION_BYTE_ARRAY) {
            convertOptions[:fromRepresentation] = StringUtil.REPRESENTATION_STRING_PLAIN_TEXT;
        }
        return (StringUtil.convertEncodedString(str, convertOptions) as ByteArray);
    }

    // Convert a byte array to a string.
    //   @param  byteArray byte array to be converted
    //   @param  toRep     representation to be converted to (typically REPRESENTATION_STRING_PLAIN_TEXT)
    //   @return string converted from the given byte array
    function getByteArrayAsString(byteArray as ByteArray, toRep as StringUtil.Representation) as String {
        var convertOptions = {
            :fromRepresentation => StringUtil.REPRESENTATION_BYTE_ARRAY,
            :toRepresentation => toRep
        };

        // make sure that user didn't request conversion to a byte array; if so, default to plain text string
        if (convertOptions[:toRepresentation] == StringUtil.REPRESENTATION_BYTE_ARRAY) {
            convertOptions[:toRepresentation] = StringUtil.REPRESENTATION_STRING_PLAIN_TEXT;
        }

        var convertedString = "";
        try {
            convertedString = StringUtil.convertEncodedString(byteArray, convertOptions) as String;
        }
        catch (ex) {
        }
        return (convertedString);
    }

    // Pad a byte array to a specified length.
    //   @param  byteArray  byte array to be padded
    //   @param  paddedSize size the byte array should be padded to
    //   @return byte array of the specified length
    function padByteArray(byteArray as ByteArray, paddedSize as Number) as ByteArray {
        var newByteArray = byteArray;
        while (newByteArray.size() < paddedSize) {
            newByteArray.add(0);
        }
        return (newByteArray);
    }

}
