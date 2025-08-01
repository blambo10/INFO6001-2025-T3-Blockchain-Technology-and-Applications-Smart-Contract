pragma solidity >=0.8.2 <0.9.0;

import "./ParkingSpace.sol";

/**
 * @title SmartParking Contract
 * @dev This contract manages smartparking system and associated spaces
 */
contract SmartParking {
    
    ParkingSpaces private spaces;

    constructor(){
        //[BL] Create parking spaces upon deployment of contract,
        //.    spaces are bound to minted tokens by ID
        spaces = new ParkingSpaces(address(this));
    }

    struct Sensor{
        uint id;
        uint x;
        uint y;
        bool occupied;
        uint modifiedTimeStamp;
        string vehicleRegisteration;
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
                           uint x,
                           uint y);
    
    event SensorReadingUpdate(uint id, 
                              bool occupied, 
                              uint durationInPreviousState, 
                              string vehicleRegisteration);


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
    function RegisterSensor(uint _id, uint _x, uint _y) public {
        require(!sensors[_id].registered, 
                "Sensor Already Registered");
        require((_x != 0), 
                "geolocation x value invalid");
        require((_y != 0), 
                "geolocation y value invalid");

        sensors[_id] = Sensor(
            {
                id: _id,
                x: _x,
                y: _y,
                occupied: false,
                modifiedTimeStamp: block.timestamp,
                vehicleRegisteration: "",
                registered: true
            }
        );

        emit SensorRegistered(_id, _x, _y);
    }

    /**
     * @notice Mutating function to update register sesnors data
     * @param _id Sensor id.
     * @param _occupied Current sensor state.
     * @param _vehicleRegisteration Registeration of vehicle currently occupying.
     */
    function updateSensorReadings(uint _id, 
                                  bool _occupied, 
                                  string memory _vehicleRegisteration) 
                                  public IsSensorRegistered(_id) {
        uint durationInPreviousState = 0;
        string memory previousStateVehicleRegisteration = "";

        //[BL] vacate space and free token allocation if sensor detects vacant occupancy.
        if(!_occupied && sensors[_id].occupied){
            _vehicleRegisteration = "";

            previousStateVehicleRegisteration = sensors[_id].vehicleRegisteration;            
            spaces.vacateSpace(reservations[previousStateVehicleRegisteration]);
            delete reservations[previousStateVehicleRegisteration];
        }

        //[BL] reserve token allocation and associte with vehicle reg
        //     if sensor detects vacant occupancy.
        if(_occupied){
            require(bytes(_vehicleRegisteration).length > 0, 
                    "invalid vehicle registeration!");
            require(reservations[_vehicleRegisteration] == 0, 
                    "vehicle already holds an active reservation!");

            uint spaceReservation = spaces.reserveSpace();
            require(spaceReservation > 0, 
                    "parking space allocation was not returned!");


            reservations[_vehicleRegisteration] = spaceReservation;
        }

        sensors[_id].occupied = _occupied;
        sensors[_id].vehicleRegisteration = _vehicleRegisteration;


        if(block.timestamp > sensors[_id].modifiedTimeStamp){
            durationInPreviousState = block.timestamp - sensors[_id].modifiedTimeStamp;
        }

        sensors[_id].modifiedTimeStamp = block.timestamp;

        emit SensorReadingUpdate(_id, 
                                _occupied, 
                                durationInPreviousState,
                                previousStateVehicleRegisteration);
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