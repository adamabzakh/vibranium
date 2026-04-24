here is my code

<?php
ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ALL);

/**
 * VIBRANIUM ESPORT - LIVE DASHBOARD (SELF-TRIGGERING)
 */
require_once 'db_config.php'; // 1. Open Connection first

// 2. Run Matchmaker (Pass the existing $conn so it doesn't try to open a new one)
$matchmaker = __DIR__ . '/matchmaker.php';
if (file_exists($matchmaker)) {
    include($matchmaker); 
}
// Fetch Top 5 Players - Change 'total_time' to 'coins' or 'xp' if needed
$leaderQuery = "SELECT username, totalSpent, rank FROM loyality ORDER BY totalSpent DESC LIMIT 5";
$leaderRes = $conn->query($leaderQuery);
$topPlayers = ($leaderRes && $leaderRes->num_rows > 0) ? $leaderRes->fetch_all(MYSQLI_ASSOC) : [];

// Sanitize rank name to match your file names (e.g., "Silver II" -> "silverii")
    $rankClean = strtolower(str_replace(' ', '', $player['rank']));
    $rankImagePath = "assets/ranks/" . $rankClean . ".png"; 

    // Fallback if image doesn't exist
    if (!file_exists($rankImagePath)) {
        $rankImagePath = "assets/ranks/unranked.png";
    }
// --- 2. DATA FETCHING ---
$snapshotFile = __DIR__ . '/pc_last_state.json';
$availablePcs = 0;
$counts = ['Stage' => 0, 'VIP' => 0, 'Normal' => 0, 'MVIP' => 0];

