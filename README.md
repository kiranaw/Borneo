# Borneo: arBOReal aNimal movEment mOdel

[![DOI](https://sandbox.zenodo.org/badge/DOI/10.5072/zenodo.1074440.svg)](https://sandbox.zenodo.org/record/1074440#.Yqx4eNJBxhH)

## About 

This is the repository containing the code presented in the paper submitted to [Frontiers in Ecology and Evolution](https://www.frontiersin.org/journals/ecology-and-evolution/sections/models-in-ecology-and-evolution#research-topics) 

Title: Assessing the impact of disturbances of the forest structure on the arboreal movement of orangutans - an agent-based modelling approach 

Authors: Kirana Widyastuti, Romain Reuillon, Paul Chapron, Wildan Abdussalam, Darmae Nasir, Mark E Harrison, Helen Morrogh-bernard, Muhammad Ali Imron, Uta Berger


  * [Organisation of the repository](https://github.com/kiranaw/Borneo#organisation-of-the-repository)
  * [Model](https://github.com/kiranaw/Borneo#model)
    + [Software requirements](https://github.com/kiranaw/Borneo#software-requirements)
    + [Running the model once](https://github.com/kiranaw/Borneo#running-the-model-once)
  * [Experiments](https://github.com/kiranaw/Borneo#experiments)
    + [Reproducing the experiments](https://github.com/kiranaw/Borneo#reproducing-the-experiments)
    + [Sensitivity analysis](https://github.com/kiranaw/Borneo#sensitivity-analysis)
    + [Calibration](https://github.com/kiranaw/Borneo#calibration)
    + [Scenario](https://github.com/kiranaw/Borneo#scenario)
      - [Calibrated models](https://github.com/kiranaw/Borneo#calibrated-models)
      - [Proportion of burnt forest and Month of observation](https://github.com/kiranaw/Borneo#proportion-of-burnt-forest-and-month-of-observation)
      - [Results presented in the paper](https://github.com/kiranaw/Borneo#results-presented-in-the-paper)
  * [Results](https://github.com/kiranaw/Borneo#results)
    + [Calibration](https://github.com/kiranaw/Borneo#calibration-1)
    + [Scenario](https://github.com/kiranaw/Borneo#scenario-1)
    + [Sensitivity](https://github.com/kiranaw/Borneo#sensitivity)
    + [Figure](https://github.com/kiranaw/Borneo#figure)


## Organisation of the repository 

 -  directory model contains the Netlogo model code, extensions and trees data
 -  directory experiments contains the scripts of the experiments presented in the paper  (section 3.2.)
 -  directory results contains (a sample of) simulation results obtained for these experiments



## Model 

### Software requirements

The model is built in [Netlogo](https://ccl.northwestern.edu/netlogo/download.shtml), version 6.2.2 and requires the following extensions: 
- `csv` is used to load trees data (e.g. `sebangau.csv` file) and the various scenario of burnt forest 
- `nw` is used for the pathfinding utility function of the orangutan agent in the tree network 
- `rnd` is used for a weighted sampling utility function

For the model to work properly, the extensions directories have to remain in the same directory as the `BORNEO-ABM.nlogo` model file.

### Running the model once

1. Launch Netlogo version XXX
2. open the `BORNEO-ABM.nlogo` model via the `File>Open` menu of Netlogo
3. click the Setup Button to build the spatial tree network configuration 
4. click the Go Button to launch a simulation with default values 
5. Don't forget to set the plots upgrade switch to 'on' in order to observe the monitors (top right corner of the Netlogo GUI)

Optionaly, You can select two environmental parameters that affect the trees network: 

- `burnt-proportion` that allows to simulate forest fires up to a given proportion of the forest (slider at bottom left corner of the netlogo GUI)
- `month` that affect the location of fruiting trees in the forest (chooser  near the bottom left corner of Netlogo world)

These two optional parameters are fully explored in the [Scenario section](https://github.com/kiranaw/Borneo#scenario) of the README.



## Experiments
Experiments are conducted via [OpenMOLE](next.openmole.org), a platforme tailored to explore simulation models.

Design of Experiments are described in `*.oms` of the [experiment directory](https://github.com/kiranaw/Borneo/tree/master/experiments). The experiments are described in this README in plain text and also have been commented in the source to give the reader insights about the blocks of code meaning.


### Reproducing the experiments

For reproducing the experiments presented in the paper, see the instructions to install and run Openmole [here](https://next.openmole.org/Download.html).
Note that some of the results presented in the paper, especially the multi-criteria calibration, have been obtained in more than 24 hours on a slurm environment utilising around 500 CPUs. Scenarios described in https://github.com/kiranaw/Borneo/tree/master/experiments/scenario are more affordable as they only imply 100 replications for each parameter combination ;-) 


### Sensitivity analysis 

This experiment and the Morris method are described in the paper. 
Below is the OpenMOLE script:   https://github.com/kiranaw/Borneo/blob/master/experiments/sensitivity/morris.oms .
The sensitivity analysis has been conducted for an adult female.



### Calibration 

The calibration needs fitness functions as objectives: in our case they are quadratic distance between data and simulated distributions deciles.

These Fitness functions are defined form line 6  to  13  in the https://github.com/kiranaw/Borneo/blob/master/experiments/calibration/calibrationAF.oms script, and then passed to the `NSGA2evlution` method as objectives.


The parameter to be calibrated are listed as the `genome` sequence attribute of the NSGA2evolution method , from line 41 to 50.
This method is furtherly developped [here](https://next.openmole.org/Genetic+Algorithms.html) and [there](https://next.openmole.org/Calibration.html) in the OpenMOLE Documentation 


### Scenario 


Scenarios are available for four kinds or orangutan : 
- Adult Female (AF), 
- Flanged Male (FM), 
- Hengky, 
- Indah.

In the following section, we describe the operations to run a scenario for an Adult Female AF. In order to observe the scenario for the other orangoutans,  simply replace `AF` by `FM` , `hengky` or `indah` in file names.


 
#### Calibrated models  


A calibrated model refers to the model itself and a list of input parameter values that have been calibrated toward some objectives. 
For the scenarios we used calibrated models, so some parameter values are now fixed to the solutions of the calibration experiments directly in the OpenMOLE scripts. 


- Calibrated parameter values can be found in the `model_AF_scenario.oms` file, line 61 to 71.
- the other calibrated parameterizations (i.e. solutions) of the Pareto Front for `AF` orangutan can be found in the CSV file of the [calibration directory](   https://github.com/kiranaw/Borneo/blob/master/results/calibration/) namely `result_calibration_AF.csv`;  or in the table S1 of the suplementary materials document of the paper. `FM` calibrated parameter values are in table S2, `Hengky`'s in table S3 , and `Indah`'s in table S4


#### Proportion of burnt forest and Month of observation


The proportion of burnt forest can be manually selected in the Netlogo GUI (bottom-left slider called `burnt-proportion`)


in the file https://github.com/kiranaw/Borneo/blob/master/experiments/scenario/scenario_AF_allmonths.oms , simulation scenarios have beeen conducted for every month, and a burnt porportion varying from 0 to 90% as illustrated below:

![resultfile](https://github.com/kiranaw/Borneo/blob/master/results/figures/scenario_illustration.png?raw=true)
 


#### Results presented in the paper 


The results presented in the paper is a selection of these scenarios results, showing only February results. 


## Results

This directory contains the results obtained for each experiment.
As file names may have changed, we give the content of each file 

### Calibration 

`result_calibration_AF.csv` contains the Pareto Front solutions from the calibration against Adult Female orangutans data, 

`result_calibration_FM.csv` contains the Pareto Front solutions from the calibration against Flanged Male  orangutans data , 

`result_calibration_hengky.csv` contains the Pareto Front solutions from the calibration against the data of Hengky,

`result_calibration_indah.csv`contains the Pareto Front solutions from the calibration against the data of Indah

### Figures 

Contains sample figures used in the paper

### Scenario 

`scenario_burn_AF.csv` contains the simulation results of 100 replication of an Adult Female orangutan, with burnt proportion varying from 0 to 90%, for each month of the year 


`scenario_burn_FM.csv` contains the same results for a Flanged Male. 


### Sensitivity 


Morris method produces three distinct files, one for each indice of sensitivity : 

- `mu.csv` contains the $\mu$ value for each parameter for which the sensitivity is computed (agregated elementary values)
- `mustar.csv` contains the $\mu*$ value for each parameter for which the sensitivity is computed (agregated absolute elementary values)
- `sigma.csv` contains the $\sigma$ value for each parameter for which the sensitivity is computed (non linear effect of interaction between parameters )





