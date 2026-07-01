// ==UserScript==
// @name         ShinyHub - OpenFront.io
// @namespace    shinyhub
// @version      1.0
// @description  OpenFront.io automation & enhancements
// @author       ShinyHub
// @match        https://openfront.io/*
// @grant        none
// @run-at       document-start
// ==/UserScript==

(function () {
    "use strict";

    let gameWS = null;
    let allSockets = [];
    const config = {
        autoAttack: false,
        autoSpawn: false,
        autoBuild: false,
        zoomHack: true,
        speedClick: false,
        attackRatio: 1.0,
    };

    // ─── WebSocket Hook ─────────────────────────────────────────
    const OrigWS = window.WebSocket;
    window.WebSocket = function (url, protocols) {
        const ws = protocols ? new OrigWS(url, protocols) : new OrigWS(url);
        allSockets.push(ws);

        if (url && !url.includes("/lobbies")) {
            gameWS = ws;
            console.log("[ShinyHub] Game WebSocket captured:", url);

            const origSend = ws.send.bind(ws);
            ws.send = function (data) {
                return origSend(data);
            };

            ws.addEventListener("message", function (e) {
                try {
                    if (typeof e.data === "string") {
                        const msg = JSON.parse(e.data);
                        handleServerMessage(msg);
                    }
                } catch (_) {}
            });
        }

        return ws;
    };
    window.WebSocket.prototype = OrigWS.prototype;
    window.WebSocket.CONNECTING = OrigWS.CONNECTING;
    window.WebSocket.OPEN = OrigWS.OPEN;
    window.WebSocket.CLOSING = OrigWS.CLOSING;
    window.WebSocket.CLOSED = OrigWS.CLOSED;

    function sendIntent(intent) {
        if (!gameWS || gameWS.readyState !== WebSocket.OPEN) return false;
        const msg = JSON.stringify({ type: "intent", intent: intent });
        gameWS.send(msg);
        return true;
    }

    // ─── Game State ─────────────────────────────────────────────
    let gameState = {
        myId: null,
        players: {},
        tick: 0,
        inSpawnPhase: false,
        started: false,
    };

    function handleServerMessage(msg) {
        if (!msg) return;
        if (msg.type === "start" || msg.turns) {
            gameState.started = true;
        }
    }

    // ─── Zoom Hack ──────────────────────────────────────────────
    function applyZoomHack() {
        if (!config.zoomHack) return;

        const hackZoom = () => {
            const canvas = document.querySelector("canvas");
            if (!canvas) return;

            canvas.addEventListener(
                "wheel",
                function (e) {
                    if (e.ctrlKey || e.shiftKey) {
                        e.stopPropagation();
                        const zoomEvt = new WheelEvent("wheel", {
                            deltaY: e.deltaY * 3,
                            clientX: e.clientX,
                            clientY: e.clientY,
                            bubbles: true,
                        });
                        Object.defineProperty(zoomEvt, "_shinyhub", { value: true });
                        canvas.dispatchEvent(zoomEvt);
                    }
                },
                true
            );
        };

        const obs = new MutationObserver(() => {
            if (document.querySelector("canvas")) {
                hackZoom();
                obs.disconnect();
            }
        });
        obs.observe(document.documentElement, { childList: true, subtree: true });
    }

    // ─── Speed Click (attack spam) ──────────────────────────────
    let speedClickInterval = null;

    function toggleSpeedClick() {
        if (speedClickInterval) {
            clearInterval(speedClickInterval);
            speedClickInterval = null;
            return;
        }
        const canvas = document.querySelector("canvas");
        if (!canvas) return;

        speedClickInterval = setInterval(() => {
            if (!config.speedClick) {
                clearInterval(speedClickInterval);
                speedClickInterval = null;
                return;
            }
            const rect = canvas.getBoundingClientRect();
            const cx = rect.left + rect.width / 2;
            const cy = rect.top + rect.height / 2;
            for (let i = 0; i < 3; i++) {
                canvas.dispatchEvent(
                    new PointerEvent("pointerdown", { clientX: cx, clientY: cy, bubbles: true })
                );
                canvas.dispatchEvent(
                    new PointerEvent("pointerup", { clientX: cx, clientY: cy, bubbles: true })
                );
            }
        }, 50);
    }

    // ─── UI ─────────────────────────────────────────────────────
    function createUI() {
        const panel = document.createElement("div");
        panel.id = "shinyhub-panel";
        panel.innerHTML = `
        <style>
            #shinyhub-panel {
                position: fixed;
                top: 80px;
                right: 20px;
                width: 260px;
                background: rgba(10, 12, 20, 0.95);
                border: 1px solid rgba(130, 80, 255, 0.4);
                border-radius: 12px;
                color: #e0e0e0;
                font-family: 'Segoe UI', sans-serif;
                font-size: 13px;
                z-index: 999999;
                user-select: none;
                backdrop-filter: blur(10px);
                box-shadow: 0 0 20px rgba(130, 80, 255, 0.15);
                overflow: hidden;
            }
            #shinyhub-header {
                background: linear-gradient(135deg, rgba(130, 80, 255, 0.3), rgba(80, 40, 180, 0.3));
                padding: 10px 14px;
                font-size: 16px;
                font-weight: 700;
                cursor: move;
                display: flex;
                justify-content: space-between;
                align-items: center;
                border-bottom: 1px solid rgba(130, 80, 255, 0.2);
            }
            #shinyhub-header span { color: #a77bff; }
            #shinyhub-minimize {
                cursor: pointer;
                font-size: 18px;
                color: #888;
                transition: color 0.2s;
            }
            #shinyhub-minimize:hover { color: #fff; }
            #shinyhub-body { padding: 10px 14px; }
            .sh-toggle {
                display: flex;
                justify-content: space-between;
                align-items: center;
                padding: 7px 0;
                border-bottom: 1px solid rgba(255,255,255,0.05);
            }
            .sh-toggle:last-child { border-bottom: none; }
            .sh-toggle-label { font-size: 13px; }
            .sh-switch {
                width: 38px;
                height: 20px;
                background: #333;
                border-radius: 10px;
                position: relative;
                cursor: pointer;
                transition: background 0.2s;
            }
            .sh-switch.on { background: #8250ff; }
            .sh-switch::after {
                content: '';
                position: absolute;
                top: 2px;
                left: 2px;
                width: 16px;
                height: 16px;
                background: #fff;
                border-radius: 50%;
                transition: left 0.2s;
            }
            .sh-switch.on::after { left: 20px; }
            .sh-section {
                font-size: 11px;
                color: #8250ff;
                text-transform: uppercase;
                letter-spacing: 1px;
                padding: 10px 0 4px;
                font-weight: 600;
            }
            .sh-btn {
                width: 100%;
                padding: 8px;
                margin: 4px 0;
                background: rgba(130, 80, 255, 0.15);
                border: 1px solid rgba(130, 80, 255, 0.3);
                border-radius: 8px;
                color: #c9b0ff;
                cursor: pointer;
                font-size: 12px;
                transition: all 0.2s;
            }
            .sh-btn:hover {
                background: rgba(130, 80, 255, 0.3);
                color: #fff;
            }
            .sh-status {
                font-size: 11px;
                color: #666;
                padding: 6px 0;
                text-align: center;
            }
            .sh-status.connected { color: #4ade80; }
        </style>

        <div id="shinyhub-header">
            <span>ShinyHub</span> <span style="font-size:11px;color:#666">OpenFront</span>
            <div id="shinyhub-minimize">_</div>
        </div>
        <div id="shinyhub-body">
            <div class="sh-status" id="sh-ws-status">Waiting for game...</div>

            <div class="sh-section">Visuals</div>
            <div class="sh-toggle">
                <span class="sh-toggle-label">Zoom Hack (Ctrl+Scroll)</span>
                <div class="sh-switch on" data-key="zoomHack"></div>
            </div>

            <div class="sh-section">Automation</div>
            <div class="sh-toggle">
                <span class="sh-toggle-label">Speed Click</span>
                <div class="sh-switch" data-key="speedClick"></div>
            </div>

            <div class="sh-section">Hotkeys</div>
            <div style="font-size:11px;color:#777;padding:4px 0;">
                Ctrl+Scroll = Super Zoom<br>
                F6 = Toggle Panel
            </div>
        </div>
        `;
        document.body.appendChild(panel);

        // Dragging
        const header = panel.querySelector("#shinyhub-header");
        let dragging = false, dx = 0, dy = 0;
        header.addEventListener("mousedown", (e) => {
            if (e.target.id === "shinyhub-minimize") return;
            dragging = true;
            dx = e.clientX - panel.offsetLeft;
            dy = e.clientY - panel.offsetTop;
        });
        document.addEventListener("mousemove", (e) => {
            if (!dragging) return;
            panel.style.left = e.clientX - dx + "px";
            panel.style.right = "auto";
            panel.style.top = e.clientY - dy + "px";
        });
        document.addEventListener("mouseup", () => (dragging = false));

        // Minimize
        const body = panel.querySelector("#shinyhub-body");
        panel.querySelector("#shinyhub-minimize").addEventListener("click", () => {
            body.style.display = body.style.display === "none" ? "block" : "none";
        });

        // Toggles
        panel.querySelectorAll(".sh-switch").forEach((sw) => {
            sw.addEventListener("click", () => {
                const key = sw.dataset.key;
                config[key] = !config[key];
                sw.classList.toggle("on", config[key]);

                if (key === "speedClick") toggleSpeedClick();
            });
        });

        // WS status updater
        setInterval(() => {
            const el = document.getElementById("sh-ws-status");
            if (!el) return;
            if (gameWS && gameWS.readyState === WebSocket.OPEN) {
                el.textContent = "Connected to game";
                el.className = "sh-status connected";
            } else {
                el.textContent = "Waiting for game...";
                el.className = "sh-status";
            }
        }, 1000);

        // F6 toggle
        document.addEventListener("keydown", (e) => {
            if (e.key === "F6") {
                e.preventDefault();
                panel.style.display = panel.style.display === "none" ? "block" : "none";
            }
        });
    }

    // ─── Init ───────────────────────────────────────────────────
    if (document.readyState === "loading") {
        document.addEventListener("DOMContentLoaded", () => {
            createUI();
            applyZoomHack();
        });
    } else {
        createUI();
        applyZoomHack();
    }

    console.log("[ShinyHub] OpenFront hack loaded");
})();
