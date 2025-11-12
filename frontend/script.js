class MazeRenderer {
  constructor(canvas) {
    this.canvas = canvas;
    this.ctx = canvas.getContext("2d");
    this.grid = null;
    this.cellSize = 12; // Cella méret px
    this.wallColor = "#222";
    this.pathColor = "#fff";
    this.padding = 2;
  }

  async loadFromApi(url) {
    const res = await fetch(url);
    if (!res.ok) {
      const err = await res.json().catch(() => ({ error: res.statusText }));
      throw new Error(err.error || res.statusText || "Hiba az API hívásban");
    }
    const data = await res.json();
    if (!data.grid) throw new Error("Rossz API válasz: nincs grid!");
    this.grid = data.grid;
    this.n = data.n;
    this.m = data.m;
    return data;
  }

  fitToCanvas(maxWidth = 800, maxHeight = 600) {
    if (!this.grid) return;
    const cw = this.grid[0].length;
    const ch = this.grid.length;
    const availableW = maxWidth - this.padding * 2;
    const availableH = maxHeight - this.padding * 2;
    const sizeW = Math.floor(availableW / cw);
    const sizeH = Math.floor(availableH / ch);
    this.cellSize = Math.max(1, Math.min(sizeW, sizeH));
    this.render();
  }

  render() {
    if (!this.grid) return;
    const rows = this.grid.length;
    const cols = this.grid[0].length;
    const w = cols * this.cellSize + this.padding * 2;
    const h = rows * this.cellSize + this.padding * 2;
    this.canvas.width = w;
    this.canvas.height = h;
    const ctx = this.ctx;
    // háttér
    ctx.fillStyle = this.wallColor;
    ctx.fillRect(0, 0, w, h);

    // cellák kirajzolása
    for (let r = 0; r < rows; r++) {
      for (let c = 0; c < cols; c++) {
        const val = this.grid[r][c];
        if (val === 1) {
          const x = this.padding + c * this.cellSize;
          const y = this.padding + r * this.cellSize;
          ctx.fillStyle = this.pathColor;
          ctx.fillRect(x, y, this.cellSize, this.cellSize);
        }
      }
    }
  }

  // segéd: grid szöveggé alakítása
  gridToText() {
    if (!this.grid) return "";
    return this.grid
      .map((row) => row.map((v) => (v ? " " : "#")).join(""))
      .join("\n");
  }
}

document.addEventListener("DOMContentLoaded", () => {
  const canvas = document.getElementById("canvas");
  const renderer = new MazeRenderer(canvas);
  const inpN = document.getElementById("inpN");
  const inpM = document.getElementById("inpM");
  const inpSeed = document.getElementById("inpSeed");
  const btnGen = document.getElementById("btnGen");
  const btnFit = document.getElementById("btnFit");
  const status = document.getElementById("status");

  async function generate() {
    try {
      status.textContent = "generálás...";
      const n = parseInt(inpN.value, 10);
      const m = parseInt(inpM.value, 10);
      if (n % 2 === 0 || m % 2 === 0) {
        alert("N és M páratlan értékűek kell legyenek!");
        status.textContent = "hiba: páros méret";
        return;
      }
      let url = `maze.php?n=${n}&m=${m}`;
      const seed = inpSeed.value.trim();
      if (seed !== "") url += `&seed=${encodeURIComponent(seed)}`;
      const data = await renderer.loadFromApi(url);

      renderer.fitToCanvas(
        Math.min(window.innerWidth - 40, 1200),
        Math.min(window.innerHeight - 160, 900)
      );
      status.textContent = `kész — ${data.n}×${data.m}`;
    } catch (e) {
      status.textContent = "hiba: " + e.message;
      console.error(e);
      alert("Hiba: " + e.message);
    }
  }

  btnGen.addEventListener("click", generate);
  btnFit.addEventListener("click", () => {
    renderer.fitToCanvas(
      Math.min(window.innerWidth - 40, 1200),
      Math.min(window.innerHeight - 160, 900)
    );
  });
  // 0. generalas
  generate();
});
