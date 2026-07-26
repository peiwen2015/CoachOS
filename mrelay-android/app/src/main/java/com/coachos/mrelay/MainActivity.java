package com.coachos.mrelay;

import android.annotation.SuppressLint;
import android.app.Activity;
import android.app.AlertDialog;
import android.content.ClipData;
import android.content.ClipboardManager;
import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.os.Handler;
import android.os.Looper;
import android.view.View;
import android.webkit.CookieManager;
import android.webkit.WebChromeClient;
import android.webkit.WebSettings;
import android.webkit.WebView;
import android.webkit.WebViewClient;
import android.widget.Button;
import android.widget.ScrollView;
import android.widget.TextView;
import android.widget.Toast;

public class MainActivity extends Activity {
    private static final String GARMIN_ACTIVITIES_URL = "https://connect.garmin.com/modern/activities";
    private static final int AUTO_CAPTURE_MAX_ATTEMPTS = 12;
    private static final long AUTO_CAPTURE_RETRY_MS = 900L;

    private WebView webView;
    private TextView statusText;
    private final Handler mainHandler = new Handler(Looper.getMainLooper());
    private String summaryPageText = "";
    private String summaryPageUrl = "";
    private String lastPayload = "";

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        webView = findViewById(R.id.webView);
        statusText = findViewById(R.id.statusText);
        Button openGarminButton = findViewById(R.id.openGarminButton);
        Button clearButton = findViewById(R.id.clearButton);
        Button autoCaptureButton = findViewById(R.id.autoCaptureButton);
        Button captureSummaryButton = findViewById(R.id.captureSummaryButton);
        Button captureDetailButton = findViewById(R.id.captureDetailButton);
        Button previewButton = findViewById(R.id.previewButton);
        Button shareButton = findViewById(R.id.shareButton);
        Button backButton = findViewById(R.id.backButton);
        View mainRoot = findViewById(R.id.mainRoot);

        configureWebView();
        mainRoot.setOnApplyWindowInsetsListener((view, insets) -> {
            view.setPadding(0, insets.getSystemWindowInsetTop(), 0, insets.getSystemWindowInsetBottom());
            return insets;
        });

        openGarminButton.setOnClickListener(v -> webView.loadUrl(GARMIN_ACTIVITIES_URL));
        clearButton.setOnClickListener(v -> clearCaptureState());
        autoCaptureButton.setOnClickListener(v -> captureBothPagesAndCopy());
        captureSummaryButton.setOnClickListener(v -> captureSummaryPage());
        captureDetailButton.setOnClickListener(v -> captureDetailPageAndCopy());
        previewButton.setOnClickListener(v -> showPreview());
        shareButton.setOnClickListener(v -> sharePayload());
        backButton.setOnClickListener(v -> {
            if (webView.canGoBack()) {
                webView.goBack();
            }
        });

