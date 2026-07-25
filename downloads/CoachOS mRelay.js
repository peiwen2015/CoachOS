// Variables used by Scriptable.
// These must be at the very top of the file. Do not edit.
// icon-color: deep-blue; icon-glyph: magic;
// ============================================================
// 🏃‍♂️ CoachOS mRelay for Scriptable
// 從 Garmin Connect 頁面 DOM 讀取資料，對齊 Excel v1.1 格式
// ============================================================

// Keychain keys（跨次儲存個人設定）
const K_MAXHR  = 'coachOS_maxHR';
const K_CP     = 'coachOS_cp';
const K_SHOES  = 'coachOS_shoes';
const K_COURSE = 'coachOS_courseType';
const K_GOAL   = 'coachOS_goal';

function kGet(key, def) {
  return Keychain.contains(key) ? Keychain.get(key) : (def || '');
}
function kSet(key, val) { if (val) Keychain.set(key, String(val)); }

function extractActivityId(url) {
  const m = url.match(/\/activity\/(\d+)/);
  return m ? m[1] : null;
}

function inferCourseType(name) {
  const s = String(name || '').toLowerCase();
  if (/interval|tempo|threshold|fartlek|speed|repeats/.test(s)) return 'Quality Run';
  if (/long|lsd/.test(s)) return 'Long Run';
  if (/recovery|easy|eazy|jog|warm/.test(s)) return 'Easy Run';
  if (/race|marathon|half|10k|5k/.test(s)) return 'Race';
  return '';
}

function inferGoal(courseType) {
  switch (courseType) {
    case 'Easy Run':
      return 'Aerobic Base';
    case 'Long Run':
      return 'Aerobic Endurance';
    case 'Quality Run':
      return 'Threshold / VO2max';
    case 'Race':
      return 'Race Specific';
    default:
      return '';
  }
}

// ============================================================
// 解析 DOM innerText
// ============================================================

