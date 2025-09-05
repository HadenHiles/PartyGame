# Flutter Party Game — Copilot Step‑By‑Step Plan

## High Level Gameplay

The plan is to have 1-3 rounds of "word play" style games based on user input. Each round consists of a player input phase, and then a vs./voting phase with a scoring mechanism and leaderboard between rounds. Round 1: - 90 second timer on primary device (TV) screen - Every player is prompted on their device to write two sentences (one after another), with the ability to easily insert one to two "blank spaces" in the sentence where others can insert their own words later on. - 60 second fill in the blank phase - Each player is given 2 random sentences to fill in the blanks (not their own, fill in one after another) - Voting/VS phase - Players with the same sentence are pitted against each other (1v1) and the other players vote for their favorite mashup using their devices. Winner takes the crown (and the loser gets smashed, gladiator style!) Round 2 (similar to round 1): - 45 second timer - Every player is prompted to enter as many random words as the can before time runs out (these words will be used as "cards" that will be used by other players later on in the round) - 60 second timer - (this step could get more complicated) Every player is given an AI written sentence with 2-3 fill in the blanks and 5-8 word cards to choose from to fill in each blank. The ai sentences should use the user generated sentences from round 1 as a theme, but always be coherent and tell some sort of mini-story (kind of like mad-libs if you remember those). For this phase, the user should be able to pick between 2 ai sentences. - Voting/VS. - same as round 1, players are pitted against each other gladiator style Round 3 (putting it all together): - 90 second timer - players are all given 2 finalized sentences from one of the previous rounds, that they can now edit by changing the blank space values, or by adding to the beginning and/or end of the sentence. Visuals should make it clear what components can be modified. - Gold, silver, bronze, voting system (weighted scoring) - Players final chosen sentence is pitted up against the other players, and everyone votes for their gold, silver, and bronze Final Scores: Show the final scores, and the victorious player with confetti etc. Between each round it should show the updated leaderboard.

## Progress Checklist

Legend: [x] done • [ ] pending • [~] in progress

- Pre‑flight

  - [x] Target platforms limited to Web, iOS, Android (removed desktop folders)
  - [x] App IDs updated to `com.hadenhiles.partygames` (Android namespace/applicationId, iOS bundle IDs)
  - [x] Clean scaffold: GoRouter + theme + basic host/player screens
  - [x] Firebase configured via FlutterFire (web/iOS/Android) and initialized at startup
  - [x] Add firebase_auth and anonymous auth bootstrap
  - [x] Neon animated background on core screens (Join, Host Lobby, Waiting, Host Round, R1 Author)
  - [x] Confetti overlay integrated (Host start, Author submit)
  - [ ] Emulator + Hosting wiring (serve web, functions)

- 1. Initialize project & packages

  - [x] Add packages: firebase_core, cloud_firestore, go_router, qr_flutter
  - [~] Add packages: firebase_auth, audioplayers, confetti, uuid, collection (firebase_auth, confetti added)
  - [ ] Add `.env.example` and simple `lib/env.dart`
  - [ ] Functions project (TypeScript) + Hosting rewrites

- 2. File tree scaffold

  - [x] `lib/routing/app_router.dart`
  - [x] `lib/theme/app_theme.dart`
  - [x] `lib/models/{room.dart, player.dart, phase.dart}`
  - [x] `lib/services/{firebase_service.dart, room_service.dart}` (room service in‑memory for now)
  - [x] `lib/screens/host/host_lobby_screen.dart`
  - [x] `lib/screens/player/{join_screen.dart, player_waiting_screen.dart}`
  - [ ] Remaining screens and services from the tree (R1/R2/R3, widgets, etc.)

- 3. Data model (Firestore)

  - [ ] Define full Firestore collection schemas and serializers

- 4. Security rules

  - [ ] Lock down writes (players self‑writes only; phases/scores via Functions)

- 5. Cloud Functions — core game flow

  - [ ] Implement callable functions (createRoom, joinRoom, advancePhase, submit/vote/tally)

