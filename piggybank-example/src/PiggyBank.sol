// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title PiggyBank - 개인 저금통 예제
/// @notice 입금자는 본인이 입금한 만큼만 출금할 수 있다.
contract PiggyBank {
    mapping(address => uint256) public balances;

    /// @notice 입금 함수 (ETH)
    function deposit() external payable {
        require(msg.value > 0, "zero value");
        balances[msg.sender] += msg.value;
    }

    /// @notice 본인 잔액 중 `amount` 만큼 출금
    function withdraw(uint256 amount) external {
        require(balances[msg.sender] >= amount, "insufficient balance");
        balances[msg.sender] -= amount;
        payable(msg.sender).transfer(amount);
    }

    /// @notice 컨트랙트 전체 ETH 잔액 반환 (view 용도)
    function contractBalance() external view returns (uint256) {
        return address(this).balance;
    }
} 