function parseActivity(text) {
  const d = {};
  const lines = String(text || '').split('\n').map(s => s.trim()).filter(Boolean);
  const pad = n => String(n).padStart(2, '0');
  const now = new Date();
  const fmt = (dt) => `${dt.getFullYear()}-${pad(dt.getMonth()+1)}-${pad(dt.getDate())}`;
  const weekdays = {
    '星期日': 0, '星期天': 0, '星期一': 1, '星期二': 2, '星期三': 3,
    '星期四': 4, '星期五': 5, '星期六': 6,
  };
  const parseDisplayDate = function() {
    const firstMatch = text.match(/(?:今天|昨天|星期[日天一二三四五六])(?:\s*@|\s+@|\s)/);
    if (firstMatch) {
      const label = firstMatch[0].replace(/\s*@.*$/, '').trim();
      if (label === '今天') return fmt(now);
      if (label === '昨天') {
        const y = new Date(now);
        y.setDate(y.getDate() - 1);
        return fmt(y);
      }
      const m = label.match(/星期[日天一二三四五六]/);
      if (m) {
        const target = weekdays[m[0]];
        const d0 = new Date(now);
        for (let i = 0; i < 7; i++) {
          if (d0.getDay() === target) return fmt(d0);
          d0.setDate(d0.getDate() - 1);
        }
      }
    }

    const explicit = text.match(/(\d{4})[\/.-](\d{1,2})[\/.-](\d{1,2})/);
    if (explicit) return `${explicit[1]}-${pad(explicit[2])}-${pad(explicit[3])}`;

    const monthDay = text.match(/(\d{1,2})[\/.-](\d{1,2})/);
    if (monthDay) {
      const candidate = new Date(now.getFullYear(), parseInt(monthDay[1], 10) - 1, parseInt(monthDay[2], 10));
      return fmt(candidate);
    }

    return fmt(now);
  };
  d.date = parseDisplayDate();

  const nameM = text.match(/[AP]M\s*\n+([^\n]+)\n+活動:/);
  d.name = nameM ? nameM[1].trim() : null;

  const timeM = text.match(/今天 @ (\d+:\d+ [AP]M)/);
  d.startTime = timeM ? timeM[1] : null;

  const rx  = (re) => { const r = text.match(re); return r ? r[1] : null; };
  const rxf = (re) => { const v = rx(re); return v ? parseFloat(v) : null; };
  const rxi = (re) => { const v = rx(re); return v ? parseInt(v, 10) : null; };
  const pair = function(patterns) {
    for (const re of patterns) {
      const m = text.match(re);
      if (m && m[1] != null) return m[1];
    }
    return null;
  };
  const findAfter = function(labels, valueRe, maxLookahead) {
    const labelList = Array.isArray(labels) ? labels : [labels];
    for (const label of labelList) {
      const idx = lines.findIndex(line => line === label || line.startsWith(label + '：') || line.startsWith(label + ':'));
      if (idx < 0) continue;
      const end = Math.min(lines.length, idx + 1 + (maxLookahead || 6));
      for (let i = idx + 1; i < end; i++) {
        const v = lines[i];
        if (!v) continue;
        if (!valueRe) return v;
        const m = v.match(valueRe);
        if (m) return m[1];
      }
    }
    return null;
  };
  const findBefore = function(label) {
    const idx = lines.findIndex(line => line === label || line.startsWith(label + '：') || line.startsWith(label + ':'));
    if (idx <= 0) return null;
    const v = String(lines[idx - 1] || '').trim();
    if (!v || v === '?' || v === '？') return null;
    return v;
  };
  const findNearNumber = function(labels, min, max, maxLookahead) {
    const labelList = Array.isArray(labels) ? labels : [labels];
    for (const label of labelList) {
      const idx = lines.findIndex(line => line === label || line.startsWith(label + '：') || line.startsWith(label + ':'));
      if (idx < 0) continue;
      const end = Math.min(lines.length, idx + 1 + (maxLookahead || 6));
      for (let i = idx + 1; i < end; i++) {
        const v = lines[i];
        if (!v) continue;
        const m = v.match(/^([\d]+(?:\.[\d]+)?)$/);
        if (!m) continue;
        const n = parseFloat(m[1]);
        if (Number.isFinite(n) && n >= min && n <= max) return n;
      }
    }
    return null;
  };
  const findNearWithUnit = function(labels, unitRe, min, max, maxLookahead) {
    const labelList = Array.isArray(labels) ? labels : [labels];
    for (const label of labelList) {
      const idx = lines.findIndex(line => line === label || line.startsWith(label + '：') || line.startsWith(label + ':'));
      if (idx < 0) continue;
      const end = Math.min(lines.length, idx + 1 + (maxLookahead || 6));
      for (let i = idx + 1; i < end; i++) {
        const v = lines[i];
        if (!v) continue;
        const m = v.match(/^([\d]+(?:\.[\d]+)?)\s*([^\d\s]+)?$/);
        if (!m) continue;
        const n = parseFloat(m[1]);
        const unit = m[2] || '';
        if (Number.isFinite(n) && n >= min && n <= max && (!unitRe || unitRe.test(unit))) return n;
      }
    }
    return null;
  };
  const toInt = function(v) {
    const n = parseInt(v, 10);
    return Number.isFinite(n) ? n : null;
  };
  const toFloat = function(v) {
    const n = parseFloat(v);
    return Number.isFinite(n) ? n : null;
  };

  d.distance = toFloat(pair([
    /([\d.]+)\s*公里\s*\n(?:距離|實際距離)/,
    /(?:距離|實際距離)\s*\n\s*([\d.]+)\s*公里/,
  ]) || findAfter(['距離', '實際距離'], /^([\d.]+)\s*公里$/, 4));
  d.duration = pair([
    /([\d:]+)\s*\n(?:時間|計時)/,
    /(?:時間|計時)\s*\n\s*([\d:]+)/,
  ]) || findAfter(['時間', '計時'], /^([\d:]+)$/, 4);
  d.movingTime = pair([
    /([\d:]+)\s*\n移動時間/,
    /移動時間\s*\n\s*([\d:]+)/,
  ]) || findAfter('移動時間', /^([\d:]+)$/, 4);
  d.avgPace = pair([
    /([\d:]+)\s*\/(?:公里|km)\s*\n平均配速/,
    /平均配速\s*\n\s*([\d:]+)\s*\/(?:公里|km)/,
  ]) || findAfter('平均配速', /^([\d:]+)\s*\/(?:公里|km)$/, 4);
  d.bestPace = pair([
    /([\d:]+)\s*\/(?:公里|km)\s*\n最佳配速/,
    /最佳配速\s*\n\s*([\d:]+)\s*\/(?:公里|km)/,
  ]) || findAfter('最佳配速', /^([\d:]+)\s*\/(?:公里|km)$/, 4);
  d.gap = pair([
    /([\d:]+)\s*\/(?:公里|km)\s*\n(?:平均坡度校正配速|平均坡度修正配速)/,
    /(?:平均坡度校正配速|平均坡度修正配速)\s*\n\s*([\d:]+)\s*\/(?:公里|km)/,
  ]) || findAfter(['平均坡度校正配速', '平均坡度修正配速'], /^([\d:]+)\s*\/(?:公里|km)$/, 4);
  d.avgHR = toInt(findBefore('平均心率') || rxi([
    /([\d]+)\s*bpm\s*\n平均心率/,
    /平均心率\s*\n\s*([\d]+)\s*bpm/,
  ]) || findAfter('平均心率', /^([\d]+)\s*bpm$/, 4)) || null;
  d.maxHR = toInt(findBefore('最大心率') || rxi([
    /([\d]+)\s*bpm\s*\n最大心率/,
    /最大心率\s*\n\s*([\d]+)\s*bpm/,
  ]) || findAfter('最大心率', /^([\d]+)\s*bpm$/, 4)) || null;
  d.calories = toInt(findBefore('總消耗卡路里') || findBefore('消耗熱量') || rxi([
    /([\d]+)\s*\n總消耗卡路里/,
    /總消耗卡路里\s*\n\s*([\d]+)/,
  ]) || findAfter('總消耗卡路里', /^([\d]+)$/, 4)) || null;
  d.elevGain = toInt(findBefore('總爬升') || rxi([
    /([\d]+)\s*(?:公尺|m)\s*\n總爬升/,
    /總爬升\s*\n\s*([\d]+)\s*(?:公尺|m)/,
  ]) || findAfter('總爬升', /^([\d]+)\s*(?:公尺|m)$/, 4)) || null;
  d.elevDesc = findNearNumber('總下降', 0, 20000, 4);

  // 跑步動態
  d.cadence  = toInt(rxi([
    /([\d]+)\s*每分鐘步數\s*\n平均步頻/,
    /平均步頻\s*\n\s*([\d]+)\s*spm/,
  ]) || findAfter('平均步頻', /^([\d]+)\s*spm$/, 4)) || null;
  d.strideM  = rxf([
    /([\d.]+)\s*公尺\s*\n平均步幅/,
    /平均步幅\s*\n\s*([\d.]+)\s*mm/,
  ]) || (function() {
    const v = findAfter('平均步幅', /^([\d.]+)\s*mm$/, 4);
    return v ? parseFloat(v) / 1000 : null;
  })();
  d.gct      = toFloat(rxf([
    /([\d.]+)\s*(?:亳秒|毫秒|ms)\s*\n平均觸地時間/,
    /平均觸地時間\s*\(GCT\)\s*\n\s*([\d.]+)\s*(?:亳秒|毫秒|ms)/,
  ]) || findAfter('平均觸地時間', /^([\d.]+)\s*(?:亳秒|毫秒|ms)$/, 4)) || null;
  d.vo       = rxf([
    /([\d.]+)\s*cm\s*\n平均垂直振幅/,
    /平均垂直振幅\s*\n\s*([\d.]+)\s*mm/,
  ]) || (function() {
    const v = findAfter('平均垂直振幅', /^([\d.]+)\s*mm$/, 4);
    return v ? parseFloat(v) / 10 : null;
  })();
  d.vr       = toFloat(rxf([
    /([\d.]+)\s*%\s*\n平均移動效率/,
    /平均垂直比\s*\n\s*([\d.]+)\s*%/,
  ]) || findAfter('平均垂直比', /^([\d.]+)\s*%$/, 4)) || null;
  d.avgPower = toInt(rxi([
    /([\d]+)\s*瓦\s*\n平均功率/,
    /平均功率\s*\n\s*([\d]+)\s*W/,
  ]) || findAfter('平均功率', /^([\d]+)\s*W$/, 4)) || null;
  d.maxPower = toInt(rxi([
    /([\d]+)\s*瓦\s*\n最大功率/,
    /最大功率\s*\n\s*([\d]+)\s*W/,
  ]) || findAfter('最大功率', /^([\d]+)\s*W$/, 4)) || null;

  // 訓練效果
  d.teAero    = toFloat(rxf([
    /([\d.]+)\s*影響\s*\n有氧/,
    /有氧訓練效果\s*\n\s*([\d.]+)/,
  ]) || findAfter('有氧訓練效果', /^([\d.]+)$/, 4)) || null;
  d.teAna     = toFloat(rxf([
    /([\d.]+)\s*(?:影響|維持效果)\s*\n無氧/,
    /無氧訓練效果\s*\n\s*([\d.]+)/,
  ]) || findAfter('無氧訓練效果', /^([\d.]+)$/, 4)) || null;
  d.teBenefit = pair([
    /([^\n]+)\n主要益處/,
    /主要益處\s*\n\s*([^\n]+)/,
  ]) || findAfter('主要益處', /^([^\n]+)$/, 4);
  d.load      = toInt(rxi([
    /([\d]+)\n運動負荷/,
    /訓練負荷\s*\n\s*([\d]+)/,
  ]) || findAfter('訓練負荷', /^([\d]+)$/, 4)) || null;
  d.perf      = toInt(rxi([
    /([\d]+)%(?:良好|普通|差勁|優異)/,
    /執行分數\s*\n\s*([\d]+)%/,
  ]) || findAfter('執行分數', /^([\d]+)%$/, 4)) || null;

  // 體力
  d.stamStart = findNearNumber(['起始體力', '起始上限'], 0, 100, 4);
  d.stamEnd   = findNearNumber(['結束體力', '結束上限'], 0, 100, 4);

  // 手錶感測溫度
  d.watchTemp = toFloat(rxf([
    /([\d.]+)\s*°C\s*\n平均溫度/,
    /平均溫度\s*\n\s*([\d.]+)\s*°C/,
  ]) || findAfter('平均溫度', /^([\d.]+)\s*°C$/, 4)) || null;

  // EF
  if (d.avgPace && d.avgHR) {
    const parts = d.avgPace.split(':');
    const paceSec = parseInt(parts[0], 10) * 60 + parseInt(parts[1], 10);
    const speedMpMin = 1000 / paceSec * 60;
    d.ef = (speedMpMin / d.avgHR).toFixed(3);
  }

  return d;
}

