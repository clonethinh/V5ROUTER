#!/bin/sh

# ===================================================================
# Setup Script for EM9190 Monitoring - SMS Web Interface
# Port: 8888
# Website Directory: /www/em9190
# ===================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
WEB_DIR="/www/em9190"
CGI_DIR="/www/em9190/cgi-bin"
PORT="8888"
UHTTPD_CONFIG="/etc/config/uhttpd"

echo "=== Sierra Wireless EM9190 Monitoring - SMS Setup ==="
echo "Port: $PORT"
echo "Web Directory: $WEB_DIR"
echo ""

# 1. Tạo thư mục website
echo "Tạo thư mục website..."
mkdir -p "$WEB_DIR"
mkdir -p "$CGI_DIR"
mkdir -p /root/sms-archive



# 2. Tạo file HTML chính
echo "ĐANG TẠO MONITOR EM9190 5G"
echo "Tạo file HTML chính..."
cat > "$WEB_DIR/index.html" << 'EOF'
<!DOCTYPE html>
<html lang="vi" data-theme="dark">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Sierra Wireless EM9190 5G - Enterprise Monitoring System</title> <!-- Tựa đề sẽ được cập nhật bằng JS -->

    <!-- Favicon -->
    <link rel="icon" type="image/svg+xml" href="data:image/svg+xml,<svg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 100 100'><text y='.9em' font-size='90'>📡</text></svg>">

    <!-- Fonts -->
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&family=JetBrains+Mono:wght@300;400;500&display=swap" rel="stylesheet">

    <!-- External Libraries -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
    <script src="https://cdnjs.cloudflare.com/ajax/libs/animejs/3.2.1/anime.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.1/dist/chart.umd.min.js"></script> <!-- Sử dụng CDN Chart.js mới nhất -->

    <style>
        /* ===== CSS VARIABLES ===== */
        :root {
            /* Enterprise Color Palette */
            --primary-gradient: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            --secondary-gradient: linear-gradient(135deg, #f093fb 0%, #f5576c 100%);
            --success-gradient: linear-gradient(135deg, #4facfe 0%, #00f2fe 100%);
            --warning-gradient: linear-gradient(135deg, #ffecd2 0%, #fcb69f 100%);
            --danger-gradient: linear-gradient(135deg, #ff9a9e 0%, #fecfef 100%);

            /* Glass Morphism */
            --glass-bg: rgba(255, 255, 255, 0.08);
            --glass-border: rgba(255, 255, 255, 0.2);
            --glass-blur: blur(20px);
            --glass-shadow: 0 20px 40px rgba(0, 0, 0, 0.1);

            /* Dark Theme */
            --bg-primary: #0a0a0a;
            --bg-secondary: #1a1a2e;
            --bg-tertiary: #16213e;
            --text-primary: #ffffff;
            --text-secondary: #b3b3b3;
            --text-tertiary: #808080;

            /* Spacing */
            --spacing-xs: 4px;
            --spacing-sm: 8px;
            --spacing-md: 16px;
            --spacing-lg: 24px;
            --spacing-xl: 32px;
            --spacing-2xl: 48px;

            /* Border Radius */
            --radius-sm: 8px;
            --radius-md: 12px;
            --radius-lg: 16px;
            --radius-xl: 24px;

            /* Shadows */
            --shadow-soft: 0 4px 20px rgba(0, 0, 0, 0.1);
            --shadow-medium: 0 10px 30px rgba(0, 0, 0, 0.15);
            --shadow-strong: 0 20px 40px rgba(0, 0, 0, 0.2);

            /* Transitions */
            --transition-fast: 0.2s ease;
            --transition-medium: 0.4s cubic-bezier(0.165, 0.84, 0.44, 1);
            --transition-slow: 0.8s cubic-bezier(0.23, 1, 0.32, 1);
        }

        [data-theme="light"] {
            --bg-primary: #f8fafd; /* Đã sửa lỗi chính tả từ f8fafc */
            --bg-secondary: #ffffff;
            --bg-tertiary: #f1f5f9;
            --text-primary: #1e293b;
            --text-secondary: #475569;
            --text-tertiary: #64748b;
            --glass-bg: rgba(255, 255, 255, 0.4);
            --glass-border: rgba(255, 255, 255, 0.6);
        }

        /* ===== RESET & BASE STYLES ===== */
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
            background: var(--bg-primary);
            color: var(--text-primary);
            line-height: 1.6;
            overflow-x: hidden;
            animation: pageReveal 1s var(--transition-medium);
        }

        /* ===== ANIMATIONS ===== */
        @keyframes pageReveal {
            0% { opacity: 0; transform: translateY(30px) scale(0.95); filter: blur(10px); }
            100% { opacity: 1; transform: translateY(0) scale(1); filter: blur(0); }
        }
        @keyframes slideInFromBottom {
            0% { opacity: 0; transform: translateY(50px) scale(0.95); }
            100% { opacity: 1; transform: translateY(0) scale(1); }
        }
        @keyframes pulseGlow {
            0%, 100% { box-shadow: 0 0 20px rgba(102, 126, 234, 0.3); }
            50% { box-shadow: 0 0 40px rgba(102, 126, 234, 0.8); }
        }
        @keyframes shimmer {
            0% { transform: translateX(-100%); }
            100% { transform: translateX(100%); }
        }
        @keyframes borderGlow {
            0%, 100% { opacity: 0.6; }
            50% { opacity: 1; }
        }
        @keyframes ripple {
            0% { transform: scale(1); opacity: 0.8; }
            100% { transform: scale(2); opacity: 0; }
        }
        @keyframes floatUp {
            0%, 100% { transform: translateY(0px); }
            50% { transform: translateY(-10px); }
        }
        @keyframes loadingLine {
            0% { left: -100%; }
            100% { left: 100%; }
        }
        @keyframes speedShimmer { /* Đã sửa tên animation */
            0% { transform: translateX(-100%); }
            100% { transform: translateX(100%); }
        }
        @keyframes searchingPulse {
            0%, 100% { box-shadow: 0 0 0 0 rgba(255, 206, 84, 0.4); }
            50% { box-shadow: 0 0 0 8px rgba(255, 206, 84, 0); }
        }
        @keyframes chartGlow {
            0%, 100% { left: -100%; }
            50% { left: 100%; }
        }
        @keyframes speedPulse {
            0%, 100% { transform: scale(1); }
            50% { transform: scale(1.02); }
        }

        /* ===== LAYOUT STRUCTURE ===== */
        .enterprise-layout {
            min-height: 100vh;
            background: radial-gradient(circle at 20% 50%, rgba(102, 126, 234, 0.1) 0%, transparent 50%), radial-gradient(circle at 80% 20%, rgba(118, 75, 162, 0.1) 0%, transparent 50%), var(--bg-primary);
            position: relative;
        }
        .enterprise-layout::before {
            content: '';
            position: fixed;
            top: 0; left: 0; right: 0; bottom: 0;
            background: repeating-linear-gradient(0deg, transparent, transparent 2px, rgba(255, 255, 255, 0.01) 2px, rgba(255, 255, 255, 0.01) 4px);
            pointer-events: none;
            z-index: -1;
        }
        .dashboard-header {
            position: sticky; top: 0; z-index: 100;
            backdrop-filter: var(--glass-blur);
            background: var(--glass-bg);
            border-bottom: 1px solid var(--glass-border);
            padding: var(--spacing-lg);
        }
        .header-content {
            max-width: 1400px; margin: 0 auto;
            display: flex; justify-content: space-between; align-items: center;
        }
        .brand-section { display: flex; align-items: center; gap: var(--spacing-md); }
        .brand-icon {
            width: 48px; height: 48px;
            background: var(--primary-gradient); border-radius: var(--radius-md);
            display: flex; align-items: center; justify-content: center; font-size: 24px;
            animation: floatUp 3s ease-in-out infinite;
        }
        .brand-text {
            font-size: 24px; font-weight: 700;
            background: var(--primary-gradient); -webkit-background-clip: text; background-clip: text; -webkit-text-fill-color: transparent;
            text-shadow: none;
        }
        .header-controls { display: flex; align-items: center; gap: var(--spacing-md); }
        .control-button {
            padding: 12px 16px;
            background: var(--glass-bg); border: 1px solid var(--glass-border); border-radius: var(--radius-md);
            color: var(--text-primary); cursor: pointer;
            transition: all var(--transition-medium);
            backdrop-filter: var(--glass-blur);
            display: flex; align-items: center; gap: 8px;
            font-size: 14px; font-weight: 500;
        }
        .control-button:hover { transform: translateY(-2px); box-shadow: var(--shadow-medium); background: var(--glass-border); }

        /* ===== DASHBOARD CONTAINER ===== */
        .dashboard-container {
            max-width: 1400px; margin: 0 auto;
            padding: var(--spacing-2xl) var(--spacing-lg);
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(400px, 1fr));
            gap: var(--spacing-lg);
        }

        /* ===== GLASS CARD COMPONENT ===== */
        .glass-card {
            background: var(--glass-bg); backdrop-filter: var(--glass-blur);
            border: 1px solid var(--glass-border); border-radius: var(--radius-xl);
            padding: var(--spacing-xl); box-shadow: var(--glass-shadow);
            transition: all var(--transition-medium);
            position: relative; overflow: hidden;
            animation: slideInFromBottom var(--transition-slow);
            animation-delay: calc(var(--index, 0) * 0.1s); animation-fill-mode: both;
        }
        .glass-card::before { /* Loading line animation */
            content: '';
            position: absolute; top: 0; left: -100%;
            width: 100%; height: 2px;
            background: var(--primary-gradient);
            animation: loadingLine 3s ease-in-out infinite;
        }
        .glass-card:hover { transform: translateY(-8px) scale(1.02); box-shadow: var(--shadow-strong); border-color: rgba(102, 126, 234, 0.4); }
        .card-header {
            display: flex; justify-content: space-between; align-items: center;
            margin-bottom: var(--spacing-lg); padding-bottom: var(--spacing-md);
            border-bottom: 1px solid var(--glass-border);
        }
        .card-title {
            font-size: 18px; font-weight: 600; color: var(--text-primary);
            display: flex; align-items: center; gap: var(--spacing-sm);
        }
        .card-icon {
            width: 24px; height: 24px;
            background: var(--primary-gradient); border-radius: 6px;
            display: flex; align-items: center; justify-content: center; font-size: 12px;
        }

        /* ===== STATUS COMPONENTS ===== */
        #status-badge {
            padding: 8px 16px; border-radius: 20px; font-weight: 600; font-size: 12px;
            text-transform: uppercase; letter-spacing: 0.5px;
            display: inline-flex; align-items: center; gap: 8px;
            position: relative; transition: all var(--transition-fast);
        }
        #status-badge.connected { background: var(--success-gradient); color: white; animation: pulseGlow 2s ease-in-out infinite; }
        #status-badge.disconnected { background: var(--danger-gradient); color: white; }
        #status-badge.loading { background: var(--warning-gradient); color: #333; }
        #status-badge::before { /* Ripple effect */
            content: ''; width: 8px; height: 8px; border-radius: 50%; background: currentColor;
            animation: ripple 1.5s infinite;
        }

        /* ===== REGISTRATION STATUS ===== */
        .registration-registered { color: #4facfe !important; font-weight: 600; }
        .registration-not_registered { color: #ff9a9e !important; font-weight: 600; }
        .registration-searching { color: #ffce54 !important; font-weight: 600; animation: pulse 1.5s ease-in-out infinite; }
        .registration-denied { color: #ff6b6b !important; font-weight: 600; }
        .registration-roaming { color: #a8e6cf !important; font-weight: 600; }
        @keyframes pulse { 0%, 100% { opacity: 1; } 50% { opacity: 0.6; } }

        /* ===== SIGNAL VISUALIZATION ===== */
        #signal-bars { display: flex; align-items: flex-end; gap: 4px; height: 60px; padding: var(--spacing-md) 0; }
        #signal-bars .bar {
            flex: 1; max-width: 12px; background: var(--primary-gradient); border-radius: 6px 6px 0 0;
            position: relative; overflow: hidden; transition: all var(--transition-slow); opacity: 0.3;
        }
        #signal-bars .bar.active { opacity: 1; box-shadow: 0 0 20px rgba(102, 126, 234, 0.5); }
        #signal-bars .bar::after { /* Shimmer effect */
            content: ''; position: absolute; top: 0; left: 0; right: 0; height: 30%;
            background: linear-gradient(to bottom, rgba(255,255,255,0.4), transparent);
            animation: shimmer 2s ease-in-out infinite;
        }

        /* ===== DATA FIELDS ===== */
        .data-row {
            display: flex; justify-content: space-between; align-items: center;
            padding: var(--spacing-sm) 0;
            border-bottom: 1px solid rgba(255, 255, 255, 0.05);
            transition: all var(--transition-fast);
        }
        .data-row:hover { background: rgba(255, 255, 255, 0.02); padding-left: var(--spacing-sm); border-radius: var(--radius-sm); }
        .data-label { font-size: 14px; color: var(--text-secondary); font-weight: 500; }
        .data-value {
            font-size: 14px; color: var(--text-primary); font-weight: 600;
            font-family: 'JetBrains Mono', monospace;
        }
        .data-value.gradient-text { background: var(--primary-gradient); -webkit-background-clip: text; background-clip: text; -webkit-text-fill-color: transparent; }

        /* ===== SPECIALIZED COMPONENTS ===== */
        .ping-indicator { /* Đã thêm lớp cho các kiểu khác nhau */
            display: inline-flex; align-items: center; gap: 6px;
            padding: 4px 8px; border-radius: 12px; font-size: 12px; font-weight: 600;
        }
        .ping-indicator.good { background: rgba(79, 172, 254, 0.2); color: #4facfe; }
        .ping-indicator.fair { background: rgba(255, 206, 84, 0.2); color: #ffce54; }
        .ping-indicator.poor { background: rgba(255, 154, 158, 0.2); color: #ff9a9e; }
        .ping-indicator.bad { background: rgba(255, 107, 107, 0.2); color: #ff6b6b; }
        .ping-indicator.unreachable { background: rgba(128, 128, 128, 0.2); color: #808080; }

        /* ===== SPEED SECTION STYLES ===== */
        .speed-section { margin-top: var(--spacing-lg); padding-top: var(--spacing-lg); border-top: 1px solid var(--glass-border); }
        .speed-header {
            display: flex; justify-content: space-between; align-items: center;
            margin-bottom: var(--spacing-md);
        }
        .speed-header h4 { font-size: 14px; font-weight: 600; color: var(--text-primary); margin: 0; }
        .speed-controls { display: flex; gap: 8px; }
        .mini-button {
            width: 28px; height: 28px;
            background: var(--glass-bg); border: 1px solid var(--glass-border); border-radius: 6px;
            color: var(--text-secondary); cursor: pointer;
            display: flex; align-items: center; justify-content: center; font-size: 12px;
            transition: all var(--transition-fast);
        }
        .mini-button:hover { background: var(--primary-gradient); color: white; transform: scale(1.05); }
        .speed-display { display: flex; flex-direction: column; gap: var(--spacing-md); margin-bottom: var(--spacing-lg); }
        .speed-item { position: relative; }
        .speed-item.download { --speed-color: #4facfe; --speed-gradient: linear-gradient(90deg, #4facfe, #00f2fe); }
        .speed-item.upload { --speed-color: #f093fb; --speed-gradient: linear-gradient(90deg, #f093fb, #f5576c); }
        .speed-info { display: flex; justify-content: space-between; align-items: center; margin-bottom: 8px; }
        .speed-label {
            display: flex; align-items: center; gap: 6px;
            font-size: 12px; color: var(--text-secondary); font-weight: 500;
        }
        .speed-label i { color: var(--speed-color); font-size: 10px; }
        .speed-value { font-family: 'JetBrains Mono', monospace; font-size: 13px; font-weight: 700; }
        .speed-bar {
            height: 6px; background: rgba(255, 255, 255, 0.05); border-radius: 3px; overflow: hidden; position: relative;
        }
        .speed-progress {
            height: 100%; background: var(--speed-gradient); border-radius: 3px; width: 0%;
            transition: width 0.8s cubic-bezier(0.23, 1, 0.32, 1);
            position: relative; overflow: hidden;
        }
        .speed-progress::after { /* Shimmer effect */
            content: ''; position: absolute; top: 0; left: 0; right: 0; bottom: 0;
            background: linear-gradient(90deg, transparent, rgba(255,255,255,0.3), transparent);
            animation: speedShimmer 2s ease-in-out infinite;
        }
        .speed-chart-container {
            height: 120px;
            background: var(--glass-bg); border: 1px solid var(--glass-border); border-radius: var(--radius-md);
            padding: var(--spacing-sm); margin-top: var(--spacing-md);
            position: relative; overflow: hidden; transition: all var(--transition-medium);
        }
        .speed-chart-container::before { /* Glow effect */
            content: ''; position: absolute; top: 0; left: -100%;
            width: 100%; height: 1px; background: var(--primary-gradient);
            animation: chartGlow 3s ease-in-out infinite;
        }
        .speed-chart-container.collapsed { height: 0; padding: 0; margin-top: 0; border: none; }
        #speed-chart { width: 100% !important; height: 100% !important; display: block; }
        .speed-item.active { animation: speedPulse 2s ease-in-out infinite; }

        /* ===== CONTROLS & INTERACTIONS ===== */
        .action-button {
            padding: 8px 16px; background: var(--glass-bg); border: 1px solid var(--glass-border); border-radius: var(--radius-sm);
            color: var(--text-primary); font-size: 12px; font-weight: 500; cursor: pointer;
            transition: all var(--transition-medium);
            display: inline-flex; align-items: center; gap: 6px;
        }
        .action-button:hover { background: var(--primary-gradient); color: white; transform: translateY(-1px); box-shadow: var(--shadow-soft); }
        .dropdown-select {
            padding: 8px 12px; background: var(--glass-bg); border: 1px solid var(--glass-border); border-radius: var(--radius-sm);
            color: var(--text-primary); font-size: 12px; cursor: pointer;
            transition: all var(--transition-fast);
        }
        .dropdown-select:focus { outline: none; border-color: rgba(102, 126, 234, 0.6); box-shadow: 0 0 0 3px rgba(102, 126, 234, 0.1); }

        /* ===== PROGRESS INDICATORS ===== */
        .countdown-timer {
            font-family: 'JetBrains Mono', monospace; font-size: 11px; color: var(--text-tertiary);
            background: var(--glass-bg); padding: 4px 8px; border-radius: 12px; border: 1px solid var(--glass-border);
        }

        /* ===== RESPONSIVE DESIGN ===== */
        @media (max-width: 768px) {
            .dashboard-container { grid-template-columns: 1fr; padding: var(--spacing-lg); gap: var(--spacing-md); }
            .glass-card { padding: var(--spacing-lg); }
            .header-content { flex-direction: column; gap: var(--spacing-md); }
            .brand-text { font-size: 20px; }
            .header-controls { flex-wrap: wrap; justify-content: center; }
            .speed-header { flex-direction: column; align-items: flex-start; gap: 8px; }
            .speed-info { flex-direction: column; align-items: flex-start; gap: 4px; }
            .speed-chart-container { height: 100px; }
            /* Responsive cho signal */
            .signal-visualization { flex-direction: column; gap: var(--spacing-lg); }
            .signal-bars-container { height: 60px; gap: 6px; }
            .signal-bar { width: 12px; }
            .signal-circle { width: 100px; height: 100px; }
            .ping-display { flex-direction: column; gap: var(--spacing-sm); }
        }
        @media (max-width: 480px) {
            .dashboard-container { padding: var(--spacing-md); }
            .glass-card { padding: var(--spacing-md); }
            .data-row { flex-direction: column; align-items: flex-start; gap: 4px; }
        }

        /* ===== UTILITY CLASSES ===== */
        .text-gradient { background: var(--primary-gradient); -webkit-background-clip: text; background-clip: text; -webkit-text-fill-color: transparent; }
        .glow-effect { filter: drop-shadow(0 0 20px rgba(102, 126, 234, 0.3)); }
        .pulse-animation { animation: pulseGlow 2s ease-in-out infinite; }
        .fade-in { animation: slideInFromBottom 0.6s var(--transition-medium); }

        /* ===== LOADING STATES ===== */
        .loading-skeleton {
            background: linear-gradient(90deg, rgba(255,255,255,0.1) 25%, rgba(255,255,255,0.2) 50%, rgba(255,255,255,0.1) 75%);
            background-size: 200% 100%; animation: shimmer 1.5s infinite;
            border-radius: 4px; height: 1em;
        }

        /* ===== TOAST NOTIFICATIONS ===== */
        .toast-container {
            position: fixed; top: 100px; right: 24px; z-index: 1000;
            display: flex; flex-direction: column; gap: 12px;
        }
        .toast {
            padding: 16px 20px;
            background: var(--glass-bg); backdrop-filter: var(--glass-blur);
            border: 1px solid var(--glass-border); border-radius: var(--radius-md);
            color: var(--text-primary); box-shadow: var(--shadow-medium);
            transform: translateX(400px); transition: all var(--transition-medium);
        }
        .toast.show { transform: translateX(0); }
        .toast.success { border-left: 4px solid #4facfe; }
        .toast.error { border-left: 4px solid #ff9a9e; }

        /* ===== CUSTOM SCROLLBAR ===== */
        ::-webkit-scrollbar { width: 8px; }
        ::-webkit-scrollbar-track { background: var(--bg-secondary); }
        ::-webkit-scrollbar-thumb { background: var(--glass-border); border-radius: 4px; }
        ::-webkit-scrollbar-thumb:hover { background: rgba(102, 126, 234, 0.6); }

        /* ===== DATA USAGE STYLING ===== */
        .data-usage-large { font-size: 15px !important; font-weight: 700 !important; background: var(--success-gradient) !important; -webkit-background-clip: text !important; background-clip: text !important; -webkit-text-fill-color: transparent !important; text-shadow: 0 0 20px rgba(79, 172, 254, 0.3); }
        .data-usage-medium { font-weight: 600 !important; color: #4facfe !important; }
        .data-usage-small { color: var(--text-secondary) !important; }
        @keyframes dataUsageUpdate { 0% { transform: scale(1); filter: brightness(1); } 50% { transform: scale(1.05); filter: brightness(1.2); } 100% { transform: scale(1); filter: brightness(1); } }
        .data-usage-updated { animation: dataUsageUpdate 0.6s ease-in-out; }
        .data-icon { font-size: 12px; margin-right: 4px; display: inline-block; animation: iconPulse 2s ease-in-out infinite; }
        @keyframes iconPulse { 0%, 100% { transform: scale(1); } 50% { transform: scale(1.1); } }
        .data-usage-danger { background: var(--danger-gradient) !important; -webkit-background-clip: text !important; background-clip: text !important; -webkit-text-fill-color: transparent !important; }
        .data-usage-warning { background: var(--warning-gradient) !important; -webkit-background-clip: text !important; background-clip: text !important; -webkit-text-fill-color: transparent !important; }
        .data-usage-success { background: var(--success-gradient) !important; -webkit-background-clip: text !important; background-clip: text !important; -webkit-text-fill-color: transparent !important; }
        .data-usage-secondary { color: var(--text-secondary) !important; }

        /* ===== ENHANCED SIGNAL VISUALIZATION ===== */
        .signal-visualization { display: flex; align-items: center; justify-content: space-between; margin: var(--spacing-lg) 0; padding: var(--spacing-lg); background: var(--glass-bg); border-radius: var(--radius-lg); border: 1px solid var(--glass-border); }
        .signal-bars-container { display: flex; align-items: flex-end; gap: 8px; height: 80px; position: relative; }
        .signal-bar {
            width: 16px; height: 100%; position: relative; background: rgba(255, 255, 255, 0.05); border-radius: 8px 8px 0 0; overflow: hidden; transition: all var(--transition-medium);
        }
        .signal-bar[data-level="1"] { height: 20%; } .signal-bar[data-level="2"] { height: 40%; } .signal-bar[data-level="3"] { height: 60%; } .signal-bar[data-level="4"] { height: 80%; } .signal-bar[data-level="5"] { height: 100%; }
        .bar-fill {
            position: absolute; bottom: 0; left: 0; right: 0; height: 0%; background: var(--primary-gradient); border-radius: 8px 8px 0 0; transition: height 1s cubic-bezier(0.23, 1, 0.32, 1); overflow: hidden;
        }
        .bar-fill::after { /* Shimmer */
            content: ''; position: absolute; top: 0; left: 0; right: 0; height: 100%;
            background: linear-gradient(to bottom, rgba(255, 255, 255, 0.4), transparent 70%);
            animation: barShimmer 3s ease-in-out infinite;
        }
        .bar-glow {
            position: absolute; bottom: -2px; left: -2px; right: -2px; height: 4px;
            background: var(--primary-gradient); border-radius: 50%; opacity: 0; filter: blur(4px); transition: opacity var(--transition-medium);
        }
        .signal-bar.active .bar-fill { height: 100%; }
        .signal-bar.active .bar-glow { opacity: 0.8; animation: glowPulse 2s ease-in-out infinite; }
        @keyframes barShimmer { 0%, 100% { transform: translateY(-100%); } 50% { transform: translateY(0); } }
        @keyframes glowPulse { 0%, 100% { opacity: 0.4; transform: scale(1); } 50% { opacity: 1; transform: scale(1.2); } }
        .signal-circle { position: relative; width: 120px; height: 120px; }
        .circle-progress { transform: rotate(-90deg); }
        .circle-bg { fill: none; stroke: rgba(255, 255, 255, 0.1); stroke-width: 8; }
        .circle-fill {
            fill: none; stroke: url(#signalGradient); stroke-width: 8; stroke-linecap: round;
            stroke-dasharray: 314; stroke-dashoffset: 314; transition: stroke-dashoffset 1.5s cubic-bezier(0.23, 1, 0.32, 1);
        }
        .circle-content { position: absolute; top: 50%; left: 50%; transform: translate(-50%, -50%); text-align: center; }
        .circle-value {
            font-size: 24px; font-weight: 700; font-family: 'JetBrains Mono', monospace;
            background: var(--primary-gradient); -webkit-background-clip: text; background-clip: text; -webkit-text-fill-color: transparent; line-height: 1;
        }
        .circle-label { font-size: 11px; color: var(--text-tertiary); text-transform: uppercase; letter-spacing: 1px; margin-top: 4px; }
        .signal-quality-badge {
            display: flex; align-items: center; gap: 8px; padding: 6px 12px;
            background: var(--glass-bg); border: 1px solid var(--glass-border); border-radius: 20px;
            backdrop-filter: var(--glass-blur);
        }
        .signal-percentage { font-family: 'JetBrains Mono', monospace; font-weight: 700; font-size: 14px; background: var(--success-gradient); -webkit-background-clip: text; background-clip: text; -webkit-text-fill-color: transparent; }
        .signal-quality-text { font-size: 11px; text-transform: uppercase; letter-spacing: 0.5px; font-weight: 600; }
        .signal-quality-badge.excellent .signal-quality-text { color: #4facfe; }
        .signal-quality-badge.good .signal-quality-text { color: #00f2fe; }
        .signal-quality-badge.fair .signal-quality-text { color: #ffce54; }
        .signal-quality-badge.poor .signal-quality-text { color: #ff9a9e; }
        .signal-quality-badge.no-signal .signal-quality-text { color: #808080; }
        .signal-metrics { display: grid; grid-template-columns: 1fr; gap: var(--spacing-md); margin-top: var(--spacing-lg); }
        .metric-item { display: flex; align-items: center; gap: var(--spacing-md); padding: var(--spacing-sm) 0; border-bottom: 1px solid rgba(255, 255, 255, 0.05); }
        .metric-label { min-width: 60px; font-size: 12px; font-weight: 500; color: var(--text-secondary); }
        .metric-value { min-width: 80px; font-family: 'JetBrains Mono', monospace; font-weight: 600; font-size: 13px; color: var(--text-primary); }
        .metric-bar { flex: 1; height: 6px; background: rgba(255, 255, 255, 0.05); border-radius: 3px; overflow: hidden; position: relative; }
        .metric-progress { height: 100%; background: var(--primary-gradient); border-radius: 3px; width: 0%; transition: width 1s cubic-bezier(0.23, 1, 0.32, 1); position: relative; }
        .metric-progress::after { /* Shimmer */
            content: ''; position: absolute; top: 0; left: 0; right: 0; bottom: 0;
            background: linear-gradient(90deg, transparent, rgba(255, 255, 255, 0.3), transparent);
            animation: metricShimmer 2s ease-in-out infinite;
        }
        @keyframes metricShimmer { 0% { transform: translateX(-100%); } 100% { transform: translateX(100%); } }

        /* Enhanced Ping Section */
        .ping-section { margin-top: var(--spacing-lg); padding-top: var(--spacing-lg); border-top: 1px solid var(--glass-border); }
        .ping-header {
            display: flex; justify-content: space-between; align-items: center;
            margin-bottom: var(--spacing-md); font-size: 12px; color: var(--text-secondary);
        }
        .ping-host { font-family: 'JetBrains Mono', monospace; font-weight: 600; color: var(--text-primary); }
        .ping-display { display: flex; align-items: center; justify-content: space-between; }
        .ping-indicator.advanced { /* Đã thêm lớp mới */
            display: flex; align-items: center; gap: 8px;
            padding: 12px 16px; background: var(--glass-bg); border: 1px solid var(--glass-border); border-radius: var(--radius-md);
            position: relative; overflow: hidden;
        }
        .ping-pulse {
            width: 12px; height: 12px; border-radius: 50%; background: #4facfe; position: relative;
        }
        .ping-pulse::before {
            content: ''; position: absolute; top: 0; left: 0; right: 0; bottom: 0;
            border-radius: 50%; background: inherit; animation: pingPulse 1.5s ease-out infinite;
        }
        @keyframes pingPulse {
            0% { transform: scale(1); opacity: 1; }
            100% { transform: scale(2.5); opacity: 0; }
        }
        .ping-value { font-family: 'JetBrains Mono', monospace; font-weight: 700; font-size: 18px; color: var(--text-primary); }
        .ping-unit { font-size: 12px; color: var(--text-secondary); font-weight: 500; }
        .ping-quality-text {
            font-size: 12px; font-weight: 600; text-transform: uppercase; letter-spacing: 0.5px;
            padding: 4px 8px; border-radius: 12px; background: rgba(255, 255, 255, 0.05);
        }

        /* SVG Gradient Definition */
        .signal-circle svg defs linearGradient#signalGradient stop:first-child { stop-color: #4facfe; }
        .signal-circle svg defs linearGradient#signalGradient stop:last-child { stop-color: #00f2fe; }

    </style>
</head>

<body>
    <!-- Enterprise Layout Wrapper -->
    <div class="enterprise-layout">
        <!-- Dashboard Header -->
        <header class="dashboard-header" role="banner">
            <div class="header-content">
                <div class="brand-section" aria-label="Brand Information">
                    <div class="brand-icon">📡</div>
                    <h1 class="brand-text" data-i18n="brand">Sierra Wireless AirPrime EM9190 5G NR</h1>
                </div>

                <nav class="header-controls" aria-label="Header Controls">
                    <!-- Language Toggle -->
                    <button class="control-button" id="lang-toggle" aria-label="Toggle Language">
                        <i class="fas fa-globe"></i>
                        <span id="current-lang">VI</span>
                    </button>

                    <!-- Theme Toggle -->
                    <button class="control-button" id="theme-toggle" aria-label="Toggle Theme">
                        <i class="fas fa-moon"></i> <!-- Icon will be updated by JS -->
                        <span data-i18n="theme">Theme</span>
                    </button>

                    <!-- Manual Refresh -->
                    <button class="control-button" id="manual-refresh" aria-label="Manual Refresh">
                        <i class="fas fa-sync"></i>
                        <span data-i18n="refresh">Refresh</span>
                    </button>

                    <!-- Auto Refresh Timer -->
                    <div class="countdown-timer" aria-live="polite">
                        <span data-i18n="next_update">Next update:</span>
                        <span id="countdown">15s</span>
                    </div>
                </nav>
            </div>
        </header>

        <!-- Main Dashboard Container -->
        <main class="dashboard-container" id="main-container" role="main">

            <!-- Connection Information Card -->
            <div class="glass-card fade-in" id="connection-info" style="--index: 0" role="region" aria-labelledby="connection-info-title">
                <div class="card-header">
                    <div class="card-title" id="connection-info-title">
                        <div class="card-icon">🔗</div>
                        <span data-i18n="connection.title">Connection Information</span>
                    </div>
                    <div id="status-badge" class="connected" role="status" aria-live="polite">
                        <span data-i18n="status.connected">Connected</span>
                    </div>
                </div>
                <div class="card-content">
                    <div class="data-row">
                        <span class="data-label" data-i18n="connection.operator">Operator:</span>
                        <span class="data-value" id="operator">-</span>
                    </div>
                    <div class="data-row">
                        <span class="data-label" data-i18n="connection.mcc_mnc">MCC-MNC:</span>
                        <span class="data-value" id="mcc_mnc">-</span>
                    </div>
                    <div class="data-row">
                        <span class="data-label" data-i18n="connection.location">Location:</span>
                        <span class="data-value" id="location">-</span>
                    </div>
                    <div class="data-row">
                        <span class="data-label" data-i18n="connection.mode">Mode:</span>
                        <span class="data-value gradient-text" id="mode">-</span>
                    </div>
                    <div class="data-row">
                        <span class="data-label" data-i18n="connection.registration">Registration:</span>
                        <span class="data-value registration-registered" id="registration">-</span> <!-- Class sẽ được cập nhật bởi JS -->
                    </div>
                    <div class="data-row">
                        <span class="data-label" data-i18n="connection.conn_time">Connection Time:</span>
                        <span class="data-value" id="conn_time">-</span>
                    </div>
                    <div class="data-row">
                        <span class="data-label" data-i18n="connection.ip_wan">WAN IP:</span>
                        <span class="data-value" id="ip_wan">-</span>
                        <button class="action-button" id="reload-ip" aria-label="Reload WAN IP">
                            <i class="fas fa-redo"></i>
                            <span data-i18n="actions.reload">Reload</span>
                        </button>
                    </div>
                </div>
            </div>

            <!-- Device Information Card -->
            <div class="glass-card fade-in" id="device-info" style="--index: 1" role="region" aria-labelledby="device-info-title">
                <div class="card-header">
                    <div class="card-title" id="device-info-title">
                        <div class="card-icon">📱</div>
                        <span data-i18n="device.title">Device Information</span>
                    </div>
                </div>
                <div class="card-content">
                    <div class="data-row">
                        <span class="data-label" data-i18n="device.model">Model:</span>
                        <span class="data-value" id="model">-</span>
                    </div>
                    <div class="data-row">
                        <span class="data-label" data-i18n="device.firmware">Firmware:</span>
                        <span class="data-value" id="firmware">-</span>
                    </div>
                    <div class="data-row">
                        <span class="data-label" data-i18n="device.temperature">Temperature:</span>
                        <span class="data-value" id="temperature">-</span>
                    </div>
                    <div class="data-row">
                        <span class="data-label" data-i18n="device.imei">IMEI:</span>
                        <span class="data-value" id="imei">-</span>
                    </div>
                    <div class="data-row">
                        <span class="data-label" data-i18n="device.port">Port:</span>
                        <span class="data-value" id="cport">-</span>
                    </div>
                    <div class="data-row">
                        <span class="data-label" data-i18n="device.current_apn">Current APN:</span>
                        <span class="data-value" id="current_apn">-</span>
                    </div>
                    <div class="data-row">
                        <span class="data-label" data-i18n="device.change_apn">Change APN:</span>
                        <select class="dropdown-select" id="apn-select" aria-label="Select APN">
                            <option value="auto" data-i18n="apn.auto">Auto</option>
                            <option value="v-internet" data-i18n="apn.viettel">Viettel</option>
                            <option value="m-wap" data-i18n="apn.mobifone">Mobifone</option>
                            <option value="m3-world" data-i18n="apn.vinaphone">Vinaphone</option>
                        </select>
                    </div>
                </div>
            </div>

            <!-- Signal Strength Card - Enhanced Version -->
            <div class="glass-card fade-in" id="signal-info" style="--index: 2" role="region" aria-labelledby="signal-info-title">
                <div class="card-header">
                    <div class="card-title" id="signal-info-title">
                        <div class="card-icon">📶</div>
                        <span data-i18n="signal.title">Signal Strength</span>
                    </div>
                    <div class="signal-quality-badge" id="signal-quality-badge">
                        <span class="signal-percentage" id="signal-percentage">-</span>
                        <span class="signal-quality-text" data-i18n="signal.excellent">Excellent</span> <!-- Text will be updated by JS -->
                    </div>
                </div>
                <div class="card-content">
                    <!-- Enhanced Signal Bars Visualization -->
                    <div class="signal-visualization">
                        <div class="signal-bars-container" id="signal-bars-container" role="img" aria-label="Signal bars visualization">
                            <div class="signal-bar" data-level="1"><div class="bar-fill"></div><div class="bar-glow"></div></div>
                            <div class="signal-bar" data-level="2"><div class="bar-fill"></div><div class="bar-glow"></div></div>
                            <div class="signal-bar" data-level="3"><div class="bar-fill"></div><div class="bar-glow"></div></div>
                            <div class="signal-bar" data-level="4"><div class="bar-fill"></div><div class="bar-glow"></div></div>
                            <div class="signal-bar" data-level="5"><div class="bar-fill"></div><div class="bar-glow"></div></div>
                        </div>
                        <!-- Signal Strength Circle -->
                        <div class="signal-circle" id="signal-circle" role="img" aria-label="Signal strength circle chart">
                            <svg class="circle-progress" width="120" height="120">
                                <defs>
                                    <linearGradient id="signalGradient" x1="0%" y1="0%" x2="100%" y2="0%">
                                        <stop offset="0%" stop-color="#4facfe"></stop>
                                        <stop offset="100%" stop-color="#00f2fe"></stop>
                                    </linearGradient>
                                </defs>
                                <circle class="circle-bg" cx="60" cy="60" r="50"></circle>
                                <circle class="circle-fill" cx="60" cy="60" r="50" id="signal-circle-fill"></circle>
                            </svg>
                            <div class="circle-content">
                                <div class="circle-value" id="circle-signal-value">-</div>
                                <div class="circle-label" data-i18n="signal.strength">Signal</div>
                            </div>
                        </div>
                    </div>
                    <!-- Signal Metrics Grid -->
                    <div class="signal-metrics">
                        <div class="metric-item">
                            <div class="metric-label" data-i18n="signal.csq">CSQ:</div>
                            <div class="metric-value" id="csq">-</div>
                            <div class="metric-bar"><div class="metric-progress" id="csq-progress"></div></div>
                        </div>
                        <div class="metric-item">
                            <div class="metric-label">RSRP:</div>
                            <div class="metric-value" id="rsrp">-</div>
                            <div class="metric-bar"><div class="metric-progress" id="rsrp-progress"></div></div>
                        </div>
                        <div class="metric-item">
                            <div class="metric-label">RSRQ:</div>
                            <div class="metric-value" id="rsrq">-</div>
                            <div class="metric-bar"><div class="metric-progress" id="rsrq-progress"></div></div>
                        </div>
                        <div class="metric-item">
                            <div class="metric-label">RSSI:</div>
                            <div class="metric-value" id="rssi">-</div>
                            <div class="metric-bar"><div class="metric-progress" id="rssi-progress"></div></div>
                        </div>
                        <div class="metric-item">
                            <div class="metric-label">SINR:</div>
                            <div class="metric-value" id="sinr">-</div>
                            <div class="metric-bar"><div class="metric-progress" id="sinr-progress"></div></div>
                        </div>
                    </div>
                    <!-- Ping Information -->
                    <div class="ping-section">
                        <div class="ping-header">
                            <span data-i18n="signal.ping_to">Ping to:</span>
                            <span class="ping-host" id="ping_host">-</span>
                        </div>
                        <div class="ping-display">
                            <div class="ping-indicator advanced" id="ping-indicator">
                                <div class="ping-pulse"></div>
                                <span class="ping-value" id="ping">-</span>
                                <span class="ping-unit">ms</span>
                            </div>
                            <div class="ping-quality-text" id="ping-quality-text">-</div> <!-- Text will be updated by JS -->
                        </div>
                    </div>
                </div>
            </div>

            <!-- Band Information Card -->
            <div class="glass-card fade-in" id="band-info" style="--index: 3" role="region" aria-labelledby="band-info-title">
                <div class="card-header">
                    <div class="card-title" id="band-info-title">
                        <div class="card-icon">📡</div>
                        <span data-i18n="band.title">Band Information</span>
                    </div>
                </div>
                <div class="card-content">
                    <div class="data-row">
                        <span class="data-label" data-i18n="band.primary">Primary Band:</span>
                        <span class="data-value gradient-text" id="pband">-</span>
                    </div>
                    <div class="data-row">
                        <span class="data-label" data-i18n="band.secondary_1">Secondary Band 1:</span>
                        <span class="data-value" id="s1band">-</span>
                    </div>
                    <div class="data-row">
                        <span class="data-label" data-i18n="band.secondary_2">Secondary Band 2:</span>
                        <span class="data-value" id="s2band">-</span>
                    </div>
                    <div class="data-row">
                        <span class="data-label" data-i18n="band.secondary_3">Secondary Band 3:</span>
                        <span class="data-value" id="s3band">-</span>
                    </div>
                    <div class="data-row">
                        <span class="data-label">EARFCN:</span>
                        <span class="data-value" id="earfcn">-</span>
                    </div>
                    <div class="data-row">
                        <span class="data-label">PCI:</span>
                        <span class="data-value" id="pci">-</span>
                    </div>
                </div>
            </div>

            <!-- Data Usage Card -->
            <div class="glass-card fade-in" id="data-info" style="--index: 4" role="region" aria-labelledby="data-info-title">
                <div class="card-header">
                    <div class="card-title" id="data-info-title">
                        <div class="card-icon">📊</div>
                        <span data-i18n="data.title">Data Usage</span>
                    </div>
                </div>
                <div class="card-content">
                    <div class="data-row">
                        <span class="data-label" data-i18n="data.received">Received:</span>
                        <span class="data-value" id="rx_data">-</span> <!-- Sẽ được định dạng bởi JS -->
                    </div>
                    <div class="data-row">
                        <span class="data-label" data-i18n="data.sent">Sent:</span>
                        <span class="data-value" id="tx_data">-</span> <!-- Sẽ được định dạng bởi JS -->
                    </div>
                    <div class="data-row">
                        <span class="data-label">LAC (Dec):</span>
                        <span class="data-value" id="lac_dec">-</span>
                    </div>
                    <div class="data-row">
                        <span class="data-label">LAC (Hex):</span>
                        <span class="data-value" id="lac_hex">-</span>
                    </div>
                    <div class="data-row">
                        <span class="data-label">CID (Dec):</span>
                        <span class="data-value" id="cid_dec">-</span>
                    </div>
                    <div class="data-row">
                        <span class="data-label">CID (Hex):</span>
                        <span class="data-value" id="cid_hex">-</span>
                    </div>
                </div>
            </div>

            <!-- SIM & Speed Information Card -->
            <div class="glass-card fade-in" id="sim-info" style="--index: 5" role="region" aria-labelledby="sim-info-title">
                <div class="card-header">
                    <div class="card-title" id="sim-info-title">
                        <div class="card-icon">💳</div>
                        <span data-i18n="sim.title">SIM Information</span>
                    </div>
                </div>
                <div class="card-content">
                    <div class="data-row">
                        <span class="data-label">IMSI:</span>
                        <span class="data-value" id="imsi">-</span>
                    </div>
                    <div class="data-row">
                        <span class="data-label">ICCID:</span>
                        <span class="data-value" id="iccid">-</span>
                    </div>
                    <div class="data-row">
                        <span class="data-label" data-i18n="sim.protocol">Protocol:</span>
                        <span class="data-value" id="protocol">-</span>
                    </div>

                    <!-- Enhanced Speed Information with Chart -->
                    <div class="speed-section">
                        <div class="speed-header">
                            <h4 data-i18n="speed.realtime_speed">Real-time Speed</h4>
                            <div class="speed-controls">
                                <button class="mini-button" id="speed-chart-toggle" aria-label="Toggle Speed Chart Visibility">
                                    <i class="fas fa-chart-line"></i>
                                </button>
                            </div>
                        </div>

                        <div class="speed-display">
                            <div class="speed-item download">
                                <div class="speed-info">
                                    <span class="speed-label" data-i18n="speed.download">
                                        <i class="fas fa-download"></i>
                                        Download:
                                    </span>
                                    <span class="speed-value gradient-text" id="rx_speed">-</span> <!-- Sẽ được định dạng bởi JS -->
                                </div>
                                <div class="speed-bar"><div class="speed-progress" id="download-progress"></div></div>
                            </div>

                            <div class="speed-item upload">
                                <div class="speed-info">
                                    <span class="speed-label" data-i18n="speed.upload">
                                        <i class="fas fa-upload"></i>
                                        Upload:
                                    </span>
                                    <span class="speed-value gradient-text" id="tx_speed">-</span> <!-- Sẽ được định dạng bởi JS -->
                                </div>
                                <div class="speed-bar"><div class="speed-progress" id="upload-progress"></div></div>
                            </div>
                        </div>

                        <!-- Mini Speed Chart -->
                        <div class="speed-chart-container" id="speed-chart-container">
                            <canvas id="speed-chart"></canvas>
                        </div>
                    </div>
                </div>
            </div>

        </main>
    </div>

    <!-- Toast Container -->
    <div class="toast-container" id="toast-container" aria-live="polite" aria-atomic="true"></div>

    <script>
        // ===== TRANSLATIONS =====
        // (Giữ nguyên object translations như ban đầu, có thể bổ sung thêm nếu cần)
        const translations = {
            vi: {
                brand: "Sierra Wireless AirPrime EM9190 5G NR",
                title: "Sierra Wireless EM9190 5G - Hệ thống giám sát Enterprise",
                theme: "Chủ đề",
                refresh: "Làm mới",
                next_update: "Cập nhật tiếp:",

                connection: {
                    title: "Thông tin kết nối",
                    operator: "Nhà mạng:",
                    mcc_mnc: "MCC-MNC:",
                    location: "Vị trí:",
                    mode: "Chế độ:",
                    registration: "Đăng ký:",
                    conn_time: "Thời gian kết nối:",
                    ip_wan: "IP WAN:"
                },

                device: {
                    title: "Thông tin thiết bị",
                    model: "Model:",
                    firmware: "Firmware:",
                    temperature: "Nhiệt độ:",
                    imei: "IMEI:",
                    port: "Port:",
                    current_apn: "APN hiện tại:",
                    change_apn: "Đổi APN:"
                },

                signal: {
                    title: "Cường độ tín hiệu",
                    csq: "CSQ:",
                    strength: "Signal", // Thêm key cho label của circle
                    excellent: "Excellent", // Default text, sẽ được override bởi lang
                    good: "Good",
                    fair: "Fair",
                    poor: "Poor",
                    no_signal: "No Signal",
                    ping_to: "Ping tới:"
                },

                band: {
                    title: "Thông tin Band",
                    primary: "Band chính:",
                    secondary_1: "Band phụ 1:",
                    secondary_2: "Band phụ 2:",
                    secondary_3: "Band phụ 3:"
                },

                data: {
                    title: "Dữ liệu",
                    received: "Đã nhận:",
                    sent: "Đã gửi:"
                },

                sim: {
                    title: "Thông tin SIM",
                    protocol: "Protocol:"
                },

                speed: {
                    download: "Tải xuống:",
                    upload: "Tải lên:",
                    realtime_speed: "Tốc độ thời gian thực"
                },

                status: {
                    connected: "Đã kết nối",
                    disconnected: "Mất kết nối",
                    loading: "Đang tải"
                },

                actions: {
                    reload: "Reload"
                },

                apn: {
                    auto: "Tự động",
                    viettel: "Viettel",
                    mobifone: "Mobifone",
                    vinaphone: "Vinaphone"
                },

                registration: {
                    "0": "Chưa đăng ký",
                    "1": "Đã đăng ký",
                    "2": "Đang tìm kiếm...",
                    "3": "Từ chối đăng ký",
                    "5": "Đã đăng ký (Roaming)"
                }
            },

            en: {
                brand: "Sierra Wireless AirPrime EM9190 5G NR",
                title: "Sierra Wireless EM9190 5G - Enterprise Monitoring System",
                theme: "Theme",
                refresh: "Refresh",
                next_update: "Next update:",

                connection: {
                    title: "Connection Information",
                    operator: "Operator:",
                    mcc_mnc: "MCC-MNC:",
                    location: "Location:",
                    mode: "Mode:",
                    registration: "Registration:",
                    conn_time: "Connection Time:",
                    ip_wan: "WAN IP:"
                },

                device: {
                    title: "Device Information",
                    model: "Model:",
                    firmware: "Firmware:",
                    temperature: "Temperature:",
                    imei: "IMEI:",
                    port: "Port:",
                    current_apn: "Current APN:",
                    change_apn: "Change APN:"
                },

                signal: {
                    title: "Signal Strength",
                    csq: "CSQ:",
                    strength: "Signal",
                    excellent: "Excellent",
                    good: "Good",
                    fair: "Fair",
                    poor: "Poor",
                    no_signal: "No Signal",
                    ping_to: "Ping to:"
                },

                band: {
                    title: "Band Information",
                    primary: "Primary Band:",
                    secondary_1: "Secondary Band 1:",
                    secondary_2: "Secondary Band 2:",
                    secondary_3: "Secondary Band 3:"
                },

                data: {
                    title: "Data Usage",
                    received: "Received:",
                    sent: "Sent:"
                },

                sim: {
                    title: "SIM Information",
                    protocol: "Protocol:"
                },

                speed: {
                    download: "Download:",
                    upload: "Upload:",
                    realtime_speed: "Real-time Speed"
                },

                status: {
                    connected: "Connected",
                    disconnected: "Disconnected",
                    loading: "Loading"
                },

                actions: {
                    reload: "Reload"
                },

                apn: {
                    auto: "Auto",
                    viettel: "Viettel",
                    mobifone: "Mobifone",
                    vinaphone: "Vinaphone"
                },

                registration: {
                    "0": "Not Registered",
                    "1": "Registered",
                    "2": "Searching...",
                    "3": "Registration Denied",
                    "5": "Registered (Roaming)"
                }
            }
        };

        // ===== GLOBAL VARIABLES =====
        let currentLang = localStorage.getItem('language') || 'vi';
        let currentTheme = localStorage.getItem('theme') || 'dark';
        let updateInterval;
        let countdown = 15;
        let retryCount = 0;
        const MAX_RETRIES = 5;

        // ===== SPEED CHART VARIABLES =====
        let speedChart = null;
        let speedData = { download: [], upload: [], timestamps: [] };
        let maxDataPoints = 20;
        let chartVisible = true;
        let maxSpeed = { download: 0, upload: 0 }; // Giữ giá trị max để scale bar

        // ===== INITIALIZATION =====
        document.addEventListener('DOMContentLoaded', function() {
            initializeApp();
            setupEventListeners();
            startDataUpdates();
        });

        function initializeApp() {
            document.documentElement.lang = currentLang;
            document.documentElement.setAttribute('data-theme', currentTheme);
            updateLanguage();
            updateThemeToggle();
            updateLangToggle();
            initializeAnimations(); // Gọi animation khởi tạo

            // Khởi tạo biểu đồ tốc độ sau một khoảng delay để đảm bảo DOM đã sẵn sàng
            setTimeout(() => {
                initSpeedChart();
                setupSpeedChartControls();
            }, 100);
        }

        // ===== LANGUAGE SYSTEM =====
        function updateLanguage() {
            document.title = translations[currentLang].title; // Cập nhật tiêu đề tài liệu

            const elements = document.querySelectorAll('[data-i18n]');
            elements.forEach(element => {
                const key = element.getAttribute('data-i18n');
                const translation = getNestedTranslation(translations[currentLang], key);
                if (translation !== undefined) { // Chỉ cập nhật nếu có bản dịch
                    element.textContent = translation;
                }
            });
            updateSignalQualityBadgeText(); // Cập nhật văn bản badge tín hiệu
        }

        function getNestedTranslation(obj, key) {
            if (!obj) return undefined;
            return key.split('.').reduce((o, k) => (o && o[k] !== undefined) ? o[k] : undefined, obj);
        }

        function toggleLanguage() {
            currentLang = currentLang === 'vi' ? 'en' : 'vi';
            localStorage.setItem('language', currentLang);
            document.documentElement.lang = currentLang;
            updateLanguage();
            updateLangToggle();

            // Cập nhật nhãn biểu đồ
            if (speedChart) {
                speedChart.data.datasets[0].label = getNestedTranslation(translations[currentLang], 'speed.download');
                speedChart.data.datasets[1].label = getNestedTranslation(translations[currentLang], 'speed.upload');
                speedChart.update();
            }

            showToast(currentLang === 'vi' ? 'Đã chuyển sang Tiếng Việt' : 'Switched to English', 'success');
        }

        function updateLangToggle() {
            const langToggle = document.getElementById('current-lang');
            if (langToggle) langToggle.textContent = currentLang.toUpperCase();
        }

        // ===== THEME SYSTEM =====
        function toggleTheme() {
            currentTheme = currentTheme === 'dark' ? 'light' : 'dark';
            localStorage.setItem('theme', currentTheme);
            document.documentElement.setAttribute('data-theme', currentTheme);
            updateThemeToggle();
            showToast(
                currentLang === 'vi'
                    ? `Đã chuyển sang chế độ ${currentTheme === 'dark' ? 'tối' : 'sáng'}`
                    : `Switched to ${currentTheme} mode`,
                'success'
            );
        }

        function updateThemeToggle() {
            const themeIcon = document.querySelector('#theme-toggle i');
            if (themeIcon) {
                themeIcon.className = currentTheme === 'dark' ? 'fas fa-sun' : 'fas fa-moon';
            }
        }

        // ===== EVENT LISTENERS =====
        function setupEventListeners() {
            const langToggle = document.getElementById('lang-toggle');
            if (langToggle) langToggle.addEventListener('click', toggleLanguage);

            const themeToggle = document.getElementById('theme-toggle');
            if (themeToggle) themeToggle.addEventListener('click', toggleTheme);

            const refreshButton = document.getElementById('manual-refresh');
            if (refreshButton) {
                refreshButton.addEventListener('click', () => {
                    fetchData();
                    showToast(currentLang === 'vi' ? 'Đang làm mới dữ liệu...' : 'Refreshing data...', 'success');
                });
            }

            const apnSelect = document.getElementById('apn-select');
            if (apnSelect) apnSelect.addEventListener('change', handleApnChange);

            const ipReloadButton = document.getElementById('reload-ip');
            if (ipReloadButton) ipReloadButton.addEventListener('click', handleIpReload);

            const speedChartToggleButton = document.getElementById('speed-chart-toggle');
            if (speedChartToggleButton) speedChartToggleButton.addEventListener('click', toggleSpeedChart);

            // Cập nhật lại animation cho các card khi window resize
            window.addEventListener('resize', () => {
                const cards = document.querySelectorAll('.glass-card');
                cards.forEach((card, index) => {
                    // Reset animation delay để đảm bảo thứ tự hiển thị lại
                    card.style.animationDelay = `calc(${index} * 0.1s)`;
                });
            });
        }

        // ===== SPEED CHART INITIALIZATION =====
        function initSpeedChart() {
            const ctx = document.getElementById('speed-chart').getContext('2d');
            if (!ctx) return; // Thoát nếu không tìm thấy canvas

            speedChart = new Chart(ctx, {
                type: 'line',
                data: {
                    labels: [],
                    datasets: [
                        {
                            label: getNestedTranslation(translations[currentLang], 'speed.download'),
                            data: [],
                            borderColor: '#4facfe', // Primary gradient start
                            backgroundColor: 'rgba(79, 172, 254, 0.1)',
                            borderWidth: 2,
                            fill: true,
                            tension: 0.4,
                            pointRadius: 0,
                            pointHoverRadius: 4,
                            pointBackgroundColor: '#4facfe',
                            pointBorderColor: '#ffffff',
                            pointBorderWidth: 2
                        },
                        {
                            label: getNestedTranslation(translations[currentLang], 'speed.upload'),
                            data: [],
                            borderColor: '#f093fb', // Secondary gradient start
                            backgroundColor: 'rgba(240, 147, 251, 0.1)',
                            borderWidth: 2,
                            fill: true,
                            tension: 0.4,
                            pointRadius: 0,
                            pointHoverRadius: 4,
                            pointBackgroundColor: '#f093fb',
                            pointBorderColor: '#ffffff',
                            pointBorderWidth: 2
                        }
                    ]
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    interaction: {
                        intersect: false,
                        mode: 'index'
                    },
                    plugins: {
                        legend: {
                            display: true,
                            position: 'top',
                            align: 'end',
                            labels: {
                                usePointStyle: true,
                                pointStyle: 'circle',
                                font: { size: 10, family: 'Inter' },
                                color: 'rgba(255, 255, 255, 0.8)',
                                boxWidth: 6,
                                boxHeight: 6
                            }
                        },
                        tooltip: {
                            backgroundColor: 'rgba(0, 0, 0, 0.8)',
                            titleColor: '#ffffff',
                            bodyColor: '#ffffff',
                            borderColor: 'rgba(255, 255, 255, 0.2)',
                            borderWidth: 1,
                            cornerRadius: 8,
                            displayColors: true,
                            callbacks: {
                                label: function(context) {
                                    const value = formatSpeedValue(context.parsed.y);
                                    return `${context.dataset.label}: ${value}`;
                                }
                            }
                        }
                    },
                    scales: {
                        x: { display: false, grid: { display: false } },
                        y: {
                            display: true,
                            beginAtZero: true,
                            grid: { color: 'rgba(255, 255, 255, 0.05)', lineWidth: 1 },
                            ticks: {
                                color: 'rgba(255, 255, 255, 0.6)',
                                font: { size: 9, family: 'JetBrains Mono' },
                                maxTicksLimit: 4,
                                callback: function(value) { return formatSpeedValue(value); }
                            }
                        }
                    },
                    elements: { line: { borderCapStyle: 'round', borderJoinStyle: 'round' } },
                    animation: {
                        duration: 0, // Tắt animation cho cập nhật realtime, chỉ dùng cho lần load đầu
                        easing: 'linear'
                    }
                }
            });
        }

        // ===== SPEED DATA UPDATE =====
        function updateSpeedDisplay(data) {
            const rxSpeed = data.rx_speed || '-';
            const txSpeed = data.tx_speed || '-';

            updateFieldWithAnimation('rx_speed', rxSpeed);
            updateFieldWithAnimation('tx_speed', txSpeed);

            const downloadMbps = parseSpeedToMbps(rxSpeed);
            const uploadMbps = parseSpeedToMbps(txSpeed);

            updateSpeedProgressBars(downloadMbps, uploadMbps);
            updateSpeedChart(downloadMbps, uploadMbps);
            updateSpeedActivity(downloadMbps, uploadMbps);
        }

        function parseSpeedToMbps(speedStr) {
            if (!speedStr || speedStr === '-') return 0;
            const match = speedStr.match(/([\d.]+)\s*(B\/s|KB\/s|MB\/s|GB\/s)/i);
            if (!match) return 0;
            const value = parseFloat(match[1]);
            const unit = match[2].toUpperCase();
            switch(unit) {
                case 'B/S': return value / (1024 * 1024);
                case 'KB/S': return value / 1024;
                case 'MB/S': return value;
                case 'GB/S': return value * 1024;
                default: return 0;
            }
        }

        function updateSpeedProgressBars(downloadMbps, uploadMbps) {
            const downloadProgress = document.getElementById('download-progress');
            const uploadProgress = document.getElementById('upload-progress');

            // Cập nhật max speed cho việc scale
            maxSpeed.download = Math.max(maxSpeed.download, downloadMbps || 1);
            maxSpeed.upload = Math.max(maxSpeed.upload, uploadMbps || 1);

            const downloadPercent = Math.min(100, (downloadMbps / maxSpeed.download) * 100);
            const uploadPercent = Math.min(100, (uploadMbps / maxSpeed.upload) * 100);

            if (downloadProgress) downloadProgress.style.width = `${downloadPercent}%`;
            if (uploadProgress) uploadProgress.style.width = `${uploadPercent}%`;
        }

        function updateSpeedChart(downloadMbps, uploadMbps) {
            if (!speedChart) return;

            const now = new Date();
            const timeLabel = now.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit', second: '2-digit' });

            speedData.download.push(downloadMbps);
            speedData.upload.push(uploadMbps);
            speedData.timestamps.push(timeLabel);

            if (speedData.download.length > maxDataPoints) {
                speedData.download.shift();
                speedData.upload.shift();
                speedData.timestamps.shift();
            }

            speedChart.data.labels = speedData.timestamps;
            speedChart.data.datasets[0].data = speedData.download;
            speedChart.data.datasets[1].data = speedData.upload;

            // Tự động điều chỉnh trục Y
            const chartMax = Math.max(maxSpeed.download, maxSpeed.upload, 1);
            speedChart.options.scales.y.max = chartMax * 1.1;

            // Cập nhật mà không có animation cho realtime feed
            speedChart.update('none');
        }

        function updateSpeedActivity(downloadMbps, uploadMbps) {
            const downloadItem = document.querySelector('.speed-item.download');
            const uploadItem = document.querySelector('.speed-item.upload');
            const threshold = 0.01; // Ngưỡng Mbps để coi là có hoạt động

            if (downloadItem) downloadItem.classList.toggle('active', downloadMbps > threshold);
            if (uploadItem) uploadItem.classList.toggle('active', uploadMbps > threshold);
        }

        function formatSpeedValue(mbps) {
            if (mbps === 0) return '0 B/s';
            if (mbps < 0.001) return (mbps * 1024 * 1024).toFixed(0) + ' B/s'; // Dưới 1 KB/s
            if (mbps < 1) return (mbps * 1024).toFixed(1) + ' KB/s';
            if (mbps < 1000) return mbps.toFixed(2) + ' MB/s';
            return (mbps / 1024).toFixed(2) + ' GB/s';
        }

        // ===== CHART TOGGLE FUNCTIONALITY =====
        function toggleSpeedChart() {
            chartVisible = !chartVisible;
            const chartContainer = document.getElementById('speed-chart-container');
            const toggleButton = document.getElementById('speed-chart-toggle');

            if (chartContainer) {
                chartContainer.classList.toggle('collapsed', !chartVisible);
            }
            if (toggleButton) {
                const icon = toggleButton.querySelector('i');
                if (icon) icon.className = chartVisible ? 'fas fa-chart-line' : 'fas fa-chart-line-down';
            }

            if (chartVisible && speedChart) {
                // Điều chỉnh kích thước biểu đồ khi hiển thị lại
                setTimeout(() => speedChart.resize(), 300);
            }
        }
        // ===== SPEED CHART CONTROLS SETUP =====
        function setupSpeedChartControls() {
            const speedChartToggleButton = document.getElementById('speed-chart-toggle');
            // Kiểm tra xem nút có tồn tại không trước khi thêm listener
            if (speedChartToggleButton) {
                speedChartToggleButton.addEventListener('click', toggleSpeedChart);
                console.log('setupSpeedChartControls: Event listener added for speed chart toggle.');
            } else {
                console.warn('setupSpeedChartControls: speed-chart-toggle button not found.');
            }
        }

        // ===== DATA FETCHING =====
        async function fetchData() {
            try {
                const response = await fetch('/cgi-bin/em9190-info', {
                    headers: { 'Cache-Control': 'no-cache', 'Pragma': 'no-cache' }
                });

                if (!response.ok) {
                    throw new Error(`HTTP Error: ${response.status}`);
                }
                const data = await response.json();
                updateUI(data);
                resetRetryCount();

            } catch (error) {
                console.error('Data fetch error:', error);
                handleFetchError();
            }
        }

        // ===== ENHANCED SIGNAL UPDATE FUNCTIONS =====
        function updateSignalVisualization(data) {
            const signalPercent = parseInt(data.signal) || 0;
            const csq = parseInt(data.csq) || 0;
            const rsrp = parseFloat(data.rsrp) || 0;
            const rsrq = parseFloat(data.rsrq) || 0;
            const rssi = parseFloat(data.rssi) || 0;
            const sinr = parseFloat(data.sinr) || 0;

            updateSignalBars(signalPercent);
            updateSignalCircle(signalPercent);
            updateSignalQualityBadge(signalPercent);
            updateMetricBars({ csq, rsrp, rsrq, rssi, sinr });
        }

        function updateSignalBars(signalPercent) {
            const bars = document.querySelectorAll('.signal-bar');
            const activeBarCount = Math.ceil((signalPercent / 100) * bars.length);

            bars.forEach((bar, index) => {
                const fill = bar.querySelector('.bar-fill');
                if (index < activeBarCount) {
                    bar.classList.add('active');
                    // Animation delay để các bar hiện lên tuần tự
                    setTimeout(() => {
                        if (fill) fill.style.height = '100%';
                    }, index * 50); // 50ms delay giữa các bar
                } else {
                    bar.classList.remove('active');
                    if (fill) fill.style.height = '0%';
                }
            });
        }

        function updateSignalCircle(signalPercent) {
            const circleFill = document.getElementById('signal-circle-fill');
            const circleValue = document.getElementById('circle-signal-value');
            const circumference = 2 * Math.PI * 50; // radius = 50
            const offset = circumference - (Math.min(signalPercent, 100) / 100) * circumference;

            if (circleFill) circleFill.style.strokeDashoffset = offset;
            if (circleValue) animateValue(circleValue, 0, signalPercent, 1500); // Animate value từ 0 đến signalPercent
        }

        function updateSignalQualityBadge(signalPercent) {
            const badge = document.getElementById('signal-quality-badge');
            const percentage = document.getElementById('signal-percentage');

            if (!badge || !percentage) return;

            percentage.textContent = `${signalPercent}%`;

            let quality, qualityKey;
            if (signalPercent >= 80) { quality = 'excellent'; qualityKey = 'signal.excellent'; }
            else if (signalPercent >= 60) { quality = 'good'; qualityKey = 'signal.good'; }
            else if (signalPercent >= 40) { quality = 'fair'; qualityKey = 'signal.fair'; }
            else if (signalPercent >= 20) { quality = 'poor'; qualityKey = 'signal.poor'; }
            else { quality = 'no-signal'; qualityKey = 'signal.no_signal'; }

            // Cập nhật class và key cho text
            badge.className = `signal-quality-badge ${quality}`;
            const qualityTextElement = badge.querySelector('.signal-quality-text');
            if (qualityTextElement) {
                qualityTextElement.setAttribute('data-i18n', qualityKey);
            }
            updateSignalQualityBadgeText(); // Gọi hàm để update text dựa trên ngôn ngữ
        }

        // Hàm riêng để update text của signal quality badge
        function updateSignalQualityBadgeText() {
            const badge = document.getElementById('signal-quality-badge');
            if (!badge) return;
            const qualityTextElement = badge.querySelector('.signal-quality-text');
            const currentQualityClass = Array.from(badge.classList).find(cls => cls !== 'signal-quality-badge' && cls !== 'excellent' && cls !== 'good' && cls !== 'fair' && cls !== 'poor' && cls !== 'no-signal');
            const qualityKey = `signal.${currentQualityClass || 'no-signal'}`; // Fallback

            if (qualityTextElement) {
                const translation = getNestedTranslation(translations[currentLang], qualityKey);
                if (translation !== undefined) {
                    qualityTextElement.textContent = translation;
                }
            }
        }

        function updateMetricBars(metrics) {
            updateMetricBar('csq-progress', metrics.csq, 31); // CSQ: 0-31
            updateMetricBar('rsrp-progress', Math.max(0, Math.min(100, ((metrics.rsrp + 140) / 96) * 100)), 100); // RSRP: -140 đến -44 dBm -> 0-100%
            updateMetricBar('rsrq-progress', Math.max(0, Math.min(100, ((metrics.rsrq + 19.5) / 16.5) * 100)), 100); // RSRQ: -19.5 đến -3 dB -> 0-100%
            updateMetricBar('rssi-progress', Math.max(0, Math.min(100, ((metrics.rssi + 110) / 80) * 100)), 100); // RSSI: -110 đến -30 dBm -> 0-100%
            updateMetricBar('sinr-progress', Math.max(0, Math.min(100, ((metrics.sinr + 10) / 50) * 100)), 100); // SINR: -10 đến 40 dB -> 0-100%
        }

        function updateMetricBar(elementId, value, maxValue) {
            const progressBar = document.getElementById(elementId);
            if (!progressBar) return;
            const percentage = Math.min(100, (value / maxValue) * 100);
            progressBar.style.width = `${percentage}%`;
        }

        function animateValue(element, start, end, duration) {
            let startTime = null;
            function step(timestamp) {
                if (!startTime) startTime = timestamp;
                const elapsed = timestamp - startTime;
                const progress = Math.min(elapsed / duration, 1);
                const easeOut = 1 - Math.pow(1 - progress, 3); // Ease-out cubic
                const current = Math.round(start + (end - start) * easeOut);

                element.textContent = `${current}%`;

                if (progress < 1) requestAnimationFrame(step);
            }
            requestAnimationFrame(step);
        }

        // ===== CẬP NHẬT HÀM updateUI =====
        function updateUI(data) {
            updateConnectionStatus(data.status);
            updateSignalVisualization(data);
            updateRegistrationStatus(data.registration);

            // Update các trường dữ liệu
            const fieldMap = {
                'operator': 'operator', 'mcc_mnc': 'mcc_mnc', 'location': 'location',
                'mode': 'technology', 'conn_time': 'conn_time', 'ip_wan': 'ip_wan',
                'model': 'modem', 'firmware': 'firmware', 'temperature': 'temperature',
                'imei': 'imei', 'cport': 'cport', 'current_apn': 'current_apn',
                'csq': 'csq', 'signal': 'signal', 'rsrp': 'rsrp', 'rsrq': 'rsrq',
                'rssi': 'rssi', 'sinr': 'sinr', 'ping': 'ping', 'ping_host': 'ping_host',
                'pband': 'pband', 's1band': 's1band', 's2band': 's2band', 's3band': 's3band',
                'earfcn': 'earfcn', 'pci': 'pci',
                'lac_dec': 'lac_dec', 'lac_hex': 'lac_hex', 'cid_dec': 'cid_dec', 'cid_hex': 'cid_hex',
                'imsi': 'imsi', 'iccid': 'iccid', 'protocol': 'protocol'
            };

            Object.entries(fieldMap).forEach(([elementId, dataKey]) => {
                const value = data[dataKey];
                if (elementId === 'temperature' && value !== undefined && value !== '-') {
                    updateFieldWithAnimation(elementId, `${value}°C`); // Định dạng nhiệt độ
                } else {
                    updateFieldWithAnimation(elementId, value);
                }
            });

            // Xử lý riêng cho Data Usage và Speed
            updateDataUsage(data.rx_data, data.tx_data);
            updateSpeedDisplay(data);
            updatePingIndicator(data.ping, data.ping_quality);
        }

        // ===== HÀM NÂNG CAO ĐỂ XỬ LÝ DATA USAGE =====
        function updateDataUsage(rxBytes, txBytes) {
            const formattedRx = formatBytesAdvanced(parseInt(rxBytes) || 0, 'download');
            const formattedTx = formatBytesAdvanced(parseInt(txBytes) || 0, 'upload');

            updateDataUsageElement('rx_data', formattedRx);
            updateDataUsageElement('tx_data', formattedTx);
        }

        function formatBytesAdvanced(bytes, type) {
            if (bytes <= 0) return { value: '-', unit: '', icon: '', color: 'secondary', fullText: '-' };
            const k = 1024;
            const sizes = ['B', 'KB', 'MB', 'GB', 'TB'];
            const i = Math.floor(Math.log(bytes) / Math.log(k));
            const sizeIndex = Math.min(i, sizes.length - 1);
            const value = bytes / Math.pow(k, sizeIndex);

            let formattedValue;
            if (sizeIndex === 0) formattedValue = bytes.toString();
            else if (value >= 100) formattedValue = value.toFixed(0);
            else if (value >= 10) formattedValue = value.toFixed(1);
            else formattedValue = value.toFixed(2);

            // Xác định màu sắc và icon dựa trên kích thước và loại (download/upload)
            let color, icon;
            if (sizeIndex >= 4) { color = 'danger'; icon = type === 'download' ? '📥' : '📤'; } // TB
            else if (sizeIndex >= 3) { color = 'warning'; icon = type === 'download' ? '⬇️' : '⬆️'; } // GB
            else if (sizeIndex >= 2) { color = 'success'; icon = type === 'download' ? '📊' : '📈'; } // MB
            else { color = 'secondary'; icon = type === 'download' ? '📋' : '📑'; } // KB/B

            return { value: formattedValue, unit: sizes[sizeIndex], icon: icon, color: color, fullText: `${formattedValue} ${sizes[sizeIndex]}` };
        }

        function updateDataUsageElement(elementId, dataInfo) {
            const element = document.getElementById(elementId);
            if (!element) return;

            const displayText = dataInfo.fullText;
            const oldValue = element.textContent.trim(); // Lấy text hiện tại và trim khoảng trắng

            // Chỉ cập nhật nếu có sự thay đổi và không phải là '-' ban đầu
            if (oldValue !== displayText && (oldValue !== '-' || displayText !== '-')) {
                // Thêm animation update
                element.style.transition = 'transform 0.2s ease, color 0.2s ease';
                element.style.transform = 'scale(1.05)';
                element.style.color = '#4facfe'; // Màu tạm thời

                setTimeout(() => {
                    // Cập nhật nội dung HTML (bao gồm icon) và class
                    element.innerHTML = `<span class="data-icon">${dataInfo.icon}</span> ${displayText}`;
                    element.className = `data-value data-usage-${dataInfo.color}`; // Cập nhật class màu
                    // Thêm class styling theo kích thước
                    if (dataInfo.color === 'danger') element.classList.add('data-usage-large');
                    else if (dataInfo.color === 'warning') element.classList.add('data-usage-medium');
                    else element.classList.add('data-usage-small');

                    element.style.transform = 'scale(1)';
                    element.style.color = ''; // Reset màu
                }, 200);
            } else if (oldValue === '-' && displayText === '-') {
                // Nếu cả hai đều là '-', đảm bảo element có class mặc định và không bị ảnh hưởng animation
                element.innerHTML = '-';
                element.className = 'data-value';
            }
        }

        function updateRegistrationStatus(regStatus) {
            const regElement = document.getElementById('registration');
            if (!regElement) return;

            const statusMap = { '0': 'not_registered', '1': 'registered', '2': 'searching', '3': 'denied', '5': 'roaming' };
            const statusKey = regStatus ? regStatus.toString() : '0'; // Mặc định là '0' (Chưa đăng ký)
            const translation = getNestedTranslation(translations[currentLang], `registration.${statusKey}`) || getNestedTranslation(translations[currentLang], 'registration.0');
            const statusClass = statusMap[statusKey] || 'not_registered';

            updateFieldWithAnimation('registration', translation); // Cập nhật text với animation
            regElement.className = `data-value registration-${statusClass}`; // Cập nhật class CSS
        }

        function updateFieldWithAnimation(elementId, value) {
            const element = document.getElementById(elementId);
            if (!element) return;

            const sanitizedValue = value === undefined || value === null || value === '' ? '-' : String(value);
            const oldValue = element.textContent.trim();

            if (oldValue !== sanitizedValue) {
                element.style.transition = 'transform 0.15s ease-in-out, color 0.15s ease-in-out';
                element.style.transform = 'scale(1.05)';
                element.style.color = '#4facfe'; // Màu tạm thời

                setTimeout(() => {
                    element.textContent = sanitizedValue;
                    element.style.transform = 'scale(1)';
                    element.style.color = ''; // Reset màu
                }, 150);
            }
        }

        function updateConnectionStatus(status) {
            const statusBadge = document.getElementById('status-badge');
            const statusTextSpan = statusBadge ? statusBadge.querySelector('span') : null;

            if (!statusBadge) return;

            // Xóa các lớp trạng thái cũ và thêm lớp mới
            statusBadge.classList.remove('connected', 'disconnected', 'loading');
            statusBadge.classList.add(status || 'loading'); // Mặc định là loading nếu status không rõ

            // Cập nhật văn bản
            let statusKey;
            switch(status) {
                case 'connected': statusKey = 'status.connected'; break;
                case 'disconnected': statusKey = 'status.disconnected'; break;
                default: statusKey = 'status.loading'; break;
            }
            const translation = getNestedTranslation(translations[currentLang], statusKey);
            if (statusTextSpan && translation) {
                statusTextSpan.textContent = translation;
            }
        }

        function updatePingIndicator(ping, quality) {
            const indicator = document.getElementById('ping-indicator');
            const pingValue = document.getElementById('ping');
            const pingQualityText = document.getElementById('ping-quality-text');

            if (!indicator || !pingValue || !pingQualityText) return;

            indicator.classList.remove('good', 'fair', 'poor', 'bad', 'unreachable'); // Xóa các lớp cũ
            if (quality) {
                indicator.classList.add(quality); // Thêm lớp chất lượng mới
            }

            pingValue.textContent = ping || '-';

            // Cập nhật văn bản chất lượng ping
            const qualityTranslationKey = `ping_quality.${quality}` // Giả sử có key này trong translations
            const translation = getNestedTranslation(translations[currentLang], qualityTranslationKey) || quality || '-';
            pingQualityText.textContent = translation;
        }

        // ===== ERROR HANDLING =====
        function handleFetchError() {
            retryCount++;
            const message = currentLang === 'vi'
                ? `Lỗi kết nối. Thử lại ${retryCount}/${MAX_RETRIES}...`
                : `Connection error. Retry ${retryCount}/${MAX_RETRIES}...`;
            showToast(message, 'error');

            if (retryCount <= MAX_RETRIES) {
                // Exponential backoff: 2s, 4s, 8s, 16s, 32s
                const delay = Math.pow(2, retryCount) * 1000;
                setTimeout(fetchData, delay);
            } else {
                const finalMessage = currentLang === 'vi'
                    ? 'Không thể kết nối tới thiết bị'
                    : 'Unable to connect to device';
                showToast(finalMessage, 'error');
                updateConnectionStatus('disconnected');
            }
        }

        function resetRetryCount() {
            retryCount = 0;
        }

        // ===== ACTIONS =====
        async function handleApnChange(event) {
            const newApn = event.target.value;
            const currentApnElement = document.getElementById('current_apn');

            showToast(currentLang === 'vi' ? 'Đang thay đổi APN...' : 'Changing APN...', 'success');
            try {
                // Giả định API backend nhận request POST hoặc GET với action/value
                const response = await fetch(`/cgi-bin/em9190-info?action=set_apn&value=${newApn}`, { method: 'POST' }); // Giả định POST
                const result = await response.json();

                if (result.status === 'ok') {
                    showToast(currentLang === 'vi' ? `APN đã được đổi thành: ${newApn}` : `APN changed to: ${newApn}`, 'success');
                    if (currentApnElement) currentApnElement.textContent = newApn;
                } else {
                    throw new Error(result.message || 'APN change failed');
                }
            } catch (error) {
                showToast(currentLang === 'vi' ? 'Lỗi khi thay đổi APN' : 'Error changing APN', 'error');
                console.error('APN change error:', error);
            }
        }

        async function handleIpReload() {
            showToast(currentLang === 'vi' ? 'Đang khởi động lại kết nối...' : 'Restarting connection...', 'success');
            try {
                const response = await fetch('/cgi-bin/em9190-info?action=restart', { method: 'POST' }); // Giả định POST
                const result = await response.json();

                if (result.status === 'ok') {
                    showToast(currentLang === 'vi' ? 'Đã khởi động lại modem' : 'Modem restarted successfully', 'success');
                    // Sau khi khởi động lại, chờ một chút rồi làm mới dữ liệu
                    setTimeout(fetchData, 5000); // Chờ 5 giây
                } else {
                    throw new Error(result.message || 'Restart failed');
                }
            } catch (error) {
                showToast(currentLang === 'vi' ? 'Lỗi khi khởi động lại' : 'Error restarting modem', 'error');
                console.error('Restart error:', error);
            }
        }

        // ===== AUTO UPDATE SYSTEM =====
        function startDataUpdates() {
            fetchData(); // Lần fetch đầu tiên khi tải trang

            updateInterval = setInterval(() => {
                countdown--;
                updateCountdown();
                if (countdown <= 0) {
                    fetchData();
                    countdown = 15; // Reset lại bộ đếm
                }
            }, 1000);
        }

        function updateCountdown() {
            const countdownElement = document.getElementById('countdown');
            if (countdownElement) countdownElement.textContent = `${countdown}s`;
        }

        // ===== ANIMATIONS =====
        // Các animation phức tạp (như chart, signal bars) đã được tích hợp vào hàm update tương ứng
        // Chỉ giữ lại animation entry cho các card chính
        function initializeAnimations() {
            const cards = document.querySelectorAll('.glass-card');
            cards.forEach((card, index) => {
                card.style.setProperty('--index', index);
                // Cần đảm bảo animation được kích hoạt sau khi DOM được render
                // Thêm một chút delay hoặc sử dụng setTimeout để kích hoạt
                setTimeout(() => {
                    card.style.animation = `slideInFromBottom ${getAnimationDuration(card)} var(--transition-slow) forwards`;
                    card.style.animationDelay = `calc(${index} * 0.1s)`;
                }, 50);
            });
             // Animation cho header
            const header = document.querySelector('.dashboard-header');
            if (header) {
                setTimeout(() => {
                    header.style.animation = `pageReveal 0.8s var(--transition-medium) forwards`;
                }, 50);
            }
        }

        // Hàm trợ giúp để lấy thời lượng animation từ CSS (ước lượng)
        function getAnimationDuration(element) {
            // Cố gắng lấy duration từ CSS, nếu không dùng mặc định
            const style = window.getComputedStyle(element);
            const animationDuration = style.getPropertyValue('animation-duration');
            return animationDuration || '0.8s';
        }

        // ===== TOAST NOTIFICATIONS =====
        function showToast(message, type = 'success') {
            const toastContainer = document.getElementById('toast-container');
            if (!toastContainer) return;

            const toast = document.createElement('div');
            toast.className = `toast ${type}`;
            toast.innerHTML = `
                <i class="fas fa-${type === 'success' ? 'check-circle' : 'exclamation-circle'}"></i>
                <span>${message}</span>
            `;
            toastContainer.appendChild(toast);

            // Show toast
            setTimeout(() => toast.classList.add('show'), 10); // Dùng setTimeout nhỏ để đảm bảo transition hoạt động

            // Hide and remove toast
            setTimeout(() => {
                toast.classList.remove('show');
                toast.addEventListener('transitionend', () => toastContainer.removeChild(toast), { once: true });
            }, 3000); // Toast hiển thị trong 3 giây
        }

        // ===== UTILITY FUNCTIONS =====
        // Hàm format byte đã được nâng cấp ở trên (formatBytesAdvanced)

        // ===== CLEANUP ON UNLOAD =====
        window.addEventListener('beforeunload', () => {
            if (updateInterval) clearInterval(updateInterval);
        });

    </script>
</body>
</html>
EOF

echo "đang tạo ping-info..."
cat > "$CGI_DIR/ping-info" << 'EOF'
#!/bin/sh
echo "Content-Type: application/json"
echo ""

HOST="8.8.8.8"
PING_MS=$(ping -c 1 -W 1 "$HOST" 2>/dev/null | awk -F'time=' '/time=/{print $2}' | cut -d' ' -f1)

if echo "$PING_MS" | grep -qE '^[0-9.]+'; then
    VAL=$(printf "%.0f" "$PING_MS")
    if [ "$VAL" -lt 20 ]; then QUALITY="good"
    elif [ "$VAL" -lt 50 ]; then QUALITY="fair"
    elif [ "$VAL" -lt 100 ]; then QUALITY="poor"
    else QUALITY="bad"
    fi
else
    PING_MS="-"
    QUALITY="unreachable"
fi

echo "{\"ping\":\"$PING_MS\", \"quality\":\"$QUALITY\"}"
EOF

# 3. Tạo CGI script
echo "Tạo CGI script..."
cat > "$CGI_DIR/em9190-info" << 'EOF'
#!/bin/sh
exec 2>/dev/null
echo "Content-Type: application/json"
echo ""

DEVICE="/dev/ttyUSB0"

# ==== HÀM PHỤ ====

# Lấy một dòng phản hồi từ lệnh AT, lọc theo chuỗi và lấy dòng cuối
get_at_response() {
    CMD="$1"
    FILTER="$2"
    sms_tool -d "$DEVICE" at "$CMD" > /tmp/at_resp.txt 2>/dev/null
    grep "$FILTER" /tmp/at_resp.txt | tail -1
}

# Lấy một giá trị duy nhất từ kết quả lệnh AT, loại bỏ các dòng không cần thiết
get_single_line_value() {
    CMD="$1"
    sms_tool -d "$DEVICE" at "$CMD" 2>/dev/null | grep -vE '^(AT|\s*OK|\s*$)' | head -1 | tr -d '\r\n '
}

# Lấy IMSI của SIM
get_imsi() {
    get_single_line_value "AT+CIMI"
}

# Lấy ICCID của SIM
get_iccid() {
    sms_tool -d "$DEVICE" at "AT+ICCID" 2>/dev/null | grep -i "ICCID" | awk -F: '{print $2}' | tr -d '\r\n "'
}

# Làm sạch chuỗi: thay thế chuỗi rỗng bằng "-" và xóa ký tự xuống dòng
sanitize_string() {
    [ -z "$1" ] && echo "-" || echo "$1" | tr -d '\r\n'
}

# Làm sạch số: thay thế chuỗi rỗng bằng "-"
sanitize_number() {
    [ -z "$1" ] && echo "-" || echo "$1"
}

# ==== INTERFACE VÀ IP WAN ====
# Phát hiện tên interface mạng đang hoạt động (wwan0, eth2, usb0, 5G, hoặc interface có default route)
detect_interface() {
    if ifconfig wwan0 2>/dev/null | grep -q "inet "; then
        echo "wwan0"
    elif ifconfig br-lan 2>/dev/null | grep -q "inet "; then
        echo "br-lan"
    else
        for iface in eth2 usb0 5G; do
            if ifconfig "$iface" 2>/dev/null | grep -q "inet "; then
                echo "$iface"
                return
            fi
        done
        ip route | awk '/default/ {print $5}' | head -1
    fi
}



# Lấy địa chỉ IP WAN của interface được chỉ định, ưu tiên ubus, sau đó ifconfig, ip addr
get_wan_ip() {
    local iface="$1"
    local ip=""
    local IFACE_FROM_UBUS="" # Biến để lưu tên interface từ ubus

    # Cố gắng lấy tên interface từ ubus thông qua /tmp/network/active hoặc biến môi trường
    if [ -f "/tmp/network/active" ]; then
        IFACE_FROM_UBUS=$(cat "/tmp/network/active")
    elif [ -n "$IFACE" ]; then # Fallback nếu không có /tmp/network/active
        IFACE_FROM_UBUS="$IFACE"
    fi

    # Ưu tiên lấy IP từ ubus nếu IFACE_FROM_UBUS hợp lệ
    if [ -n "$IFACE_FROM_UBUS" ]; then
        ip=$(ubus call network.interface."$IFACE_FROM_UBUS" status 2>/dev/null | jsonfilter -e '@["ipv4-address"][0].address')
    fi
    
    # Nếu ubus không trả về IP, thử ifconfig
    if [ -z "$ip" ] && [ -n "$iface" ]; then
        ip=$(ifconfig "$iface" 2>/dev/null | awk '/inet / {print $2}' | cut -d: -f2)
    fi
    
    # Nếu ifconfig cũng không có, thử ip addr
    if [ -z "$ip" ] && [ -n "$iface" ]; then
        ip=$(ip addr show "$iface" 2>/dev/null | awk '/inet / {print $2}' | cut -d/ -f1)
    fi
    
    # Xác thực định dạng IP (phải là IPv4 hợp lệ và không phải là địa chỉ APIPA/0.0.0.0)
    if echo "$ip" | grep -qE '^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$' && \
       ! echo "$ip" | grep -qE '^(0\.0\.0\.0|169\.254)'; then
        echo "$ip"
    else
        echo "-" # Trả về "-" nếu không tìm thấy IP hợp lệ
    fi
}

# Lấy APN hiện tại: Ưu tiên lấy APN từ section '5G' trong /etc/config/network
get_current_apn() {
    echo "DEBUG_APN: Starting get_current_apn()" >> /tmp/apn_debug.log
    local apn_from_config="-"

    # Kiểm tra xem uci có tồn tại không và có tệp cấu hình không
    if ! command -v uci >/dev/null 2>&1 || [ ! -f /etc/config/network ]; then
        echo "DEBUG_APN: uci command not found or config file missing." >> /tmp/apn_debug.log
        echo "auto" # Trả về auto nếu không tìm thấy uci hoặc tệp config
        return
    fi
    
    # Lấy APN trực tiếp từ section '5G'
    # Vì chúng ta biết cấu trúc là network.5G.apn
    local section_name="5G"
    local current_apn=$(uci get network."$section_name".apn 2>/dev/null)
    
    echo "DEBUG_APN: Attempted to get APN from section '$section_name'." >> /tmp/apn_debug.log
    echo "DEBUG_APN: Retrieved APN value: '$current_apn'." >> /tmp/apn_debug.log

    # Trả về APN đã tìm thấy hoặc mặc định là "auto"
    if [ -n "$current_apn" ] && [ "$current_apn" != "-" ]; then
        echo "$current_apn"
    else
        echo "auto" # Mặc định là "auto" nếu không lấy được APN
    fi
}

# Lấy danh sách máy chủ DNS, ưu tiên từ resolv.conf.auto hoặc ubus
get_dns_servers() {
    local dns_list=""
    
    if [ -f /tmp/resolv.conf.auto ]; then # Ưu tiên từ file cấu hình DNS
        dns_list=$(awk '/nameserver/ {print $2}' /tmp/resolv.conf.auto | tr '\n' ',' | sed 's/,$//')
    fi
    
    # Nếu chưa có DNS và có tên interface từ ubus
    if [ -z "$dns_list" ] && [ -n "$IFNAME" ]; then
        dns_list=$(ubus call network.interface."$IFNAME" status 2>/dev/null | jsonfilter -e '@["dns-server"][*]' | tr '\n' ',' | sed 's/,$//')
    fi
    echo "${dns_list:--}" # Trả về "-" nếu không có DNS nào
}

# Dịch Mã Quốc Gia (MCC) sang tên quốc gia
get_country_from_mcc() {
    case "$1" in
        452) echo "Việt Nam" ;;
        310) echo "USA" ;;
        262) echo "Germany" ;;
        *) echo "-" ;; # Không xác định
    esac
}

# Hàm trợ giúp định dạng tốc độ từ bytes sang KB/s hoặc MB/s
format_speed() {
    local bytes=$1
    if [ "$bytes" -eq 0 ]; then # Nếu số byte là 0, trả về "-"
        echo "-"
        return
    fi
    
    local speed_kbps=$(awk "BEGIN { printf \"%.2f\", $bytes / 1024 }") # Tốc độ KB/s
    local speed_mbps=$(awk "BEGIN { printf \"%.2f\", $bytes / 1024 / 1024 }") # Tốc độ MB/s

    # Sử dụng awk để so sánh số thực, kiểm tra xem có lớn hơn 0.01 không để tránh hiển thị 0.00 MB/s
    if awk "BEGIN { exit !($speed_mbps > 0.01) }"; then 
        printf "%.2f MB/s" "$speed_mbps"
    elif awk "BEGIN { exit !($speed_kbps > 0.01) }"; then
        printf "%.2f KB/s" "$speed_kbps"
    else # Nếu nhỏ hơn cả KB/s
        printf "%d B/s" $bytes
    fi
}

# ==== Biến cho Tốc Độ Rx/Tx ====
# Các tệp tạm để lưu trữ trạng thái mẫu Rx/Tx và thời gian
LAST_RX_BYTES_FILE="/tmp/em9190_last_rx_bytes"
LAST_TX_BYTES_FILE="/tmp/em9190_last_tx_bytes"
LAST_SAMPLE_TIME_FILE="/tmp/em9190_last_sample_time"

# Hàm lấy giá trị từ tệp, an toàn với tệp rỗng hoặc không tồn tại
get_safe_value() {
    local file="$1"
    local default_value="$2"
    if [ -f "$file" ] && [ -s "$file" ]; then # Kiểm tra tệp tồn tại và có nội dung
        cat "$file"
    else
        echo "$default_value" # Trả về giá trị mặc định nếu không
    fi
}

# ==== THỰC HIỆN CHÍNH ====

IFACE=$(detect_interface) # Xác định interface mạng chính
IP_WAN=$(get_wan_ip "$IFACE") # Lấy địa chỉ IP WAN
CURRENT_APN=$(get_current_apn) # Lấy APN hiện tại
DNS_SERVERS=$(get_dns_servers) # Lấy máy chủ DNS

# Lấy thông tin trạng thái tổng quan từ modem
O=$(sms_tool -d "$DEVICE" at "AT!GSTATUS?" 2>/dev/null)

# ==== THÔNG TIN MODEM ====
MODEL=$(sms_tool -d "$DEVICE" at "AT+CGMM" 2>/dev/null | grep -v -e '^AT' -e '^OK' -e '^$' | head -n1 | tr -d '\r\n')
FW=$(sms_tool -d "$DEVICE" at "AT+CGMR" 2>/dev/null | grep -v -e '^AT' -e '^OK' -e '^$' | head -n1 | awk '{print $1}')
IMEI=$(sanitize_string "$(get_single_line_value 'AT+CGSN')") # Lấy IMEI
IMSI=$(sanitize_string "$(get_imsi)") # Lấy IMSI
ICCID=$(sanitize_string "$(get_iccid)") # Lấy ICCID

# ==== NHIỆT ĐỘ, CHẾ ĐỘ MẠNG ====
TEMP=$(echo "$O" | awk -F: '/Temperature:/ {print $3}' | xargs) # Nhiệt độ
SYS_MODE=$(echo "$O" | awk '/^System mode:/ {print $3}') # Chế độ hệ thống (LTE, ENDC, ...)
case "$SYS_MODE" in
    "LTE") MODE="LTE" ;;
    "ENDC") MODE="5G NSA" ;;
    "NR5G-SA") MODE="5G SA" ;;  # nếu có SA
    *) MODE="LTE" ;; # fallback an toàn
esac
[ -z "$MODE" ] || [ "$MODE" = "-" ] && MODE="LTE"

# ==== TAC, CID, LAC, PCI ====
# Lấy TAC (Tracking Area Code)
TAC_HEX=$(echo "$O" | grep -oE 'TAC:[[:space:]]+[0-9a-fA-F]+' | head -1 | sed -E 's/TAC:[[:space:]]+//' | tr -d '\r\n\t ')
if echo "$TAC_HEX" | grep -qE '^[0-9a-fA-F]+$'; then # Kiểm tra xem có phải là hex hợp lệ không
    TAC_DEC=$(printf "%d" "0x$TAC_HEX" 2>/dev/null) # Chuyển đổi sang thập phân
else
    TAC_HEX="-" # Nếu không hợp lệ, đặt là "-"
    TAC_DEC="-"
fi

# Lấy CID (Cell ID) và LAC (Location Area Code)
CID_HEX=$(echo "$O" | awk '/.*TAC:/ {gsub(/[()]/, "", $7); print $7}' | tr -d '\r\n ')
if [ -n "$CID_HEX" ]; then
    CID_DEC=$(printf "%d" "0x$CID_HEX" 2>/dev/null || echo "-") # Chuyển đổi CID từ hex sang thập phân
else
    CID_DEC="-"
    CID_HEX="-"
fi

PCI=$(echo "$O" | awk '/.*TAC:/ {print $8}' | sed 's/[,)]//g' | tr -d '\r\n ') # Lấy PCI (Physical Cell Identifier)
[ -z "$PCI" ] && PCI="-" # Đảm bảo PCI không rỗng

# ==== CHỈ SỐ CƯỜNG ĐỘ TÍN HIỆU ====
RSRP=$(echo "$O" | awk '/^PCC/ && /RSRP/ {print $8}' | head -1 | xargs) # RSRP (Reference Signal Received Power)
RSSI=$(echo "$O" | awk '/^PCC/ && /RSSI/ {print $4}' | head -1 | xargs) # RSSI (Received Signal Strength Indicator)
RSRQ=$(echo "$O" | grep "^RSRQ" | awk '{print $3}') # RSRQ (Reference Signal Received Quality)
SINR=$(echo "$O" | grep "^SINR" | awk '{print $3}') # SINR (Signal to Interference + Noise Ratio)
[ -z "$RSRQ" ] && RSRQ="-" # Đảm bảo RSRQ không rỗng
[ -z "$SINR" ] && SINR="-" # Đảm bảo SINR không rỗng

# ==== THÔNG TIN BAND TẦN ====
RAW_BAND=$(echo "$O" | awk '/^LTE band:/ {print $3}')
BAND=$(echo "$RAW_BAND" | sed 's/^B//')  # Xóa ký tự B nếu có
FREQ=$(echo "$O" | awk '/^LTE band:/ {print $6}')

if [ -n "$BAND" ]; then
    PBAND="B${BAND} @${FREQ} MHz"
    MODE="$MODE B${BAND}"
else
    PBAND="-"
fi


# Hàm trợ giúp lấy chuỗi band tần với tần số (ví dụ: B3 @1800 MHz)
get_band_string() {
    echo -n "B$1" # In số band
    case "$1" in
        "1") echo -n " (2100 MHz)";;
        "3") echo -n " (1800 MHz)";;
        "7") echo -n " (2600 MHz)";;
        "8") echo -n " (900 MHz)";;
        "20") echo -n " (800 MHz)";;
        "28") echo -n " (700 MHz)";;
        "40") echo -n " (2300 MHz)";;
        *) echo -n "";; # Không có thông tin tần số cho các band khác
    esac
}

# Hàm lấy thông tin Secondary Component Carrier (SCC)
get_scc_band() {
    local SCC_NO="$1" # Số hiệu SCC (1, 2, 3)
    # Kiểm tra xem SCC có trạng thái ACTIVE không
    local ACTIVE=$(echo "$O" | awk -F: "/^LTE SCC${SCC_NO} state:.*ACTIVE/ {print \$3}")
    if [ -n "$ACTIVE" ]; then # Nếu SCC đang hoạt động
        local BW=$(echo "$O" | awk "/^LTE SCC${SCC_NO} bw/ {print \$5}") # Lấy băng thông
        local BSTR="B${ACTIVE/B/}" # Lấy số band chính
        MODE="${MODE/LTE/LTE-A} + $BSTR" # Cập nhật MODE (ví dụ: LTE thành LTE-A nếu có SCC)
        echo "$(get_band_string ${ACTIVE/B/}) @$BW MHz" # Trả về chuỗi band tần và băng thông
    else
        echo "-" # Nếu SCC không hoạt động, trả về "-"
    fi
}

S1BAND=$(get_scc_band 1) # Lấy thông tin SCC 1
S2BAND=$(get_scc_band 2) # Lấy thông tin SCC 2
S3BAND=$(get_scc_band 3) # Lấy thông tin SCC 3

# ==== THÔNG TIN 5G NR ====
# Lấy băng tần 5G NR (nếu có)
NRBAND=$(echo "$O" | awk '/^SCC. NR5G band:/ {print $4}')
if [ -n "$NRBAND" ] && [ "$NRBAND" != "---" ]; then
    MODE="$MODE + n${NRBAND/n/}" # Cập nhật MODE với băng tần 5G (ví dụ: n78)
    # Lấy các chỉ số tín hiệu 5G và ghi đè nếu có
    NR_RSRP=$(echo "$O" | awk '/SCC. NR5G RSRP:/ {print $4}')
    NR_RSRQ=$(echo "$O" | awk '/SCC. NR5G RSRQ:/ {print $4}')
    NR_SINR=$(echo "$O" | awk '/SCC. NR5G SINR:/ {print $4}')
    [ -n "$NR_RSRP" ] && RSRP="$NR_RSRP"
    [ -n "$NR_RSRQ" ] && RSRQ="$NR_RSRQ"
    [ -n "$NR_SINR" ] && SINR="$NR_SINR"
fi

# ==== CSQ (Chỉ số chất lượng tín hiệu) ====
CSQ_LINE=$(get_at_response "AT+CSQ" "+CSQ")
CSQ=$(echo "$CSQ_LINE" | awk -F: '{print $2}' | awk -F, '{print $1}' | tr -d ' ') # Lấy giá trị CSQ
if [ -n "$CSQ" ] && [ "$CSQ" -ne 99 ]; then # Nếu CSQ hợp lệ (không phải 99)
    CSQ_PER=$(expr $CSQ \* 100 / 31) # Chuyển đổi CSQ (0-31) sang tỷ lệ %
else
    CSQ="0" # Đặt CSQ = 0 nếu không hợp lệ
    CSQ_PER="0" # Đặt tỷ lệ % = 0
fi

# ==== COPS (Thông tin nhà mạng) ====
sms_tool -d "$DEVICE" at "AT+COPS=3,2" > /dev/null 2>&1 # Đặt chế độ chọn mạng tự động
COPS_LINE=$(get_at_response "AT+COPS?" "+COPS") # Lấy thông tin nhà mạng
COPS_NUM=$(echo "$COPS_LINE" | grep -oE '[0-9]{5,6}' | head -1) # Trích xuất số MCC-MNC

# Phân loại nhà mạng dựa trên số MCC-MNC
case "$COPS_NUM" in
    "45202") COPS="Vinaphone";;
    "45201") COPS="Mobifone";;
    "45204") COPS="Viettel";;
    *)       COPS="Unknown";; # Nhà mạng không xác định
