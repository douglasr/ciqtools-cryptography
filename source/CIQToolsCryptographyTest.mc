/*
MIT License

Copyright (c) 2024 Douglas Robertson (douglas@edgeoftheearth.com)

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

import Toybox.Lang;
import Toybox.System;
import Toybox.Test;

module CIQToolsCryptography {

    // Wrapping all test cases within a module will allow the compiler
    // to eliminate the entire module when not building unit tests.
    (:test)
    module Test {

        const DEVICE_UNIQUE_ID = "77213e58a7ad4a1b a5f1c2edb15a05a33e8d1ee1";
        const PLAIN_TEXT_SHORT = "Foo Bar";
        const PLAIN_TEXT_LONG = "The quick brown fox jumped over the lazy dog. And also the Monkey C.";

        (:test)
        function testStrToCipher(logger as Logger) as Boolean {
            var cipherKey = stringToCipherKey(DEVICE_UNIQUE_ID);
            Test.assert(cipherKey.size() == 16);
            Test.assertEqual(cipherKey, [0x37,0x37,0x32,0x31,0x33,0x65,0x35,0x38,0x61,0x37,0x61,0x64,0x34,0x61,0x31,0x62]b);
            return (true);
        }

        (:test)
        function testEncrypt(logger as Logger) as Boolean {
            var cipherKey = stringToCipherKey(DEVICE_UNIQUE_ID);
            var encryptedText = encrypt(PLAIN_TEXT_SHORT, cipherKey);
            Test.assert(encryptedText instanceof String);
            Test.assertEqual(encryptedText, "114acda1259acce07322e9801f58f845");
            Test.assertEqual(encrypt(PLAIN_TEXT_LONG, cipherKey), "f7a6b84be14e7981a385f86da6ae18645403318b911bc189ce9b56968d0bdcbb64c87e0d2f02a5d0bd1de614f2640c79a4477324811496f4d57bbfa4f99c5758c4a31254b404ed59f0ede9bb90e030c5");
            return (true);
        }

        (:test)
        function testDecrypt(logger as Logger) as Boolean {
            var cipherKey = stringToCipherKey(DEVICE_UNIQUE_ID);
            var encryptedText = "114acda1259acce07322e9801f58f845";
            var plainText = decrypt(encryptedText, cipherKey);
            Test.assert(plainText instanceof String);
            Test.assertEqual(plainText, "Foo Bar");
            Test.assertEqual(decrypt("78be3d15ef83d1cd99d72371f37ebea9", cipherKey), "Foo Bar!");
            Test.assertEqual(decrypt("169b23d43f4c718f922731a23c811684", cipherKey), "Test String");
            Test.assertEqual(
                decrypt(
                    "f7a6b84be14e7981a385f86da6ae18645403318b911bc189ce9b56968d0bdcbb64c87e0d2f02a5d0bd1de614f2640c79a4477324811496f4d57bbfa4f99c5758c4a31254b404ed59f0ede9bb90e030c5",
                    cipherKey
                ),
                PLAIN_TEXT_LONG
            );
            return (true);
        }
    }
}
