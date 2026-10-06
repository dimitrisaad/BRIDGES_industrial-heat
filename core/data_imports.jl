################################################################################
# Baseline Energy Demands
################################################################################
# Import the baseline electrical demands [MWh/hr] across all system nodes
D_Elec2 = CSV.read("$(foldername)/BaselineElectricDemands$(system)$(region).csv",DataFrame)

NODES_ELEC = length(D_Elec2[1,:])       # Number of electrical nodes is specified based on the number of columns in D_Elec2
# Set up a new array to hold electrical demand info.
D_Elec = zeros(8760,NODES_ELEC)         
for n = 1:NODES_ELEC
    D_Elec[:,n] = baselineElecDemand_multiplier*D_Elec2[:,n]
end

# Import the baseline gas demands [MWh/hr] across all system nodes
D_Gas2 = CSV.read("$(foldername)/BaselineGasDemands$(system)$(region).csv",DataFrame)

NODES_GAS = length(D_Gas2[1,:])         # Number of gas nodes is specified based on the number of columns in D_Gas2
# Set up a new array to hold gas demand info.
D_Gas = zeros(8760,NODES_GAS)
for n = 1:NODES_GAS
    D_Gas[:,n] = baselinegasdemand_multiplier*D_Gas2[:,n]
end

# Names/Numbers of nodes to facilitate look-ups
REGIONS_ELEC = String.(names(D_Elec2))
REGIONS_GAS = String.(names(D_Gas2))

# Maximum fossil gas supply at the boundary/slack node
MAXSLACK = zeros(1,NODES_GAS)   # Set slack supply to zero everywhere except for the boundary node
MAXSLACK[SLACK_NODE] = SLACK_GAS    # [MW] (Arbitrarily large, but not so large as to trigger numerical issues in optimization)
MAXSLACK[ADDITIONAL_SLACK_NODE] = SLACK_GAS    # additional gas supply at non slack node


################################################################################
# Industrial facility demands
################################################################################
IndustrialFacilities = CSV.read("$(foldername)/IndustrialFacilities$(system).csv",DataFrame)
INDUSTRIAL = length(IndustrialFacilities[:, :1])        # Number of industrial facility "services" modeled
#
IndustrialServices = IndustrialFacilities."Service Type"                     # End-use services satisfied by each industrial facility class
PrimeMover_INDUSTRIAL = IndustrialFacilities."Prime Mover"                   # "Fuel" used for each industrial class
InitialIndustrialPopulation = IndustrialFacilities."Existing Units"          # Initial industrial unit/facility population [no. units]
IndustrialPeakDemand = IndustrialFacilities."Peak Heat Demand [MW]"          # Peak demand of a given industrial service
IndustrialSectorCode = IndustrialFacilities."NAICS Code"                     # NAICS code pertaining to each unit
IndustrialSectorName = IndustrialFacilities."Sector Name"                    # Sector name of the associated NAICS code
IndustrialEnduse = IndustrialFacilities."End-use"                            # End-use of a given unit
IndustrialTemperature = IndustrialFacilities."Temperature"                   # Temperature, in celsius, of heat demand
IndustrialLifetime = IndustrialFacilities."Lifetime [years]"                 # Expected facility/unit lifetime [years]
IndustrialProcessType = IndustrialFacilities."Process Type"                  # Industrial unit process type; for now only conventional
# toggle for industrial heat
IndustrialPeakDemand = IndustrialPeakDemand * industrialHeat_ON



## Create a matrix that maps each industrial unit to the energy service that it satisfies
################################################################################
numIndustrialSERVICES = length(unique(IndustrialServices))
industrialServiceList = unique(IndustrialServices)           # List of all industrial services (i.e. sectorCode + enduse + temperature)
#
IndustrialToServices = zeros(INDUSTRIAL,numIndustrialSERVICES)
# For each industrial unit, a, put a 1 in the column corresponding to its energy service
for a = 1:INDUSTRIAL
    IndustrialToServices[a,findfirst(occursin.([(IndustrialServices[a])],industrialServiceList))] = 1
end


## Industrial unit level energy demand profiles (hourly)
# In MWh/hr per unit, for each hour in a typical year; then must be clustered down
################################################################################
# here we have 3 types of demand: direct heat, gas, and electricity
IndustrialProfilesGAS2  = CSV.read("$(foldername)/IndustrialProfiles_GAS"  * profile_case * ".csv",DataFrame)
IndustrialProfilesELEC2 = CSV.read("$(foldername)/IndustrialProfiles_ELEC" * profile_case * ".csv",DataFrame)
IndustrialProfilesHEAT2 = CSV.read("$(foldername)/IndustrialProfiles_HEAT" * profile_case * ".csv",DataFrame)

IndustrialProfilesGAS  = zeros(HOURS_PER_YEAR,length(IndustrialProfilesGAS2[1,:]))
IndustrialProfilesELEC = zeros(HOURS_PER_YEAR,length(IndustrialProfilesELEC2[1,:]))
IndustrialProfilesHEAT = zeros(HOURS_PER_YEAR,length(IndustrialProfilesHEAT2[1,:]))
# Rounded to avoid introducing numerical issues
for i = 1:length(IndustrialProfilesGAS2[1,:])
    # set to zero if we decide not to model industry like appliances
    IndustrialProfilesGAS[:,i]  = round.(IndustrialProfilesGAS2[:,i], digits = 8)  * modelIndustryLikeAppliances_ON
    IndustrialProfilesELEC[:,i] = round.(IndustrialProfilesELEC2[:,i], digits = 8) * modelIndustryLikeAppliances_ON
    IndustrialProfilesHEAT[:,i] = round.(IndustrialProfilesHEAT2[:,i], digits = 8) * modelIndustryLikeAppliances_ON
end

INDUSTRIAL_NodalLoc_ELEC = zeros(NODES_ELEC, INDUSTRIAL)
INDUSTRIAL_NodalLoc_GAS  = zeros(NODES_GAS, INDUSTRIAL)

Loc_ELEC = IndustrialFacilities[:,1]
Loc_GAS = IndustrialFacilities[:,2]
for a = 1:INDUSTRIAL
    INDUSTRIAL_NodalLoc_ELEC[findfirst(occursin.([string(Loc_ELEC[a])],REGIONS_ELEC)),a] = 1
    INDUSTRIAL_NodalLoc_GAS[findfirst(occursin.([string(Loc_GAS[a])],REGIONS_GAS)),a] = 1
end


### Process emissions
ProcessEmissions = CSV.read("$(foldername)/IndustrialProcessEmissions$(system).csv",DataFrame)
#
PROCESS = length(ProcessEmissions[:, :1])                                       # Number of industrial facility "services" modeled
#
InitialProcessNumber = ProcessEmissions."Existing Units"                        # Initial industrial unit/facility population [no. units]
PointSourceEmissions = ProcessEmissions."CO2 Process Emissions [tCO2/h]"        # CO2 Process Emissions [tCO2 / h];     i.e. can be abated by CCS
NonPtSourceEmissions = ProcessEmissions."Non-CO2 Process Emissions [tCO2/h]"    # Non-CO2 Process Emissions [tCO2 / h]; i.e. can be abated by DAC
#
PointSourceEmissions = PointSourceEmissions .* processEmissions_ON
NonPtSourceEmissions = NonPtSourceEmissions .* processEmissions_ON


PROCESS_NodalLoc_ELEC = zeros(NODES_ELEC, PROCESS)
PROCESS_NodalLoc_GAS  = zeros(NODES_GAS, PROCESS)

Loc_ELEC = ProcessEmissions[:,1]
Loc_GAS = ProcessEmissions[:,2]
for p = 1:PROCESS
    PROCESS_NodalLoc_ELEC[findfirst(occursin.([string(Loc_ELEC[p])],REGIONS_ELEC)),p] = 1
    PROCESS_NodalLoc_GAS[findfirst(occursin.([string(Loc_GAS[p])],REGIONS_GAS)),p] = 1
end



