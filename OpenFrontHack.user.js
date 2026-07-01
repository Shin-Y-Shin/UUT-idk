// ==UserScript==
// @name         ShinyHub - OpenFront.io
// @namespace    shinyhub
// @version      2.0
// @description  OpenFront.io automation & enhancements
// @author       ShinyHub
// @match        https://openfront.io/*
// @grant        none
// @run-at       document-start
// ==/UserScript==

(function () {
    "use strict";

    let gameWS = null;
    const config = {
        maxTroopAttack: false,
    };

    // ─── WebSocket Hook (must run before page loads) ────────
    const OrigWS = window.WebSocket;
    const origSendFn = OrigWS.prototype.send;

    window.WebSocket = function (url, protocols) {
        const ws = protocols ? new OrigWS(url, protocols) : new OrigWS(url);

        if (url && !url.includes("/lobbies") && !url.includes("google") && !url.includes("securepubads") && !url.includes("doubleclick")) {
            gameWS = ws;
            window._shinyGameWS = ws;
            console.log("[ShinyHub] Game WebSocket captured:", url);
        }

        return ws;
    };
    window.WebSocket.prototype = OrigWS.prototype;
    window.WebSocket.CONNECTING = OrigWS.CONNECTING;
    window.WebSocket.OPEN = OrigWS.OPEN;
    window.WebSocket.CLOSING = OrigWS.CLOSING;
    window.WebSocket.CLOSED = OrigWS.CLOSED;

    // ─── Max Troop Attack Hook ──────────────────────────────
    OrigWS.prototype.send = function (data) {
        if (config.maxTroopAttack && typeof data === "string") {
            try {
                const msg = JSON.parse(data);
                if (msg.type === "intent" && msg.intent?.type === "attack") {
                    msg.intent.troops = 999999999;
                    data = JSON.stringify(msg);
                }
            } catch (_) {}
        }
        return origSendFn.call(this, data);
    };

    function sendIntent(intent) {
        const ws = gameWS || window._shinyGameWS;
        if (!ws || ws.readyState !== 1) return false;
        origSendFn.call(ws, JSON.stringify({ type: "intent", intent }));
        return true;
    }

    // ─── Wait for game to load, then build UI ───────────────
    function waitForGame() {
        const check = setInterval(() => {
            if (window.__webglView && window.__webglView.renderer && window.__webglView.renderer.camera) {
                clearInterval(check);
                buildUI();
            }
        }, 500);
    }

    function buildUI() {
        if (document.getElementById("shinyhub-panel")) document.getElementById("shinyhub-panel").remove();

        const view = window.__webglView;
        const renderer = view.renderer;
        const cam = renderer.camera;
        const origZoom = cam.zoom;

        function setZoom(level) {
            cam.zoom = level;
            cam.dirty = true;
        }

        const panel = document.createElement("div");
        panel.id = "shinyhub-panel";
        panel.innerHTML = `
        <style>
            #shinyhub-panel { position:fixed; top:10px; right:10px; width:280px; background:rgba(8,10,18,0.96); border:1px solid rgba(130,80,255,0.5); border-radius:14px; color:#e0e0e0; font-family:'Segoe UI',sans-serif; font-size:13px; z-index:999999; user-select:none; backdrop-filter:blur(12px); box-shadow:0 4px 30px rgba(130,80,255,0.2), 0 0 1px rgba(130,80,255,0.6); overflow:hidden; }
            #sh-hdr { background:linear-gradient(135deg,rgba(130,80,255,0.35),rgba(60,20,160,0.35)); padding:10px 14px; font-size:15px; font-weight:700; cursor:move; display:flex; justify-content:space-between; align-items:center; border-bottom:1px solid rgba(130,80,255,0.25); }
            .sh-title { color:#b48aff; font-size:16px; }
            .sh-ver { color:#555; font-size:10px; margin-left:6px; }
            #sh-min { cursor:pointer; font-size:16px; color:#666; width:24px; height:24px; display:flex; align-items:center; justify-content:center; border-radius:6px; transition:all 0.2s; }
            #sh-min:hover { background:rgba(255,255,255,0.1); color:#fff; }
            #sh-body { padding:8px 12px 12px; max-height:500px; overflow-y:auto; }
            .sh-sec { font-size:10px; color:#8250ff; text-transform:uppercase; letter-spacing:1.2px; padding:10px 0 5px; font-weight:700; }
            .sh-row { display:flex; justify-content:space-between; align-items:center; padding:6px 4px; border-radius:6px; transition:background 0.15s; }
            .sh-row:hover { background:rgba(255,255,255,0.03); }
            .sh-lbl { font-size:12.5px; color:#ccc; }
            .sh-desc { font-size:10px; color:#555; margin-top:1px; }
            .sh-sw { width:36px; height:18px; background:#2a2a3a; border-radius:9px; position:relative; cursor:pointer; transition:background 0.2s; flex-shrink:0; }
            .sh-sw.on { background:#7c4dff; }
            .sh-sw::after { content:''; position:absolute; top:2px; left:2px; width:14px; height:14px; background:#fff; border-radius:50%; transition:left 0.15s; }
            .sh-sw.on::after { left:20px; }
            .sh-btn { width:100%; padding:7px 10px; margin:3px 0; background:rgba(130,80,255,0.12); border:1px solid rgba(130,80,255,0.25); border-radius:8px; color:#b48aff; cursor:pointer; font-size:11.5px; transition:all 0.15s; text-align:center; }
            .sh-btn:hover { background:rgba(130,80,255,0.25); color:#fff; border-color:rgba(130,80,255,0.5); }
            .sh-slider-row { padding:6px 4px; }
            .sh-slider { width:100%; accent-color:#7c4dff; cursor:pointer; }
            .sh-val { font-size:11px; color:#7c4dff; font-weight:600; }
            .sh-st { font-size:10.5px; padding:5px 0; text-align:center; }
            .sh-st.ok { color:#4ade80; }
            .sh-st.no { color:#666; }
            .sh-sep { border-top:1px solid rgba(255,255,255,0.04); margin:2px 0; }
            #sh-body::-webkit-scrollbar { width:4px; }
            #sh-body::-webkit-scrollbar-thumb { background:rgba(130,80,255,0.3); border-radius:4px; }
        </style>
        <div id="sh-hdr">
            <div><span class="sh-title">ShinyHub</span><span class="sh-ver">v2.0</span></div>
            <div id="sh-min">—</div>
        </div>
        <div id="sh-body">
            <div class="sh-st" id="sh-status">Checking...</div>

            <div class="sh-sec">Camera</div>
            <div class="sh-slider-row">
                <div class="sh-row"><span class="sh-lbl">Zoom Level</span><span class="sh-val" id="sh-zoom-val">${cam.zoom.toFixed(1)}</span></div>
                <input type="range" class="sh-slider" id="sh-zoom" min="0.1" max="20" step="0.1" value="${cam.zoom}">
            </div>
            <div class="sh-btn" id="sh-zoom-max">Zoom Out Max (See Whole Map)</div>
            <div class="sh-btn" id="sh-zoom-reset">Reset Zoom</div>

            <div class="sh-sep"></div>
            <div class="sh-sec">Combat</div>
            <div class="sh-row">
                <div><div class="sh-lbl">Max Troop Attack</div><div class="sh-desc">Send max troops on every attack</div></div>
                <div class="sh-sw" data-key="maxTroopAttack"></div>
            </div>

            <div class="sh-sep"></div>
            <div class="sh-sec">Quick Build</div>
            <div class="sh-btn" data-build="City">Build City</div>
            <div class="sh-btn" data-build="Port">Build Port</div>
            <div class="sh-btn" data-build="Defense Post">Build Defense Post</div>
            <div class="sh-btn" data-build="Missile Silo">Build Missile Silo</div>
            <div class="sh-btn" data-build="Train Station">Build Train Station</div>

            <div class="sh-sep"></div>
            <div class="sh-sec">Nukes</div>
            <div class="sh-btn" data-build="Atom Bomb">Build Atom Bomb</div>
            <div class="sh-btn" data-build="Hydrogen Bomb">Build Hydrogen Bomb</div>
            <div class="sh-btn" data-build="MIRV">Build MIRV</div>

            <div class="sh-sep"></div>
            <div class="sh-sec">Fun</div>
            <div class="sh-btn" id="sh-spam-emoji">Spam Emojis</div>

            <div class="sh-sep"></div>
            <div class="sh-sec">Info</div>
            <div style="font-size:10px;color:#555;padding:4px;">
                Player ID: ${renderer.localPlayerID}<br>
                Map: ${renderer.mapW}x${renderer.mapH}<br>
                F6 = Toggle Panel
            </div>
        </div>`;
        document.body.appendChild(panel);

        // ─── Dragging ───────────────────────────────────────
        let dragging = false, dx = 0, dy = 0;
        document.getElementById("sh-hdr").addEventListener("mousedown", function (e) {
            if (e.target.id === "sh-min") return;
            dragging = true;
            dx = e.clientX - panel.offsetLeft;
            dy = e.clientY - panel.offsetTop;
        });
        document.addEventListener("mousemove", function (e) {
            if (!dragging) return;
            panel.style.left = e.clientX - dx + "px";
            panel.style.right = "auto";
            panel.style.top = e.clientY - dy + "px";
        });
        document.addEventListener("mouseup", function () { dragging = false; });

        // ─── Minimize ───────────────────────────────────────
        document.getElementById("sh-min").addEventListener("click", function () {
            const b = document.getElementById("sh-body");
            b.style.display = b.style.display === "none" ? "block" : "none";
        });

        // ─── Zoom Controls ─────────────────────────────────
        const zoomSlider = document.getElementById("sh-zoom");
        const zoomVal = document.getElementById("sh-zoom-val");
        zoomSlider.addEventListener("input", function (e) {
            const v = parseFloat(e.target.value);
            setZoom(v);
            zoomVal.textContent = v.toFixed(1);
        });
        document.getElementById("sh-zoom-max").addEventListener("click", function () {
            setZoom(0.3);
            zoomSlider.value = 0.3;
            zoomVal.textContent = "0.3";
        });
        document.getElementById("sh-zoom-reset").addEventListener("click", function () {
            setZoom(origZoom);
            zoomSlider.value = origZoom;
            zoomVal.textContent = origZoom.toFixed(1);
        });

        // ─── Toggles ───────────────────────────────────────
        panel.querySelectorAll(".sh-sw").forEach(function (sw) {
            sw.addEventListener("click", function () {
                const key = sw.dataset.key;
                config[key] = !config[key];
                sw.classList.toggle("on", config[key]);
            });
        });

        // ─── Quick Build (click-to-place) ───────────────────
        let pendingBuild = null;
        panel.querySelectorAll("[data-build]").forEach(function (btn) {
            btn.addEventListener("click", function () {
                pendingBuild = btn.dataset.build;
                btn.style.background = "rgba(130,80,255,0.4)";
                btn.textContent = "Click on map to place...";
                setTimeout(function () {
                    btn.style.background = "";
                    btn.textContent = (btn.dataset.build.includes("Bomb") || btn.dataset.build === "MIRV" ? "Build " : "Build ") + btn.dataset.build;
                }, 5000);
            });
        });

        const canvas = document.querySelector("canvas");
        if (canvas) {
            canvas.addEventListener("click", function (e) {
                if (!pendingBuild) return;
                const rect = canvas.getBoundingClientRect();
                const x = e.clientX - rect.left;
                const y = e.clientY - rect.top;
                const mapX = (x / cam.zoom + cam.offsetX) | 0;
                const mapY = (y / cam.zoom + cam.offsetY) | 0;
                const tile = mapY * renderer.mapW + mapX;
                if (tile >= 0 && tile < renderer.mapW * renderer.mapH) {
                    sendIntent({ type: "build_unit", unit: pendingBuild, tile: tile });
                    console.log("[ShinyHub] Build", pendingBuild, "at tile", tile);
                }
                pendingBuild = null;
            });
        }

        // ─── Emoji Spam ────────────────────────────────────
        document.getElementById("sh-spam-emoji").addEventListener("click", function () {
            const emojis = ["thumbs_up", "skull", "fire", "laughing", "rage", "clown", "crying", "heart"];
            let i = 0;
            const sp = setInterval(function () {
                if (i >= 20) { clearInterval(sp); return; }
                sendIntent({ type: "emoji", emoji: emojis[i % emojis.length] });
                i++;
            }, 100);
        });

        // ─── WS Status Updater ─────────────────────────────
        setInterval(function () {
            const el = document.getElementById("sh-status");
            if (!el) return;
            const ws = gameWS || window._shinyGameWS;
            if (ws && ws.readyState === 1) {
                el.textContent = "Connected to game";
                el.className = "sh-st ok";
            } else {
                el.textContent = "Waiting for game...";
                el.className = "sh-st no";
            }
        }, 1000);

        // ─── F6 Toggle ─────────────────────────────────────
        document.addEventListener("keydown", function (e) {
            if (e.key === "F6") {
                e.preventDefault();
                panel.style.display = panel.style.display === "none" ? "block" : "none";
            }
        });

        console.log("[ShinyHub] v2.0 loaded!");
    }

    // ─── Init ───────────────────────────────────────────────
    if (document.readyState === "loading") {
        document.addEventListener("DOMContentLoaded", waitForGame);
    } else {
        waitForGame();
    }

    console.log("[ShinyHub] WebSocket hook installed, waiting for game...");
})();
