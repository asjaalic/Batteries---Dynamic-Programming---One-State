# STAGE MAXIMIZATION PROBLEM FORMULATION

function DP(InputParameters::InputParam, Battery::BatteryParam, Power_prices)       #, state_variables::states When we have 2 hydropower plants- 2 turbines

    @unpack (NStages, Big, NHoursStage, conv) = InputParameters;  
    @unpack (min_SOC, max_SOC, Eff_charge, Eff_discharge, min_P, max_P, max_SOH, min_SOH,DoD, NCycles) = Battery ;         

    num_states = length(DoD)
    soc_seg = zeros(num_states)

    for i = 1:num_states
      soc_seg[i] = (1-DoD[i]/100)*max_SOC
    end

    final_values = zeros(NStages+1,num_states)
    fromState = zeros(NStages, num_states)
    deg_stage = zeros(NStages, num_states)

    final_values[end,:] = soc_seg[:]*Power_prices[NStages+1]*NHoursStage

    for t = NStages:-1:1
      for iState = 1:num_states

        val = zeros(num_states)

        for jState=1:num_states

          penalty = 0
          charge = 0
          discharge = 0 
          degradation = zeros(num_states)

          if soc_seg[jState] > soc_seg[iState] #CHARGING PHASE

            charge = (soc_seg[jState]-soc_seg[iState])/(Eff_charge*NHoursStage)
            degradation[jState] = abs(1/NCycles[jState]-1/NCycles[iState])*max_SOC

            if charge > max_P
              penalty = Big
            end

          elseif soc_seg[jState] < soc_seg[iState]#DISCHARGING PHASE

            discharge = (soc_seg[jState]-soc_seg[iState])/NHoursStage*Eff_discharge
            degradation[jState] = abs(1/NCycles[jState]-1/NCycles[iState])*max_SOC

          end

          val[jState] = Power_prices[t]*NHoursStage*(discharge-charge) - cost_Battery[t]*degradation[jState] - penalty + final_values[t+1,jState]
        
        end

        final_values[t,iState] = findmax(val[jState])[1]
        fromState[t,iState] = findmax(val[jState])[2]
        a = fromState[t,iState]
        deg_stage[t,iState] = degradation[a]

      end
    end

    #RACCOLGO RISULTATI PERCORSO MIGLIORE

    startingFrom = findmax(final_values[1,:])[2]
    netOverallRevenues = 0
    overallCost = 0

    for t=1:NStages
      comingFrom = Int(fromState[t,startingFrom])

      optValue = findmax(final_values[t,startingFrom])[1]
      deg = deg_stage[t,staringFrom]


      push!(optimalPath, saveOptimalValues(t, optValue, deg))

      startingFrom = comingFrom
    end
    
    return ResultsDP(
        soc,
        charge,
        discharge,
        deg,
        soh_final,
        soh_new,
        single_revenues,
        single_costs,
        net_revenues,
        total_cost,
      )
end

