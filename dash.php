<?php
/**
 * VIBRANIUM ESPORT - LIVE DASHBOARD (FULL SCREEN OPTIMIZED)
 */
ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ALL);

// --- 1. STATUS CHECK ---
$status_url = "https://vibraniumjobooking.com/api/get_waiting_status.php"; 
$status_response = @file_get_contents($status_url);

if (trim(strtolower($status_response)) !== 'true') {
    ?>
    <!DOCTYPE html>
    <html lang="en">
    <head>
        <meta charset="UTF-8">
        <title>System Offline - Vibranium</title>
        <style>
            body { background: #020205; color: #f7f4ff; display: flex; align-items: center; justify-content: center; height: 100vh; margin: 0; font-family: 'Inter', sans-serif; }
            .offline-box { text-align: center; border: 1px solid rgba(142, 73, 230, 0.22); padding: 50px; border-radius: 28px; background: rgba(16, 10, 28, 0.6); box-shadow: 0 0 40px rgba(0,0,0,0.5); }
            h1 { color: #2fd5ff; font-size: 2.5rem; margin-bottom: 10px; text-transform: uppercase; letter-spacing: 2px; }
            p { color: #9f90bb; font-size: 1.2rem; }
        </style>
        <script>setTimeout(() => { window.location.reload(); }, 10000);</script>
    </head>
    <body>
        <div class="offline-box">
            <h1>Waiting List Offline</h1>
            <p>Waiting list is offline - Book pc from app -> quick actions -> book pc</p>
        </div>
    </body>
    </html>
    <?php
    exit;
}

// --- 2. DATA FETCHING ---
require_once 'db_config.php'; 

// Leaderboard
$leaderQuery = "SELECT username, totalSpent, rank FROM loyality ORDER BY totalSpent DESC LIMIT 5";
$leaderRes = $conn->query($leaderQuery);
$topPlayers = ($leaderRes && $leaderRes->num_rows > 0) ? $leaderRes->fetch_all(MYSQLI_ASSOC) : [];

// PC State
$snapshotFile = __DIR__ . '/pc_last_state.json';
$availablePcs = 0;
$counts = ['Stage' => 0, 'VIP' => 0, 'Normal' => 0, 'MVIP' => 0];

if (file_exists($snapshotFile)) {
    $machines = json_decode(file_get_contents($snapshotFile), true);
    $excludedPcs = ['moza01', 'moza02'];
    foreach ($machines as $pc) {
        $rawName = $pc['name'];
        $normName = str_replace(['-', ' '], '', strtolower(trim($rawName)));
        if (($pc['state'] === 'ReadyForUser') && empty($pc['user_uuid']) && !in_array($normName, $excludedPcs)) {
            $availablePcs++;
            if (stripos($rawName, 'S') !== false) $counts['Stage']++;
            elseif (stripos($rawName, 'MV') !== false) $counts['MVIP']++;
            elseif (stripos($rawName, 'VIP') !== false) $counts['VIP']++;
            else $counts['Normal']++;
        }
    }
}

// Queue
$query = "SELECT username, queue_type FROM vibranium_queue WHERE status = 'waiting' ORDER BY created_at ASC";
$res = $conn->query($query);
$waitingList = $res ? $res->fetch_all(MYSQLI_ASSOC) : [];
$totalInQueue = count($waitingList);
$conn->close();
?>

<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <title>Vibranium Dashboard</title>
  <script src="https://cdnjs.cloudflare.com/ajax/libs/qrcodejs/1.0.0/qrcode.min.js"></script>
  <style>
    :root { --bg: #020205; --border: rgba(142, 73, 230, 0.22); --primary: #ab63ff; --cyan: #2fd5ff; --text: #f7f4ff; --muted: #9f90bb; }
    * { box-sizing: border-box; -webkit-font-smoothing: antialiased; }
    body { margin: 0; height: 100vh; overflow: hidden; font-family: 'Inter', sans-serif; background: #010103; color: var(--text); padding: 2vh 2vw; }
    .screen { display: grid; grid-template-columns: 1.6fr 0.9fr; gap: 1.5vw; height: 95vh; }
    
    .panel { background: rgba(14, 9, 24, 0.8); border: 1px solid var(--border); border-radius: 24px; padding: 20px; }
    .brand-row { display: flex; align-items: center; gap: 20px; margin-bottom: 20px; }
    .logo-shell img { width: 140px; }
    
    .summary { display: grid; grid-template-columns: 1fr 2.5fr; gap: 15px; margin-bottom: 15px; }
    .stat { background: rgba(16, 10, 28, 0.6); border: 1px solid var(--border); border-radius: 20px; padding: 15px; }
    .tier-grid { display: flex; justify-content: space-around; width: 100%; }
    .tier-num { font-size: 2.8vw; font-weight: 800; color: var(--cyan); line-height: 1; }
    .tier-label { font-size: 0.7vw; color: var(--muted); text-transform: uppercase; margin-top: 4px; }

    .queue-card { background: rgba(12, 8, 22, 0.5); border: 1px solid var(--border); border-radius: 20px; height: 58vh; overflow: hidden; }
    .queue-head, .queue-row { display: grid; grid-template-columns: 80px 1fr 150px; padding: 16px 20px; }
    .queue-head { background: rgba(108, 42, 188, 0.15); font-weight: bold; color: var(--primary); text-transform: uppercase; font-size: 0.8vw; }
    .queue-row { border-bottom: 1px solid rgba(255,255,255,0.03); font-size: 1.4vw; }
    
    .leader-row { display: flex; align-items: center; justify-content: space-between; padding: 12px 15px; margin-bottom: 8px; background: rgba(255,255,255,0.03); border-radius: 12px; }
    .rank-img { width: 45px; height: 45px; object-fit: contain; }
    
    .pulse { width: 10px; height: 10px; background: var(--cyan); border-radius: 50%; animation: blink 1.2s infinite; box-shadow: 0 0 10px var(--cyan); }
    @keyframes blink { 0%, 100% { opacity: 1; } 50% { opacity: 0.2; } }
    .total-free-val { font-size: 5.5vw; font-weight: 900; color: var(--cyan); line-height: 1; }
    .qr-frame { background: white; padding: 12px; border-radius: 18px; display: inline-block; margin-top: 15px; }
    
    /* Hardware acceleration to stop flashing */
    #ajax-queue-list, #ajax-leaderboard, #ajax-tier-grid {
        will-change: transform, opacity;
        backface-visibility: hidden;
    }
  </style>
</head>
<body>

  <div class="screen">
    <section>
      <div class="brand-row">
        <div class="logo-shell"><img src="vibranium_logo.png"></div>
        <div><h1 style="margin:0; font-size: 2.2vw; letter-spacing: 1px;">VIBRANIUM E-SPORTS</h1><p style="margin:0; color:var(--muted); font-size: 1vw;">LIVE MATCHMAKING STATUS</p></div>
      </div>

      <div class="summary">
        <div class="stat">
          <div style="color: var(--muted); font-size: 0.8vw; text-transform: uppercase;">Waiting</div>
          <div id="ajax-total-queue" style="font-size: 4vw; font-weight: 800;"><?php echo $totalInQueue; ?></div>
        </div>
        <div class="stat">
          <div class="tier-grid" id="ajax-tier-grid">
            <?php foreach($counts as $tier => $val): ?>
              <div style="text-align:center;">
                <div class="tier-num"><?php echo $val; ?></div>
                <div class="tier-label"><?php echo $tier; ?></div>
              </div>
            <?php endforeach; ?>
          </div>
        </div>
      </div>

      <div class="queue-card">
        <div class="queue-head"><div>Pos.</div><div>Player Name</div><div style="text-align:right;">PC Tier</div></div>
        <div id="ajax-queue-list">
          <?php foreach (array_slice($waitingList, 0, 7) as $idx => $p): ?>
            <div class="queue-row">
              <div style="color:var(--primary); font-weight:bold;">#<?php echo $idx+1; ?></div>
              <div style="font-weight: 500;"><?php echo htmlspecialchars($p['username']); ?></div>
              <div style="text-align:right; color:var(--muted); font-size: 0.9em;"><?php echo strtoupper($p['queue_type']); ?></div>
            </div>
          <?php endforeach; ?>
        </div>
      </div>
    </section>

    <aside style="display:flex; flex-direction:column; gap:1.5vw;">
      <div class="panel" style="text-align:center; flex: 1;">
        <div style="text-transform:uppercase; color:var(--muted); font-size:0.9vw; letter-spacing: 1px;">Available Stations</div>
        <div id="ajax-free-pcs" class="total-free-val"><?php echo $availablePcs; ?></div>
        <div style="display:flex; align-items:center; justify-content:center; gap:10px; color:var(--cyan); font-weight:bold; font-size: 0.9vw;">
            <div class="pulse"></div> SYSTEM LIVE
        </div>
        <div class="qr-frame"><div id="qrcode"></div></div>
      </div>

      <div class="panel" style="flex: 1.2;">
        <h3 style="margin:0 0 15px 0; color:var(--cyan); font-size: 1.2vw; text-transform: uppercase;">Leader Board</h3>
        <div id="ajax-leaderboard">
          <?php foreach ($topPlayers as $player):
            $rankImg = "assets/ranks/" . strtolower(str_replace(' ', '', $player['rank'])) . ".png";
            if ($player['rank'] == 'VIBE: Eternal') {
                $rankImg = "assets/ranks/" . "vibe_eternal" . ".png";
            }
            
          ?>
            <div class="leader-row">
              <div style="display:flex; align-items:center; gap:12px;">
                <img src="<?php echo $rankImg; ?>" class="rank-img">
                <div>
                    <div style="font-weight:700; font-size: 1.1vw;"><?php echo htmlspecialchars($player['username']); ?></div>
                    <div style="font-size:0.75vw; color:var(--primary); font-weight: 600;"><?php echo $player['rank']; ?></div>
                </div>
              </div>
              <div style="text-align:right;"><span style="color:var(--cyan); font-weight:800; font-size: 1.1vw;"><?php echo $player['totalSpent']; ?></span> <small style="color:var(--muted);">JD</small></div>
            </div>
          <?php endforeach; ?>
        </div>
      </div>
    </aside>
  </div>

  <script>
    new QRCode(document.getElementById('qrcode'), {
      text: 'https://vibraniumjobooking.com/app_redirect.html',
      width: 200, height: 200, correctLevel : QRCode.CorrectLevel.H
    });

    /**
     * ULTIMATE SMOOTH REFRESH
     * Uses requestAnimationFrame to prevent full-screen flashing
     */
    async function refreshData() {
      try {
        const res = await fetch(window.location.href);
        const html = await res.text();
        
        if (html.includes("Waiting List Offline")) { window.location.reload(); return; }

        const parser = new DOMParser();
        const newDoc = parser.parseFromString(html, 'text/html');
        const containers = ['ajax-total-queue', 'ajax-tier-grid', 'ajax-queue-list', 'ajax-free-pcs', 'ajax-leaderboard'];

        containers.forEach(id => {
          const oldEl = document.getElementById(id);
          const newEl = newDoc.getElementById(id);
          
          if (oldEl && newEl && oldEl.innerHTML.trim() !== newEl.innerHTML.trim()) {
              // Smooth update using the browser's paint cycle
              requestAnimationFrame(() => {
                if (id === 'ajax-total-queue' || id === 'ajax-free-pcs') {
                    oldEl.innerText = newEl.innerText;
                } else {
                    oldEl.style.opacity = '0.7'; // Subtle hint of update
                    oldEl.innerHTML = newEl.innerHTML;
                    requestAnimationFrame(() => {
                        oldEl.style.opacity = '1';
                    });
                }
              });
          }
        });
      } catch (e) { console.error(e); }
    }

    setInterval(refreshData, 5000);
  </script>
</body>
</html>