// ============================================================
// 解析每公里資料（best-effort）
// ============================================================

function parseLaps(text) {
  const laps = [];
  const tableSection = text.match(/每公里([\s\S]{0,5000}?)(?:圈次|間歇|備註|$)/);
  if (!tableSection) return laps;

  const rows = tableSection[1].trim().split('\n').map(function(s) { return s.trim(); }).filter(Boolean);
  let i = 0;
  while (i < rows.length - 2) {
    const lapNum = parseInt(rows[i], 10);
    if (!isNaN(lapNum) && lapNum > 0 && lapNum <= 50) {
      const paceM = rows[i+1] ? rows[i+1].match(/^(\d+:\d+)$/) : null;
      const hrM   = rows[i+2] ? rows[i+2].match(/^(\d{2,3})$/) : null;
      if (paceM && hrM) {
        laps.push({ km: lapNum, pace: paceM[1], hr: parseInt(hrM[1], 10) });
        i += 3;
        continue;
      }
    }
    i++;
  }
  return laps;
}

function calcFromLaps(laps) {
  if (!laps || laps.length < 2) return { hrDrift: null, cv: null };

  const half = Math.floor(laps.length / 2);
  const avg = function(arr) { return arr.reduce(function(s, v) { return s + v; }, 0) / arr.length; };

  const hrs = laps.map(function(l) { return l.hr; });
  const firstHR = avg(hrs.slice(0, half));
  const lastHR  = avg(hrs.slice(half));
  const hrDrift = (lastHR - firstHR) / firstHR * 100;

  const pacesSec = laps.map(function(l) {
    const parts = l.pace.split(':');
    return parseInt(parts[0], 10) * 60 + parseInt(parts[1], 10);
  });
  const avgP = avg(pacesSec);
  const sd   = Math.sqrt(avg(pacesSec.map(function(v) { return Math.pow(v - avgP, 2); })));
  const cv   = sd / avgP * 100;

  return {
    hrDrift: (hrDrift >= 0 ? '+' : '') + hrDrift.toFixed(1) + '%',
    cv: cv.toFixed(1) + '%',
  };
}

