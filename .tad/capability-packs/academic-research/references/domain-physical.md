# Physical Sciences Domain Judgment Rules

Extracted from ScienceClaw physical science, engineering, and materials skills.
Rules with specific thresholds, parameters, and numeric standards only.

---

## 1. Molecular Dynamics Setup

**R-PHY-001: Force Field Selection by System**
| System | Force field | Water model |
|---|---|---|
| Standard proteins | AMBER14 (`amber14-all.xml`) | TIP3P-FB |
| Proteins + small molecules | AMBER14 + GAFF2 | TIP3P-FB |
| Membrane proteins | CHARMM36m | TIP3P |
| Nucleic acids | AMBER99-bsc1 or AMBER14 | TIP3P |
| Disordered proteins | ff19SB or CHARMM36m | TIP3P |

> Source: skills/molecular-dynamics/SKILL.md

**R-PHY-002: MD Simulation Parameters**
- Timestep: 2 fs with HBonds constraints (standard); 4 fs with hydrogen mass repartitioning (HMR)
- Electrostatics: PME (Particle Mesh Ewald) for solvated systems — more accurate than cutoff
- Nonbonded cutoff: 1.0 nm
- Ewald error tolerance: 0.0005
- Solvent padding: 10 Angstroms
- Ionic strength: 0.15 M NaCl (physiological)

> Source: skills/molecular-dynamics/SKILL.md

**R-PHY-003: Equilibration Protocol**
- Phase 1 — Energy minimization: max 1000 iterations, tolerance 10 kJ/mol/nm
- Phase 2 — NVT equilibration: 50,000-100,000 steps (100-200 ps at 2 fs/step)
- Phase 3 — NPT equilibration: 100-500 ps
- Phase 4 — NPT production: application-dependent (1 ns = 500,000 steps at 2 fs)
- Barostat: Monte Carlo, update frequency 25 steps
- Temperature: Langevin integrator at 300 K, friction 1/ps
- MUST always minimize before MD (raw PDB structures have steric clashes)

> Source: skills/molecular-dynamics/SKILL.md

**R-PHY-004: Trajectory Analysis Rules**
- Discard first 20-50% of trajectory as equilibration
- RMSD: compute on backbone atoms after alignment to reference frame
- RMSF: compute per-residue to identify flexible regions
- Contact analysis: default cutoff 4.5 Angstroms for protein-ligand contacts
- Save checkpoints: MD runs can fail; checkpoints allow restart
- GPU acceleration: 10-100x speedup over CPU (CUDA > OpenCL > CPU fallback order)

> Source: skills/molecular-dynamics/SKILL.md

**R-PHY-005: PDB Preparation (PDBFixer)**
- Fix missing residues and atoms
- Replace nonstandard residues
- Remove heterogens (water/ligands) as needed
- Add hydrogens at target pH (default 7.0)
- Verify structure before simulation

> Source: skills/molecular-dynamics/SKILL.md

---

## 2. Materials Science

**R-PHY-010: Thermodynamic Stability Threshold**
- Energy above convex hull (Ehull): < 25 meV/atom typical threshold for stability
- Formation energy: negative values indicate thermodynamic stability
- Phonon stability: check for imaginary frequencies (dynamic instability flag)
- Aqueous stability: Pourbaix diagram analysis for electrochemical applications

> Source: skills/materials-screening/SKILL.md

**R-PHY-011: Photovoltaic Material Screening**
- Band gap range: 1.0-1.8 eV
- Direct gap preferred over indirect
- Low effective mass desirable
- These filters are application-specific — define filter chain before screening

> Source: skills/materials-screening/SKILL.md

**R-PHY-012: Materials Database Priority**
- Materials Project: computed DFT properties (primary)
- AFLOW: automatic materials discovery
- ICSD: experimental crystal structures
- NIST Materials Data: experimental property measurements
- Springer Materials: curated multi-source data
- Always compare computational vs. experimental values when both available

> Source: skills/materials-science/SKILL.md

**R-PHY-013: Crystal Structure Reporting**
- Space group and crystal system
- Lattice parameters in Angstroms
- Wyckoff positions for atoms
- Density computation
- Temperature and pressure conditions for all properties
- Appropriate DFT functional and basis set must be noted

> Source: skills/materials-science/SKILL.md

**R-PHY-014: Phase Diagram Analysis**
- Identify: stable phases, invariant reactions (eutectic, peritectic), solid solutions
- Use CALPHAD method for complex systems (Thermo-Calc, FactSage)
- Include metastable phases if relevant
- Label: temperature and composition axes, phase boundaries

> Source: skills/materials-science/SKILL.md