## Industrial peak energy demand decrease; mainly due to expected refinery shutdowns
# Unit-less, between 0 and 1
################################################################################
# here we have 3 types of demand: direct heat, gas, and electricity
decline_heatDemand  = Matrix( CSV.read("$(foldername)/IndustrialHeatDemandActivity_" * refineryCase * ".csv",DataFrame) )
decline_processEmissions  = Matrix( CSV.read("$(foldername)/IndustrialProcessEmissionsActivity_" * refineryCase * ".csv",DataFrame) )








################################################################################
# End-use appliance demands
################################################################################
EndUseAppliances = CSV.read("$(foldername)/EndUseAppliances$(system)$(num).csv",DataFrame)
APPLIANCES = length(EndUseAppliances[:, :1])        # Number of appliance classes modeled
ApplianceServices = EndUseAppliances[:,5]           # End-use services satisfied by each appliance class
PrimeMover_APPLIANCES = EndUseAppliances[:,6]       # Technology type for each appliance class
InitialAppliancePopulation = EndUseAppliances[:,7]  # Initial appliance population [no. units]
ApplianceLifetime = EndUseAppliances[:,8]           # Expected appliance lifetime [years]
IS_HYBRID = EndUseAppliances[:,9]                   # Indicator for whether the appliance is hybrid gas-electric
upgrade_cost = EndUseAppliances[:,10]               # Building infrastructure upgrade costs associated with transitioning to this appliance [$]
APP_avg_charge = EndUseAppliances[:,12]             # [lbs refrigerant]
APP_eol_charge = EndUseAppliances[:,13]             # [lbs refrigerant]
APP_annual_leak = EndUseAppliances[:,14]            # [%/year]
APP_eol_loss = EndUseAppliances[:,15]               # [% at EOL]
CRF_APPLIANCES = (WACC_APPLIANCES.*(1+WACC_APPLIANCES).^ApplianceLifetime)./((1+WACC_APPLIANCES).^ApplianceLifetime .- 1)   # Capital recovery factor [yr^-1] for annualizing appliance investments

## Create a matrix that maps each appliance to the energy service that it satisfies
################################################################################
SERVICES = length(unique(EndUseAppliances[:,5]))
ServiceList = unique(EndUseAppliances[:,5]) # List of all energy services (i.e., residential space heating, residential water heating, commercial space heating, commercial water heating, etc.)
AppliancesToServices = zeros(APPLIANCES,SERVICES)
# For each appliance, a, put a 1 in the column corresponding to its energy service s
for a = 1:APPLIANCES
    AppliancesToServices[a,findfirst(occursin.([(ApplianceServices[a])],ServiceList))] = 1
end

# Pre-compute the cumulative failure fraction for each appliance in each investment period
# See Eq. 2.9 in Von Wald thesis
################################################################################
cumulativefailurefrac = zeros(APPLIANCES,T_inv,T_inv)
failureProb = zeros(APPLIANCES,150)
failureArchive = CSV.read("$(foldername)/failureProb.csv",DataFrame)
# First, calculate failure probabilities for each appliance class in each year of its lifetime from 1 to 50.
for a = 1:APPLIANCES
    for i = 1:50
#       Using Poisson probability distribution to assess failure fractions
#       failureProb[a,i] = exp(-ApplianceLifetime[a])*(ApplianceLifetime[a]^(i))/factorial(i) 
#       However, the factorial function in Julia won't go over 20! which limits our ability to model long-lived equipment
#       Instead, we use an exogenous file generated using python's factorial function.
        failureProb[a,i] = failureArchive[Int(ApplianceLifetime[a]),i]
    end
    # Ensures that the sum across each row equals 1 (i.e., no appliance lasts longer than 50 years)
    failureProb[a,50] = 1 - sum(failureProb[a,1:49])
end
# Second, compute the cumulative failure fraction for each appliance type, in each investment year
# i.e., cumulativefailurefrac[a,v,t] corresponds to the cumulative failure fraction of appliances of type a
# that were installed in investment period v, that will fail by investment period t.
for a = 1:APPLIANCES
    for v = 1:T_inv
        for t = 1:T_inv
            cumulativefailurefrac[a,v,t] = round(sum(failureProb[a,1:max(Years[t]-Years[v],1)]),digits = 4)  # rounding to avoid numerical issues in the optimization program due to small coefficients
            if t == v
                cumulativefailurefrac[a,v,t] = 0.0
            end
        end
    end
end

## Appliance level energy demand profiles (hourly)
# In MWh/hr per unit, for each hour in a typical year; then must be clustered down
################################################################################
ApplianceProfilesGAS2 = CSV.read("$(foldername)/ApplianceProfiles_GAS$(system)$(region).csv",DataFrame)
ApplianceProfilesELEC2 = CSV.read("$(foldername)/ApplianceProfiles_ELEC$(system)$(region).csv",DataFrame)

ApplianceProfilesGAS = zeros(8760,length(ApplianceProfilesGAS2[1,:]))
ApplianceProfilesELEC = zeros(8760,length(ApplianceProfilesELEC2[1,:]))
# Rounded to avoid introducing numerical issues
for i = 1:length(ApplianceProfilesGAS2[1,:])
    ApplianceProfilesGAS[:,i] = round.(ApplianceProfilesGAS2[:,i], digits = 8)
    ApplianceProfilesELEC[:,i] = round.(ApplianceProfilesELEC2[:,i], digits = 8)
end

## Growth rates used for forecasting and back-casting appliance sales
# Set all growth rates to zero
################################################################################
ServicesGrowthRate = zeros(SERVICES,1)      # %\year
HistoricalGrowthRate = zeros(APPLIANCES,1)  # %\year  
ForecastGrowthRate = zeros(APPLIANCES,1)    # %\year    

# Distribution systems are set up to potentially exist at the sub-transmission nodal level
# i.e., multiple distribution systems may exist and operate independently at the
# same transmission node.
################################################################################
DISTSYS_ELEC = (unique(EndUseAppliances[:,3]))
DISTSYS_GAS  = (unique(EndUseAppliances[:,4]))
DIST_ELEC = length(DISTSYS_ELEC)
DIST_GAS = length(DISTSYS_GAS)

# APP_DistSystemLoc_GAS to tie appliances to gas distribution systems
# APP_DistSystemLoc_ELEC to tie appliances to electric distribution systems
APP_DistSystemLoc_ELEC = zeros(DIST_ELEC, APPLIANCES)
APP_DistSystemLoc_GAS = zeros(DIST_GAS, APPLIANCES)

Loc_ELEC = EndUseAppliances[:,3]
Loc_GAS = EndUseAppliances[:,4]
for a = 1:APPLIANCES
    APP_DistSystemLoc_ELEC[findfirst(occursin.([string(Loc_ELEC[a])],string.(DISTSYS_ELEC))),a] = 1
    APP_DistSystemLoc_GAS[findfirst(occursin.([string(Loc_GAS[a])],string.(DISTSYS_GAS))),a] = 1
end

APPLIANCES_NodalLoc_ELEC = zeros(NODES_ELEC, APPLIANCES)
APPLIANCES_NodalLoc_GAS = zeros(NODES_GAS, APPLIANCES)

Loc_ELEC = EndUseAppliances[:,1]
Loc_GAS = EndUseAppliances[:,2]
for a = 1:APPLIANCES
    APPLIANCES_NodalLoc_ELEC[findfirst(occursin.([string(Loc_ELEC[a])],REGIONS_ELEC)),a] = 1
    APPLIANCES_NodalLoc_GAS[findfirst(occursin.([string(Loc_GAS[a])],REGIONS_GAS)),a] = 1
end

###
maxBuild_mult_tot = maxBuild_mult
###