- 6. Pairing & scoring helpers

  - [ ] Shared helpers in Functions + mirrored Dart versions with tests

- 7. AI sentence service

  - [ ] Mock + remote stub providers

- 8. Audio & visual flair

  - [~] Confetti overlay wired in Host/Author screens; Audio assets + `audio_service.dart` pending

- 9. Host & player flows — UI

  - [~] Implement host/player screens and routing per roadmap
    - [x] host_lobby_screen.dart (room code, players list, start button)
    - [~] host_round_screen.dart (placeholder layout; timer/VS pending)
    - [x] player/join_screen.dart (polished UI)
    - [x] player/player_waiting_screen.dart (auto-route on phase)
    - [~] player/r1_author_screen.dart (UI + confetti; submit logic pending)

- 10. Timers & phase sync

  - [ ] Read‑only timers from Firestore; host advance

- 11. Voting & fairness

  - [ ] Enforce voting constraints client + server side

- 12. Leaderboard & scoring

  - [ ] Aggregate and animate standings

- 13. Routing glue & environment toggles

  - [ ] App routes and dev debug controls

- 14. Tests (Dart & Functions)

  - [ ] Unit tests for pairing, scoring, validation (Dart + Functions)

- 15. Deploy scripts & local dev

  - [ ] Emulators, deploy scripts, hosting rewrites

- 16. AI Powered TTS Game Host
  - [ ] Follow instructions from https://dev.to/noahvelasco/amplify-your-flutter-apps-with-elevenlabs-tts-api-a-simple-guide-5147 to implement an awesome game host voice
  - [ ] Automate "script" for AI Host to read/speak at key points of the game (time running out, calling out players jumping up the leaderboard, quipy one liners to keep players who have completed their phase from getting bored while waiting for others)

— The remaining detailed steps (16–25) remain pending and will be checked off as implemented.

> A detailed, paste‑ready sequence of Copilot/GPT‑5 prompts to scaffold and implement a Jackbox‑style, multi‑device party game in Flutter + Firebase. Host (TV) runs the **Host app screen**, players join from phones via web or app.

0. Overview & Assumptions (read first)

---

- **Stack:** Flutter (web/mobile/desktop), Firebase (Auth Anonymous, Firestore, Functions, Hosting), optional Cloud Run for AI.
- **Net model:** Server‑authoritative phases. Clients write only their own inputs; Functions validate, pair, tally, and advance phases.
- **Room model:** Short alphanumeric **roomCode** (e.g., 4–6 chars), one **host** device, N **players** (2–12 recommended).
- **Sync:** Host starts/advances rounds → Cloud Function writes phase, phaseStartAt, phaseEndsAt. Clients render timers from server timestamps.
- **Rounds:**

  1.  **Sentence → Fill → VS Voting**
  2.  **Word cards → AI sentence fill → VS Voting**
  3.  **Final remix → Weighted (gold/silver/bronze) voting**

- **Design:** Fun, minimal, readable at TV distance. Bright palettes, chunky typography.
- **Audio:** audioplayers for SFX/music. confetti for victory moments.

> **Copilot rule of thumb:** For each step below, copy the exact prompt into Copilot. If Copilot hesitates, paste the file tree + requirements again and say “produce complete files, no ellipses.”

1. Initialize project & packages

---

**Copilot Prompt:**

> Set up a Flutter project (if not already) with web+mobile targets and add Firebase. Then add these packages and configs. Provide exact commands and code files.
>
> **Requirements:**
>
> - Firebase core setup (anonymous auth), Firestore, Cloud Functions (TypeScript). Hosting for both host+player web builds.
> - Flutter packages: cloud_firestore, firebase_core, firebase_auth, go_router, audioplayers, confetti, qr_flutter, uuid, collection.
> - Add a .env.example and lib/env.dart loader (simple consts for now).
> - Create firebase.json, firebaserc, boilerplate Functions project.
> - Output: commands (flutterfire configure, firebase init), updated pubspec.yaml, web/index.html meta tags, and platform setup notes.

2. File tree scaffold

---

