################################################################################
### Policy-driven constraints
################################################################################

if consider_refrigerants >= 1
    include("refrigerants.jl")
    @variable(m, excess_refEmissions[I = 1:T_inv] >= 0)
else
    appliance_leak = zeros(T_inv,APPLIANCES)
    excess_refEmissions = zeros(T_inv)
end

if methaneLeak_ON == 1
    excess_fugitiveMethaneEmissions = zeros(T_inv)
else
    excess_fugitiveMethaneEmissions = zeros(T_inv)
end

excess_processEmissions = zeros(T_inv)


### Nominal allocation of net-zero emissions gas consumption to each sector, 
# not to exceed the amount of gaseous energy consumed by that sector
# See Eq. 2.62 in Von Wald thesis
################################################################################
@variable(m, CleanGas_gassector[I = 1:T_inv] >= 0)
@variable(m, CleanGas_powersector[I = 1:T_inv] >= 0)
@variable(m, CleanGas_allsectors[I = 1:T_inv] >= 0)
@constraint(m, [I = 1:T_inv], CleanGas_gassector[I] + CleanGas_powersector[I] == CleanGas_allsectors[I])
@constraint(m, [I = 1:T_inv], CleanGas_allsectors[I] == sum(weights[I,T]*8760/t_ops*sum(sum(P2G_dispatch[I,T,t,d]*eta_P2G[d] for d = 1:P2G) for t = 1:t_ops) for T = 1:T_ops))
@constraint(m, [I = 1:T_inv], CleanGas_powersector[I] <= sum(weights[I,T]*8760/t_ops*sum(sum((generation[I,T,t,g]*HeatRate[g] + startup_GEN[I,T,t,g]*StartupFuel[g])*MWh_PER_MMBTU*NG_fueled[g] for g = 1:GEN) for t = 1:t_ops) for T = 1:T_ops))
@constraint(m, [I = 1:T_inv], CleanGas_gassector[I] <= sum(weights[I,T]*8760/t_ops*sum(sum(Demand_GAS[I,T,t,n] for n = 1:NODES_GAS) for t = 1:t_ops) for T = 1:T_ops))


### Slack variables for emissions constraint violations that could represent:
#   > use of negative emissions offsets at a fixed cost 
#   > excess carbon emissions evaluated in objective function at a "social cost of carbon"
# The power and gas sector emissions that exceed their respective emissions intensity constraint are constrained by the maxOffsets share of total emissions liabilities
# See Eq. 2.61 in Von Wald thesis
################################################################################
@variable(m, excess_powerEmissions[I = 1:T_inv] >= 0)
@variable(m, excess_gasEmissions[I = 1:T_inv] >= 0)
if allsector_emissions_constraint >= 1
    @constraint(m, [I = 1:T_inv], excess_powerEmissions[I] + excess_gasEmissions[I] + excess_refEmissions[I] + excess_fugitiveMethaneEmissions[I] <= maxOffsets[I]*initialEmissions)
else
    @constraint(m, [I = 1:T_inv], excess_powerEmissions[I] <= maxOffsets_elec[I]*(sum(weights[I,T]*8760/t_ops*sum(sum((generation[I,T,t,g]*HeatRate[g] + startup_GEN[I,T,t,g]*StartupFuel[g])*emissions_factors[g] for g = 1:GEN) for t = 1:t_ops) for T = 1:T_ops)))
    @constraint(m, [I = 1:T_inv], excess_gasEmissions[I] <= maxOffsets_gas[I]*(sum(weights[I,T]*8760/t_ops*EF_NG*sum(sum(Demand_GAS[I,T,t,n] for n = 1:NODES_GAS) for t = 1:t_ops) for T = 1:T_ops)))
