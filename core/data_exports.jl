################################################################################
################################################################################
## Export results for visualization
################################################################################
################################################################################
unitsbuilt_GEN = JuMP.value.(unitsbuilt_GEN)
unitsretired_GEN = JuMP.value.(unitsretired_GEN)
unitsbuilt_STORAGE_ELEC = JuMP.value.(unitsbuilt_STORAGE_ELEC)
unitsretired_STORAGE_ELEC = JuMP.value.(unitsretired_STORAGE_ELEC)
unitsbuilt_P2G = JuMP.value.(unitsbuilt_P2G)
unitsretired_P2G = JuMP.value.(unitsretired_P2G)
unitsbuilt_STORAGE_GAS = JuMP.value.(unitsbuilt_STORAGE_GAS)
unitsretired_STORAGE_GAS = JuMP.value.(unitsretired_STORAGE_GAS)
unitsbuilt_TRANS_GAS = JuMP.value.(unitsbuilt_TRANS_GAS)
unitsretired_TRANS_GAS = JuMP.value.(unitsretired_TRANS_GAS)
unitsbuilt_TRANS_ELEC = JuMP.value.(unitsbuilt_TRANS_ELEC)
unitsretired_TRANS_ELEC = JuMP.value.(unitsretired_TRANS_ELEC)
addflow_TRANS_ELEC = JuMP.value.(addflow_TRANS_ELEC)

Demand_GAS = JuMP.value.(Demand_GAS)
Demand_ELEC = JuMP.value.(Demand_ELEC)

if gasdistretirement_allowed == 1
    distSysRetirement_GAS = JuMP.value.(distSysRetirement_GAS)
end

CleanGas_gassector = JuMP.value.(CleanGas_gassector)
CleanGas_powersector = JuMP.value.(CleanGas_powersector)
unitsbuilt_APPS= JuMP.value.(unitsbuilt_APPS)

# EmissionsAndCosts = zeros(25,T_inv)
# for i = 1:T_inv
#     # Terms for computing average electricity and gas rates
#     xA = sum(UnitSize_GEN[g]*sum(unitsbuilt_GEN[i0,g]*CRF_GEN[g]*max(min((Years[i0]+EconomicLifetime_GEN[g])-Years[i],1),0)*1000*CAPEX_GEN[i0,g] for i0 = 1:i) + UnitSize_GEN[g]*(NumUnits_GEN[g]+sum(unitsbuilt_GEN[i0,g]-unitsretired_GEN[i0,g] for i0 = 1:i))*1000*FOM_GEN[i,g] for g = 1:GEN) +  sum(weights[i,T]*8760/t_ops*sum(sum((VOM_GEN[i,g]+HeatRate[g]*FuelCosts[i,g])*JuMP.value.(generation[i,T,t,g]) for t = 1:t_ops) for g = 1:GEN) for T = 1:T_ops) + sum(weights[i,T]*8760/t_ops*sum((StartUpCosts[g]+StartupFuel[g]*FuelCosts[i,g])*sum(JuMP.value.(startup_GEN[i,T,t,g]) for t = 1:t_ops)  for g = 1:GEN) for T = 1:T_ops) + sum(UnitSize_STORAGE_ELEC[s]*sum(unitsbuilt_STORAGE_ELEC[i0,s]*max(min((Years[i0]+EconomicLifetime_STORAGE_ELEC[s])-Years[i],1),0)*CRF_STORAGE_ELEC[s]*1000*CAPEX_STORAGE_ELEC[i0,s] for i0 = 1:i)  + UnitSize_STORAGE_ELEC[s]*(NumUnits_STORAGE_ELEC[s]+sum(unitsbuilt_STORAGE_ELEC[i0,s] - unitsretired_STORAGE_ELEC[i0,s] for i0 = 1:i))*1000*FOM_STORAGE_ELEC[i,s] for s = 1:STORAGE_ELEC) + Cost_DistributionInfrastructure*1000*sum(JuMP.value.(PeakDistDemand[i,n]) for n = 1:NODES_ELEC) + offsets_Cost[i]*JuMP.value.(excess_powerEmissions[i]) - CommodityCost_NG[i]*CleanGas_powersector[i]
#     xB = CleanGas_powersector[i]
#     xC = sum(weights[i,T]*8760/t_ops*sum(sum(JuMP.value.(generation[i,T,t,g]) for g = 1:GEN) for t = 1:t_ops) for T = 1:T_ops)
#     xD = sum(UnitSize_P2G[d]*sum(unitsbuilt_P2G[i0,d]*CRF_P2G[d]*1000*CAPEX_P2G[i0,d]  for i0 = 1:i) + UnitSize_P2G[d]*(NumUnits_P2G[d] + sum(unitsbuilt_P2G[i0,d] - unitsretired_P2G[i0,d] for i0 = 1:i))*1000*FOM_P2G[i,d] for d = 1:P2G) + sum(weights[i,T]*8760/t_ops*sum(sum(VOM_P2G[i,d]*JuMP.value.(P2G_dispatch[i,T,t,d]) for t = 1:t_ops) for d = 1:P2G) for T = 1:T_ops)
#     xE = sum(weights[i,T]*8760/t_ops*sum(sum(JuMP.value.(P2G_dispatch[i,T,t,d])*(1-ISBIOMETHANE[d]) for t = 1:t_ops) for d = 1:P2G) for T = 1:T_ops)
#     xF = sum(weights[i,T]*8760/t_ops*sum(sum(JuMP.value.(P2G_dispatch[i,T,t,d])*eta_P2G[d] for t = 1:t_ops) for d = 1:P2G) for T = 1:T_ops)
#     xG = CommodityCost_NG[i]*(sum(weights[i,T]*8760/t_ops*sum(sum(JuMP.value.(Demand_GAS[i,T,t,n]) for n = 1:NODES_GAS) for t = 1:t_ops) for T = 1:T_ops)) + JuMP.value.(gasdistsyst_Cost[i])*1000 + sum(UnitSize_STORAGE_GAS[s]*sum(unitsbuilt_STORAGE_GAS[i0,s]*CRF_STORAGE_GAS[s]*1000*CAPEX_STORAGE_GAS[i0,s]  for i0 = 1:i) + UnitSize_STORAGE_GAS[s]*(NumUnits_STORAGE_GAS[s]+sum(unitsbuilt_STORAGE_GAS[i0,s] - unitsretired_STORAGE_GAS[i0,s]  for i0 = 1:i))*1000*FOM_STORAGE_GAS[i,s] for s = 1:STORAGE_GAS) + offsets_Cost[i]*JuMP.value.(excess_gasEmissions[i])  - CommodityCost_NG[i]*CleanGas_gassector[i]
#     xH = CleanGas_gassector[i]
#     xI = sum(weights[i,T]*8760/t_ops*sum(sum(JuMP.value.(Demand_GAS[i,T,t,n]) for n = 1:NODES_GAS) for t = 1:t_ops) for T = 1:T_ops)
#     xJ = sum(weights[i,T]*8760/t_ops*sum(sum((VOM_GEN[i,g]+HeatRate[g]*FuelCosts[i,g])*JuMP.value.(generation[i,T,t,g]) for t = 1:t_ops) for g = 1:GEN) for T = 1:T_ops) + sum(weights[i,T]*8760/t_ops*sum((StartUpCosts[g]+StartupFuel[g]*FuelCosts[i,g])*sum(JuMP.value.(startup_GEN[i,T,t,g]) for t = 1:t_ops)  for g = 1:GEN) for T = 1:T_ops) + offsets_Cost[i]*JuMP.value.(excess_powerEmissions[i]) - CommodityCost_NG[i]*CleanGas_powersector[i]
    
#     # Average electricity rate
#     EmissionsAndCosts[1,i] = (xA*xF+xB*xD)/(xF*xC-xB*xE)
#     # Average cost of zero-emission gas
#     EmissionsAndCosts[3,i] = (xD+xE*EmissionsAndCosts[1,i])/xF
#     # Average gas rate
#     EmissionsAndCosts[2,i] = (xG+xH*EmissionsAndCosts[3,i])/xI

#     # Average cost of zero-emission gas (exposed to marginal cost of electricity)
#     EmissionsAndCosts[19,i] =  (xC*xD+xE*xJ)/(xF*xC-xB*xE)
#     # Average electricity rate (assessed w.r.t remaining electricity (not used for P2G) and after the revenues provided by P2G)
#     EmissionsAndCosts[17,i] = (xA + xB*EmissionsAndCosts[19,i] - xE*(xJ+xB*EmissionsAndCosts[19,i])/xC)/(xC-xE)
#     # Average gas rate
#     EmissionsAndCosts[18,i] = (xG+xH*EmissionsAndCosts[19,i])/xI
        
#     # Gen Capex
#     EmissionsAndCosts[4,i] = sum(UnitSize_GEN[g]*sum(unitsbuilt_GEN[i0,g]*max(min((Years[i0]+EconomicLifetime_GEN[g])-Years[i],1),0)*CRF_GEN[g]*1000*CAPEX_GEN[i0,g] for i0 = 1:i) for g = 1:GEN)
#     # Gen FOM
#     EmissionsAndCosts[5,i] = sum(UnitSize_GEN[g]*(NumUnits_GEN[g]+sum(unitsbuilt_GEN[i0,g]-unitsretired_GEN[i0,g] for i0 = 1:i))*1000*FOM_GEN[i,g] for g = 1:GEN)
#     # Gen VOM and fuel
#     EmissionsAndCosts[6,i] = sum(weights[i,T]*8760/t_ops*sum(sum((VOM_GEN[i,g]+HeatRate[g]*FuelCosts[i,g])*JuMP.value.(generation[i,T,t,g]) for t = 1:t_ops) for g = 1:GEN) for T = 1:T_ops) + sum(weights[i,T]*8760/t_ops*sum((StartUpCosts[g]+StartupFuel[g]*FuelCosts[i,g])*sum(JuMP.value.(startup_GEN[i,T,t,g]) for t = 1:t_ops)  for g = 1:GEN) for T = 1:T_ops) - (CommodityCost_NG[i])*CleanGas_powersector[i]
#     # Storage ELEC
#     EmissionsAndCosts[7,i] = sum(UnitSize_STORAGE_ELEC[s]*sum(unitsbuilt_STORAGE_ELEC[i0,s]*max(min((Years[i0]+EconomicLifetime_STORAGE_ELEC[s])-Years[i],1),0)*CRF_STORAGE_ELEC[s]*1000*CAPEX_STORAGE_ELEC[i0,s] for i0 = 1:i)  + UnitSize_STORAGE_ELEC[s]*(NumUnits_STORAGE_ELEC[s]+sum(unitsbuilt_STORAGE_ELEC[i0,s] - unitsretired_STORAGE_ELEC[i0,s] for i0 = 1:i))*1000*FOM_STORAGE_ELEC[i,s] for s = 1:STORAGE_ELEC)
#     # T&D (Peak Distribution, New Transmission CAPEX + FOM, Existing CAPEX + FOM)
#     EmissionsAndCosts[8,i] = Cost_DistributionInfrastructure*1000*sum(JuMP.value.(PeakDistDemand[i,n]) for n = 1:NODES_ELEC)
#     EmissionsAndCosts[20,i] = sum(sum(max(min((Years[i0]+EconomicLifetime_ELECTrans)-Years[i],1),0)*(CRF_ELECTrans+ElecTransmissionOperatingCosts)*CAPEX_ELECTrans[e]*addflow_TRANS_ELEC[i0,e] for i0 = 1:i) for e = 1:EDGES_ELEC)
#     EmissionsAndCosts[25,i] = sum(AMMORTIZED_ELECTrans[e] for e = 1:EDGES_ELEC)

#     # Gas sector costs
#     # Commodity
#     EmissionsAndCosts[9,i] = CommodityCost_NG[i]*(sum(weights[i,T]*8760/t_ops*sum(sum(JuMP.value.(Demand_GAS[i,T,t,n]) for n = 1:NODES_GAS) for t = 1:t_ops) for T = 1:T_ops)) - CommodityCost_NG[i]*CleanGas_gassector[i]
#     # Distribution systems
#     EmissionsAndCosts[10,i] = JuMP.value.(gasdistsyst_Cost[i])*1000
#     # Storage GAS
#     EmissionsAndCosts[11,i] = sum(UnitSize_STORAGE_GAS[s]*sum(unitsbuilt_STORAGE_GAS[i0,s]*max(min((Years[i0]+EconomicLifetime_STORAGE_GAS[s])-Years[i],1),0)*CRF_STORAGE_GAS[s]*1000*CAPEX_STORAGE_GAS[i0,s]  for i0 = 1:i) + UnitSize_STORAGE_GAS[s]*(NumUnits_STORAGE_GAS[s]+sum(unitsbuilt_STORAGE_GAS[i0,s] - unitsretired_STORAGE_GAS[i0,s]  for i0 = 1:i))*1000*FOM_STORAGE_GAS[i,s] for s = 1:STORAGE_GAS)

#     # Appliances
#     EmissionsAndCosts[12,i] = sum(sum(CRF_APPLIANCES[a]*max(min((Years[i0]+ApplianceLifetime[a])-Years[i],1),0)*(CAPEX_APPLIANCES[i0,a]*unitsbuilt_APPS[i0,a]*1000 + JuMP.value.(applianceInfrastructureCosts[i0,a])) for i0 =1:i) for a = 1:APPLIANCES)

#     # P2G costs (without electricity costs, these are included in the electricity generation sectoral costs)
#     EmissionsAndCosts[13,i] = sum(UnitSize_P2G[d]*sum(unitsbuilt_P2G[i0,d]*max(min((Years[i0]+EconomicLifetime_P2G[d])-Years[i],1),0)*CRF_P2G[d]*1000*CAPEX_P2G[i0,d] for i0 = 1:i) + UnitSize_P2G[d]*(NumUnits_P2G[d] + sum(unitsbuilt_P2G[i0,d] - unitsretired_P2G[i0,d] for i0 = 1:i))*1000*FOM_P2G[i,d] for d = 1:P2G) + sum(weights[i,T]*8760/t_ops*sum(sum((VOM_P2G[i,d])*JuMP.value.(P2G_dispatch[i,T,t,d]) for t = 1:t_ops) for d = 1:P2G) for T = 1:T_ops)

#     # Negative emissions offsets
#     EmissionsAndCosts[14,i] = offsets_Cost[i]*(JuMP.value.(excess_powerEmissions[i]) + JuMP.value.(excess_gasEmissions[i]))
    
#     # Emissions intensity of electricity generated and gas delivered (check to make sure constraint is satisfied)
#     EmissionsAndCosts[15,i] = (sum(weights[i,T]*8760/t_ops*sum(StartupFuel[g]*emissions_factors[g]*sum(JuMP.value.(startup_GEN[i,T,t,g]) for t = 1:t_ops)  for g = 1:GEN) for T = 1:T_ops) + sum(weights[i,T]*8760/t_ops*sum(sum(JuMP.value.(generation[i,T,t,g])*HeatRate[g]*emissions_factors[g] for g = 1:GEN) for t = 1:t_ops) for T = 1:T_ops) - sum(JuMP.value.(CleanGas_GEN[i, g])/MWh_PER_MMBTU*emissions_factors[g] for g = 1:GEN))/sum(weights[i,T]*8760/t_ops*sum(sum(JuMP.value.(generation[i,T,t,g]) for g = 1:GEN) for t = 1:t_ops) for T = 1:T_ops)
#     EmissionsAndCosts[16,i] = (sum(weights[i,T]*8760/t_ops*EF_NG*sum(sum(Demand_GAS[i,T,t,n] for n = 1:NODES_GAS) for t = 1:t_ops) for T = 1:T_ops) - EF_NG*CleanGas_gassector[i])/sum(weights[i,T]*8760/t_ops*sum(sum(Demand_GAS[i,T,t,n] for n = 1:NODES_GAS) for t = 1:t_ops) for T = 1:T_ops)

#     EmissionsAndCosts[21,i] = sum(weights[i,T]*8760/t_ops*sum(StartupFuel[g]*emissions_factors[g]*sum(JuMP.value.(startup_GEN[i,T,t,g]) for t = 1:t_ops)  for g = 1:GEN) for T = 1:T_ops) + sum(weights[i,T]*8760/t_ops*sum(sum(JuMP.value.(generation[i,T,t,g])*HeatRate[g]*emissions_factors[g] for g = 1:GEN) for t = 1:t_ops) for T = 1:T_ops) - sum(JuMP.value.(CleanGas_GEN[i, g])/MWh_PER_MMBTU*emissions_factors[g] for g = 1:GEN)
#     EmissionsAndCosts[22,i] = sum(weights[i,T]*8760/t_ops*EF_NG*sum(sum(Demand_GAS[i,T,t,n] for n = 1:NODES_GAS) for t = 1:t_ops) for T = 1:T_ops) - EF_NG*CleanGas_gassector[i]
#     EmissionsAndCosts[23,i] = JuMP.value.(excess_powerEmissions[i])
#     EmissionsAndCosts[24,i] = JuMP.value.(excess_gasEmissions[i])
# end

# CapacityBuilt = zeros(T_inv,GEN+STORAGE_ELEC+P2G+STORAGE_GAS+1)
# for i = 1:T_inv
#     CapacityBuilt[i,1:GEN] = unitsbuilt_GEN[i,:].*UnitSize_GEN
#     CapacityBuilt[i,GEN+1:GEN+STORAGE_ELEC] = unitsbuilt_STORAGE_ELEC[i,:].*UnitSize_STORAGE_ELEC
#     CapacityBuilt[i,GEN+STORAGE_ELEC+1:GEN+STORAGE_ELEC+P2G] = unitsbuilt_P2G[i,:].*UnitSize_P2G
#     CapacityBuilt[i,GEN+STORAGE_ELEC+P2G+1:GEN+STORAGE_ELEC+P2G+STORAGE_GAS] = unitsbuilt_STORAGE_GAS[i,:].*UnitSize_STORAGE_GAS
#     CapacityBuilt[i,GEN+STORAGE_ELEC+P2G+STORAGE_GAS+1] = sum(distSysRetirement_GAS[i,d] for d = 1:DIST_GAS)
# end

# CapacityRetired = zeros(T_inv,GEN+STORAGE_ELEC+P2G+STORAGE_GAS+1)
# for i = 1:T_inv
#     CapacityRetired[i,1:GEN] = unitsretired_GEN[i,:].*UnitSize_GEN
#     CapacityRetired[i,GEN+1:GEN+STORAGE_ELEC] = unitsretired_STORAGE_ELEC[i,:].*UnitSize_STORAGE_ELEC
#     CapacityRetired[i,GEN+STORAGE_ELEC+1:GEN+STORAGE_ELEC+P2G] = unitsretired_P2G[i,:].*UnitSize_P2G
#     CapacityRetired[i,GEN+STORAGE_ELEC+P2G+1:GEN+STORAGE_ELEC+P2G+STORAGE_GAS] = unitsretired_STORAGE_GAS[i,:].*UnitSize_STORAGE_GAS
#     CapacityRetired[i,GEN+STORAGE_ELEC+P2G+STORAGE_GAS+1] = sum(distSysRetirement_GAS[i,d] for d = 1:DIST_GAS)
# end

# GenerationSave = zeros(T_inv,GEN+P2G+9)
# for i = 1:T_inv
#      GenerationSave[i,1:GEN] = sum(weights[i,T]*8760/t_ops*sum(JuMP.value.(generation[i,T,t,:]) for t = 1:t_ops) for T = 1:T_ops)
#      GenerationSave[i,GEN+1:GEN+P2G] = sum(weights[i,T]*8760/t_ops*sum(JuMP.value.(P2G_dispatch[i,T,t,:]).*eta_P2G for t = 1:t_ops) for T = 1:T_ops)
#      GenerationSave[i,GEN+P2G+1] = sum(weights[i,T]*8760/t_ops*sum(sum(InitialAppliancePopulation[:].*ApplianceProfiles_GAS[T,t,:]) + sum(BaselineDemand_GAS[i,T,t,:])  for t = 1:t_ops) for T = 1:T_ops)
#      GenerationSave[i,GEN+P2G+2] = sum(weights[i,T]*8760/t_ops*sum(sum(Demand_GAS[i,T,t,:]) for t = 1:t_ops) for T = 1:T_ops)
#      GenerationSave[i,GEN+P2G+3] = CleanGas_powersector[i]
#      GenerationSave[i,GEN+P2G+4] = CleanGas_gassector[i]
#      GenerationSave[i,GEN+P2G+5] = sum(weights[i,T]*8760/t_ops*sum(sum(InitialAppliancePopulation[:].*ApplianceProfiles_ELEC[T,t,:]) + sum(BaselineDemand_ELEC[i,T,t,:])  for t = 1:t_ops) for T = 1:T_ops)
#      GenerationSave[i,GEN+P2G+6] = sum(weights[i,T]*8760/t_ops*sum(sum(Demand_ELEC[i,T,t,:]) for t = 1:t_ops) for T = 1:T_ops)
#      GenerationSave[i,GEN+P2G+7] = sum(weights[i,T]*8760/t_ops*sum(sum(JuMP.value.(SUPPLY_GAS_slack[i,T,n]) for n = 1:NODES_GAS) for t = 1:t_ops) for T = 1:T_ops)
#      GenerationSave[i,GEN+P2G+8] = sum(weights[i,T]*8760/t_ops*sum(sum(sum(GEN_NodalLoc_ELEC[n,g]*JuMP.value.(generation[i,T,t,g]) for g = 1:GEN) + sum(-1*A_ELEC[n,e]*JuMP.value.(Flows_Elec[i,T,t,e]) for e = 1:EDGES_ELEC) - sum(STORAGE_ELEC_NodalLoc_ELEC[n,s]*(JuMP.value.(charging_ELEC[i,T,t,s])-JuMP.value.(discharging_ELEC[i,T,t,s])) for s = 1:STORAGE_ELEC) - Demand_ELEC[i,T,t,n] - sum(P2G_NodalLoc_ELEC[n,d]*JuMP.value.(P2G_dispatch[i,T,t,d])*(1-ISBIOMETHANE[d]) for d = 1:P2G) for n = 1:NODES_ELEC)  for t = 1:t_ops) for T = 1:T_ops) + sum(weights[i,T]*8760/t_ops*sum(sum(JuMP.value.(curtailmentRE[i,T,t,g]) for g = 1:GEN) for t = 1:t_ops) for T = 1:T_ops)
#      GenerationSave[i,GEN+P2G+9] = sum(weights[i,T]*8760/t_ops*sum(sum((JuMP.value.(generation[i,T,t,g])*HeatRate[g] + JuMP.value.(startup_GEN[i,T,t,g])*StartupFuel[g])*MWh_PER_MMBTU*NG_fueled[g] for g = 1:GEN) for t = 1:t_ops) for T = 1:T_ops)
# end