**Copilot Prompt:**

> Create the following file tree with complete stub files and TODOs at the top of each file. Ensure imports compile.

Plain textANTLR4BashCC#CSSCoffeeScriptCMakeDartDjangoDockerEJSErlangGitGoGraphQLGroovyHTMLJavaJavaScriptJSONJSXKotlinLaTeXLessLuaMakefileMarkdownMATLABMarkupObjective-CPerlPHPPowerShell.propertiesProtocol BuffersPythonRRubySass (Sass)Sass (Scss)SchemeSQLShellSwiftSVGTSXTypeScriptWebAssemblyYAMLXML`lib/    main.dart    routing/app_router.dart    theme/app_theme.dart    services/      firebase_service.dart      room_service.dart      phase_service.dart      audio_service.dart      scoring_service.dart      pairing_service.dart      ai_sentence_service.dart   // pluggable (mock/default), later replace with real AI    models/      room.dart      player.dart      phase.dart      round_models.dart          // sentences, blanks, cards, ballots, scores    screens/      host/        host_lobby_screen.dart        host_round_screen.dart       // shows countdown, matchups, VS UI        host_leaderboard_screen.dart        host_final_scores_screen.dart      player/        join_screen.dart        player_waiting_screen.dart        r1_author_screen.dart        // author 2 sentences w/ 1–2 blanks        r1_fill_screen.dart          // fill blanks for 2 random sentences        r_voting_screen.dart         // generic voting screen (R1/R2 1v1)        r2_cards_input_screen.dart   // rapid word entry        r2_sentence_choose_screen.dart // pick among 2 AI prompts, fill with cards        r3_remix_screen.dart         // final edit with constrained regions        leaderboard_interstitial.dart    widgets/      room_code_banner.dart      timer_pill.dart      vs_battle_card.dart      vote_button.dart      podium_widget.dart      toast.dart  functions/    src/      index.ts      game.ts           // HTTPS callable + triggers      pairing.ts        // deterministic pairing helpers      scoring.ts        // scoring + tie‑break logic      ai.ts             // (optional) calls provider; mock fallback      types.ts    test/      pairing.test.ts      scoring.test.ts  test/    unit/      pairing_service_test.dart      scoring_service_test.dart`

3. Data model (Firestore)

---

**Copilot Prompt:**

> Define Firestore models and (de)serializers for the following collections. Include classes, fromMap/toMap, and JSON schema docs.
>
> **Collections:**
>
> - rooms/{roomCode}: { code, hostUid, createdAt, status: open|inGame|ended, round: 1|2|3, phase: author|fill|vote|tally|leaderboard, phaseStartAt, phaseEndsAt, maxPlayers, settings {...} }
> - rooms/{roomCode}/players/{uid}: { uid, displayName, avatar, joinedAt, isHost, isConnected, score }
> - rooms/{roomCode}/r1_sentences/{id}: { authorUid, textTemplate, blanksCount (1–2) }
> - rooms/{roomCode}/r1_fills/{id}: { baseSentenceId, fillerUid, filledText }
> - rooms/{roomCode}/r1_matchups/{id}: { baseSentenceId, aFillId, bFillId, voters: \[uids\], votes: { a: n, b: n }, winnerFillId }
> - rooms/{roomCode}/r2_cards/{uid}: { words: string\[\] }
> - rooms/{roomCode}/r2_prompts/{id}: { targetUid, optionA, optionB, chosen: 'A'|'B', cardsOffered: string\[\]\[\] }
> - rooms/{roomCode}/r2_submissions/{id}: { authorUid, basePromptId, filledText }
> - rooms/{roomCode}/r2_matchups/{id}: same structure as r1_matchups
> - rooms/{roomCode}/r3_submissions/{id}: { authorUid, baseFrom: r1|r2, baseRefId, editedText }
> - rooms/{roomCode}/ballots/{round}/{uid}: for r3 weighted voting { gold: subId, silver: subId, bronze: subId }
> - rooms/{roomCode}/scores/{uid}: { r1: n, r2: n, r3: n, total }
>
> Include copyWith, equality, and helpers for timers.

