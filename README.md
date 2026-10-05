# BRIDGES: Decarbonizing Industrial Process Heat in California

BRIDGES is a sector-coupled gas–electricity energy system planning model. It co-optimizes investment and operation of the electricity and gas systems to find the least-cost pathway for an energy transition across multiple investment periods. This repository contains the California implementation used in:

> D. M. Saad, J. A. Dowling, M. Sodwatana, S. J. Davis, I. M. Azevedo, and A. R. Brandt, "The Role of Electrified Heating and Carbon Management Systems in Decarbonizing Industrial Process Heat," submitted to *Nature Communications*, 2026.

The model represents a net-zero California by 2045.

This repository is the specific version of the BRIDGES model used for the Saad et al. paper above. It is derived from the main BRIDGES California repository, <https://github.com/Stanford-EAO/BRIDGES_for_CA>. To reproduce the results in the paper, use the code in this repository.

The model is written in Julia and formulated with JuMP, using Gurobi as the optimization solver.

---

## 1. System requirements

### Software dependencies

| Software | Version | Notes |
|---|---|---|
| Julia | 1.12.6 | Version tested |
| Gurobi Optimizer | 13.0.3 | Commercial solver; a license is required (free academic licenses are available, see below) |
| JuMP.jl | 1.31.2 | Optimization modeling |
| Gurobi.jl | 1.9.3 | Julia interface to Gurobi |
| DataFrames.jl | 1.8.2 | |
| CSV.jl | 0.10.17 | |
| Clustering.jl | 0.15.8 | Used to select representative days |
| Distances.jl | 0.10.12 | |
| Tables.jl | 1.14.0 | |
| Grisu.jl | 1.0.2 | |
| PlotlyJS.jl | 0.18.18 | Plotting |
| PlotlyBase.jl | 0.8.23 | Plotting |
| DelimitedFiles | 1.9.1 | Julia standard library |
| Dates, Random | 1.11.0 | Julia standard library |

### Operating systems

The model has been tested on:
- Linux (x86_64), on Stanford's Sherlock high-performance computing cluster
- macOS 26.6.2 on Apple M2

### Hardware

No non-standard hardware is required. However, full model runs are computationally intensive:

- **Full runs (as in the manuscript):** run on Stanford's Sherlock high-performance computing cluster, typically using 32-core AMD EPYC 7502 processors and 50–100 GB of RAM. A full run with 10 representative days and five investment periods takes approximately 2–3 hours.
- **Demo run (see Section 3):** can be run on a standard desktop or laptop (tested on an Apple M2 with 16 GB of RAM).

---

## 2. Installation guide

### Step 1: Install Julia

Download and install Julia from <https://julialang.org/downloads/>. The recommended method is `juliaup`:

```bash
# macOS / Linux
curl -fsSL https://install.julialang.org | sh

# Windows (PowerShell)
winget install julia -s msstore
```

Verify the installation:

```bash
julia --version
```

### Step 2: Install Gurobi and obtain a license

1. Download Gurobi Optimizer 13.0.3 (or a compatible 13.x release) from <https://www.gurobi.com/downloads/>.
2. Obtain a license. Free academic licenses are available at <https://www.gurobi.com/academia/academic-program-and-licenses/>.
3. Activate the license with `grbgetkey <your-license-key>`.
4. Make sure the `GUROBI_HOME` environment variable points to your Gurobi installation.

### Step 3: Get the code

```bash
git clone https://github.com/dimitrisaad/BRIDGES_industrial-heat.git
cd BRIDGES_industrial-heat
```

### Step 4: Install the Julia packages

Start Julia from the repository folder and run:

```julia
using Pkg
Pkg.add([
    Pkg.PackageSpec(name="JuMP",          version="1.31.2"),
    Pkg.PackageSpec(name="Gurobi",        version="1.9.3"),
    Pkg.PackageSpec(name="DataFrames",    version="1.8.2"),
    Pkg.PackageSpec(name="CSV",           version="0.10.17"),
    Pkg.PackageSpec(name="Clustering",    version="0.15.8"),
    Pkg.PackageSpec(name="Distances",     version="0.10.12"),
    Pkg.PackageSpec(name="Tables",        version="1.14.0"),
    Pkg.PackageSpec(name="Grisu",         version="1.0.2"),
    Pkg.PackageSpec(name="PlotlyJS",      version="0.18.18"),
    Pkg.PackageSpec(name="PlotlyBase",    version="0.8.23"),
    Pkg.PackageSpec(name="DelimitedFiles")
])
Pkg.build("Gurobi")
```