esac

COPS_MCC=$(echo "$COPS_NUM" | cut -c1-3) # Lấy MCC
COPS_MNC=$(echo "$COPS_NUM" | cut -c4-) # Lấy MNC

# ==== PING ĐẾN WEBSITE NHÀ MẠNG ====
case "$COPS" in
    "Vinaphone") PING_HOST="vnpt.com.vn";;
    "Mobifone")  PING_HOST="mobifone.vn";;
    "Viettel")   PING_HOST="viettel.vn";;
    *)           PING_HOST="8.8.8.8";;
esac

# Ping thử 1 gói, lấy time trung bình
PING_MS=$(ping -c 1 -W 1 "$PING_HOST" 2>/dev/null | awk -F'time=' '/time=/{print $2}' | cut -d' ' -f1)
[ -z "$PING_MS" ] && PING_MS="-"

# Phân loại độ trễ
if echo "$PING_MS" | grep -qE '^[0-9.]+'; then
    PING_MS_VAL=$(printf "%.0f" "$PING_MS")
    if [ "$PING_MS_VAL" -lt 20 ]; then
        PING_QUALITY="good"
    elif [ "$PING_MS_VAL" -lt 50 ]; then
        PING_QUALITY="fair"
    elif [ "$PING_MS_VAL" -lt 100 ]; then
        PING_QUALITY="poor"
    else
        PING_QUALITY="bad"
    fi