################################################################################
# Transmission interchanges
################################################################################
TransmissionLinks_ELEC = CSV.read("$(foldername)/ElecTransmission$(system).csv",DataFrame)
EDGES_ELEC = length(TransmissionLinks_ELEC[:,1])
MAXFLOW_ELEC = TransmissionLinks_ELEC[:,3].*transmission_multiplier
Line_Rating = TransmissionLinks_ELEC[:,4].*transmission_multiplier
Line_Reactance = TransmissionLinks_ELEC[:,5]
ExistingUnits_ElecTrans = TransmissionLinks_ELEC[:,6]
###
MaxNewUnits_ElecTrans = TransmissionLinks_ELEC[:,7] * maxBuild_mult
###
Length_ElecTrans = TransmissionLinks_ELEC[:,8]                          # m
EconomicLifetime_ELECTrans = 50                                         # years
CAPEX_ELECTrans = ElecTransmissionCapitalCosts.*Length_ElecTrans        # $/MW-m * m => $/MW
CRF_ELECTrans = (WACC.*(1+WACC).^EconomicLifetime_ELECTrans)./((1+WACC).^EconomicLifetime_ELECTrans .- 1)
AMMORTIZED_ELECTrans = CAPEX_ELECTrans.*Line_Rating.*(CRF_ELECTrans+ElecTransmissionOperatingCosts)

TransmissionLinks_GAS = CSV.read("$(foldername)/GasTransmission$(system).csv",DataFrame)
EDGES_GAS = length(TransmissionLinks_GAS[:,1])
MAXFLOW_GAS = TransmissionLinks_GAS[:,3]./10
Diameter_Pipes = TransmissionLinks_GAS[:,4]  #[m]
Length_Pipes = TransmissionLinks_GAS[:,5]    #[m]
FrictionFactor_Pipes = TransmissionLinks_GAS[:,6]
ExistingUnits_GasTrans = TransmissionLinks_GAS[:,7]
MaxNewUnits_GasTrans = TransmissionLinks_GAS[:,8]
CompressionRatio_MAX_Branch = TransmissionLinks_GAS[:,9]
# CAPEX_GASTrans = GasTransmissionCapitalCosts.*Length_Pipes./1000
# FOM_GASTrans = GasTransmissionOperatingCosts.*Length_Pipes./1000

## Parameters for gas pipeline flow simulation
################################################################################
Temp_GAS = 300 # [K]
Temp_N = 298.15  # [K]
Pressure_N = 101325   # [Pa]
pi = 3.14
SpecGravity = 0.64
Compressibility = 0.96
# Pressure is in Pascals, which puts the actual pressure variables in Pa^2
# Compressibility and specific gravity will vary depending on actual injection
# of alternative fuels, but for the purposes of flow evauluation we assume them
# constant to avoid a fully nonlinear problem
K = zeros(size(Diameter_Pipes))
K1 = zeros(size(Diameter_Pipes))
K2 = zeros(size(Diameter_Pipes))
V = zeros(size(Diameter_Pipes))
C = zeros(size(Diameter_Pipes))

# Here, we present three different approaches to the gas flow equation:
# (1) General flow equation
for e = 1:EDGES_GAS
    K[e] = 1/((13.2986*Temp_N/Pressure_N)^2*Diameter_Pipes[e]^5/(Length_Pipes[e]*SpecGravity*Temp_GAS*Compressibility*FrictionFactor_Pipes[e]))
    V[e] = pi/4*Diameter_Pipes[e]^2*Length_Pipes[e]       # m3
    C[e] = V[e]*Temp_N/Pressure_N/Compressibility/Temp_GAS
end
# (2) Weymouth equation
for e = 1:EDGES_GAS
    K[e] = 1/((137.2364*Temp_N/Pressure_N)^2*Diameter_Pipes[e]^5.33/(Length_Pipes[e]*SpecGravity*Temp_GAS*Compressibility))
end
M_CH4 = 16/1000                         # kg/mol
UnivGasConstant = 8.314                 # J/mol-K
UnivDensity_GAS = 1/0.024465            # moles/m3
GasConstant = 8.314/M_CH4               # J/kg-K
Density_GAS = 1/0.024465*M_CH4          # kg/m3 (converted from moles/m3)
# (3) Per Correa-Posada, Carlos M., and Pedro Sanchez-Martin. "Integrated power and natural gas model for energy adequacy in short-term operation." IEEE Transactions on Power Systems 30.6 (2014): 3347-3355.
for e = 1:EDGES_GAS
    K1[e] = (pi/4)*Diameter_Pipes[e]^2/GasConstant/Temp_GAS/Compressibility/Density_GAS
    K2[e] = (pi/4)^2*Diameter_Pipes[e]^5/FrictionFactor_Pipes[e]/GasConstant/Temp_N/Compressibility/Density_GAS^2
end

# Correcting all constants to bring pressures up to MPa
K1 = K1.*10^6
K2 = K2.*10^12
K = K./10^12
C = C.*10^6

################################################################################
### Import set of energy supply/storage/demand units
################################################################################
Generators = CSV.read("$(foldername)/Generators$(system).csv",DataFrame)

HourlyVRE2 = CSV.read("$(foldername)/HourlyVRE$(system)$(region).csv",DataFrame)
HourlyVRE = zeros(8760,length(HourlyVRE2[1,:]))
for i = 1:length(HourlyVRE2[1,:])
    # Capacity factors must be greater than 0
    HourlyVRE[:,i] = max.(HourlyVRE2[:,i],0)
end

GEN = length(Generators[:, :1])
PrimeMover_GEN = Generators[:,4]
Fuel_GEN = Generators[:,5]
## add geothermal capacity anyway?
# increase geothermal
idx_geothermal = Generators[!, "Prime Mover"] .== fill("Geothermal EGS", size(Generators[!, 8],1), size(Generators[!, 8],2))    
idx_geothermal = [all(row) for row in eachrow(idx_geothermal)]
# previously 4/20
EGS_scale = 1.0
Generators[idx_geothermal, 8] = vec( fill(4 * EGS_scale, size(Generators[idx_geothermal, 8],1), size(Generators[idx_geothermal, 8],2)) )
Generators[idx_geothermal, 9] = vec( fill(20 * EGS_scale, size(Generators[idx_geothermal, 9],1), size(Generators[idx_geothermal, 9],2)) )
#

# retirement by 2030 or 2045: force them to build no new nuclear
if techScenario_Nuclear == "2030" || techScenario_Nuclear == "2045"
    idx_nuclear = Generators[!, "Prime Mover"] .== fill("Nuclear", size(Generators[!, 8],1), size(Generators[!, 8],2))    
    idx_nuclear = [all(row) for row in eachrow(idx_nuclear)]
    #
    Generators[idx_nuclear, 8] = vec( fill(0, size(Generators[idx_nuclear, 8],1), size(Generators[idx_nuclear, 8],2)) )
    Generators[idx_nuclear, 9] = vec( fill(0, size(Generators[idx_nuclear, 9],1), size(Generators[idx_nuclear, 9],2)) )
    # NEW FOR Retirement FOR 1 inv period *****
    # Generators[idx_nuclear, 6] = vec( fill(0, size(Generators[idx_nuclear, 6],1), size(Generators[idx_nuclear, 6],2)) )
end
if techScenario_NGCC == "No"
    ng_primemovers = ["Natural Gas CC-CCS","Natural Gas CC","Natural Gas CT"]
    # ng_primemovers = ["Natural Gas CC-CCS"]
    for i = 1:length(ng_primemovers)
        idx_ngccs = Generators[!, "Prime Mover"] .== fill(ng_primemovers[i], size(Generators[!, 8],1), size(Generators[!, 8],2))    
        idx_ngccs = [all(row) for row in eachrow(idx_ngccs)]
        #
        Generators[idx_ngccs, 8] = vec( fill(0, size(Generators[idx_ngccs, 8],1), size(Generators[idx_ngccs, 8],2)) )
        Generators[idx_ngccs, 9] = vec( fill(0, size(Generators[idx_ngccs, 9],1), size(Generators[idx_ngccs, 9],2)) )
    end
end
if techScenario_OffshoreWind == "Limited Offshore"
    idx_offshorewind = Generators[!, "Prime Mover"] .== fill("OffshoreWind", size(Generators[!, 8],1), size(Generators[!, 8],2))    
    idx_offshorewind = [all(row) for row in eachrow(idx_offshorewind)]
    #
    Generators[idx_offshorewind, 8] = vec( fill(2, size(Generators[idx_offshorewind, 8],1), size(Generators[idx_offshorewind, 8],2)) )
    Generators[idx_offshorewind, 9] = vec( fill(5, size(Generators[idx_offshorewind, 9],1), size(Generators[idx_offshorewind, 9],2)) )
