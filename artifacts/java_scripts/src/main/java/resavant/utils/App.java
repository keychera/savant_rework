package resavant.utils;

import java.util.HashSet;

public class App
{
    public static void main( String[] args )
    {
        if (args.length == 2) {
            String filename1 = args[0];
            String filename2 = args[1];

            HashSet<String> res = MethodDiff.methodDiffInClass(filename1, filename2);
            System.out.println(res);
        } else {
            System.out.println("Wrong input: [filename1] [filename2]");
        }
    }
}

