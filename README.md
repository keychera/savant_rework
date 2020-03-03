# Reworking Savant Artifact

This is the repository for the Final Year Project of Kevin Erdiza Yogatama. It features an implementation of Savant (paper: [pdf][savantpaper]) with the name "Resavant".

## Requirements

[Resavant essentials][driveessentials]

## Installation

1. Clone Resavant.

    `git clone https://github.com/keychera/savant_rework`

    - We'll call the parent directory PARENT_DIR

2. Prepare modified Defects4J.
    - Resavant use a modified version of Defects4J, which utilize tools named OpenClover.
    - get OpenClover 4.4.1 provided above.
    - clone the modified Defects4J from `https://github.com/keychera/defects4J`

        `git clone https://github.com/keychera/defects4J`
    
    - before installing Defects4J, put OpenClover 4.4.1 folder in a new folder named `extra` in Defects4J folder. It would look like this:

        `PARENT_DIR/defects4J/extra/clover-ant-4.4.1`
        
        (make sure the folder name is the same)
    
    - Install Defects4J following their own instruction.

3. install Java 7 and Java 8

4. prepare Daikon
    - set DAIKONDIR

5. set JAVAHOME in .bashrc and .mavenrc
6. set run.config
    - copy file `run.config.example`
    - rename it to `run.config`
    - the the following variables inside to the correct path each: JAVA7 JAVA7C JAVA8 RANKSVM_FOLDER

7. prepare the Maven project `scripts_java`
    - edit daikon path value in scripts_java's pom.xml
    - Compile using commands below

        `mvn initialize -f "PARENT_DIR/savant_rework/resavant/modules/scripts_java/pom.xml"`

        `mvn package -f "PARENT_DIR/savant_rework/resavant/modules/scripts_java/pom.xml"`

8. put junit.jar and hamcrest.jar in `PARENT_DIR/savant_rework//resavant/modules/daikon/TestRunner/lib`

## Usage

### General instruction
assuming we did `cd PARENT_DIR/savant_rework`

- building data for Savant to train/predict
    
    `./resavant/run_savant_build_data.sh -b BUGINPUT_FILE -o PATH_TO_OUTPUT`
    - BUGINPUT_FILE is the path to bug.input file for selecting range of buf to process from Defects4J, example file: [bug.input.example]
    - PATH_TO_OUTPUT is a path to arbitrary folder where output will be written
    
- let Savant train with data built from `run_savant_build_data.sh`
    
    `./resavant/run_savant_train.sh -i PATH_TO_DATA -o PATH_TO_OUTPUT`
    - PATH_TO_DATA is `PATH_TO_OUTPUT/6-l2r-data` folder path from `run_savant_build_data.sh`
    - PATH_TO_OUTPUT is a path to arbitrary folder where output will be written

- let Savant predict the value of data built from `run_savant_build_data.sh`
    
    `./resavant/run_savant_predict.sh -i PATH_TO_DATA -m PATH_TO_MODEL -o PATH_TO_OUTPUT`
    - PATH_TO_DATA is one feature file that is in `PATH_TO_OUTPUT/6-l2r-data` 
    - PATH_TO_MODEL is the model file, `PATH_TO_OUTPUT/model` from `run_savant_train.sh`
    - PATH_TO_OUTPUT is a path to arbitrary folder where output will be written

### Usage Scenarios

Some example scenarios can be seen in `scenarios.sh`



[savantpaper]: https://squareslab.github.io/materials/LeLikelyInvariants2016.pdf
[driveessentials]: https://drive.google.com/drive/folders/1zz914BGNNeYFUEdgsVKbH-IEtss-G5VS?usp=sharing
[bug.input.example]: ./resavant/bug.input.example