elseif techScenario_OffshoreWind == "No Offshore"
    idx_offshorewind = Generators[!, "Prime Mover"] .== fill("OffshoreWind", size(Generators[!, 8],1), size(Generators[!, 8],2))    
    idx_offshorewind = [all(row) for row in eachrow(idx_offshorewind)]
    #
    Generators[idx_offshorewind, 8] = vec( fill(0, size(Generators[idx_offshorewind, 8],1), size(Generators[idx_offshorewind, 8],2)) )
    Generators[idx_offshorewind, 9] = vec( fill(0, size(Generators[idx_offshorewind, 9],1), size(Generators[idx_offshorewind, 9],2)) )
end
#
#
NumUnits_GEN = Generators[:,6]                  # [units]
UnitSize_GEN = Generators[:,7]                  # [MW]
MaxNewUnitsAnnual_GEN = Generators[:,8].*br * maxBuild_mult     # [units/year]
MaxNewUnitsTotal_GEN = Generators[:,9].*br * maxBuild_mult_tot      # [units]
Pmin_GEN = Generators[:,10]                     # [p.u.]
Pmax_GEN = Generators[:,11]                     # [p.u.]
RampDownRate_GEN = Generators[:,12]             # [p.u.]
RampUpRate_GEN = Generators[:,13]               # [p.u.]
MinUpTime_GEN = Generators[:,14]                # [hours]
MinDownTime_GEN = Generators[:,15]              # [hours]
IS_RENEWABLE = Generators[:,16]                 # [bin.]
HeatRate = Generators[:,17]                     # [MMBtu fuel/MWh elec.]
NG_fueled = Generators[:,18]                    # [bin.]
emissions_factors = Generators[:,19]./1000      # [tCO2/MMBtu fuel]
StartUpCosts = Generators[:,20]                 # [$/start]
EconomicLifetime_GEN = Generators[:,21]         # [years]
Lifetime_GEN = Generators[:,22]                 # [years]
StartupFuel = Generators[:,23]                  # [MMBtu/start]
## scenarios for variable retirement year
# nuclear
idx_nuclear = Generators[!, "Prime Mover"] .== fill("Nuclear", size(Generators[!, "Prime Mover"],1), size(Generators[!, "Prime Mover"],2))    
idx_nuclear = [all(row) for row in eachrow(idx_nuclear)]
Generators[idx_nuclear, "Forced Retirement"] = vec( fill(nuclear_RetirementYear, size(Generators[idx_nuclear, "Forced Retirement"],1), size(Generators[idx_nuclear, "Forced Retirement"],2)) )
#
RetirementYear_GEN = min.(Generators[:,24]+Lifetime_GEN,Generators[:,25])
CRF_GEN = (WACC.*(1+WACC).^EconomicLifetime_GEN)./((1+WACC).^EconomicLifetime_GEN .- 1)


### P2G
PowerToGas = CSV.read("$(foldername)/PowerToGas$(system).csv",DataFrame)
#
P2G = length(PowerToGas[:, :1])
#
PrimeMover_P2G = PowerToGas[:,4]
NumUnits_P2G = PowerToGas[:,5]                  # [units]
UnitSize_P2G = PowerToGas[:,6]                  # [MW]
MaxNewUnitsAnnual_P2G = PowerToGas[:,7].*br * maxBuild_mult * 1.0    # [units/year]
MaxNewUnitsTotal_P2G = PowerToGas[:,8].*br * maxBuild_mult_tot * 1.0     # [units]
Pmin_P2G = PowerToGas[:,9]                      # [p.u.]
Pmax_P2G = PowerToGas[:,10]                     # [p.u.]
RampDownRate_P2G = PowerToGas[:,11]             # [p.u.]
RampUpRate_P2G = PowerToGas[:,12]               # [p.u.]
MinUpTime_P2G = PowerToGas[:,13]                # [hours]
MinDownTime_P2G = PowerToGas[:,14]              # [hours]
eta_P2G = PowerToGas[:,15]                      # [MJ gas/MJ elec.]
eta_P2L = PowerToGas[:,16]                      # [MJ LPG/MJ elec.]
EconomicLifetime_P2G = PowerToGas[:,17]         # [years]
Lifetime_P2G = PowerToGas[:,18]                 # [years]
ISBIOMETHANE = PowerToGas[:,19]                 # [bin.]
ISBIOMASS = PowerToGas[:,20]                    # [bin.]
MoleFracs_P2G = Matrix(PowerToGas[:,23:24])             # [%]
CRF_P2G = (WACC.*(1+WACC).^EconomicLifetime_P2G)./((1+WACC).^EconomicLifetime_P2G .- 1)
RetirementYear_P2G = min.(PowerToGas[:,21]+Lifetime_P2G, PowerToGas[:,22])


### P2H
PowerToHeat = CSV.read("$(foldername)/PowerToHeat$(system).csv",DataFrame)
#
P2H = length(PowerToHeat[:, :1])
#
PrimeMover_P2H = PowerToHeat[:,4]
NumUnits_P2H = PowerToHeat[:,5]                  # [units]
UnitSize_P2H = PowerToHeat[:,6]                  # [MW]
MaxNewUnitsAnnual_P2H = PowerToHeat[:,7].*br * heatElectrification_ON     # [units/year]
MaxNewUnitsTotal_P2H = PowerToHeat[:,8].*br  * heatElectrification_ON     # [units]
Pmin_P2H = PowerToHeat[:,9]                      # [p.u.]
Pmax_P2H = PowerToHeat[:,10]                     # [p.u.]
RampDownRate_P2H = PowerToHeat[:,11]             # [p.u.]
RampUpRate_P2H = PowerToHeat[:,12]               # [p.u.]
MinUpTime_P2H = PowerToHeat[:,13]                # [hours]
MinDownTime_P2H = PowerToHeat[:,14]              # [hours]
eta_P2H = PowerToHeat[:,15]                      # [MJ heat/MJ elec.]
T_P2H = PowerToHeat[:,16]                        # [C]
EconomicLifetime_P2H = PowerToHeat[:,17]         # [years]
Lifetime_P2H = PowerToHeat[:,18]                 # [years]
CRF_P2H = (WACC.*(1+WACC).^EconomicLifetime_P2H)./((1+WACC).^EconomicLifetime_P2H .- 1)
RetirementYear_P2H = min.(PowerToHeat[:,19]+Lifetime_P2H, PowerToHeat[:,20])

## create temperature compatibility matrix; 1 if T_P2H >= T_demand, 0 else
# T_P2H = ones(16) * 1000
TempCompat_P2H_all = [T_P2H[d] >= IndustrialTemperature[a] ? 1 : 0 for d in 1:length(T_P2H), a in 1:length(IndustrialTemperature)]
#
TempCompat_P2H_directHeat = ["Direct Heat" .== PrimeMover_INDUSTRIAL[a] ? 1 : 0 for d in 1:length(T_P2H), a in 1:length(IndustrialTemperature)]
TempCompat_P2H = TempCompat_P2H_all .* TempCompat_P2H_directHeat

#
println("Heat pump COP:")
idx_P2H_heatPump    = PrimeMover_P2H .== fill("Heat Pump", length(PrimeMover_P2H))
println(eta_P2H[idx_P2H_heatPump])
#
# eta_P2H[idx_P2H_heatPump] .= 3
# println(eta_P2H[idx_P2H_heatPump])
println("")
#
println("Resistance Heater Efficiency:")
idx_P2H_resHeater    = PrimeMover_P2H .== fill("Electric Boiler", length(PrimeMover_P2H))
println(eta_P2H[idx_P2H_resHeater])
#
# eta_P2H[idx_P2H_resHeater] .= 0.9
# println(eta_P2H[idx_P2H_resHeater])
println("")


