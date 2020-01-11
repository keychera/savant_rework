import org.junit.runner.JUnitCore;
import org.junit.runner.Request;
import org.junit.runner.Result;
import org.junit.runner.notification.Failure;

import java.util.Iterator;

public class SingleTestRunner {
    public static void main(String... args) throws ClassNotFoundException {
        if (args.length == 1) {
            String[] classAndMethod = args[0].split("::");
            Request request = Request.method(Class.forName(classAndMethod[0]),
                    classAndMethod[1]);

            Result result = new JUnitCore().run(request);
            
            System.out.println(result.wasSuccessful() ? "pass" : "fail");
            if (!result.wasSuccessful()) {
                System.out.println("detail:");
                Iterator<Failure> failureIterator = result.getFailures().iterator();
                while(failureIterator.hasNext()) {
                    Failure failure = failureIterator.next();
                    System.out.println(failure.getMessage());
                    System.out.println(failure.getTrace());
                }
            }
            System.out.println();
        } else {
            System.out.println("Wrong input");
        }
    }
}