# FireRedVAD Console Example (ESP32-P4)

**Plug & Play Voice Activity Detection** - All AI models embedded in flash, no SD card required!

This interactive console (REPL) allows you to test FireRedVAD AI models on the **Waveshare ESP32-P4-WIFI6** board with live microphone input, tune parameters in real-time, and measure performance metrics.

---

## ⚡ Quick Start (3 Steps)

### 1️⃣ Build and Flash

```bash
idf.py set-target esp32p4
idf.py build flash monitor
```

The build system automatically embeds all 12 `.frvd` AI models (~13 MB) and 21 test WAV files (~5 MB) into a dedicated SPIFFS flash partition.

### 2️⃣ Load a Model

Once the console boots, load a streaming VAD model:

```bash
vad_model_load models_frvd/firered-stream-vad-int8.frvd
```

### 3️⃣ Test with Example Audio or Live Microphone

**Option A: Test with embedded WAV file**
```bash
vad_infer_wav example_wave/speech-mic-test.wav
```

**Option B: Test with live microphone**
```bash
vad_infer_mic 10
```

---

## 🎯 What's Inside?

All models and test audio files are pre-installed in the `/spiffs/` partition:

### Stream-VAD Models (Causal, Real-Time)
- `models_frvd/firered-stream-vad-fp32.frvd` - Highest accuracy
- `models_frvd/firered-stream-vad-int16.frvd` - Balanced
- `models_frvd/firered-stream-vad-int8.frvd` - **Recommended** (fast, accurate)
- `models_frvd/firered-stream-vad-int8-ch.frvd` - Per-channel quantization

### Offline-VAD Models (Non-Causal, Highest Accuracy)
- `models_frvd/firered-vad-fp32.frvd`
- `models_frvd/firered-vad-int16.frvd`
- `models_frvd/firered-vad-int8.frvd`
- `models_frvd/firered-vad-int8-ch.frvd`

### AED Models (Acoustic Event Detection)
- `models_frvd/firered-aed-fp32.frvd`
- `models_frvd/firered-aed-int16.frvd`
- `models_frvd/firered-aed-int8.frvd`
- `models_frvd/firered-aed-int8-ch.frvd`

### Test Audio Files (21 WAV files)
- `example_wave/speech-mic-test.wav` - Clean speech recording
- `example_wave/speech-welcome-*.wav` - Speech at different volumes
- `example_wave/music-rock.wav` - Music (should NOT trigger VAD)
- `example_wave/singing-vocal.wav` - Singing voice
- `example_wave/negative-birds.wav` - Nature sounds (negative test)
- `example_wave/noise-*.wav` - Various noise types (17 files)

To list all files:
```bash
ls
ls models_frvd
ls example_wave
```

---

## 🎤 Hardware Setup

### Required
- **ESP32-P4-WIFI6** Development Board (Waveshare)
- **USB-C Cable** (for power + serial console)

### Optional Microphones
The example supports two microphone options:

#### Option A: INMP441 Digital I2S Microphone (Recommended)
- **Pins:** BCLK=20, WS=21, DIN=22
- **Advantages:** No analog noise, better SNR
- **Select with:** `mic_select inmp441`

#### Option B: ES8311 Onboard Codec (Built-in)
- **Interface:** I2C + I2S0
- **Advantages:** No external wiring needed
- **Select with:** `mic_select es8311`

---

## 📋 Common Commands

### System & Files
| Command | Description |
|---------|-------------|
| `help` | Show all available commands |
| `ls` | List embedded models |
| `guide` | Quick start workflow |

### Model Management
| Command | Description |
|---------|-------------|
| `vad_model_load <file.frvd>` | Load a model from SPIFFS (e.g., `models_frvd/firered-stream-vad-int8.frvd`) |
| `vad_model_info` | Display loaded model info |
| `vad_metrics` | Show CPU cycle and latency timings |

### Microphone Control
| Command | Description |
|---------|-------------|
| `mic_select <inmp441\|es8311>` | Switch active microphone |
| `mic_level` | Measure room noise for 1 second |
| `mic_info` | Display current mic configuration |
| `agc_enable <0\|1>` | Enable/disable Automatic Gain Control |
| `agc_info` | Show AGC status and parameters |

