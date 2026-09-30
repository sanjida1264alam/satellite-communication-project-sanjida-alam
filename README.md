# Satellite Communication Link Simulation — Sanjida Alam

MATLAB implementation of a simplified GEO satellite communication link for the Satellite Communications-2 course.

## Student

**Sanjida Alam**

## Project contents

The MATLAB script includes:

- GEO satellite link-budget calculation
- Free-space path loss (FSPL)
- EIRP
- Received power
- Thermal noise power
- C/N
- C/N0
- Eb/N0
- Link margin using the stated 10 dB design-reference assumption
- Theoretical BER for BPSK, QPSK and 16-QAM
- Monte-Carlo BER simulation
- Combined BER comparison
- BER-based link-margin calculation using BER = 10^-5
- Transmit-power sensitivity for 2, 5, 10, 20 and 40 W
- Additional-loss sensitivity for 0, 2, 5, 8, 10, 12 and 15 dB
- Effect of 3 dB additional loss
- Effect of doubling transmit power
- Enhanced constellation analysis

## Constellation analysis

The enhanced constellation section creates **three separate figures**, each containing three plots:

1. BPSK — Ideal, Light AWGN, Heavy AWGN
2. QPSK — Ideal, Light AWGN, Heavy AWGN
3. 16-QAM — Ideal, Light AWGN, Heavy AWGN

This gives **9 constellation plots in total**.

The Light AWGN condition uses the project's baseline Eb/N0. The Heavy AWGN condition uses 6 dB as a visualization condition to make the effect of noise clear.

## How to run

Open `satellite_communication_project_Sanjida_Alam.m` in MATLAB or MATLAB Online and click **Run**.

The script uses standard MATLAB functions for the implemented calculations and simulations.

## Main parameters

- Frequency: 12 GHz
- GEO distance: 36,000 km
- Transmit power: 10 W
- Transmit antenna gain: 40 dBi
- Receive antenna gain: 45 dBi
- Transmitter loss: 2 dB
- Receiver loss: 2 dB
- Other loss: 2 dB
- System noise temperature: 500 K
- Bit rate: 10 Mbps

## Report connection

The script supports the numerical results and figures presented in the accompanying academic report, including the link budget, BER analysis, sensitivity studies and constellation analysis.

## Author

Sanjida Alam