end
### Constraints on the emissions intensity of the electric and gas sectors.
# Here, some emissions from gaseous fuel consumption are offset by the nominal allocation of net-zero emission gas to each sector.
# See Eq. 2.60 in Von Wald thesis
################################################################################
if allsector_emissions_constraint == 1
    @variable(m, powerEmissions[I = 1:T_inv] >= 0)              # MMTCO2
    @variable(m, gasEmissions[I = 1:T_inv] >= 0)                # MMTCO2
    @variable(m, appEmissions[I = 1:T_inv] >= 0)                # MMTCO2
    @variable(m, fugitiveMethaneEmissions[I = 1:T_inv] >= 0)    # MMTCO2
    @variable(m, processEmissions[I = 1:T_inv] >= 0)            # MMTCO2
    # CDR
    @variable(m, removedEmissions_CDR[I = 1:T_inv] >= 0)            # MMTCO2
    @constraint(m, [I = 1:T_inv], removedEmissions_CDR[I] == sum(weights[I,T]*8760/t_ops*sum(sum( CDR_dispatch[I,T,t,d] for d = 1:CDR) for t = 1:t_ops) for T = 1:T_ops) / 1e6 )     # divide by 1e6 to get MMTCO2
    
    # if CDR is not used for industrial heat, limit to non-point source emissions and other fugitive leaks
    # get DACCS index
    idx_CDR_DACCS = in(["DAC-LS", "DAC-SS"]).(PrimeMover_CDR)
    # get CCS indices
    idx_CDR_CCScombustion_all = in(["CCS-Combustion", "CCS-GasUse"]).(techType_CDR)
    #
    idx_CDR_CCScombustion_heat   = techType_CDR .== fill("CCS-Combustion", length(techType_CDR))
    idx_CDR_CCScombustion_gasUse = techType_CDR .== fill("CCS-GasUse", length(techType_CDR))
    idx_CDR_CCSprocess           = techType_CDR .== fill("CCS-Process", length(techType_CDR))
    

    # limit captured carbon to only be used for process emissions
    # in doing this, we limit DAC to be built in the node of emission
    @constraint(m, [I = 1:T_inv, T = 1:T_ops, t = 1:t_ops, n = 1:NODES_ELEC], sum(CDR_NodalLoc_ELEC[n,d]*CDR_dispatch[I,T,t,d] / carbonRemoved_CDR[d] for d in findall(idx_CDR_CCSprocess)) 
                                                                           <= sum( PROCESS_NodalLoc_ELEC[n,p] * InitialProcessNumber[p] * 1 * PointSourceEmissions[p]*decline_processEmissions[p,I] for p = 1:PROCESS))
    # constraint on CCS for gas-use
    @constraint(m, [I = 1:T_inv, T = 1:T_ops, t = 1:t_ops, n = 1:NODES_GAS], sum(CDR_NodalLoc_ELEC[n,d] * CDR_dispatch[I,T,t,d] / carbonRemoved_CDR[d] for d in findall(idx_CDR_CCScombustion_gasUse)) <= EF_NG * CDR_Demand_fromGAS[I,T,t,n])
    
    if DACCS4industrialHeat_ON == 0
        #
        println("DACCS will not be used for industrial heat.")
        ### DAC ONLY
        # total CDR removed by DAC is at most the fugitive emissions + remaining that wasnt captured by CCS-process
        # @constraint(m, [I = 1:T_inv], sum( weights[I,T]*8760/t_ops * sum( sum( CDR_dispatch[I,T,t,d] for d in findall(idx_CDR_DACCS) ) for t = 1:t_ops ) for T = 1:T_ops ) 
        #                            <= 10e6 ) 
        # @constraint(m, [I = 1:T_inv], sum( weights[I,T]*8760/t_ops * sum( sum( CDR_dispatch[I,T,t,d] for d in findall(idx_CDR_DACCS) ) for t = 1:t_ops ) for T = 1:T_ops ) 
        #                            <= 1.1 * (appEmissions[I] * 1e6 + fugitiveMethaneEmissions[I] * 1e6 + sum( InitialProcessNumber[p] * 1 * NonPtSourceEmissions[p] * 8760 for p = 1:PROCESS) ) ) 

        ### CCS ONLY
        # CCS for process emissions
        # @constraint(m, [I = 1:T_inv, T = 1:T_ops, t = 1:t_ops, n = 1:NODES_ELEC], sum(CDR_NodalLoc_ELEC[n,d]*CDR_dispatch[I,T,t,d] for d in findall(idx_CDR_CCSprocess)) == 0)
        # zero out CCS for combustion for heat
        @constraint(m, [I = 1:T_inv, T = 1:T_ops, t = 1:t_ops, n = 1:NODES_ELEC], sum(CDR_NodalLoc_ELEC[n,d]*CDR_dispatch[I,T,t,d] for d in findall(idx_CDR_CCScombustion_heat)) == 0)
        @constraint(m, [I = T_inv, T = 1:T_ops, t = 1:t_ops, n = 1:NODES_GAS], Industrial_HeatDemand_fromGAS_heatMagnitude[I,T,t,n] == 0)

    else
        println("DACCS will be used for industrial heat.")
        # constraint on CCS to being limited to utilized industrial gas
        @constraint(m, [I = 1:T_inv, T = 1:T_ops, t = 1:t_ops, n = 1:NODES_GAS], sum(CDR_NodalLoc_ELEC[n,d] * CDR_dispatch[I,T,t,d] / carbonRemoved_CDR[d] for d in findall(idx_CDR_CCScombustion_all)) <= EF_NG * (CDR_Demand_fromGAS[I,T,t,n] + Industrial_HeatDemand_fromGAS[I,T,t,n]) )
        # constraint on each service type; in the most common industry case, we constrain CCS based on temperature
        @constraint(m, [I = 1:T_inv, T = 1:T_ops, t = 1:t_ops, n = 1:NODES_GAS, s = 1:numIndustrialSERVICES], sum(CDR_NodalLoc_ELEC[n,d] * CDR_dispatch[I,T,t,d] / carbonRemoved_CDR[d] * IndustrialCCSMatching[d,s] for d in findall(idx_CDR_CCScombustion_heat)) 
                                                                                                           <= EF_NG * ( sum(INDUSTRIAL_NodalLoc_GAS[n,a]*(unitsremaining_INDUSTRIAL[I,a])*IndustrialProfiles_GAS[T,t,a]*IndustrialPeakDemand[a]*decline_heatDemand[a,I] * IndustrialToServices[a,s] for a = 1:INDUSTRIAL) ))
    end


    #
    @constraint(m, [I = 1:T_inv], powerEmissions[I] + gasEmissions[I] + appEmissions[I] + fugitiveMethaneEmissions[I] + processEmissions[I]
                               <= TotalEmissions_Allowed[I] + removedEmissions_CDR[I] + EF_NG*CleanGas_allsectors[I] / 1e6)     # MMTCO2
    @constraint(m, [I = 1:T_inv], sum(appliance_leak[I,a] for a = 1:APPLIANCES)*1e6 <= appEmissions[I]*1e6 + excess_refEmissions[I])     # MMTCO2
    @constraint(m, [I = 1:T_inv], sum(weights[I,T]*8760/t_ops*sum(sum((generation[I,T,t,g]*HeatRate[g] + startup_GEN[I,T,t,g]*StartupFuel[g])*emissions_factors[g] for g = 1:GEN) for t = 1:t_ops) for T = 1:T_ops) <= powerEmissions[I]*1e6 + excess_powerEmissions[I])
    @constraint(m, [I = 1:T_inv], sum(weights[I,T]*8760/t_ops*EF_NG*sum(sum(Demand_GAS[I,T,t,n] for n = 1:NODES_GAS) for t = 1:t_ops) for T = 1:T_ops) <= gasEmissions[I]*1e6 + excess_gasEmissions[I])
    # fugitive methane
    @constraint(m, [I = 1:T_inv], sum(weights[I,T]*8760/t_ops*sum(SUPPLY_GAS_slack[I,T,n]*t_ops for n = 1:NODES_GAS) for T = 1:T_ops) * methane_leakage / EnergyContent_methane * GWP100_methane <= fugitiveMethaneEmissions[I]*1e6 + excess_fugitiveMethaneEmissions[I])     # MMTCO2
    # process emissions
    @constraint(m, process_emissions_constraint[I = 1:T_inv], 
                                  sum(sum(weights[I,T]*8760/t_ops*sum(sum( PROCESS_NodalLoc_ELEC[n,p] * InitialProcessNumber[p] * 1 * (PointSourceEmissions[p]*decline_processEmissions[p,I] + NonPtSourceEmissions[p]) for p = 1:PROCESS) for n = 1:NODES_GAS) for t = 1:t_ops) for T = 1:T_ops)
                               <= processEmissions[I]*1e6 + excess_processEmissions[I])     # MMTCO2
    println(process_emissions_constraint[1])


