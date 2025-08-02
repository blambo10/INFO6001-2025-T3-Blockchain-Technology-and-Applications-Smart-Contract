// SPDX-License-Identifier: MIT
pragma solidity >=0.8.2 <0.9.0;

library GeoUtils {
    /**
     * @notice Function to verify long / lat are within valid ranges.
     * @param _x Longitude location of sensor.
     * @param _y Latitude location of sensor.
     */
    function validateCoordinates(int _x, int _y) internal pure returns (bool) {
        bool isValid = true;
        
        if(_x < -180 || _x > 180) {
            isValid =  false;
        }

        if(_y < -90 || _y > 90){
            isValid = false;
        }

        return isValid;
    }
}