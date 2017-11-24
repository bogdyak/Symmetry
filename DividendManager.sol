pragma solidity^0.4.15;

import "./SingleTokenCoin.sol";
// import "./SafeMath.sol";
import "./AuthAdmin.sol";
// import "./Ownable.sol";

contract DividendManager is Ownable {
    
    using SafeMath for uint256;
    
    uint256 public dividends_share;
    uint256 public reinvestment_share;
    
    SingleTokenCoin token;
    AuthAdmin authAdmin;

    mapping (address => uint256) public dividends;

    event PaymentAvailable(address addr, uint256 amount);
    event DividendPayment(uint256 dividend_per_token, uint256 timestamp);
    event DevidendsSnapshot(address _addr, uint256 _value);
    event ReinvestmentWithdrawal(address _owner, uint256 _value);
    
    modifier adminOnly {
        require (authAdmin.isCurrentAdmin(msg.sender));
        _;
    }
    
    function DividendManager(address token_address, address auth_address) {
        token = SingleTokenCoin(token_address);
        set_new_admin(auth_address);
        dividends_share = 50;
        reinvestment_share = 50;
    }

    function () payable {
        // require (!token.is_end());
        uint256 funds_for_dividends = msg.value.mul(dividends_share).div(100);
        uint256 dividend_per_token = funds_for_dividends / token.totalSupply();
        require (dividend_per_token != 0);
        uint256 totalPaidOut = 0;
        for (uint256 i = 0; i < token.count_token_holders(); i++) {
            address addr = token.tokenHolder(i);
            if (token.balanceOf(addr) < 1000E6) {
                uint256 dividends_before_commision = dividend_per_token.mul(token.balanceOf(addr));    
                uint256 dividends_after_commision = dividends_before_commision.mul(85).div(100);
            } else if (token.balanceOf(addr) > 1000E6) {
                dividends_before_commision = dividend_per_token.mul(token.balanceOf(addr));
                dividends_after_commision = dividends_before_commision.mul(925).div(1000);
            }
            dividends[addr] = dividends[addr].add(dividends_after_commision);
            PaymentAvailable(addr, dividends_after_commision);
            totalPaidOut = totalPaidOut.add(dividends_after_commision);
        }
        DividendPayment(dividend_per_token, now);
        // uint256 remainder = msg.value.sub(totalPaidOut);
        // require (remainder > 0 && !msg.sender.send(remainder));
        // dividends[msg.sender] = dividends[msg.sender].add(remainder);
        // PaymentAvailable(msg.sender, remainder);
    }

    function set_new_admin (address admin_address) onlyOwner {
        authAdmin = AuthAdmin(admin_address);
    }

    function set_new_dividend_share (uint256 new_dividends_share) adminOnly {
        require (new_dividends_share > 0 && new_dividends_share <= 100);
        dividends_share = new_dividends_share;
        reinvestment_share = 100 - dividends_share;                                                                                                                                                                                                                                                                                                                                                                                
    }
    
    function withdrawDividend() {
        require (dividends[msg.sender] != 0);
        uint256 addr_dividends = dividends[msg.sender];
        dividends[msg.sender] = 0;
        require (msg.sender.send(addr_dividends));
        DevidendsSnapshot(msg.sender, addr_dividends);
    }
    
    function get_funds_left_for_reinvestment () onlyOwner {
        ReinvestmentWithdrawal(owner, this.balance);
        require(msg.sender.send(this.balance));
    }
}