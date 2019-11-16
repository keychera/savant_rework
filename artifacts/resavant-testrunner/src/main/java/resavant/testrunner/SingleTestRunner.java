package resavant.testrunner;

import java.util.List;

import org.junit.runner.JUnitCore;
import org.junit.runner.Request;
import org.junit.runner.Result;
import org.junit.runner.notification.Failure;

/**
 * Hello world!
 *
 */
public class SingleTestRunner 
{
    public static void process(String className, String methodName, String outputPath )
        throws IllegalArgumentException, ClassNotFoundException
    {
        if (className == null) {
            throw new IllegalArgumentException("The className must not be null");
        }
        if (methodName == null) {
            throw new IllegalArgumentException("The methodName must not be null");
        }
        if (outputPath == null) {
            throw new IllegalArgumentException("The outputPath must not be null");
        }
        Class<?> testClass = Class.forName(className);
        Request request = Request.method(testClass, methodName);

        Result result = new JUnitCore().run(request);

        System.out.println("testing " + className + " method " + methodName);

        if (result.wasSuccessful()) {
            System.out.println(result.wasSuccessful());
        } else {
            System.out.println("what");
            List<Failure> failures = result.getFailures();
            for (Failure failure : failures) {
                System.out.println(failure.toString());
            }
        }
            
    }

}