### CDR
# Here, CDR is a misnomer. It is a remnant of the first addition to this file — direct air capture systems — prior to adding CCS
# the file name remained CDR, despite including point-source CCS systems. This should be renamed to carbon management in future versions
carbonDioxideRemoval = CSV.read("$(foldername)/CarbonDioxideRemoval" * CDR_case * ".csv",DataFrame)
# filter
if noSolidSorbent == 1
    # remove solid sorbent
    idx_allowed = carbonDioxideRemoval[!, "Prime Mover"] .!= fill("DAC-SS", size(carbonDioxideRemoval[!, "Prime Mover"],1), size(carbonDioxideRemoval[!, "Prime Mover"],2))
    idx_allowed = [all(row) for row in eachrow(idx_allowed)]
    carbonDioxideRemoval = carbonDioxideRemoval[idx_allowed,:]
end
#
CDR = length(carbonDioxideRemoval[:, :1])
#
PrimeMover_CDR = carbonDioxideRemoval[:,4]
techType_CDR   = carbonDioxideRemoval[:,5]
forIndustrialServiceType_CDR   = carbonDioxideRemoval[:,6]
NumUnits_CDR = carbonDioxideRemoval[:,7]                  # [units]
UnitSize_CDR = carbonDioxideRemoval[:,8]                  # [tCO2/h]
MaxNewUnitsAnnual_CDR = carbonDioxideRemoval[:,9].*br * carbonDioxideRemoval_ON     # [units/year]
MaxNewUnitsTotal_CDR = carbonDioxideRemoval[:,10].*br  * carbonDioxideRemoval_ON       # [units]
Pmin_CDR = carbonDioxideRemoval[:,11]                      # [p.u.]
Pmax_CDR = carbonDioxideRemoval[:,12]                     # [p.u.]
RampDownRate_CDR = carbonDioxideRemoval[:,13]             # [p.u.]
RampUpRate_CDR = carbonDioxideRemoval[:,14]               # [p.u.]
MinUpTime_CDR = carbonDioxideRemoval[:,15]                # [hours]
MinDownTime_CDR = carbonDioxideRemoval[:,16]              # [hours]
#
elecConsumed_CDR = carbonDioxideRemoval[:,17]             # [MWh_e/tCO2_removed]
heatConsumed_CDR = carbonDioxideRemoval[:,18]             # [MWh_th/tCO2_removed]
#
if scalingFactor_CDR_gas != 1
    println("CDR, Gas demand scaled:")
    println(scalingFactor_CDR_gas)
    #
    heatConsumed_CDR .*= scalingFactor_CDR_gas
end
#
if scalingFactor_CDR_elec != 1
    println("CDR, Elec demand scaled:")
    println(scalingFactor_CDR_elec)
    #
    elecConsumed_CDR .*= scalingFactor_CDR_elec
end

minCapacityFactor_CDR = carbonDioxideRemoval[:,19]        # [-]
maxCapacityFactor_CDR = carbonDioxideRemoval[:,20]        # [-]
#
carbonRemoved_CDR = carbonDioxideRemoval[:,21]        # [-]
#
EconomicLifetime_CDR = carbonDioxideRemoval[:,22]         # [years]
Lifetime_CDR = carbonDioxideRemoval[:,23]                 # [years]
CRF_CDR = (WACC.*(1+WACC).^EconomicLifetime_CDR)./((1+WACC).^EconomicLifetime_CDR .- 1)
RetirementYear_CDR = min.(carbonDioxideRemoval[:,24]+Lifetime_CDR, carbonDioxideRemoval[:,25])

## Create a matrix that maps each industrial service to CCS type
################################################################################
#
IndustrialCCSMatching = zeros(CDR,numIndustrialSERVICES)
#
for d = 1:CDR
    idx = findfirst(occursin.([forIndustrialServiceType_CDR[d]], industrialServiceList))
    if idx !== nothing
        IndustrialCCSMatching[d, idx] = 1
    end
end




### Electrical Storage
ElectricalStorage = CSV.read("$(foldername)/Storage_ELEC$(system).csv",DataFrame)
### choose storage options
# formEnergy
if FormEnergy_allowed == 0
    idx_allowed = ElectricalStorage[!, "Prime Mover"] .!= fill("Multi-day storage", size(ElectricalStorage[!, "Prime Mover"],1), size(ElectricalStorage[!, "Prime Mover"],2))
    idx_allowed = [all(row) for row in eachrow(idx_allowed)]
    ElectricalStorage = ElectricalStorage[idx_allowed,:]
end
# pumped hydro storage
if PHS_allowed == 0
    idx_allowed = ElectricalStorage[!, "Prime Mover"] .!= fill("Pumped hydro storage", size(ElectricalStorage[!, "Prime Mover"],1), size(ElectricalStorage[!, "Prime Mover"],2))
    idx_allowed = [all(row) for row in eachrow(idx_allowed)]
    ElectricalStorage = ElectricalStorage[idx_allowed,:]
end
# hydrogen storage
if H2Storage_allowed == 0
    idx_allowed = ElectricalStorage[!, "Prime Mover"] .!= fill("Long-duration storage", size(ElectricalStorage[!, "Prime Mover"],1), size(ElectricalStorage[!, "Prime Mover"],2))
    idx_allowed = [all(row) for row in eachrow(idx_allowed)]
    ElectricalStorage = ElectricalStorage[idx_allowed,:]
end
###
STORAGE_ELEC = length(ElectricalStorage[:, :1])
PrimeMover_STORAGE_ELEC = ElectricalStorage[:,4]
NumUnits_STORAGE_ELEC = ElectricalStorage[:,5]                  # [units]
UnitSize_STORAGE_ELEC = ElectricalStorage[:,6]                  # [MW]
MaxNewUnitsAnnual_STORAGE_ELEC = ElectricalStorage[:,7].*br * maxBuild_mult     # [units/year]
MaxNewUnitsTotal_STORAGE_ELEC = ElectricalStorage[:,8].*br  * maxBuild_mult_tot     # [units]
duration_ELEC = ElectricalStorage[:,9]                          # [hours]
eta_charging_ELEC = ElectricalStorage[:,10]                     # [%]
eta_discharging_ELEC = ElectricalStorage[:,11]                  # [%]
eta_loss_ELEC = ElectricalStorage[:,12]                         # [%]
EconomicLifetime_STORAGE_ELEC = ElectricalStorage[:,13]         # [years]
Lifetime_STORAGE_ELEC = ElectricalStorage[:,14]                 # [years]
CRF_STORAGE_ELEC = (WACC.*(1+WACC).^EconomicLifetime_STORAGE_ELEC)./((1+WACC).^EconomicLifetime_STORAGE_ELEC .- 1)
RetirementYear_STORAGE_ELEC = min.(ElectricalStorage[:,15]+Lifetime_STORAGE_ELEC,ElectricalStorage[:,16])

