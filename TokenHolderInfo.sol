pragma solidity^0.4.15;

import "./AuthAdmin.sol";
import "./SingleTokenCoin.sol";

contract TokenHolderInfo {
    
    using SafeMath for uint256;

    address[] token_holders_array;
    
    mapping (address => uint256) balances;

    SingleTokenCoin token;
    AuthAdmin authAdmin;

    event SnapshotTaken();
    event SnapshotUpdated(address holder, uint256 oldBalance, uint256 newBalance, string details);

    modifier adminOnly {
        require (authAdmin.isCurrentAdmin(msg.sender));
        _;
    }
    modifier usersOnly {
        require (authAdmin.isCurrentUser(msg.sender));
        _;
    }

    function TokenHolderInfo(address token_address, address admin_address) {
        token = SingleTokenCoin(token_address);
        authAdmin = AuthAdmin(admin_address);
    }

    function snapshot() adminOnly {
        uint256 i;
        for (i = 0; i < token_holders_array.length; i++)
            balances[token_holders_array[i]] = 0;
            token_holders_array.length = token.count_token_holders();
        for (i = 0; i < token_holders_array.length; i++) {
            address addr = token.tokenHolder(i);
            token_holders_array[i] = addr;
            balances[addr] = token.balanceOf(addr);
        }
        SnapshotTaken();
    }

    function snapshotUpdate(address _addr, uint256 _newBalance, string _details) adminOnly {
        uint256 existingBalance = balances[_addr];
        if (existingBalance == _newBalance)
            return;
        if (existingBalance == 0) {
            token_holders_array.push(_addr);
            balances[_addr] = _newBalance;
        }
        else if (_newBalance > 0) {
            balances[_addr] = _newBalance;
        } else {
            balances[_addr] = 0;
            uint256 count_token_holders = token_holders_array.length;
            uint256 current_position = 0;
            bool found = false;
            uint256 i;
            for (i = 0; i < count_token_holders; i++)
                if (token_holders_array[i] == _addr) {
                    current_position = i;
                    found = true;
                    break;
                }
            require(found);
                for (i = current_position; i < count_token_holders - 1; i++)
                    token_holders_array[i] = token_holders_array[i + 1];
                token_holders_array.length--;
        }
        SnapshotUpdated(_addr, existingBalance, _newBalance, _details);
    }
                        /*--------------------------
                                  Getters
                        --------------------------*/
    function balanceOf(address addr) usersOnly constant returns (uint256) {
        return balances[addr];
    }

    function count_token_holders() usersOnly constant returns (uint256) {
        return token_holders_array.length;
    }

    function tokenHolder(uint256 _index) usersOnly constant returns (address) {
        return token_holders_array[_index];
    }
}