# MultiSigWallet 예제

`MultiSigWallet.sol`은 오프체인 ECDSA 서명을 사용하여 찬반을 기록하고, 찬성 수가 `required` 이상이 되면 자동으로 트랜잭션을 실행하는 간단한 멀티시그 월렛 예제입니다.

메시지 다이제스트 포맷: `keccak256(abi.encodePacked(id, to, value, data))`

## 테스트/사용 예시
1. 로컬 테스트넷 실행
```bash
anvil -p 8545
```

2. 컨트랙트 배포 (예: 2-of-3 멀티시그)
```bash
forge create MultiSigWallet \
  --constructor-args "[<VOTER1>,<VOTER2>,<VOTER3>]" 2 \
  --rpc-url http://localhost:8545 \
  --private-key <OWNER_KEY>
```

3. 서명 생성 예시는 Foundry Cheatcode `vm.sign` 참조:
https://book.getfoundry.sh/cheatcodes/sign 