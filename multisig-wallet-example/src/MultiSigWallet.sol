// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title MultiSigWallet - 오프체인 서명을 이용한 간단한 멀티시그 월렛 예제
contract MultiSigWallet {
    struct Transaction {
        uint256 id;
        address to;
        uint256 value;
        bytes data;
        uint256 yesVotes;
        uint256 noVotes;
        bool executed;
    }

    mapping(uint256 => Transaction) public transactions;
    uint256 public txCount;

    mapping(address => bool) public voters;
    mapping(uint256 => mapping(address => bool)) public hasVoted;

    uint256 public required; // 필요한 찬성 수
    address public owner;

    event Submit(uint256 indexed id, address indexed to, uint256 value, bytes data);
    event Execute(uint256 indexed id);

    constructor(address[] memory _voters, uint256 _required) {
        require(_voters.length >= _required && _required > 0, "invalid required");
        owner = msg.sender;
        required = _required;
        for (uint256 i = 0; i < _voters.length; i++) {
            voters[_voters[i]] = true;
        }
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "not owner");
        _;
    }

    /// @notice 트랜잭션 제안(배포자 전용)
    function submit(address to, uint256 value, bytes calldata data) external onlyOwner returns (uint256) {
        uint256 id = ++txCount;
        transactions[id] = Transaction({
            id: id,
            to: to,
            value: value,
            data: data,
            yesVotes: 0,
            noVotes: 0,
            executed: false
        });
        emit Submit(id, to, value, data);
        return id;
    }

    /// @notice 투표 (오프체인 서명 검증)
    /// @param id       제안된 트랜잭션 ID
    /// @param approve  찬성 여부
    /// @param sig      ECDSA 서명 (keccak256(abi.encodePacked(id, to, value, data)))
    function vote(uint256 id, bool approve, bytes calldata sig) external {
        Transaction storage tx_ = transactions[id];
        require(tx_.to != address(0), "tx not found");
        require(voters[msg.sender], "not voter");
        require(!hasVoted[id][msg.sender], "already voted");

        // 메시지 다이제스트 생성 규격: keccak256(abi.encodePacked(id, to, value, data))
        bytes32 digest = keccak256(abi.encodePacked(id, tx_.to, tx_.value, tx_.data));
        (bytes32 r, bytes32 s, uint8 v) = _split(sig);
        address recovered = ecrecover(digest, v, r, s);
        require(recovered == msg.sender, "invalid signature");

        hasVoted[id][msg.sender] = true;
        if (approve) {
            tx_.yesVotes += 1;
            if (tx_.yesVotes >= required && !tx_.executed) {
                _execute(id);
            }
        } else {
            tx_.noVotes += 1;
        }
    }

    /// @dev 내부 실행 함수(찬성 수 임계치 달성 시 호출)
    function _execute(uint256 id) internal {
        Transaction storage tx_ = transactions[id];
        require(!tx_.executed, "already executed");
        tx_.executed = true;
        (bool success, ) = tx_.to.call{value: tx_.value}(tx_.data);
        require(success, "tx failed");
        emit Execute(id);
    }

    /// @notice 서명 분할 헬퍼
    function _split(bytes memory sig) internal pure returns (bytes32 r, bytes32 s, uint8 v) {
        require(sig.length == 65, "invalid signature length");
        assembly {
            r := mload(add(sig, 32))
            s := mload(add(sig, 64))
            v := byte(0, mload(add(sig, 96)))
        }
    }

    receive() external payable {}
} 