Check that Gurobi is working:

```julia
using JuMP, Gurobi
model = Model(Gurobi.Optimizer)
```

### Typical install time

About 5–10 minutes on a normal desktop computer for Julia and the required packages, plus a few minutes to install Gurobi and activate its license.

---

## 3. Demo

No separate demo dataset is needed. All input data is provided in the `Data/` folder, and a shortened version of the full model can be run on a normal desktop computer.

### Running the demo

1. Open the parameters file, `core/Parameters/parameters_default.jl`.
2. Change the number of investment periods from the default of 5 to 1:

   ```julia
   T_inv = 1   # default: 5
   ```

   With `T_inv = 5`, the model optimizes across five investment periods (2025, 2030, 2035, 2040, 2045). Setting `T_inv = 1` solves only the first investment period (2025). This greatly reduces the problem size while exercising the full model workflow: data loading, clustering of representative days, model construction, optimization and output writing.

3. From the repository folder, run:

   ```bash
   julia run_file.jl
   ```

### Expected output

At the end of the run, `core/data_exports.jl` exports the results to a new, uniquely named folder inside `Outputs/` (the `Outputs/` folder is created automatically if it does not already exist). Each run writes to its own folder, so results from earlier runs are not overwritten.

### Expected run time

- About 10 minutes on an HPC node (Sherlock cluster, see Section 1)
- About 30–60 minutes on an Apple M2 with 16 GB of RAM

---

## 4. Instructions for use

### Repository structure

```
BRIDGES_industrial-heat/
├── run_file.jl              # Main entry point; runs the model
├── my_job.script            # SLURM job script for HPC runs
├── core/
│   ├── Parameters/
│   │   └── parameters_default.jl  # Scenario settings and model parameters
│   ├── clustering.jl        # Clusters hourly input data into representative days
│   ├── data_exports.jl      # Exports results; runs at the end of run_file.jl
│   └── ...                  # Other core model files
├── Data/                    # All input data
└── Outputs/                 # Created on first run; one folder per run
```

### Input data

All input data is provided in the `Data/` folder and falls into three groups:

- **Hourly time-series data**, clustered into representative days by `core/clustering.jl` to keep the optimization tractable. These include baseline electricity and gas demands (`BaselineElectricDemandsNetworkCold.csv`, `BaselineGasDemandsNetworkCold.csv`), appliance load profiles (`ApplianceProfiles_*.csv`), industrial electricity, gas and heat demand profiles (`IndustrialProfiles_*.csv`), variable renewable generation profiles (`HourlyVRENetworkCold.csv`) and natural gas prices (`NatgasPrice_*.csv`).
- **Technology and network data** describing energy technologies and infrastructure by zone. These include generators (`GeneratorsNetwork.csv`), electricity, gas and heat storage (`Storage_*.csv`), power-to-gas and power-to-heat technologies (`PowerToGasNetwork.csv`, `PowerToHeatNetwork.csv`), end-use appliances (`EndUseAppliancesNetwork.csv`), electricity and gas transmission networks (`ElecTransmissionNetwork.csv`, `GasTransmissionNetwork.csv`), and cost data (`CAPEXLookup.csv`, `FOMLookup.csv`, `VOMLookup.csv`, `FuelCostLookUp.csv`, `CostScenarios*.csv`).
- **Industrial and carbon management data**, including industrial facilities (`IndustrialFacilitiesNetwork.csv`), industrial heat demand and process emissions trajectories (`IndustrialHeatDemandActivity_*.csv`, `IndustrialProcessEmissionsActivity_*.csv`, `IndustrialProcessEmissionsNetwork.csv`), matching of industrial emissions to carbon capture (`IndustrialCCSMatching.csv`, `IndustrialEmissionsCCSBreakdownEmissions.csv`) and carbon dioxide removal (`CarbonDioxideRemoval.csv`).