// ============================================================
// 天氣（wttr.in）
// ============================================================

async function fetchWeather(location) {
  if (!location || !location.trim()) return null;
  try {
    const loc = encodeURIComponent(location.trim());
    const req = new Request('https://wttr.in/' + loc + '?format=j1');
    req.timeoutInterval = 8;
    const data = await req.loadJSON();
    const c = data && data.current_condition && data.current_condition[0];
    if (!c) return null;
    const descArr = (c.lang_zh && c.lang_zh.length) ? c.lang_zh : c.weatherDesc;
    const desc = (descArr && descArr[0] && descArr[0].value) ? descArr[0].value : 'N/A';
    return {
      desc:    desc,
      temp:    c.temp_C + '°C',
      humidity: c.humidity + '%',
      windDir: c.winddir16Point || 'N/A',
      windKmh: c.windspeedKmph + ' km/h',
    };
  } catch(e) {
    return null;
  }
}

function sleep(ms) {
  return new Promise(resolve => {
    const timer = new Timer();
    timer.timeInterval = ms / 1000;
    timer.repeats = false;
    timer.schedule(() => resolve());
  });
}

function mergeActivityDetails(d, activityJson, detailJson) {
  const act = activityJson || {};
  const det = detailJson || {};

  const pickNum = function(v) {
    const n = Number(v);
    return Number.isFinite(n) ? n : null;
  };

  const pickFrom = function(obj, paths) {
    for (const path of paths) {
      let cur = obj;
      let ok = true;
      for (const key of path) {
        if (cur && Object.prototype.hasOwnProperty.call(cur, key)) {
          cur = cur[key];
        } else {
          ok = false;
          break;
        }
      }
      if (ok && cur !== undefined && cur !== null && cur !== '') return cur;
    }
    return null;
  };

  const assignIfMissing = function(key, val) {
    if (d[key] == null && val != null && val !== '') d[key] = val;
  };

  const firstValidNumber = function() {
    for (let i = 0; i < arguments.length; i++) {
      const v = arguments[i];
      if (v == null || v === '') continue;
      const n = Number(v);
      if (Number.isFinite(n) && n > 0) return n;
    }
    return null;
  };

  assignIfMissing('distance', firstValidNumber(pickFrom(act, [['distance'], ['summary', 'distance']]), pickFrom(det, [['distance'], ['summary', 'distance']])));
  assignIfMissing('duration', pickFrom(act, [['duration'], ['movingTime'], ['elapsedDuration']]) || pickFrom(det, [['duration'], ['movingTime'], ['elapsedDuration']]));
  assignIfMissing('movingTime', pickFrom(act, [['movingTime']]) || pickFrom(det, [['movingTime']]));
  assignIfMissing('avgPace', pickFrom(act, [['avgPace'], ['averagePace'], ['pace']]) || pickFrom(det, [['avgPace'], ['averagePace'], ['pace']]));
  assignIfMissing('bestPace', pickFrom(act, [['bestPace'], ['maxPace']]) || pickFrom(det, [['bestPace'], ['maxPace']]));
  assignIfMissing('gap', pickFrom(act, [['gap'], ['gradeAdjustedPace']]) || pickFrom(det, [['gap'], ['gradeAdjustedPace']]));
  assignIfMissing('avgHR', firstValidNumber(pickNum(pickFrom(act, [['averageHR'], ['avgHR'], ['averageHeartRate'], ['avgHeartRate']])), pickNum(pickFrom(det, [['averageHR'], ['avgHR'], ['averageHeartRate'], ['avgHeartRate']]))));
  assignIfMissing('maxHR', firstValidNumber(pickNum(pickFrom(act, [['maxHR'], ['maxHeartRate']])), pickNum(pickFrom(det, [['maxHR'], ['maxHeartRate']]))));
  assignIfMissing('calories', firstValidNumber(pickNum(pickFrom(act, [['calories'], ['totalCalories'], ['activeCalories']])), pickNum(pickFrom(det, [['calories'], ['totalCalories'], ['activeCalories']]))));
  assignIfMissing('elevGain', firstValidNumber(pickNum(pickFrom(act, [['elevGain'], ['totalElevationGain'], ['elevationGain']])), pickNum(pickFrom(det, [['elevGain'], ['totalElevationGain'], ['elevationGain']]))));
  assignIfMissing('cadence', firstValidNumber(pickNum(pickFrom(act, [['averageCadence'], ['cadence']])), pickNum(pickFrom(det, [['averageCadence'], ['cadence']]))));
  assignIfMissing('avgPower', firstValidNumber(pickNum(pickFrom(act, [['averagePower'], ['avgPower']])), pickNum(pickFrom(det, [['averagePower'], ['avgPower']]))));
  assignIfMissing('maxPower', firstValidNumber(pickNum(pickFrom(act, [['maxPower'], ['maximumPower']])), pickNum(pickFrom(det, [['maxPower'], ['maximumPower']]))));
  assignIfMissing('stamStart', firstValidNumber(pickNum(pickFrom(act, [['startBatteryLevel'], ['startStamina'], ['startingStamina']])), pickNum(pickFrom(det, [['startBatteryLevel'], ['startStamina'], ['startingStamina']]))));
  assignIfMissing('stamEnd', firstValidNumber(pickNum(pickFrom(act, [['endBatteryLevel'], ['endStamina'], ['endingStamina']])), pickNum(pickFrom(det, [['endBatteryLevel'], ['endStamina'], ['endingStamina']]))));

  return d;
}