elseif allsector_emissions_constraint == 0
    @constraint(m, [I = 1:T_inv], sum(weights[I,T]*8760/t_ops*sum(sum((generation[I,T,t,g]*HeatRate[g] + startup_GEN[I,T,t,g]*StartupFuel[g])*emissions_factors[g] for g = 1:GEN) for t = 1:t_ops) for T = 1:T_ops)  <= EI_ElecSector[I]/1000*sum(weights[I,T]*8760/t_ops*sum(sum(generation[I,T,t,g0] for g0 = 1:GEN) for t = 1:t_ops) for T = 1:T_ops) + excess_powerEmissions[I])
    @constraint(m, [I = 1:T_inv], sum(weights[I,T]*8760/t_ops*EF_NG*sum(sum(Demand_GAS[I,T,t,n] for n = 1:NODES_GAS) for t = 1:t_ops) for T = 1:T_ops) <= EI_GasSector[I]/1000*sum(weights[I,T]*8760/t_ops*sum(sum(Demand_GAS[I,T,t,n] for n = 1:NODES_GAS) for t = 1:t_ops) for T = 1:T_ops) + excess_gasEmissions[I])

end
# # case where we impose no emission constraint
# elseif allsector_emissions_constraint == 2
#     @variable(m, powerEmissions[I = 1:T_inv] >= 0)          # MMTCO2
#     @variable(m, gasEmissions[I = 1:T_inv] >= 0)            # MMTCO2
#     @variable(m, appEmissions[I = 1:T_inv] >= 0)            # MMTCO2
#     @variable(m, fugitiveMethaneEmissions[I = 1:T_inv] >= 0)    # MMTCO2