To run the model with your own data, replace or edit the files in `Data/` while keeping the same file names, column structure and zone definitions.

### Scenarios and parameters

Scenarios and model parameters are set in `parameters_default.jl`. Key parameters include:

| Parameter | Default | Description |
|---|---|---|
| `T_inv` | 5 | Number of investment periods (2025–2045 in 5-year steps) |
| `N_Periods` | 10 | Number of representative days from clustering |
| `heatElectrification_ON` | 1 | Allows electrified heating technologies for industrial process heat (1 = on, 0 = off) |
| `DACCS4industrialHeat_ON` | 1 | Allows carbon management systems for industrial process heat (1 = on, 0 = off) |

The default settings correspond to the **baseline scenario** in the manuscript: a least-cost, net-zero California energy system by 2045, with electrified heating and carbon management systems allowed.

### Running on a local machine

```bash
julia run_file.jl
```

### Running on an HPC cluster (SLURM)

The full model was run on Stanford's Sherlock cluster. The requested resources are specified in `my_job.script`; adjust these for your cluster, then submit:

```bash
sbatch my_job.script
```

This runs the scenario currently set in `parameters_default.jl` and optimizes the least-cost energy system across all investment periods (2025, 2030, 2035, 2040, 2045).

---

## 5. Reproduction instructions

To reproduce the quantitative results in the manuscript:

1. **Baseline scenario:** run the model with the default `parameters_default.jl` (`T_inv = 5`, `N_Periods = 10`, `heatElectrification_ON = 1`, `DACCS4industrialHeat_ON = 1`). Both electrified heating and carbon management systems are allowed. Expected run time is approximately 2–3 hours on a 32-core node with 50–100 GB of RAM.
2. **Other scenarios:** change the following switches in `parameters_default.jl` and rerun the model:
   - **Electrified heating scenario:** set `DACCS4industrialHeat_ON = 0` (carbon management systems for industrial heat not allowed).
   - **Carbon management scenario:** set `heatElectrification_ON = 0` (electrified heating not allowed).
3. **Exporting results:** `core/data_exports.jl` runs automatically at the end of `run_file.jl` and exports all the files used to reproduce the results in the manuscript, saving them in a unique folder for each run inside `Outputs/`.

---

## License

No license has been specified for this code.

---

## Citation

If you use this model, please cite the manuscript above and the following earlier publications describing BRIDGES:

- G. Von Wald, K. Sundar, E. Sherwin, A. Zlotnik, and A. Brandt, "Optimal gas-electric energy system decarbonization planning," *Advances in Applied Energy*, vol. 6, 2022. [doi:10.1016/j.adapen.2022.100086](https://doi.org/10.1016/j.adapen.2022.100086)
- D. M. Saad, M. Sodwatana, E. D. Sherwin, and A. R. Brandt, "Energy storage in combined gas-electric energy transitions models: The case of California," *Applied Energy*, vol. 385, 2025. [doi:10.1016/j.apenergy.2025.125480](https://doi.org/10.1016/j.apenergy.2025.125480)
- M. Sodwatana, D. M. Saad, M. Ahumada-Paras, and A. R. Brandt, "Appliance decarbonization and its impacts on California's energy transition," *Applied Energy*, vol. 390, 2025. [doi:10.1016/j.apenergy.2025.125769](https://doi.org/10.1016/j.apenergy.2025.125769)
- M. J. Aljubran, D. M. Saad, M. Sodwatana, A. R. Brandt, and R. N. Horne, "The value of enhanced geothermal systems for the energy transition in California," *Sustainable Energy & Fuels*, vol. 9, 2025. [doi:10.1039/D4SE01520G](https://doi.org/10.1039/D4SE01520G)
- D. M. Saad, M. Ahumada-Paras, M. Sodwatana, and A. R. Brandt, "Impact of multi-sector carbon tax for achieving deep decarbonization," in *2025 IEEE Power & Energy Society General Meeting (PESGM)*, 2025. [doi:10.1109/PESGM52009.2025.11224977](https://doi.org/10.1109/PESGM52009.2025.11224977)


## Contact

Dimitri M. Saad: dimi3@stanford.edu or dimi3@alumni.stanford.edu