// ============================================================
// 提示框
// ============================================================

async function promptSubjective() {
  const a = new Alert();
  a.title = '🧠 主觀感受';
  a.message = '如果 Garmin Connect 沒有顯示主觀感受，才需要手動輸入。';
  a.addTextField('感受難度 (1-10)', '3');
  a.addTextField('感覺如何', '普通');
  a.addTextField('補給紀錄（可留空）', '');
  a.addTextField('備註（可留空）', '');
  a.addAction('✅ 完成');
  if (await a.present() === -1) {
    return {
      difficulty: 'N/A',
      feeling: 'N/A',
      nutrition: '',
      notes: '',
    };
  }
  return {
    difficulty: a.textFieldValue(0) || 'N/A',
    feeling:    a.textFieldValue(1) || 'N/A',
    nutrition:  a.textFieldValue(2) || '',
    notes:      a.textFieldValue(3) || '',
  };
}

function parseSubjective(text) {
  const lines = String(text || '').split('\n').map(s => s.trim()).filter(Boolean);
  const clean = function(v) {
    if (!v) return null;
    const s = String(v).trim();
    if (!s || s === '?' || s === '？') return null;
    return s;
  };

  const findBefore = function(label) {
    const idx = lines.findIndex(line => line === label || line.startsWith(label + '：') || line.startsWith(label + ':'));
    if (idx < 0) return null;
    if (idx - 1 >= 0) return clean(lines[idx - 1]);
    return null;
  };

  const feeling = clean(findBefore('自我評量'));
  const difficulty = clean(findBefore('感受難度'));

  if (!difficulty && !feeling) return null;
  return {
    difficulty: difficulty || 'N/A',
    feeling: feeling || 'N/A',
  };
}