**R-PHY-015: Characterization Technique Selection**
| Property | Technique | Key output |
|---|---|---|
| Crystal structure | XRD | 2-theta peaks with hkl indices |
| Microstructure | SEM / TEM | Grain size, morphology |
| Surface chemistry | XPS | Binding energies, composition |
| Thermal transitions | DSC | Glass transition, melting point |
| Mechanical properties | Nanoindentation | Hardness, elastic modulus |

> Source: skills/materials-science/SKILL.md

**R-PHY-016: Materials Screening Ranking**
- Multi-criteria: weighted scoring with normalized property values
- Pareto front analysis for multi-objective screening
- Sensitivity analysis on weight choices to assess robustness
- Cross-reference with ICSD for synthesis precedent
- Apply cost and toxicity filters for practical applications

> Source: skills/materials-screening/SKILL.md

---

## 3. Signal Processing

**R-PHY-020: Nyquist Criterion**
- Sampling rate must satisfy: fs > 2 * fmax
- Violation causes aliasing (irreversible frequency folding)
- Anti-aliasing filter before ADC is mandatory in hardware

> Source: skills/signal-processing/SKILL.md

**R-PHY-021: Spectral Analysis Protocol**
- Remove DC offset (mean subtraction) before FFT
- Apply windowing function to reduce spectral leakage: Hann, Hamming, or Blackman
- Zero-padding for frequency resolution improvement
- PSD estimation: Welch's method (noise reduction) or periodogram (snapshot)
- Identify dominant frequencies and harmonics

> Source: skills/signal-processing/SKILL.md

**R-PHY-022: Filter Design Rules**
- FIR: linear phase (important when phase matters), higher order, Parks-McClellan design
- IIR: lower order (more efficient), nonlinear phase, bilinear transform design
- IIR stability check: all poles must be inside unit circle
- Specify: passband/stopband frequencies, ripple, attenuation
- Verify: frequency response, phase response, group delay meet specifications

> Source: skills/signal-processing/SKILL.md

**R-PHY-023: Time-Frequency Analysis Selection**
- Non-stationary signals: STFT (spectrogram) with window size trade-off
- Wavelet analysis: CWT for frequency analysis, DWT for decomposition/compression
- Mother wavelet selection: Morlet for frequency resolution, Daubechies for transients

> Source: skills/signal-processing/SKILL.md

**R-PHY-024: Denoising Methods**
- White noise: spectral subtraction, Wiener filter
- Transient noise: wavelet thresholding (soft or hard)
- Adaptive noise: LMS or RLS adaptive filtering
- Always quantify: SNR improvement in dB (before and after)

> Source: skills/signal-processing/SKILL.md

---

## 4. Energy Systems

**R-PHY-030: Solar Resource Assessment**
- Data: GHI (Global Horizontal Irradiance), DNI, DHI
- Use TMY (Typical Meteorological Year) or site-specific measurements
- Account for: degradation, soiling, inverter losses, wiring losses, curtailment
- Capacity factor: annual/monthly, energy yield in kWh/kWp
- System losses must be itemized separately

> Source: skills/energy-systems/SKILL.md

**R-PHY-031: Wind Resource Assessment**
- Wind speed distributions: Weibull distribution
- Compute power curves for selected turbine
- Assess turbulence intensity
- Site-specific measurement preferred over reanalysis data

> Source: skills/energy-systems/SKILL.md

**R-PHY-032: Battery Storage Characterization**
- Energy density: Wh/kg
- Power density: W/kg
- Round-trip efficiency: %
- Cycle life: number of cycles to 80% capacity
- Calendar life: years
- Self-discharge rate: %/month
- Degradation and replacement costs in economics

> Source: skills/energy-systems/SKILL.md

**R-PHY-033: Economic Analysis (LCOE)**
- LCOE formula: (capital + O&M + fuel) / lifetime_energy, discounted
- Must specify: discount rate, capital costs, O&M, fuel costs, lifetime
- Include incentives: ITC, PTC, feed-in tariffs
- Report: NPV, IRR, payback period
- Sensitivity analysis on: resource, cost, discount rate
- Distinguish kW (power) vs. kWh (energy), AC vs. DC

> Source: skills/energy-systems/SKILL.md

**R-PHY-034: Climate Scenario Standards**
- Use RCP/SSP pathways for climate projections
- Emission factors: source and year must be specified
- Carbon accounting: tCO2e (tonnes CO2 equivalent)
- Lifecycle emissions: cradle-to-gate analysis

> Source: skills/energy-systems/SKILL.md

---

## 5. Environmental Science

