package resavant.utils;

import java.util.BitSet;
import java.util.Iterator;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Set;

import com.atlassian.clover.CloverDatabase;
import com.atlassian.clover.CoverageDataSpec;
import com.atlassian.clover.api.CloverException;
import com.atlassian.clover.api.registry.ClassInfo;
import com.atlassian.clover.api.registry.FileInfo;
import com.atlassian.clover.api.registry.MethodInfo;
import com.atlassian.clover.api.registry.PackageInfo;
import com.atlassian.clover.registry.entities.FullMethodInfo;
import com.atlassian.clover.registry.entities.FullProjectInfo;
import com.atlassian.clover.registry.entities.TestCaseInfo;
import com.atlassian.clover.util.SimpleCoverageRange;

public class SavantCloverDBExtractor {
    static CloverDatabase db;
    static Set<FullMethodInfo> methodInfos;
    

    public static void main(String[] args) {
        String databasePath = "/home/square/Documents/projects/d4j_repo/chart_1_buggy/.clover/clover4_4_1.db";
        try {
            db = CloverDatabase.loadWithCoverage(databasePath, new CoverageDataSpec());
            methodInfos = getMethodInfoSet(db);

            System.out.println();
            String methodName = "org.jfree.chart.LegendItemCollection.getItemCount";
            FullMethodInfo aMethod =
                GeneralUtils.findElementInCollection(
                    methodInfos,
                    (FullMethodInfo m, String name) -> m.getQualifiedName().equals(name),
                    methodName
                );
            if (aMethod != null) {
                System.out.println("getting test hits for method :(" + aMethod.getName() + ")");
                getTestHits(aMethod);
            } else {
                System.out.println("method :(" + methodName + " not found!");
            }
            
            String testName = "org.jfree.chart.renderer.category.junit.AbstractCategoryItemRendererTests.test2947660";
            Set<TestCaseInfo> testCaseInfos = getTestCaseInfoSet(db);
            TestCaseInfo aTestcase =
                GeneralUtils.findElementInCollection(
                    testCaseInfos,
                    (TestCaseInfo test, String name) -> test.getQualifiedName().equals(name),
                    testName
                );
            if (aTestcase != null) {
                System.out.println("this test found! :(" + aTestcase.getQualifiedName() + ")");
                System.out.println("test status: " + aTestcase.isSuccess());

                Set<TestCaseInfo> failedTests = new LinkedHashSet<>();
                failedTests.add(aTestcase);
                BitSet hits = db.getCoverageData().getHitsFor(failedTests);
                System.out.println(hits.length());

                List<FullMethodInfo> hitMethods = GeneralUtils.findElementsInCollection(
                    methodInfos,
                    (FullMethodInfo method, BitSet testHits) -> isMethodHit(method, testHits),
                    hits
                );
                System.out.println("number of methods found: " + hitMethods.size());
                Iterator<FullMethodInfo> methodIterator = hitMethods.iterator();
                while(methodIterator.hasNext()) {
                    System.out.println(methodIterator.next().getQualifiedName());
                } 

            } else {
                System.out.println("test :(" + testName + " not found!");
            }
        
        } catch (CloverException e) {
            System.out.println("Error from Clover: ");
            e.printStackTrace();
            return;
        }
    }

    private static boolean isMethodHit(FullMethodInfo method, BitSet testHits) {
        int firstIndex = method.getDataIndex();
        int length = method.getDataIndex() + method.getDataLength();
        boolean val = true;
        for (int i = firstIndex; i < length; i++) {
            val &= testHits.get(i);
        }
        return val;
    }

    private static void getTestHits(MethodInfo methodInfo) {
        SimpleCoverageRange methodRange = new SimpleCoverageRange(methodInfo.getDataIndex(), methodInfo.getDataLength());
        Set<TestCaseInfo> tcis = db.getTestHits(methodRange);
        System.out.println("length of tcis: " + tcis.size());
        for (TestCaseInfo testCaseInfo : tcis) {
            System.out.println(testCaseInfo.getTestName());
        }
    }

    private static Set<FullMethodInfo> getMethodInfoSet(CloverDatabase db) {
        FullProjectInfo projectInfo = db.getAppOnlyModel();
        Set<FullMethodInfo> methodInfos = new LinkedHashSet<>();
        for (PackageInfo packageInfo : projectInfo.getAllPackages()) {
            for (FileInfo fileInfo : packageInfo.getFiles()) {
                for (ClassInfo classInfo : fileInfo.getClasses()) {
                    for (MethodInfo methodInfo : classInfo.getAllMethods()) {
                        methodInfos.add((FullMethodInfo)methodInfo);
                    }
                }
            }
        }
        return methodInfos;
    }

    private static Set<TestCaseInfo> getTestCaseInfoSet(CloverDatabase db) {
        return db.getCoverageData().getPerTestCoverage().getTests();
    }
}