#     # CDR
#     @variable(m, removedEmissions_CDR[I = 1:T_inv] >= 0)            # MMTCO2
#     @constraint(m, [I = 1:T_inv], removedEmissions_CDR[I] == sum(weights[I,T]*8760/t_ops*sum(sum( CDR_dispatch[I,T,t,d]  for d = 1:CDR) for t = 1:t_ops) for T = 1:T_ops) / 1e6 )     # divide by 1e6 to get MMTCO2
#     # remove the following constraint:
#     # @constraint(m, [I = 1:T_inv], powerEmissions[I] + gasEmissions[I] + appEmissions[I] <= TotalEmissions_Allowed[I] + removedEmissions_CDR[I])     # MMTCO2
#     #
#     @constraint(m, [I = 1:T_inv], sum(appliance_leak[I,a] for a = 1:APPLIANCES)*1e6 <= appEmissions[I]*1e6 + excess_refEmissions[I])     # MMTCO2
#     @constraint(m, [I = 1:T_inv], sum(weights[I,T]*8760/t_ops*sum(sum((generation[I,T,t,g]*HeatRate[g] + startup_GEN[I,T,t,g]*StartupFuel[g])*emissions_factors[g] for g = 1:GEN) for t = 1:t_ops) for T = 1:T_ops) - EF_NG*CleanGas_powersector[I]   <= powerEmissions[I]*1e6 + excess_powerEmissions[I])
#     @constraint(m, [I = 1:T_inv], sum(weights[I,T]*8760/t_ops*EF_NG*sum(sum(Demand_GAS[I,T,t,n] for n = 1:NODES_GAS) for t = 1:t_ops) for T = 1:T_ops) - EF_NG*CleanGas_gassector[I] <= gasEmissions[I]*1e6 + excess_gasEmissions[I])
#     # fugitive methane
#     @constraint(m, [I = 1:T_inv], sum(weights[I,T]*8760/t_ops*sum(sum(CDR_Demand_fromGAS[I,T,t,n] for n = 1:NODES_GAS) for t = 1:t_ops) for T = 1:T_ops) * methane_leakage / EnergyContent_methane * GWP100_methane <= fugitiveMethaneEmissions[I]*1e6 + excess_fugitiveMethaneEmissions[I])     # MMTCO2

