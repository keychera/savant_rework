package resavant.utils;

import static org.junit.Assert.assertEquals;

import java.io.File;
import java.io.FileNotFoundException;
import java.net.URISyntaxException;
import java.net.URL;
import java.util.HashSet;

import org.junit.Test;

/**
 * Unit test for simple App.
 */
public class AppTest {
    /**
     * Rigorous Test :-)
     * 
     * @throws FileNotFoundException
     */
    @Test
    public void shouldAnswerWithTrue() throws FileNotFoundException {
        URL diffClassesURL = AppTest.class.getClassLoader().getResource("diff-classes");
        String diffClassesPath;
        try {
            diffClassesPath = new File(diffClassesURL.toURI()).getAbsolutePath();
        } catch (URISyntaxException e) {
            e.printStackTrace();
            throw new FileNotFoundException("Exception: diff-class resource folder not found");
        }
        String file1 = diffClassesPath + "/1/buggy.java.src";
        String file2 = diffClassesPath + "/1/fixed.java.src";
        HashSet<String> actual = MethodDiff.methodDiffInClass(file1, file2);

        HashSet<String> expected = new HashSet<>();
        expected.add("TestClass.Add(int,int)");
        expected.add("TestClass.Divide(int,int)");

        assertEquals(expected, actual);
    }
}