# HourlyGenFullSave = zeros(T_inv*8760,GEN+STORAGE_ELEC+P2G+1)
# HourlyLoadFullSave = zeros(T_inv*8760,4)
# HourlyStoredElecFullSave = zeros(T_inv*8760,STORAGE_ELEC)
# HourlyTransmissionFullSave = zeros(T_inv*8760,EDGES_ELEC)
# DailyGasSOCFullSave = zeros(T_inv*365,STORAGE_GAS+2)
# HourlyStoredGasEnergyFullSave = zeros(T_inv*8760,STORAGE_GAS)
# DailyGasTransmissionFullSave = zeros(T_inv*Periods_Per_Year,EDGES_GAS)
# for i = 1:T_inv
#     for c = 1:Periods_Per_Year
#         j = Int(RepDays[i,c])
#         count = Int((i-1)*8760+(c-1)*t_ops)+1
#         HourlyGenFullSave[count:count+t_ops-1,1:GEN] = JuMP.value.(generation[i,j,:,:])
#         HourlyGenFullSave[count:count+t_ops-1, GEN+1:GEN+STORAGE_ELEC] = (JuMP.value.(charging_ELEC[i,j,:,:])-JuMP.value.(discharging_ELEC[i,j,:,:]))
#         HourlyGenFullSave[count:count+t_ops-1, GEN+STORAGE_ELEC+1:GEN+STORAGE_ELEC+P2G] = JuMP.value.(P2G_dispatch[i,j,:,:].*transpose(ones(P2G)-ISBIOMETHANE))
#         HourlyGenFullSave[count:count+t_ops-1, GEN+STORAGE_ELEC+P2G+1] = sum(JuMP.value.(curtailmentRE[i,j,:,:]), dims = 2)
#         HourlyLoadFullSave[count:count+t_ops-1, 1] = sum(Demand_ELEC[i,j,:,:], dims = 2)
#         HourlyLoadFullSave[count:count+t_ops-1, 2] = sum(Demand_GAS[i,j,:,:], dims = 2)
#         HourlyLoadFullSave[count:count+t_ops-1, 3] = sum(BaselineDemand_ELEC[i,j,:,:], dims = 2)
#         HourlyLoadFullSave[count:count+t_ops-1, 4] = sum(BaselineDemand_GAS[i,j,:,:], dims = 2)
#         HourlyStoredElecFullSave[count:count+t_ops-1,:] = JuMP.value.(storedEnergy_ELEC[i,j,1:t_ops,:])
#         HourlyStoredGasEnergyFullSave[count:count+t_ops-1,:] = JuMP.value.(storedEnergy_GAS[i,j,1:t_ops,:])
#         if LINKED_PERIODS_STORAGE == 1
#             DailyGasSOCFullSave[Int((i-1)*Periods_Per_Year + c),1:STORAGE_GAS] = JuMP.value.(SOCTracked_GAS[i,c,:])
#         end
#         DailyGasSOCFullSave[Int((i-1)*Periods_Per_Year + c), STORAGE_GAS+1] = JuMP.value.(SUPPLY_GAS_slack[i,j,18])
#         DailyGasSOCFullSave[Int((i-1)*Periods_Per_Year + c), STORAGE_GAS+2] = JuMP.value.(SUPPLY_GAS_slack[i,j,20])
#         HourlyTransmissionFullSave[count:count+t_ops-1,:] = JuMP.value.(Flows_Elec[i,j,:,:])
#         DailyGasTransmissionFullSave[Int((i-1)*Periods_Per_Year + c),:] = JuMP.value.(Flows_Gas[i,j,:])
#     end
# end


# ApplianceDecisions = zeros(3*T_inv,APPLIANCES)
# for i = 1:T_inv
#     count = (3*i-2)
#     ApplianceDecisions[count,:] = unitsbuilt_APPS[i,:]
#     ApplianceDecisions[count+1,:] = JuMP.value.(unitsretired_APPS[i,:])
#     ApplianceDecisions[count+2,:] = JuMP.value.(unitsremaining_APPS[i,:])
# end

# Creates output folder autmatically

# specificOutput = CAPEX_HB_case * CAPEX_CCS_case * "_NGcost" * string(Int(floor(sum(weights[1,:] .* CommodityCost_NG[1,:] * MWh_PER_MMBTU))))
# try
#     specificOutput = EMISSION_2045_case * "_NGcost" * string(Int(floor(sum(weights[1,:] .* CommodityCost_NG[1,:] * MWh_PER_MMBTU))))
# catch
#     specificOutput = "_NGcost" * string(Int(floor(sum(weights[1,:] .* CommodityCost_NG[1,:] * MWh_PER_MMBTU))))
# end

specificOutput = EMISSION_2045_case * "_NGcost" * string(Int(floor(sum(weights[1,:] .* CommodityCost_NG[1,:] * gasCostProjection[T_inv] * MWh_PER_MMBTU))))



function mk_output_dir()
    timestamp = Dates.format(now(), "YYYYmmdd-HHMMSS")
    dir_name = joinpath(@__DIR__, "Output", "$timestamp")
    @assert !ispath(dir_name) "File name already taken"
    dir_name = dir_name * specificOutput
    mkpath(dir_name)
    return dir_name
end
top_dir = mk_output_dir()
println("Saving to: ",last(top_dir, 1405))

# CSV.write("$(top_dir)/APPLIANCE_DECISIONS.csv",Tables.table(ApplianceDecisions'), writeheader = true)
# CSV.write("$(top_dir)/EMISSIONS_COSTS.csv",Tables.table(EmissionsAndCosts'), writeheader = true)
# CSV.write("$(top_dir)/CAPACITY_BUILT.csv",Tables.table(CapacityBuilt'), writeheader = true)
# CSV.write("$(top_dir)/CAPACITY_RETIRED.csv",Tables.table(CapacityRetired'), writeheader = true)
# CSV.write("$(top_dir)/GENERATION.csv",Tables.table(GenerationSave'), writeheader = true)
# CSV.write("$(top_dir)/HOURLY_GENERATION.csv",Tables.table(HourlyGenFullSave'), writeheader = true)
# CSV.write("$(top_dir)/HOURLY_LOAD.csv",Tables.table(HourlyLoadFullSave'), writeheader = true)
# CSV.write("$(top_dir)/HOURLY_ELECTRIC_TRANSMISSION.csv",Tables.table(HourlyTransmissionFullSave'), writeheader = true)

# CSV.write("$(top_dir)/HOURLY_GAS_STOREDENERGY.csv",Tables.table(HourlyStoredGasEnergyFullSave'), writeheader = true)
# CSV.write("$(top_dir)/DAILY_GAS_SOC.csv",Tables.table(DailyGasSOCFullSave'), writeheader = true)
# CSV.write("$(top_dir)/HOURLY_ELEC_STOREDENERGY.csv",Tables.table(HourlyStoredElecFullSave'), writeheader = true)
# CSV.write("$(top_dir)/DAILY_GAS_TRANSMISSION.csv",Tables.table(DailyGasTransmissionFullSave'), writeheader = true)

# CSV.write("$(top_dir)/REPDAYS.csv",Tables.table(RepDays[1,:]), writeheader = true)
# CSV.write("$(top_dir)/ADDELECFLOW.csv",Tables.table(addflow_TRANS_ELEC), writeheader = true)
# CSV.write("$(top_dir)/PEAKDEMAND.csv",Tables.table(JuMP.value.(PeakDistDemand)), writeheader = true)
# CSV.write("$(top_dir)/PEAKDEMANDINC.csv",Tables.table(JuMP.value.(PeakDistDemandInc)), writeheader = true)

# if gasdistretirement_allowed == 1
#     CSV.write("$(top_dir)/DISTRETIRE.csv",Tables.table(JuMP.value.(distSysRetirement_GAS)), writeheader = true)
# end









##########################################################################
#################### ENERGY STORAGE CAPACITY EXPORTS #####################
##########################################################################
#
### P2G [MW]
# check heat rate: 
# print(HeatRate[Fuel_GEN.=="Natural Gas"])
preCapacity_P2G = NumUnits_P2G .* UnitSize_P2G # .* eta_P2G .* 0.4
# define array based on inv periods
invCapacity_P2G = zeros(T_inv, length(preCapacity_P2G))
# loop
for i=1:T_inv
    #
    netForInvP = UnitSize_P2G .* sum( JuMP.value.(unitsbuilt_P2G[invP,:]) - JuMP.value.(unitsretired_P2G[invP,:]) for invP = 1:i)
    invCapacity_P2G[i,:] = preCapacity_P2G[:] + netForInvP[:]
end

## then let's find the indeces of the different P2G
idx_PowerToCH4  = PrimeMover_P2G .== fill("Net-zero CH4", length(PrimeMover_P2G))
idx_biomethane  = PrimeMover_P2G .== fill("Biomethane", length(PrimeMover_P2G))
idx_PowerToH2   = PrimeMover_P2G .== fill("Electrolysis", length(PrimeMover_P2G))

# concatenate
capPowerToCH4_array  = vcat(transpose(preCapacity_P2G[idx_PowerToCH4]), invCapacity_P2G[:,idx_PowerToCH4])
capBiomethane_array  = vcat(transpose(preCapacity_P2G[idx_biomethane]), invCapacity_P2G[:,idx_biomethane])
capPowerToH2_array   = vcat(transpose(preCapacity_P2G[idx_PowerToH2]), invCapacity_P2G[:,idx_PowerToH2])

# find sum
capPowerToCH4 = sum(capPowerToCH4_array, dims=2)
capBiomethane = sum(capBiomethane_array, dims=2)
capPowerToH2  = sum(capPowerToH2_array, dims=2)

# Specify column names as strings
column_names_P2G = ["Power-to-CH4", "Biomethane", "Power-to-H2"]

# Convert data to 1-dimensional arrays
capPowerToCH4  = vec(capPowerToCH4)
capBiomethane  = vec(capBiomethane)
capPowerToH2   = vec(capPowerToH2)


### P2H [MW]
preCapacity_P2H = NumUnits_P2H .* UnitSize_P2H
# define array based on inv periods
invCapacity_P2H = zeros(T_inv, length(preCapacity_P2H))
# loop
for i=1:T_inv
    #
    netForInvP = UnitSize_P2H .* sum( JuMP.value.(unitsbuilt_P2H[invP,:]) - JuMP.value.(unitsretired_P2H[invP,:]) for invP = 1:i)
    invCapacity_P2H[i,:] = preCapacity_P2H[:] + netForInvP[:]
end

## then let's find the indeces of the different P2H
idx_P2H_elecBoiler  = PrimeMover_P2H .== fill("Electric Boiler", length(PrimeMover_P2H))
idx_P2H_heatPump    = PrimeMover_P2H .== fill("Heat Pump", length(PrimeMover_P2H))

# concatenate
capP2H_elecBoiler_array  = vcat(transpose(preCapacity_P2H[idx_P2H_elecBoiler]), invCapacity_P2H[:,idx_P2H_elecBoiler])
capP2H_heatPump_array  = vcat(transpose(preCapacity_P2H[idx_P2H_heatPump]), invCapacity_P2H[:,idx_P2H_heatPump])

# find sum
capP2H_elecBoiler = sum(capP2H_elecBoiler_array, dims=2)
capP2H_heatPump   = sum(capP2H_heatPump_array, dims=2)

# Specify column names as strings
column_names_P2H = ["Electric Boiler", "Heat Pump"]

# Convert data to 1-dimensional arrays
capP2H_elecBoiler  = vec(capP2H_elecBoiler)
capP2H_heatPump    = vec(capP2H_heatPump)



### CDR [tCO2 / y]
preCapacity_CDR = NumUnits_CDR .* UnitSize_CDR * 8760
# define array based on inv periods
invCapacity_CDR = zeros(T_inv, length(preCapacity_CDR))
# loop
for i=1:T_inv
    #
    netForInvP = UnitSize_CDR .* 8760 .* sum( JuMP.value.(unitsbuilt_CDR[invP,:]) - JuMP.value.(unitsretired_CDR[invP,:]) for invP = 1:i)
    invCapacity_CDR[i,:] = preCapacity_CDR[:] + netForInvP[:]
end

## then let's find the indeces of the different CDR
idx_CDR_DACLS  = PrimeMover_CDR .== fill("DAC-LS", length(PrimeMover_CDR))
idx_CDR_DACSS  = PrimeMover_CDR .== fill("DAC-SS", length(PrimeMover_CDR))
idx_CDR_CCSprocess    = techType_CDR .== fill("CCS-Process", length(techType_CDR))
idx_CDR_CCScombustion    = techType_CDR .== fill("CCS-Combustion", length(techType_CDR))
idx_CDR_CCSgasUse    = techType_CDR .== fill("CCS-GasUse", length(techType_CDR))


# concatenate
capCDR_DACLS_array  = vcat(transpose(preCapacity_CDR[idx_CDR_DACLS]), invCapacity_CDR[:,idx_CDR_DACLS])
capCDR_DACSS_array  = vcat(transpose(preCapacity_CDR[idx_CDR_DACSS]), invCapacity_CDR[:,idx_CDR_DACSS])
capCDR_CCSprocess_array    = vcat(transpose(preCapacity_CDR[idx_CDR_CCSprocess]),   invCapacity_CDR[:,idx_CDR_CCSprocess])
capCDR_CCScombustion_array    = vcat(transpose(preCapacity_CDR[idx_CDR_CCScombustion]),   invCapacity_CDR[:,idx_CDR_CCScombustion])
capCDR_CCSgasUse_array    = vcat(transpose(preCapacity_CDR[idx_CDR_CCSgasUse]),   invCapacity_CDR[:,idx_CDR_CCSgasUse])

# find sum
capCDR_DACLS = sum(capCDR_DACLS_array, dims=2)
capCDR_DACSS = sum(capCDR_DACSS_array, dims=2)
capCDR_CCSprocess   = sum(capCDR_CCSprocess_array, dims=2)
capCDR_CCScombustion   = sum(capCDR_CCScombustion_array, dims=2)
capCDR_CCSgasUse   = sum(capCDR_CCSgasUse_array, dims=2)


# Specify column names as strings
column_names_CDR = ["DAC-LS", "DAC-SS", "CCS-Process", "CCS-Combustion", "CCS-GasUse"]

# Convert data to 1-dimensional arrays
capCDR_DACLS  = vec(capCDR_DACLS)
capCDR_DACSS  = vec(capCDR_DACSS)
capCDR_CCSprocess   = vec(capCDR_CCSprocess)
capCDR_CCScombustion    = vec(capCDR_CCScombustion)
capCDR_CCSgasUse    = vec(capCDR_CCSgasUse)





#### Storage Capacity in MWh
preCapacity_ELEC = (NumUnits_STORAGE_ELEC .* UnitSize_STORAGE_ELEC .* duration_ELEC)
# define array based on inv periods
invCapacity_ELEC = zeros(T_inv, length(preCapacity_ELEC))
# loop
for i=1:T_inv
    #
    netForInvP = UnitSize_STORAGE_ELEC .* duration_ELEC .* sum( JuMP.value.(unitsbuilt_STORAGE_ELEC[invP,:]) - JuMP.value.(unitsretired_STORAGE_ELEC[invP,:]) for invP = 1:i)
    invCapacity_ELEC[i,:] = preCapacity_ELEC[:] + netForInvP[:]
end
# gas
preCapacity_GAS = UnitSize_STORAGE_GAS .* duration_GAS

## then let's find the indeces of the different storage mechanisms
idx_PHS       = PrimeMover_STORAGE_ELEC .== fill("Pumped hydro storage", length(PrimeMover_STORAGE_ELEC))
idx_LiBattery = PrimeMover_STORAGE_ELEC .== fill("Li-ion battery", length(PrimeMover_STORAGE_ELEC))
idx_H2Storage = PrimeMover_STORAGE_ELEC .== fill("Long-duration storage", length(PrimeMover_STORAGE_ELEC))
idx_FeBattery = PrimeMover_STORAGE_ELEC .== fill("Multi-day storage", length(PrimeMover_STORAGE_ELEC))

# concatenate
capPHS_array       = vcat(transpose(preCapacity_ELEC[idx_PHS]), invCapacity_ELEC[:,idx_PHS])
capLiBattery_array = vcat(transpose(preCapacity_ELEC[idx_LiBattery]), invCapacity_ELEC[:,idx_LiBattery])
capH2Storage_array = vcat(transpose(preCapacity_ELEC[idx_H2Storage]), invCapacity_ELEC[:,idx_H2Storage])
capFeBattery_array = vcat(transpose(preCapacity_ELEC[idx_FeBattery]), invCapacity_ELEC[:,idx_FeBattery])

# find sum
capPHS       = sum(capPHS_array, dims=2)
capLiBattery = sum(capLiBattery_array, dims=2)
capH2Storage = sum(capH2Storage_array, dims=2)
capFeBattery = sum(capFeBattery_array, dims=2)

# Specify column names as strings
column_names = ["Li-ion battery", "Pumped hydro storage", "Hydrogen Storage", "Fe-air Battery"]

# Convert data to 1-dimensional arrays
capPHS       = vec(capPHS)
capLiBattery = vec(capLiBattery)
capH2Storage = vec(capH2Storage)
capFeBattery = vec(capFeBattery)

# Create a DataFrame with column names and data
df = DataFrame(column_names[1] => capLiBattery, column_names[2] => capPHS, column_names[3] => capH2Storage, column_names[4] => capFeBattery)

#
resultName   = "$(top_dir)/STORAGE_ENERGY_CAPACITIES"
temporalName = string("_$(T_inv)","Inv","+","$(N_Periods)","RepDays")
scenarioName = string("_MDS","$(FormEnergy_allowed)","+","PHS","$(PHS_allowed)")
outputName = string(resultName ,temporalName, scenarioName,".csv")
#
CSV.write(outputName, df, writeheader = true)




#
#### Storage Capacity in MW
preCapacity_ELEC = (NumUnits_STORAGE_ELEC .* UnitSize_STORAGE_ELEC)
# define array based on inv periods
invCapacity_ELEC = zeros(T_inv, length(preCapacity_ELEC))
# loop
for i=1:T_inv
    #
    netForInvP = UnitSize_STORAGE_ELEC .* sum( JuMP.value.(unitsbuilt_STORAGE_ELEC[invP,:]) - JuMP.value.(unitsretired_STORAGE_ELEC[invP,:]) for invP = 1:i)
    invCapacity_ELEC[i,:] = preCapacity_ELEC[:] + netForInvP[:]
end
# gas
preCapacity_GAS = UnitSize_STORAGE_GAS

## then let's find the indeces of the different storage mechanisms
idx_PHS       = PrimeMover_STORAGE_ELEC .== fill("Pumped hydro storage", length(PrimeMover_STORAGE_ELEC))
idx_LiBattery = PrimeMover_STORAGE_ELEC .== fill("Li-ion battery", length(PrimeMover_STORAGE_ELEC))
idx_H2Storage = PrimeMover_STORAGE_ELEC .== fill("Long-duration storage", length(PrimeMover_STORAGE_ELEC))
idx_FeBattery = PrimeMover_STORAGE_ELEC .== fill("Multi-day storage", length(PrimeMover_STORAGE_ELEC))

# concatenate
capPHS_array       = vcat(transpose(preCapacity_ELEC[idx_PHS]), invCapacity_ELEC[:,idx_PHS])
capLiBattery_array = vcat(transpose(preCapacity_ELEC[idx_LiBattery]), invCapacity_ELEC[:,idx_LiBattery])
capH2Storage_array = vcat(transpose(preCapacity_ELEC[idx_H2Storage]), invCapacity_ELEC[:,idx_H2Storage])
capFeBattery_array = vcat(transpose(preCapacity_ELEC[idx_FeBattery]), invCapacity_ELEC[:,idx_FeBattery])

# find sum
capPHS       = sum(capPHS_array, dims=2)
capLiBattery = sum(capLiBattery_array, dims=2)
capH2Storage = sum(capH2Storage_array, dims=2)
capFeBattery = sum(capFeBattery_array, dims=2)

# Specify column names as strings
column_names = ["Li-ion battery", "Pumped hydro storage", "Hydrogen Storage", "Fe-air Battery"]

# Convert data to 1-dimensional arrays
capPHS       = vec(capPHS)
capLiBattery = vec(capLiBattery)
capH2Storage = vec(capH2Storage)
capFeBattery = vec(capFeBattery)


# Create a DataFrame with column names and data
df = DataFrame(column_names[1] => capLiBattery, column_names[2] => capPHS, column_names[3] => capH2Storage, column_names[4] => capFeBattery,
               column_names_P2G[1] => capPowerToCH4, column_names_P2G[2] => capBiomethane, column_names_P2G[3] => capPowerToH2, 
               column_names_P2H[1] => capP2H_elecBoiler, column_names_P2H[2] => capP2H_heatPump,
               column_names_CDR[1] => capCDR_DACLS, column_names_CDR[2] => capCDR_DACSS,
               column_names_CDR[3] => capCDR_CCSprocess, column_names_CDR[4] => capCDR_CCScombustion, column_names_CDR[5] => capCDR_CCSgasUse)

#
resultName   = "$(top_dir)/STORAGE_POWER_CAPACITIES"
temporalName = string("_$(T_inv)","Inv","+","$(N_Periods)","RepDays")
scenarioName = string("_MDS","$(FormEnergy_allowed)","+","PHS","$(PHS_allowed)")
outputName = string(resultName, temporalName, scenarioName,".csv")
#
CSV.write(outputName, df, writeheader = true)



#### Objective Function Value
outputName = string("$(top_dir)/ObjectiveFunctionValue", temporalName, scenarioName,".csv")
CSV.write(outputName, DataFrame(Value = [objective_value(m)]), writeheader = true)



