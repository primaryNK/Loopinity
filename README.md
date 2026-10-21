# Loopinity Website

Loopinity 인디게임 스튜디오를 위한 반응형 원페이지 웹사이트입니다. Node.js 내장 HTTP 서버로 동작하며 별도 npm 패키지가 필요하지 않습니다.

## GitHub Pages 배포

`main` 브랜치에 변경 사항을 푸시하면 `.github/workflows/pages.yml`이 `public` 폴더를 GitHub Pages에 자동 배포합니다.

저장소를 처음 만든 뒤 GitHub의 **Settings → Pages → Build and deployment → Source**에서 **GitHub Actions**를 선택하세요. 이후 Actions의 `Deploy website to GitHub Pages` 작업이 완료되면 저장소의 Pages 주소에서 사이트를 확인할 수 있습니다.

정적 파일 경로는 프로젝트형 Pages 주소(`https://사용자명.github.io/저장소명/`)에서도 동작하도록 상대 경로로 구성되어 있습니다.

## Docker로 실행

Docker Desktop이 실행 중인 상태에서 프로젝트 폴더에서 다음 명령을 실행합니다.

```bash
docker compose up --build -d
```

브라우저에서 <http://localhost:3000>을 엽니다.

```bash
# 상태 확인
docker compose ps

# 실시간 로그
docker compose logs -f web

# 종료
docker compose down
```

## 도메인 없이 외부에 공개하기

Windows에서 [start-public.bat](start-public.bat)을 더블클릭하면 다음 작업을 자동으로 수행합니다.

1. 웹 컨테이너 빌드 및 실행
2. 웹 서버 상태 확인
3. Cloudflare Quick Tunnel 백그라운드 실행
4. 임시 `https://...trycloudflare.com` 주소 표시 및 클립보드 복사

명령 프롬프트에서는 다음처럼 실행할 수도 있습니다.

```bat
start-public.bat
```

표시된 창을 닫아도 Docker 컨테이너는 계속 실행됩니다. 같은 파일을 다시 실행하면 새 Tunnel을 만들지 않고 현재 주소를 다시 보여줍니다.

시작 파일은 과거 버전에서 생성된 고정 이름의 `loopinity-web` 컨테이너가 남아 있으면 자동으로 제거합니다. Compose 프로젝트명은 `loopinity`로 고정되어 있으므로 폴더 이름을 변경하거나 복사해도 컨테이너 이름 충돌이 발생하지 않습니다.

외부 공개와 웹 서버를 모두 종료하려면 [stop-public.bat](stop-public.bat)을 더블클릭하거나 다음 명령을 실행합니다.

```bat
stop-public.bat
```

Quick Tunnel 주소는 영구 주소가 아니며 Tunnel 컨테이너를 새로 만들면 변경됩니다. 테스트와 시연 용도로 사용하세요. 운영용 고정 주소가 필요하면 소유한 도메인과 Cloudflare Named Tunnel을 사용해야 합니다.

처음 수동으로 실행했던 `docker run --rm cloudflare/cloudflared...` 명령이 아직 열려 있다면 해당 창에서 `Ctrl+C`로 먼저 종료한 다음 배치 파일을 사용하세요.

코드를 수정한 뒤에는 아래 명령으로 이미지를 다시 빌드합니다.

```bash
docker compose up --build -d
```

## Docker 명령만 사용하기

Compose 없이도 실행할 수 있습니다.

```bash
docker build -t loopinity-web .
docker run --name loopinity-web -p 3000:3000 -d loopinity-web
```

중지 및 컨테이너 제거:

```bash
docker stop loopinity-web
docker rm loopinity-web
```

## 로컬 Node.js로 실행

Node.js 20 이상이 필요합니다.

```bash
npm start
```

개발 중 파일 변경 시 서버를 자동 재시작하려면:

```bash
npm run dev
```

테스트 실행:

```bash
npm test
```

## 수정 위치

- 페이지 구성과 문구: `public/index.html`
- 스타일과 반응형 레이아웃: `public/styles.css`
- 한국어/영어/일본어 번역과 애니메이션: `public/script.js`
- 첫 화면 이미지: `public/assets/loopinity-hero.png`
- 서버 설정: `server.js`

현재 이메일 주소(`hello@loopinity.games`)와 개인정보처리방침 링크는 예시입니다. 실제 공개 전 회사 연락처와 정책 페이지로 교체하세요.
