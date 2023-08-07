# EXCEL SAVINGS
#using DataFrames
#using XLSX

function data_saving(InputParameters::InputParam,ResultsOpt::Results)

    @unpack (NStages, Big, NHoursStage, conv) = InputParameters;
  
    @unpack (min_SOC, max_SOC, min_P, max_P, Eff_charge, Eff_discharge, max_SOH, min_SOH ) = Battery ; 

    hour=string(now())
    a=replace(hour,':'=> '-')

    nameF= "$NStages stages - versione prof"
    nameFile="Final results decreasing prices $nameF" 

    folder = "$nameF"
    mkdir(folder)
    cd(folder)
    main=pwd()

    general = DataFrame()
    battery_costs= DataFrame()
    
    general[!,"SOH_initial"] = soh_initial[:]
    general[!,"SOH_final"] = soh_final[:]
    general[!,"Degradation"] = deg_stage[:]
    general[!,"Net_Revenues"] = revenues_per_stage[:]
    general[!,"Gain charge/discharge"] = gain_stage[:]
    general[!,"Cost revamping"] = cost_rev[:]

    battery_costs[!,"Costs €/MWh"] = Battery_price[:]

    XLSX.writetable("$nameFile.xlsx", overwrite=true,                                       #$nameFile
    results_stages = (collect(DataFrames.eachcol(general)),DataFrames.names(general)),
    costs = (collect(DataFrames.eachcol(battery_costs)),DataFrames.names(battery_costs)),
    )

    for iStage=1:NStages
        steps = DataFrame()

        steps[!,"Step"] = ((iStage-1)*NHoursStage+1):(NHoursStage*iStage)
        steps[!, "Energy_prices €/MWh"] = Power_prices[((iStage-1)*NHoursStage+1):(NHoursStage*iStage)]
        steps[!,"SOC MWh"] = soc[((iStage-1)*NHoursStage+1):(NHoursStage*iStage)]
        steps[!, "Charge MW"] = charge[((iStage-1)*NHoursStage+1):(NHoursStage*iStage)]
        steps[!, "Discharge MW"] = discharge[((iStage-1)*NHoursStage+1):(NHoursStage*iStage)]
        steps[!, "SOC_quad MW"] = soc_quad[((iStage-1)*NHoursStage+1):(NHoursStage*iStage)]
        steps[!, "Deg MWh"] = deg[((iStage-1)*NHoursStage+1):(NHoursStage*iStage)]
        steps[!, "X"] = x[((iStage-1)*NHoursStage+1):(NHoursStage*iStage)]
        steps[!, "Y"] = y[((iStage-1)*NHoursStage+1):(NHoursStage*iStage)]
        steps[!, "Z"] = z[((iStage-1)*NHoursStage+1):(NHoursStage*iStage)]
        steps[!, "XX"] = w_xx[((iStage-1)*NHoursStage+1):(NHoursStage*iStage)]
        steps[!, "YY"] = w_yy[((iStage-1)*NHoursStage+1):(NHoursStage*iStage)]
        steps[!, "ZZ"] = w_zz[((iStage-1)*NHoursStage+1):(NHoursStage*iStage)]
        steps[!, "XY"] = w_xy[((iStage-1)*NHoursStage+1):(NHoursStage*iStage)]
        steps[!, "XZ"] = w_xz[((iStage-1)*NHoursStage+1):(NHoursStage*iStage)]
        steps[!, "ZY"] = w_zy[((iStage-1)*NHoursStage+1):(NHoursStage*iStage)]

        XLSX.writetable("$iStage stage $nameF.xlsx", overwrite=true,                                       #$nameFile
        results_steps = (collect(DataFrames.eachcol(steps)),DataFrames.names(steps)),
        )

    end

    cd(main)             # ritorno nella cartella di salvataggio dati


    return println("Saved data in xlsx")
end






