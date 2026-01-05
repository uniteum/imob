# IMob Interface

Solidity interface for the Mob multisig wallet protocol.

## Overview

IMob defines the complete public API for Mob, a lightweight multisig wallet using weighted voting. This interface enables integration with Mob instances without depending on the implementation.

## Core Concepts

- **Voter** - Address authorized to vote on actions
- **Sway** - Voting weight assigned to each voter
- **Asksway** - Minimum sway required to propose actions
- **Quorum** - Minimum vote tally required to execute actions
- **Actsway** - Per-action minimum sway required to execute
- **Action** - Proposal consisting of `(nonce, actsway, to, eth, data)`
- **Action Hash** - `keccak256(abi.encode(action))` uniquely identifying each proposal
- **Tally** - Accumulated votes for a specific action (changeable until execution)

## Three-Step Process

Mob uses a simple **Ask → Vote → Act** flow:

1. **Ask** - Propose an action (requires `sway >= asksway`)
2. **Vote** - Allocate voting weight to an action (changeable until execution)
3. **Act** - Execute when `tally >= quorum` and `caller.sway >= actsway`

## Functions

### Factory

```solidity
function make(
    uint256 variant,
    uint256 asksway,
    uint256 quorum,
    address[] calldata voters,
    uint256[] calldata sways
) external returns (IMob mob)
```

Creates a new Mob instance with deterministic address based on all parameters.

**Parameters:**
- `variant` - Version or configuration identifier
- `asksway` - Minimum sway needed to propose actions
- `quorum` - Minimum tally needed to execute actions
- `voters` - Array of voter addresses
- `sways` - Corresponding voting weights

**Returns:** Address of the deployed Mob instance

```solidity
function made(
    uint256 variant,
    uint256 asksway,
    uint256 quorum,
    address[] calldata voters,
    uint256[] calldata sways
) external view returns (address location, bytes32 salt)
```

Computes the deterministic address and salt for a Mob configuration without deploying.

### Core Operations

```solidity
function ask(
    uint256 nonce,
    uint256 actsway,
    address to,
    uint256 eth,
    bytes calldata data
) external returns (bytes32 h)
```

Propose an action. Caller must have `sway >= asksway`. Returns action hash.

**Parameters:**
- `nonce` - Uniqueness parameter (different nonces create different action hashes)
- `actsway` - Minimum sway required to execute this action
- `to` - Target address for the call
- `eth` - Amount of ETH to send
- `data` - Call data to send

```solidity
function vote(bytes32 h, uint256 amount) external
```

Allocate voting weight to an action. Caller must be a voter. Amount capped at caller's sway. **Vote can be changed anytime before execution.**

```solidity
function act(bytes32 h) external
```

Execute an action. Requires `tally[h] >= quorum` and `caller.sway >= action.actsway`.

### State Queries

```solidity
function variant() external returns (uint256)
function asksway() external returns (uint256)
function quorum() external returns (uint256)
function size() external returns (uint256)
function voter(uint256 index) external returns (address)
function sway(address voter) external returns (uint256)
function tally(bytes32 h) external returns (uint256)
function votes(bytes32 h, address voter) external returns (uint256)
function acted(bytes32 h) external returns (bool)
```

```solidity
function action(bytes32 h) external returns (
    uint256 nonce,
    uint256 actsway,
    address to,
    uint256 eth,
    bytes memory data
)
```

## Events

```solidity
event Make(IMob indexed mob, uint256 variant, uint256 quorum, uint256 size)
```

Emitted when a new Mob instance is created.

```solidity
event Asked(bytes32 indexed h, address indexed asker, address indexed to, uint256 actsway)
```

Emitted when an action is proposed.

```solidity
event Voted(bytes32 indexed h, address indexed voter, uint256 amount, uint256 tally)
```

Emitted when a voter allocates or changes their vote.

```solidity
event Acted(bytes32 indexed h, address indexed actor, address indexed to)
```

Emitted when an action is executed.

## Errors

```solidity
error MobInitialized()
```

Mob instance already initialized (cannot reinitialize).

```solidity
error VoterNeedsSway(address voter)
```

Caller is not a voter (has no sway).

```solidity
error AskNeedsSway(bytes32 h, address voter, uint256 sway, uint256 asksway)
```

Caller lacks sufficient sway to propose actions.

```solidity
error ActNeedsSway(bytes32 h, address voter, uint256 sway, uint256 actsway)
```

Caller lacks sufficient sway to execute the action.

```solidity
error ActNeedsQuorum(bytes32 h, address voter, uint256 tally, uint256 quorum)
```

Action tally below quorum threshold.

```solidity
error ActComplete(bytes32 h, address voter)
```

Action already executed.

```solidity
error ActFailed(bytes32 h)
```

External call failed during execution.

```solidity
error LengthMismatch(uint256 voters, uint256 sways)
```

Voters and sways arrays have different lengths.

```solidity
error QuorumImpossible(uint256 totalSway, uint256 quorum)
```

Quorum exceeds total available sway.

```solidity
error VoterNeeded()
```

Voters array is empty.

## Example Usage

```solidity
import {IMob} from "./IMob.sol";

// Connect to existing Mob
IMob mob = IMob(mobAddress);

// Propose a token transfer
bytes memory callData = abi.encodeWithSelector(
    IERC20.transfer.selector,
    recipient,
    1000e18
);

bytes32 h = mob.ask(
    1,              // nonce
    1,              // actsway
    tokenAddress,   // to
    0,              // eth
    callData        // data
);

// Vote on the action
mob.vote(h, 5);  // Vote with 5 sway

// Change vote later
mob.vote(h, 3);  // Reduce to 3 sway

// Execute when ready
if (mob.tally(h) >= mob.quorum()) {
    mob.act(h);
}
```

## License

MIT

## Version

Solidity ^0.8.30