# end

### Maximum biomethane production and use of sustainable bio-energy. 
# Total bio-energy constraint is included in the case where net-zero emissions fuel production units can be used to generate methane or LPG fuel
# but must compete for sustainable biomass feedstocks.
# See Eq. 2.63 in Von Wald thesis
################################################################################
@constraint(m, [I = 1:T_inv], maxBiomethane[I] >= sum(weights[I,T]*8760/t_ops*sum(sum(ISBIOMETHANE[d]*P2G_dispatch[I,T,t,d]*eta_P2G[d] for d = 1:P2G) for t = 1:t_ops) for T = 1:T_ops))
@constraint(m, [I = 1:T_inv], maxSustainableBiomass[I] >= sum(weights[I,T]*8760/t_ops*sum(sum(ISBIOMASS[d]*P2G_dispatch[I,T,t,d]*(eta_P2G[d]+eta_P2L[d]) for d = 1:P2G) for t = 1:t_ops) for T = 1:T_ops))


###############################################################################
### Gas distribution retirement constraint set
# See Eq. 2.69 in Von Wald thesis
###############################################################################
# User can select whether to allow the model to decide when the retire the gas system
# by setting gasdistretirement_allowed = 1.
# In this case, binary variables are introduced to indicate for each distribution system
# when that system is shut down.
if gasdistretirement_allowed == 1
    # @variable(m, distSysRetirement_GAS[I = 1:T_inv, d = 1:DIST_GAS], Bin)
    # @constraint(m, [I = 1:T_inv, d = 1:DIST_GAS], (1-sum(distSysRetirement_GAS[j,d] for j = 1:I))*sum(sum(InitialAppliancePopulation[a]/1000*ApplianceProfilesGAS[t,a] for t = 1:8760) for a = 1:APPLIANCES) >= sum(sum(sum(APP_DistSystemLoc_GAS[d,a]*(unitsremaining_APPS[I,a])*ApplianceProfiles_GAS[T,t,a] for a = 1:APPLIANCES) for t= 1:t_ops) for T = 1:T_ops))
    @variable(m, distSysRetirement_GAS[I = 1:T_inv, d = 1:DIST_GAS] >= 0)
    @constraint(m, [I = 1:T_inv, d = 1:DIST_GAS], (1-sum(distSysRetirement_GAS[j,d] for j = 1:I))*sum(APP_DistSystemLoc_GAS[d,a]*InitialAppliancePopulation[a]/1000 for a = gasApps) >= sum(APP_DistSystemLoc_GAS[d,a]*(unitsremaining_APPS[I,a]) for a = gasApps))
    @constraint(m, [d = 1:DIST_GAS], sum(distSysRetirement_GAS[j,d] for j = 1:T_inv) <= 1)

# Use may also select whether to force the model to shut down gas distribution systems
# by using gasdistretirement_forced with a 1 in the year where the system must be shut down.
# Currently all distribution systems must be shut down in the same year.
elseif sum(gasdistretirement_forced) >= 1
    region_index = 1:DIST_GAS
    distSysRetirement_GAS = zeros(T_inv,DIST_GAS)
    if region_retire == "North"
        region_index = [1,2,3,4,11,12,16]
    elseif region_retire == "South"
        region_index = [5,6,7,8,9,10,13,14,15]
    elseif region_retire == "Cities"
        region_index = [3,4,6,7,8,9,12]
    end
    for ii = 1:T_inv
        distSysRetirement_GAS[ii,region_index] .= gasdistretirement_forced[ii]
    end
    # And delivered gas volumes are constrained to be 0 during and after this designated shut-down year:
    @constraint(m, [I = 1:T_inv, d = 1:DIST_GAS], (1-sum(distSysRetirement_GAS[j,d] for j = 1:I))*sum(APP_DistSystemLoc_GAS[d,a]*InitialAppliancePopulation[a]/1000 for a = gasApps) >= sum(APP_DistSystemLoc_GAS[d,a]*(unitsremaining_APPS[I,a]) for a = gasApps))

