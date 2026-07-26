# CoachOS mRelay Android

Android utility for capturing Garmin Connect activity page text and copying it into a CoachOS mRelay prompt payload.

## Run

1. Open this folder in Android Studio:
   `/Users/perryliu/Documents/GitHub/CoachOS/mrelay-android`
2. Let Android Studio sync Gradle.
3. Select the running emulator.
4. Press Run.

## Install Debug APK On A Phone

Build the APK:

```bash
JAVA_HOME="/Applications/Android Studio.app/Contents/jbr/Contents/Home" \
ANDROID_HOME="$HOME/Library/Android/sdk" \
/tmp/gradle-9.6.1/bin/gradle --no-daemon assembleDebug
```

Install through USB:

```bash
~/Library/Android/sdk/platform-tools/adb install -r app/build/outputs/apk/debug/app-debug.apk
```

Packaged debug APK:

```text
releases/CoachOS-mRelay-Android-v0.3.0-debug.apk
```

## Practical Flow

1. The app opens Garmin Connect activities in an Android WebView.
2. Sign in if Garmin asks.
3. Open a running activity.
4. Wait until the data is visible.
5. Tap `一鍵擷取並複製`.
6. The app captures the summary page, switches to `間歇訓練` or `計圈`, waits for the table, then copies the merged payload.
7. Use `預覽` to inspect the payload, or `分享` to send it to another app.
8. Paste the clipboard content into ChatGPT, Claude, Gemini, or CoachOS.

If Garmin changes the tab UI, use the manual fallback: tap `存數據分頁`, switch to `間歇訓練` or `計圈`, then tap `存第二頁並複製`.

## Controls

- `開 Garmin`: reload Garmin Connect activities.
- `清除`: reset the captured summary page and latest payload.
- `返回`: go back inside the WebView.
- `一鍵擷取並複製`: capture summary and interval/lap pages automatically, then copy the merged payload.
- `存數據分頁`: capture the current Garmin activity summary page.
- `存第二頁並複製`: capture the current split/interval page and copy the merged CoachOS payload.
- `預覽`: inspect the latest payload.
- `分享`: open Android share sheet for the latest payload.

This prototype does not store Garmin account, password, cookies, or tokens in app code.