4. Security rules

---

**Copilot Prompt:**

> Write strict Firestore security rules:
>
> - Only authenticated users.
> - Players can create/update **only their** player doc and submissions tied to their uid.
> - No one can write to matchups, ballots of others, scores, or room phase fields except via Cloud Functions service account.
> - Add composite indexes as needed. Provide firestore.indexes.json and example rules_debug logging notes.

5. Cloud Functions — core game flow

---

**Copilot Prompt:**

> Implement Cloud Functions (TypeScript) for server‑authoritative flow. Provide complete code with validation.
>
> **Functions (httpsCallable):**
>
> - createRoom(maxPlayers, settings) → creates rooms/{code} with status=open; returns code + admin token for host.
> - joinRoom(code, displayName, avatar) → creates/updates player doc; ensures capacity; returns role.
> - startRound(code, roundNumber) → sets round and transitions to first phase.
> - advancePhase(code) → host‑only; moves to next phase depending on current round; sets phaseStartAt, phaseEndsAt.
> - submitR1Sentence(code, textTemplate) → validate 1–2 blanks; store.
> - submitR1Fill(code, baseSentenceId, filledText) → validate not own sentence; store.
> - buildR1Matchups(code) → pair fills per base sentence into 1v1s; ensure fairness; write r1_matchups.
> - voteR1(code, matchupId, pick) → record vote; prevent self‑vote and duplicates.
> - tallyR1(code) → compute winners, award points, write scores.
> - Similar: submitR2Cards, generateR2Prompts (uses ai.ts mock first), submitR2, buildR2Matchups, voteR2, tallyR2.
> - Round 3: submitR3Remix, voteR3Weighted, tallyR3 (gold=3, silver=2, bronze=1 default weights).
> - endGame(code) → status=ended.
>
> **Notes:** Use batched writes/transactions, server timestamps, and deterministic RNG seeds per room to make pairing reproducible.

6. Pairing & scoring helpers (shared logic)

---

**Copilot Prompt:**

> Implement pairing.ts and scoring.ts in Functions, and mirror pure Dart versions in services/. Ensure identical logic for tests. Include:
>
> - Deterministic shuffle by seed (roomCode + phaseStartAt)
> - 1v1 pairing that handles odd counts (bye or 3‑way with round‑robin mini‑vote; choose bye for v1)
> - Score allocation: R1/R2 win=+100, tie=+50 each; R3 weighted (3/2/1) normalized; carry totals.

7. AI sentence service (Round 2)

---

**Copilot Prompt:**

> Implement ai_sentence_service.dart with an interface and two providers:
>
> 1.  MockAiSentenceService — builds short coherent prompts using Round 1 themes (extract top nouns/verbs from R1 sentences) and inserts 2–3 {blank} tokens.
> 2.  RemoteAiSentenceService (stub) — calls a backend functions/ai.ts endpoint; leave TODO for provider API key.Provide fallback to mock if remote fails.

8. Audio & visual flair

---

**Copilot Prompt:**

> Add audio and confetti scaffolding.
>
> - Create folder assets/audio/ with placeholders: countdown_tick.mp3, whoosh.mp3, win_fanfare.mp3, bg_music_loop.mp3.
> - Implement audio_service.dart with preload, playSfx(name), playMusic(loop=true), stopMusic.
> - Integrate SFX: start/stop timers, VS reveal, vote tap, win splash. Integrate confetti on win and final podium.
> - Update pubspec.yaml assets.

9. Host & player flows — UI screens

---

**Copilot Prompt:**

