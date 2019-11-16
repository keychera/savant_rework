# a simple SingleTestRunner

to run a specific method in a testclass of a project

## step to use

1. Compile the program first

2. make file with name 'runconfig' with content below

    ```
    CLASSPATH="<relevant path consist of several thing expained in the next step.>"
    TESTCLASS="<name of the test class(with its package naming)>"
    TESTMETHOD="<name of the method>"
    
    ```

3. the classpath that needs to be included consist of

    1. path to `junit-4.12.jar` and `hamcrest-core-1.3.jar`
    2. path that includes the classes and test classes of the target program

4. run `run.sh`
