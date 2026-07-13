# MATLAB Call Graph

This diagram shows the public workflow in `Random-Pore-Model`. The `archive/` folder is not part of the main call graph.

```mermaid
flowchart TD
    startup["startup.m<br/>Add project folders to MATLAB path"]

    subgraph Examples["examples/"]
        single["RunSingleTGAExample.m"]
        batch["RunBatchFitting.m"]
        synergyRun["RunSynergyPulseSimulation.m"]
        pulseValRun["RunPulseValidationExample.m"]
    end

    subgraph Utilities["utilities/"]
        readTGA["ReadTGA.m"]
        readPulse["ReadPulseData.m"]
        style["PaperStyle.m"]
        format["ApplyFigureFormat.m"]
        exportFig["ExportFigure.m"]
        exportExcel["ExportExcel.m"]
    end

    subgraph Core["src/"]
        conv["CalculateConversion.m"]
        iso["ExtractIsothermalSegment.m"]
        synergy["AnalyzeSynergy.m"]
    end

    subgraph Fitting["fitting/"]
        fit["FitRPM.m"]
        arr["ArrheniusAnalysis.m"]
    end

    subgraph Simulation["simulation/"]
        pulse["SimulatePulse.m"]
        validate["ValidatePulsePrediction.m"]
    end

    subgraph Figures["figures/"]
        plotCore["PlotCoreResults.m"]
        plotBatch["PlotBatchComparison.m"]
        plotSynPulse["PlotSynergyAndPulse.m"]
        plotPulseVal["PlotPulseValidation.m"]
    end

    startup --> single
    startup --> batch
    startup --> synergyRun
    startup --> pulseValRun

    single --> readTGA
    single --> conv
    single --> iso
    single --> fit
    single --> plotCore

    batch --> readTGA
    batch --> conv
    batch --> iso
    batch --> fit
    batch --> arr
    batch --> plotBatch
    batch --> exportExcel

    synergyRun --> readTGA
    synergyRun --> conv
    synergyRun --> iso
    synergyRun --> fit
    synergyRun --> synergy
    synergyRun --> pulse
    synergyRun --> plotSynPulse

    pulseValRun --> readTGA
    pulseValRun --> readPulse
    pulseValRun --> conv
    pulseValRun --> iso
    pulseValRun --> fit
    pulseValRun --> synergy
    pulseValRun --> validate
    pulseValRun --> plotPulseVal

    validate --> pulse

    plotCore --> style
    plotCore --> format
    plotCore --> exportFig

    plotBatch --> style
    plotBatch --> format
    plotBatch --> exportFig

    plotSynPulse --> style
    plotSynPulse --> format
    plotSynPulse --> exportFig

    plotPulseVal --> style
    plotPulseVal --> format
    plotPulseVal --> exportFig

    arr --> style
    arr --> format
    arr --> exportFig

    format --> style
    exportFig --> style
```

## Main Workflow Summary

```text
ReadTGA
  -> CalculateConversion
  -> ExtractIsothermalSegment
  -> FitRPM
  -> PlotCoreResults / PlotBatchComparison
```

```text
CO2 RPM + H2O RPM + mixed-atmosphere data
  -> AnalyzeSynergy
  -> SimulatePulse
  -> PlotSynergyAndPulse
```

```text
Pulse experimental data
  -> ReadPulseData
  -> ValidatePulsePrediction
  -> PlotPulseValidation
```