if (file_exists($snapshotFile)) {
    $machines = json_decode(file_get_contents($snapshotFile), true);
    $excludedPcs = ['moza01', 'moza02'];

    foreach ($machines as $pc) {
        $rawName = $pc['name'];
        $normName = str_replace(['-', ' '], '', strtolower(trim($rawName)));
        $isReady = ($pc['state'] === 'ReadyForUser');
        $isEmpty = empty($pc['user_uuid']);
        $isAdmin = in_array($normName, $excludedPcs);

        if ($isReady && $isEmpty && !$isAdmin) {
            $availablePcs++;
            if (stripos($rawName, 'S') !== false) { $counts['Stage']++; } 
            elseif (stripos($rawName, 'MV') !== false) { $counts['MVIP']++; } 
            elseif (stripos($rawName, 'VIP') !== false) { $counts['VIP']++; } 
            else { $counts['Normal']++; }
        }
    }
}

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
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <meta http-equiv="refresh" content="3"> 
  <title>Vibranium Esport - Waiting List</title>
  <script src="https://cdnjs.cloudflare.com/ajax/libs/qrcodejs/1.0.0/qrcode.min.js"></script>
  <style>
    :root {
      --bg: #020205;
      --border: rgba(142, 73, 230, 0.22);
      --primary: #ab63ff;
      --cyan: #2fd5ff;
      --text: #f7f4ff;
      --muted: #9f90bb;
    }
    * { box-sizing: border-box; }
    html, body { margin: 0; width: 100%; height: 100%; overflow: hidden; font-family: Inter, sans-serif; background: linear-gradient(135deg, #010103 0%, #040309 100%); color: var(--text); }
    body { padding: 1.6vh 1.6vw; }
    .screen { width: 100%; height: 100%; border-radius: 28px; background: linear-gradient(180deg, rgba(5, 4, 11, 0.98), rgba(2, 2, 6, 1)); display: grid; grid-template-columns: 1.65fr 0.82fr; gap: 1.1vw; padding: 1.8vh 1.3vw; }
    .brand-row { display: flex; align-items: center; gap: 1.5vw; margin-bottom: 2vh; }
    .logo-shell { width: 80px; height: 80px; }
    .logo-shell img { width: 100%; height: 100%; object-fit: contain; }
    .brand h1 { margin: 0; font-size: 2.5vw; letter-spacing: 1px; }
    .brand p { margin: 0; color: var(--muted); font-size: 1vw; }
    .summary { display: grid; grid-template-columns: 0.7fr 1.3fr; gap: 0.9vw; margin-bottom: 1.4vh; }
    .stat { background: rgba(16, 10, 28, 0.6); border: 1px solid var(--border); border-radius: 22px; padding: 1.5vh; display: flex; flex-direction: column; justify-content: center; }
    .tier-grid { display: flex; justify-content: space-around; width: 100%; }
    .tier-item { text-align: center; }
    .tier-num { font-size: 3vw; font-weight: 800; color: var(--cyan); line-height: 1; }
    .tier-label { font-size: 0.8vw; text-transform: uppercase; color: var(--muted); margin-top: 5px; }
    .queue-card { height: calc(100% - 215px); background: rgba(12, 8, 22, 0.5); border: 1px solid var(--border); border-radius: 26px; overflow: hidden; display: flex; flex-direction: column; }
    .queue-head { display: grid; grid-template-columns: 100px 1fr 180px; padding: 1.2rem 1.4rem; background: rgba(108, 42, 188, 0.15); font-weight: 700; }
    .queue-row { display: grid; grid-template-columns: 100px 1fr 180px; padding: 1.2rem 1.4rem; font-size: 1.5vw; border-bottom: 1px solid rgba(255,255,255,0.03); }
    .position { color: var(--primary); font-weight: 800; }
    .right { display: flex; flex-direction: column; gap: 1vw; }
    .panel { background: rgba(14, 9, 24, 0.8); border: 1px solid var(--border); border-radius: 24px; padding: 1.5rem; flex: 1; }
    .total-free-box { text-align: center; margin-bottom: 1.5vh; border-bottom: 1px solid var(--border); padding-bottom: 1vh; }
    .total-free-val { font-size: 5.5vw; font-weight: 900; color: var(--cyan); line-height: 1; }
    .qr-frame { width: 220px; height: 220px; background: #fff; border-radius: 18px; display: grid; place-items: center; margin: 1.5vh auto; padding: 10px; }
    
    .status-indicator {
      display: flex;
      justify-content: center;
      align-items: center;
      gap: 10px;
      background: rgba(47, 213, 255, 0.1);
      padding: 10px;
      border-radius: 12px;
      margin-top: 10px;
      color: var(--cyan);
      font-size: 0.9vw;
      font-weight: bold;
    }
    /* Leaderboard Styling */
.leader-list {
    display: flex;
    flex-direction: column;
    gap: 8px;
}

.leader-row {
    display: flex;
    align-items: center;
    justify-content: space-between;
    padding: 10px 14px;
    background: rgba(255, 255, 255, 0.03);
    border-radius: 12px;
    border: 1px solid rgba(142, 73, 230, 0.1);
}

.rank-badge {
    width: 28px;
    height: 28px;
    border-radius: 50%;
    display: grid;
    place-items: center;
    font-weight: 900;
    font-size: 0.8vw;
    color: #000;
}

.rank-1 { background: #ffd700; box-shadow: 0 0 10px #ffd700; } /* Gold */
.rank-2 { background: #c0c0c0; } /* Silver */
.rank-3 { background: #cd7f32; } /* Bronze */
.rank-other { background: transparent; border: 1px solid var(--muted); color: var(--muted); }
    .pulse { width: 10px; height: 10px; background: var(--cyan); border-radius: 50%; box-shadow: 0 0 10px var(--cyan); animation: blink 1s infinite; }
    @keyframes blink { 0% { opacity: 1; } 50% { opacity: 0.3; } 100% { opacity: 1; } }
  </style>
</head>
<body>
  <div class="screen">
    <section class="left">
      <div class="brand-row">
        <div class="logo-shell"><img src="vibranium_logo.png" alt="Logo"></div>
        <div class="brand">
          <h1>Vibranium E-Sports</h1>
          <p>Live Waiting List</p>
        </div>
      </div>

      <div class="summary">
        <div class="stat">
          <div style="color: var(--muted); font-size: 0.9vw; text-transform: uppercase;">In Queue</div>
          <div style="font-size: 4vw; font-weight: 800;"><?php echo $totalInQueue; ?></div>
        </div>
        <div class="stat">
          <div class="tier-grid">
            <?php foreach($counts as $tier => $val): ?>
            <div class="tier-item">
              <div class="tier-num"><?php echo $val; ?></div>
              <div class="tier-label"><?php echo $tier; ?></div>
            </div>
            <?php endforeach; ?>
          </div>
        </div>
      </div>

      <div class="queue-card">
        <div class="queue-head">
          <div>Pos.</div>
          <div>Player Name</div>
          <div style="text-align:right;">PC Tier</div>
        </div>
        <div class="queue-list">
          <?php if ($totalInQueue === 0): ?>
            <div style="padding: 50px; text-align: center; opacity: 0.3; font-size: 2vw;">No players waiting</div>
          <?php else: ?>
            <?php foreach (array_slice($waitingList, 0, 8) as $index => $player): ?>
              <div class="queue-row">
                <div class="position">#<?php echo $index + 1; ?></div>
                <div class="name"><?php echo htmlspecialchars($player['username']); ?></div>
                <div style="text-align:right; color: var(--muted); font-size: 0.8em;"><?php echo strtoupper($player['queue_type']); ?></div>
              </div>
            <?php endforeach; ?>
          <?php endif; ?>
        </div>
      </div>
    </section>

    <aside class="right">
      <div class="panel join-card">
        <div class="total-free-box">
          <div style="font-size: 1vw; color: var(--muted); text-transform: uppercase;">Total Free PCs</div>
          <div class="total-free-val"><?php echo $availablePcs; ?></div>
          
          <div class="status-indicator">
            <div class="pulse"></div>
            LIVE ACTIVE
          </div>
        </div>

        <div style="text-align:center;">
          <h2 style="margin:0;">Join the list</h2>
          <div class="qr-frame"><div id="qrcode"></div></div>
          <div style="color: var(--cyan); font-weight: bold; font-size: 1.1vw;">vibraniumjobooking.com</div>
        </div>
      </div>

      <div class="panel leaderboard-panel">
    <h2 style="margin-top:0; font-size: 1.4vw; color: var(--cyan); text-transform: uppercase; letter-spacing: 1px;">Arena Legends</h2>
    <div class="leader-list">
        <?php if (empty($topPlayers)): ?>
            <p style="color: var(--muted); opacity: 0.5; text-align: center;">No rankings available</p>
        <?php else: ?>
            <?php foreach ($topPlayers as $index => $player): 
                $rank = $index + 1;
                $badgeClass = ($rank <= 3) ? "rank-$rank" : "rank-other";
            ?>
                <div class="leader-row">
                    <div style="display: flex; align-items: center; gap: 12px;">
                        <div class="rank-badge <?php echo $badgeClass; ?>"><?php echo $rank; ?></div>
                        <span style="font-weight: 600; font-size: 1.1vw;"><?php echo htmlspecialchars($player['username']); ?></span>
                    </div>
                    <span style="color: var(--primary); font-weight: 800; font-family: monospace;">
                        <?php echo number_format($player['totalSpent']); ?> JD
                    </span>
                </div>
            <?php endforeach; ?>
        <?php endif; ?>
    </div>
</div>
    </aside>
  </div>

  <script>
    new QRCode(document.getElementById('qrcode'), {
      text: 'https://vibraniumjobooking.com/api/app_redirect.php',
      width: 200, height: 200, correctLevel: QRCode.CorrectLevel.H
    });
  </script>
</body>
</html>