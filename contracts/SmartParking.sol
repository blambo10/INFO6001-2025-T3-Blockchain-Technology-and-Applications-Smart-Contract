// SPDX-License-Identifier: MIT
pragma solidity >=0.8.2 <0.9.0;

import "./ParkingSpace.sol";
import "./helpers/GeoHelpers.sol";
import "./helpers/StringHelpers.sol";

/**
 * @title SmartParking Contract
 * @dev This contract manages smartparking system and associated spaces
 */
contract SmartParking {
    using GeoUtils for int;
    using StringUtils for string;
    ParkingSpaces private spaces;
    string constant VOID = "";
    uint constant REG_MAX_CHARS = 7;

    constructor(){
        //[BL] Create parking spaces upon deployment of contract,
        //.    spaces are bound to minted tokens by ID
        spaces = new ParkingSpaces(address(this));
    }

    struct Sensor{
        uint id;
        int x;
        int y;
        bool occupied;
        uint modifiedTimeStamp;
        string vehicleRegistration;
        bool registered;
    }

    struct Reservation{
        uint tokenId;
        bool exists;
    }

    mapping(uint => Sensor) private sensors;
    mapping(string => uint) private reservations;
    string[] private registered;

    //[BL] Events are used to emit sensor information such as
    //.    registration and updated state to the front end.
    event SensorRegistered(uint id, 
                           int x,
                           int y);
    
    event SensorReadingUpdate(uint id, 
                              bool occupied, 
                              uint durationInPreviousState, 
                              string vehicleRegistration);


    modifier IsSensorRegistered(uint _id) {
        require(sensors[_id].registered, "Sensor Not Registered!");
        _;
    }

    /**
     * @notice Function to register sensor with contract.
     * @param _id Sensor id.
     * @param _x Longitude location of sensor.
     * @param _y Latitude location of sensor.
     */
    function RegisterSensor(uint _id, int _x, int _y) public {
        require(!sensors[_id].registered, 
                "Sensor Already Registered");
        require(GeoUtils.validateCoordinates(_x, _y), "invalid coordinates"); 

        sensors[_id] = Sensor(
            {
                id: _id,
                x: _x,
                y: _y,
                occupied: false,
                modifiedTimeStamp: block.timestamp,
                vehicleRegistration: VOID,
                registered: true
            }
        );

        emit SensorRegistered(_id, _x, _y);
    }

    /**
     * @notice Mutating function to update register sesnors data
     * @param _id Sensor id.
     * @param _occupied Current sensor state.
     * @param _vehicleRegistration Registration of vehicle currently occupying.
     */
    function updateSensorReadings(uint _id, 
                                  bool _occupied, 
                                  string memory _vehicleRegistration) 
                                  public IsSensorRegistered(_id) {
        uint durationInPreviousState = 0;
        string memory previousStatevehicleRegistration = sensors[_id].vehicleRegistration;

        //[BL] vacate space and free token allocation if sensor detects vacant occupancy.
        if(!_occupied && sensors[_id].occupied){
            require(clearSensorOccupancy(_id));
            _vehicleRegistration = VOID;
        }
       
        //[BL] reserve token allocation and associte with vehicle reg
        //     if sensor detects vacant occupancy.
        if(_occupied){
            require(StringUtils.verifyCharacterLimit(REG_MAX_CHARS, _vehicleRegistration),
                    "invalid vehicle registration!");
            require(reservations[_vehicleRegistration] == 0, 
                    "vehicle already holds an active reservation!");

            require(clearSensorOccupancy(_id), "unable to clear sensor of previous occupant");

            uint spaceReservation = spaces.reserveSpace();
            require(spaceReservation > 0, 
                    "parking space allocation was not returned!");

            reservations[_vehicleRegistration] = spaceReservation;
        }

        sensors[_id].occupied = _occupied;
        sensors[_id].vehicleRegistration = _vehicleRegistration;


        if(block.timestamp > sensors[_id].modifiedTimeStamp){
            durationInPreviousState = block.timestamp - sensors[_id].modifiedTimeStamp;
        }

        sensors[_id].modifiedTimeStamp = block.timestamp;

        //[BL] emiting event containing all attributes that will enable tracking duration occupied,
        //.    this will provide the foundation for later extension and charging customers.
        emit SensorReadingUpdate(_id, 
                                _occupied, 
                                durationInPreviousState,
                                previousStatevehicleRegistration);
    }

    /**
     * @notice Clear sensor occupancy
     * @param _id Sensor id.
     * @return bool indicating if clear was succesful.
     */
    function clearSensorOccupancy(uint _id) private returns (bool) {
        string memory previousStatevehicleRegistration = sensors[_id].vehicleRegistration;            
        spaces.vacateSpace(reservations[previousStatevehicleRegistration]);
        delete reservations[previousStatevehicleRegistration];
        return true;
    }

    /**
     * @notice Test function to check parking space reservations in ParkingSpace Contract.
     * @param _tokenId The amount to increment the counter by.
     * @return Parking space status
     */
    function getParkingReservation(uint _tokenId) public view returns (string memory) {
        return spaces.checkSpaceValue(_tokenId);
    }

    /**
     * @notice Function to retreive all parking sensor data.
     * @param _id The amount to increment the counter by.
     * @return Sensor data type pertaining to supplied sensor id.
     */
    function getSensorData(uint _id) public view returns (Sensor memory) {
        return sensors[_id];
    }
}