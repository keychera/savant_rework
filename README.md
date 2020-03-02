# Reworking Savant Artifact

This is the repository for the Final Year Project of Kevin Erdiza Yogatama. It features an implementation of Savant (paper: [pdf][savantpaper]) with the name "Resavant".

## Requirements

[Resavant essentials][driveessentials]

## Installation

1. Clone Resavant.

    `git clone https://github.com/keychera/savant_rework`
    
2. Prepare modified Defects4J.
    - Resavant use a modified version of Defects4J, which utilize tools named OpenClover.
    - get OpenClover 4.4.1 provided above.
    - clone the modified Defects4J from `https://github.com/keychera/defects4J`

        `git clone https://github.com/keychera/defects4J`
    
    - before installing Defects4J, put OpenClover 4.4.1 folder in a new folder named `extra` in Defects4J folder. It would look like this:

        `../defects4J/extra/clover-ant-4.4.1/..`
        
        (make sure the folder name is the same)
    
    - Install Defects4J following their own instruction.

3. install Java 7 and Java 8

4. prepare Daikon
    - set DAIKONDIR

5. set JAVAHOME in .bashrc and .mavenrc
6. set run.config (set JAVA7 JAVA7C JAVA8 RANKSVM_FOLDER)

7. edit daikon path value in scripts_java's pom.xml

8. mvn initialize -f "[..]/resavant/modules/scripts_java/pom.xml"
9. mvn package -f "[..]/resavant/modules/scripts_java/pom.xml"

10. put junit.jar and hamcrest.jar in /resavant/modules/daikon/TestRunner/lib

## Usage

99. run [..]/resavant/run_savant_train.sh



[savantpaper]: https://squareslab.github.io/materials/LeLikelyInvariants2016.pdf
[driveessentials]: https://drive.google.com/drive/folders/1zz914BGNNeYFUEdgsVKbH-IEtss-G5VS?usp=sharing