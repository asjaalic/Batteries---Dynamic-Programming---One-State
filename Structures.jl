# STRUCTURES USED IN THE PROBLEM

# Input data
#-----------------------------------------------

# Input parameters 
@with_kw struct InputParam{F<:Float64,I<:Int}
    NStages::I                                    # Number of stages of N months in the problem FORMULATION-- calcolato come NYears/NMonths*12
    NHoursStage::F                                 # Number of hours in each time step                                     # Number of steps in the NYeras --> NYears*8760/NHoursStep
    Big::F                                        # A big number
    conv::F                                       # A small number for degradation convergence
end

# Battery's characteristics
@with_kw struct BatteryParam{F<:Float64}
    min_SOC::F                                     # Battery's minimum energy storage capacity
    max_SOC::F                                     # Batter's maximum energy storage capacity
    Eff_charge::F                                  # Battery's efficiency for charging operation
    Eff_discharge::F                               # Battery's efficiency for discharging operation
    min_P::F
    max_P::F
    max_SOH::F                                     # Maximum SOH that can be achieved because of volume issues
    min_SOH::F                                     # Minimum SOH to be respected by contract
    DoD::Any                                       # Different DoDs                                        
    NCycles::Any                                   # Equivalent cycles given DoD
end
  
# solver parameters
@with_kw struct SolverParam{F<:Float64,I<:Int}
    MIPGap::F 
    MIPFocus::I
    Method::F
    Cuts::F
    Heuristics::F
end

  
# Indirizzi cartelle
@with_kw struct caseData{S<:String}
    DataPath::S
    InputPath::S
    ResultPath::S
    CaseName::S
end

# runMode Parameters
@with_kw mutable struct runModeParam{B<:Bool}

    # Solver settings
    solveMIP::B     #If using SOS2

    batterySystemFromFile::B 

    #runMode self defined reading of input 
    setInputParameters::B             #from .in file
 
    excel_savings::B 

end

# Dynamic Programmings
struct ResultsDP
    soc::Any
    charge::Any 
    discharge::Any
    deg::Any
    soh_final::Any
    soh_new::Any
    single_revenues::Any
    single_costs::Any
    net_revenues::Any
    total_cost::Any
end