else
    PING_QUALITY="unreachable"
fi


# ==== CREG (Trạng thái đăng ký mạng) ====
CREG_LINE=$(get_at_response "AT+CREG?" "+CREG")
REG_STATUS=$(echo "$CREG_LINE" | awk -F, '{print $2}' | tr -d ' ') # Lấy trạng thái đăng ký (0: ko, 1: da dang ky, 2: dang tim, 5: roaming)

# ==== EARFCN ====
EARFCN=$(echo "$O" | awk '/^LTE Rx chan:/ {print $4}') # Lấy EARFCN (tần số kênh)

# ==== PROTOCOL ====
PROTO_INFO=$(awk '/Vendor=1199 ProdID=90d3/{f=1} f && /Driver=/{print; f=0}' /sys/kernel/debug/usb/devices 2>/dev/null)
case "$PROTO_INFO" in
    *qmi_wwan*) PROTO="qmi";;
    *cdc_mbim*) PROTO="mbim";;
    *cdc_ether*) PROTO="ecm";;
    *) PROTO="qmi";;
esac

# Lấy thông tin interface logic (tên trong /etc/config/network)
# Nếu IFNAME chưa có thì gán mặc định
[ -z "$IFNAME" ] && IFNAME="5G"

# Nếu IFACE chưa có thì lấy từ ifstatus hoặc detect
# Xác định interface vật lý đang hoạt động
IFACE=$(detect_interface)

# Tìm IFNAME logic tương ứng trong ubus (ví dụ: 5G hoặc lan)
IFNAME=$(ubus -S list network.interface.* | while read iface; do
    ubus call "$iface" status 2>/dev/null | grep -q "\"l3_device\": \"$IFACE\"" && echo "$iface" | cut -d'.' -f3 && break
done)

# Fallback mặc định nếu không tìm được
[ -z "$IFNAME" ] && IFNAME="5G"


