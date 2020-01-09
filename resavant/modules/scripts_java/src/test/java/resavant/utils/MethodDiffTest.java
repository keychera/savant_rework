package resavant.utils;

import static org.junit.Assert.assertEquals;

import java.io.File;
import java.io.FileNotFoundException;
import java.net.URISyntaxException;
import java.net.URL;
import java.util.HashSet;

import org.junit.BeforeClass;
import org.junit.Test;

/**
 * Unit test for simple App.
 */
public class MethodDiffTest {
    private static String diffClassesPath;

    @BeforeClass
    public static void name() throws FileNotFoundException {
        URL diffClassesURL = MethodDiffTest.class.getClassLoader().getResource("diff-classes");
        try {
            diffClassesPath = new File(diffClassesURL.toURI()).getAbsolutePath();
        } catch (URISyntaxException e) {
            e.printStackTrace();
            throw new FileNotFoundException("Exception: diff-class resource folder not found");
        }
    }

    @Test
    public void TestModify() {
        String file1 = diffClassesPath + "/1-modify/buggy.java.src";
        String file2 = diffClassesPath + "/1-modify/fixed.java.src";
        HashSet<String> actual = MethodDiff.methodDiffInClass(file1, file2);

        HashSet<String> expected = new HashSet<>();
        expected.add("test.math.TestClass::Add(int,int) : int");
        expected.add("test.math.TestClass::Divide(int,int) : int");

        assertEquals(expected, actual);
    }

    @Test
    public void TestAdd() {
        String file1 = diffClassesPath + "/2-add/buggy.java.src";
        String file2 = diffClassesPath + "/2-add/fixed.java.src";
        HashSet<String> actual = MethodDiff.methodDiffInClass(file1, file2);

        HashSet<String> expected = new HashSet<>();
        expected.add("test.math.TestClass::Negate(int) : int");

        assertEquals(expected, actual);
    }

    @Test
    public void TestRemove() {
        String file1 = diffClassesPath + "/3-remove/buggy.java.src";
        String file2 = diffClassesPath + "/3-remove/fixed.java.src";
        HashSet<String> actual = MethodDiff.methodDiffInClass(file1, file2);

        HashSet<String> expected = new HashSet<>();
        expected.add("test.math.TestClass::Multiply(int,int) : int");
        expected.add("test.math.TestClass::Divide(int,int) : int");

        assertEquals(expected, actual);
    }

    @Test
    public void TestChangeSignature() {
        String file1 = diffClassesPath + "/4-change-signature/buggy.java.src";
        String file2 = diffClassesPath + "/4-change-signature/fixed.java.src";
        HashSet<String> actual = MethodDiff.methodDiffInClass(file1, file2);

        HashSet<String> expected = new HashSet<>();
        expected.add("test.math.TestClass::Divide(int,int) : int");

        // TODO
        // assertEquals(expected, actual);
    }

    @Test
    public void TestChangeConstructor() {
        String file1 = diffClassesPath + "/5-change-constructor/buggy.java.src";
        String file2 = diffClassesPath + "/5-change-constructor/fixed.java.src";
        HashSet<String> actual = MethodDiff.methodDiffInClass(file1, file2);

        HashSet<String> expected = new HashSet<>();
        expected.add("test.math.TestClass::TestClass(int,int)");

        // TODO
        // assertEquals(expected, actual);
    }
}
