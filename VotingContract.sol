pragma solidity^0.4.15;

// import "./VotingManager.sol";
import "./AuthAdmin.sol";
import "./SingleTokenCoin.sol";

contract VotingContract {
    
    using SafeMath for uint256;
    
    uint256 public time_voting_begins;
    uint256 public time_voting_ends;
    
    uint256 public vote01accepted;
    uint256 public vote01declined;

    mapping (address => uint256) vote01;

    AuthAdmin authAdmin;
    SingleTokenCoin token;
    
    function VotingContract(
        uint256 _time_voting_begins,
        uint256 _time_voting_ends,
        address symm_token_address
    ) {
        require (_time_voting_begins <= _time_voting_ends);
        time_voting_begins = _time_voting_begins;
        time_voting_ends = _time_voting_ends;
        token = SingleTokenCoin(symm_token_address);
    }

    function voteOne(bool vote) {
        require (now > time_voting_begins && now < time_voting_ends);
        
        uint256 voteWeight = token.balanceOf(msg.sender);
        require (voteWeight != 0);

        uint256 existingVote = vote01[msg.sender];
        uint256 newVote = vote ? 1 : 2;
        if (newVote == existingVote)
            return;
            
        vote01[msg.sender] = newVote;
        if (existingVote == 1)
            vote01accepted -= voteWeight;
        else if (existingVote == 2)
            vote01declined -= voteWeight;
        if (vote)
            vote01accepted += voteWeight;
        else
            vote01declined += voteWeight;
    }

}