# Lấy IP WAN (ưu tiên dùng ubus cho chuẩn)
IP_WAN=$(ubus call network.interface.$IFNAME status 2>/dev/null | jsonfilter -e '@["ipv4-address"][0].address')
if [ -z "$IP_WAN" ] || [ "$IP_WAN" = "null" ]; then
    IP_WAN=$(curl -s --max-time 2 https://api.ipify.org?format=json | jsonfilter -e "@.ip")
fi
[ -z "$IP_WAN" ] && IP_WAN="-"


# Lấy uptime của interface mạng
IFACE=$(detect_interface)
IFNAME=$(ubus -S list network.interface.* | grep "$IFACE" | cut -d'.' -f3 | head -n1)
[ -z "$IFNAME" ] && IFNAME="5G"

# Lấy uptime chính xác theo IFNAME
# Lấy uptime từ interface logic
UPTIME_NETWORK=$(ubus call network.interface."$IFNAME" status 2>/dev/null | jsonfilter -e "@.uptime")
FINAL_UPTIME=0
if [ -n "$UPTIME_NETWORK" ] && echo "$UPTIME_NETWORK" | grep -qE '^[0-9]+$'; then
    FINAL_UPTIME=$UPTIME_NETWORK
elif [ -f "/proc/uptime" ]; then
    FINAL_UPTIME=$(cut -d. -f1 /proc/uptime)
fi


# Nếu không có, fallback về hệ thống
FINAL_UPTIME=0
if [ -n "$UPTIME_NETWORK" ] && echo "$UPTIME_NETWORK" | grep -qE '^[0-9]+$'; then
    FINAL_UPTIME=$UPTIME_NETWORK
elif [ -f "/proc/uptime" ]; then
    FINAL_UPTIME=$(cut -d. -f1 /proc/uptime)
fi

# Định dạng
CONN_TIME=$(printf "%02d:%02d:%02d" $((FINAL_UPTIME/3600)) $((FINAL_UPTIME%3600/60)) $((FINAL_UPTIME%60)))


# Lấy số byte Rx/Tx hiện tại từ thống kê hệ thống
RX_BYTES=$(cat /sys/class/net/"$IFACE"/statistics/rx_bytes 2>/dev/null)
TX_BYTES=$(cat /sys/class/net/"$IFACE"/statistics/tx_bytes 2>/dev/null)
[ -z "$RX_BYTES" ] && RX_BYTES=0
[ -z "$TX_BYTES" ] && TX_BYTES=0


# ==== TÍNH TOÁN TỐC ĐỘ RX/TX ====
DIFF_RX_BYTES=0 # Chênh lệch byte nhận
DIFF_TX_BYTES=0 # Chênh lệch byte gửi
TIME_DIFF=0     # Chênh lệch thời gian

# Lấy các giá trị mẫu Rx/Tx bytes và thời gian từ lần lấy mẫu trước
LAST_RX_BYTES=$(get_safe_value "$LAST_RX_BYTES_FILE" 0)
LAST_TX_BYTES=$(get_safe_value "$LAST_TX_BYTES_FILE" 0)
LAST_SAMPLE_TIME=$(get_safe_value "$LAST_SAMPLE_TIME_FILE" 0)

# Lấy thời điểm lấy mẫu hiện tại (chuẩn Unix timestamp)
CURRENT_SAMPLE_TIME=$(date +%s)

# Tính toán chênh lệch thời gian và byte nếu có dữ liệu mẫu trước đó
if [ "$LAST_SAMPLE_TIME" -gt 0 ]; then
    TIME_DIFF=$((CURRENT_SAMPLE_TIME - LAST_SAMPLE_TIME))
    DIFF_RX_BYTES=$((RX_BYTES - LAST_RX_BYTES))
    DIFF_TX_BYTES=$((TX_BYTES - LAST_TX_BYTES))

    if [ "$TIME_DIFF" -gt 0 ]; then
        RX_SPEED_BPS=$(awk "BEGIN { printf \"%.0f\", ($DIFF_RX_BYTES / $TIME_DIFF) }")
        TX_SPEED_BPS=$(awk "BEGIN { printf \"%.0f\", ($DIFF_TX_BYTES / $TIME_DIFF) }")
    else
        RX_SPEED_BPS=0
        TX_SPEED_BPS=0
    fi
else
    RX_SPEED_BPS=0
    TX_SPEED_BPS=0
fi

# Định dạng tốc độ sang đơn vị dễ đọc (KB/s, MB/s)
RX_SPEED_FORMAT=$(format_speed "$RX_SPEED_BPS")
TX_SPEED_FORMAT=$(format_speed "$TX_SPEED_BPS")

# ==== KIỂM TRA TRẠNG THÁI KẾT NỐI ====
if [ "$IP_WAN" = "-" ]; then # Nếu không có IP WAN hợp lệ
    STATUS="disconnected"
    CONNECTION_STATUS="Disconnected"
else
    STATUS="connected"
    CONNECTION_STATUS="Connected"
fi

# ==== XỬ LÝ YÊU CẦU RESTART ====
# Kiểm tra chuỗi truy vấn để tìm hành động "restart"
if echo "$QUERY_STRING" | grep -q "action=restart"; then
    echo '{"status":"running","message":"Restarting..."}' >&2 # Ghi thông báo lỗi ra stderr
    # Thực hiện lệnh AT để tắt rồi bật modem
    (
        echo -e "AT+CFUN=4\r" # Tắt modem
        sleep 2
        echo -e "AT+CFUN=1\r" # Bật lại modem
    ) > "$DEVICE" # Ghi các lệnh vào thiết bị serial
    sleep 2 # Chờ một chút để modem khởi động lại
    echo '{"status":"ok"}' # Trả về kết quả thành công
    exit 0 # Thoát script
fi
#============================================
# ==== XỬ LÝ YÊU CẦU SET APN MỚI ====
if echo "$QUERY_STRING" | grep -q "action=set_apn"; then
    NEW_APN=$(echo "$QUERY_STRING" | sed -n 's/.*value=\([^&]*\).*/\1/p' \
        | sed 's/%20/ /g' | sed 's/[^a-zA-Z0-9._-]//g')


    if [ -n "$NEW_APN" ]; then
        # Chuyển toàn bộ debug sang stderr/log file
        echo "DEBUG_APN: Nhận yêu cầu set APN mới: $NEW_APN" >> /tmp/apn_debug.log

        uci set network.5G.apn="$NEW_APN"
        uci commit network
        /etc/init.d/network restart >/dev/null 2>&1 &

        echo "{\"status\":\"ok\", \"apn\":\"$NEW_APN\"}"
    else
        echo '{"status":"fail", "message":"APN không hợp lệ"}'
    fi
    exit 0
fi




# ==== LƯU TRỮ THÔNG TIN MẪU CHO LẦN SAU ====
# Ghi số byte Rx/Tx hiện tại và thời gian lấy mẫu vào các tệp tạm
echo "$RX_BYTES" > "$LAST_RX_BYTES_FILE"
echo "$TX_BYTES" > "$LAST_TX_BYTES_FILE"
echo "$CURRENT_SAMPLE_TIME" > "$LAST_SAMPLE_TIME_FILE"

# ==== IN DỮ LIỆU DƯỚI DẠNG JSON ====
cat << JSONEOF
{
    "conn_time": "$CONN_TIME",
    "status": "$(sanitize_string "$STATUS")",
    "connection_status": "$(sanitize_string "$CONNECTION_STATUS")",
    "ip_wan": "$(sanitize_string "$IP_WAN")",
    "current_apn": "$(sanitize_string "$CURRENT_APN")",
    "dns_servers": "$(sanitize_string "$DNS_SERVERS")",
    "interface": "$(sanitize_string "$IFACE")",
    "modem": "Sierra Wireless AirPrime EM9190 5G NR",
    "model": "$(sanitize_string "$MODEL")",
    "mtemp": "$(sanitize_string "$TEMP")",
    "temperature": "$(sanitize_string "$TEMP")",
    "firmware": "SWIX55C_03.10.07.00",
    "cport": "$(sanitize_string "$DEVICE")",
    "protocol": "$(sanitize_string "$PROTO")",
    "csq": "$(sanitize_number "$CSQ")",
    "signal": "$(sanitize_number "$CSQ_PER")",
    "operator": "$(sanitize_string "$COPS")",
    "operator_name": "$(sanitize_string "$COPS")",
    "operator_mcc": "$(sanitize_string "$COPS_MCC")",
    "operator_mnc": "$(sanitize_string "$COPS_MNC")",
    "mcc_mnc": "$(sanitize_string "$COPS_MCC-$COPS_MNC")",
    "location": "$(get_country_from_mcc "$COPS_MCC")",
    "technology": "$(sanitize_string "$MODE")",
    "mode": "$(sanitize_string "$MODE")",
    "registration": "$(sanitize_string "$REG_STATUS")",
    "imei": "$(sanitize_string "$IMEI")",
    "imsi": "$(sanitize_string "$IMSI")",
    "iccid": "$(sanitize_string "$ICCID")",
    "lac_dec": "$(sanitize_number "$TAC_DEC")",
    "lac_hex": "$(sanitize_string "$TAC_HEX")",
    "cid_dec": "$(sanitize_number "$CID_DEC")",
    "cid_hex": "$(sanitize_string "$CID_HEX")",
    "pci": "$(sanitize_number "$PCI")",
    "earfcn": "$(sanitize_number "$EARFCN")",
    "band": "$(sanitize_string "$PBAND")",
    "pband": "$(sanitize_string "$PBAND")",
    "s1band": "$(sanitize_string "$S1BAND")",
    "s2band": "$(sanitize_string "$S2BAND")",
    "s3band": "$(sanitize_string "$S3BAND")",
    "rsrp": "$(sanitize_number "$RSRP")",
    "rsrq": "$(sanitize_number "$RSRQ")",
    "rssi": "$(sanitize_number "$RSSI")",
    "sinr": "$(sanitize_number "$SINR")",
	"rx_data": $(sanitize_number "$RX_BYTES"),
	"tx_data": $(sanitize_number "$TX_BYTES"),
    "rx_speed": "$RX_SPEED_FORMAT",
    "tx_speed": "$TX_SPEED_FORMAT",
    "ping": "$(sanitize_string "$PING_MS")",
    "ping_host": "$(sanitize_string "$PING_HOST")",
    "ping_quality": "$(sanitize_string "$PING_QUALITY")"
}
JSONEOF

EOF

echo "Tạo CGI SMS-SEND script..."
cat > "$CGI_DIR/sms-read" << 'EOF'
#!/bin/sh
# ─── HTTP HEADER ────────────────────────────────────────────────────────────────
echo "Content-Type: application/json; charset=utf-8"
echo ""

# ─── CẤU HÌNH THƯ MỤC/FILE ─────────────────────────────────────────────────────
ARCHIVE_DIR="/root/sms-archive"           # Thư mục chứa monthly JSON files
SENT_TIME_LOG="/tmp/sms_sent_times"       # Log timestamp cho sms-read mapping
SEND_LOG="/tmp/sms-send.log"              # Debug log chi tiết
mkdir -p "$ARCHIVE_DIR"

# ─── HÀM LOG HỖ TRỢ ───────────────────────────────────────────────────────────
log() { echo "$(date '+%Y-%m-%d %H:%M:%S') - $*" >> "$SEND_LOG"; }

# ─── TÌM MODEM ACTIVE ──────────────────────────────────────────────────────────
MODEM_ID=$(mmcli -L 2>/dev/null | grep -o '/Modem/[0-9]\+' | head -n1 | awk -F/ '{print $NF}')
if [ -z "$MODEM_ID" ]; then
    log "ERROR: No active modem found"
    echo '{ "status":"error","message":"Không tìm thấy modem hoạt động" }'
    exit 1
fi

MM="/usr/bin/mmcli"
log "Found active modem: $MODEM_ID"

# ─── HÀM GIẢI MÃ URL ──────────────────────────────────────────────────────────
urldecode() { 
    printf '%b' "${1//+/ }" | sed 's/%/\\x/g' | xargs -0 printf '%b' 2>/dev/null || echo "$1"
}

# ─── HÀM ESCAPE JSON AN TOÀN ──────────────────────────────────────────────────
json_escape() { 
    printf '%s' "$1" | sed 's/\\/\\\\/g; s/"/\\"/g; s/\t/\\t/g; s/\r/\\r/g; s/\n/\\n/g'
}

# ─── KHỞI TẠO MONTHLY FILE ────────────────────────────────────────────────────
init_monthly_file() {
    local month_file="$1"
    local month="$2"
    
    if [ ! -f "$month_file" ]; then
        log "Creating new monthly file: $month_file"
        
        # Tạo thư mục nếu chưa có
        mkdir -p "$(dirname "$month_file")"
        
        # Tạo file JSON với cấu trúc chuẩn
        cat > "$month_file" <<EOF
{
  "month": "$month",
  "messages": [],
  "total": 0,
  "last_updated": "$(date '+%Y-%m-%d %H:%M:%S')",
  "version": "1.0",
  "created_at": "$(date '+%Y-%m-%d %H:%M:%S')"
}
 EOF
        
        # Kiểm tra file được tạo thành công
        if [ -f "$month_file" ] && [ -s "$month_file" ]; then
            log "Monthly file created successfully"
            return 0
        else
            log "ERROR: Failed to create monthly file"
            return 1
        fi
    else
        log "Monthly file already exists: $month_file"
        
        # Validate JSON structure
        if command -v jq >/dev/null 2>&1; then
            if ! jq . "$month_file" >/dev/null 2>&1; then
                log "WARNING: Monthly file is corrupted, recreating..."
                mv "$month_file" "${month_file}.corrupted.$(date +%s)"
                init_monthly_file "$month_file" "$month"
                return $?
            fi
        fi
        return 0
    fi
}

# ─── BACKUP MONTHLY FILE ──────────────────────────────────────────────────────
backup_monthly_file() {
    local month_file="$1"
    if [ -f "$month_file" ]; then
        cp "$month_file" "${month_file}.backup.$(date +%s)"
        # Giữ chỉ 3 backup gần nhất
        ls -t "${month_file}.backup."* 2>/dev/null | tail -n +4 | xargs rm -f 2>/dev/null || true
        log "Created backup for monthly file"
    fi
}

# ─── LẤY THAM SỐ TỪ GET/POST ──────────────────────────────────────────────────
read_stdin() { 
    if [ -n "$CONTENT_LENGTH" ] && [ "$CONTENT_LENGTH" -gt 0 ]; then
        dd bs="$CONTENT_LENGTH" count=1 2>/dev/null
    else
        cat
    fi
}

if [ "$REQUEST_METHOD" = "POST" ]; then
    DATA=$(read_stdin)
    log "POST request, data: $DATA"
else
    DATA="$QUERY_STRING"
    log "GET request, query: $DATA"
fi

# Parse cả JSON và form-urlencoded
if echo "$DATA" | grep -q '"number"'; then
    # JSON format: {"number":"xxx","text":"yyy"}
    NUMBER=$(echo "$DATA" | sed -n 's/.*"number"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p')
    TEXT=$(echo   "$DATA" | sed -n 's/.*"text"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p')
    log "Parsed JSON - Number: $NUMBER, Text: $TEXT"
else
    # Form-urlencoded: number=xxx&text=yyy
    NUMBER=$(echo "$DATA" | sed -n 's/.*number=\([^&]*\).*/\1/p')
    TEXT=$(echo   "$DATA" | sed -n 's/.*text=\([^&]*\).*/\1/p')
    log "Parsed form - Number: $NUMBER, Text: $TEXT"
fi

# URL decode
NUMBER=$(urldecode "$NUMBER")
TEXT=$(urldecode  "$TEXT")

# Validation
if [ -z "$NUMBER" ] || [ -z "$TEXT" ]; then
    log "ERROR: Missing number or text - Number: '$NUMBER', Text: '$TEXT'"
    echo '{ "status":"error","message":"Thiếu số điện thoại hoặc nội dung tin nhắn" }'
    exit 1
fi

log "Final params - Number: $NUMBER, Text: $TEXT"

# ─── TẠO SMS QUA MODEMMANAGER ─────────────────────────────────────────────────
log "Creating SMS via ModemManager..."
CREATE_OUTPUT=$($MM -m "$MODEM_ID" --messaging-create-sms="number='$NUMBER',text='$TEXT'" 2>&1)
log "Create SMS output: $CREATE_OUTPUT"

# 🔧 Extract SMS path chính xác (đã sửa lỗi)
SMS_PATH=$(echo "$CREATE_OUTPUT" | grep -o '/org/freedesktop/ModemManager1/SMS/[0-9]*')

if [ -z "$SMS_PATH" ]; then
    log "ERROR: Failed to extract SMS path from output: $CREATE_OUTPUT"
    echo '{ "status":"error","message":"Không thể tạo SMS","detail":"'"$(json_escape "$CREATE_OUTPUT")"'" }'
    exit 1
fi

SMS_ID=${SMS_PATH##*/}
log "Created SMS successfully - Path: $SMS_PATH, ID: $SMS_ID"

# ─── GỬI SMS ───────────────────────────────────────────────────────────────────
log "Sending SMS ID $SMS_ID..."
SEND_OUT=$($MM -s "$SMS_PATH" --send 2>&1)
log "Send SMS output: $SEND_OUT"

if ! echo "$SEND_OUT" | grep -qi "successfully sent"; then
    log "ERROR: Failed to send SMS - Output: $SEND_OUT"
    echo '{ "status":"error","message":"Gửi SMS thất bại","detail":"'"$(json_escape "$SEND_OUT")"'" }'
    exit 1
fi

log "SMS $SMS_ID sent successfully"

# ─── GHI TIMESTAMP VÀO SENT_TIME_LOG ─────────────────────────────────────────
SEND_TIME=$(date '+%Y-%m-%dT%H:%M:%S+07:00')
echo "${SMS_ID}:${SEND_TIME}" >> "$SENT_TIME_LOG"

# Cleanup log file (giữ 100 entries cuối)
if [ -f "$SENT_TIME_LOG" ]; then
    tail -100 "$SENT_TIME_LOG" > "${SENT_TIME_LOG}.tmp" && mv "${SENT_TIME_LOG}.tmp" "$SENT_TIME_LOG"
fi

log "Logged send time: $SMS_ID -> $SEND_TIME"

# ─── KHỞI TẠO MONTHLY ARCHIVE ─────────────────────────────────────────────────
MONTH=$(date '+%Y-%m')
MONTHLY_FILE="$ARCHIVE_DIR/messages-${MONTH}.json"

# Khởi tạo file monthly
if ! init_monthly_file "$MONTHLY_FILE" "$MONTH"; then
    log "FATAL: Cannot initialize monthly archive file"
    echo '{ "status":"error","message":"Lỗi khởi tạo file lưu trữ" }'
    exit 1
fi

# Backup trước khi modify
backup_monthly_file "$MONTHLY_FILE"

log "Archiving to monthly file: $MONTHLY_FILE"

# ─── FILE LOCKING ─────────────────────────────────────────────────────────────
exec 300>"$MONTHLY_FILE.lock"
if ! flock -n 300; then
    log "ERROR: Cannot acquire lock on monthly file"
    echo '{ "status":"error","message":"File archive đang bị sử dụng, vui lòng thử lại" }'
    exit 1
fi

# ─── TẠO JSON MESSAGE OBJECT ──────────────────────────────────────────────────
MSG_JSON=$(cat <<EOF
{
  "id": $SMS_ID,
  "number": "$(json_escape "$NUMBER")",
  "text": "$(json_escape "$TEXT")",
  "date": "$SEND_TIME",
  "type": "submit",
  "state": "sent",
  "storage": "router",
  "read_status": 1
}
 EOF
)

log "Created message JSON for SMS $SMS_ID"

# ─── THÊM MESSAGE VÀO MONTHLY FILE ────────────────────────────────────────────
ARCHIVE_SUCCESS=false

if command -v jq >/dev/null 2>&1; then
    log "Using jq for JSON processing"
    CURRENT_TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
    
    NEW_CONTENT=$(jq --argjson m "$MSG_JSON" --arg ts "$CURRENT_TIMESTAMP" '
        .messages += [$m] |
        .total = (.messages|length) |
        .last_updated = $ts
    ' "$MONTHLY_FILE" 2>/dev/null)
    
    if [ $? -eq 0 ] && [ -n "$NEW_CONTENT" ]; then
        echo "$NEW_CONTENT" > "$MONTHLY_FILE"
        ARCHIVE_SUCCESS=true
        log "Successfully added message using jq"
    else
        log "jq processing failed, trying awk fallback"
    fi
fi

# AWK fallback nếu jq không có hoặc thất bại
if [ "$ARCHIVE_SUCCESS" = "false" ]; then
    log "Using awk for JSON processing"
    
    awk -v new_msg="$MSG_JSON" -v timestamp="$(date '+%Y-%m-%d %H:%M:%S')" '
    BEGIN { found_messages = 0; added = 0 }
    /"messages"[[:space:]]*:[[:space:]]*\[/ {
        print $0
        found_messages = 1
        next
    }
    found_messages && /^[[:space:]]*\]/ && !added {
        if (new_msg != "") {
            print "    " new_msg
            added = 1
        }
        print $0
        found_messages = 0
        next
    }
    found_messages && /^[[:space:]]*$/ && !added {
        if (new_msg != "") {
            print "    " new_msg ","
            added = 1
        }
        next
    }
    # Update total count (simplified)
    /"total"[[:space:]]*:[[:space:]]*[0-9]+/ {
        if (added) {
            gsub(/[0-9]+/, "999", $0)  # Placeholder - real count would need separate calculation
        }
    }
    # Update timestamp
    /"last_updated"/ {
        gsub(/"[^"]*"$/, "\"" timestamp "\"", $0)
    }
    { print }
    ' "$MONTHLY_FILE" > "${MONTHLY_FILE}.tmp"
    
    if [ -s "${MONTHLY_FILE}.tmp" ]; then
        mv "${MONTHLY_FILE}.tmp" "$MONTHLY_FILE"
        ARCHIVE_SUCCESS=true
        log "Successfully added message using awk"
    else
        log "awk processing also failed"
        rm -f "${MONTHLY_FILE}.tmp"
    fi
fi

if [ "$ARCHIVE_SUCCESS" = "false" ]; then
    log "WARNING: Failed to archive SMS $SMS_ID to monthly file"
fi

# ─── XÓA SMS KHỎI SIM (tiết kiệm bộ nhớ) ──────────────────────────────────────
log "Deleting SMS $SMS_ID from SIM..."

DELETE_SUCCESS=false

# Thử method 1: Delete by SMS path
DELETE_OUT1=$($MM -s "$SMS_PATH" --delete 2>&1)
if echo "$DELETE_OUT1" | grep -qi "successfully deleted"; then
    DELETE_SUCCESS=true
    log "Successfully deleted SMS using SMS path"
else
    log "Failed to delete using SMS path: $DELETE_OUT1"
    
    # Thử method 2: Delete by SMS ID
    DELETE_OUT2=$($MM -m "$MODEM_ID" --messaging-delete-sms="$SMS_ID" 2>&1)
    if echo "$DELETE_OUT2" | grep -qi "successfully deleted"; then
        DELETE_SUCCESS=true
        log "Successfully deleted SMS using SMS ID"
    else
        log "Failed to delete using SMS ID: $DELETE_OUT2"
    fi
fi

# ─── TẠO RESPONSE JSON ────────────────────────────────────────────────────────
log "Preparing response JSON..."

RESPONSE_JSON=$(cat <<EOF
{
  "status": "success",
  "message": "SMS đã được gửi thành công",
  "data": {
    "sms_id": $SMS_ID,
    "number": "$(json_escape "$NUMBER")",
    "text": "$(json_escape "$TEXT")",
    "date": "$SEND_TIME",
    "type": "submit",
    "state": "sent",
    "storage": "router",
    "read_status": 1
  },
  "archive": {
    "monthly_file": "$MONTHLY_FILE",
    "archived": $ARCHIVE_SUCCESS,
    "deleted_from_sim": $DELETE_SUCCESS
  },
  "timestamp": "$(date '+%Y-%m-%d %H:%M:%S')"
}
 EOF
)

echo "$RESPONSE_JSON"

log "SMS send operation completed - ID: $SMS_ID, Archive: $ARCHIVE_SUCCESS, Delete: $DELETE_SUCCESS"

# ─── CLEANUP ───────────────────────────────────────────────────────────────────
flock -u 300 2>/dev/null
exit 0

EOF

# 3. Tạo CGI script
echo "Tạo CGI SMS-READ script..."
cat > "$CGI_DIR/sms-read" << 'EOF'
#!/bin/sh
echo "Content-Type: application/json; charset=utf-8"
echo ""

# === DEBUG LOG ===
DEBUG_LOG="/tmp/sms-read-debug.log"
debug() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$DEBUG_LOG"
}

debug "=== SMS-READ START ==="

# === CẤU HÌNH ===
ARCHIVE_DIR="/root/sms-archive"
mkdir -p "$ARCHIVE_DIR"

CURRENT_MONTH=$(date "+%Y-%m")
MONTHLY_FILE="$ARCHIVE_DIR/messages-${CURRENT_MONTH}.json"
TEMP_FILE="/tmp/messages_temp_$$.json"

debug "Monthly file: $MONTHLY_FILE"

# === KHỞI TẠO MONTHLY FILE ===
init_monthly_file() {
    if [ ! -f "$MONTHLY_FILE" ] || [ ! -s "$MONTHLY_FILE" ]; then
        debug "Creating/recreating monthly file"
        
        # Tạo dynamic values
        CURRENT_MONTH_INIT=$(date "+%Y-%m")
        CURRENT_TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")
        
        cat > "$MONTHLY_FILE" << EOF
{
  "month": "$CURRENT_MONTH_INIT",
  "messages": [],
  "total": 0,
  "last_updated": "$CURRENT_TIMESTAMP"
}
 EOF
    else
        debug "Monthly file exists"
        if command -v jq >/dev/null 2>&1; then
            if ! jq . "$MONTHLY_FILE" >/dev/null 2>&1; then
                debug "Monthly file corrupt, recreating"
                
                CURRENT_MONTH_INIT=$(date "+%Y-%m")
                CURRENT_TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")
                
                cat > "$MONTHLY_FILE" << EOF
{
  "month": "$CURRENT_MONTH_INIT", 
  "messages": [],
  "total": 0,
  "last_updated": "$CURRENT_TIMESTAMP"
}
 EOF
            fi
        fi
    fi
}

# === FILE LOCKING ===
exec 200>"$MONTHLY_FILE.lock"
if ! flock -n 200; then
    debug "Could not acquire lock"
    echo '{ "messages": [] }'
    exit 1
fi

init_monthly_file

# === ESCAPE JSON SAFELY ===
escape_json_text() {
    local text="$1"
    echo "$text" | sed 's/\\/\\\\/g; s/"/\\"/g; s/\t/\\t/g; s/\r/\\r/g'
}

# === THÊM MESSAGE VÀO MONTHLY FILE - SỬA LỖI JQ ===
add_to_monthly() {
    local new_message="$1"
    debug "Adding message to monthly file"
    
    # Backup
    cp "$MONTHLY_FILE" "${MONTHLY_FILE}.backup" 2>/dev/null
    
    if command -v jq >/dev/null 2>&1; then
        debug "Using jq for JSON processing"
        
        echo "$new_message" > /tmp/new_msg_$$.json
        
        if ! jq . /tmp/new_msg_$$.json >/dev/null 2>&1; then
            debug "New message JSON is invalid"
            rm -f /tmp/new_msg_$$.json
            return 1
        fi
        
        debug "New message JSON is valid"
        
        CURRENT_TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
        
        jq --slurpfile new_msg /tmp/new_msg_$$.json \
           --arg timestamp "$CURRENT_TIMESTAMP" '
            .messages += $new_msg |
            .total = (.messages | length) |
            .last_updated = $timestamp
        ' "$MONTHLY_FILE" > "$TEMP_FILE" 2>/tmp/jq_error_$$.log
        
        rm -f /tmp/new_msg_$$.json
        
        if [ -s "$TEMP_FILE" ] && jq . "$TEMP_FILE" >/dev/null 2>&1; then
            debug "jq processing successful"
        else
            debug "jq processing failed"
            if [ -f /tmp/jq_error_$$.log ]; then
                debug "jq error: $(cat /tmp/jq_error_$$.log)"
                cat /tmp/jq_error_$$.log >> /tmp/jq_error.log
            fi
            rm -f "$TEMP_FILE" /tmp/jq_error_$$.log
        fi
    else
        debug "Using awk for JSON processing (fallback)"
        awk -v new_msg="$new_message" '
        BEGIN { found_array = 0; added = 0 }
        /^[[:space:]]*"messages"[[:space:]]*:[[:space:]]*\[/ {
            print $0
            found_array = 1
            next
        }
        found_array && /^[[:space:]]*\]/ {
            if (!added && new_msg != "") {
                print "    " new_msg
                added = 1
            }
            print $0
            found_array = 0
            next
        }
        /"last_updated"/ {
            gsub(/"[^"]*"$/, "\"" strftime("%Y-%m-%d %H:%M:%S") "\"", $0)
        }
        { print }
        ' "$MONTHLY_FILE" > "$TEMP_FILE"
    fi
    
    if [ -s "$TEMP_FILE" ]; then
        mv "$TEMP_FILE" "$MONTHLY_FILE"
        debug "Successfully added message to monthly file"
        return 0
    else
        debug "Failed to create temp file or temp file empty"
        if [ -f "${MONTHLY_FILE}.backup" ]; then
            mv "${MONTHLY_FILE}.backup" "$MONTHLY_FILE"
            debug "Rolled back to backup"
        fi
        return 1
    fi
}

# === ĐỌC MESSAGES TỪ ARCHIVE ===
read_archive_messages() {
    debug "Reading messages from archive"
    if [ -f "$MONTHLY_FILE" ] && command -v jq >/dev/null 2>&1; then
        jq -r '.messages[]? | @json' "$MONTHLY_FILE" 2>/dev/null
    fi
}

# === MAIN PROCESSING ===
debug "Starting main processing"

PROCESSED_COUNT=0

# 1. LẤY DANH SÁCH SMS TỪ MODEM
SMS_LIST=$(mmcli -m 0 --messaging-list-sms 2>/dev/null)
debug "Raw SMS list: $SMS_LIST"

SMS_IDS=""
if [ -n "$SMS_LIST" ]; then
    # Thay vì tăng dần, bạn có thể đổi sort -n thành sort -nr nếu muốn
    SMS_IDS=$(echo "$SMS_LIST" | grep -oE '/SMS/[0-9]+' | sed 's|/SMS/||g' | sort -nr)
    debug "Extracted SMS IDs (sorted desc): $SMS_IDS"
fi

# 2. XỬ LÝ TIN NHẮN MỚI
for ID in $SMS_IDS; do
    [ -n "$ID" ] || continue
    
    debug "Processing SMS ID: $ID"
    
    INFO=$(mmcli -s "$ID" 2>/dev/null)
    if [ -z "$INFO" ]; then
        debug "No info returned for SMS $ID"
        continue
    fi
    
    NUMBER=$(echo "$INFO" | grep "number:" | head -1 | sed 's/.*number:[[:space:]]*//')
    RAW_TEXT=$(echo "$INFO" | grep "text:" | head -1 | sed 's/.*text:[[:space:]]*//')
    TYPE=$(echo "$INFO" | grep "pdu type:" | head -1 | sed 's/.*pdu type:[[:space:]]*//')
    STATE=$(echo "$INFO" | grep "state:" | head -1 | sed 's/.*state:[[:space:]]*//')
    DATE=$(echo "$INFO" | grep "timestamp:" | head -1 | sed 's/.*timestamp:[[:space:]]*//')
    
    debug "SMS $ID - Number: $NUMBER, Raw Text: $RAW_TEXT, Type: $TYPE, State: $STATE"
    
    if [ -z "$RAW_TEXT" ] || [ "$STATE" = "receiving" ]; then
        debug "No text or receiving state for SMS $ID, skipping"
        continue
    fi
    
    if echo "$DATE" | grep -qE '\+[0-9]{2}$'; then
        DATE=$(echo "$DATE" | sed 's/+\([0-9][0-9]\)$/+\1:00/')
    fi
    
    TEXT_ESC=$(escape_json_text "$RAW_TEXT")
    NUMBER_ESC=$(escape_json_text "$NUMBER")
    
	# Xác định read_status mặc định theo loại tin nhắn
	READ_STATUS=1
	if [ "$TYPE" = "deliver" ]; then
		READ_STATUS=0
	fi	
	
NEW_MESSAGE="{
  \"id\": $ID,
  \"number\": \"$NUMBER_ESC\",
  \"text\": \"$TEXT_ESC\",
  \"date\": \"$DATE\",
  \"type\": \"$TYPE\",
  \"state\": \"$STATE\",
  \"storage\": \"router\",
  \"read_status\": $READ_STATUS
}"

    debug "Created JSON for SMS $ID"
    
    if add_to_monthly "$NEW_MESSAGE"; then
        debug "Successfully saved SMS $ID to archive"
        
        # Xóa SMS khỏi SIM sau khi lưu
        if mmcli -m 0 --messaging-delete-sms="$ID" >/dev/null 2>&1; then
            debug "Deleted SMS $ID from SIM"
        else
            debug "Failed to delete SMS $ID from SIM"
        fi
        
        PROCESSED_COUNT=$((PROCESSED_COUNT + 1))
    else
        debug "Failed to save SMS $ID to archive"
    fi
done

debug "Finished processing. Total new messages: $PROCESSED_COUNT"

# 3. IN RA JSON CHUẨN VỚI MẢNG MESSAGES ĐƯỢC SẮP XẾP GIẢM DẦN THEO ID
jq '.messages |= sort_by(.id) | .messages |= reverse' "$MONTHLY_FILE"

# CLEANUP
rm -f "$TEMP_FILE" "${MONTHLY_FILE}.backup" /tmp/jq_error_$$.log
flock -u 200

debug "=== SMS-READ END ==="
EOF

echo "Tạo CGI SMS-DELETE script..."
cat > "$CGI_DIR/sms-delete" << 'EOF'
#!/bin/sh
echo "Content-Type: application/json; charset=utf-8"
echo ""

# === DEBUG LOG ===
DEBUG_LOG="/tmp/sms-delete-debug.log"
debug() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$DEBUG_LOG"
}

debug "=== SMS-DELETE START ==="

# === CẤU HÌNH ===
ARCHIVE_DIR="/root/sms-archive"
CURRENT_MONTH=$(date "+%Y-%m")
MONTHLY_FILE="$ARCHIVE_DIR/messages-${CURRENT_MONTH}.json"
TEMP_FILE="/tmp/messages_delete_temp_$$.json"

debug "Monthly file: $MONTHLY_FILE"

# === HÀM ESCAPE JSON ===
escape_json() {
    echo "$1" | sed 's/\\/\\\\/g; s/"/\\"/g; s/\t/\\t/g; s/\r/\\r/g; s/\n/\\n/g'
}

# === HÀM TRẢ VỀ LỖI ===
return_error() {
    local error_code="$1"
    local message="$2"
    local details="$3"
    
    debug "ERROR: $error_code - $message - $details"
    
    cat << EOF
{
    "success": false,
    "error_code": "$error_code",
    "message": "$(escape_json "$message")",
    "details": "$(escape_json "$details")",
    "deleted": [],
    "failed": [],
    "total": 0,
    "deleted_count": 0,
    "failed_count": 0,
    "timestamp": "$(date '+%Y-%m-%d %H:%M:%S')"
}
 EOF
    exit 1
}

debug "Starting SMS delete process - Method: $REQUEST_METHOD"

# === LẤY DANH SÁCH ID ===
IDS=""

if [ "$REQUEST_METHOD" = "POST" ]; then
    # Đọc POST data
    if [ -n "$CONTENT_LENGTH" ] && [ "$CONTENT_LENGTH" -gt 0 ]; then
        POST_DATA=$(dd bs="$CONTENT_LENGTH" count=1 2>/dev/null)
    else
        read -r POST_DATA
    fi
    
    debug "POST_DATA: $POST_DATA"
    
    # Parse Content-Type
    CONTENT_TYPE=$(echo "$CONTENT_TYPE" | tr '[:upper:]' '[:lower:]')
    
    if echo "$CONTENT_TYPE" | grep -q "application/json"; then
        # Parse JSON: {"ids": ["14", "15"]} hoặc {"message_ids": ["14"]}
        IDS=$(echo "$POST_DATA" | sed -n 's/.*"ids"[[:space:]]*:[[:space:]]*\[\([^]]*\)\].*/\1/p' | sed 's/"//g' | sed 's/[[:space:]]*,[[:space:]]*/,/g')
        
        if [ -z "$IDS" ]; then
            IDS=$(echo "$POST_DATA" | sed -n 's/.*"message_ids"[[:space:]]*:[[:space:]]*\[\([^]]*\)\].*/\1/p' | sed 's/"//g' | sed 's/[[:space:]]*,[[:space:]]*/,/g')
        fi
        
        if [ -z "$IDS" ]; then
            # Parse single ID: {"id": "14"}
            IDS=$(echo "$POST_DATA" | sed -n 's/.*"id"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p')
        fi
    else
        # Parse form data: ids=14,15 hoặc ids[]=14&ids[]=15
        IDS=$(echo "$POST_DATA" | sed -n 's/^.*ids=\([^&]*\).*$/\1/p' | sed 's/%2C/,/g' | sed 's/%20/ /g')
        
        if [ -z "$IDS" ]; then
            # Parse array format: ids[]=14&ids[]=15
            IDS=$(echo "$POST_DATA" | grep -o 'ids\[\]=[^&]*' | sed 's/ids\[\]=//' | paste -sd ',' -)
        fi
    fi
    
elif [ "$REQUEST_METHOD" = "GET" ] || [ "$REQUEST_METHOD" = "DELETE" ]; then
    # Parse query string: ?ids=14,15
    IDS=$(echo "$QUERY_STRING" | sed -n 's/^.*ids=\([^&]*\).*$/\1/p' | sed 's/%2C/,/g' | sed 's/%20/ /g')
    
    if [ -z "$IDS" ]; then
        # Parse single id: ?id=14
        IDS=$(echo "$QUERY_STRING" | sed -n 's/^.*id=\([^&]*\).*$/\1/p')
    fi
    
    debug "QUERY_STRING: $QUERY_STRING"
fi

debug "Parsed IDS: $IDS"

# === VALIDATION INPUT ===
if [ -z "$IDS" ]; then
    return_error "missing_ids" "Không có ID tin nhắn để xóa" "Vui lòng cung cấp danh sách ID qua parameter 'ids' hoặc 'id'"
fi

# Kiểm tra monthly archive file
if [ ! -f "$MONTHLY_FILE" ]; then
    return_error "archive_not_found" "File archive tháng hiện tại không tồn tại" "Đường dẫn: $MONTHLY_FILE"
fi

if [ ! -w "$MONTHLY_FILE" ]; then
    return_error "archive_no_permission" "Không có quyền ghi vào file archive" "Đường dẫn: $MONTHLY_FILE"
fi

# === FILE LOCKING ===
exec 200>"$MONTHLY_FILE.lock"
if ! flock -n 200; then
    return_error "file_locked" "File đang được sử dụng bởi process khác" "Vui lòng thử lại sau"
fi

# === BACKUP FILE ===
cp "$MONTHLY_FILE" "${MONTHLY_FILE}.backup" || {
    flock -u 200
    return_error "backup_failed" "Không thể tạo backup file" "Backup path: ${MONTHLY_FILE}.backup"
}

# === KHỞI TẠO BIẾN ĐẾM ===
DELETED_COUNT=0
FAILED_COUNT=0
TOTAL_COUNT=0
DELETED_IDS=""
FAILED_IDS=""
DELETED_DETAILS=""
FAILED_DETAILS=""

# === XỬ LÝ XÓA MESSAGES THEO ID ===
debug "Processing delete for IDs: $IDS"

