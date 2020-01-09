package resavant.utils;

import static org.junit.Assert.assertEquals;

import java.io.File;
import java.io.FileNotFoundException;
import java.net.URISyntaxException;
import java.net.URL;
import java.util.Iterator;
import java.util.LinkedHashSet;

import com.atlassian.clover.registry.entities.FullMethodInfo;
import com.atlassian.clover.registry.entities.TestCaseInfo;

import org.junit.BeforeClass;
import org.junit.Test;

/**
 * Unit test for Savant Clover DB Extracgtor App.
 */
public class SavantCloverDBExtractorTest {

    @BeforeClass
    public static void InitDB() throws FileNotFoundException {
        URL testDBURL = SavantCloverDBExtractor.class.getClassLoader().getResource("test-clover-db");
        String testDBPath;
        try {
            testDBPath = new File(testDBURL.toURI()).getAbsolutePath();
        } catch (URISyntaxException e) {
            e.printStackTrace();
            throw new FileNotFoundException("Exception: test-clover-db resource folder not found");
        }
        String testLang1bDB = testDBPath + "/Lang.1b.clover-db/clover4_4_1.db";

        SavantCloverDBExtractor.extractFromDB(testLang1bDB);
    }

    @Test
    public void TestDB() {
        LinkedHashSet<FullMethodInfo> methodInfos = (LinkedHashSet<FullMethodInfo>) SavantCloverDBExtractor.failingMatrix.methodInfos;
        
        Iterator<FullMethodInfo> methodIterator = methodInfos.iterator();
        LinkedHashSet<String> methodNamesOutput = new LinkedHashSet<>();
        while(methodIterator.hasNext()) {
            String output = SavantCloverDBExtractor.getFormattedMethodName(methodIterator.next());
            methodNamesOutput.add(output);
        }
        
        LinkedHashSet<String> expected = new LinkedHashSet<>();
        expected.add("org.apache.commons.lang3.StringUtils::isBlank(CharSequence) : boolean");
        expected.add("org.apache.commons.lang3.math.NumberUtils::createNumber(String) : Number");
        expected.add("org.apache.commons.lang3.math.NumberUtils::createInteger(String) : Integer");
        
        assertEquals(expected, methodNamesOutput);

        LinkedHashSet<TestCaseInfo> testCaseInfos = (LinkedHashSet<TestCaseInfo>) SavantCloverDBExtractor.failingMatrix.testCaseInfos;

        Iterator<TestCaseInfo> testIterator = testCaseInfos.iterator();
        assertEquals(true, testIterator.hasNext());

        String testName = SavantCloverDBExtractor.getFormattedMethodName(testIterator.next().getSourceMethod());
        assertEquals("org.apache.commons.lang3.math.NumberUtilsTest::TestLang747() : void", testName);
    }
}