# PiggyBank 예제

`PiggyBank.sol`은 입금자별 잔액을 추적하여 본인이 입금한 만큼만 출금하도록 하는 간단한 저금통 스마트 컨트랙트입니다.

## 실행 방법
1. 테스트 실행
```bash
forge test -C piggybank-example -vvvv
```

2. 배포 예시
```bash
forge create PiggyBank --rpc-url http://localhost:8545 --private-key <PRIVATE_KEY>
``` 