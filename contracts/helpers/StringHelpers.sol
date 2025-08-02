// SPDX-License-Identifier: MIT
pragma solidity >=0.8.2 <0.9.0;

library StringUtils {
    function verifyCharacterLimit(uint _maxLength, string memory _string) internal pure returns (bool) {
        bytes1 asciiSpaceHex = hex"20";
        bytes memory stringInBytes = bytes(_string);
        
        if(stringInBytes.length > _maxLength) {
            return false;
        }

        for (uint i = 0; i < stringInBytes.length; i++) {
            if (stringInBytes[i] == asciiSpaceHex) {
                return false;
            }
        }

        return true;
    }
}