async function promptWeatherLocation() {
  const a = new Alert();
  a.title = '🌤 天氣（可略過）';
  a.message = '輸入座標或城市名，留空略過';
  a.addTextField('跑步地點（例: 25.01,121.50 或 台北）', '');
  a.addAction('查詢天氣');
  a.addCancelAction('略過');
  if (await a.present() === -1) return null;
  return a.textFieldValue(0) || null;
}

// ============================================================
// 建立 Markdown
// ============================================================

function buildMarkdown(d, course, subj, weather, laps) {
  const md = [];
  const na = 'N/A';
  const inferredCourseType = course.type || inferCourseType(d.name);
  const inferredGoal = course.goal || inferGoal(inferredCourseType);

  md.push('# 🏃‍♂️ 跑步訓練分析');
  md.push('**日期：** ' + d.date + (d.startTime ? ' @ ' + d.startTime : '') +
          ' ｜ **活動：** ' + (d.name || '跑步'));
  md.push('');

  // 課表資訊
  if (inferredCourseType || inferredGoal || course.shoe) {
    md.push('## 📋 課表資訊');
    md.push('| 項目 | 內容 |');
    md.push('|:-----|:-----|');
    if (inferredCourseType) md.push('| 課表類型 | ' + inferredCourseType + ' |');
    if (inferredGoal) md.push('| 訓練目的 | ' + inferredGoal + ' |');
    if (course.shoe) md.push('| 鞋款 | ' + course.shoe + ' |');
    md.push('');
  }

  // 天氣環境
  if (weather) {
    md.push('## 🌤 天氣環境');
    md.push('| 項目 | 數值 |');
    md.push('|:-----|-----:|');
    md.push('| 天氣描述 | ' + weather.desc + ' |');
    md.push('| 氣溫 | ' + weather.temp + ' |');
    md.push('| 濕度 | ' + weather.humidity + ' |');
    md.push('| 風向 | ' + weather.windDir + ' |');
    md.push('| 風速 | ' + weather.windKmh + ' |');
    md.push('');
  }

  if (subj && (subj.difficulty || subj.feeling)) {
    md.push('## 🧠 主觀感受');
    md.push('| 項目 | 內容 |');
    md.push('|:-----|:-----|');
    if (subj.difficulty) md.push('| RPE / 感受難度 | ' + subj.difficulty + ' / 10 |');
    if (subj.feeling) md.push('| 感覺如何 | ' + subj.feeling + ' |');
    md.push('');
  }

  // 訓練摘要
  md.push('## 📊 訓練摘要');
  md.push('| 項目 | 數值 |');
  md.push('|:-----|-----:|');
  md.push('| 距離 | ' + (d.distance != null ? d.distance.toFixed(2) + ' km' : na) + ' |');
  md.push('| 完成時間 | ' + (d.duration || na) + ' |');
  md.push('| 移動時間 | ' + (d.movingTime || na) + ' |');
  md.push('| 平均配速 | ' + (d.avgPace ? d.avgPace + ' /km' : na) + ' |');
  md.push('| 最佳配速 | ' + (d.bestPace ? d.bestPace + ' /km' : na) + ' |');
  md.push('| 坡度校正配速 | ' + (d.gap ? d.gap + ' /km' : na) + ' |');
  md.push('| 平均心率 | ' + (d.avgHR != null ? d.avgHR + ' bpm' : na) + ' |');
  md.push('| 最大心率 | ' + (d.maxHR != null ? d.maxHR + ' bpm' : na) + ' |');
  if (course.maxHR && d.avgHR)
    md.push('| 平均心率% | ' + Math.round(d.avgHR / course.maxHR * 100) + '% |');
  md.push('| 消耗熱量 | ' + (d.calories != null ? d.calories + ' kcal' : na) + ' |');
  md.push('| 總爬升 | ' + (d.elevGain != null ? d.elevGain + ' m' : na) + ' |');
  md.push('| 手錶感測溫度 | ' + (d.watchTemp != null ? d.watchTemp.toFixed(1) + ' °C' : na) + ' |');
  md.push('');

  // 體力狀態
  if (d.stamStart != null || d.stamEnd != null) {
    md.push('## ⚡ 體力狀態');
    md.push('| 項目 | 數值 |');
    md.push('|:-----|-----:|');
    if (d.stamStart != null) md.push('| 起始體力 | ' + d.stamStart + '% |');
    if (d.stamEnd   != null) md.push('| 結束體力 | ' + d.stamEnd   + '% |');
    md.push('');
  }

  // 跑步動態
  if (d.cadence || d.gct || d.vo) {
    md.push('## 🦿 跑步動態（Running Economy）');
    md.push('| 項目 | 數值 |');
    md.push('|:-----|-----:|');
    if (d.cadence  != null) md.push('| 平均步頻 | ' + d.cadence + ' spm |');
    if (d.strideM  != null) md.push('| 平均步幅 | ' + Math.round(d.strideM * 1000) + ' mm |');
    if (d.gct      != null) md.push('| 平均觸地時間 (GCT) | ' + Math.round(d.gct) + ' ms |');
    if (d.vo       != null) md.push('| 平均垂直振幅 | ' + Math.round(d.vo * 10) + ' mm |');
    if (d.vr       != null) md.push('| 平均垂直比 | ' + d.vr.toFixed(1) + '% |');
    if (d.avgPower != null) md.push('| 平均功率 | ' + d.avgPower + ' W |');
    if (d.maxPower != null) md.push('| 最大功率 | ' + d.maxPower + ' W |');
    if (course.cp && d.avgPower)
      md.push('| 功率% CP | ' + Math.round(d.avgPower / course.cp * 100) + '% |');
    md.push('');
  }

  // 訓練效果
  if (d.teAero != null || d.load != null) {
    md.push('## 💪 訓練效果');
    md.push('| 項目 | 數值 |');
    md.push('|:-----|-----:|');
    if (d.teBenefit)        md.push('| 主要益處 | ' + d.teBenefit + ' |');
    if (d.teAero != null)   md.push('| 有氧訓練效果 | ' + d.teAero + ' |');
    if (d.teAna  != null)   md.push('| 無氧訓練效果 | ' + d.teAna  + ' |');
    if (d.load   != null)   md.push('| 訓練負荷 | ' + d.load + ' |');
    if (d.perf   != null)   md.push('| 執行分數 | ' + d.perf + '% |');
    md.push('');
  }

  // 每公里數據
  if (laps && laps.length > 0) {
    md.push('## 🔢 每公里數據');
    let hdr = '| 公里 | 配速 | 心率 |';
    let sep = '|:---:|-----:|-----:|';
    if (course.maxHR) { hdr += ' 心率% |'; sep += '------:|'; }
    md.push(hdr);
    md.push(sep);
    laps.forEach(function(l) {
      let row = '| ' + l.km + ' | ' + l.pace + ' | ' + l.hr + ' bpm |';
      if (course.maxHR) row += ' ' + Math.round(l.hr / course.maxHR * 100) + '% |';
      md.push(row);
    });
    md.push('');
  }

  md.push('---');
  md.push('## 💬 分析請求');
  md.push('請根據以上數據分析這次跑步訓練，包括：');
  md.push('1. 整體訓練質量評估（依課表目標判斷達成度）');
  md.push('2. 心率控制表現（與個人最大心率' + (course.maxHR ? ' ' + course.maxHR + ' bpm' : '') + '相比）');
  md.push('3. 跑步效率解讀（EF、跑步動態、功率）');
  md.push('4. 訓練效果與累積負荷評估');
  md.push('5. 下次訓練建議');
  md.push('');
  md.push('*CoachOS mRelay · ' + new Date().toLocaleString('zh-TW') + '*');

  return md.join('\n');
}