### HEAT STORAGE
#
HeatStorage = CSV.read("$(foldername)/Storage_HEAT$(system).csv",DataFrame)
#
H2Heating_allowed = 1
# hydrogen for heating
# if H2Heating_allowed == 0
#     idx_allowed = HeatStorage[!, "Prime Mover"] .!= fill("Hydrogen-to-Heat", size(HeatStorage[!, "Prime Mover"],1), size(HeatStorage[!, "Prime Mover"],2))
#     idx_allowed = [all(row) for row in eachrow(idx_allowed)]
#     HeatStorage = HeatStorage[idx_allowed,:]
# end
#
STORAGE_HEAT = length(HeatStorage[:, :1])
PrimeMover_STORAGE_HEAT = HeatStorage[:,4]
NumUnits_STORAGE_HEAT = HeatStorage[:,5]                  # [units]
UnitSize_STORAGE_HEAT = HeatStorage[:,6]                  # [MWh]   *** energy capacity
MaxNewUnitsAnnual_STORAGE_HEAT = HeatStorage[:,7].*br * maxBuild_mult * heatStorage_ON     # [units/year]
MaxNewUnitsTotal_STORAGE_HEAT = HeatStorage[:,8].*br  * maxBuild_mult_tot * heatStorage_ON     # [units]
#
maxCharge_HEAT    = HeatStorage[:,9]                          # [MW]
maxDischarge_HEAT = HeatStorage[:,10]                          # [MW]
#
eta_charging_HEAT = HeatStorage[:,11]                     # [%]
eta_discharging_HEAT = HeatStorage[:,12]                  # [%]
eta_loss_HEAT = HeatStorage[:,13]                         # [%]
#
#
println("HB Efficiency:")
idx_HS_HB   = PrimeMover_STORAGE_HEAT .== fill("Rondo Heat Battery", length(PrimeMover_STORAGE_HEAT))
println(eta_discharging_HEAT[idx_HS_HB])
#
# eta_discharging_HEAT[idx_HS_HB] .= 0.9
# println(eta_discharging_HEAT[idx_HS_HB])
println("")
#
println("Loss of heat storage")
idx_HS_HB   = PrimeMover_STORAGE_HEAT .== fill("Rondo Heat Battery", length(PrimeMover_STORAGE_HEAT))
println(eta_loss_HEAT[idx_HS_HB])
#
# eta_loss_HEAT[idx_HS_HB] .= 0.000833 / 2 * 5
# println(eta_loss_HEAT[idx_HS_HB])
println("")
#
println("H2-to-heat Efficiency:")
idx_HS_H2   = PrimeMover_STORAGE_HEAT .== fill("Hydrogen-to-Heat", length(PrimeMover_STORAGE_HEAT))
println(eta_discharging_HEAT[idx_HS_H2])
#
# eta_discharging_HEAT[idx_HS_H2] .= 0.9
# println(eta_discharging_HEAT[idx_HS_H2])
println("")
#
#
### technology combinations
MaxNewUnitsTotal_STORAGE_HEAT[idx_HS_HB] .*= TechCombo_HB_ON
MaxNewUnitsTotal_STORAGE_HEAT[idx_HS_H2] .*= TechCombo_H2_ON
MaxNewUnitsTotal_P2H[idx_P2H_heatPump]   .*= TechCombo_HP_ON
MaxNewUnitsTotal_P2H[idx_P2H_resHeater]  .*= TechCombo_EH_ON




#
EconomicLifetime_STORAGE_HEAT = HeatStorage[:,15]         # [years]
Lifetime_STORAGE_HEAT = HeatStorage[:,16]                 # [years]
CRF_STORAGE_HEAT = (WACC.*(1+WACC).^EconomicLifetime_STORAGE_HEAT)./((1+WACC).^EconomicLifetime_STORAGE_HEAT .- 1)
RetirementYear_STORAGE_HEAT = min.(HeatStorage[:,17]+Lifetime_STORAGE_HEAT,HeatStorage[:,18])
###
# T_HeatStorage = ones(32) * 1000
T_HeatStorage = HeatStorage[:,14]  # [C]
TempCompat_HeatStorage_all = [T_HeatStorage[s] >= IndustrialTemperature[a] ? 1 : 0 for s in 1:length(T_HeatStorage), a in 1:length(IndustrialTemperature)]
#
TempCompat_HeatStorage_directHeat = ["Direct Heat" .== PrimeMover_INDUSTRIAL[a] ? 1 : 0 for s in 1:length(T_HeatStorage), a in 1:length(IndustrialTemperature)]
TempCompat_HeatStorage = TempCompat_HeatStorage_all .* TempCompat_HeatStorage_directHeat

# do again but for T = 200 degrees
T_outofST = ones(length(T_HeatStorage)) * 200
TempCompat_outofST_all = [T_outofST[s] >= IndustrialTemperature[a] ? 1 : 0 for s in 1:length(T_outofST), a in 1:length(IndustrialTemperature)]
TempCompat_outofST_directHeat = ["Direct Heat" .== PrimeMover_INDUSTRIAL[a] ? 1 : 0 for s in 1:length(T_HeatStorage), a in 1:length(IndustrialTemperature)]
TempCompat_outofST = TempCompat_outofST_all .* TempCompat_outofST_directHeat



#
GasStorage = CSV.read("$(foldername)/Storage_GAS$(system).csv",DataFrame)
#
STORAGE_GAS = length(GasStorage[:, :1])
PrimeMover_STORAGE_GAS = GasStorage[:,4]
NumUnits_STORAGE_GAS = GasStorage[:,5]                          # [units]
UnitSize_STORAGE_GAS = GasStorage[:,6]                          # [MW]
MaxNewUnitsAnnual_STORAGE_GAS = GasStorage[:,7] * maxBuild_mult                 # [units/year]
MaxNewUnitsTotal_STORAGE_GAS = GasStorage[:,8]  * maxBuild_mult_tot                 # [units]
duration_GAS = GasStorage[:,9]                                  # [hours]
eta_charging_GAS = GasStorage[:,10]                             # [%]
eta_discharging_GAS = GasStorage[:,11]                          # [%]
eta_loss_GAS = GasStorage[:,12]                                 # [%]
EconomicLifetime_STORAGE_GAS = GasStorage[:,13]                 # [years]
Lifetime_STORAGE_GAS = GasStorage[:,14]                         # [years]
CRF_STORAGE_GAS = (WACC.*(1+WACC).^EconomicLifetime_STORAGE_GAS)./((1+WACC).^EconomicLifetime_STORAGE_GAS .- 1)
RetirementYear_STORAGE_GAS = min.(GasStorage[:,15]+Lifetime_STORAGE_GAS,GasStorage[:,16])
MoleFracs_STORAGE = Matrix(GasStorage[:,17:18])
initialStorage_GAS = GasStorage[:,19]                           # [MWh]

# Gas storage facilities are assumed to be maintained regardless of decisions made in optimization
CAPEX_STORAGE_GAS = 0*ones(T_inv,STORAGE_GAS)                   # [$]
FOM_STORAGE_GAS = 0*ones(T_inv,STORAGE_GAS)                     # [$]

# define cost of storage as:
costOfGasStorage = 0.5 / MWh_PER_MMBTU                          # [$/MWh]



################################################################################
### Gas quality tracking information
################################################################################
GAS_COMPONENTS = 2                     # Currently set up for CH4, H2
V_m = 40.87                            # moles/standard m3
MolarMass = [16, 2]                    # kg/kmol
LHV = [50, 120]                        # MJ/kg
MoleFrac_MAX = [1.0, H2molfrac_max]              # kmol/kmol gas
HV_MIN = 40                            # MJ/kg
HV_MAX = 120                           # MJ/kg
MoleFracs_SLACK = zeros(NODES_GAS,GAS_COMPONENTS)
MoleFracs_SLACK[:,1] .= 1.0

## For each source of gas, calculate the molar mass [kg/kmol] and LHV [MJ/kg] of gas provided
MolarMass_SLACK = sum(MoleFracs_SLACK.*transpose(MolarMass), dims = 2)         # [kg/kmol gas]
MolarMass_STORAGE = sum(MoleFracs_STORAGE.*transpose(MolarMass), dims = 2)     # [kg/kmol gas]
MolarMass_P2G = sum(MoleFracs_P2G.*transpose(MolarMass), dims = 2)             # [kg/kmol gas]

LHV_SLACK = sum(MoleFracs_SLACK.*transpose(MolarMass.*LHV), dims = 2)./MolarMass_SLACK        # [MJ/kg gas]
LHV_STORAGE = sum(MoleFracs_STORAGE.*transpose(MolarMass.*LHV), dims = 2)./MolarMass_STORAGE    # [MJ/kg gas]
LHV_P2G = sum(MoleFracs_P2G.*transpose(MolarMass.*LHV), dims = 2)./MolarMass_P2G            # [MJ/kg gas]

################################################################################
### CAPEX, FOM, VOM, and fuel costs
################################################################################
CAPEXLookup = CSV.read("$(foldername)/CAPEXLookup" * CDR_case * ".csv",DataFrame)
FOMLookup = CSV.read("$(foldername)/FOMLookup" * CDR_case * ".csv",DataFrame)
VOMLookup = CSV.read("$(foldername)/VOMLookup" * CDR_case * ".csv",DataFrame)
FuelCostLookup = CSV.read("$(foldername)/FuelCostLookUp.csv",DataFrame)

