// SPDX-License-Identifier: MIT
pragma solidity ^0.8.3;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title ParkingSpaces Contract
 * @dev This contract manages Parking Space allocation using ERC721 tokens for asset management.
 */
contract ParkingSpaces is ERC721, Ownable {
    
    uint constant NO_VACANCIES = 0;
    uint constant MAX_SPACES = 100;
    string constant VOID = "";
    string constant OCCUPIED = "OCCUPIED";
    string constant VACANT = "VACANT";
    string constant UNKNOWN_STATE = "UNKNOWN_STATE";

    mapping(uint => ParkingSpaceState) private parkingSpaces;

    enum ParkingSpaceState { Void, Occupied, Vacant }

    event ParkingSpaceStatus(uint id, 
                            ParkingSpaceState state);

    /**
     * @notice Constructor for contract
     * @param _ownerAddress Address of contract who will own all parkingspaces.
     */
    constructor(address _ownerAddress) 
    ERC721("SmartParkingSpaces", "SMPS") 
    Ownable(_ownerAddress) {
        
        for (uint _tokenId = 1; 
            _tokenId <= MAX_SPACES; 
            _tokenId++) {

            _safeMint(_ownerAddress, _tokenId);
            parkingSpaces[_tokenId] = ParkingSpaceState.Vacant;
        }

    }

    /**
     * @notice Mutator function for reserving minted token and associated space.
     * @return tokenId of type uint 
     */
    function reserveSpace() public onlyOwner returns (uint) {       
        uint tokenId = _findNextVacantSpace();
        parkingSpaces[tokenId] = ParkingSpaceState.Occupied;

        //[BL] emit event to advise the changing of parking space status.
        emit ParkingSpaceStatus(tokenId, 
                        ParkingSpaceState.Occupied);

        return tokenId;
    }

    /**
     * @notice Test function for checking occupancy state of space / token.
     * @param _tokenId id of parking space / token.
     * @return state of type string
     */
    function checkSpaceValue(uint _tokenId) public view onlyOwner returns (string memory) {
        string memory state;

        if(parkingSpaces[_tokenId] == ParkingSpaceState.Void) {
            state = VOID;
        } else if(parkingSpaces[_tokenId] == ParkingSpaceState.Occupied) {
            state = OCCUPIED;
        } else if(parkingSpaces[_tokenId] == ParkingSpaceState.Vacant) {
            state = VACANT;
        }

        return state;
    }

    /**
     * @notice Mutator function to vacate space / token.
     * @param _tokenId id of parking space / token.
     */
    function vacateSpace(uint _tokenId) public onlyOwner {
        parkingSpaces[_tokenId] = ParkingSpaceState.Vacant;
        
        //[BL] emit event to advise the changing of parking space status.
        emit ParkingSpaceStatus(_tokenId, 
                            ParkingSpaceState.Vacant);
    }

    /**
     * @notice Function to fetch next vacant parking space.
     * @return id of next vacant space / token of type uint
     */
    function _findNextVacantSpace() private onlyOwner view returns (uint) {
        for (uint _tokenId = 1; _tokenId <= MAX_SPACES; _tokenId++) {
            
            if(_tokenId >= MAX_SPACES) {
                return NO_VACANCIES;
            }
            
            if(parkingSpaces[_tokenId] == ParkingSpaceState.Vacant) {
                return _tokenId;
            }
           
        }

        return NO_VACANCIES;
    }
}