# Tạo danh sách IDs để xóa
DELETE_IDS_LIST=""
IFS=','
for ID in $IDS; do
    # Làm sạch ID - chỉ giữ lại số
    CLEAN_ID=$(echo "$ID" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//' | sed 's/[^0-9]//g')
    
    # Bỏ qua ID rỗng hoặc không hợp lệ
    if [ -z "$CLEAN_ID" ] || [ "$CLEAN_ID" = "0" ]; then
        debug "Skipping invalid ID: '$ID'"
        continue
    fi
    
    TOTAL_COUNT=$((TOTAL_COUNT + 1))
    
    if [ -z "$DELETE_IDS_LIST" ]; then
        DELETE_IDS_LIST="$CLEAN_ID"
    else
        DELETE_IDS_LIST="$DELETE_IDS_LIST,$CLEAN_ID"
    fi
    
    debug "Added ID $CLEAN_ID to delete list"
done

debug "Final delete IDs list: $DELETE_IDS_LIST"

if [ -z "$DELETE_IDS_LIST" ]; then
    flock -u 200
    return_error "no_valid_ids" "Không có ID hợp lệ để xóa" "Tất cả IDs đều không hợp lệ"
fi

# === XỬ LÝ JSON VỚI JQ HOẶC AWK ===
SUCCESS=false

if command -v jq >/dev/null 2>&1; then
    debug "Using jq for JSON processing"
    
    # Đọc file hiện tại
    CURRENT_JSON=$(cat "$MONTHLY_FILE")
    
    # Tạo filter jq để xóa messages có ID trong danh sách
    # Chuyển đổi comma-separated list thành jq array
    JQ_IDS_ARRAY="[$(echo "$DELETE_IDS_LIST" | sed 's/,/,/g' | sed 's/[^,0-9]//g')]"
    
    debug "JQ IDs array: $JQ_IDS_ARRAY"
    
    # Đếm số messages trước khi xóa
    OLD_COUNT=$(echo "$CURRENT_JSON" | jq '.messages | length' 2>/dev/null || echo 0)
    debug "Messages before delete: $OLD_COUNT"
    
    # Xử lý xóa với jq
    CURRENT_TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
    
    NEW_JSON=$(echo "$CURRENT_JSON" | jq --argjson delete_ids "$JQ_IDS_ARRAY" \
        --arg timestamp "$CURRENT_TIMESTAMP" '
        # Lưu messages cũ để so sánh
        (.messages | map(select(.id as $id | $delete_ids | index($id) | not))) as $remaining_messages |
        # Cập nhật file với messages còn lại
        .messages = $remaining_messages |
        .total = ($remaining_messages | length) |
        .last_updated = $timestamp
    ' 2>/dev/null)
    
    if [ $? -eq 0 ] && [ -n "$NEW_JSON" ]; then
        # Đếm số messages sau khi xóa
        NEW_COUNT=$(echo "$NEW_JSON" | jq '.messages | length' 2>/dev/null || echo 0)
        DELETED_COUNT=$((OLD_COUNT - NEW_COUNT))
        FAILED_COUNT=$((TOTAL_COUNT - DELETED_COUNT))
        
        debug "Messages after delete: $NEW_COUNT"
        debug "Actually deleted: $DELETED_COUNT"
        
        # Lưu file mới
        echo "$NEW_JSON" > "$TEMP_FILE"
        
        if [ -s "$TEMP_FILE" ]; then
            mv "$TEMP_FILE" "$MONTHLY_FILE"
            SUCCESS=true
            DELETED_IDS="$DELETE_IDS_LIST"
            debug "Successfully deleted $DELETED_COUNT messages using jq"
        else
            debug "Failed to write new JSON file"
            FAILED_IDS="$DELETE_IDS_LIST"
        fi
    else
        debug "jq processing failed"
        FAILED_IDS="$DELETE_IDS_LIST"
        FAILED_COUNT=$TOTAL_COUNT
    fi

else
    debug "Using awk for JSON processing (jq not available)"
    
    # AWK approach - đánh dấu messages để xóa
    awk -v delete_ids="$DELETE_IDS_LIST" '
    BEGIN {
        # Parse danh sách IDs cần xóa
        split(delete_ids, ids_to_delete, ",")
        for (i in ids_to_delete) {
            delete_map[ids_to_delete[i]] = 1
        }
        
        in_messages = 0
        brace_count = 0
        current_id = ""
        current_message = ""
        skip_message = 0
        deleted_count = 0
        total_messages = 0
    }
    
    /"messages"[[:space:]]*:[[:space:]]*\[/ {
        in_messages = 1
        print $0
        next
    }
    
    in_messages && /^\s*\]/ {
        in_messages = 0
        print $0
        next
    }
    
    in_messages {
        if (/^\s*{/) {
            brace_count = 1
            current_message = $0
            skip_message = 0
            current_id = ""
            total_messages++
        } else if (brace_count > 0) {
            current_message = current_message "\n" $0
            
            # Tìm ID trong message
            if (/\"id\"[[:space:]]*:[[:space:]]*([0-9]+)/) {
                match($0, /\"id\"[[:space:]]*:[[:space:]]*([0-9]+)/, arr)
                current_id = arr[1]
                if (current_id in delete_map) {
                    skip_message = 1
                    deleted_count++
                }
            }
            
            if (/^\s*}/) {
                brace_count = 0
                if (!skip_message) {
                    print current_message
                }
                current_message = ""
            }
        }
    }
    
    !in_messages {
        # Cập nhật total count
        if (/\"total\"[[:space:]]*:[[:space:]]*[0-9]+/) {
            gsub(/\"total\"[[:space:]]*:[[:space:]]*[0-9]+/, "\"total\": " (total_messages - deleted_count))
        }
        # Cập nhật timestamp
        if (/\"last_updated\"/) {
            gsub(/"[^"]*"$/, "\"" strftime("%Y-%m-%d %H:%M:%S") "\"", $0)
        }
        print $0
    }
    
    END {
        print deleted_count > "/tmp/awk_deleted_count_" PROCINFO["pid"]
    }
    ' "$MONTHLY_FILE" > "$TEMP_FILE"
    
    # Đọc số lượng đã xóa từ AWK
    if [ -f "/tmp/awk_deleted_count_$$" ]; then
        DELETED_COUNT=$(cat "/tmp/awk_deleted_count_$$")
        rm -f "/tmp/awk_deleted_count_$$"
    else
        DELETED_COUNT=0
    fi
    
    FAILED_COUNT=$((TOTAL_COUNT - DELETED_COUNT))
    
    # Kiểm tra kết quả
    if [ -s "$TEMP_FILE" ]; then
        mv "$TEMP_FILE" "$MONTHLY_FILE"
        SUCCESS=true
        DELETED_IDS="$DELETE_IDS_LIST"
        debug "Successfully processed with awk, deleted: $DELETED_COUNT"
    else
        SUCCESS=false
        FAILED_IDS="$DELETE_IDS_LIST"
        debug "awk processing failed"
    fi
fi

# === TẠO JSON ARRAYS ===
DELETED_ARRAY="[]"
FAILED_ARRAY="[]"

if [ -n "$DELETED_IDS" ] && [ "$DELETED_COUNT" -gt 0 ]; then
    DELETED_ARRAY="[$(echo "$DELETED_IDS" | sed 's/,/","/g' | sed 's/^/"/' | sed 's/$/"/')]"
fi

if [ -n "$FAILED_IDS" ] && [ "$FAILED_COUNT" -gt 0 ]; then
    FAILED_ARRAY="[$(echo "$FAILED_IDS" | sed 's/,/","/g' | sed 's/^/"/' | sed 's/$/"/')]"
fi

# === TẠO RESPONSE MESSAGE ===
if [ "$SUCCESS" = "true" ] && [ "$DELETED_COUNT" -gt 0 ]; then
    if [ "$DELETED_COUNT" -eq "$TOTAL_COUNT" ]; then
        MESSAGE="Đã xóa thành công tất cả $DELETED_COUNT tin nhắn từ archive"
    else
        MESSAGE="Đã xóa thành công $DELETED_COUNT/$TOTAL_COUNT tin nhắn từ archive"
    fi
else
    MESSAGE="Không thể xóa tin nhắn nào từ archive"
    SUCCESS=false
fi

debug "Final result - Success: $SUCCESS, Deleted: $DELETED_COUNT, Failed: $FAILED_COUNT"

# === TRẢ VỀ JSON RESPONSE ===
cat << EOF
{
    "success": $SUCCESS,
    "message": "$(escape_json "$MESSAGE")",
    "total": $TOTAL_COUNT,
    "deleted_count": $DELETED_COUNT,
    "failed_count": $FAILED_COUNT,
    "deleted": $DELETED_ARRAY,
    "failed": $FAILED_ARRAY,
    "details": {
        "monthly_file": "$MONTHLY_FILE",
        "processing_method": "$(command -v jq >/dev/null && echo 'jq' || echo 'awk')",
        "backup_created": true,
        "request_method": "$REQUEST_METHOD",
        "timestamp": "$(date '+%Y-%m-%d %H:%M:%S')"
    }
}
 EOF

# === CLEANUP ===
rm -f "$TEMP_FILE"
flock -u 200

debug "=== SMS-DELETE END ==="

# === SET EXIT CODE ===
if [ "$SUCCESS" = "true" ]; then
    exit 0
else
    exit 1
fi
EOF

echo "Tạo CGI SMS-MARK-READ script..."
cat > "$CGI_DIR/sms-mark-read" << 'EOF'
#!/bin/sh
echo "Content-Type: application/json; charset=utf-8"
echo ""

# ===== CẤU HÌNH =====
ARCHIVE_DIR="/root/sms-archive"
LOG_FILE="/tmp/sms-mark-read.log"
DEBUG=1  # 1 = bật debug, 0 = tắt debug

# ===== HÀM LOG DEBUG =====
log_debug() {
    if [ "$DEBUG" -eq 1 ]; then
        echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
    fi
}

# ===== HÀM ESCAPE JSON =====
escape_json() {
    echo "$1" | sed 's/\\/\\\\/g; s/"/\\"/g; s/\t/\\t/g; s/\r/\\r/g; s/\n/\\n/g'
}

# ===== HÀM TRẢ VỀ LỖI =====
return_error() {
    local error_code="$1"
    local message="$2"
    local details="$3"

    log_debug "ERROR: $error_code - $message - $details"

    cat << EOF
{
    "success": false,
    "status": "error",
    "error_code": "$error_code",
    "message": "$(escape_json "$message")",
    "details": "$(escape_json "$details")",
    "timestamp": "$(date '+%Y-%m-%d %H:%M:%S')"
}
 EOF
    exit 1
}

# ===== LẤY THAM SỐ TỪ REQUEST =====
MESSAGE_ID=""
READ_STATUS=""

if [ "$REQUEST_METHOD" = "POST" ]; then
    if [ -n "$CONTENT_LENGTH" ] && [ "$CONTENT_LENGTH" -gt 0 ]; then
        POST_DATA=$(dd bs="$CONTENT_LENGTH" count=1 2>/dev/null)
    else
        read -r POST_DATA
    fi
    log_debug "POST_DATA: $POST_DATA"

    CONTENT_TYPE_LOWER=$(echo "$CONTENT_TYPE" | tr '[:upper:]' '[:lower:]')
    if echo "$CONTENT_TYPE_LOWER" | grep -q "application/json"; then
        MESSAGE_ID=$(echo "$POST_DATA" | sed -n 's/.*"message_id"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p')
        if [ -z "$MESSAGE_ID" ]; then
            MESSAGE_ID=$(echo "$POST_DATA" | sed -n 's/.*"id"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p')
        fi

        READ_STATUS=$(echo "$POST_DATA" | sed -n 's/.*"read_status"[[:space:]]*:[[:space:]]*\([01]\).*/\1/p')
        if [ -z "$READ_STATUS" ]; then
            READ_STATUS=$(echo "$POST_DATA" | sed -n 's/.*"read"[[:space:]]*:[[:space:]]*\([01]\).*/\1/p')
        fi
    else
        MESSAGE_ID=$(echo "$POST_DATA" | sed -n 's/.*id=\([^&]*\).*/\1/p')
        if [ -z "$MESSAGE_ID" ]; then
            MESSAGE_ID=$(echo "$POST_DATA" | sed -n 's/.*message_id=\([^&]*\).*/\1/p')
        fi

        READ_STATUS=$(echo "$POST_DATA" | sed -n 's/.*read_status=\([^&]*\).*/\1/p')
        if [ -z "$READ_STATUS" ]; then
            READ_STATUS=$(echo "$POST_DATA" | sed -n 's/.*read=\([^&]*\).*/\1/p')
        fi
    fi
else
    MESSAGE_ID=$(echo "$QUERY_STRING" | sed -n 's/.*id=\([^&]*\).*/\1/p')
    if [ -z "$MESSAGE_ID" ]; then
        MESSAGE_ID=$(echo "$QUERY_STRING" | sed -n 's/.*message_id=\([^&]*\).*/\1/p')
    fi

    READ_STATUS=$(echo "$QUERY_STRING" | sed -n 's/.*read_status=\([^&]*\).*/\1/p')
    if [ -z "$READ_STATUS" ]; then
        READ_STATUS=$(echo "$QUERY_STRING" | sed -n 's/.*read=\([^&]*\).*/\1/p')
    fi
    log_debug "QUERY_STRING: $QUERY_STRING"
fi

log_debug "Parsed MESSAGE_ID: $MESSAGE_ID"
log_debug "Parsed READ_STATUS: $READ_STATUS"

# ===== KIỂM TRA ĐẦU VÀO =====
if [ -z "$MESSAGE_ID" ]; then
    return_error "missing_message_id" "Thiếu tham số message ID" "Vui lòng cung cấp 'id' hoặc 'message_id'"
fi

if [ -z "$READ_STATUS" ]; then
    return_error "missing_read_status" "Thiếu tham số read status" "Vui lòng cung cấp 'read_status' hoặc 'read' (0 hoặc 1)"
fi

CLEAN_ID=$(echo "$MESSAGE_ID" | sed 's/[^0-9]//g')
if [ -z "$CLEAN_ID" ] || [ "$CLEAN_ID" = "0" ]; then
    return_error "invalid_message_id" "ID tin nhắn không hợp lệ" "ID phải là số nguyên dương: '$MESSAGE_ID'"
fi

if [ "$READ_STATUS" != "0" ] && [ "$READ_STATUS" != "1" ]; then
    return_error "invalid_read_status" "Trạng thái đọc không hợp lệ" "read_status phải là 0 (chưa đọc) hoặc 1 (đã đọc): '$READ_STATUS'"
fi

if [ ! -d "$ARCHIVE_DIR" ]; then
    return_error "archive_not_found" "Thư mục archive không tồn tại" "Đường dẫn: $ARCHIVE_DIR"
fi

# ===== XÁC ĐỊNH FILE THÁNG TƯƠNG ỨNG =====
CURRENT_MONTH=$(date "+%Y-%m")
MONTHLY_FILE="$ARCHIVE_DIR/messages-${CURRENT_MONTH}.json"

if [ ! -f "$MONTHLY_FILE" ]; then
    return_error "archive_file_not_found" "File archive tháng không tồn tại" "Đường dẫn: $MONTHLY_FILE"
fi

if [ ! -r "$MONTHLY_FILE" ] || [ ! -w "$MONTHLY_FILE" ]; then
    return_error "archive_file_permission_error" "Không có quyền truy cập file archive" "File: $MONTHLY_FILE"
fi

log_debug "Using archive file: $MONTHLY_FILE"

# ===== CẬP NHẬT read_status TRONG MẢNG messages THEO ID =====
if ! command -v jq >/dev/null 2>&1; then
    return_error "jq_missing" "Lệnh jq không được cài đặt" "Không thể xử lý file JSON"
fi

TEMP_FILE="/tmp/messages_temp_$$.json"

jq --argjson id "$CLEAN_ID" --argjson rs "$READ_STATUS" '
    .messages |= map(
        if .id == $id then .read_status = $rs else . end
    )
' "$MONTHLY_FILE" > "$TEMP_FILE"

if [ $? -ne 0 ] || [ ! -s "$TEMP_FILE" ]; then
    return_error "jq_update_failed" "Cập nhật read_status thất bại" "Lỗi khi xử lý jq"
fi

# Tạo bản sao lưu trước khi ghi
BACKUP_FILE="/tmp/messages-$(date +%Y%m%d_%H%M%S).backup.json"
cp "$MONTHLY_FILE" "$BACKUP_FILE" 2>/dev/null
log_debug "Tạo bản backup: $BACKUP_FILE"

# Ghi lại file archive đã cập nhật
if mv "$TEMP_FILE" "$MONTHLY_FILE"; then
    log_debug "Cập nhật read_status cho message_id $CLEAN_ID thành công."

    cat << EOF
{
    "success": true,
    "status": "success",
    "message": "Cập nhật trạng thái đọc tin nhắn thành công",
    "message_id": $CLEAN_ID,
    "read_status": $READ_STATUS,
    "changed": true,
    "archive_file": "$MONTHLY_FILE",
    "backup_file": "$BACKUP_FILE",
    "timestamp": "$(date '+%Y-%m-%d %H:%M:%S')"
}
 EOF
    exit 0
else
    # Rollback
    cp "$BACKUP_FILE" "$MONTHLY_FILE" 2>/dev/null
    return_error "file_write_error" "Không thể ghi file archive sau cập nhật" "Đã rollback về bản backup"
fi
EOF

echo "Tạo hệ thống SMS..."
cat > "$WEB_DIR/sms.html" << 'EOF'
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>SMS Manager Pro - Quản lý tin nhắn chuyên nghiệp</title>
    <link rel="stylesheet" href="style.css">
    <link href="https://cdn.jsdelivr.net/npm/boxicons@2.1.4/css/boxicons.min.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
</head>
<body>
    <!-- Header -->
    <header class="header">
        <div class="container">
            <div class="header-content">
                <div class="logo">
                    <i class='bx bx-message-dots'></i>
                    <span>TRUNG TÂM TIN NHẮN EM919X 5G</span>
                </div>
                <div class="header-actions">
                    <button class="btn btn-outline" id="refreshBtn">
                        <i class='bx bx-refresh'></i>
                        Làm mới
                    </button>
                    <div class="user-menu">
                        <i class='bx bx-user-circle'></i>
                        <span>Admin</span>
                    </div>
                </div>
            </div>
        </div>
    </header>


    <!-- Main Content -->
    <main class="main-content">
        <div class="container">
            <div class="content-grid">
                
                <!-- Sidebar -->
                <aside class="sidebar">
                    <!-- Stats Cards -->
                    <div class="stats-grid">
                        <div class="stat-card">
                            <div class="stat-icon primary">
                                <i class='bx bx-message'></i>
                            </div>
                            <div class="stat-info">
                                <div class="stat-number" id="totalMessages">0</div>
                                <div class="stat-label">Tổng tin nhắn</div>
                            </div>
                        </div>
                        <div class="stat-card">
                            <div class="stat-icon success">
                                <i class='bx bx-message-check'></i>
                            </div>
                            <div class="stat-info">
                                <div class="stat-number" id="sentMessages">0</div>
                                <div class="stat-label">Đã gửi</div>
                            </div>
                        </div>
                        <div class="stat-card">
                            <div class="stat-icon warning">
                                <i class='bx bx-message-dots'></i>
                            </div>
                            <div class="stat-info">
                                <div class="stat-number" id="receivedMessages">0</div>
                                <div class="stat-label">Đã nhận</div>
                            </div>
                        </div>
                        <div class="stat-card">
                            <div class="stat-icon info">
                                <i class='bx bx-message-alt-error'></i>
                            </div>
                            <div class="stat-info">
                                <div class="stat-number" id="unreadMessages">0</div>
                                <div class="stat-label">Chưa đọc</div>
                            </div>
                        </div>
                    </div>

                    <!-- Quick Actions -->
                    <div class="quick-actions">
                        <h3 class="section-title">
                            <i class='bx bx-zap'></i>
                            Thao tác nhanh
                        </h3>
                        <div class="action-buttons">
                            <button class="action-btn primary" id="newMessageBtn">
                                <i class='bx bx-plus'></i>
                                Tin nhắn mới
                            </button>
                            <button class="action-btn success" id="exportBtn">
                                <i class='bx bx-download'></i>
                                Xuất dữ liệu
                            </button>
                            <button class="action-btn warning" id="bulkDeleteBtn">
                                <i class='bx bx-trash'></i>
                                Xóa hàng loạt
                            </button>
                        </div>
                    </div>
                    <!-- Basic -->
                    <div class="auto-refresh-settings">
                        <label>
                            <input type="checkbox" id="userActivityPause" checked>
                            Tạm dừng khi có hoạt động
                        </label>
                        <select id="activityDelay">
                            <option value="15">15 giây</option>
                            <option value="30" selected>30 giây</option>
                            <option value="60">60 giây</option>
                        </select>
                    </div>
                    <!-- Filter Panel -->
                    <div class="filter-panel">
                        <h3 class="section-title">
                            <i class='bx bx-filter'></i>
                            Bộ lọc
                        </h3>
                        
                        <div class="filter-group">
                            <label class="filter-label">Loại tin nhắn</label>
                            <select class="form-select" id="messageType">
                                <option value="">Tất cả</option>
                                <option value="received">Tin nhắn đến</option>
                                <option value="sent">Tin nhắn gửi</option>
                            </select>
                        </div>

                        <div class="filter-group">
                            <label class="filter-label">Trạng thái</label>
                            <select class="form-select" id="readStatus">
                                <option value="">Tất cả</option>
                                <option value="unread">Chưa đọc</option>
                                <option value="read">Đã đọc</option>
                            </select>
                        </div>

                        <div class="filter-group">
                            <label class="filter-label">Thời gian</label>
                            <select class="form-select" id="timeFilter">
                                <option value="">Tất cả</option>
                                <option value="today">Hôm nay</option>
                                <option value="yesterday">Hôm qua</option>
                                <option value="thisWeek">Tuần này</option>
                                <option value="lastWeek">Tuần trước</option>
                                <option value="thisMonth">Tháng này</option>
                                <option value="lastMonth">Tháng trước</option>
                            </select>
                        </div>

                        <div class="filter-group">
                            <label class="filter-label">Tìm kiếm</label>
                            <div class="search-box">
                                <i class='bx bx-search'></i>
                                <input type="text" id="searchInput" placeholder="Tìm theo số điện thoại hoặc nội dung...">
                            </div>
                        </div>

                        <div class="filter-actions">
                            <button class="btn btn-primary btn-small" id="applyFilter">
                                <i class='bx bx-check'></i>
                                Áp dụng
                            </button>
                            <button class="btn btn-outline btn-small" id="clearFilter">
                                <i class='bx bx-x'></i>
                                Xóa bộ lọc
                            </button>
                        </div>
                    </div>
                </aside>

                <!-- Content Area -->
                <div class="content-area">
                    
                    <!-- Toolbar -->
                    <div class="toolbar">
                        <div class="toolbar-left">
                            <div class="view-tabs">
                                <button class="tab-btn active" data-view="all">
                                    <i class='bx bx-list-ul'></i>
                                    Tất cả
                                </button>
                                <button class="tab-btn" data-view="received">
                                    <i class='bx bx-message-rounded-check'></i>
                                    Tin nhắn đến
                                </button>
                                <button class="tab-btn" data-view="sent">
                                    <i class='bx bx-send'></i>
                                    Tin nhắn gửi
                                </button>
                            </div>
                        </div>
                        
                        <div class="toolbar-right">
                            <div class="bulk-actions" id="bulkActions" style="display: none;">
                                <span class="selected-count" id="selectedCount">0 đã chọn</span>
                                <button class="btn btn-outline btn-small" id="selectAllBtn">
                                    <i class='bx bx-check-square'></i>
                                    Chọn tất cả
                                </button>
                                <button class="btn btn-success btn-small" id="markReadBtn">
                                    <i class='bx bx-check-circle'></i>
                                    Đánh dấu đã đọc
                                </button>
                                <button class="btn btn-danger btn-small" id="deleteSelectedBtn">
                                    <i class='bx bx-trash'></i>
                                    Xóa đã chọn
                                </button>
                            </div>
                            <!-- Thêm phần tự động làm mới -->
                            <!-- Thêm indicator hiển thị trạng thái -->
                            <div id="autoRefreshIndicator" class="auto-refresh-indicator">
                                <i class='bx bx-refresh'></i> Tắt tự động làm mới
                            </div>
                            <div class="auto-refresh-control">
                                </label>
                                <select id="autoRefreshSelect" class="form-select">
                                    <option value="0">Tắt</option>
                                    <option value="5">5 giây</option>
                                    <option value="10" selected>10 giây</option>
                                    <option value="20">20 giây</option>
                                    <option value="30">30 giây</option>
                                    <option value="60">60 giây</option>
                                </select>
                            </div>
                            <div class="pagination-info">
                                <select class="form-select small" id="itemsPerPage">
                                    <option value="20">20/trang</option>
                                    <option value="50">50/trang</option>
                                    <option value="100">100/trang</option>
                                </select>
                            </div>
                        </div>
                    </div>

                    <!-- Messages List -->
                    <div class="messages-container">
                        <div id="messagesLoading" class="loading-state">
                            <div class="spinner"></div>
                            <span>Đang tải tin nhắn...</span>
                        </div>

                        <div id="messagesEmpty" class="empty-state" style="display: none;">
                            <div class="empty-icon">
                                <i class='bx bx-message-alt-x'></i>
                            </div>
                            <h3>Không có tin nhắn</h3>
                            <p>Chưa có tin nhắn nào hoặc không tìm thấy kết quả phù hợp với bộ lọc.</p>
                            <button class="btn btn-primary" id="clearFiltersBtn">
                                <i class='bx bx-filter-alt'></i>
                                Xóa bộ lọc
                            </button>
                        </div>

                        <div class="messages-list" id="messagesList">
                            <!-- Messages will be dynamically loaded here -->
                        </div>
                    </div>

                    <!-- Pagination -->
                    <div class="pagination-container">
                        <div class="pagination" id="pagination">
                            <!-- Pagination will be dynamically generated -->
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </main>

    <!-- New Message Modal -->
    <div class="modal" id="newMessageModal">
        <div class="modal-overlay"></div>
        <div class="modal-container">
            <div class="modal-header">
                <h3>
                    <i class='bx bx-message-add'></i>
                    Gửi tin nhắn mới
                </h3>
                <button class="modal-close" id="closeNewMessageModal">
                    <i class='bx bx-x'></i>
                </button>
            </div>
            <div class="modal-body">
                <!-- Cập nhật form trong modal -->
                <form id="newMessageForm" class="message-form">
                    <div class="form-group">
                        <label class="form-label" for="recipientPhone">
                            <i class='bx bx-phone'></i>
                            Số điện thoại người nhận
                        </label>
                        <input type="tel" id="recipientPhone" class="form-input" 
                               placeholder="Nhập số điện thoại" 
                               title="Nhập bất kỳ số điện thoại nào"
                               required>
                        <div class="form-hint">Hỗ trợ: số di động, số dịch vụ (888, 9xxx), số cố định, số quốc tế</div>
                        <div class="form-error" id="phoneError" style="display: none;"></div>
                    </div>

                
                    <div class="form-group">
                        <label class="form-label" for="messageContent">
                            <i class='bx bx-message-detail'></i>
                            Nội dung tin nhắn
                        </label>
                        <textarea id="messageContent" class="form-textarea" 
                                  placeholder="Nhập nội dung tin nhắn..." 
                                  rows="4" 
                                  maxlength="160" 
                                  required></textarea>
                        <div class="form-footer">
                            <div class="char-counter">
                                <span id="charCount">0</span>/160 ký tự
                            </div>
                            <div class="sms-count">
                                <span id="smsCount">1</span> tin nhắn
                            </div>
                        </div>
                        <div class="form-error" id="contentError" style="display: none;"></div>
                    </div>
                
                    <div class="form-group">
                        <label class="form-label">
                            <i class='bx bx-template'></i>
                            Mẫu tin nhắn
                        </label>
                        <select id="messageTemplate" class="form-select">
                            <option value="">Chọn mẫu tin nhắn...</option>
                            <option value="greeting">Chào hỏi khách hàng</option>
                            <option value="promotion">Thông báo khuyến mãi</option>
                            <option value="reminder">Nhắc nhở thanh toán</option>
                            <option value="confirmation">Xác nhận đơn hàng</option>
                        </select>
                    </div>
                
                    <!-- Thay thế phần connection-status trong modal -->
                    <div class="connection-status" id="connectionStatus">
                        <div class="status-indicator" id="statusIndicator">
                            <i class='bx bx-loader-alt bx-spin'></i>
                            <span>Đang kiểm tra kết nối...</span>
                        </div>
                    </div>

                
                    <div class="form-actions">
                        <button type="button" class="btn btn-outline" id="cancelNewMessage">
                            <i class='bx bx-x'></i>
                            Hủy
                        </button>
                        <button type="submit" class="btn btn-primary" id="sendMessageBtn">
                            <i class='bx bx-send'></i>
                            Gửi tin nhắn
                        </button>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <!-- Message Detail Modal -->
    <div class="modal" id="messageDetailModal">
        <div class="modal-overlay"></div>
        <div class="modal-container modal-lg">
            <div class="modal-header">
                <h3>
                    <i class='bx bx-message-detail'></i>
                    Chi tiết tin nhắn
                </h3>
                <button class="modal-close" id="closeMessageDetailModal">
                    <i class='bx bx-x'></i>
                </button>
            </div>
            <div class="modal-body" id="messageDetailContent">
                <!-- Content will be dynamically loaded -->
            </div>
        </div>
    </div>

    <!-- Toast Notifications -->
    <div class="toast-container" id="toastContainer">
        <!-- Toasts will be dynamically added here -->
    </div>

    <!-- Script -->
    <script src="script.js"></script>
</body>
</html>
EOF

cat > "$WEB_DIR/style.css" << 'EOF'
/* Reset và Base Styles */
* {
    margin: 0;
    padding: 0;
    box-sizing: border-box;
}

:root {
    /* Thêm vào phần variables hiện có */
    --white: #ffffff;
    --dark: #1a1a1a;
    --primary-rgb: 59, 130, 246;
    --success-rgb: 16, 185, 129;
    --warning-rgb: 245, 158, 11;
    --danger-rgb: 239, 68, 68;
    
    /* Countdown specific colors */
    --countdown-bg: rgba(0, 0, 0, 0.8);
    --countdown-text: #ffffff;
    --countdown-active: #10b981;
    --countdown-warning: #f59e0b;
    --countdown-danger: #ef4444;
    --countdown-paused: #8b5cf6;
    --countdown-border: rgba(255, 255, 255, 0.2);
    
    /* Colors */
    --primary-color: #3b82f6;
    --primary-dark: #2563eb;
    --primary-light: #dbeafe;
    
    --success-color: #10b981;
    --success-light: #d1fae5;
    
    --warning-color: #f59e0b;
    --warning-light: #fef3c7;
    
    --danger-color: #ef4444;
    --danger-light: #fecaca;
    
    --info-color: #06b6d4;
    --info-light: #cffafe;
    
    --gray-50: #f9fafb;
    --gray-100: #f3f4f6;
    --gray-200: #e5e7eb;
    --gray-300: #d1d5db;
    --gray-400: #9ca3af;
    --gray-500: #6b7280;
    --gray-600: #4b5563;
    --gray-700: #374151;
    --gray-800: #1f2937;
    --gray-900: #111827;
    
    /* Typography */
    --font-family: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
    --font-size-xs: 0.75rem;
    --font-size-sm: 0.875rem;
    --font-size-base: 1rem;
    --font-size-lg: 1.125rem;
    --font-size-xl: 1.25rem;
    --font-size-2xl: 1.5rem;
    --font-size-3xl: 1.875rem;
    
    /* Spacing */
    --spacing-1: 0.25rem;
    --spacing-2: 0.5rem;
    --spacing-3: 0.75rem;
    --spacing-4: 1rem;
    --spacing-5: 1.25rem;
    --spacing-6: 1.5rem;
    --spacing-8: 2rem;
    --spacing-12: 3rem;
    
    /* Borders */
    --border-radius: 0.5rem;
    --border-radius-lg: 0.75rem;
    --border-radius-full: 50%;
    
    /* Shadows */
    --shadow-sm: 0 1px 2px 0 rgba(0, 0, 0, 0.05);
    --shadow: 0 1px 3px 0 rgba(0, 0, 0, 0.1), 0 1px 2px 0 rgba(0, 0, 0, 0.06);
    --shadow-md: 0 4px 6px -1px rgba(0, 0, 0, 0.1), 0 2px 4px -1px rgba(0, 0, 0, 0.06);
    --shadow-lg: 0 10px 15px -3px rgba(0, 0, 0, 0.1), 0 4px 6px -2px rgba(0, 0, 0, 0.05);
    --shadow-xl: 0 20px 25px -5px rgba(0, 0, 0, 0.1), 0 10px 10px -5px rgba(0, 0, 0, 0.04);
    
    /* Transitions */
    --transition: all 0.15s ease-in-out;
}

body {
    font-family: var(--font-family);
    font-size: var(--font-size-base);
    line-height: 1.6;
    color: var(--gray-800);
    background-color: var(--gray-50);
    overflow-x: hidden;
}

.container {
    max-width: 1400px;
    margin: 0 auto;
    padding: 0 var(--spacing-4);
}

/* Header */
.header {
    background: white;
    border-bottom: 1px solid var(--gray-200);
    box-shadow: var(--shadow-sm);
    position: sticky;
    top: 0;
    z-index: 100;
}

.header-content {
    display: flex;
    align-items: center;
    justify-content: space-between;
    height: 70px;
}

.logo {
    display: flex;
    align-items: center;
    gap: var(--spacing-3);
    font-size: var(--font-size-xl);
    font-weight: 700;
    color: var(--primary-color);
}

.logo i {
    font-size: 2rem;
}

.header-actions {
    display: flex;
    align-items: center;
    gap: var(--spacing-3);
    flex-wrap: wrap;
}

.user-menu {
    display: flex;
    align-items: center;
    gap: var(--spacing-2);
    padding: var(--spacing-2) var(--spacing-3);
    border-radius: var(--border-radius);
    background: var(--gray-100);
    color: var(--gray-700);
    font-weight: 500;
}

.user-menu i {
    font-size: var(--font-size-xl);
}

/* Main Content */
.main-content {
    padding: var(--spacing-6) 0;
    min-height: calc(100vh - 70px);
}

.content-grid {
    display: grid;
    grid-template-columns: 320px 1fr;
    gap: var(--spacing-6);
}

/* Sidebar */
.sidebar {
    display: flex;
    flex-direction: column;
    gap: var(--spacing-6);
}

/* Stats Cards */
.stats-grid {
    display: grid;
    grid-template-columns: 1fr 1fr;
    gap: var(--spacing-4);
}

.stat-card {
    background: white;
    padding: var(--spacing-4);
    border-radius: var(--border-radius-lg);
    box-shadow: var(--shadow);
    border: 1px solid var(--gray-200);
    display: flex;
    align-items: center;
    gap: var(--spacing-3);
    transition: var(--transition);
}

.stat-card:hover {
    transform: translateY(-2px);
    box-shadow: var(--shadow-md);
}

.stat-icon {
    width: 48px;
    height: 48px;
    border-radius: var(--border-radius);
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: var(--font-size-xl);
}

.stat-icon.primary {
    background: var(--primary-light);
    color: var(--primary-color);
}

.stat-icon.success {
    background: var(--success-light);
    color: var(--success-color);
}

.stat-icon.warning {
    background: var(--warning-light);
    color: var(--warning-color);
}

.stat-icon.info {
    background: var(--info-light);
    color: var(--info-color);
}

.stat-number {
    font-size: var(--font-size-2xl);
    font-weight: 700;
    color: var(--gray-900);
    line-height: 1;
}

.stat-label {
    font-size: var(--font-size-sm);
    color: var(--gray-500);
    font-weight: 500;
}

/* Quick Actions */
.quick-actions,
.filter-panel {
    background: white;
    padding: var(--spacing-5);
    border-radius: var(--border-radius-lg);
    box-shadow: var(--shadow);
    border: 1px solid var(--gray-200);
}

.section-title {
    display: flex;
    align-items: center;
    gap: var(--spacing-2);
    font-size: var(--font-size-lg);
    font-weight: 600;
    color: var(--gray-800);
    margin-bottom: var(--spacing-4);
}

.section-title i {
    color: var(--primary-color);
}

.action-buttons {
    display: flex;
    flex-direction: column;
    gap: var(--spacing-3);
}

.action-btn {
    display: flex;
    align-items: center;
    gap: var(--spacing-2);
    padding: var(--spacing-3) var(--spacing-4);
    border: none;
    border-radius: var(--border-radius);
    font-size: var(--font-size-sm);
    font-weight: 500;
    cursor: pointer;
    transition: var(--transition);
    text-decoration: none;
    justify-content: flex-start;
}

.action-btn.primary {
    background: var(--primary-color);
    color: white;
}

.action-btn.primary:hover {
    background: var(--primary-dark);
}

.action-btn.success {
    background: var(--success-color);
    color: white;
}

.action-btn.success:hover {
    background: #059669;
}

.action-btn.warning {
    background: var(--warning-color);
    color: white;
}

.action-btn.warning:hover {
    background: #d97706;
}

/* Filter Panel */
.filter-group {
    margin-bottom: 24px;
    width: 100%;
}

.filter-label {
    display: block;
    font-weight: 600;
    color: #1f2937;
    margin-bottom: 10px;
    font-size: 15px;
    letter-spacing: -0.025em;
}

.filter-label::before {
    content: '';
    width: 3px;
    height: 16px;
    background: linear-gradient(135deg, #3b82f6, #1d4ed8);
    border-radius: 2px;
    margin-right: 8px;
}

.form-select {
    width: 100%;
    padding: 14px 50px 14px 16px;
    font-size: 15px;
    font-weight: 500;
    color: #1e293b;
    background: linear-gradient(145deg, #ffffff, #f8fafc);
    background-image: url("data:image/svg+xml,%3csvg xmlns='http://www.w3.org/2000/svg' fill='none' viewBox='0 0 20 20'%3e%3cpath stroke='%23475569' stroke-linecap='round' stroke-linejoin='round' stroke-width='2' d='m6 8 4 4 4-4'/%3e%3c/svg%3e");
    background-position: right 16px center;
    background-repeat: no-repeat;
    background-size: 18px 18px;
    border: 2px solid #e2e8f0;
    border-radius: 12px;
    cursor: pointer;
    outline: none;
    transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
    appearance: none;
    -webkit-appearance: none;
    -moz-appearance: none;
    box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
    line-height: 1.5;
}



.form-input,
.form-textarea {
    width: 100%;
    padding: var(--spacing-3) var(--spacing-4);
    border: 1px solid var(--gray-300);
    border-radius: var(--border-radius);
    font-size: var(--font-size-sm);
    color: var(--gray-800);
    transition: var(--transition);
    background: white;
}

.form-select:focus,
.form-input:focus,
.form-textarea:focus {
    outline: none;
    border-color: var(--primary-color);
    box-shadow: 0 0 0 3px var(--primary-light);
}

.form-textarea {
    resize: vertical;
    min-height: 80px;
}

.search-box {
    position: relative;
    display: flex;
    align-items: center;
    background: linear-gradient(145deg, #ffffff, #f8fafc);
    border: 2px solid #e2e8f0;
    border-radius: 12px;
    transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
    box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
}

.search-box:hover {
    border-color: #cbd5e1;
    box-shadow: 0 4px 6px rgba(0, 0, 0, 0.05);
}

.search-box:focus-within {
    border-color: #3b82f6;
    box-shadow: 
        0 0 0 3px rgba(59, 130, 246, 0.1),
        0 4px 12px rgba(59, 130, 246, 0.15);
    transform: translateY(-1px);
}

.search-box i {
    position: absolute;
    left: 14px;
    color: #64748b;
    font-size: 18px;
    transition: color 0.3s ease;
}

.search-box:focus-within i {
    color: #3b82f6;
}

.search-box input {
    width: 100%;
    padding: 14px 18px 14px 46px;
    border: none;
    outline: none;
    font-size: 15px;
    color: #1e293b;
    background: transparent;
    font-family: inherit;
    line-height: 1.5;
}

.search-box input::placeholder {
    color: #94a3b8;
    transition: color 0.3s ease;
}

.search-box:focus-within input::placeholder {
    color: #cbd5e1;
}

/* Tablet */
@media screen and (max-width: 768px) {
    .filter-group {
        margin-bottom: 20px;
    }
    
    .filter-label {
        font-size: 14px;
        margin-bottom: 8px;
    }
    
    .search-box {
        border-radius: 10px;
    }
    
    .search-box input {
        padding: 12px 16px 12px 42px;
        font-size: 14px;
    }
    
    .search-box i {
        left: 12px;
        font-size: 16px;
    }
}

/* Hiệu ứng khi đang tìm kiếm */
.search-box.searching {
    border-color: #f59e0b;
}

.search-box.searching i {
    animation: searchPulse 1.5s ease-in-out infinite;
}

@keyframes searchPulse {
    0%, 100% { 
        opacity: 1; 
        transform: scale(1);
    }
    50% { 
        opacity: 0.6;
        transform: scale(1.1);
    }
}

/* Hiệu ứng khi có kết quả */
.search-box.has-results {
    border-color: #10b981;
}

.search-box.has-results i {
    color: #10b981;
}

.search-box {
    position: relative;
}

.search-clear {
    position: absolute;
    right: 12px;
    background: none;
    border: none;
    color: #9ca3af;
    cursor: pointer;
    padding: 4px;
    border-radius: 50%;
    opacity: 0;
    transition: all 0.2s ease;
    font-size: 16px;
}

.search-box input:not(:placeholder-shown) ~ .search-clear {
    opacity: 1;
}

.search-clear:hover {
    color: #6b7280;
    background-color: #f3f4f6;
}


/* Mobile */
@media screen and (max-width: 480px) {
    .filter-group {
        margin-bottom: 16px;
    }
    
    .filter-label {
        font-size: 13px;
        margin-bottom: 6px;
    }
    
    .search-box {
        border-radius: 8px;
        box-shadow: 0 1px 2px rgba(0, 0, 0, 0.05);
    }
    
    .search-box input {
        padding: 10px 14px 10px 38px;
        font-size: 16px; /* Tránh zoom trên iOS */
    }
    
    .search-box i {
        left: 10px;
        font-size: 15px;
    }
}


.filter-actions {
    display: flex;
    gap: var(--spacing-2);
    margin-top: var(--spacing-4);
}

/* Buttons */
.btn {
    display: inline-flex;
    align-items: center;
    gap: var(--spacing-2);
    padding: var(--spacing-3) var(--spacing-4);
    border: 1px solid transparent;
    border-radius: var(--border-radius);
    font-size: var(--font-size-sm);
    font-weight: 500;
    text-decoration: none;
    cursor: pointer;
    transition: var(--transition);
    justify-content: center;
    white-space: nowrap;
}

.btn:disabled {
    opacity: 0.5;
    cursor: not-allowed;
}

.btn-primary {
    background: var(--primary-color);
    color: white;
}

.btn-primary:hover:not(:disabled) {
    background: var(--primary-dark);
}

.btn-success {
    background: var(--success-color);
    color: white;
}

.btn-success:hover:not(:disabled) {
    background: #059669;
}

.btn-warning {
    background: var(--warning-color);
    color: white;
}

.btn-warning:hover:not(:disabled) {
    background: #d97706;
}

.btn-danger {
    background: var(--danger-color);
    color: white;
}

.btn-danger:hover:not(:disabled) {
    background: #dc2626;
}

.btn-outline {
    background: white;
    border-color: var(--gray-300);
    color: var(--gray-700);
}

.btn-outline:hover:not(:disabled) {
    background: var(--gray-50);
    border-color: var(--gray-400);
}

.btn-small {
    padding: var(--spacing-2) var(--spacing-3);
    font-size: var(--font-size-xs);
}

/* Content Area */
.content-area {
    background: white;
    border-radius: var(--border-radius-lg);
    box-shadow: var(--shadow);
    border: 1px solid var(--gray-200);
    overflow: hidden;
}

/* Toolbar */
.toolbar {
    display: flex;
    align-items: center;
    justify-content: space-between;
    padding: var(--spacing-4) var(--spacing-5);
    border-bottom: 1px solid var(--gray-200);
    background: var(--gray-50);
}

.view-tabs {
    display: flex;
    gap: var(--spacing-1);
}

.tab-btn {
    display: flex;
    align-items: center;
    gap: var(--spacing-2);
    padding: var(--spacing-2) var(--spacing-4);
    border: none;
    border-radius: var(--border-radius);
    font-size: var(--font-size-sm);
    font-weight: 500;
    color: var(--gray-600);
    background: transparent;
    cursor: pointer;
    transition: var(--transition);
}

.tab-btn:hover {
    background: var(--gray-200);
    color: var(--gray-800);
}

.tab-btn.active {
    background: var(--primary-color);
    color: white;
}

.toolbar-right {
    display: flex;
    align-items: center;
    gap: var(--spacing-4);
}

.bulk-actions {
    display: flex;
    align-items: center;
    gap: var(--spacing-3);
}

.selected-count {
    font-size: var(--font-size-sm);
    font-weight: 500;
    color: var(--gray-600);
}

.pagination-info .form-select {
    width: auto;
    min-width: 120px;
}

/* Messages Container */
.messages-container {
    min-height: 400px;
}

/* Loading State */
.loading-state {
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;
    padding: var(--spacing-12);
    gap: var(--spacing-4);
}

.spinner {
    width: 40px;
    height: 40px;
    border: 3px solid var(--gray-200);
    border-top: 3px solid var(--primary-color);
    border-radius: 50%;
    animation: spin 1s linear infinite;
}

@keyframes spin {
    0% { transform: rotate(0deg); }
    100% { transform: rotate(360deg); }
}

.loading-state span {
    color: var(--gray-500);
    font-weight: 500;
}

/* Empty State */
.empty-state {
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;
    padding: var(--spacing-12);
    text-align: center;
    gap: var(--spacing-4);
}

.empty-icon {
    width: 80px;
    height: 80px;
    border-radius: var(--border-radius-full);
    background: var(--gray-100);
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 2.5rem;
    color: var(--gray-400);
    margin-bottom: var(--spacing-2);
}

.empty-state h3 {
    font-size: var(--font-size-xl);
    color: var(--gray-800);
    font-weight: 600;
}

.empty-state p {
    color: var(--gray-500);
    max-width: 400px;
}

/* Messages List */
.messages-list {
    padding: var(--spacing-4);
}

.message-item {
    display: flex;
    align-items: flex-start;
    gap: var(--spacing-4);
    padding: var(--spacing-4);
    border-radius: var(--border-radius);
    border: 1px solid var(--gray-200);
    margin-bottom: var(--spacing-3);
    transition: var(--transition);
    cursor: pointer;
    background: white;
}

.message-item:hover {
    box-shadow: var(--shadow-md);
    border-color: var(--primary-color);
}

.message-item.unread {
    border-left: 4px solid var(--primary-color);
    background: var(--primary-light);
}

.message-item.selected {
    background: var(--primary-light);
    border-color: var(--primary-color);
}

.message-checkbox {
    margin-top: var(--spacing-1);
}

.message-checkbox input[type="checkbox"] {
    width: 18px;
    height: 18px;
    cursor: pointer;
}

.message-avatar {
    width: 40px;
    height: 40px;
    border-radius: var(--border-radius-full);
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: var(--font-size-lg);
    font-weight: 600;
    flex-shrink: 0;
}

.message-avatar.received {
    background: var(--success-light);
    color: var(--success-color);
}

.message-avatar.sent {
    background: var(--info-light);
    color: var(--info-color);
}

.message-content {
    flex: 1;
    min-width: 0;
}

.message-header {
    display: flex;
    align-items: center;
    justify-content: space-between;
    margin-bottom: var(--spacing-2);
}

.message-phone {
    font-weight: 600;
    color: var(--gray-800);
    font-size: var(--font-size-base);
}

.message-meta {
    display: flex;
    align-items: center;
    gap: var(--spacing-3);
    font-size: var(--font-size-xs);
    color: var(--gray-500);
}

.message-type {
    display: inline-flex;
    align-items: center;
    gap: var(--spacing-1);
    padding: 2px var(--spacing-2);
    border-radius: var(--border-radius);
    font-size: var(--font-size-xs);
    font-weight: 500;
}

.message-type.received {
    background: var(--success-light);
    color: var(--success-color);
}

.message-type.sent {
    background: var(--info-light);
    color: var(--info-color);
}

.message-text {
    color: var(--gray-700);
    line-height: 1.5;
    overflow: hidden;
    display: -webkit-box;
    -webkit-line-clamp: 2;
    -webkit-box-orient: vertical;
    margin-bottom: var(--spacing-2);
}

.message-footer {
    display: flex;
    align-items: center;
    justify-content: space-between;
}

.message-time {
    font-size: var(--font-size-xs);
    color: var(--gray-500);
}

.message-actions {
    display: flex;
    gap: var(--spacing-2);
    opacity: 0;
    transition: var(--transition);
}

.message-item:hover .message-actions {
    opacity: 1;
}

.message-action-btn {
    padding: var(--spacing-1);
    border: none;
    background: transparent;
    color: var(--gray-400);
    cursor: pointer;
    border-radius: var(--border-radius);
    transition: var(--transition);
    font-size: var(--font-size-sm);
}

.message-action-btn:hover {
    background: var(--gray-100);
    color: var(--gray-600);
}

.message-action-btn.delete:hover {
    background: var(--danger-light);
    color: var(--danger-color);
}

/* Pagination */
.pagination-container {
    padding: var(--spacing-4) var(--spacing-5);
    border-top: 1px solid var(--gray-200);
    background: var(--gray-50);
}

.pagination {
    display: flex;
    align-items: center;
    justify-content: center;
    gap: var(--spacing-2);
}

.pagination-btn {
    display: flex;
    align-items: center;
    justify-content: center;
    width: 40px;
    height: 40px;
    border: 1px solid var(--gray-300);
    background: white;
    color: var(--gray-700);
    cursor: pointer;
    border-radius: var(--border-radius);
    transition: var(--transition);
    font-size: var(--font-size-sm);
    font-weight: 500;
}

.pagination-btn:hover:not(:disabled) {
    background: var(--gray-50);
    border-color: var(--gray-400);
}

.pagination-btn:disabled {
    opacity: 0.5;
    cursor: not-allowed;
}

.pagination-btn.active {
    background: var(--primary-color);
    border-color: var(--primary-color);
    color: white;
}

.pagination-info {
    font-size: var(--font-size-sm);
    color: var(--gray-600);
    padding: 0 var(--spacing-4);
}

/* Modals */
.modal {
    position: fixed;
    top: 0;
    left: 0;
    width: 100%;
    height: 100%;
    z-index: 1000;
    display: none;
}

.modal.active {
    display: flex;
    align-items: center;
    justify-content: center;
}

.modal-overlay {
    position: absolute;
    top: 0;
    left: 0;
    width: 100%;
    height: 100%;
    background: rgba(0, 0, 0, 0.5);
    backdrop-filter: blur(4px);
}

.modal-container {
    position: relative;
    background: white;
    border-radius: var(--border-radius-lg);
    box-shadow: var(--shadow-xl);
    max-width: 500px;
    width: 90%;
    max-height: 90vh;
    overflow: hidden;
    display: flex;
    flex-direction: column;
}

.modal-container.modal-lg {
    max-width: 700px;
}

.modal-header {
    display: flex;
    align-items: center;
    justify-content: space-between;
    padding: var(--spacing-5);
    border-bottom: 1px solid var(--gray-200);
    background: var(--gray-50);
}

.modal-header h3 {
    display: flex;
    align-items: center;
    gap: var(--spacing-2);
    font-size: var(--font-size-xl);
    font-weight: 600;
    color: var(--gray-800);
}

.modal-header i {
    color: var(--primary-color);
}

.modal-close {
    width: 32px;
    height: 32px;
    border: none;
    background: transparent;
    color: var(--gray-400);
    cursor: pointer;
    border-radius: var(--border-radius);
    transition: var(--transition);
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: var(--font-size-lg);
}

.modal-close:hover {
    background: var(--gray-200);
    color: var(--gray-600);
}

.modal-body {
    padding: var(--spacing-5);
    flex: 1;
    overflow-y: auto;
}

/* Form Styles */
.message-form {
    display: flex;
    flex-direction: column;
    gap: var(--spacing-5);
}

.form-group {
    display: flex;
    flex-direction: column;
    gap: var(--spacing-2);
}

.form-label {
    display: flex;
    align-items: center;
    gap: var(--spacing-2);
    font-size: var(--font-size-sm);
    font-weight: 500;
    color: var(--gray-700);
}

.form-label i {
    color: var(--primary-color);
}

.form-hint {
    font-size: var(--font-size-xs);
    color: var(--gray-500);
}

.form-footer {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-top: var(--spacing-2);
}

.char-counter {
    font-size: var(--font-size-xs);
    color: var(--gray-500);
}

.form-actions {
    display: flex;
    gap: var(--spacing-3);
    justify-content: flex-end;
    margin-top: var(--spacing-4);
}

/* Message Detail Content */
.message-detail-grid {
    display: grid;
    gap: var(--spacing-4);
}

.detail-section {
    background: var(--gray-50);
    padding: var(--spacing-4);
    border-radius: var(--border-radius);
    border: 1px solid var(--gray-200);
}

.detail-section h4 {
    font-size: var(--font-size-lg);
    font-weight: 600;
    color: var(--gray-800);
    margin-bottom: var(--spacing-3);
    display: flex;
    align-items: center;
    gap: var(--spacing-2);
}

.detail-section h4 i {
    color: var(--primary-color);
}

.detail-row {
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding: var(--spacing-2) 0;
    border-bottom: 1px solid var(--gray-200);
}

.detail-row:last-child {
    border-bottom: none;
}

.detail-label {
    font-size: var(--font-size-sm);
    font-weight: 500;
    color: var(--gray-600);
}

.detail-value {
    font-size: var(--font-size-sm);
    color: var(--gray-800);
    text-align: right;
}

.message-content-full {
    background: white;
    padding: var(--spacing-4);
    border-radius: var(--border-radius);
    border: 1px solid var(--gray-200);
    line-height: 1.6;
    color: var(--gray-800);
    white-space: pre-wrap;
}

.detail-actions {
    display: flex;
    gap: var(--spacing-3);
    justify-content: flex-end;
    margin-top: var(--spacing-4);
    padding-top: var(--spacing-4);
    border-top: 1px solid var(--gray-200);
}

/* Toast Notifications */
.toast-container {
    position: fixed;
    top: var(--spacing-6);
    right: var(--spacing-6);
    z-index: 2000;
    display: flex;
    flex-direction: column;
    gap: var(--spacing-3);
    max-width: 400px;
    width: 100%;
}

.toast {
    display: flex;
    align-items: center;
    gap: var(--spacing-3);
    padding: var(--spacing-4);
    border-radius: var(--border-radius);
    box-shadow: var(--shadow-lg);
    border: 1px solid;
    animation: slideIn 0.3s ease-out;
    position: relative;
    overflow: hidden;
}

.toast::before {
    content: '';
    position: absolute;
    bottom: 0;
    left: 0;
    height: 3px;
    background: currentColor;
    animation: progress 4s linear forwards;
}

.toast.success {
    background: var(--success-light);
    border-color: var(--success-color);
    color: var(--success-color);
}

.toast.error {
    background: var(--danger-light);
    border-color: var(--danger-color);
    color: var(--danger-color);
}

.toast.warning {
    background: var(--warning-light);
    border-color: var(--warning-color);
    color: var(--warning-color);
}

.toast.info {
    background: var(--info-light);
    border-color: var(--info-color);
    color: var(--info-color);
}

.toast-icon {
    font-size: var(--font-size-lg);
    flex-shrink: 0;
}

.toast-content {
    flex: 1;
}

.toast-title {
    font-weight: 600;
    font-size: var(--font-size-sm);
    margin-bottom: var(--spacing-1);
}

.toast-message {
    font-size: var(--font-size-xs);
    opacity: 0.8;
}

.toast-close {
    background: transparent;
    border: none;
    color: currentColor;
    cursor: pointer;
    padding: var(--spacing-1);
    border-radius: var(--border-radius);
    transition: var(--transition);
    opacity: 0.7;
}

.toast-close:hover {
    opacity: 1;
    background: rgba(0, 0, 0, 0.1);
}

@keyframes slideIn {
    from {
        transform: translateX(100%);
        opacity: 0;
    }
    to {
        transform: translateX(0);
        opacity: 1;
    }
}

@keyframes progress {
    from {
        width: 100%;
    }
    to {
        width: 0%;
    }
}

/* Responsive Design */
@media (max-width: 1200px) {
    .content-grid {
        grid-template-columns: 280px 1fr;
    }
    
    .stats-grid {
        grid-template-columns: 1fr;
        gap: var(--spacing-2);
    }
    
    .stat-card {
        padding: var(--spacing-3);
    }
}

@media (max-width: 992px) {
    .content-grid {
        grid-template-columns: 1fr;
        gap: var(--spacing-4);
    }
    
    .sidebar {
        order: 2;
    }
    
    .content-area {
        order: 1;
    }
    
    .stats-grid {
        grid-template-columns: 1fr 1fr;
    }
    
    .toolbar {
        flex-direction: column;
        gap: var(--spacing-4);
        align-items: stretch;
    }
    
    .toolbar-right {
        justify-content: space-between;
    }
    
    .view-tabs {
        justify-content: center;
    }
}

@media (max-width: 768px) {
    .container {
        padding: 0 var(--spacing-3);
    }
    
    .main-content {
        padding: var(--spacing-4) 0;
    }
    
    .header-content {
        height: 60px;
    }
    
    .logo {
        font-size: var(--font-size-lg);
    }
    
    .logo i {
        font-size: var(--font-size-xl);
    }
    
    .stats-grid {
        grid-template-columns: 1fr;
    }
    
    .view-tabs {
        flex-direction: column;
        gap: var(--spacing-2);
    }
    
    .tab-btn {
        justify-content: center;
    }
    
    .message-item {
        flex-direction: column;
        gap: var(--spacing-3);
    }
    
    .message-header {
        flex-direction: column;
        align-items: flex-start;
        gap: var(--spacing-2);
    }
    
    .message-meta {
        flex-wrap: wrap;
    }
    
    .modal-container {
        margin: var(--spacing-4);
        width: calc(100% - 2rem);
    }
    
    .form-actions {
        flex-direction: column;
    }
    
    .btn {
        width: 100%;
        justify-content: center;
    }
    
    .toast-container {
        left: var(--spacing-4);
        right: var(--spacing-4);
        top: var(--spacing-4);
    }
    
    .bulk-actions {
        flex-direction: column;
        gap: var(--spacing-2);
        align-items: stretch;
    }
    
    .bulk-actions .btn {
        justify-content: center;
    }
}

@media (max-width: 480px) {
    .header-actions {
        gap: var(--spacing-2);
    }
    
    .user-menu span {
        display: none;
    }
    
    .quick-actions,
    .filter-panel {
        padding: var(--spacing-4);
    }
    
    .filter-actions {
        flex-direction: column;
    }
    
    .message-actions {
        opacity: 1;
        position: static;
        justify-content: flex-end;
        width: 100%;
        margin-top: var(--spacing-2);
    }
    
    .pagination {
        flex-wrap: wrap;
        gap: var(--spacing-1);
    }
    
    .pagination-btn {
        width: 36px;
        height: 36px;
        font-size: var(--font-size-xs);
    }
}

/* Dark mode support (optional) */
@media (prefers-color-scheme: dark) {
    :root {
        --gray-50: #1f2937;
        --gray-100: #374151;
        --gray-200: #4b5563;
        --gray-300: #6b7280;
        --gray-400: #9ca3af;
        --gray-500: #d1d5db;
        --gray-600: #e5e7eb;
        --gray-700: #f3f4f6;
        --gray-800: #f9fafb;
        --gray-900: #ffffff;
    }
}

/* Utility Classes */
.sr-only {
    position: absolute;
    width: 1px;
    height: 1px;
    padding: 0;
    margin: -1px;
    overflow: hidden;
    clip: rect(0, 0, 0, 0);
    white-space: nowrap;
    border: 0;
}

.text-center {
    text-align: center;
}

.text-right {
    text-align: right;
}

.font-medium {
    font-weight: 500;
}

.font-semibold {
    font-weight: 600;
}

.font-bold {
    font-weight: 700;
}

.text-xs {
    font-size: var(--font-size-xs);
}

.text-sm {
    font-size: var(--font-size-sm);
}

.text-lg {
    font-size: var(--font-size-lg);
}

.text-xl {
    font-size: var(--font-size-xl);
}

.hidden {
    display: none !important;
}

.flex {
    display: flex;
}

.flex-1 {
    flex: 1;
}

.items-center {
    align-items: center;
}

.justify-center {
    justify-content: center;
}

.justify-between {
    justify-content: space-between;
}

.gap-2 {
    gap: var(--spacing-2);
}

.gap-3 {
    gap: var(--spacing-3);
}

.gap-4 {
    gap: var(--spacing-4);
}

.p-2 {
    padding: var(--spacing-2);
}

.p-3 {
    padding: var(--spacing-3);
}

.p-4 {
    padding: var(--spacing-4);
}

.px-3 {
    padding-left: var(--spacing-3);
    padding-right: var(--spacing-3);
}

.py-2 {
    padding-top: var(--spacing-2);
    padding-bottom: var(--spacing-2);
}

.mb-2 {
    margin-bottom: var(--spacing-2);
}

.mb-3 {
    margin-bottom: var(--spacing-3);
}

.mb-4 {
    margin-bottom: var(--spacing-4);
}

.mt-4 {
    margin-top: var(--spacing-4);
}

/* Form validation styles */
.form-error {
    color: var(--danger-color);
    font-size: var(--font-size-xs);
    margin-top: var(--spacing-1);
    display: flex;
    align-items: center;
    gap: var(--spacing-1);
}

.form-error::before {
    content: '⚠️';
}

.form-input.error,
.form-textarea.error {
    border-color: var(--danger-color);
    box-shadow: 0 0 0 3px var(--danger-light);
}

.form-input.success,
.form-textarea.success {
    border-color: var(--success-color);
    box-shadow: 0 0 0 3px var(--success-light);
}

/* Connection status */
.connection-status {
    padding: var(--spacing-3);
    border-radius: var(--border-radius);
    background: var(--gray-50);
    border: 1px solid var(--gray-200);
    margin-bottom: var(--spacing-4);
}

.status-indicator {
    display: flex;
    align-items: center;
    gap: var(--spacing-2);
    font-size: var(--font-size-sm);
    color: var(--gray-600);
}

.status-indicator.connected {
    color: var(--success-color);
}

.status-indicator.disconnected {
    color: var(--warning-color);
}

/* SMS count display */
.form-footer {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-top: var(--spacing-2);
    font-size: var(--font-size-xs);
    color: var(--gray-500);
}

.sms-count {
    background: var(--primary-light);
    color: var(--primary-color);
    padding: 2px var(--spacing-2);
    border-radius: var(--border-radius);
}

/* Loading button animation */
.bx-spin {
    animation: spin 1s linear infinite;
}

@keyframes spin {
    from { transform: rotate(0deg); }
    to { transform: rotate(360deg); }
}

/* Button loading state */
.btn:disabled {
    opacity: 0.7;
    cursor: not-allowed;
    pointer-events: none;
}

.message-storage {
    background: var(--gray-200);
    color: var(--gray-600);
    padding: 2px 6px;
    border-radius: 4px;
    font-size: 10px;
    font-weight: 500;
    text-transform: uppercase;
}

.message-meta {
    display: flex;
    align-items: center;
    gap: var(--spacing-2);
    font-size: var(--font-size-xs);
    color: var(--gray-500);
    flex-wrap: wrap;
}

/* Debug panel (có thể ẩn trong production) */
.debug-info {
    background: var(--gray-50);
    border: 1px solid var(--gray-200);
    border-radius: var(--border-radius);
    padding: var(--spacing-3);
    margin-top: var(--spacing-4);
    font-size: var(--font-size-xs);
    font-family: monospace;
}

.debug-toggle {
    color: var(--gray-400);
    cursor: pointer;
    user-select: none;
}

/* Connection status styles */
.connection-status {
    padding: var(--spacing-3);
    border-radius: var(--border-radius);
    background: var(--gray-50);
    border: 1px solid var(--gray-200);
    margin-bottom: var(--spacing-4);
    transition: all 0.3s ease;
}

.status-indicator {
    display: flex;
    align-items: center;
    gap: var(--spacing-2);
    font-size: var(--font-size-sm);
    color: var(--gray-600);
    transition: all 0.3s ease;
}

.status-indicator.checking {
    color: var(--info-color);
}

.status-indicator.checking .connection-status {
    background: var(--info-light);
    border-color: var(--info-color);
}

.status-indicator.connected {
    color: var(--success-color);
}

.status-indicator.connected ~ .connection-status,
.status-indicator.connected {
    background: var(--success-light);
    border-color: var(--success-color);
}

.status-indicator.disconnected {
    color: var(--warning-color);
}

.status-indicator.disconnected ~ .connection-status,
.status-indicator.disconnected {
    background: var(--warning-light);
    border-color: var(--warning-color);
}

/* Spin animation cho checking icon */
.bx-spin {
    animation: spin 1s linear infinite;
}

@keyframes spin {
    from { transform: rotate(0deg); }
    to { transform: rotate(360deg); }
}

/* Send button disabled state */
.btn:disabled {
    opacity: 0.5;
    cursor: not-allowed;
    pointer-events: none;
}

.btn:disabled:hover {
    transform: none;
    box-shadow: none;
}

/* Bulk Confirmation Modal */
.bulk-confirm-modal {
    position: fixed;
    top: 0;
    left: 0;
    width: 100%;
    height: 100%;
    z-index: 2000;
    display: flex;
    align-items: center;
    justify-content: center;
    opacity: 0;
    visibility: hidden;
    transition: all 0.3s ease;
}

.bulk-confirm-modal.active {
    opacity: 1;
    visibility: visible;
}

.bulk-confirm-modal .modal-overlay {
    position: absolute;
    top: 0;
    left: 0;
    width: 100%;
    height: 100%;
    background: rgba(0, 0, 0, 0.6);
    backdrop-filter: blur(4px);
}

.bulk-confirm-modal .modal-content {
    position: relative;
    background: white;
    border-radius: var(--border-radius-lg);
    box-shadow: var(--shadow-xl);
    max-width: 480px;
    width: 90%;
    max-height: 90vh;
    overflow: hidden;
    transform: scale(0.95);
    transition: transform 0.3s ease;
}

.bulk-confirm-modal.active .modal-content {
    transform: scale(1);
}

.bulk-confirm-modal .modal-header {
    padding: var(--spacing-5);
    border-bottom: 1px solid var(--gray-200);
    background: var(--danger-light);
}

.bulk-confirm-modal .modal-header h3 {
    display: flex;
    align-items: center;
    gap: var(--spacing-2);
    font-size: var(--font-size-xl);
    font-weight: 600;
    color: var(--danger-color);
    margin: 0;
}

.bulk-confirm-modal .modal-body {
    padding: var(--spacing-5);
}

.bulk-confirm-modal .modal-body p {
    font-size: var(--font-size-base);
    color: var(--gray-700);
    margin-bottom: var(--spacing-4);
    line-height: 1.6;
}

.warning-box {
    display: flex;
    align-items: center;
    gap: var(--spacing-2);
    padding: var(--spacing-3);
    background: var(--warning-light);
    border: 1px solid var(--warning-color);
    border-radius: var(--border-radius);
    font-size: var(--font-size-sm);
    color: var(--warning-color);
}

.warning-box i {
    font-size: var(--font-size-lg);
}

.bulk-confirm-modal .modal-actions {
    display: flex;
    gap: var(--spacing-3);
    justify-content: flex-end;
    padding: var(--spacing-5);
    border-top: 1px solid var(--gray-200);
    background: var(--gray-50);
}

.bulk-confirm-modal .btn {
    min-width: 120px;
    justify-content: center;
}

/* Responsive */
@media (max-width: 480px) {
    .bulk-confirm-modal .modal-actions {
        flex-direction: column;
    }
    
    .bulk-confirm-modal .btn {
        width: 100%;
    }
}

/* Status Badges */
.status-badge {
    display: inline-flex;
    align-items: center;
    gap: 4px;
    padding: 4px 8px;
    border-radius: 12px;
    font-size: 0.75rem;
    font-weight: 500;
    white-space: nowrap;
}

.status-badge i {
    font-size: 0.875rem;
}

.status-badge.unread {
    background: var(--danger-light);
    color: var(--danger-color);
    border: 1px solid var(--danger-color);
}

.status-badge.read {
    background: var(--success-light);
    color: var(--success-color);
    border: 1px solid var(--success-color);
}

.status-badge.sent {
    background: var(--info-light);
    color: var(--info-color);
    border: 1px solid var(--info-color);
}

.status-badge.delivered {
    background: var(--success-light);
    color: var(--success-color);
    border: 1px solid var(--success-color);
}

.status-badge.failed {
    background: var(--danger-light);
    color: var(--danger-color);
    border: 1px solid var(--danger-color);
}

.status-badge.pending {
    background: var(--warning-light);
    color: var(--warning-color);
    border: 1px solid var(--warning-color);
}

.status-badge.unknown {
    background: var(--gray-200);
    color: var(--gray-600);
    border: 1px solid var(--gray-400);
}

.storage-badge {
    display: inline-block;
    padding: 2px 6px;
    background: var(--gray-200);
    color: var(--gray-700);
    border-radius: 4px;
    font-size: 0.75rem;
    font-weight: 500;
    text-transform: uppercase;
}

/* Auto-refresh control container */
.auto-refresh-control {
    display: flex;
    align-items: center;
    gap: var(--spacing-2);
    background: rgba(255, 255, 255, 0.1);
    padding: var(--spacing-2) var(--spacing-3);
    border-radius: var(--border-radius);
    border: 1px solid rgba(255, 255, 255, 0.2);
    backdrop-filter: blur(10px);
}

.auto-refresh-control .auto-refresh-label {
    font-size: var(--font-size-sm);
    color: white;
    font-weight: 500;
    white-space: nowrap;
    margin: 0;
}

.auto-refresh-control:hover {
    background: rgba(255, 255, 255, 0.15);
    border-color: rgba(255, 255, 255, 0.3);
    transform: translateY(-1px);
}

.auto-refresh-control .filter-label {
    font-size: var(--font-size-xs);
    font-weight: 500;
    color: var(--gray-600);
    display: flex;
    align-items: center;
    gap: var(--spacing-1);
    margin-bottom: 0;
}

.auto-refresh-control .form-select {
    min-width: 80px;
    padding: 4px 8px;
    font-size: var(--font-size-xs);
    height: 32px;
    border: 1px solid rgba(255, 255, 255, 0.3);
    background: rgba(255, 255, 255, 0.9);
    border-radius: 4px;
    color: #374151;
}

/* Focus states tốt hơn */
.auto-refresh-control:focus-within {
    outline: 2px solid var(--primary-color);
    outline-offset: 2px;
}

/* Reduced motion support */
@media (prefers-reduced-motion: reduce) {
    .auto-refresh-indicator i,
    .spinner {
        animation: none;
    }
}


/* Thêm will-change cho performance */
.auto-refresh-indicator.active i {
    will-change: transform;
    animation: countdown-spin 2s linear infinite;
}

.auto-refresh-indicator span {
    will-change: color, text-shadow;
}


/* Auto Refresh Indicator */
.auto-refresh-indicator {
    display: flex;
    align-items: center;
    gap: var(--spacing-2);
    padding: var(--spacing-2) var(--spacing-3);
    background: var(--countdown-bg);
    border: 1px solid var(--countdown-border);
    border-radius: var(--border-radius);
    font-size: var(--font-size-sm);
    color: var(--countdown-text);
    min-width: 100px;
    justify-content: center;
    transition: all 0.3s ease;
    backdrop-filter: blur(10px);
}

/* Trạng thái hoạt động */
.auto-refresh-indicator.active {
    background: linear-gradient(135deg, var(--countdown-active), #059669);
    border-color: var(--countdown-active);
    color: white;
    box-shadow: 0 0 20px rgba(16, 185, 129, 0.3);
}

/* Trạng thái tạm dừng */
.auto-refresh-indicator.paused {
    background: linear-gradient(135deg, var(--countdown-paused), #7c3aed);
    border-color: var(--countdown-paused);
    color: white;
    box-shadow: 0 0 20px rgba(139, 92, 246, 0.3);
}

/* Trạng thái tắt */
.auto-refresh-indicator {
    background: linear-gradient(135deg, #6b7280, #4b5563);
    border-color: #6b7280;
    color: #d1d5db;
}

.auto-refresh-indicator i {
    font-size: var(--font-size-sm);
}

/* Responsive cho auto refresh */
@media (max-width: 768px) {
    .auto-refresh-control {
        min-width: 100px;
    }
    
    .auto-refresh-indicator {
        font-size: 10px;
        padding: var(--spacing-1) var(--spacing-2);
    }
    
    .auto-refresh-indicator span {
        font-weight: 600;
        font-family: 'Courier New', monospace;
        letter-spacing: 0.5px;
        text-shadow: 0 1px 2px rgba(0, 0, 0, 0.5);
    }
    
    .auto-refresh-indicator.active span {
    color: white;
    }
    
    /* Cảnh báo khi còn ít thời gian */
    .auto-refresh-indicator.active[data-remaining="5"] span,
    .auto-refresh-indicator.active[data-remaining="4"] span,
    .auto-refresh-indicator.active[data-remaining="3"] span,
    .auto-refresh-indicator.active[data-remaining="2"] span,
    .auto-refresh-indicator.active[data-remaining="1"] span {
        color: var(--countdown-danger);
        animation: countdown-glow 1s ease-in-out infinite;
    }
}

@media (max-width: 480px) {
    .toolbar-right {
        flex-wrap: wrap;
        gap: var(--spacing-2);
    }
    
    .auto-refresh-control,
    .auto-refresh-indicator {
        width: 100%;
    }
}

/* Trạng thái paused */
.auto-refresh-indicator.paused {
    background: rgba(var(--warning-rgb), 0.2);
    border-color: var(--warning-color);
    color: var(--warning-color);
}

.auto-refresh-indicator.paused i {
    animation: countdown-pulse 2s ease-in-out infinite;
}

@keyframes pulse {
    0%, 100% { opacity: 1; }
    50% { opacity: 0.5; }
}

/* Auto Refresh Settings Container */
.auto-refresh-settings {
    background: var(--white);
    border: 1px solid var(--gray-200);
    border-radius: var(--border-radius);
    padding: var(--spacing-4);
    margin: var(--spacing-3) 0;
    box-shadow: 0 2px 8px rgba(0, 0, 0, 0.08);
}

/* Settings Title (nếu cần) */
.auto-refresh-settings::before {
    content: "⚙️ Cài đặt tự động làm mới";
    display: block;
    font-weight: 600;
    color: #374151;
    margin-bottom: 12px;
    padding-bottom: 8px;
    border-bottom: 1px solid #f3f4f6;
    font-size: 14px;
}

/* Label với Checkbox */
.auto-refresh-settings label {
    display: flex;
    align-items: center;
    gap: 8px;
    margin-bottom: 12px;
    font-size: 14px;
    color: #374151;
    cursor: pointer;
}

.auto-refresh-settings label:hover {
    color: var(--primary-color);
}

/* Custom Checkbox */
.auto-refresh-settings input[type="checkbox"] {
    width: 18px;
    height: 18px;
    border: 2px solid #d1d5db;
    border-radius: 4px;
    background: white;
    cursor: pointer;
    position: relative;
    appearance: none;
}

.auto-refresh-settings input[type="checkbox"]:checked {
    background: var(--primary-color);
    border-color: var(--primary-color);
}

.auto-refresh-settings input[type="checkbox"]:checked::after {
    content: "✓";
    position: absolute;
    top: 50%;
    left: 50%;
    transform: translate(-50%, -50%);
    color: var(--white);
    font-size: 12px;
    font-weight: bold;
}

.auto-refresh-settings input[type="checkbox"]:hover {
    border-color: var(--primary-color);
    box-shadow: 0 0 0 2px rgba(var(--primary-rgb), 0.1);
}

.auto-refresh-settings input[type="checkbox"]:focus {
    outline: none;
    border-color: var(--primary-color);
    box-shadow: 0 0 0 3px rgba(var(--primary-rgb), 0.2);
}

/* Select Dropdown */
.auto-refresh-settings select {
    width: 100%;
    padding: var(--spacing-2) var(--spacing-3);
    border: 1px solid var(--gray-300);
    border-radius: var(--border-radius);
    background: var(--white);
    color: var(--gray-700);
    font-size: var(--font-size-sm);
    cursor: pointer;
    transition: var(--transition);
}

.auto-refresh-settings select:hover {
    border-color: var(--primary-color);
}

.auto-refresh-settings select:focus {
    outline: none;
    border-color: var(--primary-color);
    box-shadow: 0 0 0 2px rgba(var(--primary-rgb), 0.1);
}

/* Select với icon */
.auto-refresh-settings select {
    background-image: url("data:image/svg+xml,%3csvg xmlns='http://www.w3.org/2000/svg' fill='none' viewBox='0 0 20 20'%3e%3cpath stroke='%236b7280' stroke-linecap='round' stroke-linejoin='round' stroke-width='1.5' d='m6 8 4 4 4-4'/%3e%3c/svg%3e");
    background-position: right 8px center;
    background-repeat: no-repeat;
    background-size: 16px;
    padding-right: 32px;
    appearance: none;
    -webkit-appearance: none;
    -moz-appearance: none;
}

/* Layout Inline */
.auto-refresh-settings.inline {
    display: flex;
    align-items: center;
    gap: var(--spacing-4);
    padding: var(--spacing-3);
}

.auto-refresh-settings.inline label {
    margin-bottom: 0;
    white-space: nowrap;
}

.auto-refresh-settings.inline select {
    width: auto;
    min-width: 100px;
}

.auto-refresh-settings.inline::before {
    display: none; /* Ẩn title trong mode inline */
}

/* Trong Modal */
.modal .auto-refresh-settings {
    margin: 0;
    border: none;
    box-shadow: none;
    background: var(--gray-50);
}

/* Trong Dropdown */
.dropdown-menu .auto-refresh-settings {
    margin: 0;
    padding: var(--spacing-3);
    border: none;
    border-radius: 0;
    box-shadow: none;
    background: transparent;
}

.dropdown-menu .auto-refresh-settings::before {
    border-bottom-color: var(--gray-200);
}

/* Mobile Responsive */
@media (max-width: 768px) {
    .auto-refresh-settings {
        padding: var(--spacing-3);
    }
    
    .auto-refresh-settings label {
        font-size: var(--font-size-xs);
        gap: var(--spacing-1);
    }
    
    .auto-refresh-settings select {
        padding: var(--spacing-1) var(--spacing-2);
        font-size: var(--font-size-xs);
    }
    
    /* Force inline trên mobile */
    /* Auto-refresh settings */
    .auto-refresh-settings {
        background: white;
        border: 1px solid #e5e7eb;
        border-radius: 8px;
        padding: 16px;
        margin: 12px 0;
        box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
    }
}

@media (max-width: 480px) {
    .auto-refresh-settings.inline {
        flex-direction: column;
        align-items: stretch;
    }
    
    .auto-refresh-settings.inline label {
        justify-content: center;
    }
}

.auto-refresh-settings.success {
    border-color: var(--success-color);
    background: var(--success-light);
}

.auto-refresh-settings.success input[type="checkbox"]:checked {
    background: var(--success-color);
    border-color: var(--success-color);
}

/* Spin animation cho icon refresh */
.auto-refresh-indicator.active i.bx-spin {
    animation: countdown-spin 2s linear infinite;
}

/* Pulse animation cho trạng thái pause */
.auto-refresh-indicator.paused i {
    animation: countdown-pulse 2s ease-in-out infinite;
}

/* Keyframes */
@keyframes countdown-spin {
    from { transform: rotate(0deg); }
    to { transform: rotate(360deg); }
}

@keyframes countdown-pulse {
    0%, 100% { 
        opacity: 1; 
        transform: scale(1);
    }
    50% { 
        opacity: 0.7; 
        transform: scale(1.1);
    }
}

/* Glow effect cho số đếm ngược */
@keyframes countdown-glow {
    0%, 100% { text-shadow: 0 0 5px currentColor; }
    50% { text-shadow: 0 0 20px currentColor, 0 0 30px currentColor; }
}
EOF

cat > "$WEB_DIR/script.js" << 'EOF'
// SMS Manager Pro - Modern JavaScript Implementation
class SMSManager {
    constructor() {
        this.messages = [];
        this.filteredMessages = [];
        this.currentPage = 1;
        this.itemsPerPage = 20;
        this.refreshing = false;
        this.exporting = false;
        this.selectedMessages = new Set();
        this.autoRefreshInterval = 0; // 0 = tắt tự động làm mới
        this.autoRefreshTimer = null;
        this.isAutoRefreshEnabled = false;
        this.userActivityTimer = null;
        this.userActivityEnabled = true; // Có thể tắt/bật tính năng này
        this.userActivityDelay = 30000; // 30 giây
        this.countdownTimer   = null;   // interval 1 s
        this.remainingSeconds = 0;      // giây còn lại
        this.countdownPaused  = false;  // true khi stopAutoRefresh / paused
        this.wasAutoRefreshActive = false; // Lưu trạng thái trước khi pause
        this.filters = {
            type: '',
            status: '',
            time: '',
            search: ''
        };
        this.currentView = 'all';
        this.isLoading = false;
        this.bulkOperations = {
            deleting: false,
            markingRead: false,
            exporting: false
            };
                    
        // Message templates
        this.templates = {
            greeting: "Xin chào! Cảm ơn bạn đã quan tâm đến dịch vụ của chúng tôi.",
            promotion: "🎉 Khuyến mãi đặc biệt! Giảm giá 50% cho tất cả sản phẩm. Mã: SALE50",
            reminder: "Nhắc nhở: Hóa đơn của bạn sẽ đến hạn thanh toán vào ngày mai. Vui lòng thanh toán đúng hạn.",
            confirmation: "Xác nhận đơn hàng #12345 đã được tiếp nhận. Chúng tôi sẽ liên hệ với bạn trong 24h."
        };

        this.init();
    }

    async init() {
        this.bindEvents();
        this.setupModals();
        this.setupAutoRefresh();
        this.pauseAutoRefreshOnUserActivity();
        
        const isConnected = await this.checkServerConnection();
        await this.loadMessages();
        this.updateStats();
        this.renderMessages();
        this.restoreAutoRefreshSettings(); // ← Thêm dòng này
        
        if (isConnected) {
            this.showWelcomeToast();
        }
    }


    
    // Bắt đầu tự động làm mới
    startAutoRefresh() {
        if (this.autoRefreshInterval <= 0) return;
        
        this.stopAutoRefresh();
        
        this.autoRefreshTimer = setInterval(async () => {
            if (!this.refreshing) {
                console.log(`Tự động làm mới sau ${this.autoRefreshInterval}s`);
                await this.loadMessages();
                this.updateStats();
                this.renderMessages();
                this.showToast('info', 'Đã làm mới', 'Dữ liệu được cập nhật tự động');
                
                // Reset countdown sau khi refresh
                this.remainingSeconds = this.autoRefreshInterval;
            }
        }, this.autoRefreshInterval * 1000);
        
        this.isAutoRefreshEnabled = true;
        this.countdownPaused = false;
        this.startCountdown(); // ← Thêm này
    }

    
    // Dừng tự động làm mới
    stopAutoRefresh() {
        if (this.autoRefreshTimer) {
            clearInterval(this.autoRefreshTimer);
            this.autoRefreshTimer = null;
        }
        this.isAutoRefreshEnabled = false;
        this.stopCountdown(); // ← Thêm này
        this.updateCountdownUI(); // ← Thay đổi từ updateAutoRefreshUI()
    }

    
    // Thiết lập khoảng thời gian tự động làm mới
    setAutoRefreshInterval(seconds) {
        this.autoRefreshInterval = seconds;
        
        if (seconds > 0) {
            this.startAutoRefresh();
            localStorage.setItem('autoRefreshInterval', seconds.toString());
        } else {
            this.stopAutoRefresh();
            localStorage.removeItem('autoRefreshInterval');
        }
    }
    
    // Cập nhật giao diện hiển thị trạng thái
    updateAutoRefreshUI() {
        const select = document.getElementById('autoRefreshSelect');
        const indicator = document.getElementById('autoRefreshIndicator');
        
        if (select) {
            select.value = this.autoRefreshInterval.toString();
        }
        
        if (indicator) {
            if (this.isAutoRefreshEnabled) {
                indicator.innerHTML = `<i class='bx bx-refresh bx-spin'></i> Tự động làm mới: ${this.autoRefreshInterval}s`;
                indicator.className = 'auto-refresh-indicator active';
            } else {
                indicator.innerHTML = `<i class='bx bx-refresh'></i> Tắt tự động làm mới`;
                indicator.className = 'auto-refresh-indicator';
            }
        }
    }
    
    // ---------------------------------------------------------------------
    // Thiết lập toàn bộ tính năng Auto-Refresh + User-Activity-Pause
    // GỌI MỘT LẦN trong init():  this.setupAutoRefresh();
    // ---------------------------------------------------------------------
    setupAutoRefresh() {
        /*----------------------------------------------------
         * 1. DOM Elements
         *---------------------------------------------------*/
        const refreshSelect      = document.getElementById('autoRefreshSelect');
        const activityCheckbox   = document.getElementById('userActivityPause');
        const delaySelect        = document.getElementById('activityDelay');
    
        /*----------------------------------------------------
         * 2. Khôi phục cấu hình đã lưu (nếu có)
         *---------------------------------------------------*/
        // – Chu kỳ auto-refresh
        const savedInterval = localStorage.getItem('autoRefreshInterval');
        if (savedInterval && refreshSelect) {
            refreshSelect.value = savedInterval;
            this.autoRefreshInterval = parseInt(savedInterval, 10);
            this.remainingSeconds = this.autoRefreshInterval; // ← Thêm này
        }
    
        // – Tạm dừng theo user-activity
        if (activityCheckbox) {
            const savedPause = localStorage.getItem('userActivityPause');
            activityCheckbox.checked = savedPause === null ? true : savedPause === 'true';
            this.userActivityEnabled = activityCheckbox.checked;
        }
    
        // – Thời gian trì hoãn khôi phục
        if (delaySelect) {
            const savedDelay = localStorage.getItem('userActivityDelay');
            if (savedDelay) {
                delaySelect.value = savedDelay;
                this.userActivityDelay = parseInt(savedDelay, 10) * 1000;
            }
        }
    
        /*----------------------------------------------------
         * 3. Bind sự kiện cho Auto-Refresh Select
         *---------------------------------------------------*/
        if (refreshSelect) {
            // Bảo đảm không gắn trùng listener
            refreshSelect.removeEventListener('change', this._onRefreshSelectChange);
            this._onRefreshSelectChange = (e) => {
                const seconds = parseInt(e.target.value, 10);
                this.setAutoRefreshInterval(seconds);
            };
            refreshSelect.addEventListener('change', this._onRefreshSelectChange);
        }
    
        /*----------------------------------------------------
         * 4. Bind sự kiện cho User-Activity Pause
         *---------------------------------------------------*/
        if (activityCheckbox) {
            activityCheckbox.removeEventListener('change', this._onActivityCheckboxChange);
            this._onActivityCheckboxChange = (e) => {
                const enabled = e.target.checked;
                this.toggleUserActivityPause(enabled);
                localStorage.setItem('userActivityPause', enabled);
            };
            activityCheckbox.addEventListener('change', this._onActivityCheckboxChange);
        }
    
        /*----------------------------------------------------
         * 5. Bind sự kiện cho Delay Select
         *---------------------------------------------------*/
        if (delaySelect) {
            delaySelect.removeEventListener('change', this._onDelaySelectChange);
            this._onDelaySelectChange = (e) => {
                const seconds = parseInt(e.target.value, 10);
                this.setUserActivityDelay(seconds);
                localStorage.setItem('userActivityDelay', seconds);
            };
            delaySelect.addEventListener('change', this._onDelaySelectChange);
        }
    
        /*----------------------------------------------------
         * 6. Khởi động các cơ chế
         *---------------------------------------------------*/
        // Auto-refresh ngay nếu giá trị > 0
        if (this.autoRefreshInterval > 0) {
            this.startAutoRefresh();
        }
    
        // Chỉ bind monitor user-activity một lần
        if (!this._userActivityBound) {
            this.pauseAutoRefreshOnUserActivity();
            this._userActivityBound = true;
        }
    
        // Cập nhật UI ban đầu với countdown
        this.updateCountdownUI(); // ← Thay đổi từ updateAutoRefreshUI()
        
        // Khởi động countdown nếu auto-refresh đang bật
        if (this.isAutoRefreshEnabled && this.autoRefreshInterval > 0) {
            this.startCountdown(); // ← Thêm này
        }
    }

    // Khôi phục cài đặt từ localStorage
    restoreAutoRefreshSettings() {
        const savedInterval = localStorage.getItem('autoRefreshInterval');
        if (savedInterval) {
            this.setAutoRefreshInterval(parseInt(savedInterval));
        }
    }
    
    // Test auto refresh functionality
    testAutoRefresh() {
        console.log('=== AUTO REFRESH STATUS ===');
        console.log('Current interval:', this.autoRefreshInterval);
        console.log('Timer active:', !!this.autoRefreshTimer);
        console.log('Is enabled:', this.isAutoRefreshEnabled);
        
        const select = document.getElementById('autoRefreshSelect');
        console.log('Select element found:', !!select);
        if (select) {
            console.log('Select value:', select.value);
        }
        
        const indicator = document.getElementById('autoRefreshIndicator');
        console.log('Indicator element found:', !!indicator);
    }

    // Tạm dừng auto refresh khi người dùng hoạt động
    pauseAutoRefreshOnUserActivity() {
        if (!this.userActivityEnabled) return;
        
        const resetUserActivity = () => {
            // Xóa timer cũ
            clearTimeout(this.userActivityTimer);
            
            // Tạm dừng auto refresh nếu đang chạy
            if (this.isAutoRefreshEnabled && !this.wasAutoRefreshActive) {
                console.log('🔄 Tạm dừng auto refresh do user activity');
                this.wasAutoRefreshActive = true;
                this.stopAutoRefresh();
                this.updateAutoRefreshUI('paused');
            }
            
            // Đặt timer để tiếp tục auto refresh
            this.userActivityTimer = setTimeout(() => {
                if (this.autoRefreshInterval > 0 && this.wasAutoRefreshActive) {
                    console.log('▶️ Tiếp tục auto refresh sau khi user không hoạt động');
                    this.wasAutoRefreshActive = false;
                    this.startAutoRefresh();
                }
            }, this.userActivityDelay);
        };
        
        // Lắng nghe các sự kiện người dùng
        const events = ['click', 'keypress', 'scroll', 'mousemove', 'touchstart', 'touchmove'];
        events.forEach(event => {
            document.addEventListener(event, resetUserActivity, { 
                passive: true,
                once: false
            });
        });
        
        console.log('👂 User activity monitoring enabled');
    }

    // Cập nhật giao diện hiển thị trạng thái
    updateAutoRefreshUI(status = null) {
        const select = document.getElementById('autoRefreshSelect');
        const indicator = document.getElementById('autoRefreshIndicator');
        
        if (select) {
            select.value = this.autoRefreshInterval.toString();
        }
        
        if (indicator) {
            if (status === 'paused') {
                // Trạng thái tạm dừng
                indicator.innerHTML = `<i class='bx bx-pause'></i><span>Tạm dừng</span>`;
                indicator.className = 'auto-refresh-indicator paused';
            } else if (this.isAutoRefreshEnabled) {
                // Đang hoạt động
                indicator.innerHTML = `<i class='bx bx-refresh bx-spin'></i><span>${this.autoRefreshInterval}s</span>`;
                indicator.className = 'auto-refresh-indicator active';
            } else {
                // Tắt
                indicator.innerHTML = `<i class='bx bx-refresh'></i><span>Tắt</span>`;
                indicator.className = 'auto-refresh-indicator';
            }
        }
    }

    // Bật/tắt user activity monitoring
    toggleUserActivityPause(enable) {
        this.userActivityEnabled = enable;
        
        if (!enable && this.userActivityTimer) {
            clearTimeout(this.userActivityTimer);
            this.userActivityTimer = null;
            
            // Khôi phục auto refresh nếu cần
            if (this.wasAutoRefreshActive && this.autoRefreshInterval > 0) {
                this.wasAutoRefreshActive = false;
                this.startAutoRefresh();
            }
        }
        
        console.log(`User activity pause: ${enable ? 'enabled' : 'disabled'}`);
    }
    
    /* Khởi động đếm ngược */
    startCountdown() {
        // Clear trước cho chắc
        this.stopCountdown();
    
        this.remainingSeconds = this.autoRefreshInterval;
        this.updateCountdownUI();
    
        this.countdownTimer = setInterval(() => {
            if (this.countdownPaused) return;      // đang pause (user activity)
            if (this.remainingSeconds > 0) {
                this.remainingSeconds--;
                this.updateCountdownUI();
            }
        }, 1000);
    }
    
    /* Dừng đếm ngược */
    stopCountdown() {
        if (this.countdownTimer) {
            clearInterval(this.countdownTimer);
            this.countdownTimer = null;
        }
    }
    
    /* Cập nhật hiển thị số giây */
    updateCountdownUI() {
        const indicator = document.getElementById('autoRefreshIndicator');
        if (!indicator) return;
    
        if (this.isAutoRefreshEnabled) {
            indicator.innerHTML =
                `<i class='bx bx-refresh bx-spin'></i><span>${this.remainingSeconds}s</span>`;
            indicator.className = 'auto-refresh-indicator active';
        } else if (this.countdownPaused) {
            indicator.innerHTML =
                `<i class='bx bx-pause'></i><span>Tạm dừng</span>`;
            indicator.className = 'auto-refresh-indicator paused';
        } else {
            indicator.innerHTML =
                `<i class='bx bx-refresh'></i><span>Tắt</span>`;
            indicator.className = 'auto-refresh-indicator';
        }
    }

    
    // Thay đổi thời gian delay
    setUserActivityDelay(seconds) {
        this.userActivityDelay = seconds * 1000;
        console.log(`User activity delay changed to: ${seconds}s`);
    }

    
    resetNewMessageForm() {
        try {
            console.log('Resetting form');
            const form = document.getElementById('newMessageForm');
            if (form) {
                form.reset();
            }
            
            // Reset character counter
            const charCount = document.getElementById('charCount');
            if (charCount) {
                charCount.textContent = '0';
            }
            
            console.log('Form reset completed');
        } catch (error) {
            console.error('Error in resetNewMessageForm:', error);
        }
    }
    
    async openNewMessageModal() {
        try {
            console.log('Opening new message modal - START');
            
            const modal = document.getElementById('newMessageModal');
            console.log('Modal element found:', !!modal);
            
            if (!modal) {
                console.error('Modal element not found');
                return;
            }
            
            modal.classList.add('active');
            document.body.style.overflow = 'hidden';
            console.log('Modal activated');
            
            // Reset form
            try {
                this.resetNewMessageForm();
                console.log('Form reset completed');
            } catch (error) {
                console.error('Error resetting form:', error);
            }
            
            // Focus input after modal display
            setTimeout(() => {
                try {
                    const phoneInput = document.getElementById('recipientPhone');
                    if (phoneInput) {
                        phoneInput.focus();
                        console.log('Input focused');
                    } else {
                        console.error('Phone input not found');
                    }
                } catch (error) {
                    console.error('Error focusing input:', error);
                }
            }, 100);
            
            // Check connection after modal is displayed
            setTimeout(async () => {
                try {
                    console.log('Starting connection check after modal display');
                    await this.checkConnectionStatus();
                } catch (error) {
                    console.error('Error in connection check:', error);
                }
            }, 300);
            
        } catch (error) {
            console.error('Error in openNewMessageModal:', error);
        }
    }


    
    async checkConnectionStatus() {
        try {
            console.log('checkConnectionStatus started');
            
            console.log('Calling updateConnectionStatus with checking');
            this.updateConnectionStatus('checking');
            
            const isConnected = await this.testConnection();
            console.log('Connection result:', isConnected);
            
            if (isConnected) {
                console.log('Calling updateConnectionStatus with connected');
                this.updateConnectionStatus('connected');
            } else {
                console.log('Calling updateConnectionStatus with disconnected');
                this.updateConnectionStatus('disconnected');
            }
        } catch (error) {
            console.error('Connection check failed:', error);
            try {
                this.updateConnectionStatus('disconnected');
            } catch (updateError) {
                console.error('Error updating status to disconnected:', updateError);
            }
        }
    }



    
    async testConnection() {
        try {
            const baseUrl = window.location.origin;
            
            // Test với timeout ngắn để tránh treo
            const controller = new AbortController();
            const timeoutId = setTimeout(() => controller.abort(), 5000); // 5 seconds
            
            const response = await fetch(`${baseUrl}/cgi-bin/sms-send`, {
                method: 'GET',
                headers: { 
                    'Accept': '*/*',
                    'Cache-Control': 'no-cache' 
                },
                signal: controller.signal
            });
            
            clearTimeout(timeoutId);
            
            // Kiểm tra response status
            return response.status < 500; // Accept 200, 400, 404 but not 500+
            
        } catch (error) {
            if (error.name === 'AbortError') {
                console.log('Connection test timeout');
            } else {
                console.log('Connection test failed:', error.message);
            }
            return false;
        }
    }

    // THÊM METHOD NÀY VÀO NGAY ĐÂY
    updateConnectionStatus(status) {
        console.log('updateConnectionStatus called with:', status);
        
        // Thử nhiều cách tìm element
        let statusElement = document.getElementById('connectionStatus');
        
        if (!statusElement) {
            statusElement = document.querySelector('.connection-status');
        }
        
        if (!statusElement) {
            statusElement = document.querySelector('#newMessageModal .connection-status');
        }
        
        console.log('statusElement found:', statusElement);
        
        if (!statusElement) {
            console.error('connectionStatus element not found anywhere');
            // Tạo element tạm thời để test
            const tempDiv = document.createElement('div');
            tempDiv.innerHTML = `
                <div style="padding: 10px; background: yellow; margin: 10px;">
                    Status: ${status}
                </div>
            `;
            document.body.appendChild(tempDiv);
            return;
        }
        
        // Tiếp tục với logic update bình thường...
        const textElement = statusElement.querySelector('span');
        if (textElement) {
            switch (status) {
                case 'checking':
                    textElement.textContent = 'Đang kiểm tra kết nối...';
                    textElement.style.color = 'blue';
                    break;
                case 'connected':
                    textElement.textContent = 'Kết nối server thành công';
                    textElement.style.color = 'green';
                    break;
                case 'disconnected':
                    textElement.textContent = 'Không thể kết nối server';
                    textElement.style.color = 'red';
                    break;
            }
            console.log('Status updated to:', textElement.textContent);
        }
    }


    
    // Test function - gọi trong console
    async testConnectionManual() {
        console.log('Manual test started');
        this.updateConnectionStatus('checking');
        
        setTimeout(() => {
            this.updateConnectionStatus('connected');
        }, 2000);
    }





    // Thêm method này để check server connection cho init
    async checkServerConnection() {
        const isConnected = await this.testConnection();
        
        if (!isConnected) {
            this.showToast('warning', 'Cảnh báo kết nối', 'Không thể kết nối đến server SMS. Sử dụng dữ liệu mẫu.');
        }
        
        return isConnected;
    }

    bindEvents() {
        // --- SAFE BINDING FOR MAIN BUTTONS ---
    
        // Export button
        const exportBtn = document.getElementById('exportBtn');
        if (exportBtn) {
            const newBtn = exportBtn.cloneNode(true);
            exportBtn.replaceWith(newBtn);
            newBtn.addEventListener('click', (e) => {
                e.preventDefault();
                e.stopPropagation();
                console.log('Export button clicked');
                this.exportMessages();
            });
        }
    
        // Refresh button
        const refreshBtn = document.getElementById('refreshBtn');
        if (refreshBtn) {
            const newBtn = refreshBtn.cloneNode(true);
            refreshBtn.replaceWith(newBtn);
            newBtn.addEventListener('click', (e) => {
                e.preventDefault();
                e.stopPropagation();
                this.refreshMessages();
            });
        }
    
        // New Message button
        const newMessageBtn = document.getElementById('newMessageBtn');
        if (newMessageBtn) {
            const newBtn = newMessageBtn.cloneNode(true);
            newMessageBtn.replaceWith(newBtn);
            newBtn.addEventListener('click', (e) => {
                e.preventDefault();
                e.stopPropagation();
                this.openNewMessageModal();
            });
        }
    
        // Bulk delete button
        const bulkDeleteBtn = document.getElementById('bulkDeleteBtn');
        if (bulkDeleteBtn) {
            const newBtn = bulkDeleteBtn.cloneNode(true);
            bulkDeleteBtn.replaceWith(newBtn);
            newBtn.addEventListener('click', (e) => {
                e.preventDefault();
                e.stopPropagation();
                this.bulkDeleteMessages();
            });
        }
    
        // --- OTHER EVENT BINDINGS ---
    
        // View tabs
        document.querySelectorAll('.tab-btn').forEach(btn => {
            btn.addEventListener('click', (e) => {
                this.switchView(e.target.dataset.view);
            });
        });
    
        // Filters
        document.getElementById('applyFilter')?.addEventListener('click', () => {
            this.applyFilters();
        });
    
        document.getElementById('clearFilter')?.addEventListener('click', () => {
            this.clearFilters();
        });
    
        // Search input
        const searchInput = document.getElementById('searchInput');
        let searchTimeout;
        if (searchInput) {
            searchInput.addEventListener('input', (e) => {
                clearTimeout(searchTimeout);
                searchTimeout = setTimeout(() => {
                    this.filters.search = e.target.value;
                    this.applyFilters();
                }, 500);
            });
        }
    
        // Bulk actions
        document.getElementById('selectAllBtn')?.addEventListener('click', () => {
            this.toggleSelectAll();
        });
    
        document.getElementById('markReadBtn')?.addEventListener('click', () => {
            this.markSelectedAsRead();
        });
    
        document.getElementById('deleteSelectedBtn')?.addEventListener('click', () => {
            this.deleteSelectedMessages();
        });
    
        // Pagination
        const itemsPerPage = document.getElementById('itemsPerPage');
        if (itemsPerPage) {
            itemsPerPage.addEventListener('change', (e) => {
                this.itemsPerPage = parseInt(e.target.value);
                this.currentPage = 1;
                this.renderMessages();
            });
        }
    
        // New message form
        const messageForm = document.getElementById('newMessageForm');
        if (messageForm) {
            messageForm.addEventListener('submit', (e) => {
                e.preventDefault();
                this.sendMessage();
            });
        }
    
        // Character counter
        const messageContent = document.getElementById('messageContent');
        if (messageContent) {
            messageContent.addEventListener('input', () => {
                this.updateCharCount();
            });
        }
    
        // Template selector
        const templateSelect = document.getElementById('messageTemplate');
        if (templateSelect) {
            templateSelect.addEventListener('change', (e) => {
                if (e.target.value) {
                    messageContent.value = this.templates[e.target.value];
                    this.updateCharCount();
                }
            });
        }
    
        // Modal close (click outside or close icon)
        document.querySelectorAll('.modal-close, .modal-overlay').forEach(el => {
            el.addEventListener('click', (e) => {
                if (e.target === el) {
                    this.closeModals();
                }
            });
        });
    
        // Keyboard shortcuts
        document.addEventListener('keydown', (e) => {
            if (e.key === 'Escape') {
                this.closeModals();
            }
            if (e.ctrlKey && e.key === 'n') {
                e.preventDefault();
                this.openNewMessageModal();
            }
            if (e.ctrlKey && e.key === 'r') {
                e.preventDefault();
                this.refreshMessages();
            }
        });
        
        // Đóng modal bằng nút X
        document.addEventListener('click', (e) => {
            if (e.target.classList.contains('modal-close') || 
                e.target.closest('.modal-close')) {
                
                const modal = e.target.closest('.modal');
                if (modal) {
                    const modalId = modal.getAttribute('id');
                    this.closeModal(modalId);
                }
            }
        });
        
        // Đóng modal bằng click overlay
        document.addEventListener('click', (e) => {
            if (e.target.classList.contains('modal-overlay')) {
                const modal = e.target.closest('.modal');
                if (modal) {
                    const modalId = modal.getAttribute('id');
                    this.closeModal(modalId);
                }
            }
        });
        
        // Đóng modal bằng phím ESC
        document.addEventListener('keydown', (e) => {
            if (e.key === 'Escape') {
                const activeModal = document.querySelector('.modal.active');
                if (activeModal) {
                    const modalId = activeModal.getAttribute('id');
                    this.closeModal(modalId);
                }
            }
        });
    }


    // Modal Management
    setupModals() {
        // Cancel buttons
        document.getElementById('cancelNewMessage').addEventListener('click', () => {
            this.closeNewMessageModal();
        });
    }

    openNewMessageModal() {
        console.log('=== OPENING MODAL START ===');
        
        try {
            const modal = document.getElementById('newMessageModal');
            console.log('Modal found:', !!modal);
            
            if (modal) {
                modal.classList.add('active');
                document.body.style.overflow = 'hidden';
                console.log('Modal should be visible now');
                
                // Simple connection check without complex timing
                setTimeout(() => {
                    console.log('Running connection check...');
                    this.simpleConnectionCheck();
                }, 500);
            }
        } catch (error) {
            console.error('Modal error:', error);
        }
        
        console.log('=== OPENING MODAL END ===');
    }
    
    // Method đóng modal
    closeModal(modalId) {
        try {
            const modal = document.getElementById(modalId);
            if (modal) {
                modal.classList.remove('active');
                document.body.style.overflow = '';
                
                // Reset form nếu là modal tạo tin nhắn
                if (modalId === 'newMessageModal') {
                    this.resetNewMessageForm();
                }
            }
        } catch (error) {
            console.error('Error closing modal:', error);
        }
    }
    
    // Method đóng modal cụ thể
    closeNewMessageModal() {
        this.closeModal('newMessageModal');
    }
    
    closeMessageDetailModal() {
        this.closeModal('messageDetailModal');
    }

    
    // Simplified connection check
    async simpleConnectionCheck() {
        console.log('Connection check started');
        
        const statusElement = document.getElementById('connectionStatus');
        if (!statusElement) return;
        
        const span = statusElement.querySelector('span');
        const icon = statusElement.querySelector('i');
        
        if (!span) return;
        
        // Set checking state
        span.textContent = 'Đang kiểm tra kết nối...';
        span.style.color = '#3b82f6'; // Blue color
        if (icon) icon.className = 'bx bx-loader-alt bx-spin';
        
        try {
            // Thử kết nối bình thường trước
            let isConnected = await this.testConnection();
            
            // Nếu thất bại, thử retry
            if (!isConnected) {
                console.log('Initial connection failed, starting retry...');
                isConnected = await this.retryConnection();
            }
            
            if (isConnected) {
                span.textContent = 'Kết nối server thành công';
                span.style.color = 'green';
                if (icon) icon.className = 'bx bx-check-circle';
                
                // Enable send button
                const sendBtn = document.getElementById('sendMessageBtn');
                if (sendBtn) {
                    sendBtn.disabled = false;
                    sendBtn.title = '';
                }
                
            } else {
                span.textContent = 'Không thể kết nối server (đã thử 3 lần)';
                span.style.color = 'red';
                if (icon) icon.className = 'bx bx-error-circle';
                
                // Disable send button  
                const sendBtn = document.getElementById('sendMessageBtn');
                if (sendBtn) {
                    sendBtn.disabled = true;
                    sendBtn.title = 'Server không khả dụng';
                }
                
                // Show toast notification
                if (this.showToast) {
                    this.showToast('error', 'Lỗi kết nối', 'Không thể kết nối đến server SMS sau 3 lần thử');
                }
            }
            
            console.log('Connection status updated to:', span.textContent);
            
        } catch (error) {
            span.textContent = 'Lỗi kiểm tra kết nối';
            span.style.color = 'red';
            if (icon) icon.className = 'bx bx-error-circle';
            console.error('Connection check error:', error);
        }
    }


    closeNewMessageModal() {
        const modal = document.getElementById('newMessageModal');
        modal.classList.remove('active');
        document.body.style.overflow = '';
        this.resetNewMessageForm();
    }

    openMessageDetailModal(messageId) {
        const message = this.messages.find(m => m.id === messageId);
        if (!message) return;

        const modal = document.getElementById('messageDetailModal');
        const content = document.getElementById('messageDetailContent');
        
        content.innerHTML = this.renderMessageDetail(message);
        modal.classList.add('active');
        document.body.style.overflow = 'hidden';

        // Bind detail modal events
        this.bindMessageDetailEvents(message);
    }

    closeModals() {
        document.querySelectorAll('.modal').forEach(modal => {
            modal.classList.remove('active');
        });
        document.body.style.overflow = '';
    }

    // Data Management
    async loadMessages() {
        this.setLoading(true);
        
        try {
            console.log('Loading messages from backend...'); // Debug log
            
            const response = await this.fetchMessages();
            
            if (response && response.length > 0) {
                this.messages = response;
                this.filteredMessages = [...this.messages];
                
                console.log('Loaded messages:', this.messages); // Debug log
                this.showToast('success', 'Tải dữ liệu thành công', `Đã tải ${this.messages.length} tin nhắn từ server`);
            } else {
                // Nếu không có data từ backend, sử dụng mock data
                console.log('No data from backend, using mock data');
                this.messages = this.generateMockData();
                this.filteredMessages = [...this.messages];
                this.showToast('warning', 'Sử dụng dữ liệu mẫu', 'Không có dữ liệu từ server');
            }
            
        } catch (error) {
            console.error('Error loading messages:', error);
            this.messages = this.generateMockData();
            this.filteredMessages = [...this.messages];
            this.showToast('error', 'Lỗi kết nối', 'Không thể tải dữ liệu từ server, sử dụng dữ liệu mẫu');
        }
        
        this.setLoading(false);
    }

    async fetchMessages() {
        try {
            const baseUrl = window.location.origin;
            const response = await fetch(`${baseUrl}/cgi-bin/sms-read`, {
                method: 'GET',
                headers: {
                    'Accept': 'application/json,text/plain,*/*',
                    'Cache-Control': 'no-cache'
                }
            });
            
            if (response.ok) {
                const data = await response.json();
                console.log('Raw backend response:', data); // Debug log
                return this.parseBackendResponse(data);
            } else {
                throw new Error(`HTTP ${response.status}: ${response.statusText}`);
            }
        } catch (error) {
            console.error('Backend fetch error:', error);
            this.showToast('warning', 'Lỗi tải dữ liệu', 'Không thể kết nối backend, sử dụng dữ liệu mẫu');
            return null;
        }
    }
    


    // Helper method để parse text response nếu backend không trả JSON
    parseTextResponse(text) {
        try {
            // Thử parse JSON nếu có thể
            return JSON.parse(text);
        } catch {
            // Nếu không phải JSON, trả về empty array
            console.warn('Backend response is not JSON:', text);
            return [];
        }
    }

    parseBackendResponse(data) {
        try {
            let messagesArray = [];
            
            if (data && data.messages && Array.isArray(data.messages)) {
                messagesArray = data.messages;
            } else if (Array.isArray(data)) {
                messagesArray = data;
            }
    
            console.log('=== PARSING BACKEND RESPONSE ===');
            console.log('Total messages:', messagesArray.length);
    
            return messagesArray.map(item => {
                console.log('Raw message data:', {
                    id: item.id,
                    read_status: item.read_status, // Kiểm tra field này
                    state: item.state,
                    type: item.type
                });
    
                const mappedMessage = {
                    id: item.id?.toString() || this.generateId(),
                    phone: item.number || '',
                    content: item.text || '',
                    type: item.type === 'deliver' ? 'received' : 'sent',
                    timestamp: new Date(item.date),
                    // QUAN TRỌNG: Kiểm tra backend trả về field gì cho read status
                    read: this.determineReadStatus(item),
                    status: this.mapBackendState(item.state, item.type),
                    storage: item.storage || 'unknown',
                    _raw: item
                };
    
                console.log('Mapped read status:', {
                    id: mappedMessage.id,
                    read: mappedMessage.read,
                    originalData: item
                });
    
                return mappedMessage;
            }).sort((a, b) => b.timestamp - a.timestamp);
    
        } catch (error) {
            console.error('Error parsing backend response:', error);
            return [];
        }
    }
    
    // Cập nhật method determineReadStatus
    determineReadStatus(item) {
        // Kiểm tra field read_status từ backend
        if (item.read_status !== undefined) {
            return item.read_status === 1 || item.read_status === true;
        }
        
        // Fallback logic
        if (item.read !== undefined) return item.read;
        if (item.is_read !== undefined) return item.is_read;
        
        // Tin nhắn gửi thường được coi là đã đọc
        if (item.type === 'submit') return true;
        
        // Mặc định tin nhắn nhận được coi là chưa đọc
        return false;
    }

        
    mapBackendState(state, type) {
        // Map backend state to frontend status
        const stateMap = {
            'sent': 'sent',
            'received': 'received', 
            'delivered': 'delivered',
            'failed': 'failed',
            'pending': 'pending'
        };

        return stateMap[state] || (type === 'submit' ? 'sent' : 'received');
    }

    generateMockData() {
        const mockMessages = [];
        const phones = ['0901234567', '0912345678', '0923456789', '0934567890', '0945678901'];
        const sampleContents = [
            'Xin chào! Tôi muốn hỏi về sản phẩm của bạn.',
            'Cảm ơn bạn đã hỗ trợ. Rất hài lòng với dịch vụ.',
            'Đơn hàng của tôi đã được giao chưa?',
            'Tôi cần hỗ trợ về việc thanh toán.',
            'Sản phẩm rất tốt, tôi sẽ giới thiệu cho bạn bè.',
            'Có khuyến mãi gì trong tháng này không?',
            'Thời gian giao hàng là bao lâu?',
            'Tôi muốn đổi trả sản phẩm.',
            'Cửa hàng có chi nhánh ở đâu?',
            'Cảm ơn bạn đã tư vấn nhiệt tình.'
        ];

        for (let i = 0; i < 150; i++) {
            const isReceived = Math.random() > 0.6;
            const timestamp = new Date();
            timestamp.setHours(timestamp.getHours() - Math.random() * 24 * 30); // Last 30 days

            mockMessages.push({
                id: this.generateId(),
                phone: phones[Math.floor(Math.random() * phones.length)],
                content: sampleContents[Math.floor(Math.random() * sampleContents.length)],
                type: isReceived ? 'received' : 'sent',
                timestamp: timestamp,
                read: Math.random() > 0.3,
                status: Math.random() > 0.1 ? 'delivered' : 'failed'
            });
        }

        return mockMessages.sort((a, b) => b.timestamp - a.timestamp);
    }

    async sendMessage() {
        const phone = document.getElementById('recipientPhone').value.trim();
        const content = document.getElementById('messageContent').value.trim();

        if (!phone || !content) {
            this.showToast('error', 'Lỗi', 'Vui lòng điền đầy đủ thông tin');
            return;
        }

        if (!this.validatePhone(phone)) {
            this.showToast('error', 'Số điện thoại không hợp lệ', 'Vui lòng nhập số điện thoại đúng định dạng');
            return;
        }

        // Disable form during sending
        const submitBtn = document.querySelector('#newMessageForm button[type="submit"]');
        const originalText = submitBtn.innerHTML;
        submitBtn.disabled = true;
        submitBtn.innerHTML = '<i class="bx bx-loader-alt bx-spin"></i> Đang gửi...';

        try {
            const success = await this.submitMessage(phone, content);
            
            if (success) {
                // Add to local messages for immediate UI update
                const newMessage = {
                    id: this.generateId(),
                    phone: phone,
                    content: content,
                    type: 'sent',
                    timestamp: new Date(),
                    read: true,
                    status: 'sent'
                };

                this.messages.unshift(newMessage);
                this.applyFilters();
                this.updateStats();
                this.renderMessages();

                this.closeNewMessageModal();
                this.showToast('success', 'Gửi thành công', 'Tin nhắn đã được gửi đến ' + phone);
            }
        } catch (error) {
            this.showToast('error', 'Gửi thất bại', error.message || 'Có lỗi xảy ra khi gửi tin nhắn');
        } finally {
            // Re-enable form
            submitBtn.disabled = false;
            submitBtn.innerHTML = originalText;
        }
    }

    async submitMessage(phone, content) {
        try {
            // Sử dụng định dạng URL giống như curl command của bạn
            const baseUrl = window.location.origin; // Tự động lấy domain hiện tại
            const url = `${baseUrl}/cgi-bin/sms-send?number=${encodeURIComponent(phone)}&text=${encodeURIComponent(content)}`;
            
            const response = await fetch(url, {
                method: 'GET', // Sử dụng GET như trong curl command
                headers: {
                    'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
                    'Accept-Language': 'vi-VN,vi;q=0.9,en;q=0.8',
                    'Cache-Control': 'no-cache'
                },
                // Thêm timeout để tránh treo request
                signal: AbortSignal.timeout(30000) // 30 seconds timeout
            });

            if (response.ok) {
                // Kiểm tra response content để xác định thành công
                const responseText = await response.text();
                
                // Log response để debug (có thể bỏ khi production)
                console.log('SMS Send Response:', responseText);
                
                // Kiểm tra response có chứa thông báo lỗi không
                if (responseText.toLowerCase().includes('error') || 
                    responseText.toLowerCase().includes('failed') ||
                    responseText.toLowerCase().includes('fail')) {
                    throw new Error('Server báo lỗi khi gửi tin nhắn');
                }
                
                return true;
            } else {
                throw new Error(`Server trả về lỗi: ${response.status} ${response.statusText}`);
            }
        } catch (error) {
            console.error('Send message error:', error);
            
            if (error.name === 'AbortError') {
                throw new Error('Gửi tin nhắn bị timeout, vui lòng thử lại');
            } else if (error.name === 'TypeError' && error.message.includes('fetch')) {
                throw new Error('Không thể kết nối đến server');
            } else {
                throw error;
            }
        }
    }

    // Thêm method để test connection
    async testConnection() {
        console.log('testConnection started');
        try {
            const baseUrl = window.location.origin;
            console.log('Testing URL:', `${baseUrl}/cgi-bin/sms-send`);
            
            const controller = new AbortController();
            const timeoutId = setTimeout(() => {
                console.log('Connection test timeout');
                controller.abort();
            }, 5000);
            
            const response = await fetch(`${baseUrl}/cgi-bin/sms-send`, {
                method: 'GET',
                headers: { 
                    'Accept': '*/*',
                    'Cache-Control': 'no-cache' 
                },
                signal: controller.signal
            });
            
            clearTimeout(timeoutId);
            console.log('Response received:', response.status, response.ok);
            
            // ✅ CHỈ coi là thành công khi status 200-299
            const result = response.ok; // thay vì response.status < 500
            console.log('Connection test result:', result);
            return result;
            
        } catch (error) {
            console.log('Connection test error:', error.name, error.message);
            if (error.name === 'AbortError') {
                console.log('Connection test timeout');
            }
            return false;
        }
    }
    
    // THÊM CÁC METHOD MỚI NGAY ĐOẠN NÀY (sau testConnection)
    async retryConnection() {
        console.log('Starting connection retry...');
        for (let i = 0; i < 3; i++) {
            console.log(`Retry attempt ${i + 1}/3`);
            
            const result = await this.testConnection();
            if (result) {
                console.log('Connection successful on retry', i + 1);
                return true;
            }
            
            // Hiển thị retry indicator
            this.showConnectionTimeout(`Thử lại lần ${i + 1}/3...`);
            
            // Đợi 1 giây trước khi thử lại
            await new Promise(resolve => setTimeout(resolve, 1000));
        }
        
        console.log('All retry attempts failed');
        return false;
    }

    showConnectionTimeout(message = 'Timeout - Đang thử lại...') {
        const span = document.querySelector('#connectionStatus span');
        const icon = document.querySelector('#connectionStatus i');
        
        if (span) {
            span.textContent = message;
            span.style.color = 'orange';
        }
        
        if (icon) {
            icon.className = 'bx bx-error-circle';
        }
        
        console.log('Showing timeout message:', message);
    }

    async deleteMessage(messageId) {
        if (!confirm('Bạn có chắc chắn muốn xóa tin nhắn này?')) {
            return false;
        }
    
        try {
            console.log('Deleting message:', messageId);
            
            const baseUrl = window.location.origin;
            // Sử dụng parameter "ids" thay vì "id"
            const url = `${baseUrl}/cgi-bin/sms-delete?ids=${encodeURIComponent(messageId)}`;
            
            console.log('Delete URL:', url);
            
            const response = await fetch(url, {
                method: 'GET',
                headers: {
                    'Accept': 'application/json,*/*',
                    'Cache-Control': 'no-cache'
                }
            });
    
            console.log('Delete response status:', response.status);
            
            if (response.ok) {
                const result = await response.json();
                console.log('Delete response:', result);
                
                if (result.success && result.deleted_count > 0) {
                    // Remove from local messages
                    this.messages = this.messages.filter(m => m.id !== messageId);
                    this.selectedMessages.delete(messageId);
                    this.applyFilters();
                    this.updateStats();
                    this.renderMessages();
                    this.closeModals();
                    
                    this.showToast('success', 'Đã xóa', `Đã xóa tin nhắn thành công`);
                    return true;
                } else {
                    this.showToast('error', 'Xóa thất bại', result.message || 'Không thể xóa tin nhắn');
                    return false;
                }
            } else {
                throw new Error(`HTTP ${response.status}: ${response.statusText}`);
            }
        } catch (error) {
            console.error('Delete message error:', error);
            this.showToast('error', 'Lỗi xóa tin nhắn', error.message || 'Có lỗi xảy ra khi xóa');
            return false;
        }
    }


    // Thêm method để kiểm tra và hiển thị trạng thái connection
    async checkServerConnection() {
        const isConnected = await this.testConnection();
        
        if (!isConnected) {
            this.showToast('warning', 'Cảnh báo kết nối', 'Không thể kết nối đến server SMS. Sử dụng dữ liệu mẫu.');
        }
        
        return isConnected;
    }

    // Filtering and Search
    applyFilters() {
        let filtered = [...this.messages];

        // Filter by view type
        if (this.currentView === 'received') {
            filtered = filtered.filter(m => m.type === 'received');
        } else if (this.currentView === 'sent') {
            filtered = filtered.filter(m => m.type === 'sent');
        }

        // Apply filters
        if (this.filters.type) {
            filtered = filtered.filter(m => m.type === this.filters.type);
        }

        if (this.filters.status) {
            const isUnread = this.filters.status === 'unread';
            filtered = filtered.filter(m => m.read !== isUnread);
        }

        if (this.filters.time) {
            filtered = this.filterByTime(filtered, this.filters.time);
        }

        if (this.filters.search) {
            const search = this.filters.search.toLowerCase();
            filtered = filtered.filter(m => 
                m.phone.includes(search) || 
                m.content.toLowerCase().includes(search)
            );
        }

        this.filteredMessages = filtered;
        this.currentPage = 1;
        this.renderMessages();
        this.updateBulkActionsVisibility();
    }
    
    showBulkDeleteConfirmation(count) {
        return new Promise((resolve) => {
            // Create custom confirmation modal instead of basic confirm()
            const modal = document.createElement('div');
            modal.className = 'bulk-confirm-modal';
            modal.innerHTML = `
                <div class="modal-overlay"></div>
                <div class="modal-content">
                    <h3>Xác nhận xóa hàng loạt</h3>
                    <p>Bạn có chắc chắn muốn xóa <strong>${count}</strong> tin nhắn đã chọn?</p>
                    <p class="warning">Hành động này không thể hoàn tác.</p>
                    <div class="modal-actions">
                        <button class="btn btn-outline cancel-btn">Hủy</button>
                        <button class="btn btn-danger confirm-btn">Xóa ${count} tin nhắn</button>
                    </div>
                </div>
            `;
            
            document.body.appendChild(modal);
            
            modal.querySelector('.cancel-btn').onclick = () => {
                modal.remove();
                resolve(false);
            };
            
            modal.querySelector('.confirm-btn').onclick = () => {
                modal.remove();
                resolve(true);
            };
        });
    }


    filterByTime(messages, timeFilter) {
        const now = new Date();
        const today = new Date(now.getFullYear(), now.getMonth(), now.getDate());
        
        switch (timeFilter) {
            case 'today':
                return messages.filter(m => m.timestamp >= today);
            
            case 'yesterday':
                const yesterday = new Date(today);
                yesterday.setDate(yesterday.getDate() - 1);
                return messages.filter(m => 
                    m.timestamp >= yesterday && m.timestamp < today
                );
            
            case 'thisWeek':
                const weekStart = new Date(today);
                weekStart.setDate(weekStart.getDate() - weekStart.getDay());
                return messages.filter(m => m.timestamp >= weekStart);
            
            case 'lastWeek':
                const lastWeekStart = new Date(today);
                lastWeekStart.setDate(lastWeekStart.getDate() - lastWeekStart.getDay() - 7);
                const lastWeekEnd = new Date(lastWeekStart);
                lastWeekEnd.setDate(lastWeekEnd.getDate() + 7);
                return messages.filter(m => 
                    m.timestamp >= lastWeekStart && m.timestamp < lastWeekEnd
                );
            
            case 'thisMonth':
                const monthStart = new Date(now.getFullYear(), now.getMonth(), 1);
                return messages.filter(m => m.timestamp >= monthStart);
            
            case 'lastMonth':
                const lastMonthStart = new Date(now.getFullYear(), now.getMonth() - 1, 1);
                const lastMonthEnd = new Date(now.getFullYear(), now.getMonth(), 1);
                return messages.filter(m => 
                    m.timestamp >= lastMonthStart && m.timestamp < lastMonthEnd
                );
            
            default:
                return messages;
        }
    }

    clearFilters() {
        this.filters = { type: '', status: '', time: '', search: '' };
        
        // Reset form elements
        document.getElementById('messageType').value = '';
        document.getElementById('readStatus').value = '';
        document.getElementById('timeFilter').value = '';
        document.getElementById('searchInput').value = '';
        
        this.applyFilters();
        this.showToast('info', 'Bộ lọc đã được xóa', 'Hiển thị tất cả tin nhắn');
    }

    // View Management
    switchView(view) {
        this.currentView = view;
        
        // Update tab buttons
        document.querySelectorAll('.tab-btn').forEach(btn => {
            btn.classList.remove('active');
        });
        document.querySelector(`[data-view="${view}"]`).classList.add('active');
        
        this.applyFilters();
    }

    // Rendering
    renderMessages() {
        const container = document.getElementById('messagesList');
        const loadingElement = document.getElementById('messagesLoading');
        const emptyElement = document.getElementById('messagesEmpty');
        
        if (this.isLoading) {
            loadingElement.style.display = 'flex';
            container.style.display = 'none';
            emptyElement.style.display = 'none';
            return;
        }
        
        loadingElement.style.display = 'none';
        
        if (this.filteredMessages.length === 0) {
            container.style.display = 'none';
            emptyElement.style.display = 'flex';
            return;
        }
        
        emptyElement.style.display = 'none';
        container.style.display = 'block';

        // Pagination
        const startIndex = (this.currentPage - 1) * this.itemsPerPage;
        const endIndex = startIndex + this.itemsPerPage;
        const pageMessages = this.filteredMessages.slice(startIndex, endIndex);

        // Render messages
        container.innerHTML = pageMessages.map(message => this.renderMessageItem(message)).join('');

        // Bind message events
        this.bindMessageEvents();
        
        // Render pagination
        this.renderPagination();
    }

    renderMessageItem(message) {
        const isSelected = this.selectedMessages.has(message.id);
        const timeAgo = this.getTimeAgo(message.timestamp);
        const preview = this.truncateText(message.content, 100);
        
        // Xử lý hiển thị số điện thoại (loại bỏ +84 nếu có)
        const displayPhone = message.phone.startsWith('+84') 
            ? '0' + message.phone.substring(3) 
            : message.phone;

        return `
            <div class="message-item ${message.read ? '' : 'unread'} ${isSelected ? 'selected' : ''}" 
                 data-message-id="${message.id}">
                <div class="message-checkbox">
                    <input type="checkbox" ${isSelected ? 'checked' : ''} 
                           onchange="smsManager.toggleMessageSelection('${message.id}')">
                </div>
                
                <div class="message-avatar ${message.type}">
                    ${message.type === 'received' ? '📨' : '📤'}
                </div>
                
                <div class="message-content" onclick="smsManager.openMessageDetailModal('${message.id}')">
                    <div class="message-header">
                        <div class="message-phone">${displayPhone}</div>
                        <div class="message-meta">
                            <span class="message-type ${message.type}">
                                <i class='bx ${message.type === 'received' ? 'bx-down-arrow-alt' : 'bx-up-arrow-alt'}'></i>
                                ${message.type === 'received' ? 'Nhận' : 'Gửi'}
                            </span>
                            <span class="message-time">${timeAgo}</span>
                            ${message.storage ? `<span class="message-storage">${message.storage.toUpperCase()}</span>` : ''}
                        </div>
                    </div>
                    
                    <div class="message-text">${preview}</div>
                    
                    <div class="message-footer">
                        <div class="message-status">
                            ${this.renderMessageStatus(message)}
                        </div>
                        <div class="message-actions">
                            ${message.type === 'received' ? `
                                <button class="message-action-btn" onclick="event.stopPropagation(); smsManager.replyToMessage('${message.id}')" 
                                        title="Trả lời">
                                    <i class='bx bx-reply'></i>
                                </button>
                            ` : ''}
                            <button class="message-action-btn delete" onclick="event.stopPropagation(); smsManager.deleteMessage('${message.id}')" 
                                    title="Xóa">
                                <i class='bx bx-trash'></i>
                            </button>
                        </div>
                    </div>
                </div>
            </div>
        `;
    }

    renderMessageStatus(message) {
        if (!message) return '<span class="status-badge unknown">Không xác định</span>';
        
        // Xử lý tin nhắn nhận được
        if (message.type === 'received') {
            if (!message.read) {
                return '<span class="status-badge unread"><i class="bx bx-error-circle"></i> Chưa đọc</span>';
            } else {
                return '<span class="status-badge read"><i class="bx bx-check-circle"></i> Đã đọc</span>';
            }
        }
        
        // Xử lý tin nhắn gửi đi
        if (message.type === 'sent') {
            switch (message.status) {
                case 'sent':
                    return '<span class="status-badge sent"><i class="bx bx-check"></i> Đã gửi</span>';
                case 'delivered':
                    return '<span class="status-badge delivered"><i class="bx bx-check-double"></i> Đã nhận</span>';
                case 'failed':
                    return '<span class="status-badge failed"><i class="bx bx-x-circle"></i> Gửi thất bại</span>';
                case 'pending':
                    return '<span class="status-badge pending"><i class="bx bx-time"></i> Đang gửi</span>';
                default:
                    return '<span class="status-badge sent"><i class="bx bx-check"></i> Đã gửi</span>';
            }
        }
        
        // Fallback cho trường hợp không xác định được type
        return '<span class="status-badge unknown"><i class="bx bx-help-circle"></i> Không xác định</span>';
    }


    renderMessageDetail(message) {
        const timeFormatted = this.formatDateTime(message.timestamp);
        const displayPhone = message.phone.startsWith('+84') 
            ? '0' + message.phone.substring(3) + ' (' + message.phone + ')'
            : message.phone;
        
        return `
            <div class="message-detail-grid">
                <div class="detail-section">
                    <h4>
                        <i class='bx bx-info-circle'></i>
                        Thông tin tin nhắn
                    </h4>
                    <div class="detail-row">
                        <span class="detail-label">ID:</span>
                        <span class="detail-value">${message.id}</span>
                    </div>
                    <div class="detail-row">
                        <span class="detail-label">Số điện thoại:</span>
                        <span class="detail-value">${displayPhone}</span>
                    </div>
                    <div class="detail-row">
                        <span class="detail-label">Loại:</span>
                        <span class="detail-value">
                            <span class="message-type ${message.type}">
                                <i class='bx ${message.type === 'received' ? 'bx-down-arrow-alt' : 'bx-up-arrow-alt'}'></i>
                                ${message.type === 'received' ? 'Tin nhắn đến' : 'Tin nhắn gửi'}
                            </span>
                        </span>
                    </div>
                    <div class="detail-row">
                        <span class="detail-label">Thời gian:</span>
                        <span class="detail-value">${timeFormatted}</span>
                    </div>
                    <div class="detail-row">
                        <span class="detail-label">Trạng thái:</span>
                        <span class="detail-value">${this.renderMessageStatus(message)}</span>
                    </div>
                    <div class="detail-row">
                        <span class="detail-label">Lưu trữ:</span>
                        <span class="detail-value">
                            <span class="storage-badge ${message.storage}">
                                ${message.storage ? message.storage.toUpperCase() : 'N/A'}
                            </span>
                        </span>
                    </div>
                    <div class="detail-row">
                        <span class="detail-label">Độ dài:</span>
                        <span class="detail-value">${message.content.length} ký tự</span>
                    </div>
                </div>
                
                <div class="detail-section">
                    <h4>
                        <i class='bx bx-message-detail'></i>
                        Nội dung tin nhắn
                    </h4>
                    <div class="message-content-full">${message.content}</div>
                </div>
                
                <div class="detail-actions">
                    ${message.type === 'received' ? `
                        <button class="btn btn-primary" onclick="smsManager.replyToMessage('${message.id}')">
                            <i class='bx bx-reply'></i>
                            Trả lời
                        </button>
                    ` : ''}
                    ${!message.read ? `
                        <button class="btn btn-success" onclick="smsManager.markAsRead('${message.id}')">
                            <i class='bx bx-check'></i>
                            Đánh dấu đã đọc
                        </button>
                    ` : ''}
                    <button class="btn btn-danger" onclick="smsManager.deleteMessage('${message.id}')">
                        <i class='bx bx-trash'></i>
                        Xóa tin nhắn
                    </button>
                </div>
            </div>
        `;
    }



    renderPagination() {
        const container = document.getElementById('pagination');
        const totalPages = Math.ceil(this.filteredMessages.length / this.itemsPerPage);
        
        if (totalPages <= 1) {
            container.innerHTML = '';
            return;
        }

        let paginationHTML = '';

        // Previous button
        paginationHTML += `
            <button class="pagination-btn" ${this.currentPage === 1 ? 'disabled' : ''} 
                    onclick="smsManager.goToPage(${this.currentPage - 1})">
                <i class='bx bx-chevron-left'></i>
            </button>
        `;

        // Page numbers
        const startPage = Math.max(1, this.currentPage - 2);
        const endPage = Math.min(totalPages, this.currentPage + 2);

        if (startPage > 1) {
            paginationHTML += `<button class="pagination-btn" onclick="smsManager.goToPage(1)">1</button>`;
            if (startPage > 2) {
                paginationHTML += `<span class="pagination-dots">...</span>`;
            }
        }

        for (let i = startPage; i <= endPage; i++) {
            paginationHTML += `
                <button class="pagination-btn ${i === this.currentPage ? 'active' : ''}" 
                        onclick="smsManager.goToPage(${i})">${i}</button>
            `;
        }

        if (endPage < totalPages) {
            if (endPage < totalPages - 1) {
                paginationHTML += `<span class="pagination-dots">...</span>`;
            }
            paginationHTML += `<button class="pagination-btn" onclick="smsManager.goToPage(${totalPages})">${totalPages}</button>`;
        }

        // Next button
        paginationHTML += `
            <button class="pagination-btn" ${this.currentPage === totalPages ? 'disabled' : ''} 
                    onclick="smsManager.goToPage(${this.currentPage + 1})">
                <i class='bx bx-chevron-right'></i>
            </button>
        `;

        // Page info
        const startItem = (this.currentPage - 1) * this.itemsPerPage + 1;
        const endItem = Math.min(this.currentPage * this.itemsPerPage, this.filteredMessages.length);
        
        container.innerHTML = `
            ${paginationHTML}
            <div class="pagination-info">
                Hiển thị ${startItem}-${endItem} trong tổng số ${this.filteredMessages.length} tin nhắn
            </div>
        `;
    }

    // Message Event Bindings
    bindMessageEvents() {
        // Click events are handled via onclick attributes in the HTML
        // This method can be used for additional event bindings if needed
    }

    bindMessageDetailEvents(message) {
        // Events for message detail modal are bound via onclick in the rendered HTML
    }

    // Bulk Operations
    toggleMessageSelection(messageId) {
        if (this.selectedMessages.has(messageId)) {
            this.selectedMessages.delete(messageId);
        } else {
            this.selectedMessages.add(messageId);
        }
        
        this.updateBulkActionsVisibility();
        this.updateSelectedCount();
        this.updateMessageItemSelection(messageId);
    }

    toggleSelectAll() {
        const pageMessages = this.getPageMessages();
        const allSelected = pageMessages.every(m => this.selectedMessages.has(m.id));
        
        if (allSelected) {
            // Deselect all on current page
            pageMessages.forEach(m => this.selectedMessages.delete(m.id));
        } else {
            // Select all on current page
            pageMessages.forEach(m => this.selectedMessages.add(m.id));
        }
        
        this.renderMessages();
        this.updateBulkActionsVisibility();
        this.updateSelectedCount();
    }

    async markSelectedAsRead() {
        if (this.selectedMessages.size === 0) {
            this.showToast('warning', 'Không có tin nhắn nào được chọn', 'Vui lòng chọn ít nhất một tin nhắn');
            return;
        }
    
        const selectedIds = Array.from(this.selectedMessages);
        const totalCount = selectedIds.length;
        let successCount = 0;
    
        // Show progress
        this.showToast('info', 'Đang xử lý...', `Đang cập nhật ${totalCount} tin nhắn`);
    
        // Update each message
        for (const messageId of selectedIds) {
            try {
                const success = await this.updateReadStatusOnServer(messageId, true);
                if (success) {
                    // Update local state
                    const message = this.messages.find(m => m.id === messageId);
                    if (message) {
                        message.read = true;
                        successCount++;
                    }
                }
            } catch (error) {
                console.error('Error updating message:', messageId, error);
            }
        }
    
        // Clear selections and update UI
        this.selectedMessages.clear();
        this.applyFilters();
        this.updateStats();
        this.renderMessages();
        
        // Show result
        if (successCount === totalCount) {
            this.showToast('success', 'Thành công', `Đã đánh dấu ${successCount} tin nhắn là đã đọc`);
        } else {
            this.showToast('warning', 'Một phần thành công', `Đã cập nhật ${successCount}/${totalCount} tin nhắn`);
        }
    }


    async deleteSelectedMessages() {
        if (this.selectedMessages.size === 0) {
            this.showToast('warning', 'Không có tin nhắn nào được chọn');
            return;
        }
    
        if (this.bulkDeleting) return;
        
        const selectedIds = Array.from(this.selectedMessages);
        const confirmed = confirm(`Bạn có chắc chắn muốn xóa ${selectedIds.length} tin nhắn?`);
        
        if (!confirmed) return;
    
        this.bulkDeleting = true;
    
        try {
            // Chia nhỏ thành batch để tránh URL quá dài
            const batchSize = 10;
            const batches = [];
            
            for (let i = 0; i < selectedIds.length; i += batchSize) {
                batches.push(selectedIds.slice(i, i + batchSize));
            }
    
            let totalDeleted = 0;
            let totalFailed = 0;
    
            this.showToast('info', 'Đang xóa...', `Xử lý ${batches.length} nhóm tin nhắn`);
    
            // Xử lý từng batch
            for (let i = 0; i < batches.length; i++) {
                const batch = batches[i];
                const idsParam = batch.join(',');
                const url = `${window.location.origin}/cgi-bin/sms-delete?ids=${encodeURIComponent(idsParam)}`;
                
                console.log(`Processing batch ${i+1}/${batches.length}:`, batch);
                
                const response = await fetch(url, {
                    method: 'GET',
                    headers: { 'Accept': 'application/json,*/*' }
                });
    
                if (response.ok) {
                    const result = await response.json();
                    totalDeleted += result.deleted_count || 0;
                    totalFailed += result.failed_count || 0;
    
                    // Remove successfully deleted messages from local array
                    if (result.deleted && result.deleted.length > 0) {
                        const deletedIds = result.deleted.map(id => id.toString());
                        this.messages = this.messages.filter(m => 
                            !deletedIds.includes(m.id.toString())
                        );
                    }
                } else {
                    totalFailed += batch.length;
                }
    
                // Small delay between batches
                if (i < batches.length - 1) {
                    await new Promise(resolve => setTimeout(resolve, 500));
                }
            }
    
            // Update UI
            this.selectedMessages.clear();
            this.applyFilters();
            this.updateStats();
            this.renderMessages();
    
            // Show result
            if (totalFailed === 0) {
                this.showToast('success', 'Xóa thành công', `Đã xóa ${totalDeleted} tin nhắn`);
            } else {
                this.showToast('warning', 'Xóa một phần', `Đã xóa ${totalDeleted}/${totalDeleted + totalFailed} tin nhắn`);
            }
    
        } catch (error) {
            console.error('Bulk delete error:', error);
            this.showToast('error', 'Lỗi xóa', error.message);
        } finally {
            this.bulkDeleting = false;
        }
    }

    
    showBulkProgress(current, total, operation = 'Đang xử lý') {
        const percentage = Math.round((current / total) * 100);
        const existingToast = document.querySelector('.toast.bulk-progress');
        
        if (existingToast) {
            const progressBar = existingToast.querySelector('.progress-bar');
            const progressText = existingToast.querySelector('.progress-text');
            
            if (progressBar) progressBar.style.width = `${percentage}%`;
            if (progressText) progressText.textContent = `${operation} ${current}/${total} (${percentage}%)`;
        } else {
            // Create new progress toast
            this.showProgressToast(operation, current, total);
        }
    }


    async deleteBatchWithRetry(batch, maxRetries = 2) {
        for (let attempt = 1; attempt <= maxRetries; attempt++) {
            try {
                const idsParam = batch.join(',');
                const url = `${window.location.origin}/cgi-bin/sms-delete?ids=${encodeURIComponent(idsParam)}`;
                
                const response = await fetch(url, {
                    method: 'GET',
                    headers: { 'Accept': 'application/json,*/*' },
                    timeout: 10000 // 10 second timeout
                });
    
                if (response.ok) {
                    return await response.json();
                } else if (response.status >= 500 && attempt < maxRetries) {
                    // Retry on server errors
                    console.log(`Batch failed, retrying... (${attempt}/${maxRetries})`);
                    await new Promise(resolve => setTimeout(resolve, 1000 * attempt));
                    continue;
                } else {
                    throw new Error(`HTTP ${response.status}: ${response.statusText}`);
                }
            } catch (error) {
                if (attempt === maxRetries) {
                    throw error;
                }
                console.log(`Attempt ${attempt} failed, retrying...`, error);
                await new Promise(resolve => setTimeout(resolve, 1000 * attempt));
            }
        }
    }
    
    // Kiểm tra độ dài URL để tránh 414 error
    buildDeleteUrl(ids) {
        const baseUrl = `${window.location.origin}/cgi-bin/sms-delete?ids=`;
        const idsParam = ids.join(',');
        const fullUrl = baseUrl + encodeURIComponent(idsParam);
        
        // Check URL length limit (typically 2048 characters)
        if (fullUrl.length > 2000) {
            throw new Error('Too many IDs for single request. Will process in batches.');
        }
        
        return fullUrl;
    }

    
    // Thêm debug vào method updateReadStatusOnServer
    async updateReadStatusOnServer(messageId, readStatus) {
        try {
            const baseUrl = window.location.origin;
            const url = `${baseUrl}/cgi-bin/sms-mark-read?id=${encodeURIComponent(messageId)}&read=${readStatus ? 1 : 0}`;
            
            console.log('=== UPDATING READ STATUS ===');
            console.log('URL:', url);
            console.log('Message ID:', messageId);
            console.log('Read Status:', readStatus);
            
            const response = await fetch(url, {
                method: 'GET',
                headers: {
                    'Accept': '*/*',
                    'Cache-Control': 'no-cache'
                }
            });
    
            console.log('Response status:', response.status);
            console.log('Response OK:', response.ok);
            
            if (response.ok) {
                const responseText = await response.text();
                console.log('Response text:', responseText);
                return true;
            } else {
                console.error('Server error:', response.status, response.statusText);
                return false;
            }
        } catch (error) {
            console.error('Network error:', error);
            return false;
        }
    }



    // Message Actions
    replyToMessage(messageId) {
        const message = this.messages.find(m => m.id === messageId);
        if (!message) return;

        this.closeModals();
        this.openNewMessageModal();
        
        // Pre-fill phone number
        document.getElementById('recipientPhone').value = message.phone;
        document.getElementById('messageContent').focus();
    }

    async markAsRead(messageId) {
        try {
            console.log('Marking message as read:', messageId);
            
            // Gọi backend để cập nhật trạng thái
            const success = await this.updateReadStatusOnServer(messageId, true);
            
            if (success) {
                // Cập nhật local state
                const message = this.messages.find(m => m.id === messageId);
                if (message) {
                    message.read = true;
                    this.applyFilters();
                    this.updateStats();
                    this.renderMessages();
                    this.closeModals();
                    this.showToast('success', 'Đã cập nhật', 'Tin nhắn đã được đánh dấu là đã đọc');
                }
            } else {
                this.showToast('error', 'Lỗi', 'Không thể cập nhật trạng thái đọc');
            }
        } catch (error) {
            console.error('Error marking as read:', error);
            this.showToast('error', 'Lỗi', 'Có lỗi xảy ra khi cập nhật trạng thái');
        }
    }

    // Navigation
    goToPage(page) {
        const totalPages = Math.ceil(this.filteredMessages.length / this.itemsPerPage);
        if (page >= 1 && page <= totalPages) {
            this.currentPage = page;
            this.renderMessages();
        }
    }

    // Utility Functions
    updateStats() {
        const total = this.messages.length;
        const sent = this.messages.filter(m => m.type === 'sent').length;
        const received = this.messages.filter(m => m.type === 'received').length;
        const unread = this.messages.filter(m => !m.read).length;

        document.getElementById('totalMessages').textContent = total;
        document.getElementById('sentMessages').textContent = sent;
        document.getElementById('receivedMessages').textContent = received;
        document.getElementById('unreadMessages').textContent = unread;
    }

    updateBulkActionsVisibility() {
        const bulkActions = document.getElementById('bulkActions');
        const hasSelection = this.selectedMessages.size > 0;
        
        bulkActions.style.display = hasSelection ? 'flex' : 'none';
        this.updateSelectedCount();
    }

    updateSelectedCount() {
        document.getElementById('selectedCount').textContent = `${this.selectedMessages.size} đã chọn`;
    }

    updateMessageItemSelection(messageId) {
        const messageElement = document.querySelector(`[data-message-id="${messageId}"]`);
        if (messageElement) {
            const isSelected = this.selectedMessages.has(messageId);
            messageElement.classList.toggle('selected', isSelected);
            
            const checkbox = messageElement.querySelector('input[type="checkbox"]');
            checkbox.checked = isSelected;
        }
    }

    getPageMessages() {
        const startIndex = (this.currentPage - 1) * this.itemsPerPage;
        const endIndex = startIndex + this.itemsPerPage;
        return this.filteredMessages.slice(startIndex, endIndex);
    }

    setLoading(loading) {
        this.isLoading = loading;
        
        if (loading) {
            document.getElementById('messagesLoading').style.display = 'flex';
            document.getElementById('messagesList').style.display = 'none';
            document.getElementById('messagesEmpty').style.display = 'none';
        }
    }

    // Method loadMessages không hiển thị toast
    async loadMessagesQuiet() {
        this.setLoading(true);
        
        try {
            const response = await this.fetchMessages();
            
            if (response && response.length > 0) {
                this.messages = response;
                this.filteredMessages = [...this.messages];
            } else {
                this.messages = this.generateMockData();
                this.filteredMessages = [...this.messages];
            }
            
        } catch (error) {
            console.error('Error loading messages:', error);
            this.messages = this.generateMockData();
            this.filteredMessages = [...this.messages];
            throw error;
        } finally {
            this.setLoading(false);
        }
    }
    
    // Method refreshMessages sử dụng loadMessagesQuiet
    async refreshMessages() {
        // Prevent multiple calls
        if (this.refreshing) {
            console.log('Already refreshing, skipping...');
            return;
        }
        
        this.refreshing = true;
        console.log('=== REFRESH START ===');
        
        try {
            this.showToast('info', 'Đang làm mới...', 'Tải lại danh sách tin nhắn');
            this.selectedMessages.clear();
            
            // Load messages without showing toast
            await this.loadMessagesQuiet();
            
            this.updateStats();
            this.renderMessages();
            
            this.showToast('success', 'Làm mới thành công', `Hiển thị ${this.messages.length} tin nhắn`);
            
        } catch (error) {
            console.error('Refresh error:', error);
            this.showToast('error', 'Lỗi làm mới', 'Có lỗi xảy ra khi tải dữ liệu');
        } finally {
            this.refreshing = false;
            console.log('=== REFRESH END ===');
        }
    }

    
    // Method để sync với server khi có tin nhắn mới
    async syncWithServer() {
        try {
            const response = await this.fetchMessages();
            if (response && response.length > this.messages.length) {
                const newMessages = response.slice(0, response.length - this.messages.length);
                this.showToast('info', 'Tin nhắn mới!', `Có ${newMessages.length} tin nhắn mới`);
                this.messages = response;
                this.applyFilters();
                this.updateStats();
                this.renderMessages();
            }
        } catch (error) {
            console.log('Auto sync failed:', error);
        }
    }

    // Auto sync mỗi 30 giây (tùy chọn)
    startAutoSync() {
        setInterval(() => {
            this.syncWithServer();
        }, 30000); // 30 seconds
    }

    resetNewMessageForm() {
        document.getElementById('newMessageForm').reset();
        document.getElementById('charCount').textContent = '0';
    }

    updateCharCount() {
        const textarea = document.getElementById('messageContent');
        const count = textarea.value.length;
        const counter = document.getElementById('charCount');
        
        counter.textContent = count;
        
        if (count > 160) {
            counter.style.color = 'var(--danger-color)';
        } else if (count > 140) {
            counter.style.color = 'var(--warning-color)';
        } else {
            counter.style.color = 'var(--gray-500)';
        }
    }

    validatePhone(phone) {
        // Loại bỏ khoảng trắng và ký tự đặc biệt không cần thiết
        const cleanPhone = phone.replace(/[\s\-\(\)\+]/g, '');
        
        // Kiểm tra cơ bản: phải có ít nhất 1 chữ số và không chứa ký tự đặc biệt
        const basicRegex = /^[0-9]+$/;
        
        // Độ dài từ 3-15 số (đủ cho mọi loại số trên thế giới)
        const lengthValid = cleanPhone.length >= 3 && cleanPhone.length <= 15;
        
        return basicRegex.test(cleanPhone) && lengthValid;
    }


    truncateText(text, maxLength) {
        if (text.length <= maxLength) return text;
        return text.substr(0, maxLength) + '...';
    }

    getTimeAgo(timestamp) {
        const now = new Date();
        const diff = now - timestamp;
        const minutes = Math.floor(diff / 60000);
        const hours = Math.floor(diff / 3600000);
        const days = Math.floor(diff / 86400000);

        if (minutes < 1) return 'Vừa xong';
        if (minutes < 60) return `${minutes} phút trước`;
        if (hours < 24) return `${hours} giờ trước`;
        if (days < 7) return `${days} ngày trước`;
        
        return this.formatDate(timestamp);
    }

    formatDate(date) {
        return date.toLocaleDateString('vi-VN', {
            day: '2-digit',
            month: '2-digit',
            year: 'numeric'
        });
    }

    formatDateTime(date) {
        return date.toLocaleString('vi-VN', {
            day: '2-digit',
            month: '2-digit',
            year: 'numeric',
            hour: '2-digit',
            minute: '2-digit'
        });
    }

    generateId() {
        return Date.now().toString(36) + Math.random().toString(36).substr(2);
    }

    // Export Functions
    async exportMessages() {
        // Prevent multiple calls
        if (this.exporting) {
            console.log('Already exporting, skipping...');
            return;
        }
        
        this.exporting = true;
        console.log('=== EXPORT START ===');
        
        try {
            const messages = this.filteredMessages.length > 0 ? this.filteredMessages : this.messages;
            
            if (messages.length === 0) {
                this.showToast('warning', 'Không có dữ liệu', 'Không có tin nhắn nào để xuất');
                return;
            }
    
            // Disable export button during processing
            const exportBtn = document.getElementById('exportBtn');
            if (exportBtn) {
                exportBtn.disabled = true;
                exportBtn.innerHTML = '<i class="bx bx-loader-alt bx-spin"></i> Đang xuất...';
            }
    
            this.showToast('info', 'Đang xuất dữ liệu...', `Chuẩn bị xuất ${messages.length} tin nhắn`);
    
            // Generate CSV content
            const csvContent = this.generateCSV(messages);
            const blob = new Blob([csvContent], { type: 'text/csv;charset=utf-8;' });
            
            // Create download link
            const link = document.createElement('a');
            const url = URL.createObjectURL(blob);
            
            const timestamp = new Date().toISOString().slice(0, 19).replace(/:/g, '-');
            const filename = `sms-export-${timestamp}.csv`;
            
            link.setAttribute('href', url);
            link.setAttribute('download', filename);
            link.style.visibility = 'hidden';
            
            document.body.appendChild(link);
            link.click();
            document.body.removeChild(link);
            
            // Clean up URL object
            URL.revokeObjectURL(url);
            
            this.showToast('success', 'Xuất thành công', `Đã xuất ${messages.length} tin nhắn ra file ${filename}`);
            
        } catch (error) {
            console.error('Export error:', error);
            this.showToast('error', 'Lỗi xuất dữ liệu', error.message || 'Có lỗi xảy ra khi xuất file');
        } finally {
            this.exporting = false;
            
            // Re-enable export button
            const exportBtn = document.getElementById('exportBtn');
            if (exportBtn) {
                exportBtn.disabled = false;
                exportBtn.innerHTML = '<i class="bx bx-download"></i> Xuất dữ liệu';
            }
            
            console.log('=== EXPORT END ===');
        }
    }


    generateCSV(messages) {
        const headers = ['Số điện thoại', 'Nội dung', 'Loại', 'Thời gian', 'Trạng thái đọc', 'Trạng thái gửi'];
        const csvRows = [headers.join(',')];
        
        messages.forEach(message => {
            const row = [
                message.phone,
                `"${message.content.replace(/"/g, '""')}"`, // Escape quotes
                message.type === 'received' ? 'Nhận' : 'Gửi',
                this.formatDateTime(message.timestamp),
                message.read ? 'Đã đọc' : 'Chưa đọc',
                message.status || 'N/A'
            ];
            csvRows.push(row.join(','));
        });
        
        return '\ufeff' + csvRows.join('\n'); // UTF-8 BOM for Excel compatibility
    }

    bulkDeleteMessages() {
        if (this.selectedMessages.size === 0) {
            this.showToast('info', 'Chọn tin nhắn để xóa', 'Vui lòng chọn ít nhất một tin nhắn');
            return;
        }
        
        this.deleteSelectedMessages();
    }

    // Toast Notifications
    showToast(type, title, message) {
        const toast = this.createToast(type, title, message);
        const container = document.getElementById('toastContainer');
        
        container.appendChild(toast);
        
        // Auto remove after 4 seconds
        setTimeout(() => {
            if (toast.parentNode) {
                toast.remove();
            }
        }, 4000);
    }

    createToast(type, title, message) {
        const toast = document.createElement('div');
        toast.className = `toast ${type}`;
        
        const iconMap = {
            success: 'bx-check-circle',
            error: 'bx-error-circle',
            warning: 'bx-error',
            info: 'bx-info-circle'
        };
        
        toast.innerHTML = `
            <div class="toast-icon">
                <i class='bx ${iconMap[type]}'></i>
            </div>
            <div class="toast-content">
                <div class="toast-title">${title}</div>
                <div class="toast-message">${message}</div>
            </div>
            <button class="toast-close" onclick="this.parentNode.remove()">
                <i class='bx bx-x'></i>
            </button>
        `;
        
        return toast;
    }

    showWelcomeToast() {
        setTimeout(() => {
            this.showToast('info', 'Chào mừng!', 'Hệ thống SMS Manager Pro đã sẵn sàng');
        }, 1000);
    }
}

// Initialize the SMS Manager when DOM is loaded
// Khởi tạo với auto sync
document.addEventListener('DOMContentLoaded', () => {
    window.smsManager = new SMSManager();
    
    // Bật auto sync sau 1 phút
    setTimeout(() => {
        window.smsManager.startAutoSync();
    }, 60000);
});

// Add some additional CSS for status badges
const additionalCSS = `
.status-badge {
    display: inline-flex;
    align-items: center;
    gap: 4px;
    padding: 2px 8px;
    border-radius: 12px;
    font-size: 0.75rem;
    font-weight: 500;
}

.status-badge.unread {
    background: var(--primary-light);
    color: var(--primary-color);
}

.status-badge.sent {
    background: var(--info-light);
    color: var(--info-color);
}

.status-badge.delivered {
    background: var(--success-light);
    color: var(--success-color);
}

.status-badge.failed {
    background: var(--danger-light);
    color: var(--danger-color);
}

.status-badge.pending {
    background: var(--warning-light);
    color: var(--warning-color);
}

.pagination-dots {
    display: flex;
    align-items: center;
    padding: 0 8px;
    color: var(--gray-400);
}
`;

// Inject additional CSS
const style = document.createElement('style');
style.textContent = additionalCSS;
document.head.appendChild(style);
EOF


# 4. Cấp quyền thực thi cho CGI
echo "Cấp quyền thực thi cho CGI..."
chmod +x "$CGI_DIR/em9190-info"
chmod +x "$CGI_DIR/ping-info"
chmod +x "$CGI_DIR/sms-send"
chmod +x "$CGI_DIR/sms-read"
chmod +x "$CGI_DIR/sms-delete"
chmod +x "$CGI_DIR/sms-mark-read"

# 5. Cấu hình uhttpd
echo "Cấu hình uhttpd..."

# Backup config gốc
cp "$UHTTPD_CONFIG" "$UHTTPD_CONFIG.backup"

# Thêm config mới
cat >> "$UHTTPD_CONFIG" << EOF

config uhttpd 'em9190'
	option home '/www/em9190'
	option cgi_prefix '/cgi-bin'
	list listen_http '0.0.0.0:$PORT'
	list listen_http '[::]:$PORT'
	option redirect_https '0'
	option rfc1918_filter '0'
	option max_requests '10'
	option max_connections '100'
	option tcp_keepalive '1'
	option ubus_prefix '/ubus'
	option index_file 'index.html'
	option error_page '/error.html'
	option script_timeout '60'
	option network_timeout '30'
	option http_keepalive '20'
	option tcp_keepalive '1'
EOF

# 6. Khởi động dịch vụ
echo "Khởi động dịch vụ uhttpd..."
/etc/init.d/uhttpd restart

# 7. Kiểm tra và hiển thị kết quả
echo ""
echo "=== Cài đặt hoàn tất ==="
echo ""
echo "Thông tin truy cập:"
echo "- URL: http://$(ip route get 1 | awk '{print $NF;exit}'):$PORT"
echo "- Port: $PORT"
echo "- Thư mục web: $WEB_DIR"
echo ""
echo "Kiểm tra dịch vụ:"
if netstat -ln 2>/dev/null | grep -q ":$PORT " || ss -ln 2>/dev/null | grep -q ":$PORT "; then
    echo "✅ Dịch vụ uhttpd đang chạy trên port $PORT"
else
    echo "❌ Dịch vụ uhttpd chưa khởi động"
fi

echo ""
echo "Để gỡ cài đặt, chạy:"
echo "rm -rf $WEB_DIR"
echo "sed -i '/em9190/,/^$/d' $UHTTPD_CONFIG"
echo "/etc/init.d/uhttpd restart"
echo ""
echo "Truy cập: http://$(ip route get 1 | awk '{print $NF;exit}'):$PORT"
