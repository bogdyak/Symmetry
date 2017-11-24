pragma solidity^0.4.15;

import "./AuthAdmin.sol";

contract OpennesContract {
    
    Funds_Value[] public fundsValue;
    Account_Value[] public accountValue;
    AuthAdmin authAdmin;
    
    struct Funds_Value {
        uint256 in_usd;
        uint256 in_ethers;
        uint256 suppliedTimestamp;
        uint256 block_time;
    }

    struct Account_Value {
        string account_type; /* Bitcoin, USD, etc. */
        string issuer_name; /* Kraken, Bank of America, etc. */
        uint256 balance; /* Rounded to appropriate for balance - i.e. full USD or full BTC */
        string accountReference; /* Could be crypto address, bank account number, etc. */
        string validationUrl; /* Some validation URL - i.e. base64 encoded notary */
        uint256 suppliedTimestamp;
        uint256 block_time;
    }

    event FundsValue(uint256 in_usd, uint256 in_ethers, uint256 suppliedTimestamp, uint256 block_time);
    event AccountValue(string account_type, string issuer_name, uint256 balance, string accountReference, string validationUrl, uint256 timestamp, uint256 block_time);

    modifier adminOnly {
        require (authAdmin.isCurrentAdmin(msg.sender));
        _;
    }

    function OpennesContract(address admin_address) {
        authAdmin = AuthAdmin(admin_address);
    }

    function share_funds_value (uint256 _usdTotalFund,
    uint256 _etherTotalFund,
    uint256 _definedTimestamp) adminOnly {
        fundsValue.push(Funds_Value(_usdTotalFund, _etherTotalFund, _definedTimestamp, now)); 
        FundsValue(_usdTotalFund, _etherTotalFund, _definedTimestamp, now);
    }

    function share_accounts_value (string _account_type,
        string _issuer_name,
        uint256 _balance,
        string _accountReference,
        string _validationUrl,
        uint256 _timestamp) adminOnly 
    {
        accountValue.push(Account_Value(_account_type, _issuer_name, _balance, _accountReference, _validationUrl, _timestamp, now));
        AccountValue(_account_type, _issuer_name, _balance, _accountReference, _validationUrl, _timestamp, now);
    }
                        /*--------------------------
                                  Getters
                        --------------------------*/
    
    function count_funds_value () constant returns (uint256 quantity) {
        quantity = fundsValue.length;
    }

    function count_account_value () constant returns (uint256 quantity) {
        quantity = accountValue.length;
    }
}