CAPEX_GEN = zeros(T_inv,GEN)
FOM_GEN = zeros(T_inv,GEN)
VOM_GEN = zeros(T_inv,GEN)
FuelCosts = zeros(T_inv,GEN)
CAPEX_P2G = zeros(T_inv,P2G)
FOM_P2G = zeros(T_inv,P2G)
VOM_P2G = zeros(T_inv,P2G)
CAPEX_STORAGE_ELEC = zeros(T_inv,STORAGE_ELEC)
FOM_STORAGE_ELEC = zeros(T_inv,STORAGE_ELEC)
CAPEX_APPLIANCES = zeros(T_inv, APPLIANCES)
FOM_APPLIANCES = zeros(T_inv, APPLIANCES)
### HEAT STORAGE
CAPEX_STORAGE_HEAT = zeros(T_inv,STORAGE_HEAT)
FOM_STORAGE_HEAT = zeros(T_inv,STORAGE_HEAT)
CAPEX_STEAM_TURBINE = zeros(T_inv,STORAGE_HEAT)
### P2H
CAPEX_P2H = zeros(T_inv,P2H)
FOM_P2H = zeros(T_inv,P2H)
VOM_P2H = zeros(T_inv,P2H)
###
#
CAPEX_CDR = zeros(T_inv,CDR)
FOM_CDR = zeros(T_inv,CDR)
VOM_CDR = zeros(T_inv,CDR)


## Apply cost multipliers for different energy storage cost scenarios
################################################################################
# define function for scaling
function scaleCAPEX(techType, df, multiplier)
    
    # Get the index of the columns corresponding to the range you want (2020 to 2050)
    start_col = findfirst(names(CAPEXLookup) .== "2020")
    end_col = findlast(names(CAPEXLookup) .== "2050")
    #
    # Filter the DataFrame for rows with "Li-ion battery" in the "Technology" column
    filtered_data = CAPEXLookup[CAPEXLookup[!, "Technology"] .== techType, :]

    # Select columns from '2020' to '2030' for the filtered data
    selected_columns = filtered_data[:, start_col:end_col]

    # Multiply values in selected columns by multiplier
    selected_columns = selected_columns .* multiplier

    CAPEXLookup[CAPEXLookup[!, "Technology"] .== techType, start_col:end_col] .= selected_columns
    
    return df
end

## run it on all costs; if multiplier is 1 then it won't change anything
# Li-ion
techType = "Li-ion battery"
CAPEXLookup = scaleCAPEX(techType, CAPEXLookup, cost_LiIon_multiplier)
println("")
println("Li-ion 2020 cost is: ", CAPEXLookup[CAPEXLookup[!, "Technology"] .== techType, "2020"][1], " \$/kW")
# Fe-Air
techType = "Multi-day storage"
CAPEXLookup = scaleCAPEX(techType, CAPEXLookup, cost_FeAir_multiplier)
println("Fe-Air 2020 cost is: ", CAPEXLookup[CAPEXLookup[!, "Technology"] .== techType, "2020"][1], " \$/kW")
# Hydrogen
techType = "Long-duration storage"
CAPEXLookup = scaleCAPEX(techType, CAPEXLookup, cost_HydrogenStorage_multiplier)
println("Hydrogen 2020 cost is: ", CAPEXLookup[CAPEXLookup[!, "Technology"] .== techType, "2020"][1], " \$/kW")
println("")



## Assign the appropriate cost scenario based on CleanElecCosts and CleanGasCosts
################################################################################
CostScenarios = CSV.read("$(foldername)/CostScenarios" * CDR_case * ".csv",DataFrame)

if CleanCosts == "Low"
    global CostScenarios = CSV.read("$(foldername)/CostScenariosLow$(cost_case).csv",DataFrame)
elseif CleanCosts == "High"
    global CostScenarios = CSV.read("$(foldername)/CostScenariosHigh$(cost_case).csv",DataFrame)
end

if techScenario_EGS == "Yes"
    println("Low cost EGS")
    CostScenarios[CostScenarios.Technology .== "Geothermal EGS", :Cost] .= "Low"
    println(CostScenarios[CostScenarios.Technology .== "Geothermal EGS", :])
    println("")
end

