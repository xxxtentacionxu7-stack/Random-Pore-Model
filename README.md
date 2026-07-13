# Random Pore Model for Pulsed Gasification

## Project Overview

This repository contains MATLAB code for thermogravimetric analysis (TGA), random pore model (RPM) fitting, CO2/H2O synergy analysis, and pulsed gasification simulation.

The repository is organized as a research code portfolio. Experimental datasets are intentionally omitted.

## Research Background

The project studies biomass char gasification behavior under CO2, H2O, and mixed atmospheres. The workflow uses TGA data to calculate conversion, fit RPM kinetic parameters, analyze gasification synergy, and simulate pulsed H2O/CO2 operation.

## Workflow

1. Read TGA data.
2. Calculate conversion and derivative signals.
3. Extract the isothermal reaction segment.
4. Fit RPM parameters.
5. Analyze CO2/H2O synergy.
6. Simulate and validate pulsed gasification.
7. Generate publication-style plots.

## Folder Structure

```text
Random-Pore-Model/
├── src/          Core conversion, isothermal extraction, and synergy logic
├── fitting/      RPM fitting and Arrhenius analysis
├── simulation/   Pulsed gasification simulation and validation
├── utilities/    Data readers, exporters, and figure style helpers
├── examples/     Example scripts showing how to run the workflow
├── figures/      Plotting functions; no experimental figures are included
├── docs/         Project notes, file classification, and data policy
├── archive/      Legacy, data-specific, and chapter-figure scripts
├── startup.m     MATLAB path setup
├── README.md
└── LICENSE
```

## How to Run

Open MATLAB, enter the repository root, and run:

```matlab
cd('path/to/Random-Pore-Model')
startup
```

Example workflows are in `examples/`. They require user-provided experimental data files with the expected column formats. Data files are not included in this public repository.

```matlab
RunSingleTGAExample
RunBatchFitting
RunSynergyPulseSimulation
RunPulseValidationExample
```

## Future Work

- Add a small synthetic example dataset for demonstration.
- Add unit tests for input validation and workflow smoke tests.
- Add selected portfolio figures after publication/data-sharing review.
- Convert selected scripts into reusable functions with documented inputs.

## License

This project currently uses the MIT License for code. Experimental data are not included.