> Implement the following UI with go_router routes and responsive layout (host vs player). Use large, high‑contrast typography for host.
>
> **Host screens**
>
> - host_lobby_screen.dart: shows room code + QR, player list, “Start Round 1” button.
> - host_round_screen.dart: shows current phase, big timer, VS cards during voting, interstitials between phases, and a mini‑leaderboard footer.
> - host_leaderboard_screen.dart: animated rank changes.
> - host_final_scores_screen.dart: podium with confetti.
>
> **Player screens**
>
> - join_screen.dart: enter room code + name; choose emoji avatar.
> - player_waiting_screen.dart: shows status; auto‑routes when phase changes.
> - **R1 author:** r1_author_screen.dart — compose 2 sentences; UI to insert 1–2 blanks (tap to add {blank} tokens); client‑side validator.
> - **R1 fill:** r1_fill_screen.dart — sequentially fill two assigned sentences (not own).
> - **Generic voting:** r_voting_screen.dart — renders a matchup with A/B choice; shows locked state after vote.
> - **R2 cards:** r2_cards_input_screen.dart — 45s rapid entry; chip list.
> - **R2 choose:** r2_sentence_choose_screen.dart — presents two AI prompts themed from R1; pick A/B then fill blanks with provided cards.
> - **R3 remix:** r3_remix_screen.dart — show base sentences; allow editing only marked regions + prefix/suffix; clear affordances.
> - leaderboard_interstitial.dart: between rounds, show ranking with SFX.
>
> Provide UI mocks with placeholder colors and ensure null‑safe code compiles.

10. Timers & phase sync

---

**Copilot Prompt:**

> Implement phase_service.dart to read phase, phaseStartAt, phaseEndsAt from Firestore and expose a stream with remaining seconds. Timer is **read‑only** client‑side; only Functions set times. Add drift tolerance and clamp at 0.
>
> - Host can call advancePhase (button), which triggers Functions to compute next phase + duration (90/60/45s etc.).
> - Play bg_music_loop softly during phases; countdown_tick for last 10s.

11. Voting & fairness rules

---

**Copilot Prompt:**

> Implement voting constraints:
>
> - Players cannot vote on their own submission or their direct opponent’s (R1/R2).
> - Enforce one vote per matchup per player.
> - If tie, award both and mark as tie.
> - For R3, weighted ballots must contain 3 distinct submissions and exclude self; validate server‑side.

12. Leaderboard & scoring

---

**Copilot Prompt:**

> Implement scoring_service.dart that aggregates room scores/{uid} and emits sorted standings with deltas for animations. Write helper to format point pop‑ups (+100, +50, etc.). Update after each tally\* function.

13. Routing glue & environment toggles

---

**Copilot Prompt:**

> Implement app_router.dart with clear paths (/host/:code, /join, /r1/author, etc.). Add query param ?role=host|player for debugging. Provide a debugControls panel (DEV only) to skip phases.

14. Tests (Dart & Functions)

---

**Copilot Prompt:**

> Write unit tests for deterministic pairing, scoring, and validation in both Dart (test/unit/...) and Functions (functions/test/...). Provide example seeds and expected outputs.
>
> - Add a test matrix for odd player counts (3,5,7).
> - Add tests for weighted R3 ballots aggregation.

15. Deploy scripts & local dev

---

**Copilot Prompt:**

> Provide scripts and docs for local emulation and deploy.
>
> - firebase emulators:start with Firestore/Functions/Hosting.
> - melos or simple makefile tasks to run host/player builds and open in browser.
> - Hosting rewrites so /host/\* and /player/\* route to Flutter web app.
> - Production deploy commands.

16. Round 1 details — logic prompts

---

**Copilot Prompt:**

> Implement Round 1 end‑to‑end.
>
> - Sentence authoring: client ensures exactly 1–2 {blank} tokens per sentence; Function re‑validates.
> - Assignment for fill: each player receives 2 random base sentences not authored by them. Implement in Functions.buildR1Assignments and write minimal per‑player assignment docs; client fetches sequentially.
> - Matchups: for each base sentence, pair two distinct fills; if only one fill exists, auto‑advance that fill as winner.
> - Voting screen: render base sentence with highlights for filled words; A/B cards; collect votes.
> - Tally: compute winners and +100 points each.

17. Round 2 details — logic prompts

---

**Copilot Prompt:**

