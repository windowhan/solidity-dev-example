# VotingSystem 예제

`VotingSystem.sol`은 특정 주소(투표자)만 투표할 수 있고, 배포자만이 안건을 등록할 수 있는 간단한 투표 컨트랙트입니다.

* 안건은 생성 후 5분 동안 투표 가능
* 이후 `finalize` 호출로 결과 확정

## 테스트 실행
```bash
forge test -C voting-system-example -vvvv
``` 