# Look up each technology, the associated calendar year in the data tables and assign
# it a cost value
################################################################################
for i = 1:T_inv
    for g = 1:GEN
        subset = findall(in([PrimeMover_GEN[g]]),CAPEXLookup.Technology)
        scen = findall(in([PrimeMover_GEN[g]]),CostScenarios.Technology)
        scen = findall(in([CostScenarios.Cost[scen[1]]]),CAPEXLookup.Cost)
        index = findall(in(subset),scen)
        index = scen[index[1]]
        CAPEX_GEN[i,g] = CAPEXLookup[index, Int(Years[i]-2019)]
        subset = findall(in([PrimeMover_GEN[g]]),FOMLookup.Technology)
        scen = findall(in([PrimeMover_GEN[g]]),CostScenarios.Technology)
        scen = findall(in([CostScenarios.Cost[scen[1]]]),FOMLookup.Cost)
        index = findall(in(subset),scen)
        index = scen[index[1]]
        FOM_GEN[i,g] = FOMLookup[index, Int(Years[i]-2019)]
        subset = findall(in([PrimeMover_GEN[g]]),VOMLookup.Technology)
        scen = findall(in([PrimeMover_GEN[g]]),CostScenarios.Technology)
        scen = findall(in([CostScenarios.Cost[scen[1]]]),VOMLookup.Cost)
        index = findall(in(subset),scen)
        index = scen[index[1]]
        VOM_GEN[i,g] = VOMLookup[index, Int(Years[i]-2019)]
        subset = findall(in([Fuel_GEN[g]]),FuelCostLookup.Fuel)
        scen = findall(in([Fuel_GEN[g]]),CostScenarios.Technology)
        scen = findall(in([CostScenarios.Cost[scen[1]]]),FuelCostLookup.Cost)
        index = findall(in(subset),scen)
        index = scen[index[1]]
        FuelCosts[i,g] = FuelCostLookup[index, Int(Years[i]-2019)]
    end
    for d = 1:P2G
        subset = findall(in([PrimeMover_P2G[d]]),CAPEXLookup.Technology)
        scen = findall(in([PrimeMover_P2G[d]]),CostScenarios.Technology)
        scen = findall(in([CostScenarios.Cost[scen[1]]]),CAPEXLookup.Cost)
        index = findall(in(subset),scen)
        index = scen[index[1]]
        CAPEX_P2G[i,d] = CAPEXLookup[index, Int(Years[i]-2019)]
        subset = findall(in([PrimeMover_P2G[d]]),FOMLookup.Technology)
        scen = findall(in([PrimeMover_P2G[d]]),CostScenarios.Technology)
        scen = findall(in([CostScenarios.Cost[scen[1]]]),FOMLookup.Cost)
        index = findall(in(subset),scen)
        index = scen[index[1]]
        FOM_P2G[i,d] = FOMLookup[index, Int(Years[i]-2019)]
        subset = findall(in([PrimeMover_P2G[d]]),VOMLookup.Technology)
        scen = findall(in([PrimeMover_P2G[d]]),CostScenarios.Technology)
        scen = findall(in([CostScenarios.Cost[scen[1]]]),VOMLookup.Cost)
        index = findall(in(subset),scen)
        index = scen[index[1]]
        VOM_P2G[i,d] = VOMLookup[index, Int(Years[i]-2019)]
    end
    for s = 1:STORAGE_ELEC
        subset = findall(in([PrimeMover_STORAGE_ELEC[s]]),CAPEXLookup.Technology)
        scen = findall(in([PrimeMover_STORAGE_ELEC[s]]),CostScenarios.Technology)
        scen = findall(in([CostScenarios.Cost[scen[1]]]),CAPEXLookup.Cost)
        index = findall(in(subset),scen)
        index = scen[index[1]]
        CAPEX_STORAGE_ELEC[i,s] = CAPEXLookup[index, Int(Years[i]-2019)]
        subset = findall(in([PrimeMover_STORAGE_ELEC[s]]),FOMLookup.Technology)
        scen = findall(in([PrimeMover_STORAGE_ELEC[s]]),CostScenarios.Technology)
        scen = findall(in([CostScenarios.Cost[scen[1]]]),FOMLookup.Cost)
        index = findall(in(subset),scen)
        index = scen[index[1]]
        FOM_STORAGE_ELEC[i,s] = FOMLookup[index, Int(Years[i]-2019)]
    end
    ### HEAT STORAGE + P2H
    for s = 1:STORAGE_HEAT
        # heat storage
        subset = findall(in([PrimeMover_STORAGE_HEAT[s]]),CAPEXLookup.Technology)
        scen = findall(in([PrimeMover_STORAGE_HEAT[s]]),CostScenarios.Technology)
        scen = findall(in([CostScenarios.Cost[scen[1]]]),CAPEXLookup.Cost)
        index = findall(in(subset),scen)
        index = scen[index[1]]
        CAPEX_STORAGE_HEAT[i,s] = CAPEXLookup[index, Int(Years[i]-2019)]
        #
        if s <= 16
            CAPEX_STORAGE_HEAT[i,s] = CAPEX_STORAGE_HEAT[i,s] * ( CAPEX_HB_perc/100 )
        end
        #
        subset = findall(in([PrimeMover_STORAGE_HEAT[s]]),FOMLookup.Technology)
        scen = findall(in([PrimeMover_STORAGE_HEAT[s]]),CostScenarios.Technology)
        scen = findall(in([CostScenarios.Cost[scen[1]]]),FOMLookup.Cost)
        index = findall(in(subset),scen)
        index = scen[index[1]]
        FOM_STORAGE_HEAT[i,s] = FOMLookup[index, Int(Years[i]-2019)]
        # steam turbine with the heat battery
        PM_SteamTurbine = "Steam Turbine"
        subset = findall(in([PM_SteamTurbine]),CAPEXLookup.Technology)
        scen = findall(in([PM_SteamTurbine]),CostScenarios.Technology)
        scen = findall(in([CostScenarios.Cost[scen[1]]]),CAPEXLookup.Cost)
        index = findall(in(subset),scen)
        index = scen[index[1]]
        CAPEX_STEAM_TURBINE[i,s] = CAPEXLookup[index, Int(Years[i]-2019)]
    end
    for d = 1:P2H
        subset = findall(in([PrimeMover_P2H[d]]),CAPEXLookup.Technology)
        scen = findall(in([PrimeMover_P2H[d]]),CostScenarios.Technology)
        scen = findall(in([CostScenarios.Cost[scen[1]]]),CAPEXLookup.Cost)
        index = findall(in(subset),scen)
        index = scen[index[1]]
        CAPEX_P2H[i,d] = CAPEXLookup[index, Int(Years[i]-2019)]
        subset = findall(in([PrimeMover_P2H[d]]),FOMLookup.Technology)
        scen = findall(in([PrimeMover_P2H[d]]),CostScenarios.Technology)
        scen = findall(in([CostScenarios.Cost[scen[1]]]),FOMLookup.Cost)
        index = findall(in(subset),scen)
        index = scen[index[1]]
        FOM_P2H[i,d] = FOMLookup[index, Int(Years[i]-2019)]
        subset = findall(in([PrimeMover_P2H[d]]),VOMLookup.Technology)
        scen = findall(in([PrimeMover_P2H[d]]),CostScenarios.Technology)
        scen = findall(in([CostScenarios.Cost[scen[1]]]),VOMLookup.Cost)
        index = findall(in(subset),scen)
        index = scen[index[1]]
        VOM_P2H[i,d] = VOMLookup[index, Int(Years[i]-2019)]
    end
    ###
    for a = 1:APPLIANCES
        subset = findall(in([PrimeMover_APPLIANCES[a]]),CAPEXLookup.Technology)
        scen = findall(in([PrimeMover_APPLIANCES[a]]),CostScenarios.Technology)
        scen = findall(in([CostScenarios.Cost[scen[1]]]),CAPEXLookup.Cost)
        index = findall(in(subset),scen)
        index = scen[index[1]]
        CAPEX_APPLIANCES[i,a] = CAPEXLookup[index, Int(Years[i]-2019)]
        subset = findall(in([PrimeMover_APPLIANCES[a]]),FOMLookup.Technology)
        scen = findall(in([PrimeMover_APPLIANCES[a]]),CostScenarios.Technology)
        scen = findall(in([CostScenarios.Cost[scen[1]]]),FOMLookup.Cost)
        index = findall(in(subset),scen)
        index = scen[index[1]]
        FOM_APPLIANCES[i,a] = FOMLookup[index, Int(Years[i]-2019)]
    end
    # CDR
    # idx_CDR_CCS = in(["CCS-Combustion", "CCS-Process"]).(techType_CDR)
    #
    for d = 1:CDR
        subset = findall(in([PrimeMover_CDR[d]]),CAPEXLookup.Technology)
        scen = findall(in([PrimeMover_CDR[d]]),CostScenarios.Technology)
        scen = findall(in([CostScenarios.Cost[scen[1]]]),CAPEXLookup.Cost)
        index = findall(in(subset),scen)
        index = scen[index[1]]
        CAPEX_CDR[i,d] = CAPEXLookup[index, Int(Years[i]-2019)]
        #
        # if idx_CDR_CCS[d]
        #     CAPEX_CDR[i,d] = CAPEX_CDR[i,d] * ( CAPEX_CCS_perc/100 )
        # end
        #
        subset = findall(in([PrimeMover_CDR[d]]),FOMLookup.Technology)
        scen = findall(in([PrimeMover_CDR[d]]),CostScenarios.Technology)
        scen = findall(in([CostScenarios.Cost[scen[1]]]),FOMLookup.Cost)
        index = findall(in(subset),scen)
        index = scen[index[1]]
        FOM_CDR[i,d] = FOMLookup[index, Int(Years[i]-2019)]
        subset = findall(in([PrimeMover_CDR[d]]),VOMLookup.Technology)
        scen = findall(in([PrimeMover_CDR[d]]),CostScenarios.Technology)
        scen = findall(in([CostScenarios.Cost[scen[1]]]),VOMLookup.Cost)
        index = findall(in(subset),scen)
        index = scen[index[1]]
        VOM_CDR[i,d] = VOMLookup[index, Int(Years[i]-2019)]
    end
end

### manual scalings of cost for sensitivities
if scalingFactor_CM != 1
    println("Carbon Management, Costs scaled:")
    println(scalingFactor_CM)
    #
    CAPEX_CDR .*= scalingFactor_CM
    FOM_CDR   .*= scalingFactor_CM
end

if scalingFactor_H2 != 1
    println("H2-to-heat, Costs scaled:")
    println(scalingFactor_H2)
    #
    CAPEX_STORAGE_HEAT[:, idx_HS_H2] .*= scalingFactor_H2
    FOM_STORAGE_HEAT[:, idx_HS_H2]   .*= scalingFactor_H2
end

if scalingFactor_HB != 1
    println("Heat Battery, Costs scaled:")
    println(scalingFactor_HB)
    #
    CAPEX_STORAGE_HEAT[:, idx_HS_HB] .*= scalingFactor_HB
    FOM_STORAGE_HEAT[:, idx_HS_HB]   .*= scalingFactor_HB
end

if scalingFactor_EH != 1
    println("Resistance Heater, Costs scaled:")
    println(scalingFactor_EH)
    #
    CAPEX_P2H[:, idx_P2H_resHeater] .*= scalingFactor_EH
    FOM_P2H[:, idx_P2H_resHeater]   .*= scalingFactor_EH
end

if scalingFactor_HP != 1
    println("Heat Pump, Costs scaled:")
    println(scalingFactor_HP)
    #
    CAPEX_P2H[:, idx_P2H_heatPump] .*= scalingFactor_HP
    FOM_P2H[:, idx_P2H_heatPump]   .*= scalingFactor_HP
end