**R-PHY-040: Trend Analysis Methods**
- Non-parametric trend: Mann-Kendall test
- Non-parametric slope: Sen's slope estimator
- Separate seasonal/cyclical patterns from long-term trends
- Baseline period must be defined for anomaly calculations
- Uncertainty: confidence intervals or ensemble spread

> Source: skills/environmental-science/SKILL.md

**R-PHY-041: Environmental Metrics and Thresholds**
- Air quality: AQI (Air Quality Index), compare against EPA NAAQS and WHO guidelines
- Water quality: WQI (Water Quality Index)
- Carbon: tCO2e (tonnes CO2 equivalent)
- Biodiversity: Shannon index, Simpson index
- Species distribution: MaxEnt or random forest models

> Source: skills/environmental-science/SKILL.md

**R-PHY-042: Mapping Standards**
- Use appropriate projection for geographic extent
- Diverging colormaps for anomalies (deviation from baseline)
- Show rates not raw counts when population varies
- Color scales must include legends
- Data source, spatial resolution, temporal coverage documented

> Source: skills/environmental-science/SKILL.md

---

## 6. Physics and Chemistry Computation

**R-PHY-050: Physical Constants (scipy.constants)**
- Speed of light: `c = 299792458 m/s`
- Planck's constant: `h = 6.626e-34 J*s`
- Boltzmann constant: `k_B = 1.381e-23 J/K`
- Elementary charge: `e = 1.602e-19 C`
- Avogadro's number: `N_A = 6.022e23 /mol`
- Always carry units through calculations; check dimensional consistency

> Source: skills/physics-solver/SKILL.md

**R-PHY-051: Physics Problem-Solving Protocol**
1. Identify physical system and relevant principles
2. Draw/describe diagram
3. List knowns and unknowns
4. Choose appropriate equations/laws
5. Solve symbolically first (SymPy), then substitute numbers
6. Check units, limiting cases, and order of magnitude
7. Interpret result physically

> Source: skills/physics-solver/SKILL.md

**R-PHY-052: Spectroscopy Reference Ranges (IR)**
| Bond | Wavenumber range |
|---|---|
| O-H stretch | 3200-3600 cm-1 (broad) |
| N-H stretch | 3300-3500 cm-1 |
| C-H stretch | 2850-3000 cm-1 |
| C=O stretch | 1650-1750 cm-1 |
| C=C stretch | 1600-1680 cm-1 |
| C-O stretch | 1000-1300 cm-1 |

> Source: skills/chemistry-tools/SKILL.md

**R-PHY-053: Thermodynamic Equations**
- Ideal gas: PV = nRT (R = 8.314 J/(mol*K))
- Gibbs free energy: dG = dH - T*dS
- Nernst equation: E = E0 - (RT/nF)*ln(Q), F = 96485 C/mol
- Arrhenius: k = A * exp(-Ea/RT)
- Carnot efficiency: eta = 1 - T_cold/T_hot

> Source: skills/chemistry-tools/SKILL.md, skills/physics-solver/SKILL.md

**R-PHY-054: Quantum Mechanics Reference**
- Hydrogen energy levels: E(n) = -13.6/n^2 eV
- de Broglie wavelength: lambda = h/p
- Heisenberg uncertainty: dx * dp >= hbar/2
- Particle in box: E(n) = n^2*h^2 / (8*m*L^2)

> Source: skills/physics-solver/SKILL.md

---

## 7. Computational Method Selection

**R-PHY-060: Numerical Integration**
- ODE integration: `scipy.integrate.solve_ivp` with appropriate max_step
- Symbolic math: SymPy for derivations before numerical computation
- DFT calculations: specify functional and basis set
- MD simulations: OpenMM (GPU), GROMACS, or NAMD

> Source: skills/physics-solver/SKILL.md, skills/molecular-dynamics/SKILL.md

**R-PHY-061: DPI for Scientific Figures by Output**
- Notebook/screen: 72-100 DPI
- Web: 150 DPI
- Print/publications: 300 DPI
- Use `bbox_inches='tight'` to remove excess whitespace
- For large datasets: `rasterized=True` to reduce file size

> Source: skills/molecular-dynamics/SKILL.md

---

## 8. Chemical Database Access

**R-PHY-070: Public API Endpoints**
| Database | Content | Access pattern |
|---|---|---|
| PubChem | 100M+ compounds | REST API: `/rest/pug/compound/name/{name}/JSON` |
| ChEMBL | Bioactivity data | Free API |
| PDB | 200K+ protein structures | Free API |
| ZINC | Purchasable compounds | Download |
| Materials Project | Inorganic materials | Free API (MP-API) |
| NIST WebBook | Thermodynamic data | Web lookup for verification |

> Source: skills/chemistry-tools/SKILL.md, skills/chemistry/SKILL.md
