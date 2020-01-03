package resavant.utils;

import com.atlassian.clover.CloverDatabase;
import com.atlassian.clover.api.CloverException;

public class SavantCloverDBExtractor {
    public static void main(String[] args) {
        String databasePath = "/home/square/Documents/projects/d4j_repo/chart_1_buggy/.clover/clover4_4_1.db";
        extractFromDB(databasePath);
    }

    public static void extractFromDB(String databasePath) {
        CloverDatabase db;
        try {
            db = new CloverDatabase(databasePath);
            System.out.println(db.getName());
        } catch (CloverException e) {
            System.out.println("Error from Clover: ");
            e.printStackTrace();
        }
        
    }

    
}