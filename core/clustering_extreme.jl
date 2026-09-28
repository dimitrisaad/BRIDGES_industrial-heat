### find peak elec
DemandClustering = copy(D_Elec)
for n = 1:NODES_ELEC
    DemandClustering[:,n] = DemandClustering[:,n] +  sum(APPLIANCES_NodalLoc_ELEC[n,a]*ApplianceProfilesELEC[:,a]*InitialAppliancePopulation[a] for a = 1:APPLIANCES)
end
DemandClustering = sum(DemandClustering, dims = 2)
LOAD_ELEC = reshape(DemandClustering, (HOURS_PER_PERIOD, Periods_Per_Year))
vals = zeros(365)
for i = 1:365
    vals[i],day = findmax(LOAD_ELEC[:,i])
end
# p1 = plot(vals)
x,max_day_elec = findmax(vals[:])
# vline!(p1, [max_day_elec],line=(:dash, 2),color=(:black))
# vline!(p1, medoids,color=(:orange))


### find peak gas
DemandClustering = copy(D_Gas)
for n = 1:NODES_GAS
    DemandClustering[:,n] = DemandClustering[:,n] +  sum(APPLIANCES_NodalLoc_GAS[n,a]*ApplianceProfilesGAS[:,a]*InitialAppliancePopulation[a] for a = 1:APPLIANCES)
end
DemandClustering = sum(DemandClustering, dims = 2)
LOAD_GAS = reshape(DemandClustering, (HOURS_PER_PERIOD, Periods_Per_Year))
valsGAS = zeros(365)
for i = 1:365
    valsGAS[i],day = findmax(LOAD_GAS[:,i])
end
# p2 = plot(valsGAS)
x,max_day_gas = findmax(valsGAS[:])
# vline!(p2, [max_day_gas],line=(:dash, 2),color=(:black))
# vline!(p2, medoids,color=(:orange))
# plot(p1, p2, layout = (2, 1),legend=false)


### find min wind
indices_ONW = findall(x -> x == "Wind", Generators[!, "Prime Mover"])
HourlyVRE_ONW = HourlyVRE[:,indices_ONW]
HourlyVREClustering_ONW = reshape(HourlyVRE_ONW, (HOURS_PER_PERIOD, Periods_Per_Year,length(HourlyVRE_ONW[1,:])))
# sum
HourlyVREClustering_ONW = sum(HourlyVREClustering_ONW, dims = 3)
valsONW = zeros(365)
for i = 1:365
    valsONW[i] = sum(HourlyVREClustering_ONW[:,i,1])
end

x,min_day_ONW = findmin(valsONW[:])



### find min solar
indices_SolarPV = findall(x -> x == "Solar PV", Generators[!, "Prime Mover"])
HourlyVRE_solar = HourlyVRE[:,indices_SolarPV]
HourlyVREClustering_solar = reshape(HourlyVRE_solar, (HOURS_PER_PERIOD, Periods_Per_Year,length(HourlyVRE_solar[1,:])))
# sum
HourlyVREClustering_solar = sum(HourlyVREClustering_solar, dims = 3)
valsSOLAR = zeros(365)
for i = 1:365
    valsSOLAR[i] = sum(HourlyVREClustering_solar[:,i,1])
end

x,min_day_solar = findmin(valsSOLAR[:])





println("Peak electric demand day = ", max_day_elec)
println("Peak gas demand day = ", max_day_gas)
println("Minimum solar output day = ", min_day_solar)
println("Minimum wind output day = ", min_day_ONW)


println("Check weights with extreme days:")
unnorm_weights = weights.*365
valweights,day_ind = findmax(unnorm_weights[1,:])
unnorm_weights[:,day_ind] = ones(T_inv)*(valweights-4)
weights = [unnorm_weights ones(T_inv) ones(T_inv) ones(T_inv) ones(T_inv)]./365
println(weights[1,:])
println("Check medoids with extreme days:")
# order of added days: if 10 rep days -->
# day 11: day with highest gas demand
# day 12: day with highest elec demand
# day 13: day with lowest solar output
# day 14: day with lowest wind output
medoids = [medoids ones(T_inv)*max_day_gas ones(T_inv)*max_day_elec ones(T_inv)*min_day_solar ones(T_inv)*min_day_ONW]
println(medoids[1,:])

N_Periods = N_Periods + 4
T_ops = N_Periods
println("Number of representative days, with extreme days: ", T_ops)

# update RepDays
mm = findall(x->x==day_ind, RepDays[1,:])
# find days to replace; we replace the days of the highest rep day type
ind_summer = mm[Int64(round(length(mm)/2))]      # summer
ind_summer2 = mm[Int64(round(length(mm)/2 - 1))]      # summer
ind_winter = mm[Int64(round(length(mm)))]        # winter
ind_winter2 = mm[Int64(round(length(mm)-1))]        # winter
#

# assign summer day to day with highest electricity
RepDays[:,ind_summer] = ones(T_inv)*(N_Periods-2)
# assign winter day to day with highest gas
RepDays[:,ind_winter] = ones(T_inv)*(N_Periods-3)
# assign winter day to day with lowest solar
RepDays[:,ind_winter2] = ones(T_inv)*(N_Periods-1)
# assign summer day to day with lowest wind
RepDays[:,ind_summer2] = ones(T_inv)*(N_Periods)
