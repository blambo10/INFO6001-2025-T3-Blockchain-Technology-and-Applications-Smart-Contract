pragma solidity >=0.8.2 <0.9.0;

import "./ParkingSpace.sol";

//Todo: work on fixing the token transfer as it keeps throwing error.
//      also work on transfering to customer instead of msg.sender (msg.sender might be the customer, just check)

contract ParkingSensor {
    ParkingSpaces public spaces; // State variable

    constructor(){
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
            spaces.approve(address(this), 1);
            require(spaces.transferFrom(msg.sender, address(this), 1));
        }

        if(_occupied){
            spaces.approve(msg.sender, 1);
            require(spaces.transferFrom(address(this), msg.sender, 1));   
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