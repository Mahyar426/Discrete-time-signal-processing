# Discrete-Time Signal Processing — Lab Assignments
**Isfahan University of Technology · Spring 2020**
*Course: Discrete-Time Signal Processing*

> Hands-on MATLAB implementations covering sampling theory, digital filtering, coefficient quantization, and cascaded filter design. Each exercise connects theory to audible, measurable results.

---

## Repository Structure

```
├── q4.m          # Chirp signal sampling & aliasing demo
├── q5.m          # Real-time oscilloscope simulation
├── c1.m          # Butterworth filter: noise removal & cascade implementation
├── a2.wav        # Noisy audio file used for filtering experiments
└── a1.jpg        # Sample oscilloscope output screenshot
```

---

## Exercise 2 — Chirp Signal Sampling & Aliasing

### What is a Chirp Signal?
A chirp is a sinusoidal signal whose instantaneous frequency varies linearly with time. The general form for a **linear chirp** is:

$$x(t) = \cos\left[\phi_0 + 2\pi\left(\frac{c}{2}t^2 + f_0 t\right)\right]$$

where:
- $f_0$ = starting frequency
- $f_1$ = ending frequency
- $c = (f_1 - f_0)/T$ = chirp rate (Hz/s)
- $T$ = sweep duration

Chirp signals are widely used in radar, sonar, and spread-spectrum communications.

### Experiment Parameters
| Parameter | Value |
|-----------|-------|
| Duration | 16 seconds |
| Start frequency $f_0$ | 0 Hz |
| End frequency $f_1$ | 4000 Hz |
| Chirp rate $c$ | 250 Hz/s |

### Part 1 — Playback at Different Sampling Rates (`q4.m`)

The chirp was sampled at six different rates and played back through the system sound card, demonstrating the **Nyquist–Shannon sampling theorem** in practice:

| # | Sampling Rate (Hz) | Result |
|---|-------------------|--------|
| 1 | 30,000 | ✅ Clean playback, pitch rises smoothly over 16 s |
| 2 | 20,000 | ✅ Clean — well above Nyquist (8 kHz) |
| 3 | 10,000 | ✅ Clean — just above Nyquist |
| 4 | 8,000 | ✅ Clean — right at Nyquist limit |
| 5 | 4,000 | ❌ **Aliasing** — signal repeats twice; frequency components fold back |
| 6 | 2,000 | ❌ **Severe aliasing** — signal repeats four times |

**Key observation:** Since the chirp reaches 4000 Hz, the Nyquist criterion requires $F_s > 8000$ Hz. Below this threshold, high-frequency components alias into lower frequencies, making the signal appear periodic — exactly as predicted by theory.

### Part 2 — Oscilloscope Simulation (`q5.m`)

A sliding time-window loop renders the chirp incrementally, simulating a real oscilloscope display. Each frame shows a 0.25 s window that advances by a small step, then `drawnow` flushes the plot.

```matlab
for i = 0:160
    t = (i*n) : 0.0001 : (i*n) + 0.25;   % sliding window
    y = cos(phi + 2*pi*((c/2).*t.^2 + f1.*t));
    plot(t, y, 'r');
    ylim([-1 1]); grid on;
    drawnow; pause(0.25);
end
```

**Trade-off found experimentally:** a larger step makes the animation jerky; a smaller step slows rendering because more samples must be plotted per frame. The values chosen (step = 0.005 s, window = 0.25 s) balanced smoothness against execution time.

![Oscilloscope output](a1.jpg)

---

## Exercise 3 — Digital Filtering & Coefficient Quantization (`c1.m`)

### Filter Design

A **6th-order Butterworth band-stop filter** was designed to remove a tonal noise component from `a2.wav`:

```matlab
w1 = 1/4;    % normalized center frequency (= Fs/4)
dw = 1/20;   % half-bandwidth
[b1, a1] = butter(6, [w1-dw, w1+dw], 'stop');
```

