pragma solidity ^0.5.0;

/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 This contract creates an ERC20 token.
 */
 /*Author: Nigam Kumar
Date    : 20/04/2020.
nktERC20 is a sample ERC20 contract that implements IERC20 interface. */


library SafeMath { 
    // Only relevant functions
function sub(uint256 a, uint256 b) internal pure returns (uint256) {
  //assert(b <= a);
  require((b <= a), "Substraction overflow");
  uint256 c = a - b;
  return c;
}

function add(uint256 a, uint256 b) internal pure returns (uint256)   {
  uint256 c = a + b;
 // assert(c >= a);
   require((c >= a), "Addition overflow");

  return c;
}
}
 
 
interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address _who) external view returns (uint256);
    function allowance(address _owner, address _spender) external view returns (uint256);
    function transfer(address _to, uint256 _value) external returns (bool);
    function approve(address _spender, uint256 _value) external returns (bool);
    function transferFrom(address from1, address to1, uint256 _value) external returns (bool);
    event Transfer(address indexed from1, address indexed to1, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}



contract nktERC20 is IERC20 {
    using SafeMath for uint256;
    string  private name = "NKT Token";
    string  public symbol = "NKT";
    string  private standard = "NKT Token v1.0";
    uint256 private _totalsupply;  // required
    address public contractOwner;
    mapping(address => uint256) private _balanceof;
    mapping(address => mapping(address => uint256)) private _allowance;

	struct callingcontract {
		string calledfunction;
  		address callingaddress;
  		address _from;
  		address to;
  		uint256 value;
        bool returnvalue;
    }

    uint256 public numcalls = 0;
    mapping(uint256 => callingcontract) public callingcontracts;


    event Transfer(address indexed from1, address indexed to1, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

//constructor
    constructor (uint256 _initialSupply) public {
        _balanceof[msg.sender] = _initialSupply;
        _totalsupply = _initialSupply;
        contractOwner = msg.sender;
    }
 
    function() external { 
     //  bool returnValue = true;
        
    }

    /*The function totalSupply() returns the value of total sspply of the token.*/ 
    function totalSupply() external view returns (uint256) {
        return _totalsupply;
    }

    /*The function balanceOf() returns the balance at a given address.*/ 
    function balanceOf(address _who) external view returns (uint256) {
        return _balanceof[_who];
    }

    
    function allowance(address _owner, address _spender) external view returns (uint256){
             return _allowance[_owner][_spender];
    }
 
     /*Transfers token to a given address*/
     function transfer(address to1, uint256 _value) external returns (bool){
      

        callingcontract memory newcallingcontract = callingcontract(
                    "transfer",
                    msg.sender, 
                    msg.sender,
                    to1,
                    _value,
                    true
                    );
        uint256 callid = numcalls++;
        callingcontracts[callid] = newcallingcontract; //commit to state variable
   
        require ((to1 != address(0) ), "To must not be 0");
   
       if (_value > _balanceof[msg.sender]) {
            callingcontracts[callid].returnvalue = false;
        revert ("Transfer: Value more than Balanceof");
                 
        
    }
    else if (_value > _totalsupply) {
            callingcontracts[callid].returnvalue = false;
        revert ("Transfer: Value more than totalSupply");
               
    }
    else {

        
        _balanceof[msg.sender] = _balanceof[msg.sender].sub(_value);
        _balanceof[to1] = _balanceof[to1].add(_value);

        emit Transfer(msg.sender, to1, _value);

        return true;
    }
}

    function approve(address _spender, uint256 _value) external returns (bool){
     
        if (_value > _totalsupply) {
            revert ("Approve: Value more than totalSupply");
        }
        _allowance[msg.sender][_spender] = _value;

        emit Approval(contractOwner, _spender, _value);

        return true;
 
    }

    function transferFrom(address from1, address to1, uint256 _value) external returns (bool){
        /*Log who called the contract*/
        callingcontract memory newcallingcontract = callingcontract(
                    "approve",
                    msg.sender, 
                    from1,
                    to1,
                    _value,
                    true
                    );
        uint256 callid = numcalls++;
        callingcontracts[callid] = newcallingcontract; //commit to state variable

    // require ((to1 != address(0) ), "To must not be 0");
   if (to1 == address(0) ) {
       revert ("TransferFrom: To must not be 0");
   }

    if (_value > _balanceof[from1]) {
            callingcontracts[callid].returnvalue = false;
        revert ("TransferFrom: Value more than Balanceof");
        //return false;        
        
    }
    else if (_value > _allowance[from1][msg.sender]) {
            callingcontracts[callid].returnvalue = false;
        revert ("TransferFrom: Value more than Allowance");
        //return false;        

    }
    
    else if (_value > _totalsupply) {
            callingcontracts[callid].returnvalue = false;
        revert ("TransferFrom: Value more than totalSupply");
        //return false;        
    }
    else {
    
 //       balanceof[from] -= value;
 //       balanceof[to] += value;
        _balanceof[from1] = _balanceof[from1].sub(_value);
        _balanceof[to1] = _balanceof[to1].add(_value);

     //   _allowance[msg.sender][from1] -= _value;
        _allowance[from1][msg.sender] = _allowance[from1][msg.sender].sub(_value);
        emit Transfer(from1, to1, _value);

        return true;

    }