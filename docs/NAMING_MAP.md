# Naming Map

The public package uses descriptive MATLAB names while preserving the original computation logic.

| Original file | Public file | Category |
| --- | --- | --- |
| `TGA_readData.m` | `utilities/ReadTGA.m` | Utility |
| `TGA_readPulseSimple.m` | `utilities/ReadPulseData.m` | Utility |
| `TGA_calcConversion.m` | `src/CalculateConversion.m` | Model preprocessing |
| `TGA_extractIsothermal.m` | `src/ExtractIsothermalSegment.m` | Model preprocessing |
| `TGA_synergyAnalysis.m` | `src/AnalyzeSynergy.m` | Model analysis |
| `TGA_fitRPM.m` | `fitting/FitRPM.m` | Fitting |
| `TGA_arrhenius.m` | `fitting/ArrheniusAnalysis.m` | Fitting |
| `TGA_predictPulse.m` | `simulation/SimulatePulse.m` | Simulation |
| `TGA_validatePulse.m` | `simulation/ValidatePulsePrediction.m` | Validation |
| `TGA_main.m` | `examples/RunSingleTGAExample.m` | Example |
| `TGA_batch.m` | `examples/RunBatchFitting.m` | Example |
| `TGA_synergy_pulse_main.m` | `examples/RunSynergyPulseSimulation.m` | Example |
| `TGA_pulse_validation_main.m` | `examples/RunPulseValidationExample.m` | Example |

