import java.io.BufferedReader;
import java.io.FileReader;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Iterator;

import org.junit.runner.JUnitCore;
import org.junit.runner.Request;
import org.junit.runner.Result;

public class TestRunner {
    public static void main(String... args) {
        if (args.length == 2) {
            String mode = args[0];
            if (mode.equals("single")) {
                String testName = args[1];
                runTest(testName);
            } else if (mode.equals("multiple")) {
                String testListPath = args[1];
                ArrayList<String> testList = readFileEachLine(testListPath);

                Iterator<String> testIterator = testList.iterator();
                while(testIterator.hasNext()) {
                    String testName = testIterator.next();
                    runTest(testName);
                }
            } else {
                System.out.println("Wrong mode! [single|multiple]");
            }

        } else {
            System.out.println("Wrong input");
        }
    }

    private static void runTest(String testName) {
        String[] classAndMethod = testName.split("::");
        String className = classAndMethod[0];
        String methodName = classAndMethod[1].split("\\(")[0];

        Request request;
        try {
            request = Request.method(Class.forName(className), methodName);
            Result result = new JUnitCore().run(request);
            System.out.println(result.wasSuccessful() ? "pass" : "fail, msg: " + result.getFailures().get(0).getMessage());
        } catch (ClassNotFoundException e) {
            e.printStackTrace();
        }
    }

    private static ArrayList<String> readFileEachLine(String path) {
        ArrayList<String> lines = new ArrayList<>();
        BufferedReader reader;
		try {
			reader = new BufferedReader(new FileReader(path));
			String line = reader.readLine();
			while (line != null) {
				lines.add(line);
				line = reader.readLine();
			}
			reader.close();
		} catch (IOException e) {
			e.printStackTrace();
		}
        return lines;
    }
}