# Reworking Savant Artifact

this is the repository for the Final Year Project of Kevin Erdiza Yogatama. 

## Step to sets up Resavant

1. Clone Resavant

    `git clone https://github.com/keychera/savant_rework`

2. install Java 7, Java 8
3. set DAIKONDIR
4. set JAVAHOME in .bashrc and .mavenrc
5. clone Defects4J
    - put OpenCLover 4.4.1 to Defects4j/extra folder
    - ./init Defects4j
6. set run.config (set JAVA7 JAVA7C JAVA8 RANKSVM_FOLDER)
7. edit daikon path value in scripts_java's pom.xml
8. mvn initialize -f "[..]/resavant/modules/scripts_java/pom.xml"
9. mvn package -f "[..]/resavant/modules/scripts_java/pom.xml"
10. put junit.jar and hamcrest.jar in /resavant/modules/daikon/TestRunner/lib

99. run [..]/resavant/run_savant_train.sh