### Voice Activity Detection
| Command | Description |
|---------|-------------|
| `vad_infer_mic [seconds]` | Run live VAD test (default: 10s) |
| `vad_infer_wav <file.wav>` | Run VAD on a WAV file (e.g., `example_wave/speech-mic-test.wav`) |
| `vad_threshold <0.0-1.0>` | Set speech detection threshold |
| `vad_calibrate [seconds]` | Recalibrate noise floor |

---

## 🔧 Typical Workflow

```bash
# 1. List available files
ls

# 2. Load the INT8 streaming model (recommended for real-time)
vad_model_load models_frvd/firered-stream-vad-int8.frvd

# 3. Test with an embedded audio file first
vad_infer_wav example_wave/speech-mic-test.wav

# 4. Check room noise level
mic_level

# 5. Enable Automatic Gain Control if environment is quiet
agc_enable 1

# 6. Run live VAD for 30 seconds
vad_infer_mic 30

# 7. Check performance metrics
vad_metrics

# 8. Try different noise scenarios
vad_infer_wav example_wave/noise-cafeteria.wav
vad_infer_wav example_wave/music-rock.wav
```

---

## 🚨 Important Notes

### Boot Calibration
When the ESP32 boots, it performs a **1-second background noise calibration** to configure internal noise gates.

**You must remain completely silent** when this message appears:
```
PLEASE BE SILENT - CALIBRATING MICROPHONE...
```

After calibration completes, the system will play a "System Ready" chime.

### Model Selection Guide
- **For live streaming:** Use `models_frvd/firered-stream-vad-int8.frvd` (causal)
- **For offline analysis:** Use `models_frvd/firered-vad-int8.frvd` (non-causal, higher accuracy)
- **For acoustic events:** Use `models_frvd/firered-aed-int8.frvd` (screams, sirens, etc.)

### Test Audio Files
The 21 embedded WAV files cover diverse scenarios:
- **Speech samples:** Clean recordings at various volumes
- **Negative tests:** Music, singing, bird sounds (should NOT trigger VAD)
- **Noise scenarios:** Cafeteria, office, server fans, white noise, etc.

### Real-Time Performance
The INT8 models are optimized for the ESP32-P4's dual-core RISC-V @ 360MHz with PIE SIMD acceleration. Expected latency: **~2-3ms per 10ms frame** (20-30% real-time load).

---

## 📦 Prerequisites

- **ESP-IDF v6.0+** (required for proper ESP32-P4 multi-core routing and SPIFFS)
- **Python 3.8+** (for build tools)
- **Waveshare ESP32-P4-WIFI6** Development Board

---

## 🧪 Advanced Features

### Power Management & Sleep Mode
Test ultra-low-power VAD with duty-cycling:
```bash
vad_sleep_mode 500
```
This wakes up every 500ms to check for speech, then returns to light sleep.

### Cascade Detection (Dual-Core)
Load two models simultaneously for gatekeeper architecture:
```bash
vad_cascade_load models_frvd/firered-stream-vad-int8.frvd models_frvd/firered-aed-int8.frvd
```

---

## 🐛 Troubleshooting

### "Failed to mount SPIFFS"
- Make sure you flashed the **entire project** including partition table:
  ```bash
  idf.py flash
  ```
- Check that `partitions.csv` includes the `models` partition

### "No such file or directory"
- Models are in `models_frvd/` subdirectory
- Test audio is in `example_wave/` subdirectory
- Use: `vad_model_load models_frvd/firered-stream-vad-int8.frvd`
- Use: `vad_infer_wav example_wave/speech-mic-test.wav`

### Microphone Not Working
- Verify pin connections for INMP441 (BCLK=20, WS=21, DIN=22)
- Try the onboard ES8311: `mic_select es8311`
- Check `mic_level` to see if audio is being captured

---

## 📖 Further Reading

- **ESP32-P4 Datasheet:** [Espressif Docs](https://www.espressif.com/en/products/socs/esp32-p4)
- **FireRedVAD Architecture:** See `/docs/ENGINEERING_INSIGHTS.md`
- **Development Version:** For SD card support and advanced debugging, see `examples/console_vad_dev/`

---

## 🎁 What Makes This Example Special?

✅ **Zero Configuration** - Flash and run, no file transfers  
✅ **12 Models + 21 Test Audio Files** - Test all quantization levels and scenarios  
✅ **Production-Ready** - Same architecture as battery-powered voice assistants  
✅ **Professional Code** - Clean, documented, and maintainable  
✅ **Diverse Test Cases** - Speech, music, noise, negative samples included  

---

**Ready to build voice-activated devices?** Start experimenting! 🎤🔥
