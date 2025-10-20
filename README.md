# Audio-Reactive Visuals (Processing + Minim)

This interactive Audio Visual designed by Naz Sevinc

An interactive **audio-reactive visualization** built with [Processing (P3D)](https://processing.org/) and the [Minim](http://code.compartmental.net/minim/) audio library.  
The sketch has two main visual modes:

- **2D kinetic canvas** — reactive trails, frames, tunnels, and grids  
- **3D Earth scene** — a rotating globe with lighting, line bands, mosaic patches, and more

All visuals respond to **bass (20–150 Hz)** and **treble (4–8 kHz)** frequencies from a playing audio track.

---

## Requirements

- [Processing 4.x](https://processing.org/download) with `P3D` renderer  
- [Minim audio library](http://code.compartmental.net/minim/)  
  - In Processing: `Sketch → Import Library… → Add Library…` → search **“Minim”** → Install

---

## Setup

1. Create a new Processing sketch and paste the provided code into `sketch.pde`.
2. Create a `data/` folder next to your sketch (Processing does this automatically if you drag files into the editor).
3. Add the following files to the `data/` folder:
   - `ayva.mp3` — the audio file that will loop
   - `earth.jpg` — a **2:1 equirectangular** Earth texture (e.g., 4096×2048)

Then run the sketch. It will open in full-screen mode at 60 FPS.

> 💡 **Tip:** Use a high-quality, correctly proportioned Earth map to avoid stretching or seams.

---

## How It Works

- **Audio + FFT**: Minim plays `ayva.mp3` and an `FFT` analyzes the audio every frame.  
  - **Bass** and **treble** are averaged and mapped to visual properties such as motion, scaling, spawning, and animation intensity.
- **Modes**:
  - **2D Canvas**: Dynamic trails, reactive squares and circles, diagonal grid sweeps, center-to-target tunnels, and more.
  - **3D World**: A textured globe with optional spin, breathing scale, rotating light, horizontal stripe with progressive lines, a square tunnel background, and a front-layer mosaic.

---

##� Controls

### Global
| Key | Action |
|-----|--------|
| `P` | Toggle between **2D** and **World** mode |

### World Page
| Key | Action |
|-----|--------|
| `A` | Toggle globe spin (World mode) |
| `S` | Toggle globe breathing (scale pulsation) |
| `D` | Toggle directional light |
| `F` | **Hold**: Rotate directional light |
| `O` | Toggle white background |
| `I` | Toggle center horizontal stripe |
| `M` | Toggle progressive line bands (requires `I`) |
| `K` | Toggle square "KTunnel" background |
| `L` | **Hold**: Show Earth mosaic (only when globe is **not spinning**) |

### 2D Canvas
| Key | Action |
|-----|--------|
| `1` | **Hold**: Small reactive square frame |
| `2` | (Same as `1` – currently mapped identically) |
| `3` | **Hold**: Large square frame + connecting lines |
| `4` | **Hold**: Filled reactive shapes (overlay) |
| `5` | **Hold**: Hide small filled square & circle |
| `6` | **Hold**: Diagonal grid sweep |
| `7` | **Hold**: Center-to-target tunnel |
| `8` | **Hold**: Background color flash |

---

## Adjustable Parameters

| Variable | Description |
|----------|-------------|
| `iBassStart/End`, `iTrebleStart/End` | FFT frequency bands |
| `step6` | Grid density |
| `layers7`, `speed7` | Tunnel depth & speed |
| `worldAngle`, `lightSpeed` | Rotation & light speed |
| `worldScale` | Pulse intensity |
| `mGap`, `mStep` | Line spacing & animation speed |
| `kLayers`, `kGap`, `kSpeed` | KTunnel density & speed |
| `lRate`, `lLife` | Mosaic spawn rate & lifespan |

---

## Performance Tips

- Use a reasonably sized `earth.jpg` texture to save GPU memory.
- Reduce geometry complexity:
  - Lower `sphereDetail(60)` (try `30–40`).
  - Reduce `kLayers` in `drawKTunnel()`.
- Limit mosaic spawn rate (`lRate`) or reduce patch sizes.

---

## Troubleshooting

- **No sound / FFT inactive**:  
  - Ensure `ayva.mp3` is in the `data/` folder.  
  - Verify Minim is installed and audio output is available.
- **Earth looks distorted**:  
  - Check that the texture is **2:1 equirectangular**.
- **Low FPS**:  
  - Reduce texture size, `sphereDetail`, or animation layers.

---

## Quick Customization Ideas

- Replace `ayva.mp3` with any other track.
- Use different Earth maps (e.g., night lights, political, Blue Marble).
- Tweak `pulseWorld` mapping for more dramatic breathing effects.
- Experiment with grid and tunnel speed for different visual rhythms.

---

## Licensing

Use only audio and texture assets that you have the rights to distribute.  
If you share this project publicly, credit the original sources of any third-party media.

---

## Acknowledgements

- Built with [Processing](https://processing.org/)  
- Audio processing powered by [Minim](http://code.compartmental.net/minim/)  
- Inspired by audio-reactive visual art and generative design techniques

---

 **Enjoy exploring audio-reactive worlds!**