// ============================================================
// 主程式：依序讀取「數據」與「計圈／間歇訓練」原始 DOM → 合併複製
// ============================================================

async function captureTab1(activityId) {
  const wv = new WebView();
  await wv.loadURL('https://connect.garmin.com/modern/activity/' + activityId);
  await wv.present(false);
  return await wv.evaluateJavaScript(
    "document.body ? document.body.innerText.slice(0, 15000) : ''"
  );
}

async function captureTab2(activityId) {
  const wv = new WebView();
  await wv.loadURL('https://connect.garmin.com/modern/activity/' + activityId);
  await wv.present(false);

  const raw = await wv.evaluateJavaScript(`(() => {
    const body = document.body ? document.body.innerText : '';
    const tables = Array.from(document.querySelectorAll('table'))
      .map(table => table.innerText || '')
      .filter(text => /平均配速|計圈|間隔/.test(text));
    return JSON.stringify({ body: body.slice(0, 15000), tables });
  })()`);

  try {
    const data = JSON.parse(raw || '{}');
    const table = Array.isArray(data.tables)
      ? data.tables
          .filter(text => /平均配速|計圈|間隔/.test(text))
          .sort((a, b) => b.length - a.length)[0]
      : '';
    return table || data.body || '';
  } catch (e) {
    return raw || '';
  }
}

