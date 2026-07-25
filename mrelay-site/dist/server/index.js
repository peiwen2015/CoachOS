const inlineHtml = `<!doctype html>
<html lang="zh-Hant">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <meta name="theme-color" content="#102a43">
  <meta name="description" content="CoachOS mRelay：跑完步，在 iPhone 上用 Scriptable 把 Garmin Connect 活動資料直接交給 AI 教練。">
  <title>CoachOS mRelay | Garmin to AI</title>
  <style>
    body{margin:0;font-family:system-ui,-apple-system,BlinkMacSystemFont,"Segoe UI",sans-serif;background:#f8f5ed;color:#102a43;line-height:1.6}
    main{max-width:980px;margin:0 auto;padding:32px 20px 64px}
    .card{background:#fffdf8;border:1px solid #dce5e6;border-radius:20px;padding:28px}
    .eyebrow{letter-spacing:.14em;text-transform:uppercase;font-size:12px;color:#ef8354;font-weight:700}
    h1{font-size:clamp(40px,8vw,72px);line-height:1.03;margin:12px 0 18px}
    p{font-size:16px;max-width:58rem}
    a.button{display:inline-block;margin:12px 12px 0 0;padding:14px 18px;border-radius:10px;text-decoration:none;font-weight:700}
    .primary{background:#ef8354;color:#fff}
    .quiet{border:1px solid #b4c7ca;color:#102a43}
    .grid{display:grid;gap:18px;grid-template-columns:repeat(auto-fit,minmax(220px,1fr));margin-top:28px}
    .tile{background:#fff;border:1px solid #dce5e6;border-radius:16px;padding:18px}
    .muted{color:#688096}
    code{background:#102a4320;padding:2px 5px;border-radius:6px}
  </style>
</head>
<body>
  <main>
    <section class="card">
      <div class="eyebrow">GARMIN CONNECT × AI</div>
      <h1>把跑步資料，直接交給 AI 教練。</h1>
      <p>CoachOS mRelay 是一個搭配 iPhone／iPad 上 Scriptable 的 JavaScript 工具。跑完步後，從 Garmin Connect 讀取活動原始內容，整理後直接交給 AI 分析。</p>
      <p>
        <a class="button primary" href="downloads/CoachOS%20mRelay.js" download>下載 Scriptable 腳本</a>
        <a class="button quiet" href="#how">查看流程</a>
      </p>
      <p class="muted">如果你看到這個版本，代表首頁已正常載入；下面是簡化版內容，之後我可以再把完整圖文版同步回來。</p>
    </section>
    <section id="how" class="grid">
      <div class="tile"><strong>01 選活動</strong><p class="muted">在 Garmin Connect 內開啟要分析的跑步活動。</p></div>
      <div class="tile"><strong>02 切換分頁</strong><p class="muted">先看數據，再切到計圈或間歇訓練分頁。</p></div>
      <div class="tile"><strong>03 貼給 AI</strong><p class="muted">內容會複製到剪貼簿，直接貼到 ChatGPT 或其他 AI。</p></div>
    </section>
  </main>
</body>
</html>`;

function serveInlineHtml() {
  return new Response(inlineHtml, {
    headers: {
      "content-type": "text/html; charset=utf-8",
      "cache-control": "no-store",
    },
  });
}

export default {
  async fetch(request, env) {
    const url = new URL(request.url);
    if (url.pathname === "/" || url.pathname === "/index.html") {
      try {
        const response = await env.ASSETS.fetch(new Request(new URL("/index.html", request.url), request));
        if (response.status !== 404) return response;
      } catch {
        // Fall back to inline HTML when the asset binding is unavailable.
      }
      return serveInlineHtml();
    }

    if (env.ASSETS) {
      try {
        return await env.ASSETS.fetch(request);
      } catch {
        // fall through to a 404 below
      }
    }

    return new Response("Not found", { status: 404 });
  },
};
