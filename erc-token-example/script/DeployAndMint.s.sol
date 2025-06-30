// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../src/MyERC20.sol";
import "../src/MyERC721.sol";

/// @dev 실행 예: `forge script script/DeployAndMint.s.sol:DeployAndMint --fork-url http://localhost:8545 --broadcast -vvvv`
/// PRIVATE_KEY, RECEIVER 환경변수를 설정해야 한다.
contract DeployAndMint is Script {
    function run() external {
        uint256 deployerKey = vm.envUint("PRIVATE_KEY");
        address receiver = vm.envAddress("RECEIVER");

        vm.startBroadcast(deployerKey);

        // ERC20 배포 및 충전
        MyERC20 token20 = new MyERC20(1_000_000 ether);
        token20.transfer(receiver, 1_000 ether);

        // ERC721 배포 및 민트
        MyERC721 token721 = new MyERC721();
        token721.mint(receiver);

        vm.stopBroadcast();
    }
} 