pragma solidity ^0.5.0;

/*Author: Nigam Kumar
Date    : 22/04/2020.
StampCollector is a sample contracts that collects stamps from around the world. 
It differentiates between a real stamp and fake stamps based on certain properties.
It can interact with other contracts through IstampCollector interface.
The file contains some other contracts too in order to in order to have complete functionality*/

/*IStampCollector interface allows other contracts to interact with Stampcollector contract*/
interface IStampCollector {
  function isCollected(address stamp) external returns (bool);
  function collectStamp(address stamp) external;
}

/*Stamp is a sample contarct for real stamps.*/
contract Stamp {
  bytes32 public id;
  uint public rarity;
  
  constructor(bytes32 _id, uint _rarity) public {
    id = _id;
    rarity = _rarity;
  }
}

/*NotStamp is a sample contarct for fake stamps.*/
contract NotStamp {
  bytes32 public notId;
  uint public notRarity;
  
  constructor(bytes32 _id, uint _rarity) public {
    notId = _id;
    notRarity = _rarity;
  }
}

/*Contract CreateStamp is just for testing purpose. Its functions return byte values of equivalend 
uint values which can be used to create Stamps and NotStamps by passing it to contructors of Stamp 
and NotStamp*/
contract CreateStamp {
    bytes32 stampId;
    uint id;
    bytes32 notstampId;
    
  constructor() public {

    uint _stmpIdint = 1;
    uint _notstampIdint = 2;
    stampId = bytes32(_stmpIdint);
  	notstampId = bytes32(_notstampIdint);

  }

   function getStampId() public view returns (bytes32)  {
       return stampId;
   }
  
  function getNotStampId() public view returns (bytes32)  {
       return notstampId;
   }  
}

/*StampCollector Contract implements two functions : IsCollected and CollectStamp. 
Iscollected checks if the stamp has already been collected. CollectStamp collects the 
stamp from a given address. */
contract StampCollector {
NotStamp notstampcontract;
Stamp stampcontract;
IStampCollector stampColl;
address IstampCollectorAddress;
string errormessage;

	struct collectedstamp {
		bytes32 id;
  		uint rarity;
        address owner;
        address prevOwner;
    }

	struct callingcontract {
		string calledfunction;
  		address callingaddress;
  		address parameter;
        bool returnvalue;
    }

    uint256 public numStamps = 0;
    uint256 public numcalls = 0;

/*List of collected stamps*/
    mapping(uint256 => collectedstamp) public stamps;

/*indicator to check if the stamp has been collected from a given address*/
    mapping(address => bool) public collected;

/*List of addressed that have called the functions of StampCollector contract.*/
    mapping(uint256 => callingcontract) public callingcontracts;

event stampFound (address stamp, string returnmsg, bytes returnbytes);
event NotStampFound (address stamp, string returnmsg, bytes returnbytes);
event invalidAddress (address stamp, string returnmsg, bytes returnbytes); 
event stampCollected (address stamp, string returnmsg, bytes returnbytes); 
event stampAlreadyCollected (address stamp, string returnmsg, bytes returnbytes); 
event stampAlreadyCollected1 (address stamp, string returnmsg);

/*Constructor may not be required as the variables are not used anywhere.*/
constructor() public {
  	   address stampaddress = msg.sender;
  	        stampcontract = Stamp(stampaddress) ;
            notstampcontract = NotStamp(stampaddress);
  }


function isCollected(address stamp) external returns (bool) 
      {
    bool isstampcollected = false; //collected[stamp];
              callingcontract memory newcallingcontract = callingcontract(
                    "isCollected",
                    msg.sender, 
                    stamp,
                    isstampcollected
                    );
        uint256 callid = numcalls++;
        callingcontracts[callid] = newcallingcontract; //commit to state variable
       
  
   if (numStamps > 0){
    for(uint i=0; i < numStamps; i++)
    {
        if (stamps[i].prevOwner == stamp) {
            isstampcollected = true;
            callingcontracts[callid].returnvalue = isstampcollected;
         emit stampAlreadyCollected1(stamp, "IsCollected: Stamp is already collected"); 
          return isstampcollected;
        }
    }
   }
    return isstampcollected;

  }
  
  function collectStamp(address stamp) external //returns (bool, bytes memory) 
  {
 
           callingcontract memory newcallingcontract = callingcontract(
                    "collectStamp",
                    msg.sender,  
                    stamp,
                    true
                    );
        uint256 callid = numcalls++;
        callingcontracts[callid] = newcallingcontract; //commit to state variable


    Stamp stampcontract1 = Stamp(stamp);
    NotStamp notstampcontract1 = NotStamp(stamp);

/*Call low level function to check if the given address is a Stamp contract.*/
    (bool success, bytes memory returndata) =
            address(stamp).call( 
                abi.encodePacked( 
                    stampcontract1.id.selector
                )
            );
            
        if (success) { 
            bool iscollected = collected[stamp];
            
          emit stampFound (stamp, "Stamp Found",returndata);
          
          if (iscollected == false) {
            collectedstamp memory newCollectedstamp = collectedstamp(
                    Stamp(stamp).id(),
                    Stamp(stamp).rarity(),
                    msg.sender,  //owner
                    stamp
                    );
        uint256 stampid = numStamps++;
        stamps[stampid] = newCollectedstamp; 
        collected[stamp] = true;
        emit stampCollected(stamp, "Stamp Collected", returndata);
          }
          else
          {
              emit stampAlreadyCollected(stamp, "Stamp already collected", returndata);
             // revert ("Stamp already collected");
          }
        
        } 
        else { 
    (bool notstampsuccess, bytes memory returndata1) =
            address(stamp).call( 
                abi.encodePacked( 
                    notstampcontract1.notId.selector
                   
                )
            );
            
        if (notstampsuccess) { 
            emit NotStampFound(stamp, "Fake Stamp found", returndata1);
            revert("Not Stamo - Fake Stamp");
        } 
        else { 
            emit invalidAddress(stamp, "Neither Stamp nor NotStamp found", returndata1);
         }
            
         }

 }


}
