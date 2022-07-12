# MIDAS_Bangladesh

This is the complete application of MIDAS used to simulate internal migration in Bangladesh under expected flooding up to 2100 under RCP2.6, 4.5 and 8.5.

To run the application on your machine, copy the 'MIDAS Bangladesh Application' folder.  Files and subdirectories are as follows:

runMIDAS.m:  Runs one simulation of MIDAS Bangladesh

runMIDAS_RCP.m:  Runs the full experiment of all simulations specified in the file, drawing on the parameter sets stored in 'bestCalibrations.mat'

Data:  All application input datasets are stored here

Core_MIDAS_Code: These scripts are integral to most or all MIDAS applications and are unlikely to be modified for specific applications

Application_Specific_MIDAS_Code: These scripts are typically modified or rewritten for each MIDAS application

Override_Core_MIDAS_Code: Scripts in this directory will override versions with the same name stored in the Core_MIDAS_Code directory; this is set up to allow testing of alternative structures without committing them to core code

This release also includes analysis scripts used in developing the calibration, parsing MIDAS outputs, and developing figures, included in the 'Data Analysis Scripts' directory