# If no gas distribution retirement is contemplated by the model, the distSysRetirement_GAS indicators are fixed parameters
else
    distSysRetirement_GAS = zeros(T_inv,DIST_GAS)
end

## The gas distribution system fixed costs are then computed based on these shut-down decisions:
# Not explicitly included in Von Wald thesis
###############################################################################
@variable(m, gasdistsyst_Cost[I = 1:T_inv] >= 0)
# Gas distribution system cost includes several terms that will be either active or zero depending on whether the retirement decision is made:
@constraint(m, [I = 1:T_inv], gasdistsyst_Cost[I] == sum(sum(AccDepGasSyst_FixedCosts[d,j,I]/1000*distSysRetirement_GAS[j,d] for d = 1:DIST_GAS) for j = 1:T_inv) + sum(BAUGasSyst_FixedCosts[d,I]/1000*(1-sum(distSysRetirement_GAS[j,d] for j = 1:T_inv)) for d = 1:DIST_GAS))


###############################################################################
### Ancillary customer electrification costs 
# See Eq. 2.66 in Von Wald thesis
###############################################################################
@variable(m, applianceInfrastructureCosts[I = 1:T_inv, a = 1:APPLIANCES] >= 0)
@constraint(m,[I = 1, a = 1:APPLIANCES], applianceInfrastructureCosts[I,a] >= unitsbuilt_APPS[I,a]*1000*upgrade_cost[a])
if T_inv > 1
    @constraint(m,[I = 2:T_inv, a = 1:APPLIANCES], applianceInfrastructureCosts[I,a] >= 1000*(unitsbuilt_APPS[I,a] - sum(round(cumulativefailurefrac[a,v,I]-cumulativefailurefrac[a,v,I-1],digits = 4)*unitsbuilt_APPS[v,a] for v = 1:I-1))*upgrade_cost[a])
end

###############################################################################
# Generalized distribution capital costs associated with peak electrical demand
# See Eq. 2.67/2.68 in Von Wald thesis
# Currently implement a few different approaches to compute:
# (a) the total peak power demand at each node
# (b) the peak distribution-level demand at each node
# (c) the peak incremental distribution-level demand due to appliance electrification (i.e., above baseline demand)
# Current version uses PeakDistDemandInc in objective function, but an argument could be made
# that the peak costs should be evaluated with respect to system-wide coincident peak, as opposed to
# the sum of individual nodal peaks.
###############################################################################
@variable(m, PeakDemand[I = 1:T_inv, n = 1:NODES_ELEC] >= 0)
@variable(m, PeakDistDemand[I = 1:T_inv, n = 1:NODES_ELEC] >= 0)
@variable(m, PeakDistDemandInc[I = 1:T_inv, n = 1:NODES_ELEC] >= 0)
@constraint(m, [I = 1:T_inv, T = 1:T_ops, t = 1:t_ops, n = 1:NODES_ELEC], PeakDemand[I,n] >= Demand_ELEC[I,T,t,n] + sum(STORAGE_ELEC_NodalLoc_ELEC[n,s]*(charging_ELEC[I,T,t,s]-discharging_ELEC[I,T,t,s]) for s = 1:STORAGE_ELEC) + sum(P2G_NodalLoc_ELEC[n,d]*P2G_dispatch[I,T,t,d]*(1-ISBIOMETHANE[d]) for d = 1:P2G) + sum(P2H_NodalLoc_ELEC[n,d]*P2H_dispatch[I,T,t,d] for d = 1:P2H) + sum(CDR_NodalLoc_ELEC[n,d]*CDR_dispatch[I,T,t,d]*elecConsumed_CDR[d] for d = 1:CDR) )
@constraint(m, [I = 1:T_inv, t = 1:8760, n = 1:NODES_ELEC], PeakDistDemand[I,n] >= D_Elec[t,n] + 1000*sum(APPLIANCES_NodalLoc_ELEC[n,a]*(unitsremaining_APPS[I,a])*ApplianceProfilesELEC[t,a] for a = 1:APPLIANCES))
@constraint(m, [I = 1:T_inv, T = 1:T_ops, t = 1:t_ops, n = 1:NODES_ELEC], PeakDistDemandInc[I,n] >= Demand_ELEC[I,T,t,n] - BaselineDemand_ELEC[I,T,t,n])


