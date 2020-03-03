pragma solidity ^0.5.10;
import "./Roles.sol";
import "./../voting/Voting.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/EnumerableSet.sol";


/**
 * @title Democracy
 * @author Alberto Cuesta Canada
 * @notice Implements a voting-based structure for Roles
 */
contract Democracy is Roles, Renounceable {
    event Proposal(address proposal);

    bytes32 public constant LEADER_ROLE_ID = "LEADER";
    bytes32 public constant VOTER_ROLE_ID = "VOTER";

    EnumerableSet.AddressSet internal proposals;
    IERC20 public votingToken;
    uint256 public threshold;

    /// @dev Create a leader and a voter roles, and add `root` to the voter role.
    constructor (address _root, address _votingToken, uint256 _threshold)
        public
    {
        _addRole(LEADER_ROLE_ID);
        _addRole(VOTER_ROLE_ID);
        _addMember(_root, VOTER_ROLE_ID);
        votingToken = IERC20(_votingToken);
        threshold = _threshold;
    }

    /// @dev Restricted to members of the leader role.
    modifier onlyLeader() {
        require(isLeader(msg.sender), "Restricted to leaders.");
        _;
    }

    /// @dev Restricted to members of the voter role.
    modifier onlyVoter() {
        require(isVoter(msg.sender), "Restricted to voters.");
        _;
    }

    /// @dev Restricted to proposals. Same proposal cannot be used twice.
    modifier onlyProposal() {
        require(proposals.contains(msg.sender), "Restricted to proposals.");
        _;
        proposals.remove(msg.sender);
    }

    /// @dev Return `true` if the account belongs to the leader role.
    function isLeader(address account) public view returns (bool) {
        return hasRole(account, LEADER_ROLE_ID);
    }

    /// @dev Return `true` if the account belongs to the voter role.
    function isVoter(address account) public view returns (bool) {
        return hasRole(account, VOTER_ROLE_ID);
    }

    /// @dev Add an account to the voter role. Restricted to proposals.
    function addVoter(address account) public onlyProposal {
        _addMember(account, VOTER_ROLE_ID);
    }

    /// @dev Add an account to the leader role. Restricted to proposals.
    function addLeader(address account) public onlyProposal {
        _addMember(account, LEADER_ROLE_ID);
    }

    /// @dev Remove an account from the voter role. Restricted to proposals.
    function removeVoter(address account) public onlyProposal {
        _removeMember(account, VOTER_ROLE_ID);
    }

    /// @dev Remove an account from the leader role. Restricted to proposals.
    function removeLeader(address account) public onlyProposal {
        _removeMember(account, LEADER_ROLE_ID);
    }

    /// @dev Remove oneself from the leader role.
    function renounceLeader() public {
        renounceMembership(LEADER_ROLE_ID);
    }

    /// @dev Remove oneself from the voter role.
    function renounceVoter() public {
        renounceMembership(VOTER_ROLE_ID);
    }

    /// @dev Propose a democratic action.
    /// @param proposalData The abi encoding of the proposal, as one function of this contract and any parameters.
    function propose(
        bytes[] proposalData
    ) public onlyVoter {
        Voting voting = new Voting(
            votingToken,
            address(this),
            proposalData,
            threshold
        );
        proposals.add(address(voting));
        emit Proposal(address(voting));
    }
}