        webView.loadUrl(GARMIN_ACTIVITIES_URL);
    }

    @SuppressLint("SetJavaScriptEnabled")
    private void configureWebView() {
        WebSettings settings = webView.getSettings();
        settings.setJavaScriptEnabled(true);
        settings.setDomStorageEnabled(true);
        settings.setDatabaseEnabled(true);
        settings.setLoadWithOverviewMode(true);
        settings.setUseWideViewPort(true);

        CookieManager.getInstance().setAcceptCookie(true);
        CookieManager.getInstance().setAcceptThirdPartyCookies(webView, true);

        webView.setWebChromeClient(new WebChromeClient());
        webView.setWebViewClient(new WebViewClient() {
            @Override
            public void onPageFinished(WebView view, String url) {
                statusText.setText("目前頁面：" + url);
            }
        });
    }

    private void captureSummaryPage() {
        statusText.setText("正在儲存數據分頁...");
        capturePageText(pageText -> {
            if (!looksLikeActivitySummary(pageText)) {
                statusText.setText("這不像 Garmin 活動數據頁。請先點進活動並等待資料載入。");
                Toast.makeText(this, "請先開啟活動數據頁", Toast.LENGTH_SHORT).show();
                return;
            }

            summaryPageText = cleanGarminSummaryText(pageText);
            summaryPageUrl = safe(webView.getUrl());
            lastPayload = buildCoachOsPayload(summaryPageUrl, "", summaryPageText, "");
            statusText.setText("已存數據分頁。請切到間歇訓練或計圈分頁，再按「存第二頁並複製」。");
            Toast.makeText(this, "已存數據分頁", Toast.LENGTH_SHORT).show();
        });
    }

    private void captureBothPagesAndCopy() {
        statusText.setText("正在一鍵擷取數據分頁...");
        capturePageText(pageText -> {
            if (!looksLikeActivitySummary(pageText)) {
                statusText.setText("這不像 Garmin 活動頁。請先點進活動並等待資料載入。");
                Toast.makeText(this, "請先開啟活動頁", Toast.LENGTH_SHORT).show();
                return;
            }

            summaryPageText = cleanGarminSummaryText(pageText);
            summaryPageUrl = safe(webView.getUrl());
            lastPayload = buildCoachOsPayload(summaryPageUrl, "", summaryPageText, "");

            if (looksLikeSplitTable(pageText)) {
                finishAutoCaptureWithDetail(pageText);
                return;
            }

            statusText.setText("已存數據分頁，正在自動切到間歇訓練...");
            clickDetailTab(clicked -> {
                if (!clicked) {
                    statusText.setText("找不到間歇訓練分頁，仍會嘗試等待表格；若失敗請手動切分頁。");
                }
                waitForDetailPageAndCopy(1);
            });
        });
    }

    private void captureDetailPageAndCopy() {
        if (summaryPageText.trim().isEmpty()) {
            statusText.setText("請先在數據分頁按「存數據分頁」。");
            Toast.makeText(this, "請先存數據分頁", Toast.LENGTH_SHORT).show();
            return;
        }

        statusText.setText("正在擷取第二頁並複製...");
        capturePageText(detailPageText -> {
            if (!looksLikeSplitTable(detailPageText)) {
                statusText.setText("第二頁還沒有讀到間歇/計圈表格。請切到該分頁並等表格載入。");
                Toast.makeText(this, "沒有讀到第二頁表格", Toast.LENGTH_SHORT).show();
                return;
            }

            lastPayload = buildCoachOsPayload(
                summaryPageUrl,
                webView.getUrl(),
                summaryPageText,
                cleanGarminDetailText(detailPageText)
            );
            copyPayload(lastPayload);
            statusText.setText("已複製數據分頁 + 第二頁內容，可貼到 ChatGPT / Claude / Gemini。");
            Toast.makeText(this, "已複製 CoachOS mRelay 內容", Toast.LENGTH_SHORT).show();
        });
    }

    private void clickDetailTab(BooleanCallback callback) {
        webView.evaluateJavascript(
            "(function(){"
                + "var labels=['間歇訓練','計圈'];"
                + "function visible(el){"
                + "  var r=el.getBoundingClientRect();"
                + "  var s=getComputedStyle(el);"
                + "  return r.width>0&&r.height>0&&s.visibility!=='hidden'&&s.display!=='none';"
                + "}"
                + "function textOf(el){return (el.innerText||el.textContent||'').trim().replace(/\\s+/g,' ');}"
                + "var nodes=Array.from(document.querySelectorAll('button,a,[role=\"tab\"],[role=\"button\"],li,div,span'));"
                + "for(var i=0;i<labels.length;i++){"
                + "  var label=labels[i];"
                + "  for(var j=0;j<nodes.length;j++){"
                + "    var el=nodes[j];"
                + "    if(!visible(el)){continue;}"
                + "    var text=textOf(el);"
                + "    if(text===label||text.indexOf(label+' ')===0){"
                + "      var target=el.closest('button,a,[role=\"tab\"],[role=\"button\"],li')||el;"
                + "      target.scrollIntoView({block:'center',inline:'center'});"
                + "      target.click();"
                + "      return true;"
                + "    }"
                + "  }"
                + "}"
                + "return false;"
                + "})()",
            rawResult -> callback.onResult("true".equals(rawResult))
        );
    }

    private void waitForDetailPageAndCopy(int attempt) {
        statusText.setText("正在等待第二頁表格載入... " + attempt + "/" + AUTO_CAPTURE_MAX_ATTEMPTS);
        mainHandler.postDelayed(() -> readPageText(pageText -> {
            if (looksLikeSplitTable(pageText)) {
                finishAutoCaptureWithDetail(pageText);
                return;
            }

            if (attempt >= AUTO_CAPTURE_MAX_ATTEMPTS) {
                statusText.setText("還沒讀到間歇/計圈表格。請手動切到該分頁，再按「存第二頁並複製」。");
                Toast.makeText(this, "自動擷取第二頁逾時", Toast.LENGTH_SHORT).show();
                return;
            }

            waitForDetailPageAndCopy(attempt + 1);
        }), AUTO_CAPTURE_RETRY_MS);
    }

    private void finishAutoCaptureWithDetail(String detailPageText) {
        lastPayload = buildCoachOsPayload(
            summaryPageUrl,
            webView.getUrl(),
            summaryPageText,
            cleanGarminDetailText(detailPageText)
        );
        copyPayload(lastPayload);
        statusText.setText("已一鍵複製數據分頁 + 第二頁內容，可貼到 ChatGPT / Claude / Gemini。");
        Toast.makeText(this, "已一鍵複製 CoachOS mRelay 內容", Toast.LENGTH_SHORT).show();
    }

    private void capturePageText(PageTextCallback callback) {
        readPageText(pageText -> {
            if (pageText.trim().isEmpty()) {
                statusText.setText("沒有讀到內容，請等 Garmin 頁面載入完成後再試。");
                Toast.makeText(this, "沒有讀到內容", Toast.LENGTH_SHORT).show();
                return;
            }

            callback.onPageText(pageText);
        });
    }

    private void readPageText(PageTextCallback callback) {
        webView.evaluateJavascript(
            "(function(){return document.body ? document.body.innerText : '';})()",
            rawJsonText -> {
                String pageText = decodeJavascriptString(rawJsonText);
                callback.onPageText(pageText);
            }
        );
    }

    private String buildCoachOsPayload(String summaryUrl, String detailUrl, String summaryText, String detailText) {
        return "# CoachOS mRelay Garmin Raw Activity\n\n"
            + "## Android App 擷取資訊\n"
            + "- 數據分頁 URL: " + safe(summaryUrl) + "\n"
            + "- 第二分頁 URL: " + safe(detailUrl) + "\n"
            + "- Capture Time: " + java.time.ZonedDateTime.now().toString() + "\n\n"
            + "## 數據分頁原始文字\n"
            + summaryText.trim()
            + "\n\n"
            + "## 計圈／間歇訓練分頁原始文字\n"
            + safe(detailText).trim()
            + "\n\n"
            + "## 使用提醒\n"
            + "請依 Garmin 頁面中的今天、昨天、星期幾與本次擷取日期還原實際活動日期。";
    }

    private void clearCaptureState() {
        summaryPageText = "";
        summaryPageUrl = "";
        lastPayload = "";
        statusText.setText("已清除暫存。請重新存數據分頁。");
        Toast.makeText(this, "已清除", Toast.LENGTH_SHORT).show();
    }

    private void copyPayload(String payload) {
        ClipboardManager clipboard = (ClipboardManager) getSystemService(Context.CLIPBOARD_SERVICE);
        clipboard.setPrimaryClip(ClipData.newPlainText("CoachOS mRelay Garmin Raw Activity", payload));
    }

    private void showPreview() {
        String text = lastPayload.trim();
        if (text.isEmpty()) {
            statusText.setText("目前沒有可預覽內容。請先存數據分頁。");
            Toast.makeText(this, "沒有可預覽內容", Toast.LENGTH_SHORT).show();
            return;
        }

        TextView previewText = new TextView(this);
        previewText.setText(text);
        previewText.setTextSize(12);
        previewText.setTextColor(0xFF13201A);
        previewText.setPadding(28, 24, 28, 24);

        ScrollView scrollView = new ScrollView(this);
        scrollView.addView(previewText);

        new AlertDialog.Builder(this)
            .setTitle("CoachOS mRelay 預覽")
            .setView(scrollView)
            .setPositiveButton("複製", (dialog, which) -> copyPayload(lastPayload))
            .setNegativeButton("關閉", null)
            .show();
    }

    private void sharePayload() {
        String text = lastPayload.trim();
        if (text.isEmpty()) {
            statusText.setText("目前沒有可分享內容。請先完成擷取。");
            Toast.makeText(this, "沒有可分享內容", Toast.LENGTH_SHORT).show();
            return;
        }

        Intent sendIntent = new Intent(Intent.ACTION_SEND);
        sendIntent.setType("text/plain");
        sendIntent.putExtra(Intent.EXTRA_SUBJECT, "CoachOS mRelay Garmin Raw Activity");
        sendIntent.putExtra(Intent.EXTRA_TEXT, text);
        startActivity(Intent.createChooser(sendIntent, "分享 CoachOS mRelay 內容"));
    }

    private String cleanGarminText(String value) {
        String text = safe(value).trim();
        if (text.isEmpty()) {
            return "";
        }

        String startMarker = "依 ";
        int activityStart = text.indexOf(startMarker);
        if (activityStart > 0) {
            text = text.substring(activityStart);
        }

        int trademarkStart = text.indexOf("Normalized Power® (NP®)、Intensity Factor®");
        if (trademarkStart > 0) {
            text = text.substring(0, trademarkStart).trim();
        }

        return text;
    }

    private boolean looksLikeActivitySummary(String text) {
        String value = safe(text);
        return value.contains("/activity/")
            || (value.contains("平均配速")
                && value.contains("平均心率")
                && value.contains("距離")
                && value.contains("時間"));
    }

    private boolean looksLikeSplitTable(String text) {
        String value = safe(text);
        boolean hasHeader = value.contains("間隔\t步驟類型")
            || value.contains("\t間隔\t步驟類型")
            || value.contains("計圈\t時間")
            || value.contains("平均配速\t平均坡度校正配速");
        boolean hasSummary = value.contains("摘要資訊")
            || value.matches("(?s).*\\n\\s*1\\s+.*\\n.*");
        return hasHeader && hasSummary;
    }

    private String cleanGarminSummaryText(String value) {
        String text = cleanGarminText(value);
        if (text.isEmpty()) {
            return "";
        }

        String equipment = extractEquipmentText(text);
        int uiStart = findFirstExistingIndex(text, new String[] {
            "\n照片\n",
            "\n備註\n",
            "\n正在上傳檔案"
        });
        if (uiStart > 0) {
            text = text.substring(0, uiStart).trim();
        }

        if (!equipment.isEmpty()) {
            text = text + "\n\n裝備\n" + equipment;
        }
        return text;
    }

    private String cleanGarminDetailText(String value) {
        String text = cleanGarminText(value);
        if (text.isEmpty()) {
            return "";
        }

        int detailStart = findFirstExistingIndex(text, new String[] {
            "步驟類型\n全部",
            "\t間隔\t步驟類型",
            "間隔\t步驟類型",
            "計圈\n",
            "分段\n"
        });
        if (detailStart > 0) {
            text = text.substring(detailStart).trim();
        }

        int detailEnd = findFirstExistingIndex(text, new String[] {
            "\n照片\n",
            "\n備註\n",
            "\nForerunner ",
            "\n裝備\n"
        });
        if (detailEnd > 0) {
            text = text.substring(0, detailEnd).trim();
        }

        return text;
    }

    private String extractEquipmentText(String text) {
        int equipmentStart = text.indexOf("\n裝備\n");
        if (equipmentStart < 0) {
            return "";
        }

        String[] lines = text.substring(equipmentStart + "\n裝備\n".length()).split("\\n");
        StringBuilder equipment = new StringBuilder();
        int kept = 0;
        for (String line : lines) {
            String cleaned = line.trim();
            if (cleaned.isEmpty() || cleaned.equals("編輯")) {
                continue;
            }
            if (cleaned.startsWith("Normalized Power®")) {
                break;
            }

            if (equipment.length() > 0) {
                equipment.append('\n');
            }
            equipment.append(cleaned);
            kept++;

            if (kept >= 4 || cleaned.contains("公里")) {
                break;
            }
        }
        return equipment.toString();
    }

    private int findFirstExistingIndex(String text, String[] markers) {
        int best = -1;
        for (String marker : markers) {
            int index = text.indexOf(marker);
            if (index >= 0 && (best < 0 || index < best)) {
                best = index;
            }
        }
        return best;
    }

    private String safe(String value) {
        return value == null ? "" : value;
    }

    private String decodeJavascriptString(String value) {
        if (value == null || value.equals("null")) {
            return "";
        }
        String s = value;
        if (s.length() >= 2 && s.startsWith("\"") && s.endsWith("\"")) {
            s = s.substring(1, s.length() - 1);
        }
        return s
            .replace("\\n", "\n")
            .replace("\\t", "\t")
            .replace("\\\"", "\"")
            .replace("\\\\", "\\");
    }

    @Override
    public void onBackPressed() {
        if (webView != null && webView.canGoBack()) {
            webView.goBack();
            return;
        }
        super.onBackPressed();
    }

    private interface PageTextCallback {
        void onPageText(String pageText);
    }

    private interface BooleanCallback {
        void onResult(boolean value);
    }
}
