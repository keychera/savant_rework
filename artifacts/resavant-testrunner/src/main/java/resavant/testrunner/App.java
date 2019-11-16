package resavant.testrunner;

/**
 * Hello world!
 *
 */
public class App 
{
    public static void main( String[] args )
    {
        if (args.length >= 3) {
            String testClassName = args[0];
            String methodName = args[1];
            String outputPath = args[2];
            try {
                SingleTestRunner.process(testClassName, methodName, outputPath);
            } catch (ClassNotFoundException e) {
                System.out.println("eh");
                e.printStackTrace();
            }
        } else {
            System.out.println("App [classname] [methodname] [outputpath]");
        }
    }
}
