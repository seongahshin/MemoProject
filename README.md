# 메모앱

| 앱 이름 | 메모앱 |
| --- | --- |
| 진행 기간 | 2022년 8월 31일 ~ 2022년 9월 5일 (5일) |
| 앱 소개 | 메모를 작성, 저장, 고정, 검색하는 기능이 담긴 앱 |
|  앱 기능 | 메모 작성 기능, 메모 고정 기능, 제목 및 내용 기반 메모 검색 기능 |
| 디자인 패턴 | MVC |
| 화면 | UIKit, SnapKit, AutoLayout |
| 데이터베이스 | Realm |
| 라이브러리 | IQKeyboardManager, Toast |

### *⚒ 앱 스크린샷*
<img width="980" alt="스크린샷 2023-01-05 오후 2 45 50" src="https://user-images.githubusercontent.com/90595710/211744664-82753255-a020-4f65-b80f-29fc4539767a.png">

### *🎯 기술 명세*

- `SnapKit` 을 활용하여 코드 베이스로 `Auto Layout` 구현
- `UserDefaults` 를 활용해 최초 앱 실행시에만 온보딩 화면 보여주도록 구현
- `Realm` 을 활용해 `CRUD/정렬` 기능 구현
- `Realm`의 `Filter` 기능을 이용해 메모 검색 기능 구현
- `UISwipeActionsConfiguration` 을 활용해 메모 고정 및 삭제 기능 구현
- `UIActivityViewController` 를 통해 메모 공유 기능 구현
