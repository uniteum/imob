// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

interface IMob {
    error AskNeedsSway(bytes32 h, address voter, uint256 sway, uint256 asksway);
    error ActNeedsSway(bytes32 h, address voter, uint256 sway, uint256 actsway);
    error ActNeedsQuorum(bytes32 h, address voter, uint256 tally, uint256 quorum);
    error ActComplete(bytes32 h, address voter);
    error ActFailed(bytes32 h);
    error LengthMismatch(uint256 voters, uint256 sways);
    error QuorumImpossible(uint256 totalSway, uint256 quorum);
    error VoterNeeded();
    error VoterNeedsSway(address voter);
    error MobInitialized();

    event Asked(bytes32 indexed h, address indexed asker, address indexed to, uint256 actsway);
    event Voted(bytes32 indexed h, address indexed voter, uint256 amount, uint256 tally);
    event Acted(bytes32 indexed h, address indexed actor, address indexed to);
    event Make(IMob indexed mob, uint256 variant, uint256 quorum, uint256 size);

    function variant() external returns (uint256);
    function asksway() external returns (uint256);
    function quorum() external returns (uint256);
    function size() external returns (uint256);
    function voter(uint256 index) external returns (address);
    function sway(address voter) external returns (uint256);
    function tally(bytes32 h) external returns (uint256);
    function action(bytes32 h)
        external
        returns (uint256 nonce, uint256 actsway, address to, uint256 eth, bytes memory data);
    function acted(bytes32 h) external returns (bool);
    function votes(bytes32 h, address voter) external returns (uint256);
    function ask(uint256 nonce, uint256 actsway, address to, uint256 eth, bytes calldata data)
        external
        returns (bytes32 h);
    function vote(bytes32 h, uint256 amount) external;
    function act(bytes32 h) external;
    function made(uint256 variant, uint256 asksway, uint256 quorum, address[] calldata voters, uint256[] calldata sways)
        external
        view
        returns (address location, bytes32 salt);
    function make(uint256 variant, uint256 asksway, uint256 quorum, address[] calldata voters, uint256[] calldata sways)
        external
        returns (IMob mob);
}
