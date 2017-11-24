pragma solidity^0.4.15;

import "./AuthAdmin.sol";
import "./SingleTokenCoin.sol";
// import "./SafeMath.sol";

contract IcoManagement {
    
    using SafeMath for uint256;
    
    uint256 price = 1E17; // wei per 1 token
    uint256 fract_price = 1E11;  // wei per 0.000001 token
    uint256 public icoStartTime = now;
    uint256 public icoEndTime = now + 2 minutes; // for testing
    // uint256 public icoEndTime = 1517270400; 
    uint256 public min_inv = 1E17;
    uint256 public minCap = 3000E18;
    // uint256 public tokenHolders;
    
    bool public icoPhase = true;
    bool public ico_rejected = false;
    // bool token_valid = false;

    mapping(address => uint256) public contributors;
    

    SingleTokenCoin public token;
    AuthAdmin authAdmin;

    event Icoend();
    event Ico_rejected(string details);
    
    modifier onlyDuringIco {
        require (icoPhase);
        require(now < icoEndTime && now > icoStartTime);
        _;
    }

    modifier adminOnly {
        require (authAdmin.isCurrentAdmin(msg.sender));
        _;
    }
    
    modifier usersOnly {
        require(authAdmin.isCurrentUser(msg.sender));
        _;
    }
    
    function () onlyDuringIco payable {
        invest(msg.sender);
    }
    
    function invest(address _to) public onlyDuringIco payable {
        uint256 purchase = msg.value;
        contributors[_to] = contributors[_to].add(purchase);
        require (purchase >= min_inv);
        uint256 change = purchase.mod(fract_price);
        uint256 clean_purchase = purchase.sub(change);
        uint256 token_amount = clean_purchase.div(fract_price);
        require (_to.send(change));
        token.mint(_to, token_amount);
    }
    
    function IcoManagement(address admin_address) {
        require (icoStartTime <= icoEndTime);
        authAdmin = AuthAdmin(admin_address);
    }
    
    function set_token(SingleTokenCoin _addr) adminOnly {
        token = SingleTokenCoin(_addr);
    }

    function end() adminOnly {
        require (now >= icoEndTime);
        icoPhase = false;
        Icoend();
    }
    
    
    function withdraw_funds (uint256 amount) adminOnly {
        require (this.balance >= amount);
        require(msg.sender.send(amount));
    }
    
    function withdraw_if_failed() public {
        require(now > icoEndTime);
        require(!icoPhase);
        require (contributors[msg.sender] != 0);
        contributors[msg.sender] = 0;
        require (msg.sender.send(contributors[msg.sender]));
    }
    // function reject (string details) adminOnly {
    //     // require (now > icoEndTime);
    //     // require (!ico_rejected);
    //     strlog("gone");
    //     uint256 dividend_per_token = this.balance / token.totalSupply();
    //     log(dividend_per_token);
    //     log(this.balance);
    //     log(token.totalSupply());
    //     uint numberTokenHolders = token.count_token_holders();
    //     log(numberTokenHolders);
    //     uint256 total_rejected = 0;
    //     for (uint256 i = 0; i < numberTokenHolders; i++) {
    //         address addr = token.tokenHolder(i);
    //         adlog(addr);
    //         uint256 etherToSend = dividend_per_token * token.balanceOf(addr);
    //         log(etherToSend);
    //         // require (etherToSend < 1E18);
    //         rejectedIcoBalances[addr] = rejectedIcoBalances[addr].add(etherToSend);
    //         log(rejectedIcoBalances[addr]);
    //         total_rejected = total_rejected.add(etherToSend);
    //         log(total_rejected);
    //     }
    //     ico_rejected = true;
    //     Ico_rejected(details);
    //     uint256 remainder = this.balance.sub(total_rejected);
    //     log(remainder);
    //     require (remainder > 0);
    //     require (msg.sender.send(remainder));
    //     strlog("gone");
    //     rejectedIcoBalances[msg.sender] = rejectedIcoBalances[msg.sender].add(remainder);
    // }

    // function rejectedFundWithdrawal() {
    //     
    // }
}