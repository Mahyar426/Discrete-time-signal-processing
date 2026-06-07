<div align="center">

![header](https://readme-typing-svg.demolab.com?font=Fira+Code&size=26&pause=1000&color=F7C59F&center=true&vCenter=true&width=800&lines=🎛️+Digital+Signal+Processing;Sampling.+Aliasing.+Butterworth+Filters.;Coefficient+quantization+—+made+audible.)

```
██████╗ ███████╗██████╗
██╔══██╗██╔════╝██╔══██╗
██║  ██║███████╗██████╔╝
██║  ██║╚════██║██╔═══╝
██████╔╝███████║██║
╚═════╝ ╚══════╝╚═╝
   nyquist · butterworth · sos · quantization
```

![MATLAB](https://img.shields.io/badge/MATLAB-R2020a-orange?style=flat-square&logo=mathworks)
![Domain](https://img.shields.io/badge/Domain-Signal%20Processing-blue?style=flat-square)
![Topics](https://img.shields.io/badge/Topics-Filtering%20%7C%20Sampling%20%7C%20Quantization-F7C59F?style=flat-square)

</div>

---

Hands-on MATLAB exploration of core DSP concepts — from sampling theory verified *audibly* through a sound card, to a quantization sensitivity study that shows exactly why cascaded biquad filters dominate production embedded systems. Every result here is observable, not just simulated on paper.

---

## Chirp Sampling & Aliasing — Nyquist Made Audible

A linear chirp sweeping **0 → 4000 Hz over 16 seconds** was generated analytically and sampled at six rates, then played back through the system sound card — turning the Nyquist theorem into something you can hear:

| Sampling Rate | Nyquist Margin | Audible Result |
|--------------|---------------|----------------|
| 30,000 Hz | 3.75× | ✅ Smooth rising pitch |
| 20,000 Hz | 2.5× | ✅ Clean |
| 10,000 Hz | 1.25× | ✅ Clean |
| 8,000 Hz | 1.0× (limit) | ✅ Clean |
| **4,000 Hz** | **0.5× — aliased** | ❌ Signal repeats **twice** |
| **2,000 Hz** | **0.25× — aliased** | ❌ Signal repeats **four times** |

The repetition pattern is exact: each time Fs is halved below the Nyquist limit, the perceived repetition rate doubles — a clean, audible confirmation of spectral folding.

A real-time **oscilloscope simulation** (`q5.m`) renders the chirp frame-by-frame through a sliding 0.25s window using `drawnow`, letting you watch instantaneous frequency climb in real time.

---

## Butterworth Filter Design & Audio Noise Removal

A **6th-order Butterworth band-stop filter** eliminates a tonal noise spike embedded in `a2.wav`:

```matlab
w1 = 1/4;   dw = 1/20;
[b1, a1] = butter(6, [w1-dw, w1+dw], 'stop');
```

The filter carves a precise notch at ω = π/4 rad/sample. All poles sit inside the unit circle — unconditionally stable. Passing the noisy audio through `filter()` removes the artifact entirely, verified both by listening and by comparing time-domain waveforms before and after.

---

## Coefficient Quantization — A Study in Numerical Sensitivity

**The core question: how many bits do filter coefficients actually need?**

Coefficients were rounded to n significant figures and output quality was evaluated audibly and spectrally at each level.

### Direct-Form II (12th-order, monolithic)

| Significant Figures | Result |
|--------------------|--------|
| 6 | ❌ Filter completely fails |
| 8 | ⚠️ Partial noise reduction |
| 10 | ⚠️ Faint residual noise |
| **12** | ✅ **Clean output** |

With 12 significant figures, coefficients span `[10¹¹, 10¹²)`, requiring ~37–41 bits of precision. A high-order direct-form filter is numerically fragile: tiny perturbations shift pole/zero locations enough to collapse the notch entirely.

**A subtler finding:** quantization artifacts appear in the frequency response — phase discontinuities, a widened notch — *before* they become audible. The spectrum is a more sensitive diagnostic than your ears.

### Cascaded 2nd-Order Sections (SOS) — Same Filter, Radically Less Sensitive

The 12th-order filter was decomposed into **six independent biquads**, each quantized separately:

| Implementation | Significant Figures Needed | Approx. Bits |
|----------------|--------------------------|--------------|
| Direct-Form II (12th order) | 12 | ~37–41 |
| **Cascaded Biquads (SOS)** | **4** | **~13–14** |

**3× fewer bits for identical audio quality.** This is precisely why SOS decomposition is the standard in every production embedded DSP and audio codec implementation.

---

## Repository Structure

```
├── q4.m   # Chirp sampling at 6 rates — Nyquist theorem made audible
├── q5.m   # Real-time oscilloscope simulation of chirp
└── c1.m   # 12th-order Butterworth + quantization analysis + SOS cascade
```

---

## Skills Demonstrated

- Discrete-time system analysis (poles, zeros, stability, frequency response)
- IIR filter design and implementation from scratch in MATLAB
- Nyquist–Shannon sampling theorem — theoretical and perceptual verification
- Fixed-point arithmetic sensitivity and coefficient quantization analysis
- Cascaded biquad (SOS) decomposition for numerically robust filter implementation
- Real-time signal visualization with animated MATLAB plots
