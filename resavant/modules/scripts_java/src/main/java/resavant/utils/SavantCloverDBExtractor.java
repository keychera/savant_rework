package resavant.utils;

import java.io.FileWriter;
import java.io.IOException;
import java.util.ArrayList;
import java.util.BitSet;
import java.util.Collection;
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
        // input -> clover db, failing test list
        String databasePath = "/home/square/Documents/projects/d4j_repo/chart_1_buggy/.clover/clover4_4_1.db";
        List<String> testNames = new ArrayList<>();
        testNames.add("org.jfree.chart.renderer.category.junit.AbstractCategoryItemRendererTests.test2947660");

        try {
            db = CloverDatabase.loadWithCoverage(databasePath, new CoverageDataSpec());
            methodInfos = getMethodInfoSet(db);
            Set<TestCaseInfo> testCaseInfos = getTestCaseInfoSet(db);

            // get all failing test case infos
            Set<TestCaseInfo> failingTestCaseInfos = new LinkedHashSet<>();

            Iterator<String> testNameIterator = testNames.iterator();
            while (testNameIterator.hasNext()) {
                String testName = testNameIterator.next();
                TestCaseInfo aFailingTest = GeneralUtils.findElementInCollection(testCaseInfos,
                        (TestCaseInfo test, String name) -> test.getQualifiedName().equals(name), testName);
                failingTestCaseInfos.add(aFailingTest);
            }

            // get all method run by failing test case infos (the covered methods)
            BitSet testHits = db.getCoverageData().getHitsFor(failingTestCaseInfos);
            List<FullMethodInfo> coveredMethodInfos = GeneralUtils.findElementsInCollection(methodInfos,
                    (FullMethodInfo method, BitSet hits) -> isMethodHit(method, hits), testHits);

            // get all passing tests that runs the covered methods
            Set<TestCaseInfo> passingTestCaseInfos = new LinkedHashSet<>();

            Iterator<FullMethodInfo> methodIterator = coveredMethodInfos.iterator();
            while (methodIterator.hasNext()) {
                FullMethodInfo coveredMethod = methodIterator.next();
                Set<TestCaseInfo> passingTests = getTestHits(coveredMethod);
                passingTestCaseInfos.addAll(passingTests);
            }

            // create test hit matrix for each covered methods
            MethodTestMatrix failingMatrix = new MethodTestMatrix(coveredMethodInfos, failingTestCaseInfos);
            MethodTestMatrix passingMatrix = new MethodTestMatrix(coveredMethodInfos, passingTestCaseInfos);

            // print to csv
            failingMatrix.printToFile("/home/square/Documents/projects/d4j_repo/chart_1_buggy/res_fail.csv");
            passingMatrix.printToFile("/home/square/Documents/projects/d4j_repo/chart_1_buggy/res_pass.csv");

        } catch (CloverException e) {
            System.out.println("Error from Clover: ");
            e.printStackTrace();
            return;
        }
    }

    static class MethodTestMatrix {
        Collection<FullMethodInfo> methodInfos;
        Collection<TestCaseInfo> testCaseInfos;
        ArrayList<ArrayList<Boolean>> testHits;

        public MethodTestMatrix(Collection<FullMethodInfo> methodInfos, Collection<TestCaseInfo> testCaseInfos) {
            this.methodInfos = methodInfos;
            this.testCaseInfos = testCaseInfos;

            testHits = new ArrayList<>(methodInfos.size());

            int i = 0;
            Iterator<FullMethodInfo> methodIterator = methodInfos.iterator();
            while (methodIterator.hasNext()) {
                testHits.add(new ArrayList<>(testCaseInfos.size()));

                FullMethodInfo currentMethod = methodIterator.next();
                ArrayList<Boolean> currentMethodTestHit = testHits.get(i);
                Iterator<TestCaseInfo> testIterator = testCaseInfos.iterator();
                while (testIterator.hasNext()) {
                    TestCaseInfo currentTest = testIterator.next();
                    Boolean val = isMethodHit(currentMethod, currentTest);
                    currentMethodTestHit.add(val);
                }

                i++;
            }
        }

        public void printToFile(String output) {
            List<String> rows = new ArrayList<>(this.methodInfos.size());

            int i = 0;
            Iterator<FullMethodInfo> methodIterator = this.methodInfos.iterator();
            while (methodIterator.hasNext()) {
                StringBuilder rowBuilder = new StringBuilder();
                FullMethodInfo currentMethod = methodIterator.next();
                rowBuilder.append(currentMethod.getQualifiedName());

                Iterator<Boolean> testHitsIterator = testHits.get(i).iterator();
                while (testHitsIterator.hasNext()) {
                    Boolean isHit = testHitsIterator.next();
                    if (isHit) {
                        rowBuilder.append(",0");
                    } else {
                        rowBuilder.append(",1");
                    }
                }
                String row = rowBuilder.toString();
                rows.add(row);
                i++;
            }
            try {
                FileWriter writer = new FileWriter(output);
                Iterator<String> rowIterator = rows.iterator();
                while(rowIterator.hasNext()) {
                    String rowToPrint = rowIterator.next();
                    writer.write(rowToPrint + System.lineSeparator());
                }
                writer.close();

                FileWriter headerWriter = new FileWriter(output + ".header");
                Iterator<TestCaseInfo> testIterator = this.testCaseInfos.iterator();
                while (testIterator.hasNext()) {
                    String testName = testIterator.next().getQualifiedName();
                    headerWriter.write(testName + System.lineSeparator());
                }
                headerWriter.close();
            } catch (IOException e) {
                System.out.println("IO Error: ");
                e.printStackTrace();
            }
        }
    }

    private static boolean isMethodHit(FullMethodInfo method, TestCaseInfo test) {
        BitSet testHits = db.getCoverageData().getHitsFor(test);
        return isMethodHit(method, testHits);
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

    private static Set<TestCaseInfo> getTestHits(MethodInfo methodInfo) {
        SimpleCoverageRange methodRange = new SimpleCoverageRange(methodInfo.getDataIndex(), methodInfo.getDataLength());
        return db.getTestHits(methodRange);
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