##########################################################################
########################### GAS FLOWS EXPORTS ############################
##########################################################################
# function for hourly output
function process_gasOutput(gas_output, outputName)
    # Determine the column names for each slice in the third dimension
    column_names = String[]  # Initialize as an empty string array
    for i = 1:size(gas_output, 1)
        prefix = "InvPeriod_$(i)"
        for j = 1:size(gas_output, 2)
            suffix = "RepDay_$(j)"
            push!(column_names, string(prefix, "+", suffix))
        end
    end

    # Reshape the 3D matrix into a 2D matrix
    gas_output2D = gas_output[1, :,:]'
    if size(gas_output, 1) > 1
        for i = 2:size(gas_output, 1)
            gas_output2D = hcat(gas_output2D, gas_output[i, :,:]')
        end
    end

    # Create a DataFrame with column names
    df = DataFrame(gas_output2D, column_names)

    # Rename the columns to the specified names
    rename!(df, Symbol.(column_names))

    # Save the DataFrame to a CSV file
    CSV.write(outputName, df)
end

# ### P2G
# P2G_output = JuMP.value.( sum(P2G_dispatch[:,:,:,d]*eta_P2G[d] for d=1:P2G) )
# # Specify the path to the CSV file where you want to save the data
# resultName   = "$(top_dir)/P2G_HOURLY"
# temporalName = string("_$(T_inv)","Inv","+","$(N_Periods)","RepDays")
# scenarioName = string("_MDS","$(FormEnergy_allowed)","+","PHS","$(PHS_allowed)")
# #
# outputName = string(resultName, temporalName, scenarioName,".csv")
# ##
# process_gasOutput(P2G_output, outputName)

### P2CH4, includes H2 if H2 blending is on
P2CH4_output = JuMP.value.( sum(P2G_dispatch[:,:,:,d]*eta_P2G[d] * (1 - ISBIOMETHANE[d]) for d=1:P2G) )
# Specify the path to the CSV file where you want to save the data
resultName   = "$(top_dir)/GAS_P2CH4_HOURLY"
temporalName = string("_$(T_inv)","Inv","+","$(N_Periods)","RepDays")
scenarioName = string("_MDS","$(FormEnergy_allowed)","+","PHS","$(PHS_allowed)")
#
outputName = string(resultName, temporalName, scenarioName,".csv")
##
process_gasOutput(P2CH4_output, outputName)

### Biomethane
Biomethane_output = JuMP.value.( sum(P2G_dispatch[:,:,:,d]*eta_P2G[d] * ISBIOMETHANE[d] for d=1:P2G) )
# Specify the path to the CSV file where you want to save the data
resultName   = "$(top_dir)/GAS_Biomethane_HOURLY"
temporalName = string("_$(T_inv)","Inv","+","$(N_Periods)","RepDays")
scenarioName = string("_MDS","$(FormEnergy_allowed)","+","PHS","$(PHS_allowed)")
#
outputName = string(resultName, temporalName, scenarioName,".csv")
##
process_gasOutput(Biomethane_output, outputName)


### Imports
Imports_output = JuMP.value.( sum(SUPPLY_GAS_slack[:,:,n] for n=1:NODES_GAS) )
Imports_output = cat([Imports_output for _ in 1:24]..., dims=3)
# Specify the path to the CSV file where you want to save the data
resultName   = "$(top_dir)/GAS_Imports_HOURLY"
temporalName = string("_$(T_inv)","Inv","+","$(N_Periods)","RepDays")
scenarioName = string("_MDS","$(FormEnergy_allowed)","+","PHS","$(PHS_allowed)")
#
outputName = string(resultName, temporalName, scenarioName,".csv")
##
process_gasOutput(Imports_output, outputName)


### Charging
Charging_output = JuMP.value.( sum(charging_GAS[:,:,:,s] for s = 1:STORAGE_GAS) )
# Specify the path to the CSV file where you want to save the data
resultName   = "$(top_dir)/GAS_Charging_HOURLY"
temporalName = string("_$(T_inv)","Inv","+","$(N_Periods)","RepDays")
scenarioName = string("_MDS","$(FormEnergy_allowed)","+","PHS","$(PHS_allowed)")
#
outputName = string(resultName, temporalName, scenarioName,".csv")
##
process_gasOutput(Charging_output, outputName)

### Discharging
Discharging_output = JuMP.value.( sum(discharging_GAS[:,:,:,s] for s = 1:STORAGE_GAS) )
# Specify the path to the CSV file where you want to save the data
resultName   = "$(top_dir)/GAS_Discharging_HOURLY"
temporalName = string("_$(T_inv)","Inv","+","$(N_Periods)","RepDays")
scenarioName = string("_MDS","$(FormEnergy_allowed)","+","PHS","$(PHS_allowed)")
#
outputName = string(resultName, temporalName, scenarioName,".csv")
##
process_gasOutput(Discharging_output, outputName)

### ALL Demand
TotalDemand_output = JuMP.value.( sum(sum(NominalGasOfftakes[:,:,:,n,g]*LHV[g]*MolarMass[g] for g=1:GAS_COMPONENTS) for n=1:NODES_GAS) )
# Specify the path to the CSV file where you want to save the data
resultName   = "$(top_dir)/GAS_TotalDemand_HOURLY"
temporalName = string("_$(T_inv)","Inv","+","$(N_Periods)","RepDays")
scenarioName = string("_MDS","$(FormEnergy_allowed)","+","PHS","$(PHS_allowed)")
#
outputName = string(resultName, temporalName, scenarioName,".csv")
##
process_gasOutput(TotalDemand_output, outputName)

### Heat end-use Gas Demand; i.e. not for power plants
HeatDemand_output = JuMP.value.( sum(Demand_GAS[:,:,:,n] for n=1:NODES_GAS) )
# Specify the path to the CSV file where you want to save the data
resultName   = "$(top_dir)/GAS_HeatDemand_HOURLY"
temporalName = string("_$(T_inv)","Inv","+","$(N_Periods)","RepDays")
scenarioName = string("_MDS","$(FormEnergy_allowed)","+","PHS","$(PHS_allowed)")
#
outputName = string(resultName, temporalName, scenarioName,".csv")
##
process_gasOutput(HeatDemand_output, outputName)


### CDR
CDR_output = JuMP.value.( sum(CDR_dispatch[:,:,:,d] for d=1:CDR) )
# Specify the path to the CSV file where you want to save the data
resultName   = "$(top_dir)/CO2_CDR_HOURLY"
temporalName = string("_$(T_inv)","Inv","+","$(N_Periods)","RepDays")
scenarioName = string("_MDS","$(FormEnergy_allowed)","+","PHS","$(PHS_allowed)")
#
outputName = string(resultName, temporalName, scenarioName,".csv")
##
process_gasOutput(CDR_output, outputName)


### BASELINE only
Baseline_output = JuMP.value.( sum(BaselineDemand_GAS[:,:,:,n] for n=1:NODES_GAS) )
# Specify the path to the CSV file where you want to save the data
resultName   = "$(top_dir)/GAS_BaselineOnly_HOURLY"
temporalName = string("_$(T_inv)","Inv","+","$(N_Periods)","RepDays")
scenarioName = string("_MDS","$(FormEnergy_allowed)","+","PHS","$(PHS_allowed)")
#
outputName = string(resultName, temporalName, scenarioName,".csv")
##
process_gasOutput(Baseline_output, outputName)



##########################################################################
### CLIMATE ZONE SPECIFIC

function process_flowOutput(flow_output, outputName)
    # Initialize as an empty string array
    column_names = String[]
    flow_output2D = zeros(size(flow_output, 3), size(flow_output, 1) * size(flow_output, 2) * size(flow_output, 4), )
    #
    counter = 1
    #
    for i = 1:size(flow_output, 1)
        prefix = "InvPeriod_$(i)"
        for j = 1:size(flow_output, 2)
            suffix = "RepDay_$(j)"
            for k = 1:size(flow_output, 4)
                # create name
                suffix2 = "StorageSite_$(GasStorage[!, "Storage_ID"][k])"
                push!(column_names, string(prefix, "+", suffix, "+", suffix2))
                # fill matrix
                flow_output2D[:,counter] = flow_output[i,j,:,k]
                # update counter
                counter = counter + 1
            end
        end
    end
    # Create a DataFrame with column names
    df = DataFrame(flow_output2D, column_names)

    # Rename the columns to the specified names
    rename!(df, Symbol.(column_names))
    # Save the DataFrame to a CSV file
    CSV.write(outputName, df)
end


### Charging
Charging_output = JuMP.value.( charging_GAS )
# Specify the path to the CSV file where you want to save the data
resultName   = "$(top_dir)/PerGasStorageSite_Charging_HOURLY"
temporalName = string("_$(T_inv)","Inv","+","$(N_Periods)","RepDays")
scenarioName = string("_MDS","$(FormEnergy_allowed)","+","PHS","$(PHS_allowed)")
#
outputName = string(resultName, temporalName, scenarioName,".csv")
##
process_flowOutput(Charging_output, outputName)

### Discharging
Discharging_output = JuMP.value.( discharging_GAS )
# Specify the path to the CSV file where you want to save the data
resultName   = "$(top_dir)/PerGasStorageSite_Discharging_HOURLY"
temporalName = string("_$(T_inv)","Inv","+","$(N_Periods)","RepDays")
scenarioName = string("_MDS","$(FormEnergy_allowed)","+","PHS","$(PHS_allowed)")
#
outputName = string(resultName, temporalName, scenarioName,".csv")
##
process_flowOutput(Discharging_output, outputName)



##########################################################################
########################## ELEC FLOWS EXPORTS ############################
##########################################################################
#
### using the same code as gasOutput
#
### P2G
ELEC_P2G_output = JuMP.value.( sum(P2G_dispatch[:,:,:,d]*(1-ISBIOMETHANE[d]) for d = 1:P2G) )
# Specify the path to the CSV file where you want to save the data
resultName   = "$(top_dir)/ELEC_P2G_HOURLY"
temporalName = string("_$(T_inv)","Inv","+","$(N_Periods)","RepDays")
scenarioName = string("_MDS","$(FormEnergy_allowed)","+","PHS","$(PHS_allowed)")
#
outputName = string(resultName, temporalName, scenarioName,".csv")
##
process_gasOutput(ELEC_P2G_output, outputName)

### P2H
ELEC_P2H_output = JuMP.value.( sum(P2H_dispatch[:,:,:,d] for d = 1:P2H) )
# Specify the path to the CSV file where you want to save the data
resultName   = "$(top_dir)/ELEC_P2H_HOURLY"
temporalName = string("_$(T_inv)","Inv","+","$(N_Periods)","RepDays")
scenarioName = string("_MDS","$(FormEnergy_allowed)","+","PHS","$(PHS_allowed)")
#
outputName = string(resultName, temporalName, scenarioName,".csv")
##
process_gasOutput(ELEC_P2H_output, outputName)

### Generation
ELEC_Generation_output = JuMP.value.( sum(generation[:,:,:,g] for g = 1:GEN) )
# Specify the path to the CSV file where you want to save the data
resultName   = "$(top_dir)/ELEC_Gen_HOURLY"
temporalName = string("_$(T_inv)","Inv","+","$(N_Periods)","RepDays")
scenarioName = string("_MDS","$(FormEnergy_allowed)","+","PHS","$(PHS_allowed)")
#
outputName = string(resultName, temporalName, scenarioName,".csv")
##
process_gasOutput(ELEC_Generation_output, outputName)

### Curtailment
ELEC_Curtailment_output = JuMP.value.( sum(curtailmentRE[:,:,:,g] for g = 1:GEN) )
# Specify the path to the CSV file where you want to save the data
resultName   = "$(top_dir)/ELEC_Curtailment_HOURLY"
temporalName = string("_$(T_inv)","Inv","+","$(N_Periods)","RepDays")
scenarioName = string("_MDS","$(FormEnergy_allowed)","+","PHS","$(PHS_allowed)")
#
outputName = string(resultName, temporalName, scenarioName,".csv")
##
process_gasOutput(ELEC_Curtailment_output, outputName)


### Heat Charging
ELEC_HeatCharging_output = JuMP.value.( sum(charging_HEAT[:,:,:,s] for s = 1:STORAGE_HEAT) )
# Specify the path to the CSV file where you want to save the data
resultName   = "$(top_dir)/ELEC_HeatCharging_HOURLY"
temporalName = string("_$(T_inv)","Inv","+","$(N_Periods)","RepDays")
scenarioName = string("_MDS","$(FormEnergy_allowed)","+","PHS","$(PHS_allowed)")
#
outputName = string(resultName, temporalName, scenarioName,".csv")
##
process_gasOutput(ELEC_HeatCharging_output, outputName)


### Charging
ELEC_Charging_output = JuMP.value.( sum(charging_ELEC[:,:,:,s] for s = 1:STORAGE_ELEC) )
# Specify the path to the CSV file where you want to save the data
resultName   = "$(top_dir)/ELEC_Charging_HOURLY"
temporalName = string("_$(T_inv)","Inv","+","$(N_Periods)","RepDays")
scenarioName = string("_MDS","$(FormEnergy_allowed)","+","PHS","$(PHS_allowed)")
#
outputName = string(resultName, temporalName, scenarioName,".csv")
##
process_gasOutput(ELEC_Charging_output, outputName)


### Discharging
ELEC_Discharging_output = JuMP.value.( sum(discharging_ELEC[:,:,:,s] for s = 1:STORAGE_ELEC) )
# Specify the path to the CSV file where you want to save the data
resultName   = "$(top_dir)/ELEC_Discharging_HOURLY"
temporalName = string("_$(T_inv)","Inv","+","$(N_Periods)","RepDays")
scenarioName = string("_MDS","$(FormEnergy_allowed)","+","PHS","$(PHS_allowed)")
#
outputName = string(resultName, temporalName, scenarioName,".csv")
##
process_gasOutput(ELEC_Discharging_output, outputName)


### Heat-to-grid
ELEC_Heat2Grid_output = JuMP.value.( sum(discharging_HEAT_ToGridELEC[:,:,:,s] * heat2Grid_efficiency for s = 1:STORAGE_HEAT) )
# Specify the path to the CSV file where you want to save the data
resultName   = "$(top_dir)/ELEC_Heat2Grid_HOURLY"
temporalName = string("_$(T_inv)","Inv","+","$(N_Periods)","RepDays")
scenarioName = string("_MDS","$(FormEnergy_allowed)","+","PHS","$(PHS_allowed)")
#
outputName = string(resultName, temporalName, scenarioName,".csv")
##
process_gasOutput(ELEC_Heat2Grid_output, outputName)


### Demand
ELEC_Demand_output = JuMP.value.( sum(Demand_ELEC[:,:,:,n] for n = 1:NODES_ELEC) )
# Specify the path to the CSV file where you want to save the data
resultName   = "$(top_dir)/ELEC_Demand_HOURLY"
temporalName = string("_$(T_inv)","Inv","+","$(N_Periods)","RepDays")
scenarioName = string("_MDS","$(FormEnergy_allowed)","+","PHS","$(PHS_allowed)")
#
outputName = string(resultName, temporalName, scenarioName,".csv")
##
process_gasOutput(ELEC_Demand_output, outputName)


### CDR
ELEC_CDR_output = JuMP.value.( sum(CDR_dispatch[:,:,:,d] * elecConsumed_CDR[d] for d = 1:CDR) )
# Specify the path to the CSV file where you want to save the data
resultName   = "$(top_dir)/ELEC_CDR_HOURLY"
temporalName = string("_$(T_inv)","Inv","+","$(N_Periods)","RepDays")
scenarioName = string("_MDS","$(FormEnergy_allowed)","+","PHS","$(PHS_allowed)")
#
outputName = string(resultName, temporalName, scenarioName,".csv")
##
process_gasOutput(ELEC_CDR_output, outputName)




##########################################################################
############### STORAGE CHARGE/DISCHARGE ELEC FLOWS EXPORTS ##############
##########################################################################
# the data should sum up to the charging/discharging from the previous block

# data form before:
### Charging
ELEC_Charging_vec = JuMP.value.( charging_ELEC[:,:,:,:] )
### Discharging
ELEC_Discharging_vec = JuMP.value.( discharging_ELEC[:,:,:,:] )

# for each storage technology:
idx_LiBattery = PrimeMover_STORAGE_ELEC .== fill("Li-ion battery", length(PrimeMover_STORAGE_ELEC))
idx_PHS       = PrimeMover_STORAGE_ELEC .== fill("Pumped hydro storage", length(PrimeMover_STORAGE_ELEC))
idx_FeBattery = PrimeMover_STORAGE_ELEC .== fill("Multi-day storage", length(PrimeMover_STORAGE_ELEC))
idx_H2Storage = PrimeMover_STORAGE_ELEC .== fill("Long-duration storage", length(PrimeMover_STORAGE_ELEC))


### Li-ion
#
ELEC_Charging_LiIon    = sum(ELEC_Charging_vec[:,:,:,idx_LiBattery], dims=4)
ELEC_Discharging_LiIon = sum(ELEC_Discharging_vec[:,:,:,idx_LiBattery], dims=4)
## charging
resultName   = "$(top_dir)/ELEC_Charging_LiIon_HOURLY"
temporalName = string("_$(T_inv)","Inv","+","$(N_Periods)","RepDays")
scenarioName = string("_MDS","$(FormEnergy_allowed)","+","PHS","$(PHS_allowed)")
#
outputName = string(resultName, temporalName, scenarioName,".csv")
##
process_gasOutput(ELEC_Charging_LiIon, outputName)

## discharging
resultName   = "$(top_dir)/ELEC_Discharging_LiIon_HOURLY"
temporalName = string("_$(T_inv)","Inv","+","$(N_Periods)","RepDays")
scenarioName = string("_MDS","$(FormEnergy_allowed)","+","PHS","$(PHS_allowed)")
#
outputName = string(resultName, temporalName, scenarioName,".csv")
##
process_gasOutput(ELEC_Discharging_LiIon, outputName)



### PHS
#
ELEC_Charging_PHS    = sum(ELEC_Charging_vec[:,:,:,idx_PHS], dims=4)
ELEC_Discharging_PHS = sum(ELEC_Discharging_vec[:,:,:,idx_PHS], dims=4)
## charging
resultName   = "$(top_dir)/ELEC_Charging_PHS_HOURLY"
temporalName = string("_$(T_inv)","Inv","+","$(N_Periods)","RepDays")
scenarioName = string("_MDS","$(FormEnergy_allowed)","+","PHS","$(PHS_allowed)")
#
outputName = string(resultName, temporalName, scenarioName,".csv")
##
process_gasOutput(ELEC_Charging_PHS, outputName)

## discharging
resultName   = "$(top_dir)/ELEC_Discharging_PHS_HOURLY"
temporalName = string("_$(T_inv)","Inv","+","$(N_Periods)","RepDays")
scenarioName = string("_MDS","$(FormEnergy_allowed)","+","PHS","$(PHS_allowed)")
#
outputName = string(resultName, temporalName, scenarioName,".csv")
##
process_gasOutput(ELEC_Discharging_PHS, outputName)



### FeBattery
#
ELEC_Charging_FeBattery    = sum(ELEC_Charging_vec[:,:,:,idx_FeBattery], dims=4)
ELEC_Discharging_FeBattery = sum(ELEC_Discharging_vec[:,:,:,idx_FeBattery], dims=4)
## charging
resultName   = "$(top_dir)/ELEC_Charging_FeBattery_HOURLY"
temporalName = string("_$(T_inv)","Inv","+","$(N_Periods)","RepDays")
scenarioName = string("_MDS","$(FormEnergy_allowed)","+","PHS","$(PHS_allowed)")
#
outputName = string(resultName, temporalName, scenarioName,".csv")
##
process_gasOutput(ELEC_Charging_FeBattery, outputName)

## discharging
resultName   = "$(top_dir)/ELEC_Discharging_FeBattery_HOURLY"
temporalName = string("_$(T_inv)","Inv","+","$(N_Periods)","RepDays")
scenarioName = string("_MDS","$(FormEnergy_allowed)","+","PHS","$(PHS_allowed)")
#
outputName = string(resultName, temporalName, scenarioName,".csv")
##
process_gasOutput(ELEC_Discharging_FeBattery, outputName)



### H2Storage
#
ELEC_Charging_H2Storage    = sum(ELEC_Charging_vec[:,:,:,idx_H2Storage], dims=4)
ELEC_Discharging_H2Storage = sum(ELEC_Discharging_vec[:,:,:,idx_H2Storage], dims=4)
## charging
resultName   = "$(top_dir)/ELEC_Charging_H2Storage_HOURLY"
temporalName = string("_$(T_inv)","Inv","+","$(N_Periods)","RepDays")
scenarioName = string("_MDS","$(FormEnergy_allowed)","+","PHS","$(PHS_allowed)")
#
outputName = string(resultName, temporalName, scenarioName,".csv")
##
process_gasOutput(ELEC_Charging_H2Storage, outputName)

## discharging
resultName   = "$(top_dir)/ELEC_Discharging_H2Storage_HOURLY"
temporalName = string("_$(T_inv)","Inv","+","$(N_Periods)","RepDays")
scenarioName = string("_MDS","$(FormEnergy_allowed)","+","PHS","$(PHS_allowed)")
#
outputName = string(resultName, temporalName, scenarioName,".csv")
##
process_gasOutput(ELEC_Discharging_H2Storage, outputName)





##########################################################################
############################# GEN EXPORTS ################################
##########################################################################

# determine pre capacity
preCapacity_GEN = (NumUnits_GEN .* UnitSize_GEN)

# define array based on inv periods
invCapacity_GEN = zeros(T_inv, length(preCapacity_GEN))
# loop
for i=1:T_inv
    #
    netForInvP = UnitSize_GEN .* (sum( JuMP.value.(unitsbuilt_GEN[invP,:]) - JuMP.value.(unitsretired_GEN[invP,:]) for invP = 1:i))
    invCapacity_GEN[i,:] = preCapacity_GEN[:] + netForInvP[:]
end

# Create an empty dictionary
idx_GEN = Dict{String, Vector{Bool}}()
#
GenTechnology = unique(PrimeMover_GEN)

# loop to get indeces
for i in 1:length(GenTechnology)
    key = GenTechnology[i]
    value = PrimeMover_GEN .== fill(key, length(PrimeMover_GEN))

    # Add the key-value pair to the dictionary
    idx_GEN[key] = BitVector(value)
end


# # loop to concatenate
cap_GEN_matrix = Dict{String, Matrix}()
energy_GEN = Dict{String, Vector}()
for i in 1:length(GenTechnology)
    key = GenTechnology[i]
    idx = idx_GEN[key]
    cap_GEN_matrix[key] = vcat(transpose(preCapacity_GEN[idx]), invCapacity_GEN[:,idx])
end

# add the technologies' power cap
cap_GEN = Dict{String, Vector}()
for i in 1:length(GenTechnology)
    key = GenTechnology[i]
    cap_GEN[key] = vec(sum(cap_GEN_matrix[key], dims=2))
end


# create dataframe
df = DataFrame(cap_GEN)
#
resultName   = "$(top_dir)/GEN_POWER_CAPACITIES"
temporalName = string("_$(T_inv)","Inv","+","$(N_Periods)","RepDays")
scenarioName = string("_MDS","$(FormEnergy_allowed)","+","PHS","$(PHS_allowed)")
outputName = string(resultName, temporalName, scenarioName,".csv")
#
CSV.write(outputName, df, writeheader = true)


######### now for energy generation by generator prime mover:
EnergyGen = sum(weights[:,T].*8760/t_ops.*sum(JuMP.value.(generation[:,T,t,:]) for t = 1:t_ops) for T = 1:T_ops)
#
energy_GEN = Dict{String, Vector}()
# loop to combine different sources to 1
for i in 1:length(GenTechnology)
    key = GenTechnology[i]
    idx = idx_GEN[key]
    energy_GEN[key] = vec(sum(EnergyGen[:,idx], dims=2))
end

# create dataframe
df = DataFrame(energy_GEN)
#
resultName   = "$(top_dir)/GEN_ENERGY_OUTPUT"
temporalName = string("_$(T_inv)","Inv","+","$(N_Periods)","RepDays")
scenarioName = string("_MDS","$(FormEnergy_allowed)","+","PHS","$(PHS_allowed)")
outputName = string(resultName, temporalName, scenarioName,".csv")
#
CSV.write(outputName, df, writeheader = true)



##########################################################################
######################### YEARLY STORAGE EXPORTS #########################
##########################################################################
#
## then let's find the indeces of the different storage mechanisms
idx_LiBattery = PrimeMover_STORAGE_ELEC .== fill("Li-ion battery", length(PrimeMover_STORAGE_ELEC))
idx_PHS       = PrimeMover_STORAGE_ELEC .== fill("Pumped hydro storage", length(PrimeMover_STORAGE_ELEC))
idx_FeBattery = PrimeMover_STORAGE_ELEC .== fill("Multi-day storage", length(PrimeMover_STORAGE_ELEC))
idx_H2Storage = PrimeMover_STORAGE_ELEC .== fill("Long-duration storage", length(PrimeMover_STORAGE_ELEC))

totalStorageSOC_LiBattery = sum(JuMP.value.(SOCTracked_ELEC[:,:,idx_LiBattery]), dims=3)
totalStorageSOC_PHS       = sum(JuMP.value.(SOCTracked_ELEC[:,:,idx_PHS]), dims=3)
totalStorageSOC_FeBattery = sum(JuMP.value.(SOCTracked_ELEC[:,:,idx_FeBattery]), dims=3)
totalStorageSOC_H2Storage = sum(JuMP.value.(SOCTracked_ELEC[:,:,idx_H2Storage]), dims=3)
totalStorageSOC_GAS = sum(JuMP.value.(SOCTracked_GAS), dims=3)

findmax(totalStorageSOC_LiBattery)

storageTypes = ["Li-ion battery", "Pumped hydro storage", "Multi-day storage", "Long-duration storage", "Natural gas storage"]

# Determine the column names for each slice in the third dimension
column_names = String[]  # Initialize as an empty string array
for i = 1:size(storageTypes, 1)
    prefix = storageTypes[i]
    for j = 1:size(totalStorageSOC_LiBattery, 1)
        suffix = "InvPeriod_$(j)"
        push!(column_names, string(prefix, "+", suffix))
    end
end

# create yearly flows matrix, assign it to LiBattery 
# yearlyStorageFlows = totalStorageSOC_LiBattery[1, :,:]
# Li-ion
# if size(totalStorageSOC_LiBattery, 1) > 1
#     for i = 2:size(totalStorageSOC_LiBattery, 1)
#         yearlyStorageFlows = hcat(yearlyStorageFlows, totalStorageSOC_LiBattery[i, :,:])
#     end
# end
# # PHS
# for i = 1:size(totalStorageSOC_PHS, 1)
#     yearlyStorageFlows = hcat(yearlyStorageFlows, totalStorageSOC_PHS[i, :,:])
# end
# # MDS
# for i = 1:size(totalStorageSOC_FeBattery, 1)
#     yearlyStorageFlows = hcat(yearlyStorageFlows, totalStorageSOC_FeBattery[i, :,:])
# end
# # H2
# for i = 1:size(totalStorageSOC_H2Storage, 1)
#     yearlyStorageFlows = hcat(yearlyStorageFlows, totalStorageSOC_H2Storage[i, :,:])
# end
# # GAS
# for i = 1:size(totalStorageSOC_GAS, 1)
#     yearlyStorageFlows = hcat(yearlyStorageFlows, totalStorageSOC_GAS[i, :,:])
# end

function concatenateYearlyOutput(input, output)
    # add
    for i = 1:size(input, 1)
        output = hcat(output, input[i, :,:])
    end
    return output
end

yearlyStorageFlows = totalStorageSOC_LiBattery[1, :,:]
#
yearlyStorageFlows = concatenateYearlyOutput(totalStorageSOC_LiBattery, yearlyStorageFlows)
yearlyStorageFlows = concatenateYearlyOutput(totalStorageSOC_PHS, yearlyStorageFlows)
yearlyStorageFlows = concatenateYearlyOutput(totalStorageSOC_FeBattery, yearlyStorageFlows)
yearlyStorageFlows = concatenateYearlyOutput(totalStorageSOC_H2Storage, yearlyStorageFlows)
yearlyStorageFlows = concatenateYearlyOutput(totalStorageSOC_GAS, yearlyStorageFlows)
yearlyStorageFlows = yearlyStorageFlows[:,2:end]

# Create a DataFrame with column names
df = DataFrame(yearlyStorageFlows, column_names)

# Rename the columns to the specified names
rename!(df, Symbol.(column_names))

#
resultName   = "$(top_dir)/YEARLY_STORAGE_FLOWS"
temporalName = string("_$(T_inv)","Inv","+","$(N_Periods)","RepDays")
scenarioName = string("_MDS","$(FormEnergy_allowed)","+","PHS","$(PHS_allowed)")
outputName = string(resultName, temporalName, scenarioName,".csv")
# Save the DataFrame to a CSV file
CSV.write(outputName, df)


##########################################################################
### PER STORAGE SITE

function process_SOCoutput(SOC_output, outputName)
    # Initialize as an empty string array
    column_names = String[]
    SOC_output2D = zeros(size(SOC_output, 2), size(SOC_output, 1) * size(SOC_output, 3) )
    #
    counter = 1
    #
    for i = 1:size(SOC_output, 1)
        prefix = "InvPeriod_$(i)"
        for j = 1:size(SOC_output, 3)
            # create name
            suffix = "StorageSite_$(GasStorage[!, "Storage_ID"][j])"
            push!(column_names, string(prefix, "+", suffix))
            # fill SOC_output2D
            SOC_output2D[:,counter] = SOC_output[i,:,j]
            # update counter
            counter = counter + 1
        end
    end
    # Create a DataFrame with column names
    df = DataFrame(SOC_output2D, column_names)

    # Rename the columns to the specified names
    rename!(df, Symbol.(column_names))
    # Save the DataFrame to a CSV file
    CSV.write(outputName, df)
end

# gas storage sites
SOC_output = JuMP.value.(SOCTracked_GAS)
resultName   = "$(top_dir)/PerGasStorageSite_YEARLY_STORAGE_FLOWS"
temporalName = string("_$(T_inv)","Inv","+","$(N_Periods)","RepDays")
scenarioName = string("_MDS","$(FormEnergy_allowed)","+","PHS","$(PHS_allowed)")
outputName = string(resultName, temporalName, scenarioName,".csv")
#
process_SOCoutput(SOC_output, outputName)

##########################################################################
### Between Nodes
#
function process_flowsBwNodes(gasFlows, outputName)
    # Initialize as an empty string array
    column_names = String[]
    gasFlows2D = zeros(size(gasFlows, 2), size(gasFlows, 1) * size(gasFlows, 3) )
    #
    counter = 1
    #
    for i = 1:size(gasFlows, 1)
        prefix = "InvPeriod_$(i)"
        for j = 1:size(gasFlows, 3)
            # create name
            linkName = string(TransmissionLinks_GAS[!,"Node In"][j]) * "-" * string(TransmissionLinks_GAS[!,"Node Out"][j])
            suffix = "Edge_" * linkName
            push!(column_names, string(prefix, "+", suffix))
            # fill SOC_output2D
            gasFlows2D[:,counter] = gasFlows[i,:,j]
            # update counter
            counter = counter + 1
        end
    end
    # Create a DataFrame with column names
    df = DataFrame(gasFlows2D, column_names)

    # Rename the columns to the specified names
    rename!(df, Symbol.(column_names))
    # Save the DataFrame to a CSV file
    CSV.write(outputName, df)
end
# i = 1 cause natgas
GasFlows_bwNodes = JuMP.value.(NominalGasFlows[:,:,:,1]) * LHV[1] * MolarMass[1]
resultName   = "$(top_dir)/BetweenNodes_RepDay_STORAGE_FLOWS"
temporalName = string("_$(T_inv)","Inv","+","$(N_Periods)","RepDays")
scenarioName = string("_MDS","$(FormEnergy_allowed)","+","PHS","$(PHS_allowed)")
outputName = string(resultName, temporalName, scenarioName,".csv")
#
process_flowsBwNodes(GasFlows_bwNodes, outputName)





##########################################################################
######################### STORAGE UNITS BY NODE ##########################
##########################################################################
#
### Storage units by node and type
#
#### Storage Units
preCapacity_ELEC = (NumUnits_STORAGE_ELEC)
# define array based on inv periods
invCapacity_Built_ELEC = zeros(T_inv, length(preCapacity_ELEC))
invCapacity_Ret_ELEC = zeros(T_inv, length(preCapacity_ELEC))
# loop
for i = 1:T_inv
    #
    invCapacity_Built_ELEC[i,:] = JuMP.value.(unitsbuilt_STORAGE_ELEC[i,:])
    invCapacity_Ret_ELEC[i,:] = JuMP.value.(unitsretired_STORAGE_ELEC[i,:])
end

# find types 
nodeNumber = unique(ElectricalStorage[:,1])
storageType = unique(PrimeMover_STORAGE_ELEC)
# find number of storage types and nodes
numNodes = length(nodeNumber)
numStorageTypes = length(storageType)
#
invCapacity_Built_CZ_ELEC = zeros(T_inv, numStorageTypes, numNodes)
invCapacity_Ret_CZ_ELEC   = zeros(T_inv, numStorageTypes, numNodes)
#
for i = 1:T_inv
    # generate local version of built/ret for inv period I
    built_InvPeriod = invCapacity_Built_ELEC[i,:]
    ret_InvPeriod   = invCapacity_Ret_ELEC[i,:]
    #
    for j = 1:numStorageTypes
        # find indexing based on storage type
        idx_Storage = PrimeMover_STORAGE_ELEC .== fill(storageType[j], length(PrimeMover_STORAGE_ELEC))
        for k = 1:numNodes
            # find indexing based on node
            idx_Node = ElectricalStorage[:,1] .== fill(nodeNumber[k], length(ElectricalStorage[:,1]))
            # intersection
            idx_intersection = idx_Storage .& idx_Node
            # find intersection and then add to 
            resultsBuilt_intersection = built_InvPeriod[idx_intersection]
            resultsRet_intersection   = ret_InvPeriod[idx_intersection]
            #
            resultsBuilt_array = zeros(length(idx_intersection))
            resultsRet_array   = zeros(length(idx_intersection))
            resultsBuilt_array[findall(idx_intersection .== 1)] = resultsBuilt_intersection
            resultsRet_array[findall(idx_intersection .== 1)]   = resultsRet_intersection
            #
            # add to matrix
            invCapacity_Built_CZ_ELEC[i,j,k] = sum(resultsBuilt_array)
            invCapacity_Ret_CZ_ELEC[i,j,k]   = sum(resultsRet_array)
        end
    end
end



function process_storageUnitsOutput(gas_output, outputName)
    # Determine the column names for each slice in the third dimension
    column_names = String[]  # Initialize as an empty string array
    for i = 1:size(gas_output, 1)
        prefix = "InvPeriod_$(i)"
        for j = 1:size(gas_output, 2)
            suffix = storageType[j]
            push!(column_names, string(prefix, "+", suffix))
        end
    end

    # Reshape the 3D matrix into a 2D matrix
    gas_output2D = gas_output[1, :,:]'
    if size(gas_output, 1) > 1
        for i = 2:size(gas_output, 1)
            gas_output2D = hcat(gas_output2D, gas_output[i, :,:]')
        end
    end

    # Create a DataFrame with column names
    df = DataFrame(gas_output2D, column_names)

    # Rename the columns to the specified names
    rename!(df, Symbol.(column_names))

    # Save the DataFrame to a CSV file
    CSV.write(outputName, df)
end


### Built
# Specify the path to the CSV file where you want to save the data
resultName   = "$(top_dir)/NumUnitsBuilt_StorageELEC_PerNode"
temporalName = string("_$(T_inv)","Inv","+","$(N_Periods)","RepDays")
scenarioName = string("_MDS","$(FormEnergy_allowed)","+","PHS","$(PHS_allowed)")
#
outputName = string(resultName, temporalName, scenarioName,".csv")
##
process_storageUnitsOutput(invCapacity_Built_CZ_ELEC, outputName)

### Built
# Specify the path to the CSV file where you want to save the data
resultName   = "$(top_dir)/NumUnitsRet_StorageELEC_PerNode"
temporalName = string("_$(T_inv)","Inv","+","$(N_Periods)","RepDays")
scenarioName = string("_MDS","$(FormEnergy_allowed)","+","PHS","$(PHS_allowed)")
#
outputName = string(resultName, temporalName, scenarioName,".csv")
##
process_storageUnitsOutput(invCapacity_Ret_CZ_ELEC, outputName)




##########################################################################
# 
### ELEC Storage units by node and type in final year **ONLY**
##
#### Storage Capacity in MW
preCapacity_ELEC = (NumUnits_STORAGE_ELEC .* UnitSize_STORAGE_ELEC)
# define array based on inv periods
invCapacity_ELEC = zeros(1, length(preCapacity_ELEC))
# loop
for i=T_inv
    #
    netForInvP = UnitSize_STORAGE_ELEC .* sum( JuMP.value.(unitsbuilt_STORAGE_ELEC[invP,:]) - JuMP.value.(unitsretired_STORAGE_ELEC[invP,:]) for invP = 1:i)
    invCapacity_ELEC[1,:] = preCapacity_ELEC[:] + netForInvP[:]
end


# find types 
nodeNumber = unique(ElectricalStorage[:,1])
storageType = unique(PrimeMover_STORAGE_ELEC)
# find number of storage types and nodes
numNodes = length(nodeNumber)
numStorageTypes = length(storageType)
#
invCapacity_Total_CZ_ELEC = zeros(1, numStorageTypes, numNodes)
#
for i = T_inv
    # # generate local version of built/ret for inv period I
    net_InvPeriod = invCapacity_ELEC[1,:]
    #
    for j = 1:numStorageTypes
        # find indexing based on storage type
        idx_Storage = PrimeMover_STORAGE_ELEC .== fill(storageType[j], length(PrimeMover_STORAGE_ELEC))
        for k = 1:numNodes
            # find indexing based on node
            idx_Node = ElectricalStorage[:,1] .== fill(nodeNumber[k], length(ElectricalStorage[:,1]))
            # intersection
            idx_intersection = idx_Storage .& idx_Node
            # find intersection and then add to 
            resultsTotal_intersection = net_InvPeriod[idx_intersection]
            #
            resultsTotal_array = zeros(length(idx_intersection))
            resultsTotal_array[findall(idx_intersection .== 1)] = resultsTotal_intersection
            #
            # add to matrix
            invCapacity_Total_CZ_ELEC[1,j,k] = sum(resultsTotal_array)
        end
    end
end



### NetCapacity
# Specify the path to the CSV file where you want to save the data
resultName   = "$(top_dir)/NetCapacity2045_StorageELEC_PerNode"
temporalName = string("_$(T_inv)","Inv","+","$(N_Periods)","RepDays")
scenarioName = string("_MDS","$(FormEnergy_allowed)","+","PHS","$(PHS_allowed)")
#
outputName = string(resultName, temporalName, scenarioName,".csv")
##
process_storageUnitsOutput(invCapacity_Total_CZ_ELEC, outputName)



##########################################################################
# 
### HEAT Storage units by node and type in final year **ONLY**
##
#### Storage Capacity in MW
preCapacity_HEAT = (NumUnits_STORAGE_HEAT .* UnitSize_STORAGE_HEAT)
# define array based on inv periods
invCapacity_HEAT = zeros(1, length(preCapacity_HEAT))
# loop
for i=T_inv
    #
    netForInvP = UnitSize_STORAGE_HEAT .* sum( JuMP.value.(unitsbuilt_STORAGE_HEAT[invP,:]) - JuMP.value.(unitsretired_STORAGE_HEAT[invP,:]) for invP = 1:i)
    invCapacity_HEAT[1,:] = preCapacity_HEAT[:] + netForInvP[:]
end


# find types 
nodeNumber = unique(HeatStorage[:,1])
storageType = unique(PrimeMover_STORAGE_HEAT)
# find number of storage types and nodes
numNodes = length(nodeNumber)
numStorageTypes = length(storageType)
#
invCapacity_Total_CZ_HEAT = zeros(1, numStorageTypes, numNodes)
#
for i = T_inv
    # # generate local version of built/ret for inv period I
    net_InvPeriod = invCapacity_HEAT[1,:]
    #
    for j = 1:numStorageTypes
        # find indexing based on storage type
        idx_Storage = PrimeMover_STORAGE_HEAT .== fill(storageType[j], length(PrimeMover_STORAGE_HEAT))
        for k = 1:numNodes
            # find indexing based on node
            idx_Node = HeatStorage[:,1] .== fill(nodeNumber[k], length(HeatStorage[:,1]))
            # intersection
            idx_intersection = idx_Storage .& idx_Node
            # find intersection and then add to 
            resultsTotal_intersection = net_InvPeriod[idx_intersection]
            #
            resultsTotal_array = zeros(length(idx_intersection))
            resultsTotal_array[findall(idx_intersection .== 1)] = resultsTotal_intersection
            #
            # add to matrix
            invCapacity_Total_CZ_HEAT[1,j,k] = sum(resultsTotal_array)
        end
    end
end



### NetCapacity
# Specify the path to the CSV file where you want to save the data
resultName   = "$(top_dir)/NetCapacity2045_StorageHEAT_PerNode"
temporalName = string("_$(T_inv)","Inv","+","$(N_Periods)","RepDays")
scenarioName = string("_MDS","$(FormEnergy_allowed)","+","PHS","$(PHS_allowed)")
#
outputName = string(resultName, temporalName, scenarioName,".csv")
##
process_storageUnitsOutput(invCapacity_Total_CZ_HEAT, outputName)



## REPEAT but for 2035
if T_inv > 3
    #### Storage Capacity in MW
    preCapacity_HEAT = (NumUnits_STORAGE_HEAT .* UnitSize_STORAGE_HEAT)
    # define array based on inv periods
    invCapacity_HEAT = zeros(1, length(preCapacity_HEAT))
    # loop
    for i = T_inv-2
        #
        netForInvP = UnitSize_STORAGE_HEAT .* sum( JuMP.value.(unitsbuilt_STORAGE_HEAT[invP,:]) - JuMP.value.(unitsretired_STORAGE_HEAT[invP,:]) for invP = 1:i)
        invCapacity_HEAT[1,:] = preCapacity_HEAT[:] + netForInvP[:]
    end


    # find types 
    nodeNumber = unique(HeatStorage[:,1])
    storageType = unique(PrimeMover_STORAGE_HEAT)
    # find number of storage types and nodes
    numNodes = length(nodeNumber)
    numStorageTypes = length(storageType)
    #
    invCapacity_Total_CZ_HEAT = zeros(1, numStorageTypes, numNodes)
    #
    for i = T_inv-2
        # # generate local version of built/ret for inv period I
        net_InvPeriod = invCapacity_HEAT[1,:]
        #
        for j = 1:numStorageTypes
            # find indexing based on storage type
            idx_Storage = PrimeMover_STORAGE_HEAT .== fill(storageType[j], length(PrimeMover_STORAGE_HEAT))
            for k = 1:numNodes
                # find indexing based on node
                idx_Node = HeatStorage[:,1] .== fill(nodeNumber[k], length(HeatStorage[:,1]))
                # intersection
                idx_intersection = idx_Storage .& idx_Node
                # find intersection and then add to 
                resultsTotal_intersection = net_InvPeriod[idx_intersection]
                #
                resultsTotal_array = zeros(length(idx_intersection))
                resultsTotal_array[findall(idx_intersection .== 1)] = resultsTotal_intersection
                #
                # add to matrix
                invCapacity_Total_CZ_HEAT[1,j,k] = sum(resultsTotal_array)
            end
        end
    end



    ### NetCapacity
    # Specify the path to the CSV file where you want to save the data
    resultName   = "$(top_dir)/NetCapacity2035_StorageHEAT_PerNode"
    temporalName = string("_$(T_inv)","Inv","+","$(N_Periods)","RepDays")
    scenarioName = string("_MDS","$(FormEnergy_allowed)","+","PHS","$(PHS_allowed)")
    #
    outputName = string(resultName, temporalName, scenarioName,".csv")
    ##
    process_storageUnitsOutput(invCapacity_Total_CZ_HEAT, outputName)

end




##########################################################################
########################### GEN UNITS BY NODE ############################
##########################################################################
#
### Storage capacities by node and type
#
#### Storage Units
preCapacity_GEN = (NumUnits_GEN)
# define array based on inv periods
invCapacity_Built_GEN = zeros(T_inv, length(preCapacity_GEN))
invCapacity_Ret_GEN = zeros(T_inv, length(preCapacity_GEN))
# loop
for i = 1:T_inv
    #
    invCapacity_Built_GEN[i,:] = JuMP.value.(unitsbuilt_GEN[i,:])
    invCapacity_Ret_GEN[i,:] = JuMP.value.(unitsretired_GEN[i,:])
end

# find types 
nodeNumber = unique(Generators[:,1])
genType = unique(PrimeMover_GEN)
# find number of storage types and nodes
numNodes = length(nodeNumber)
numGenTypes = length(genType)
#
invCapacity_Built_CZ_GEN = zeros(T_inv, numGenTypes, numNodes)
invCapacity_Ret_CZ_GEN   = zeros(T_inv, numGenTypes, numNodes)
#
for i = 1:T_inv
    # generate local version of built/ret for inv period I
    built_InvPeriod = invCapacity_Built_GEN[i,:]
    ret_InvPeriod   = invCapacity_Ret_GEN[i,:]
    #
    for j = 1:numGenTypes
        # find indexing based on storage type
        idx_Gen = PrimeMover_GEN .== fill(genType[j], length(PrimeMover_GEN))
        for k = 1:numNodes
            # find indexing based on node
            idx_Node = Generators[:,1] .== fill(nodeNumber[k], length(Generators[:,1]))
            # intersection
            idx_intersection = idx_Gen .& idx_Node
            # find intersection and then add to 
            resultsBuilt_intersection = built_InvPeriod[idx_intersection]
            resultsRet_intersection   = ret_InvPeriod[idx_intersection]
            #
            resultsBuilt_array = zeros(length(idx_intersection))
            resultsRet_array   = zeros(length(idx_intersection))
            resultsBuilt_array[findall(idx_intersection .== 1)] = resultsBuilt_intersection
            resultsRet_array[findall(idx_intersection .== 1)]   = resultsRet_intersection
            #
            # add to matrix
            invCapacity_Built_CZ_GEN[i,j,k] = sum(resultsBuilt_array)
            invCapacity_Ret_CZ_GEN[i,j,k]   = sum(resultsRet_array)
        end
    end
end



function process_genUnitsOutput(output, outputName)
    # Determine the column names for each slice in the third dimension
    column_names = String[]  # Initialize as an empty string array
    for i = 1:size(output, 1)
        prefix = "InvPeriod_$(i)"
        for j = 1:size(output, 2)
            suffix = genType[j]
            push!(column_names, string(prefix, "+", suffix))
        end
    end

    # Reshape the 3D matrix into a 2D matrix
    output2D = output[1, :,:]'
    if size(output, 1) > 1
        for i = 2:size(output, 1)
            output2D = hcat(output2D, output[i, :,:]')
        end
    end

    # Create a DataFrame with column names
    df = DataFrame(output2D, column_names)

    # Rename the columns to the specified names
    rename!(df, Symbol.(column_names))

    # Save the DataFrame to a CSV file
    CSV.write(outputName, df)
end


### Built
# Specify the path to the CSV file where you want to save the data
resultName   = "$(top_dir)/NumUnitsBuilt_GEN_PerNode"
temporalName = string("_$(T_inv)","Inv","+","$(N_Periods)","RepDays")
scenarioName = string("_MDS","$(FormEnergy_allowed)","+","PHS","$(PHS_allowed)")
#
outputName = string(resultName, temporalName, scenarioName,".csv")
##
process_genUnitsOutput(invCapacity_Built_CZ_GEN, outputName)

### Retired
# Specify the path to the CSV file where you want to save the data
resultName   = "$(top_dir)/NumUnitsRet_GEN_PerNode"
temporalName = string("_$(T_inv)","Inv","+","$(N_Periods)","RepDays")
scenarioName = string("_MDS","$(FormEnergy_allowed)","+","PHS","$(PHS_allowed)")
#
outputName = string(resultName, temporalName, scenarioName,".csv")
##
process_genUnitsOutput(invCapacity_Ret_CZ_GEN, outputName)



##########################################################################
# 
### GEN units by node and type in final year **ONLY**
##
#### GEN Capacity in MW
preCapacity_GEN = (NumUnits_GEN .* UnitSize_GEN)
# define array based on inv periods
invCapacity_GEN = zeros(1, length(preCapacity_GEN))
# loop
for i=T_inv
    #
    netForInvP = UnitSize_GEN .* sum( JuMP.value.(unitsbuilt_GEN[invP,:]) - JuMP.value.(unitsretired_GEN[invP,:]) for invP = 1:i)
    invCapacity_GEN[1,:] = preCapacity_GEN[:] + netForInvP[:]
end



# find types 
nodeNumber = unique(Generators[:,1])
genType = unique(PrimeMover_GEN)
# find number of gen types and nodes
numNodes = length(nodeNumber)
numGenTypes = length(genType)
#
invCapacity_Total_CZ_GEN = zeros(1, numGenTypes, numNodes)
#
for i = T_inv
    # # generate local version of built/ret for inv period I
    net_InvPeriod = invCapacity_GEN[1,:]
    #
    for j = 1:numGenTypes
        # find indexing based on gen type
        idx_GEN_0 = PrimeMover_GEN .== fill(genType[j], length(PrimeMover_GEN))
        for k = 1:numNodes
            # find indexing based on node
            idx_Node = Generators[:,1] .== fill(nodeNumber[k], length(Generators[:,1]))
            # intersection
            idx_intersection = idx_GEN_0 .& idx_Node
            # find intersection and then add to 
            resultsTotal_intersection = net_InvPeriod[idx_intersection]
            #
            resultsTotal_array = zeros(length(idx_intersection))
            resultsTotal_array[findall(idx_intersection .== 1)] = resultsTotal_intersection
            #
            # add to matrix
            invCapacity_Total_CZ_GEN[1,j,k] = sum(resultsTotal_array)
        end
    end
end



### NetCapacity
# Specify the path to the CSV file where you want to save the data
resultName   = "$(top_dir)/NetCapacity2045_GEN_PerNode"
temporalName = string("_$(T_inv)","Inv","+","$(N_Periods)","RepDays")
scenarioName = string("_MDS","$(FormEnergy_allowed)","+","PHS","$(PHS_allowed)")
#
outputName = string(resultName, temporalName, scenarioName,".csv")
##
process_genUnitsOutput(invCapacity_Total_CZ_GEN, outputName)




## REPEAT but for 2035
if T_inv > 3
    #### GEN Capacity in MW
    preCapacity_GEN = (NumUnits_GEN .* UnitSize_GEN)
    # define array based on inv periods
    invCapacity_GEN = zeros(1, length(preCapacity_GEN))
    # loop
    for i = T_inv-2
        #
        netForInvP = UnitSize_GEN .* sum( JuMP.value.(unitsbuilt_GEN[invP,:]) - JuMP.value.(unitsretired_GEN[invP,:]) for invP = 1:i)
        invCapacity_GEN[1,:] = preCapacity_GEN[:] + netForInvP[:]
    end



    # find types 
    nodeNumber = unique(Generators[:,1])
    genType = unique(PrimeMover_GEN)
    # find number of gen types and nodes
    numNodes = length(nodeNumber)
    numGenTypes = length(genType)
    #
    invCapacity_Total_CZ_GEN = zeros(1, numGenTypes, numNodes)
    #
    for i = T_inv-2
        # # generate local version of built/ret for inv period I
        net_InvPeriod = invCapacity_GEN[1,:]
        #
        for j = 1:numGenTypes
            # find indexing based on gen type
            idx_GEN_0 = PrimeMover_GEN .== fill(genType[j], length(PrimeMover_GEN))
            for k = 1:numNodes
                # find indexing based on node
                idx_Node = Generators[:,1] .== fill(nodeNumber[k], length(Generators[:,1]))
                # intersection
                idx_intersection = idx_GEN_0 .& idx_Node
                # find intersection and then add to 
                resultsTotal_intersection = net_InvPeriod[idx_intersection]
                #
                resultsTotal_array = zeros(length(idx_intersection))
                resultsTotal_array[findall(idx_intersection .== 1)] = resultsTotal_intersection
                #
                # add to matrix
                invCapacity_Total_CZ_GEN[1,j,k] = sum(resultsTotal_array)
            end
        end
    end


    ### NetCapacity
    # Specify the path to the CSV file where you want to save the data
    resultName   = "$(top_dir)/NetCapacity2035_GEN_PerNode"
    temporalName = string("_$(T_inv)","Inv","+","$(N_Periods)","RepDays")
    scenarioName = string("_MDS","$(FormEnergy_allowed)","+","PHS","$(PHS_allowed)")
    #
    outputName = string(resultName, temporalName, scenarioName,".csv")
    ##
    process_genUnitsOutput(invCapacity_Total_CZ_GEN, outputName)


end





##########################################################################
########################### COSTS & EMISSIONS ############################
##########################################################################
#
# output emissions and costs over investment periods
#
output_costEmissions = Dict{String, Vector}()
#
## emissions
key = "Total Emissions"
if consider_refrigerants == 1
    emissions_invPeriod = JuMP.value.(powerEmissions + gasEmissions + appEmissions + fugitiveMethaneEmissions + processEmissions)
else
    emissions_invPeriod = JuMP.value.(powerEmissions + gasEmissions + fugitiveMethaneEmissions + processEmissions)
end
output_costEmissions[key] = emissions_invPeriod


## clean gas emissions
key = "Clean Gas Emissions"
emissions_invPeriod = JuMP.value.(EF_NG*CleanGas_allsectors[:] / 1e6)
output_costEmissions[key] = emissions_invPeriod

## industrial gas emissions
key = "Industrial Gas Emissions"
emissions_invPeriod = JuMP.value.(sum(weights[:,T].*8760/t_ops.*EF_NG.*sum(sum(Industrial_HeatDemand_fromGAS[:,T,t,n] for n = 1:NODES_GAS) for t = 1:t_ops) for T = 1:T_ops) / 1e6)
output_costEmissions[key] = emissions_invPeriod

## power emissions
key = "Power Emissions, Calculated"
emissions_invPeriod = JuMP.value.(sum(weights[:,T].*8760/t_ops.*sum(sum((generation[:,T,t,g]*HeatRate[g] + startup_GEN[:,T,t,g]*StartupFuel[g])*emissions_factors[g] for g = 1:GEN) for t = 1:t_ops) for T = 1:T_ops) / 1e6)
output_costEmissions[key] = emissions_invPeriod

## power emissions
key = "Power Emissions"
emissions_invPeriod = JuMP.value.(powerEmissions)
output_costEmissions[key] = emissions_invPeriod

## gas emissions
key = "Gas Emissions"
emissions_invPeriod = JuMP.value.(gasEmissions)
output_costEmissions[key] = emissions_invPeriod

## gas emissions
key = "Gas Emissions, Calculated"
emissions_invPeriod = JuMP.value.(sum(weights[:,T].*8760/t_ops.*EF_NG.*sum(sum(Demand_GAS[:,T,t,n] for n = 1:NODES_GAS) for t = 1:t_ops) for T = 1:T_ops) / 1e6)
output_costEmissions[key] = emissions_invPeriod

if consider_refrigerants == 1
    ## app emissions
    key = "Appliances Emissions"
    emissions_invPeriod = JuMP.value.(appEmissions)
    output_costEmissions[key] = emissions_invPeriod

    ## app emissions
    key = "Appliances Emissions, Calculated"
    emissions_invPeriod = JuMP.value.(sum(appliance_leak[:,a] for a = 1:APPLIANCES))
    output_costEmissions[key] = emissions_invPeriod
end

## removed emissions via DAC
key = "Emissions Removed via CDR"
emissions_invPeriod = JuMP.value.(removedEmissions_CDR)
output_costEmissions[key] = emissions_invPeriod

## removed emissions via CCS combustion
key = "Emissions Removed via only CCS for All Combustion"
emissions_invPeriod = JuMP.value.( sum(weights[:,T].*8760/t_ops.*sum(sum( CDR_dispatch[:,T,t,d] for d in findall(idx_CDR_CCScombustion_all)) for t = 1:t_ops) for T = 1:T_ops) / 1e6 )
output_costEmissions[key] = emissions_invPeriod

## removed emissions via CCS combustion for heat only
key = "Emissions Removed via only CCS for Combustion for heat"
emissions_invPeriod = JuMP.value.( sum(weights[:,T].*8760/t_ops.*sum(sum( CDR_dispatch[:,T,t,d] for d in findall(idx_CDR_CCScombustion_heat)) for t = 1:t_ops) for T = 1:T_ops) / 1e6 )
output_costEmissions[key] = emissions_invPeriod

## removed emissions via DACCCS gas use only
key = "Emissions Removed via only CCS for Combustion for DACCS gas use"
emissions_invPeriod = JuMP.value.( sum(weights[:,T].*8760/t_ops.*sum(sum( CDR_dispatch[:,T,t,d] for d in findall(idx_CDR_CCScombustion_gasUse)) for t = 1:t_ops) for T = 1:T_ops) / 1e6 )
output_costEmissions[key] = emissions_invPeriod



## removed emissions via CCS process only
key = "Emissions Removed via only CCS for Process"
emissions_invPeriod = JuMP.value.( sum(weights[:,T].*8760/t_ops.*sum(sum( CDR_dispatch[:,T,t,d] for d in findall(idx_CDR_CCSprocess)) for t = 1:t_ops) for T = 1:T_ops) / 1e6 )
output_costEmissions[key] = emissions_invPeriod


## removed emissions via DAC only
key = "Emissions Removed via only DAC"
emissions_invPeriod = JuMP.value.( sum(weights[:,T].*8760/t_ops.*sum(sum( CDR_dispatch[:,T,t,d] for d in findall(idx_CDR_DACCS)) for t = 1:t_ops) for T = 1:T_ops) / 1e6 )
output_costEmissions[key] = emissions_invPeriod


## fugitive emissions
key = "Fugitive Methane Emissions"
emissions_invPeriod = JuMP.value.(fugitiveMethaneEmissions)
output_costEmissions[key] = emissions_invPeriod

## fugitive emissions
key = "Fugitive Methane Emissions, Calculated"
emissions_invPeriod = JuMP.value.(sum(weights[:,T].*8760/t_ops.*sum(SUPPLY_GAS_slack[:,T,n]*t_ops for n = 1:NODES_GAS) for T = 1:T_ops) * methane_leakage / EnergyContent_methane * GWP100_methane / 1e6)
output_costEmissions[key] = emissions_invPeriod

## process emissions
key = "Process Emissions"
emissions_invPeriod = JuMP.value.(processEmissions)
output_costEmissions[key] = emissions_invPeriod


## excess power emissions
key = "Excess Power Emissions"
emissions_invPeriod = JuMP.value.(excess_powerEmissions)
output_costEmissions[key] = emissions_invPeriod

## excess gas emissions
key = "Excess Gas Emissions"
emissions_invPeriod = JuMP.value.(excess_gasEmissions)
output_costEmissions[key] = emissions_invPeriod

if consider_refrigerants == 1
    ## excess app emissions
    key = "Excess Appliances Emissions"
    emissions_invPeriod = JuMP.value.(excess_refEmissions)
    output_costEmissions[key] = emissions_invPeriod
end

## gen
key = "Cost_Generation_Capital"
genCost_capital   = JuMP.value.(costs_GENcapital)
output_costEmissions[key] = genCost_capital
#
key = "Cost_Generation_Operating"
genCost_operating = JuMP.value.(costs_GENoperating)
output_costEmissions[key] = genCost_operating


## elec storage
key = "Cost_ElecStorage_Capital"
elecStorageCost_capital   = JuMP.value.(costs_ELECSTORAGEcapital)
output_costEmissions[key] = elecStorageCost_capital
#
key = "Cost_ElecStorage_Operating"
elecStorageCost_operating = JuMP.value.(costs_ELECSTORAGEoperating)
output_costEmissions[key] = elecStorageCost_operating

## heat storage
key = "Cost_HeatStorage_Capital"
heatStorageCost_capital   = JuMP.value.(costs_HEATSTORAGEcapital)
output_costEmissions[key] = heatStorageCost_capital
#
key = "Cost_HeatStorage_Operating"
heatStorageCost_operating = JuMP.value.(costs_HEATSTORAGEoperating)
output_costEmissions[key] = heatStorageCost_operating


## appliances
key = "Cost_Appliances"
appliancesCost = JuMP.value.(costs_appliances)
output_costEmissions[key] = appliancesCost


## P2G
key = "Cost_P2G_Capital"
P2GCost_capital   = JuMP.value.(costs_P2Gcapital)
output_costEmissions[key] = P2GCost_capital
#
key = "Cost_P2G_Operating"
P2GCost_operating = JuMP.value.(costs_P2Goperating)
output_costEmissions[key] = P2GCost_operating

## P2H
key = "Cost_P2H_Capital"
P2HCost_capital   = JuMP.value.(costs_P2Hcapital)
output_costEmissions[key] = P2HCost_capital
#
key = "Cost_P2H_Operating"
P2HCost_operating = JuMP.value.(costs_P2Hoperating)
output_costEmissions[key] = P2HCost_operating


## CDR
key = "Cost_CDR_Capital"
CDRCost_capital   = JuMP.value.(costs_CDRcapital)
output_costEmissions[key] = CDRCost_capital
#
key = "Cost_CDR_Operating"
CDRCost_operating = JuMP.value.(costs_CDRoperating)
output_costEmissions[key] = CDRCost_operating
#
key = "CDR_taxCredit"
CDRCost_credit = JuMP.value.(taxCredit_CDR)
output_costEmissions[key] = CDRCost_credit


## gas storage
key = "Cost_GasStorage_Capital"
gasStorageCost_capital   = JuMP.value.(costs_GASSTORAGEcapital)
output_costEmissions[key] = gasStorageCost_capital
#
key = "Cost_GasStorage_Operating"
gasStorageCost_operating = JuMP.value.(costs_GASSTORAGEoperating)
output_costEmissions[key] = gasStorageCost_operating


## distribution
key = "Cost_Distribution"
distributionCost = JuMP.value.(costs_distribution)
output_costEmissions[key] = distributionCost


## gas imports and storage
key = "Cost_GasImportsStorage"
gasImportsStorageCost = JuMP.value.(costs_NGimports + costs_gasStorage)
output_costEmissions[key] = gasImportsStorageCost


## CO2 offsets
key = "Cost_CO2offsets"
CO2offsetsCost = JuMP.value.(costs_CO2offsets)
output_costEmissions[key] = CO2offsetsCost


## elec transmission costs
key = "Cost_ElecTransmission"
elecTransmissionCost = JuMP.value.(costs_transmission)
output_costEmissions[key] = elecTransmissionCost


## gas transmission costs
key = "Cost_GasTransmission"
gasTransmissionCost = JuMP.value.(gasdistsyst_Cost)
output_costEmissions[key] = gasTransmissionCost


### technology specific costs
#
## 
## gen costs
idx_gen_dict = Dict(
    "Solar" => in(["Solar Thermal", "Solar PV", "Comm Solar PV", "Res Solar PV"]).(PrimeMover_GEN),
    "Wind"  => in(["Wind", "OffshoreWind"]).(PrimeMover_GEN),
    "NG"    => in(["Natural Gas CC", "Natural Gas CT", "Natural Gas CC-CCS"]).(PrimeMover_GEN),

)

for key_idx in keys(idx_gen_dict)
    idx_array = idx_gen_dict[key_idx]
    gen_indices = findall(idx_array)
    key = "SystemCost_" * key_idx

    systemCost = @expression(m, [I=1:T_inv],
        sum(UnitSize_GEN[g]*sum(unitsbuilt_GEN[i0,g]*max(min((Years[i0]+EconomicLifetime_GEN[g])-Years[I],1),0)*CRF_GEN[g]*CAPEX_GEN[i0,g] for i0 = 1:I) for g in gen_indices) +
        sum(UnitSize_GEN[g]*(NumUnits_GEN[g]+sum(unitsbuilt_GEN[i0,g]-unitsretired_GEN[i0,g] for i0 = 1:I))*FOM_GEN[I,g] for g in gen_indices) + 
        sum(weights[I,T]*8760/t_ops*sum(sum((VOM_GEN[I,g]+HeatRate[g]*FuelCosts[I,g]*(1-NG_fueled[g]))/1000*generation[I,T,t,g] for t = 1:t_ops) for g in gen_indices) for T = 1:T_ops) +
        sum(weights[I,T]*8760/t_ops*sum((StartUpCosts[g]+StartupFuel[g]*FuelCosts[I,g]*(1-NG_fueled[g]))/1000*sum(startup_GEN[I,T,t,g] for t = 1:t_ops) for g in gen_indices) for T = 1:T_ops)
    )

    genSystemCost = JuMP.value.(systemCost)
    output_costEmissions[key] = genSystemCost

end

## elec storage costs
idx_storageELEC_dict = Dict(
    "Li-ion"   => in(["Li-ion battery"]).(PrimeMover_STORAGE_ELEC),
    "Hydrogen" => in(["Long-duration storage"]).(PrimeMover_STORAGE_ELEC),
    "Fe-Air"   => in(["Multi-day storage"]).(PrimeMover_STORAGE_ELEC),
    "Pumped hydro storage" => in(["Pumped hydro storage"]).(PrimeMover_STORAGE_ELEC)
)

for key_idx in keys(idx_storageELEC_dict)
    idx_array = idx_storageELEC_dict[key_idx]
    gen_indices = findall(idx_array)
    key = "SystemCost_" * key_idx

    systemCost = @expression(m, [I=1:T_inv],
        sum(UnitSize_STORAGE_ELEC[s]*sum(unitsbuilt_STORAGE_ELEC[i0,s]*max(min((Years[i0]+EconomicLifetime_STORAGE_ELEC[s])-Years[I],1),0)*CRF_STORAGE_ELEC[s]*CAPEX_STORAGE_ELEC[i0,s] for i0 = 1:I) for s in gen_indices) +
        sum(UnitSize_STORAGE_ELEC[s]*(NumUnits_STORAGE_ELEC[s]+sum(unitsbuilt_STORAGE_ELEC[i0,s]-unitsretired_STORAGE_ELEC[i0,s] for i0 = 1:I))*FOM_STORAGE_ELEC[I,s] for s in gen_indices)
    )

    elecstorageSystemCost = JuMP.value.(systemCost)
    output_costEmissions[key] = elecstorageSystemCost

end


## heat storage costs
idx_storageHEAT_dict = Dict(
    "Heat Battery"     => in(["Rondo Heat Battery"]).(PrimeMover_STORAGE_HEAT),
    "Hydrogen-to-heat" => in(["Hydrogen-to-Heat"]).(PrimeMover_STORAGE_HEAT),
)

for key_idx in keys(idx_storageHEAT_dict)
    idx_array = idx_storageHEAT_dict[key_idx]
    gen_indices = findall(idx_array)
    key = "SystemCost_" * key_idx

    systemCost = @expression(m, [I=1:T_inv],
        sum(UnitSize_STORAGE_HEAT[s]*sum(unitsbuilt_STORAGE_HEAT[i0,s]*max(min((Years[i0]+EconomicLifetime_STORAGE_HEAT[s])-Years[I],1),0)*CRF_STORAGE_HEAT[s]*CAPEX_STORAGE_HEAT[i0,s] for i0 = 1:I) for s in gen_indices) +
        sum(UnitSize_STORAGE_HEAT[s]*(NumUnits_STORAGE_HEAT[s]+sum(unitsbuilt_STORAGE_HEAT[i0,s]-unitsretired_STORAGE_HEAT[i0,s] for i0 = 1:I))*FOM_STORAGE_HEAT[I,s] for s in gen_indices) +
        sum(sum(capacityBuilt_SteamTurbine[i0,s]*max(min((Years[i0]+EconomicLifetime_STORAGE_HEAT[s])-Years[I],1),0)*CRF_STORAGE_HEAT[s]*CAPEX_STEAM_TURBINE[i0,s] for i0 = 1:I) for s in gen_indices)
    )

    heatstorageSystemCost = JuMP.value.(systemCost)
    output_costEmissions[key] = heatstorageSystemCost

end


## P2H costs
idx_P2H_dict = Dict(
    "Electric Boiler" => in(["Electric Boiler"]).(PrimeMover_P2H),
    "Heat Pump"       => in(["Heat Pump"]).(PrimeMover_P2H),
)

for key_idx in keys(idx_P2H_dict)
    idx_array = idx_P2H_dict[key_idx]
    gen_indices = findall(idx_array)
    key = "SystemCost_" * key_idx

    systemCost = @expression(m, [I=1:T_inv],
        sum(UnitSize_P2H[d]*(NumUnits_P2H[d] + sum(unitsbuilt_P2H[i0,d]-unitsretired_P2H[i0,d] for i0 = 1:I))*FOM_P2H[I,d] for d in gen_indices) +
        sum(weights[I,T]*8760/t_ops*sum(sum(VOM_P2H[I,d]/1000*P2H_dispatch[I,T,t,d] for t = 1:t_ops) for d in gen_indices) for T = 1:T_ops) +
        sum(UnitSize_P2H[d]*sum(unitsbuilt_P2H[i0,d]*max(min((Years[i0]+EconomicLifetime_P2H[d])-Years[I],1),0)*CRF_P2H[d]*CAPEX_P2H[i0,d] for i0 = 1:I) for d in gen_indices)
    )

    P2HSystemCost = JuMP.value.(systemCost)
    output_costEmissions[key] = P2HSystemCost

end


## P2G costs
idx_P2G_dict = Dict(
    "Power-to-CH4" => in(["Net-zero CH4"]).(PrimeMover_P2G),
)

for key_idx in keys(idx_P2G_dict)
    idx_array = idx_P2G_dict[key_idx]
    gen_indices = findall(idx_array)
    key = "SystemCost_" * key_idx

    systemCost = @expression(m, [I=1:T_inv],
        sum(UnitSize_P2G[d]*(NumUnits_P2G[d] + sum(unitsbuilt_P2G[i0,d]-unitsretired_P2G[i0,d] for i0 = 1:I))*FOM_P2G[I,d] for d in gen_indices) +
        sum(weights[I,T]*8760/t_ops*sum(sum(VOM_P2G[I,d]/1000*P2G_dispatch[I,T,t,d] for t = 1:t_ops) for d in gen_indices) for T = 1:T_ops) +
        sum(UnitSize_P2G[d]*sum(unitsbuilt_P2G[i0,d]*max(min((Years[i0]+EconomicLifetime_P2G[d])-Years[I],1),0)*CRF_P2G[d]*CAPEX_P2G[i0,d] for i0 = 1:I) for d in gen_indices)
    )

    P2GSystemCost = JuMP.value.(systemCost)
    output_costEmissions[key] = P2GSystemCost

end




# Create a DataFrame with column names
df = DataFrame(output_costEmissions)

# naming
resultName   = "$(top_dir)/CostsAndEmissions"
#
outputName = string(resultName, ".csv")

# Save the DataFrame to a CSV file
CSV.write(outputName, df)






### DACCCS, detailed emission reductions
# get annual emissions captured for each tech for each investment year
emissions_DACCS = JuMP.value.( sum(weights[:,T].*8760/t_ops.*sum( CDR_dispatch[:,T,t,:] for t = 1:t_ops) for T = 1:T_ops) / 1e6 )
#
df_CCS = DataFrame(emissions_DACCS', Symbol.("T_inv" .* string.(1:size(emissions_DACCS, 1))))
# insert columns at the beginning
insertcols!(df_CCS, 1,
    :CDR_ID => carbonDioxideRemoval[:,3],
    :PrimeMover => PrimeMover_CDR,
    :CDR_Type => techType_CDR,
    :IndustrialServiceType => forIndustrialServiceType_CDR,
    :MaxRemoval => MaxNewUnitsTotal_CDR .* maxCapacityFactor_CDR
)

# naming
resultName   = "$(top_dir)/detailedCCSemissionsCaptured"
#
outputName = string(resultName, ".csv")
# Save the DataFrame to a CSV file
CSV.write(outputName, df_CCS)





##########################################################################
########################### Annual Gas Demand ############################
##########################################################################
#
# output gas demand over investment periods
#
output_gasDemand = Dict{String, Vector}()
#

## clean gas demand
key = "Clean Gas"
emissions_invPeriod = JuMP.value.(CleanGas_allsectors)
output_gasDemand[key] = emissions_invPeriod

## industrial gas demand
key = "Industrial Gas Demand"
emissions_invPeriod = JuMP.value.(sum(weights[:,T].*8760/t_ops.*sum(sum(Industrial_HeatDemand_fromGAS[:,T,t,n] for n = 1:NODES_GAS) for t = 1:t_ops) for T = 1:T_ops))
output_gasDemand[key] = emissions_invPeriod

# ## baseline gas demand
# key = "Baseline Gas Demand"
# emissions_invPeriod = JuMP.value.(sum(weights[:,T].*8760/t_ops.*sum(sum(BaselineDemand_fromGAS[:,T,t,n] for n = 1:NODES_GAS) for t = 1:t_ops) for T = 1:T_ops))
# output_gasDemand[key] = emissions_invPeriod

## CDR gas demand
key = "CDR Gas Demand"
emissions_invPeriod = JuMP.value.(sum(weights[:,T].*8760/t_ops.*sum(sum(CDR_Demand_fromGAS[:,T,t,n] for n = 1:NODES_GAS) for t = 1:t_ops) for T = 1:T_ops))
output_gasDemand[key] = emissions_invPeriod


## CCS-combustion heat
key = "CCS-combustion Heat Demand"
emissions_invPeriod = JuMP.value.(sum(weights[:,T].*8760/t_ops.*sum(sum( sum(CDR_NodalLoc_GAS[n,d]*CDR_dispatch[:,T,t,d]*heatConsumed_CDR[d] for d in findall(idx_CDR_CCScombustion_heat)) for n = 1:NODES_GAS) for t = 1:t_ops) for T = 1:T_ops))
output_gasDemand[key] = emissions_invPeriod

## CCS-combustion gas use
key = "CCS-combustion Gas Use Demand"
emissions_invPeriod = JuMP.value.(sum(weights[:,T].*8760/t_ops.*sum(sum( sum(CDR_NodalLoc_GAS[n,d]*CDR_dispatch[:,T,t,d]*heatConsumed_CDR[d] for d in findall(idx_CDR_CCScombustion_gasUse)) for n = 1:NODES_GAS) for t = 1:t_ops) for T = 1:T_ops))
output_gasDemand[key] = emissions_invPeriod

## CCS-combustion gas use
key = "CCS-Gas Demand to capture Process Emissions"
emissions_invPeriod = JuMP.value.(sum(weights[:,T].*8760/t_ops.*sum(sum( sum(CDR_NodalLoc_GAS[n,d]*CDR_dispatch[:,T,t,d]*heatConsumed_CDR[d] for d in findall(idx_CDR_CCSprocess)) for n = 1:NODES_GAS) for t = 1:t_ops) for T = 1:T_ops))
output_gasDemand[key] = emissions_invPeriod


## DAC-only gas use
key = "Gas Demand to run DAC"
emissions_invPeriod = JuMP.value.(sum(weights[:,T].*8760/t_ops.*sum(sum( sum(CDR_NodalLoc_GAS[n,d]*CDR_dispatch[:,T,t,d]*heatConsumed_CDR[d] for d in findall(idx_CDR_DACCS)) for n = 1:NODES_GAS) for t = 1:t_ops) for T = 1:T_ops))
output_gasDemand[key] = emissions_invPeriod





## appliances gas demand
key = "Appliances Gas Demand"
emissions_invPeriod = JuMP.value.(sum(weights[:,T].*8760/t_ops.*sum(sum(1000*sum(APPLIANCES_NodalLoc_GAS[n,a].*(unitsremaining_APPS[:,a])*ApplianceProfiles_GAS[T,t,a] for a = 1:APPLIANCES) for n = 1:NODES_GAS) for t = 1:t_ops) for T = 1:T_ops))
output_gasDemand[key] = emissions_invPeriod


## power gen gas demand
key = "Power Generation Gas Demand"
emissions_invPeriod = JuMP.value.(sum(weights[:,T].*8760/t_ops.*sum(sum( sum(GEN_NodalLoc_GAS[n,g]*(generation[:,T,t,g]*HeatRate[g] + startup_GEN[:,T,t,g]*StartupFuel[g])*MWh_PER_MMBTU*NG_fueled[g] for g = 1:GEN) for n = 1:NODES_GAS) for t = 1:t_ops) for T = 1:T_ops))
output_gasDemand[key] = emissions_invPeriod

## total non-power gen gas demand
key = "Total Non-power Gen Gas Demand"
emissions_invPeriod = JuMP.value.(sum(weights[:,T].*8760/t_ops.*sum(sum(Demand_GAS[:,T,t,n] for n = 1:NODES_GAS) for t = 1:t_ops) for T = 1:T_ops))
output_gasDemand[key] = emissions_invPeriod


## total baseline gas demand
key = "Baseline Gas Demand"
emissions_invPeriod = JuMP.value.(sum(weights[:,T].*8760/t_ops.*sum(sum(BaselineDemand_GAS[:,T,t,n] for n = 1:NODES_GAS) for t = 1:t_ops) for T = 1:T_ops))
output_gasDemand[key] = emissions_invPeriod


## total gas demand
key = "Total Gas Demand"
emissions_invPeriod = JuMP.value.(sum(weights[:,T].*8760/t_ops.*sum(sum(  sum(LHV[g]*MolarMass[g]*NominalGasOfftakes[:,T,t,n,g] for g = 1:GAS_COMPONENTS) for n = 1:NODES_GAS) for t = 1:t_ops) for T = 1:T_ops))
output_gasDemand[key] = emissions_invPeriod




#######################################
# Create a DataFrame with column names
df_gasDemand = DataFrame(output_gasDemand)

# naming
resultName = "$(top_dir)/DemandBreakdown_GAS"
outputName = string(resultName, ".csv")

# Save the DataFrame to a CSV file
CSV.write(outputName, df_gasDemand)





##########################################################################
########################### Annual ELEC Demand ############################
##########################################################################
#
# output gas demand over investment periods
#
output_elecDemand = Dict{String, Vector}()
#
## generation
key = "Generation"
elec_invPeriod = JuMP.value.(sum(weights[:,T].*8760/t_ops.*sum(sum( sum(GEN_NodalLoc_ELEC[n,g]*generation[:,T,t,g] for g = 1:GEN)  for n = 1:NODES_GAS) for t = 1:t_ops) for T = 1:T_ops))
output_elecDemand[key] = elec_invPeriod


## heat-to-grid
key = "Heat-to-grid"
elec_invPeriod = JuMP.value.(sum(weights[:,T].*8760/t_ops.*sum(sum( sum(STORAGE_HEAT_NodalLoc_HEAT[n,s] * discharging_HEAT_ToGridELEC[:,T,t,s] * heat2Grid_efficiency for s = 1:STORAGE_HEAT)  for n = 1:NODES_GAS) for t = 1:t_ops) for T = 1:T_ops))
output_elecDemand[key] = elec_invPeriod


## elec charging
key = "ELEC Charging"
elec_invPeriod = JuMP.value.(sum(weights[:,T].*8760/t_ops.*sum(sum( sum(STORAGE_ELEC_NodalLoc_ELEC[n,s]*(charging_ELEC[:,T,t,s]) for s = 1:STORAGE_ELEC)  for n = 1:NODES_GAS) for t = 1:t_ops) for T = 1:T_ops))
output_elecDemand[key] = elec_invPeriod


## elec discharging
key = "ELEC Discharging"
elec_invPeriod = JuMP.value.(sum(weights[:,T].*8760/t_ops.*sum(sum( sum(STORAGE_ELEC_NodalLoc_ELEC[n,s]*(discharging_ELEC[:,T,t,s]) for s = 1:STORAGE_ELEC)  for n = 1:NODES_GAS) for t = 1:t_ops) for T = 1:T_ops))
output_elecDemand[key] = elec_invPeriod


## Total Demand
key = "Total Demand"
elec_invPeriod = JuMP.value.(sum(weights[:,T].*8760/t_ops.*sum(sum( Demand_ELEC[:,T,t,n] for n = 1:NODES_GAS) for t = 1:t_ops) for T = 1:T_ops))
output_elecDemand[key] = elec_invPeriod


## Baseline ELEC Demand
key = "Baseline ELEC Demand"
elec_invPeriod = JuMP.value.(sum(weights[:,T].*8760/t_ops.*sum(sum( BaselineDemand_ELEC[:,T,t,n] for n = 1:NODES_GAS) for t = 1:t_ops) for T = 1:T_ops))
output_elecDemand[key] = elec_invPeriod


## Appliances ELEC Demand
key = "Appliances ELEC Demand"
elec_invPeriod = JuMP.value.(sum(weights[:,T].*8760/t_ops.*sum(sum( 1000*sum(APPLIANCES_NodalLoc_ELEC[n,a]*(unitsremaining_APPS[:,a])*ApplianceProfiles_ELEC[T,t,a] for a = 1:APPLIANCES) for n = 1:NODES_GAS) for t = 1:t_ops) for T = 1:T_ops))
output_elecDemand[key] = elec_invPeriod


## P2G
key = "P2G Demand"
elec_invPeriod = JuMP.value.(sum(weights[:,T].*8760/t_ops.*sum(sum( sum(P2G_NodalLoc_ELEC[n,d]*P2G_dispatch[:,T,t,d]*(1-ISBIOMETHANE[d]) for d = 1:P2G)   for n = 1:NODES_GAS) for t = 1:t_ops) for T = 1:T_ops))
output_elecDemand[key] = elec_invPeriod


## P2H
key = "P2H Demand"
elec_invPeriod = JuMP.value.(sum(weights[:,T].*8760/t_ops.*sum(sum( sum(P2H_NodalLoc_ELEC[n,d]*P2H_dispatch[:,T,t,d] for d = 1:P2H) for n = 1:NODES_GAS) for t = 1:t_ops) for T = 1:T_ops))
output_elecDemand[key] = elec_invPeriod


## heat charging demand
key = "Heat Storage Charging"
elec_invPeriod = JuMP.value.(sum(weights[:,T].*8760/t_ops.*sum(sum( sum(STORAGE_HEAT_NodalLoc_HEAT[n,s] * charging_HEAT[:,T,t,s] for s = 1:STORAGE_HEAT) for n = 1:NODES_GAS) for t = 1:t_ops) for T = 1:T_ops))
output_elecDemand[key] = elec_invPeriod


## CDR
key = "CDR Demand"
elec_invPeriod = JuMP.value.(sum(weights[:,T].*8760/t_ops.*sum(sum( sum(CDR_NodalLoc_ELEC[n,d]*CDR_dispatch[:,T,t,d]*elecConsumed_CDR[d] for d = 1:CDR) for n = 1:NODES_GAS) for t = 1:t_ops) for T = 1:T_ops))
output_elecDemand[key] = elec_invPeriod


## CCS-combustion heat
key = "CCS-combustion Heat Demand"
elec_invPeriod = JuMP.value.(sum(weights[:,T].*8760/t_ops.*sum(sum( sum(CDR_NodalLoc_ELEC[n,d]*CDR_dispatch[:,T,t,d]*elecConsumed_CDR[d] for d in findall(idx_CDR_CCScombustion_heat)) for n = 1:NODES_GAS) for t = 1:t_ops) for T = 1:T_ops))
output_elecDemand[key] = elec_invPeriod

## CCS-combustion gas use
key = "CCS-combustion Gas Use Demand"
elec_invPeriod = JuMP.value.(sum(weights[:,T].*8760/t_ops.*sum(sum( sum(CDR_NodalLoc_ELEC[n,d]*CDR_dispatch[:,T,t,d]*elecConsumed_CDR[d] for d in findall(idx_CDR_CCScombustion_gasUse)) for n = 1:NODES_GAS) for t = 1:t_ops) for T = 1:T_ops))
output_elecDemand[key] = elec_invPeriod

## DAC-only gas use
key = "Gas Demand to run DAC"
elec_invPeriod = JuMP.value.(sum(weights[:,T].*8760/t_ops.*sum(sum( sum(CDR_NodalLoc_ELEC[n,d]*CDR_dispatch[:,T,t,d]*elecConsumed_CDR[d] for d in findall(idx_CDR_DACCS)) for n = 1:NODES_GAS) for t = 1:t_ops) for T = 1:T_ops))
output_elecDemand[key] = elec_invPeriod


## CCS-combustion gas use
key = "CCS-Gas Demand to capture Process Emissions"
elec_invPeriod = JuMP.value.(sum(weights[:,T].*8760/t_ops.*sum(sum( sum(CDR_NodalLoc_ELEC[n,d]*CDR_dispatch[:,T,t,d]*elecConsumed_CDR[d] for d in findall(idx_CDR_CCSprocess)) for n = 1:NODES_GAS) for t = 1:t_ops) for T = 1:T_ops))
output_elecDemand[key] = elec_invPeriod


try
    ## Industrial Electricity Demand
    key = "Non-heat Industrial Electricity Demand"
    elec_invPeriod = [JuMP.value(sum(weights[I,T]*8760/t_ops*sum(sum(sum(
            INDUSTRIAL_NodalLoc_ELEC[n,a]*unitsremaining_INDUSTRIAL[I,a]*IndustrialProfiles_ELEC[T,t,a]*IndustrialPeakDemand[a]*decline_heatDemand[a,I]
            for a = 1:INDUSTRIAL) for n = 1:NODES_ELEC) for t = 1:t_ops) for T = 1:T_ops)) for I = 1:T_inv]
    output_elecDemand[key] = elec_invPeriod
catch
    print("Did not save.")
end






#######################################
# Create a DataFrame with column names
df_elecDemand = DataFrame(output_elecDemand)

# naming
resultName = "$(top_dir)/DemandBreakdown_ELEC"
outputName = string(resultName, ".csv")

# Save the DataFrame to a CSV file
CSV.write(outputName, df_elecDemand)




##########################################################################
##########################################################################
##########################################################################
########################### HEAT STORAGE CAP #############################
##########################################################################
#
# output heat storage capacity
#
#### Storage Capacity in MWh
preCapacity_HEAT = (NumUnits_STORAGE_HEAT .* UnitSize_STORAGE_HEAT)
# define array based on inv periods
invCapacity_HEAT = zeros(T_inv, length(preCapacity_HEAT))
invCapacity_SteamTurbine = zeros(T_inv, length(preCapacity_HEAT))
# loop
for i=1:T_inv
    #
    netForInvP = UnitSize_STORAGE_HEAT .* sum( JuMP.value.(unitsbuilt_STORAGE_HEAT[invP,:]) - JuMP.value.(unitsretired_STORAGE_HEAT[invP,:]) for invP = 1:i)
    invCapacity_HEAT[i,:] = preCapacity_HEAT[:] + netForInvP[:]
    #
    invCapacity_SteamTurbine[i,:] = sum( JuMP.value.(capacityBuilt_SteamTurbine[invP,:]) for invP = 1:i)
end

## then let's find the indeces of the different storage mechanisms
idx_RHB       = PrimeMover_STORAGE_HEAT .== fill("Rondo Heat Battery", length(PrimeMover_STORAGE_HEAT))
idx_H2H       = PrimeMover_STORAGE_HEAT .== fill("Hydrogen-to-Heat",   length(PrimeMover_STORAGE_HEAT))

# concatenate
capRHB_array       = vcat(transpose(preCapacity_HEAT[idx_RHB]), invCapacity_HEAT[:,idx_RHB])
capH2H_array       = vcat(transpose(preCapacity_HEAT[idx_H2H]), invCapacity_HEAT[:,idx_H2H])
capST_array        = vcat(transpose(preCapacity_HEAT .* 0), invCapacity_SteamTurbine)

# find sum
capRHB       = sum(capRHB_array, dims=2)
capH2H       = sum(capH2H_array, dims=2)
capST        = sum(capST_array, dims=2)


# Specify column names as strings
column_names = ["Heat Battery", "Hydrogen-to-Heat", "Steam Turbine"]

# Convert data to 1-dimensional arrays
capRHB       = vec(capRHB)
capH2H       = vec(capH2H)
capST        = vec(capST)

# Create a DataFrame with column names and data
df = DataFrame(column_names[1] => capRHB, column_names[2] => capH2H, column_names[3] => capST)

#
resultName   = "$(top_dir)/HEAT_STORAGE_CAPACITIES"
temporalName = string("_$(T_inv)","Inv","+","$(N_Periods)","RepDays")
scenarioName = string("_MDS","$(FormEnergy_allowed)","+","PHS","$(PHS_allowed)")
outputName = string(resultName, temporalName, scenarioName,".csv")
#
CSV.write(outputName, df, writeheader = true)




##########################################################################
###################### HEAT STORAGE UNITS BY NODE ########################
##########################################################################
#
### HEAT Storage units by node and type
#
#### HEAT Storage Units
preCapacity_HEAT = (NumUnits_STORAGE_HEAT)
# define array based on inv periods
invCapacity_Built_HEAT = zeros(T_inv, length(preCapacity_HEAT))
invCapacity_Ret_HEAT = zeros(T_inv, length(preCapacity_HEAT))
# loop
for i = 1:T_inv
    #
    invCapacity_Built_HEAT[i,:] = JuMP.value.(unitsbuilt_STORAGE_HEAT[i,:])
    invCapacity_Ret_HEAT[i,:] = JuMP.value.(unitsretired_STORAGE_HEAT[i,:])
end

# find types 
nodeNumber = unique(HeatStorage[:,1])
storageType = unique(PrimeMover_STORAGE_HEAT)
# find number of storage types and nodes
numNodes = length(nodeNumber)
numStorageTypes = length(storageType)
#
invCapacity_Built_CZ_HEAT = zeros(T_inv, numStorageTypes, numNodes)
invCapacity_Ret_CZ_HEAT   = zeros(T_inv, numStorageTypes, numNodes)
#
for i = 1:T_inv
    # generate local version of built/ret for inv period I
    built_InvPeriod = invCapacity_Built_HEAT[i,:]
    ret_InvPeriod   = invCapacity_Ret_HEAT[i,:]
    #
    for j = 1:numStorageTypes
        # find indexing based on storage type
        idx_Storage = PrimeMover_STORAGE_HEAT .== fill(storageType[j], length(PrimeMover_STORAGE_HEAT))
        for k = 1:numNodes
            # find indexing based on node
            idx_Node = HeatStorage[:,1] .== fill(nodeNumber[k], length(HeatStorage[:,1]))
            # intersection
            idx_intersection = idx_Storage .& idx_Node
            # find intersection and then add to 
            resultsBuilt_intersection = built_InvPeriod[idx_intersection]
            resultsRet_intersection   = ret_InvPeriod[idx_intersection]
            #
            resultsBuilt_array = zeros(length(idx_intersection))
            resultsRet_array   = zeros(length(idx_intersection))
            resultsBuilt_array[findall(idx_intersection .== 1)] = resultsBuilt_intersection
            resultsRet_array[findall(idx_intersection .== 1)]   = resultsRet_intersection
            #
            # add to matrix
            invCapacity_Built_CZ_HEAT[i,j,k] = sum(resultsBuilt_array)
            invCapacity_Ret_CZ_HEAT[i,j,k]   = sum(resultsRet_array)
        end
    end
end


### Built
# Specify the path to the CSV file where you want to save the data
resultName   = "$(top_dir)/NumUnitsBuilt_StorageHEAT_PerNode"
temporalName = string("_$(T_inv)","Inv","+","$(N_Periods)","RepDays")
scenarioName = string("_MDS","$(FormEnergy_allowed)","+","PHS","$(PHS_allowed)")
#
outputName = string(resultName, temporalName, scenarioName,".csv")
##
process_storageUnitsOutput(invCapacity_Built_CZ_HEAT, outputName)

### Retired
# Specify the path to the CSV file where you want to save the data
resultName   = "$(top_dir)/NumUnitsRet_StorageHEAT_PerNode"
temporalName = string("_$(T_inv)","Inv","+","$(N_Periods)","RepDays")
scenarioName = string("_MDS","$(FormEnergy_allowed)","+","PHS","$(PHS_allowed)")
#
outputName = string(resultName, temporalName, scenarioName,".csv")
##
process_storageUnitsOutput(invCapacity_Ret_CZ_HEAT, outputName)





##########################################################################
############### STORAGE CHARGE/DISCHARGE HEAT FLOWS EXPORTS ##############
##########################################################################
#
# data form before:
### Charging
HEAT_Charging_vec = JuMP.value.( charging_HEAT[:,:,:,:] )
### Discharging
HEAT_Discharging_vec = JuMP.value.( discharging_HEAT[:,:,:,:] )
### SOC
HEAT_SOC_vec = JuMP.value.( storedEnergy_HEAT[:,:,:,:] )

#
HEAT_Discharging_ToIndustry_vec = JuMP.value.( discharging_HEAT_ToIndustry[:,:,:,:] )
HEAT_Discharging_ToGrid_vec     = JuMP.value.( discharging_HEAT_ToGridELEC[:,:,:,:] )


# for each storage technology:
idx_RHB = PrimeMover_STORAGE_HEAT .== fill("Rondo Heat Battery", length(PrimeMover_STORAGE_HEAT))

### RHB
#
HEAT_Charging_RHB    = sum(HEAT_Charging_vec[:,:,:,idx_RHB], dims=4)
HEAT_Discharging_RHB = sum(HEAT_Discharging_vec[:,:,:,idx_RHB], dims=4)
## charging
resultName   = "$(top_dir)/HEAT_Charging_RHB_HOURLY"
temporalName = string("_$(T_inv)","Inv","+","$(N_Periods)","RepDays")
scenarioName = string("_MDS","$(FormEnergy_allowed)","+","PHS","$(PHS_allowed)")
#
outputName = string(resultName, temporalName, scenarioName,".csv")
##
process_gasOutput(HEAT_Charging_RHB, outputName)

## discharging
resultName   = "$(top_dir)/HEAT_Discharging_RHB_HOURLY"
temporalName = string("_$(T_inv)","Inv","+","$(N_Periods)","RepDays")
scenarioName = string("_MDS","$(FormEnergy_allowed)","+","PHS","$(PHS_allowed)")
#
outputName = string(resultName, temporalName, scenarioName,".csv")
##
process_gasOutput(HEAT_Discharging_RHB, outputName)

#
HEAT_SOC_RHB    = sum(HEAT_SOC_vec[:,:,:,idx_RHB], dims=4)
## SOC
resultName   = "$(top_dir)/HEAT_SOC_RHB_HOURLY"
temporalName = string("_$(T_inv)","Inv","+","$(N_Periods)","RepDays")
scenarioName = string("_MDS","$(FormEnergy_allowed)","+","PHS","$(PHS_allowed)")
#
outputName = string(resultName, temporalName, scenarioName,".csv")
##
process_gasOutput(HEAT_SOC_RHB, outputName)



#
HEAT_Discharging_ToIndustry = sum(HEAT_Discharging_ToIndustry_vec[:,:,:,idx_RHB], dims=4)
HEAT_Discharging_ToGrid     = sum(HEAT_Discharging_ToGrid_vec[:,:,:,idx_RHB], dims=4)

## discharging, to Industry
resultName   = "$(top_dir)/HEAT_Discharging_toIndustry_RHB_HOURLY"
temporalName = string("_$(T_inv)","Inv","+","$(N_Periods)","RepDays")
scenarioName = string("_MDS","$(FormEnergy_allowed)","+","PHS","$(PHS_allowed)")
#
outputName = string(resultName, temporalName, scenarioName,".csv")
##
process_gasOutput(HEAT_Discharging_ToIndustry, outputName)


## discharging, to Grid
resultName   = "$(top_dir)/HEAT_Discharging_toGrid_RHB_HOURLY"
temporalName = string("_$(T_inv)","Inv","+","$(N_Periods)","RepDays")
scenarioName = string("_MDS","$(FormEnergy_allowed)","+","PHS","$(PHS_allowed)")
#
outputName = string(resultName, temporalName, scenarioName,".csv")
##
process_gasOutput(HEAT_Discharging_ToGrid, outputName)



##########################################################################
######################### YEARLY STORAGE EXPORTS #########################
##########################################################################
#
## then let's find the indeces of the different storage mechanisms
idx_RHB = PrimeMover_STORAGE_HEAT .== fill("Rondo Heat Battery", length(PrimeMover_STORAGE_HEAT))

totalStorageSOC_RHB = sum(JuMP.value.(SOCTracked_HEAT[:,:,idx_RHB]), dims=3)

findmax(totalStorageSOC_RHB)

storageTypes = ["Rondo Heat Battery"]

# Determine the column names for each slice in the third dimension
column_names = String[]  # Initialize as an empty string array
for i = 1:size(storageTypes, 1)
    prefix = storageTypes[i]
    for j = 1:size(totalStorageSOC_RHB, 1)
        suffix = "InvPeriod_$(j)"
        push!(column_names, string(prefix, "+", suffix))
    end
end

function concatenateYearlyOutput(input, output)
    # add
    for i = 1:size(input, 1)
        output = hcat(output, input[i, :,:])
    end
    return output
end

yearlyHEATStorageFlows = totalStorageSOC_RHB[1, :,:]
#
yearlyHEATStorageFlows = concatenateYearlyOutput(totalStorageSOC_RHB, yearlyHEATStorageFlows)
yearlyHEATStorageFlows = yearlyHEATStorageFlows[:,2:end]

# Create a DataFrame with column names
df = DataFrame(yearlyHEATStorageFlows, column_names)

# Rename the columns to the specified names
rename!(df, Symbol.(column_names))

#
resultName   = "$(top_dir)/YEARLY_HEAT_STORAGE_FLOWS"
temporalName = string("_$(T_inv)","Inv","+","$(N_Periods)","RepDays")
scenarioName = string("_MDS","$(FormEnergy_allowed)","+","PHS","$(PHS_allowed)")
outputName = string(resultName, temporalName, scenarioName,".csv")
# Save the DataFrame to a CSV file
CSV.write(outputName, df)



##########################################################################
######################### INDUSTRIAL HEAT SPLIT ##########################
##########################################################################
# find split of industrial heat that is met between direct heat + gas
### GAS
##### OBSOLETE; WRONG OUTPUTS
HEAT_metByGas_single        = JuMP.value.( BaselineDemand_fromDirectHeat[:,:,:,:] )
### DIRECT HEAT
HEAT_metByDirectHeat_single = JuMP.value.( BaselineDemand_fromDirectHeat[:,:,:,:] )
### TOTAL HEAT
HEAT_single                 = JuMP.value.( BaselineDemand_GAS[:,:,:,:] )

### DIRECT HEAT: from RHB
HEAT_DirectHeatFromRHB_single = JuMP.value.( sum(discharging_HEAT_ToIndustry[:,:,:,s] + discharging_HEAT_ToGridELEC[:,:,:,s] * afterTurbine_efficiency for s in findall(idx_RHB) ) )
# from H2H
HEAT_DirectHeatFromH2H_single = JuMP.value.( sum(discharging_HEAT_ToIndustry[:,:,:,s] + discharging_HEAT_ToGridELEC[:,:,:,s] * afterTurbine_efficiency for s in findall(idx_H2H) ) )


### DIRECT HEAT: from Electric Boiler
HEAT_DirectHeatFromeBoiler_single  = JuMP.value.( sum(P2H_dispatch[:,:,:,d]*eta_P2H[d] for d in findall(idx_P2H_elecBoiler)) ) 
# from Heat Pump
HEAT_DirectHeatFromHeatPump_single = JuMP.value.( sum(P2H_dispatch[:,:,:,d]*eta_P2H[d] for d in findall(idx_P2H_heatPump)) ) 

# this one is different than others; it is an addition to the baseline heat; so so baseline is no longer == direct heat + gas ; alone
### Heat for CDR
HEAT_CDR_fromGas         = JuMP.value.( CDR_Demand_fromGAS[:,:,:,:] )
HEAT_CDR_fromDirectHeat  = JuMP.value.( CDR_Demand_fromDirectHeat[:,:,:,:] )
HEAT_CDR_single          = JuMP.value.( CDR_Demand_HEAT[:,:,:,:] )

# industrial heat from gas
HEAT_byGas_single = JuMP.value.( sum(Industrial_HeatDemand_fromGAS[:,:,:,n] for n = 1:NODES_GAS) )
HEAT_byGas_ONLYheat = JuMP.value.( sum(Industrial_HeatDemand_fromGAS_heatMagnitude[:,:,:,n] for n = 1:NODES_GAS) )
#
HEAT_byGas_ONLYheat_lowTemp  = JuMP.value.( sum(Industrial_HeatDemand_fromGAS_heatMagnitude_lowTemp[:,:,:,n] for n = 1:NODES_GAS) )
HEAT_byGas_ONLYheat_midTemp  = JuMP.value.( sum(Industrial_HeatDemand_fromGAS_heatMagnitude_midTemp[:,:,:,n] for n = 1:NODES_GAS) )
HEAT_byGas_ONLYheat_highTemp = JuMP.value.( sum(Industrial_HeatDemand_fromGAS_heatMagnitude_highTemp[:,:,:,n] for n = 1:NODES_GAS) )




### by temperature
idx_temp_low  = in(["T100.0"]).(IndustrialServices)
idx_temp_mid  = in(["T1000.0"]).(IndustrialServices)
idx_temp_high = in(["T1600.0"]).(IndustrialServices)

#
HEAT_RHB_low  = JuMP.value.( sum( sum( HeatStorage_discharge_facility[:,:,:,s,a] * TempCompat_HeatStorage[s,a] for a in findall(idx_temp_low)  ) for s in findall(idx_RHB) ) )
HEAT_RHB_mid  = JuMP.value.( sum( sum( HeatStorage_discharge_facility[:,:,:,s,a] * TempCompat_HeatStorage[s,a] for a in findall(idx_temp_mid)  ) for s in findall(idx_RHB) ) )
HEAT_RHB_high = JuMP.value.( sum( sum( HeatStorage_discharge_facility[:,:,:,s,a] * TempCompat_HeatStorage[s,a] for a in findall(idx_temp_high) ) for s in findall(idx_RHB) ) )

HEAT_H2H_low  = JuMP.value.( sum( sum( HeatStorage_discharge_facility[:,:,:,s,a] * TempCompat_HeatStorage[s,a] for a in findall(idx_temp_low)  ) for s in findall(idx_H2H) ) )
HEAT_H2H_mid  = JuMP.value.( sum( sum( HeatStorage_discharge_facility[:,:,:,s,a] * TempCompat_HeatStorage[s,a] for a in findall(idx_temp_mid)  ) for s in findall(idx_H2H) ) )
HEAT_H2H_high = JuMP.value.( sum( sum( HeatStorage_discharge_facility[:,:,:,s,a] * TempCompat_HeatStorage[s,a] for a in findall(idx_temp_high) ) for s in findall(idx_H2H) ) )

HEAT_HP_low  = JuMP.value.( sum( sum( P2H_dispatch_facility[:,:,:,d,a] * eta_P2H[d] * TempCompat_P2H[d,a] for a in findall(idx_temp_low)  ) for d in findall(idx_P2H_heatPump) ) )
HEAT_HP_mid  = JuMP.value.( sum( sum( P2H_dispatch_facility[:,:,:,d,a] * eta_P2H[d] * TempCompat_P2H[d,a] for a in findall(idx_temp_mid)  ) for d in findall(idx_P2H_heatPump) ) )
HEAT_HP_high = JuMP.value.( sum( sum( P2H_dispatch_facility[:,:,:,d,a] * eta_P2H[d] * TempCompat_P2H[d,a] for a in findall(idx_temp_high) ) for d in findall(idx_P2H_heatPump) ) )


HEAT_EB_low  = JuMP.value.( sum( sum( P2H_dispatch_facility[:,:,:,d,a] * eta_P2H[d] * TempCompat_P2H[d,a] for a in findall(idx_temp_low)  ) for d in findall(idx_P2H_elecBoiler) ) )
HEAT_EB_mid  = JuMP.value.( sum( sum( P2H_dispatch_facility[:,:,:,d,a] * eta_P2H[d] * TempCompat_P2H[d,a] for a in findall(idx_temp_mid)  ) for d in findall(idx_P2H_elecBoiler) ) )
HEAT_EB_high = JuMP.value.( sum( sum( P2H_dispatch_facility[:,:,:,d,a] * eta_P2H[d] * TempCompat_P2H[d,a] for a in findall(idx_temp_high) ) for d in findall(idx_P2H_elecBoiler) ) )





###
#
HEAT_metByGas_total         = sum(HEAT_metByGas_single[:,:,:,:], dims=4)
HEAT_metByDirectHeat_total  = sum(HEAT_metByDirectHeat_single[:,:,:,:], dims=4)
HEAT_total                  = sum(HEAT_single[:,:,:,:], dims=4)
#
HEAT_DirectHeat_RHB         = HEAT_DirectHeatFromRHB_single
HEAT_DirectHeat_H2H         = HEAT_DirectHeatFromH2H_single
#
HEAT_DirectHeat_eBoiler     = HEAT_DirectHeatFromeBoiler_single
HEAT_DirectHeatFromHeatPump = HEAT_DirectHeatFromHeatPump_single
#
HEAT_byGas = HEAT_byGas_single

#
HEAT_metByGas_forCDR        = sum(HEAT_CDR_fromGas[:,:,:,:], dims=4)
HEAT_metByDirectHeat_forCDR = sum(HEAT_CDR_fromDirectHeat[:,:,:,:], dims=4)
HEAT_CDR_total              = sum(HEAT_CDR_single[:,:,:,:], dims=4)


## GAS
resultName   = "$(top_dir)/BaselineDemand_fromGas_HOURLY"
temporalName = string("_$(T_inv)","Inv","+","$(N_Periods)","RepDays")
scenarioName = string("_MDS","$(FormEnergy_allowed)","+","PHS","$(PHS_allowed)")
#
outputName = string(resultName, temporalName, scenarioName,".csv")
##
process_gasOutput(HEAT_metByGas_total, outputName)

## DIRECT HEAT
resultName   = "$(top_dir)/BaselineDemand_fromDirectHeat_HOURLY"
temporalName = string("_$(T_inv)","Inv","+","$(N_Periods)","RepDays")
scenarioName = string("_MDS","$(FormEnergy_allowed)","+","PHS","$(PHS_allowed)")
#
outputName = string(resultName, temporalName, scenarioName,".csv")
##
process_gasOutput(HEAT_metByDirectHeat_total, outputName)

## DIRECT HEAT, from eBoiler
resultName   = "$(top_dir)/IndustrialHeatDemand_DirectHeatfromeBoiler_HOURLY"
temporalName = string("_$(T_inv)","Inv","+","$(N_Periods)","RepDays")
scenarioName = string("_MDS","$(FormEnergy_allowed)","+","PHS","$(PHS_allowed)")
#
outputName = string(resultName, temporalName, scenarioName,".csv")
##
process_gasOutput(HEAT_DirectHeat_eBoiler, outputName)

## DIRECT HEAT, from heat pump
resultName   = "$(top_dir)/IndustrialHeatDemand_DirectHeatfromHeatPump_HOURLY"
temporalName = string("_$(T_inv)","Inv","+","$(N_Periods)","RepDays")
scenarioName = string("_MDS","$(FormEnergy_allowed)","+","PHS","$(PHS_allowed)")
#
outputName = string(resultName, temporalName, scenarioName,".csv")
##
process_gasOutput(HEAT_DirectHeatFromHeatPump_single, outputName)


## DIRECT HEAT, from RHB
resultName   = "$(top_dir)/IndustrialHeatDemand_DirectHeatfromRHB_HOURLY"
temporalName = string("_$(T_inv)","Inv","+","$(N_Periods)","RepDays")
scenarioName = string("_MDS","$(FormEnergy_allowed)","+","PHS","$(PHS_allowed)")
#
outputName = string(resultName, temporalName, scenarioName,".csv")
##
process_gasOutput(HEAT_DirectHeat_RHB, outputName)


## DIRECT HEAT, from RHB, LOW TEMP
resultName   = "$(top_dir)/IndustrialHeatDemand_LowTempHeatfromRHB_HOURLY"
temporalName = string("_$(T_inv)","Inv","+","$(N_Periods)","RepDays")
scenarioName = string("_MDS","$(FormEnergy_allowed)","+","PHS","$(PHS_allowed)")
#
outputName = string(resultName, temporalName, scenarioName,".csv")
##
process_gasOutput(HEAT_RHB_low, outputName)

## DIRECT HEAT, from RHB, MID TEMP
resultName   = "$(top_dir)/IndustrialHeatDemand_MidTempHeatfromRHB_HOURLY"
temporalName = string("_$(T_inv)","Inv","+","$(N_Periods)","RepDays")
scenarioName = string("_MDS","$(FormEnergy_allowed)","+","PHS","$(PHS_allowed)")
#
outputName = string(resultName, temporalName, scenarioName,".csv")
##
process_gasOutput(HEAT_RHB_mid, outputName)

## DIRECT HEAT, from RHB, HIGH TEMP
resultName   = "$(top_dir)/IndustrialHeatDemand_HighTempHeatfromRHB_HOURLY"
temporalName = string("_$(T_inv)","Inv","+","$(N_Periods)","RepDays")
scenarioName = string("_MDS","$(FormEnergy_allowed)","+","PHS","$(PHS_allowed)")
#
outputName = string(resultName, temporalName, scenarioName,".csv")
##
process_gasOutput(HEAT_RHB_high, outputName)


## DIRECT HEAT, from H2H, LOW TEMP
resultName   = "$(top_dir)/IndustrialHeatDemand_LowTempHeatfromH2H_HOURLY"
temporalName = string("_$(T_inv)","Inv","+","$(N_Periods)","RepDays")
scenarioName = string("_MDS","$(FormEnergy_allowed)","+","PHS","$(PHS_allowed)")
#
outputName = string(resultName, temporalName, scenarioName,".csv")
##
process_gasOutput(HEAT_H2H_low, outputName)

## DIRECT HEAT, from H2H, MID TEMP
resultName   = "$(top_dir)/IndustrialHeatDemand_MidTempHeatfromH2H_HOURLY"
temporalName = string("_$(T_inv)","Inv","+","$(N_Periods)","RepDays")
scenarioName = string("_MDS","$(FormEnergy_allowed)","+","PHS","$(PHS_allowed)")
#
outputName = string(resultName, temporalName, scenarioName,".csv")
##
process_gasOutput(HEAT_H2H_mid, outputName)

## DIRECT HEAT, from H2H, HIGH TEMP
resultName   = "$(top_dir)/IndustrialHeatDemand_HighTempHeatfromH2H_HOURLY"
temporalName = string("_$(T_inv)","Inv","+","$(N_Periods)","RepDays")
scenarioName = string("_MDS","$(FormEnergy_allowed)","+","PHS","$(PHS_allowed)")
#
outputName = string(resultName, temporalName, scenarioName,".csv")
##
process_gasOutput(HEAT_H2H_high, outputName)


## DIRECT HEAT, from HP, LOW TEMP
resultName   = "$(top_dir)/IndustrialHeatDemand_LowTempHeatfromHP_HOURLY"
temporalName = string("_$(T_inv)","Inv","+","$(N_Periods)","RepDays")
scenarioName = string("_MDS","$(FormEnergy_allowed)","+","PHS","$(PHS_allowed)")
#
outputName = string(resultName, temporalName, scenarioName,".csv")
##
process_gasOutput(HEAT_HP_low, outputName)

## DIRECT HEAT, from HP, MID TEMP
resultName   = "$(top_dir)/IndustrialHeatDemand_MidTempHeatfromHP_HOURLY"
temporalName = string("_$(T_inv)","Inv","+","$(N_Periods)","RepDays")
scenarioName = string("_MDS","$(FormEnergy_allowed)","+","PHS","$(PHS_allowed)")
#
outputName = string(resultName, temporalName, scenarioName,".csv")
##
process_gasOutput(HEAT_HP_mid, outputName)

## DIRECT HEAT, from HP, HIGH TEMP
resultName   = "$(top_dir)/IndustrialHeatDemand_HighTempHeatfromHP_HOURLY"
temporalName = string("_$(T_inv)","Inv","+","$(N_Periods)","RepDays")
scenarioName = string("_MDS","$(FormEnergy_allowed)","+","PHS","$(PHS_allowed)")
#
outputName = string(resultName, temporalName, scenarioName,".csv")
##
process_gasOutput(HEAT_HP_high, outputName)


## DIRECT HEAT, from EB, LOW TEMP
resultName   = "$(top_dir)/IndustrialHeatDemand_LowTempHeatfromEB_HOURLY"
temporalName = string("_$(T_inv)","Inv","+","$(N_Periods)","RepDays")
scenarioName = string("_MDS","$(FormEnergy_allowed)","+","PHS","$(PHS_allowed)")
#
outputName = string(resultName, temporalName, scenarioName,".csv")
##
process_gasOutput(HEAT_EB_low, outputName)

## DIRECT HEAT, from EB, MID TEMP
resultName   = "$(top_dir)/IndustrialHeatDemand_MidTempHeatfromEB_HOURLY"
temporalName = string("_$(T_inv)","Inv","+","$(N_Periods)","RepDays")
scenarioName = string("_MDS","$(FormEnergy_allowed)","+","PHS","$(PHS_allowed)")
#
outputName = string(resultName, temporalName, scenarioName,".csv")
##
process_gasOutput(HEAT_EB_mid, outputName)

## DIRECT HEAT, from EB, HIGH TEMP
resultName   = "$(top_dir)/IndustrialHeatDemand_HighTempHeatfromEB_HOURLY"
temporalName = string("_$(T_inv)","Inv","+","$(N_Periods)","RepDays")
scenarioName = string("_MDS","$(FormEnergy_allowed)","+","PHS","$(PHS_allowed)")
#
outputName = string(resultName, temporalName, scenarioName,".csv")
##
process_gasOutput(HEAT_EB_high, outputName)




## DIRECT HEAT, from H2H
resultName   = "$(top_dir)/IndustrialHeatDemand_DirectHeatfromH2H_HOURLY"
temporalName = string("_$(T_inv)","Inv","+","$(N_Periods)","RepDays")
scenarioName = string("_MDS","$(FormEnergy_allowed)","+","PHS","$(PHS_allowed)")
#
outputName = string(resultName, temporalName, scenarioName,".csv")
##
process_gasOutput(HEAT_DirectHeat_H2H, outputName)


## HEAT, from GAS
resultName   = "$(top_dir)/IndustrialHeatDemand_GAS_HOURLY"
temporalName = string("_$(T_inv)","Inv","+","$(N_Periods)","RepDays")
scenarioName = string("_MDS","$(FormEnergy_allowed)","+","PHS","$(PHS_allowed)")
#
outputName = string(resultName, temporalName, scenarioName,".csv")
##
process_gasOutput(HEAT_byGas_single, outputName)



## HEAT, from GAS, but heat
resultName   = "$(top_dir)/IndustrialHeatDemand_GAS_onlyHEAT_HOURLY"
temporalName = string("_$(T_inv)","Inv","+","$(N_Periods)","RepDays")
scenarioName = string("_MDS","$(FormEnergy_allowed)","+","PHS","$(PHS_allowed)")
#
outputName = string(resultName, temporalName, scenarioName,".csv")
##
process_gasOutput(HEAT_byGas_ONLYheat, outputName)



## HEAT, from GAS, but heat, low temp
resultName   = "$(top_dir)/IndustrialHeatDemand_GAS_onlyHEAT_lowTemp_HOURLY"
temporalName = string("_$(T_inv)","Inv","+","$(N_Periods)","RepDays")
scenarioName = string("_MDS","$(FormEnergy_allowed)","+","PHS","$(PHS_allowed)")
#
outputName = string(resultName, temporalName, scenarioName,".csv")
##
process_gasOutput(HEAT_byGas_ONLYheat_lowTemp, outputName)

## HEAT, from GAS, but heat, mid temp
resultName   = "$(top_dir)/IndustrialHeatDemand_GAS_onlyHEAT_midTemp_HOURLY"
temporalName = string("_$(T_inv)","Inv","+","$(N_Periods)","RepDays")
scenarioName = string("_MDS","$(FormEnergy_allowed)","+","PHS","$(PHS_allowed)")
#
outputName = string(resultName, temporalName, scenarioName,".csv")
##
process_gasOutput(HEAT_byGas_ONLYheat_midTemp, outputName)

## HEAT, from GAS, but heat, high temp
resultName   = "$(top_dir)/IndustrialHeatDemand_GAS_onlyHEAT_highTemp_HOURLY"
temporalName = string("_$(T_inv)","Inv","+","$(N_Periods)","RepDays")
scenarioName = string("_MDS","$(FormEnergy_allowed)","+","PHS","$(PHS_allowed)")
#
outputName = string(resultName, temporalName, scenarioName,".csv")
##
process_gasOutput(HEAT_byGas_ONLYheat_highTemp, outputName)







## TOTAL HEAT; without CDR
resultName   = "$(top_dir)/BaselineDemand_total_HOURLY"
temporalName = string("_$(T_inv)","Inv","+","$(N_Periods)","RepDays")
scenarioName = string("_MDS","$(FormEnergy_allowed)","+","PHS","$(PHS_allowed)")
#
outputName = string(resultName, temporalName, scenarioName,".csv")
##
process_gasOutput(HEAT_total, outputName)


## HEAT due to CDR from Gas
resultName   = "$(top_dir)/CDR_HeatDemand_fromGas_HOURLY"
temporalName = string("_$(T_inv)","Inv","+","$(N_Periods)","RepDays")
scenarioName = string("_MDS","$(FormEnergy_allowed)","+","PHS","$(PHS_allowed)")
#
outputName = string(resultName, temporalName, scenarioName,".csv")
##
process_gasOutput(HEAT_metByGas_forCDR, outputName)

## HEAT due to CDR from Heat
resultName   = "$(top_dir)/CDR_HeatDemand_fromDirectHeat_HOURLY"
temporalName = string("_$(T_inv)","Inv","+","$(N_Periods)","RepDays")
scenarioName = string("_MDS","$(FormEnergy_allowed)","+","PHS","$(PHS_allowed)")
#
outputName = string(resultName, temporalName, scenarioName,".csv")
##
process_gasOutput(HEAT_metByDirectHeat_forCDR, outputName)


## HEAT due to CDR TOTAL
resultName   = "$(top_dir)/CDR_HeatDemand_total_HOURLY"
temporalName = string("_$(T_inv)","Inv","+","$(N_Periods)","RepDays")
scenarioName = string("_MDS","$(FormEnergy_allowed)","+","PHS","$(PHS_allowed)")
#
outputName = string(resultName, temporalName, scenarioName,".csv")
##
process_gasOutput(HEAT_CDR_total, outputName)






##########################################################################
####################### GENERATION BY PRIME MOVER ########################
##########################################################################
#
primveMoverTypes = unique(PrimeMover_GEN)
#
flow_output = JuMP.value.( generation )
flow_output2D = zeros(size(flow_output, 3), size(flow_output, 1) * size(flow_output, 2) * length(primveMoverTypes) )
#
global counter = 1
# Determine the column names for each slice in the third dimension
column_names = String[]  # Initialize as an empty string array
for i = 1:size(flow_output, 1)
    prefix = "InvPeriod_$(i)"
    for j = 1:size(flow_output, 2)
        suffix = "RepDay_$(j)"
        for k = 1:length(primveMoverTypes)
            # create name
            suffix2 = "$(primveMoverTypes[k])"
            push!(column_names, string(prefix, "+", suffix, "+", suffix2))
            # fill matrix
            bool_primeMover = PrimeMover_GEN .== primveMoverTypes[k]
            flow_output2D[:,counter] = JuMP.value.( sum(generation[i,j,:,g] for g in 1:length(bool_primeMover) if bool_primeMover[g]) )
            # update counter
            global counter = counter + 1
        end
    end
end

# Create a DataFrame with column names
df = DataFrame(flow_output2D, column_names)
#
resultName   = "$(top_dir)/ByPrimeMover_GENERATION_HOURLY"
temporalName = string("_$(T_inv)","Inv","+","$(N_Periods)","RepDays")
scenarioName = string("_MDS","$(FormEnergy_allowed)","+","PHS","$(PHS_allowed)")
outputName = string(resultName, temporalName, scenarioName,".csv")
# Save the DataFrame to a CSV file
CSV.write(outputName, df)









##########################################################################
###################### CARBON DIOXIDE REMOVAL TECH #######################
##########################################################################
##########################################################################
# 
### CDR units by node and type in final year **ONLY**
##
#### CDR Capacity in tCO2/y
preCapacity_CDR = (NumUnits_CDR .* UnitSize_CDR * 8760)
# define array based on inv periods
invCapacity_CDR = zeros(1, length(preCapacity_CDR))
# loop
for i=T_inv
    #
    netForInvP = UnitSize_CDR .* 8760 .* sum( JuMP.value.(unitsbuilt_CDR[invP,:]) - JuMP.value.(unitsretired_CDR[invP,:]) for invP = 1:i)
    invCapacity_CDR[1,:] = preCapacity_CDR[:] + netForInvP[:]
end

# find types 
nodeNumber = unique(carbonDioxideRemoval[:,1])
CDRType = unique(PrimeMover_CDR)
# find number of storage types and nodes
numNodes = length(nodeNumber)
CDRTypes = length(CDRType)
#
invCapacity_Total_CZ_CDR = zeros(1, CDRTypes, numNodes)
#
for i = T_inv
    # # generate local version of built/ret for inv period I
    net_InvPeriod = invCapacity_CDR[1,:]
    #
    for j = 1:CDRTypes
        # find indexing based on storage type
        idx_CDR = PrimeMover_CDR .== fill(CDRType[j], length(PrimeMover_CDR))
        for k = 1:numNodes
            # find indexing based on node
            idx_Node = carbonDioxideRemoval[:,1] .== fill(nodeNumber[k], length(carbonDioxideRemoval[:,1]))
            # intersection
            idx_intersection = idx_CDR .& idx_Node
            # find intersection and then add to 
            resultsTotal_intersection = net_InvPeriod[idx_intersection]
            #
            resultsTotal_array = zeros(length(idx_intersection))
            resultsTotal_array[findall(idx_intersection .== 1)] = resultsTotal_intersection
            #
            # add to matrix
            invCapacity_Total_CZ_CDR[1,j,k] = sum(resultsTotal_array)
        end
    end
end




function process_CDRUnitsOutput(gas_output, outputName, storageType)
    # Determine the column names for each slice in the third dimension
    column_names = String[]  # Initialize as an empty string array
    for i = 1:size(gas_output, 1)
        prefix = "InvPeriod_$(i)"
        for j = 1:size(gas_output, 2)
            suffix = storageType[j]
            push!(column_names, string(prefix, "+", suffix))
        end
    end

    # Reshape the 3D matrix into a 2D matrix
    gas_output2D = gas_output[1, :,:]'
    if size(gas_output, 1) > 1
        for i = 2:size(gas_output, 1)
            gas_output2D = hcat(gas_output2D, gas_output[i, :,:]')
        end
    end

    # Create a DataFrame with column names
    df = DataFrame(gas_output2D, column_names)

    # Rename the columns to the specified names
    rename!(df, Symbol.(column_names))

    # Save the DataFrame to a CSV file
    CSV.write(outputName, df)
end



### NetCapacity
# Specify the path to the CSV file where you want to save the data
resultName   = "$(top_dir)/NetCapacity2045_CDR_PerNode"
temporalName = string("_$(T_inv)","Inv","+","$(N_Periods)","RepDays")
scenarioName = string("_MDS","$(FormEnergy_allowed)","+","PHS","$(PHS_allowed)")
#
outputName = string(resultName, temporalName, scenarioName,".csv")
##
process_CDRUnitsOutput(invCapacity_Total_CZ_CDR, outputName, CDRType)





### Appliances
appliances_ELEC = JuMP.value.(sum( weights[:,T] .* sum(sum(1000*sum(8760/t_ops .* APPLIANCES_NodalLoc_ELEC[n,a] * unitsremaining_APPS[:,a] * ApplianceProfiles_ELEC[T,t,a] for a = 1:APPLIANCES) for n = 1:NODES_ELEC ) for t=1:t_ops) for T=1:T_ops ) )
appliances_GAS  = JuMP.value.(sum( weights[:,T] .* sum(sum(1000*sum(8760/t_ops .* APPLIANCES_NodalLoc_GAS[n,a]  * unitsremaining_APPS[:,a] * ApplianceProfiles_GAS[T,t,a]  for a = 1:APPLIANCES) for n = 1:NODES_GAS  ) for t=1:t_ops) for T=1:T_ops ) )
# Create DataFrame directly with ordered columns
df_appliances = DataFrame(
    GAS  = vec(appliances_GAS),
    ELEC = vec(appliances_ELEC)
)

resultName   = "$(top_dir)/ApplianceEnduseEnergyDemands"
temporalName = string("_$(T_inv)","Inv","+","$(N_Periods)","RepDays")
outputName = string(resultName, temporalName,".csv")
# Save the DataFrame to a CSV file
CSV.write(outputName, df_appliances)





##########################################################################
######################## INDUSTRIAL FACILITIES ###########################
##########################################################################
#
### industrial facilities by node and type
#
#### Storage Units
# define array based on inv periods
unitsRemIND_tot = zeros(T_inv, length(unitsremaining_INDUSTRIAL[1,:]))
# loop
for i = 1:T_inv
    #
    unitsRemIND_tot[i,:] = JuMP.value.(unitsremaining_INDUSTRIAL[i,:])
end


# find types 
nodeNumber = string.(IndustrialFacilities[:,1])
serviceType = "Node" .* nodeNumber .* "+" .* IndustrialServices .* "+" .* PrimeMover_INDUSTRIAL
# serviceType = unique(serviceType)
# find number of storage types and nodes
numIndustrialServices = length(serviceType)
#
unitsRemIND = zeros(T_inv, numIndustrialServices)
#
for i = 1:T_inv
    # generate local version of units for inv period I
    units_InvPeriod = unitsRemIND_tot[i,:]
    #
    # find indexing based on service type
    for j = 1:numIndustrialServices
        #
        idx_intersection = serviceType .== fill(serviceType[j], length(serviceType))
        # find intersection and then add to 
        results_intersection = units_InvPeriod[idx_intersection]
        #
        resultsBuilt_array = zeros(length(idx_intersection))
        resultsBuilt_array[findall(idx_intersection .== 1)] = results_intersection
        #
        # add to matrix
        unitsRemIND[i,j] = sum(resultsBuilt_array)
    end
end



function process_industrialUnitsOutput(output, outputName)
    # Determine the column names for each slice in the third dimension
    column_names = String[]  # Initialize as an empty string array

    column_names = serviceType
    output2D = unitsRemIND

    # Create a DataFrame with column names
    df = DataFrame(output2D, Symbol.(column_names))

    # Save the DataFrame to a CSV file
    CSV.write(outputName, df)
end


### Output
# Specify the path to the CSV file where you want to save the data
resultName   = "$(top_dir)/IndustrialUnits"
temporalName = string("_$(T_inv)","Inv","+","$(N_Periods)","RepDays")
#
outputName = string(resultName, temporalName,".csv")
##
process_industrialUnitsOutput(unitsRemIND, outputName)



### facility direct heat capacities
#
try
    # List to store individual DataFrames
    df_list = []  

    for I in collect(1:T_inv)

        ### P2H
        idx_HP = findall(PrimeMover_P2H .== "Heat Pump")
        idx_eB = findall(PrimeMover_P2H .== "Electric Boiler")
        #
        cap_HP = sum(JuMP.value.(P2H_capacity_facility[I,idx_HP,:]),dims=1)
        cap_eB = sum(JuMP.value.(P2H_capacity_facility[I,idx_eB,:]),dims=1)

        ### Heat Storage
        idx_RHB = findall(PrimeMover_STORAGE_HEAT .== "Rondo Heat Battery")
        idx_H2H = findall(PrimeMover_STORAGE_HEAT .== "Hydrogen-to-Heat")
        #
        cap_RHB = sum(JuMP.value.(HeatStorage_capacity_facility[I,idx_RHB,:]),dims=1)
        cap_H2H = sum(JuMP.value.(HeatStorage_capacity_facility[I,idx_H2H,:]),dims=1)

        # Create DataFrame directly with ordered columns
        df_heatCapacity_T = DataFrame(
            T_inv=I,                 # Add T_inv as a column
            Industrial=serviceType,   # String vector
            HeatPump=vec(cap_HP),     # Numeric vectors
            ElectricBoiler=vec(cap_eB),
            RHB=vec(cap_RHB),
            H2H=vec(cap_H2H)
        )

        push!(df_list, df_heatCapacity_T)  # Store DataFrame in list

    end

    # Concatenate all DataFrames vertically
    df_heatCapacity = vcat(df_list...)

    ### Output
    # Specify the path to the CSV file where you want to save the data
    resultName_heatCapacity   = "$(top_dir)/IndustrialUnits_DirectHeatCapacities"
    temporalName_heatCapacity = string("_$(T_inv)","Inv","+","$(N_Periods)","RepDays")
    #
    outputName_heatCapacity = string(resultName_heatCapacity, temporalName_heatCapacity,".csv")
    # Save the DataFrame to a CSV file
    CSV.write(outputName_heatCapacity, df_heatCapacity)
catch
    println("Did not save.")
end





### facility direct heat energy
#
try
    # List to store individual DataFrames
    df_list = []  

    for I in collect(1:T_inv)
        ### P2H
        idx_HP = findall(PrimeMover_P2H .== "Heat Pump")
        idx_eB = findall(PrimeMover_P2H .== "Electric Boiler")
        #
        heatOutput_HP = sum(JuMP.value.( sum(sum(weights[I,T]*8760/t_ops * P2H_dispatch_facility[I,T,t,idx_HP,:] .* eta_P2H[idx_HP] .* TempCompat_P2H[idx_HP,:] for t=1:t_ops) for T=1:T_ops ) ), dims=1)
        heatOutput_eB = sum(JuMP.value.( sum(sum(weights[I,T]*8760/t_ops * P2H_dispatch_facility[I,T,t,idx_eB,:] .* eta_P2H[idx_eB] .* TempCompat_P2H[idx_eB,:] for t=1:t_ops) for T=1:T_ops ) ), dims=1)

        ### Heat Storage
        idx_RHB = findall(PrimeMover_STORAGE_HEAT .== "Rondo Heat Battery")
        idx_H2H = findall(PrimeMover_STORAGE_HEAT .== "Hydrogen-to-Heat")
        #
        heatOutput_RHB = sum(JuMP.value.( sum(sum(weights[I,T]*8760/t_ops * (HeatStorage_discharge_facility[I,T,t,idx_RHB,:] .* TempCompat_HeatStorage[idx_RHB,:] + HeatStorage_discharge_facility_coGen2Heat[I,T,t,idx_RHB,:] .* TempCompat_outofST[idx_RHB,:]) for t=1:t_ops) for T=1:T_ops ) ), dims=1 )
        heatOutput_H2H = sum(JuMP.value.( sum(sum(weights[I,T]*8760/t_ops * (HeatStorage_discharge_facility[I,T,t,idx_H2H,:] .* TempCompat_HeatStorage[idx_H2H,:] + HeatStorage_discharge_facility_coGen2Heat[I,T,t,idx_H2H,:] .* TempCompat_outofST[idx_H2H,:]) for t=1:t_ops) for T=1:T_ops ) ), dims=1 )

        ### Gas
        heatOutput_Gas      = JuMP.value.( sum(sum(weights[I,T]*8760/t_ops .* unitsremaining_INDUSTRIAL[I,:] .* IndustrialProfiles_GAS[T,t,:] .* IndustrialPeakDemand[:] .*decline_heatDemand[:,I] for t=1:t_ops) for T=1:T_ops ) )
        heatOutput_Gas_heat = JuMP.value.( sum(sum(weights[I,T]*8760/t_ops .* unitsremaining_INDUSTRIAL[I,:]                                  .* IndustrialPeakDemand[:] .*decline_heatDemand[:,I] for t=1:t_ops) for T=1:T_ops ) )

        # Create DataFrame directly with ordered columns
        df_heatCapacityOutput_T = DataFrame(
            T_inv=I,                 # Add T_inv as a column
            Industrial=serviceType,          # String vector
            HeatPump=vec(heatOutput_HP),     # Numeric vectors
            ElectricBoiler=vec(heatOutput_eB),
            RHB=vec(heatOutput_RHB),
            H2H=vec(heatOutput_H2H),
            Gas=vec(heatOutput_Gas),
            GasAsHeat=vec(heatOutput_Gas_heat)
        )

        push!(df_list, df_heatCapacityOutput_T)  # Store DataFrame in list

    end

    # Concatenate all DataFrames vertically
    df_heatEnergyOutput = vcat(df_list...)

    ### Output
    # Specify the path to the CSV file where you want to save the data
    resultName_heatEnergyOutput   = "$(top_dir)/IndustrialUnits_DirectHeatEnergyOutput"
    temporalName_heatEnergyOutput = string("_$(T_inv)","Inv","+","$(N_Periods)","RepDays")
    #
    outputName_heatEnergyOutput = string(resultName_heatEnergyOutput, temporalName_heatEnergyOutput,".csv")
    # Save the DataFrame to a CSV file
    CSV.write(outputName_heatEnergyOutput, df_heatEnergyOutput)
catch
    println("Did not save.")
end


###########################
### transmission expansion
# Build the DataFrame
df = DataFrame(
    Edge = collect(1:EDGES_ELEC),
    Existing_Capacity = [ExistingUnits_ElecTrans[e] * MAXFLOW_ELEC[e] for e in 1:EDGES_ELEC]
)

# Add a column for each I
for i in 1:T_inv
    df[!, Symbol("I_$i")] = [JuMP.value.(addflow_TRANS_ELEC[i, e]) for e in 1:EDGES_ELEC]
end

# Export
CSV.write("$(top_dir)/transmissionExpansion.csv", df)