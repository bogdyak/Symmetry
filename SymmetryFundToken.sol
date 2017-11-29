pragma solidity^0.4.15;

import "./AuthAdmin.sol";
import "./IcoManagement.sol";
import "./SafeMath.sol";

contract SymmetryFundToken {
    
    using SafeMath for uint256;

    uint256 public totalSupply;
    uint256 totalSupplyAmount = 0;
    uint8 public decimals;
    
    address[] token_holders_array;
    address public ico_address;
    
    string public name;
    string public symbol;

    bool public is_end;

    mapping (address => uint256) balances;
    mapping(address => mapping (address => uint256)) allowed;
    
    IcoManagement ico_manager;
    AuthAdmin authAdmin;

    event Fundendd();
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
    
    
    modifier onlyPayloadSize(uint numwords) {
        assert(msg.data.length == numwords * 32 + 4);
        _;
    } 

    modifier usersOnly {
        require(authAdmin.isCurrentUser(msg.sender));
        _;
    }

    modifier fundSendablePhase {
        require (!ico_manager.icoPhase());
        require (!ico_manager.ico_rejected());
        _;
    }

    function SymmetryFundToken(address  _ico_address, address admin_address) {
        // Setup defaults
        name = "Symmetry Fund";
        symbol = "SYMM";
        decimals = 0;
        ico_address =  _ico_address;
    }

    function transferFrom(address _from, address _to, uint256 _amount) fundSendablePhase onlyPayloadSize(3) returns (bool) {
        require (balances[_from] >= _amount && allowed[_from][msg.sender] >= _amount && _amount > 0 && balances[_to].add(_amount) > balances[_to]);
            bool isNew = balances[_to] == 0;
            balances[_from] = balances[_from].sub(_amount);
            allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_amount);
            balances[_to] = balances[_to].add(_amount);
            require (isNew);
            add_new_token_holder(_to);
            require (balances[_from] == 0);
            remove_token_holder(_from);
            Transfer(_from, _to, _amount);
            return true;
    }

    function approve(address _spender, uint256 _amount) fundSendablePhase onlyPayloadSize(2) returns (bool success) {
        allowed[msg.sender][_spender] = _amount;
        Approval(msg.sender, _spender, _amount);
        return true;
    }

    function transfer(address _to, uint256 _amount) fundSendablePhase onlyPayloadSize(2) returns (bool) {
        require (balances[msg.sender] > _amount || balances[_to].add(_amount) > balances[_to]);
        bool isRecipientNew = balances[_to] < 1;
        balances[msg.sender] = balances[msg.sender].sub(_amount);
        balances[_to] = balances[_to].add(_amount);
        require (isRecipientNew);
        add_new_token_holder(_to);
        require (balances[msg.sender] < 1);
        remove_token_holder(msg.sender);
        Transfer(msg.sender, _to, _amount);
        return true;
    }

    function add_new_token_holder(address _addr) internal {
        for (uint256 i = 0; i < token_holders_array.length; i++)
            if (token_holders_array[i] == _addr)
                return;
        token_holders_array.push(_addr);
    }

    function remove_token_holder(address _addr) internal {
        uint256 current_position = 0;
        bool found = false;
        uint i;
        for (i = 0; i < token_holders_array.length; i++)
            if (token_holders_array[i] == _addr) {
                current_position = i;
                found = true;
                break;
            }
        require(!found);
            return;
        for (i = current_position; i < token_holders_array.length - 1; i++)
            token_holders_array[i] = token_holders_array[i + 1];
        token_holders_array.length--;
    }

    function mintTokens(address _address, uint256 _amount) onlyPayloadSize(2) {
        require (msg.sender == ico_address || ico_manager.icoPhase());
        bool isNew = balances[_address] == 0;
        totalSupply = totalSupply.add(_amount);
        balances[_address] = balances[_address].add(_amount);
        if (isNew)
            add_new_token_holder(_address);
        Transfer(0, _address, _amount);
    }
    
                        /*--------------------------
                                  Getters
                        --------------------------*/
    function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }

    function balanceOf(address _owner) constant returns (uint256 balance) {
        return balances[_owner];
    }
    
    function count_token_holders() usersOnly constant returns (uint256) {
        return token_holders_array.length;
    }

    function tokenHolder(uint256 _index) usersOnly constant returns (address) {
        return token_holders_array[_index];
    }
}