async function main() {
  try {
    const intro = new Alert();
    intro.title = 'CoachOS mRelay';
    intro.message = '即將開啟 Garmin Connect。請登入（若需要），點進今天的活動，停在「數據」分頁，等內容載入完成後關閉。';
    intro.addAction('開啟 Garmin');
    intro.addCancelAction('取消');
    if (await intro.present() === -1) return;

    // 第一次開啟活動列表，由使用者登入並選取活動。
    const wv1 = new WebView();
    await wv1.loadURL('https://connect.garmin.com/app/activities');
    await wv1.present(false);

    const selectionRaw = await wv1.evaluateJavaScript(`(() => {
      return JSON.stringify({
        href: location.href,
        body: document.body ? document.body.innerText.slice(0, 15000) : ''
      });
    })()`);
    let selection = {};
    try { selection = JSON.parse(selectionRaw || '{}'); } catch (e) {}

    const activityUrl = String(selection.href || '').trim();
    const activityId = extractActivityId(activityUrl);
    if (!activityId) {
      throw new Error('找不到活動網址，請在第一次關閉前先點進今天的活動頁');
    }

    const tab1 = selection.body || '';
    if (!tab1 || tab1.length < 100) {
      throw new Error('無法讀取「數據」分頁，請確認活動頁已完整載入再關閉');
    }

    const guide = new Alert();
    guide.title = '數據分頁已完成';
    guide.message = '接下來會再次開啟同一活動頁。請切換到「計圈」或「間歇訓練」分頁後再關閉。\n\n請不要選第三個「區段」分頁。';
    guide.addAction('開啟計圈／間歇訓練');
    await guide.present();

    // 第二次開啟同一活動頁，Tab 名稱不固定，以表格內容判斷。
    const wv2 = new WebView();
    await wv2.loadURL(activityUrl);
    await wv2.present(false);
    const tab2Raw = await wv2.evaluateJavaScript(`(() => {
      const body = document.body ? document.body.innerText : '';
      const tables = Array.from(document.querySelectorAll('table'))
        .map(table => table.innerText || '')
        .filter(text => /平均配速|計圈|間隔/.test(text));
      return JSON.stringify({ body: body.slice(0, 15000), tables });
    })()`);

    let tab2 = '';
    try {
      const data = JSON.parse(tab2Raw || '{}');
      const table = Array.isArray(data.tables)
        ? data.tables
            .filter(text => /平均配速|計圈|間隔/.test(text))
            .sort((a, b) => b.length - a.length)[0]
        : '';
      tab2 = table || data.body || '';
    } catch (e) {
      tab2 = tab2Raw || '';
    }
    if (!tab2 || tab2.length < 100) {
      throw new Error('無法讀取「計圈／間歇訓練」分頁，請切換到該分頁後再關閉');
    }

    const output = [
      '# CoachOS mRelay Garmin Raw Activity',
      '**活動網址：** ' + activityUrl,
      '',
      '請直接根據以下 Garmin Connect 原始內容分析，不要假設缺失欄位，也不要把欄位位置當成固定格式。',
      '日期判讀規則：Garmin 會將今天顯示為「今天」、昨天顯示為「昨天」、同一週較早活動顯示為星期幾，更早活動才顯示完整日期；請依本次執行日期還原實際日期。',
      '',
      '## 數據分頁原始 DOM',
      '```text',
      tab1,
      '```',
      '',
      '## 計圈／間歇訓練分頁原始 DOM',
      '```text',
      tab2,
      '```',
    ].join('\n');
    Pasteboard.copyString(output);

    const done = new Alert();
    done.title = '✅ CoachOS mRelay 完成';
    done.message = '「數據」與「計圈／間歇訓練」分頁原始內容已複製到剪貼簿。\n\n接下來請開啟你常用的 AI，例如 ChatGPT、Claude 或 Gemini，進入要使用的 Project／對話，再貼上內容進行分析。';
    done.addAction('👌 好的');
    await done.present();

  } catch(e) {
    const err = new Alert();
    err.title = '❌ 錯誤';
    err.message = String(e) + (e.stack ? '\n\n' + e.stack.slice(0, 300) : '');
    err.addAction('OK');
    await err.present();
  }
}

main();
