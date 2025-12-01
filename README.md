# W-Discrete Neutrino System — v4
Complete, reproducible discretization of neutrino mass levels in the W-Structure framework.

## Overview
This repository provides a full reproducible brute-force search for discrete neutrino masses in the W-Structure framework. Each neutrino mass is assumed to have the discrete form:

m_nu = mp / ( 2^s * p * q )

where mp is the proton mass in eV, and p, q, s are integers (p>=1, q>=1, s>=0). The goal is to find minimal-complexity integer triples (p,q,s) that reproduce experimental neutrino masses with maximal accuracy.

## Experimental targets (Normal hierarchy)
nu2 = 0.0086 eV  
nu3 = 0.0500 eV  
Delta_m2 = 2.426040e-3 eV^2  
Proton mass mp = 938272088.16 eV

## Search ranges
p: 1..200  
q: 1..200  
s: 0..40

These limits are sufficient for complete system-level enumeration.

## Scoring
rel_error = |m_calc - m_target| / m_target  
complexity = s + log10(p) + log10(q)  
score = rel_error * 1e6 + complexity  
(Accuracy dominates; complexity resolves degeneracies.)

## Results (v4)

### Best match for nu2
p=153, q=170, s=22  
mass = 0.00860059585 eV  
relative error = 6.93e-5  
complexity = 26.4151

### Best match for nu3
p=157, q=114, s=20  
mass = 0.04999474759 eV  
relative error = 1.05e-4  
complexity = 24.2528

These are the smallest-complexity integer triples reproducing both masses with experimental-level precision.

## System-level optimum
nu2: (p=153, q=170, s=22)  
nu3: (p=157, q=114, s=20)  

Both solutions together form the minimal joint-complexity configuration for the system.

## Included files
W_neutrino_system_best_v4.csv  
W_neutrino_system_top10_v4.csv  
W_neutrino_nu2_top10_v4.csv  
W_neutrino_nu3_top10_v4.csv  
W_neutrino_search_v4.ps1 (full reproducible script)

## Reproducing the search
Run in PowerShell:

powershell -ExecutionPolicy Bypass -File .\W_neutrino_search_v4.ps1
## Verification Hash (SHA-256)

W-Discrete-Neutrino-System-v4.zip  
SHA-256: 7febbc56d47f07674ccce16f01426a65200d60ef0427ec88acff42176f2f184a


## Author
Hrachya Danielyan
