package resavant.utils;

import java.util.ArrayList;
import java.util.List;
import java.util.Set;

import com.atlassian.clover.CloverDatabase;
import com.atlassian.clover.CodeType;
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
    static List<FullMethodInfo> methodInfos;
    

    public static void main(String[] args) {
        String databasePath = "/home/square/Documents/projects/d4j_repo/chart_1_buggy/.clover/clover4_4_1.db";
        try {
            db = CloverDatabase.loadWithCoverage(databasePath, new CoverageDataSpec());
            methodInfos = getMethodInfoList(db);
            System.out.println();
            String methodName = "org.jfree.chart.LegendItemCollection.getItemCount";
            FullMethodInfo a_method =
                GeneralUtils.findElementInList(
                    methodInfos,
                    (FullMethodInfo m, String name) -> m.getQualifiedName().equals(name),
                    methodName
                );
            if (a_method != null) {
                System.out.println("getting test hits for method :(" + a_method.getName() + ")");
                getTestHits(a_method);
            } else {
                System.out.println("method :(" + methodName + " not found!");
            }   
        } catch (CloverException e) {
            System.out.println("Error from Clover: ");
            e.printStackTrace();
            return;
        }
    }

    private static void getTestHits(MethodInfo methodInfo) {
        SimpleCoverageRange methodRange = new SimpleCoverageRange(methodInfo.getDataIndex(), methodInfo.getDataLength());
        Set<TestCaseInfo> tcis = db.getTestHits(methodRange);
        System.out.println("length of tcis: " + tcis.size());
        for (TestCaseInfo testCaseInfo : tcis) {
            System.out.println(testCaseInfo.getTestName());
        }
    }

    private static List<FullMethodInfo> getMethodInfoList(CloverDatabase db) {
        FullProjectInfo projectInfo = db.getModel(CodeType.APPLICATION);
        List<FullMethodInfo> methodInfos = new ArrayList<>();
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
}