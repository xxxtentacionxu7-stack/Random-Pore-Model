# MATLAB File Classification

## Main Public Workflow

| File | Role | Keep status |
| --- | --- | --- |
| `src/CalculateConversion.m` | Calculates conversion and derivative signals from TGA mass data. | Keep |
| `src/ExtractIsothermalSegment.m` | Extracts isothermal reaction segment and resets reaction time. | Keep |
| `src/AnalyzeSynergy.m` | Computes CO2/H2O synergy factor from mixed-atmosphere rates. | Keep |
| `fitting/FitRPM.m` | Fits RPM parameters `k` and `psi`. | Keep |
| `fitting/ArrheniusAnalysis.m` | Performs Arrhenius analysis from fitted RPM results. | Keep |
| `simulation/SimulatePulse.m` | Simulates pulsed H2O/CO2 gasification using RPM and synergy factor. | Keep |
| `simulation/ValidatePulsePrediction.m` | Compares measured pulsed data with simulated prediction. | Keep |
| `utilities/ReadTGA.m` | Reads three-column TGA files. | Keep |
| `utilities/ReadPulseData.m` | Reads two-column pulse data files. | Keep |
| `utilities/PaperStyle.m` | Defines common plotting style. | Keep |
| `utilities/ApplyFigureFormat.m` | Applies figure and axes formatting. | Keep |
| `utilities/ExportFigure.m` | Exports MATLAB figures. | Keep |
| `utilities/ExportExcel.m` | Exports fitted results to Excel. | Keep, but optional for public demos |
| `figures/PlotCoreResults.m` | Plots TGA, DTG, RPM fit, and psi scan results. | Keep |
| `figures/PlotBatchComparison.m` | Plots multi-temperature comparison figures. | Keep |
| `figures/PlotSynergyAndPulse.m` | Plots synergy factor and pulse prediction figures. | Keep |
| `figures/PlotPulseValidation.m` | Plots pulse validation and residuals. | Keep |

## Examples

| File | Role | Keep status |
| --- | --- | --- |
| `examples/RunSingleTGAExample.m` | Single-file TGA/RPM workflow. | Keep |
| `examples/RunBatchFitting.m` | Multi-temperature batch RPM fitting workflow. | Keep |
| `examples/RunSynergyPulseSimulation.m` | Synergy analysis and pulse simulation workflow. | Keep |
| `examples/RunPulseValidationExample.m` | Pulse model validation workflow. | Keep |

## Archive

| File | Reason archived |
| --- | --- |
| `archive/data_specific/RunNoTemperatureRPMFit.m` | Uses a private absolute Excel path and data-specific column layout. |
| `archive/legacy_analysis/Compare850900RpmParameters.m` | Specialized comparison script for selected temperatures. |
| `archive/legacy_plotting/PlotPaperTgComparison.m` | Specific paper-figure plotting script. |
| `archive/legacy_plotting/Plot900RpmFit.m` | Specific 900 C plotting script. |
| `archive/legacy_plotting/Plot900AtmosphereComparison.m` | Specific 900 C atmosphere comparison script. |
| `archive/chapter3_workflow/*.m` | Thesis/chapter figure workflow retained for traceability; experimental source data are omitted. |
| `archive/rsm/PlotDesignExpertRSM.m` | RSM/Design-Expert plotting helper, outside the core RPM package. |

## Excluded From Public Package

The following file types are intentionally excluded from the public-ready package:

- `*.txt`, `*.csv`, `*.xlsx`, `*.xls`, `*.mat`
- generated images and figure binaries
- generated reports and large presentation outputs
- MATLAB autosave files such as `*.asv`

