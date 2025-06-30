// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title VotingSystem - 간단한 온체인 투표 컨트랙트 예제
contract VotingSystem {
    struct Proposal {
        uint256 id;
        string description;
        uint256 startTime;
        uint256 forVotes;
        uint256 againstVotes;
        bool finalized;
    }

    // id => Proposal
    mapping(uint256 => Proposal) public proposals;
    uint256 public proposalCount;

    // voter address -> true/false
    mapping(address => bool) public voters;
    // proposal id -> voter -> voted 여부
    mapping(uint256 => mapping(address => bool)) public hasVoted;

    address public owner;

    constructor(address[] memory _voters) {
        owner = msg.sender;
        for (uint256 i = 0; i < _voters.length; i++) {
            voters[_voters[i]] = true;
        }
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "not owner");
        _;
    }

    modifier onlyVoter() {
        require(voters[msg.sender], "not voter");
        _;
    }

    /// @notice 새 안건 추가 (배포자만)
    function addProposal(string memory description) external onlyOwner returns (uint256) {
        uint256 id = ++proposalCount;
        proposals[id] = Proposal({
            id: id,
            description: description,
            startTime: block.timestamp,
            forVotes: 0,
            againstVotes: 0,
            finalized: false
        });
        return id;
    }

    /// @notice 안건에 대해 투표 (찬성/반대)
    function vote(uint256 id, bool support) external onlyVoter {
        Proposal storage p = proposals[id];
        require(p.startTime != 0, "proposal not found");
        require(block.timestamp <= p.startTime + 5 minutes, "voting period ended");
        require(!hasVoted[id][msg.sender], "already voted");

        hasVoted[id][msg.sender] = true;
        if (support) {
            p.forVotes += 1;
        } else {
            p.againstVotes += 1;
        }
    }

    /// @notice 5분이 지난 뒤 결과를 확정
    function finalize(uint256 id) external {
        Proposal storage p = proposals[id];
        require(p.startTime != 0, "proposal not found");
        require(block.timestamp >= p.startTime + 5 minutes, "too early");
        require(!p.finalized, "already finalized");
        p.finalized = true;
    }

    /// @notice 최종 통과 여부 조회 (finalize 이후)
    function isPassed(uint256 id) external view returns (bool) {
        Proposal storage p = proposals[id];
        require(p.finalized, "not finalized");
        return p.forVotes > p.againstVotes;
    }
} 