###############################################################################
### CDR Tax Credit Revenue
# TBD
###############################################################################
# settings particular to IRA 45Q
# T_taxEndDate = 2 # tax credit is for DAC plants built before 2032; last investment period is 2030
# taxLength = [
#     1    1    2/5   0    0;
#     0    1    1     2/5  0
# ]               # tax is valid for 12 years from when DAC plant is built; we have array of row size = T_taxEndDate



# # CDR tax credit
# @variable(m, taxCredit_CDR_Q[Q = 1:T_taxEndDate, I = 1:T_inv] >= 0)
# # amount of carbon removed
# @variable(m, carbonRemoved[I = 1:T_inv] >= 0)
# @constraint(m, [I = 1:T_inv], carbonRemoved[I] == sum(weights[I,T]*8760/t_ops*sum(sum(CDR_dispatch[I,T,t,d] for t = 1:t_ops) for d = 1:CDR) for T = 1:T_ops))   # t, in that year

# # new removals, we separate the tax to account for tracking of carbon removal capacity that qualifies for the IRA 45Q
# @variable(m, newCarbonRemovals[Q = 1:T_taxEndDate] >= 0)
# #
# @variable(m, maxDACremoval[Q = 1:T_taxEndDate] >= 0)
# @constraint(m, [Q = 1:T_taxEndDate], maxDACremoval[Q] == sum(maxCapacityFactor_CDR[d] * 8760 * UnitSize_CDR[d] * (unitsbuilt_CDR[Q,d] - unitsretired_CDR[Q,d]) for d=1:CDR) )


# # 2 limits: (1) total CO2 removed in that year, & (2) total available removals from builds in that year ONLY
# # @constraint(m, [Q = 1, I = Q], newCarbonRemovals[Q] <= carbonRemoved[I])
# # @constraint(m, [Q = 2, I = Q], newCarbonRemovals[Q] <= carbonRemoved[I])
# @constraint(m, [Q = 1], newCarbonRemovals[Q] <= maxDACremoval[Q] )
# @constraint(m, [Q = 2], newCarbonRemovals[Q] <= maxDACremoval[Q] )



# # here we quantify the 45Q removal; over 12 years
# # a big assumption is that the DAC plant continues to run at the same capacity for subsq yrs, but this is expected if DAC investments are made
# @variable(m, carbonRemoved_fromInvQ[Q = 1:T_taxEndDate, I = 1:T_inv])
# @constraint(m, [Q = 1:T_taxEndDate, I = 1:T_inv], carbonRemoved_fromInvQ[Q,I] <= newCarbonRemovals[Q] * taxLength[Q,I]) 

# # calculate individual build-tax credit
# @constraint(m, [Q = 1:T_taxEndDate, I = 1:T_inv], taxCredit_CDR_Q[Q,I] == IRA_DAC_taxCredit * carbonRemoved_fromInvQ[Q,I] )
# # create total tax credit amount
# @variable(m, taxCredit_CDR[I = 1:T_inv] >= 0)
# @constraint(m, [I = 1:T_inv], taxCredit_CDR[I] == sum(taxCredit_CDR_Q[Q,I] for Q = 1:T_taxEndDate) )
@variable(m, taxCredit_CDR[I = 1:T_inv] >= 0)
@constraint(m, [I = 1:T_inv], taxCredit_CDR[I] == 0 )

# idx_gasAppliances = [x in ["GasFiredWH", "GasFurnace_SpaceHeat", "GasRange_Res", "GasFiredWHComm", "GasFurnace_SpaceHeatComm", "AC_GasFurnace", "AC_GasFurnaceComm"] for x in PrimeMover_APPLIANCES]
# @constraint(m, [I = T_inv, a = findall(idx_gasAppliances)], unitsremaining_APPS[I,a] == 0)