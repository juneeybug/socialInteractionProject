# socialInteractionProject
## hierarchy

batchprocess.m lists all the data sessions and can call all the other functions.

* convertPlx2mat.m - converts Plexon ".plx" files to ".mat". To use this function fork the "plx2mat" repo. 

* preProcess.m
  - bmi_parse.m - aligns the time stamps of BMI with those from Plexon. 
  - parseDatafile - parses the session into a "trial" structure.
    
* getTrialTypes.m - segregate the data into trial types based on target position and avatar target position. 
  
* integrateAndBinAllNeuralData.m - bins all neural data (from multiple Plexons) into required bin size 

* getRT.m - mark the beginning and end of joystick movement. 
   Note: resample_discont.cpp needs to be compiled to build a mex file that can be called within resampleparam.m
  
  
  