> Implement Round 2.
>
> - Cards input: 45s; store words per user; limit duplicates.
> - AI prompts: For each player, generate **2 options** with 2–3 blanks using themes from R1. Provide 5–8 word cards to choose for each blank (prefer cards from _other players_). Player picks one option and fills blanks by tapping cards.
> - Voting same as R1; tally as R1.

18. Round 3 details — logic prompts

---

**Copilot Prompt:**

> Implement Round 3.
>
> - Give each player 2 finalized sentences (from prior winners or random finalists). Allow editing of blank values and pre/suffix only (not the locked middle). Use a diff/highlight UI.
> - Weighted voting (gold/silver/bronze = 3/2/1). Validate distinct picks and not self.
> - Tally → allocate points, update final leaderboard, confetti.

19. SFX/Music integration — template code

---

**Copilot Prompt:**

> Fill in audio_service.dart and show usage examples in 3 screens. Use audioplayers with simple helpers and ensure lifecycle safe.

Plain textANTLR4BashCC#CSSCoffeeScriptCMakeDartDjangoDockerEJSErlangGitGoGraphQLGroovyHTMLJavaJavaScriptJSONJSXKotlinLaTeXLessLuaMakefileMarkdownMATLABMarkupObjective-CPerlPHPPowerShell.propertiesProtocol BuffersPythonRRubySass (Sass)Sass (Scss)SchemeSQLShellSwiftSVGTSXTypeScriptWebAssemblyYAMLXML`// lib/services/audio_service.dart  import 'package:audioplayers/audioplayers.dart';  class AudioService {    static final AudioService _i = AudioService._();    factory AudioService() => _i;    AudioService._();    final _music = AudioPlayer()..setReleaseMode(ReleaseMode.loop);    final _sfx = AudioPlayer();    Future preload() async {      await Future.wait([        _sfx.setSource(AssetSource('audio/whoosh.mp3')),      ]);    }    Future playSfx(String asset) => _sfx.play(AssetSource('audio/$asset'));    Future playMusic(String asset) => _music.play(AssetSource('audio/$asset'));    Future stopMusic() => _music.stop();  }`

20. Confetti — template code

---

**Copilot Prompt:**

> Add confetti to host_final_scores_screen.dart using the confetti package. Show controller start on initState and stop/dispose properly.

21. UX polish & accessibility

---

**Copilot Prompt:**

> Apply a simple fun theme in app_theme.dart (big buttons, bold colors). Ensure minimum 4.5:1 contrast for text, focus states, and large tap targets (48dp). Add haptic feedback on vote taps (mobile only).

22. Edge cases & recovery

---

**Copilot Prompt:**

> Implement:
>
> - Rejoin flow: if a player disconnects, allow them to reconnect by uid in the same room.
> - Late join: block after R1 authoring ends; show spectator mode.
> - AFK handling: if player misses submissions, auto‑skip. If voter idle, don’t block tally; count quorum rule (>=60% of eligible voters).

23. Telemetry (optional)

---

**Copilot Prompt:**

> Add minimal analytics events: room_created, joined, phase_started, submitted, voted, tallied. Use logger to print in dev; (optional) wire to Analytics later.

24. README & runbook

---

**Copilot Prompt:**

> Generate a README.md that explains the architecture, local dev, emulators, deploy, and contribution guide. Include a short troubleshooting section (Flutter clean, emulator ports, CORS for Functions, etc.).

25. Verification checklist (copy into PRs)

---

- Host + 3 players flow works in emulator
- Timers synced to server timestamps
- Security rules prevent cross‑writes
- No client can alter scores/phase
- Pairing deterministic with seed
- R2 mock AI fallback works offline
- Confetti + audio trigger at correct events
- Leaderboard updates between rounds
- Final scores & podium render on TV

### Bonus: Room QR & Join URL

**Copilot Prompt:**

> Add a QR code in the host lobby with URL https:///?code=ABCD and auto‑prefill on join screen.

### Bonus: Themeable strings & localization

**Copilot Prompt:**

> Extract all on‑screen strings to a simple strings.dart with extension points for future i18n.

_End of plan._
