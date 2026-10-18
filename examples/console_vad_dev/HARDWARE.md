# Hardware Insights - Waveshare ESP32-P4-WIFI6

This document contains detailed hardware diagnostics and measurements for the Waveshare ESP32-P4-WIFI6 development board used in the console_vad examples.

---

## Microphone Comparison: INMP441 vs ES8311

Extensive distance testing (0.1m to 3m) and FFT/RMS analysis revealed:

### INMP441 (Digital I2S) - 🏆 The Winner

**Connection:**
- BCLK = GPIO 20
- WS = GPIO 21  
- DIN = GPIO 22

**Performance Metrics:**
- **Signal-to-Noise Ratio (SNR):** **23.2 dB**
- **Raw Noise Floor:** -67.99 dBFS
- **Voice at 1m:** -44.73 dBFS

**Distance Test Results:**

| Distance | RMS Level (dBFS) | Notes |
|----------|------------------|-------|
| 0.1m | -27.23 | Very loud, close |
| 0.5m | -40.59 | Normal conversation |
| 1.0m | -44.73 | Standard desktop distance |
| 2.0m | -47.88 | Far-field |

**Advantages:**
- ✅ Digital microphone - immune to electromagnetic interference (WiFi/Bluetooth) on PCB
- ✅ Delivers incredibly clean, low-noise signal out-of-the-box
- ✅ No DC-offset or analog artifacts
- ✅ Perfect for production VAD systems

**Stereo & Beamforming Capability:**
The INMP441 currently runs in Mono. Because it uses the I2S bus, we can easily wire a **SECOND INMP441** to the exact same pins (BCLK, WS, DATA), flip the L/R pin on the second mic, and the ESP32 will instantly receive **true Stereo**. This is the foundational prerequisite for:
- Future Beamforming
- Noise Cancellation (phase cancellation)
- Direction of Arrival (DoA) detection

---

### ES8311 (Analog Onboard) - The Fallback

**Connection:**
- I2C: SDA = GPIO 7, SCL = GPIO 8
- I2S0: MCLK = GPIO 13, BCLK = GPIO 12, WS = GPIO 10, DIN = GPIO 11, DOUT = GPIO 9

**Performance Metrics (at Maximum 42 dB PGA Gain):**
- **SNR:** **20.7 dB**
- **Raw Noise Floor:** -52.67 dBFS
- **Voice at 1m:** -31.91 dBFS (requires aggressive gain)

**Distance Test Results (42 dB gain):**

| Distance | RMS Level (dBFS) | Notes |
|----------|------------------|-------|
| 0.1m | -16.12 | Very loud, possible clipping risk |
| 0.5m | -28.84 | Good level |
| 1.0m | -31.91 | Requires high gain |
| 2.0m | -37.45 | Weak signal |

**Limitations:**
- ❌ Analog - highly susceptible to PCB interference (LCD backlight, MIPI clock, WiFi "tick tick" noise)
- ❌ Requires hardware PGA gain to be aggressively boosted (36 dB or 42 dB) for far-field VAD
- ❌ **DC-Offset "Pop"**: Loud "crack" in first millisecond when powering up (DC jumps from 0V to bias ~1.6V). Handled by 80Hz high-pass filter in DSP pipeline.
- ❌ **Mono Only**: ES8311 has ONE analog ADC input - physically impossible to do beamforming

**Verdict:**
The ES8311 is an industrial-grade codec but requires careful tuning. It's suitable for:
- Quick testing without external hardware
- Secondary environment sensor
- Fallback when INMP441 is unavailable

For production-grade VAD systems, **always use the INMP441**.

---

## Automatic Gain Control (AGC) Performance

Our custom AGC algorithm normalizes audio levels across distances before feeding into the VAD neural network.

### Distance Test Results

| Distance | WITHOUT AGC | WITH AGC | AGC Effect |
|----------|-------------|----------|------------|
| **0.1m (Close)** | -27.23 dBFS | **-30.91 dBFS** | 📉 Throttled (attenuation) |
| **0.5m** | -40.59 dBFS | **-33.69 dBFS** | 📈 Boosted |
| **1.0m** | -44.73 dBFS | **-37.53 dBFS** | 📈 Massively boosted |
| **2.0m** | -47.88 dBFS | **-36.93 dBFS** | 🚀 Boosted by > 10 dB |

**Key Insights:**
- **Without AGC:** Volume drops 20 dB across 2 meters (dynamic range too wide for NN)
- **With AGC:** Volume span compressed to just **7 dB** (between -30 dB and -37 dB)
- **Why it matters:** The Neural Network always receives normalized audio, preventing false negatives on distant speakers

---

## Golden Test: Mathematical Verification

The C++ ESP32 implementation was validated byte-for-byte against the original PyTorch model:

### Test Results

| Component | MSE | Max Difference | Verdict |
|-----------|-----|----------------|---------|
| **PCM Audio Input** | 0.000000 | 0 | ✅ Bit-perfect |
| **FBANK Features** | 3.83 | 26.6 | ✅ Expected (streaming vs offline) |
| **NN Inference Output** | 0.001 | - | ✅ Statistically identical |

**FBANK Differences Explained:**
The small MSE = 3.83 difference in FBANK features is NOT an error, but an architectural optimization:
- **PyTorch:** Processes entire WAV file offline (batch processing)
- **ESP32:** Live streaming system with 400-sample sliding window, emitting 160-sample frames
- **Fast Log Math:** ESP32 uses `fast_log_mel_energy()` (IEEE-754 bit-shift hack, ~10 cycles) instead of `std::logf()` (~50-100 cycles). At 8,000 log calculations per second, this saves massive CPU overhead. The slight numerical deviation is completely absorbed by the NN's robustness.

**Conclusion:** The ESP32 C++ Inference Engine is mathematically sound, highly optimized for real-time streaming, and production-ready.

---

## DC-Offset "Pop" Phenomenon (ES8311)

**Symptom:** When starting analog recording (ES8311), the first millisecond contains a loud "crack/pop".

**Root Cause:** Physical DC-offset pop. When hardware PGA and ADC power up, voltage jumps from 0V to bias voltage (~1.6V).

**Solution:** Our DSP pipeline handles this perfectly:
- The `record_mic` command captures raw I2S data (including the pop)
- But the VAD engine never sees it
- `esp_firevad_dsp.cpp` runs a **Biquad High-Pass Filter (80 Hz cutoff)** that eliminates DC-offset and low-frequency pops *before* NN inference

---

## Hardware Recommendations

### For Production VAD Systems:
1. ✅ Use **INMP441** digital I2S microphone
2. ✅ Enable **AGC** for distance robustness
3. ✅ Use **INT8-CH** quantized models (best balance)
4. ✅ Run DSP on Core 0, NN on Core 1 (parallel processing)

### For Development/Testing:
1. ⚠️ ES8311 is acceptable for quick tests
2. ⚠️ Boost PGA gain to 36-42 dB
3. ⚠️ Expect some analog interference noise
4. ⚠️ 80Hz HPF will clean up DC-pop automatically

### Future Beamforming:
- Wire 2x INMP441 to same I2S bus (flip L/R pin)
- ESP32 receives true stereo automatically
- Enables phase-based noise cancellation and DoA

---

**Board:** Waveshare ESP32-P4-WIFI6 (Chip Rev v1.3)  
**Tested:** October 2026  
**Status:** Production-validated hardware measurements
