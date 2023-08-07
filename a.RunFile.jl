#RUN FILE

# Calls the Packages used for the optimization problem
using JuMP
using Printf
using CPLEX
using MathOptInterface
using JLD
using TimerOutputs
using DataFrames
using XLSX
using Parameters
using Dates
using CSV

# Calls the other Julia files
include("Structures.jl")
include("SetInputParameters.jl")
include("DynamicProgramming.jl")
#include("Saving in xlsx.jl")

date = string(today())

# PREPARE INPUT DATA
to = TimerOutput()

@timeit to "Set input data" begin

  #Set run case - indirizzi delle cartelle di input ed output
  case = set_runCase()
  @unpack (DataPath,InputPath,ResultPath,CaseName) = case;

  # Set run mode (how and what to run) and Input parameters
  runMode = read_runMode_file()
  InputParameters = set_parameters(runMode, case)
  @unpack (NStages, NHoursStage, Big)= InputParameters;

  # Read power prices from a file [€/MWh]
  Pp1 = read_csv("prices_2020_8760.csv",case.DataPath)                                # valori all'ora
  Pp2 = read_csv("prices_2021_8760.csv",case.DataPath)
  Pp3 = read_csv("prices_2022_8760.csv",case.DataPath)
  Battery_prices = read_csv("Battery_decreasing_prices.csv",case.DataPath)                             #  cost for battery replacement for each half hour
  Power_prices = vcat(Pp1',Pp2',Pp3')
  cost_Battery = zeros(NStages)
  a = Int(NStages/4380)
  for i = 1:a
    cost_Battery[(i-1)*4380+1:4380*i] .= Battery_prices[i]
  end

  # Upload battery's characteristics
  Battery = set_battery_system(runMode, case)
  @unpack (min_SOC, max_SOC, Eff_charge, min_P,max_P, max_SOH, min_SOH, DoD, NCycles) = Battery;  #, DoD, NCycles

  # Where and how to save the results
  FinalResPath= set_run_name(case, ResultPath, InputParameters)

end

#save input data
@timeit to "Save input" begin
    save(joinpath(FinalResPath,"CaseDetails.jld"), "case" ,case)
    save(joinpath(FinalResPath,"SolverParameters.jld"), "SolverParameters" ,SolverParameters)
    save(joinpath(FinalResPath,"InputParameters.jld"), "InputParameters" ,InputParameters)
    save(joinpath(FinalResPath,"BatteryCharacteristics.jld"), "BatteryCharacteristics" ,Battery)
    save(joinpath(FinalResPath,"PowerPrices.jld"),"PowerPrices",Power_prices)
end

# DYNAMIC PROGRAMMING
@timeit to "Solving Dynamic Pogramming" begin
    ResultsDP = DP(InputParameters, Battery, Power_prices)   #configurations
    save(joinpath(FinalResPath, "dp_Results.jld"), "dp_Results", ResultsDP) 
end


# SAVE OTIMAL-PATH DATA IN EXCEL FILES
if runMode.excel_savings
  cartella = "C:\\GitSource-Batteries\\Batteries-greedy-aproach\\Results"
  cd(cartella)
  data_saving(InputParameters,ResultsDP,Power_prices)
  println("Results saved")
else
  println("Solved without saving results in xlsx format.")
end

# SAVE PLOTS IN THE CORRESPONDING FOLDER
if runMode.plot_savings
  cartella = "C:\\GitSource-Batteries\\Batteries-greedy-aproach\\Plots"
  cd(cartella)
  plotPath(InputParameters,ResultsDP,state_variables,priceYear)
end

print(to)