The filter attenuates a narrow band around $\omega = \pi/4$ rad/sample, leaving the rest of the audio intact.

### Part A — Zero-Pole Diagram
Zeros and poles of the designed filter plotted with `zplane`. All poles lie inside the unit circle → the filter is **stable**.

### Part B — Frequency Response
Plotted with `freqz`. The magnitude response shows a deep notch (~180 dB attenuation) at the target frequency with a smooth passband on both sides.

### Part C–D — Noise Removal
Passing `a2.wav` through the filter removed a high-pitched, screeching periodic noise completely. Time-domain comparison of a 1000-sample segment shows the input waveform dominated by the tonal noise and the output reduced to the underlying audio content.

---

## Coefficient Quantization Study

A central question in fixed-point DSP implementation: **how many significant digits (bits) do filter coefficients need?**

### Direct-Form II (Single High-Order Filter)

Coefficients were rounded to $n$ significant figures using MATLAB's `round(..., n, 'significant')` and the filtered output was evaluated audibly and visually.

| Significant Figures | Approx. Bits | Audible Result |
|--------------------|-------------|----------------|
| 6 | ~20 | ❌ No recognizable audio |
| 7 | ~23 | ❌ Filter fails |
| 8 | ~27 | ⚠️ Noise partially removed |
| 10 | ~33 | ⚠️ Faint residual noise (audible with headphones) |
| **12** | **~37–41** | **✅ Clean output, noise fully removed** |

**Why so many bits?** High-order filters implemented in direct form are numerically sensitive — small perturbations in coefficients shift pole/zero locations significantly. With 12 significant figures, numbers lie in the range $[10^{11}, 10^{12})$, requiring approximately **37–41 bits** of integer precision (ignoring scale).

Interestingly, the quantization effect is clearly visible in the frequency response **before** it becomes audible: the phase plot develops discontinuities and the magnitude notch broadens at 10 significant figures, even when the output sounds acceptable.

### Cascaded 2nd-Order Sections (SOS)

The 12th-order filter was factored into **six 2nd-order sections (biquads)**:

```matlab
z = roots(b1);  p = roots(a1);

for i = 1:6
    b_cascade(i,:) = poly(z(2*i-1 : 2*i));
    a_cascade(i,:) = poly(p(2*i-1 : 2*i));
    % quantize each section independently
end
```

The total filter is recovered by convolving all section coefficients:

$$H(z) = \prod_{k=1}^{6} H_k(z) \quad \Longleftrightarrow \quad \mathbf{b} = \mathbf{b}_1 * \mathbf{b}_2 * \cdots * \mathbf{b}_6$$

**Result:** The cascaded implementation achieved clean noise removal with only **4 significant figures** per section, compared to 12 required for the monolithic direct-form filter. This demonstrates why SOS decomposition is the standard practice in production DSP systems — each low-order section is far less sensitive to coefficient rounding.

| Implementation | Min. Significant Figures for Clean Output |
|----------------|------------------------------------------|
| Direct-Form II (12th order) | 12 (~37–41 bits) |
| Cascaded 2nd-Order Sections | 4 (~13–14 bits) |

---

## Key Takeaways

- The Nyquist criterion is not merely theoretical — aliasing is immediately audible and predictable: halving $F_s$ below the signal bandwidth doubles the apparent repetition rate.
- Direct-form high-order IIR filters are numerically fragile. Coefficient sensitivity grows rapidly with filter order.
- Cascaded biquad (SOS) implementations are dramatically more robust to quantization — a result that holds in both simulation and on real fixed-point hardware.
- Quantization artifacts appear in the **frequency domain** (distorted phase, broadened notch) before they become perceptible **audibly** — making spectral analysis a more sensitive diagnostic than listening alone.

---

## Tools

- **MATLAB** — signal generation, filtering, spectral analysis, visualization
- **Sound card** — D/A conversion for perceptual evaluation of sampling and filtering effects
