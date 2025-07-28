pragma solidity >=0.8.2 <0.9.0;

import "./ParkingSpace.sol";

contract ParkingSensor {
    ParkingSpace public spaces; // State variable

    // using ParkingSpace for ParkingSpace.Sensor;
    // mapping(string => Sensor) public sensors;

    constructor(){
        //TODO: continue here and work on relationship between parking spaces and sensors,
        //.     which will transfer to new owner (vehicleRegisteration) when new occupancy starts

        //.     Note: while the constructore for ERC20 sets the owner to msg.sender initially,
        //            it can be transfered to respective registerations
        spaces = new ParkingSpace();
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

    mapping(uint => Sensor) public sensors;

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

    function getSpaces() public view returns (uint) {
        
        return spaces.totalSupply();
    }

    function RegisterSensor(uint _id, uint _x, uint _y) public {
        require(!sensors[_id].registered, "Sensor Already Registered");
        require((_x != 0), "geolocation x value invalid");
        require((_y != 0), "geolocation y value invalid");

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

    function updateSensorReadings(uint _id, 
                                  bool _occupied, 
                                  string memory _vehicleRegisteration) 
                                  public IsSensorRegistered(_id) {
        uint durationInPreviousState = 0;
        string memory previousStateVehicleRegisteration = "";

        if(!_occupied && sensors[_id].occupied){
            previousStateVehicleRegisteration = sensors[_id].vehicleRegisteration;
            _vehicleRegisteration = "";
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

    function getSensorData(uint _id) public view returns (Sensor memory) {
        return sensors[_id];
    }
}