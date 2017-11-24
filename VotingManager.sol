pragma solidity^0.4.15;

import "./AuthAdmin.sol";
import "./VotingContract.sol";

contract VotingManager {
    
    using SafeMath for uint256;
    
    uint256 public time_voting_begins;
    uint256 public time_voting_ends;
    
    address[] public voters;

    mapping (address => uint256) public voteNum;

    AuthAdmin internal authAdmin;

    modifier adminOnly {
        require (authAdmin.isCurrentAdmin(msg.sender));
        _;
    }
    
    function VotingManager (address _auth_address) {
        authAdmin = AuthAdmin(_auth_address);
    }
    
    function setVoter(uint256 _position, address _voter, uint256 _voteNum) adminOnly {
        require (now <= time_voting_begins);
        require (_position <= voters.length);
        voters[_position] = _voter;
        voteNum[_voter] = _voteNum;
    }
    
    function count_voters (uint256 quantity) adminOnly {
        require (now <= time_voting_begins);
        for (uint256 i = 0; i < voters.length; i++) {
            address voter = voters[i];
            voteNum[voter] = 0;
        }
        voters.length = quantity;
    }

    function create_new_voting (
        uint256 voting_begins,
        uint256 voting_ends,
        address symm_token_address) adminOnly returns (VotingContract)
    {
        return new VotingContract(
            voting_begins,
            voting_ends,
            symm_token_address
        );
    }
    
}
