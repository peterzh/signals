## Description:

This 'tutorials' folder contains files that are useful for learning how to use *Signals*. 

## Contents:

- 'Getting_Started_with_Signals': Those new to *Signals* should start here. This script contains information on how a *Signals* network works, how signals interact with each other in a *Signals* network, and how to create signals in a *Signals* network using common MATLAB and *Signals* specific methods.

- 'Getting_Started_with_Signals_Answers': A script containing answers to questions posed in 'Getting_Started_with_Signals'

- 'signalsExperimentTutorial': This file is a tutorial for creating a *Signals* Experiment Definition (aka an 'Exp Def'). Exp Defs are the files that are executed when running a *Signals* Experiment within Rigbox. This tutorial walks through setting up and running different versions of a *Signals* Experiment based on the [Burgess Steering Wheel Task](https://www.biorxiv.org/content/biorxiv/early/2017/07/25/051912.full.pdf).

- 'signalsExperimentTutorialAnswers': A script containing answers to questions posed in 'signalsExperimentTutorial'

- 'signalsExamplesScript': This script contains additional examples of *Signals-y* things which may not have been covered in the above files, and things which an experimenter can incorporate into their Experiment Definitions.

## Instructions on Running Exp Defs from 'signalsExperimentTutorial'

0) Open 'signalsExperimentTutorial' in MATLAB and make sure you read the notes there carefully before continuing.

1) On a rig:

- Run 'mc' in MATLAB on the 'mc' computer
- When the 'MC' gui appears, from the dropdown menus in the upper left, select:

a) Subject: 'default'
b) Type: '<custom...>' (then select the file 'signalsExperimentTutorial' when the file explorer opens)
c) Rig: Choose the rig on which you are currently running 'expServer'
d) Saved sets: <defaults> (then click the 'Load' push button)

- Click the 'Start' push button to start the experiment. 
- (If you are on the final section of the tutorial, parameters will appear as editable fields that you can click on to edit)

2) On a personal PC:
 