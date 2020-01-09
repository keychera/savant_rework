package resavant.utils;

import com.github.javaparser.JavaParser;
import com.github.javaparser.ParseResult;
import com.github.javaparser.ast.CompilationUnit;
import com.github.javaparser.ast.Node;
import com.github.javaparser.ast.body.CallableDeclaration;
import com.github.javaparser.ast.body.ClassOrInterfaceDeclaration;
import com.github.javaparser.ast.body.ConstructorDeclaration;
import com.github.javaparser.ast.body.MethodDeclaration;
import com.github.javaparser.printer.PrettyPrinterConfiguration;
import com.github.javaparser.utils.Log;

import java.io.File;
import java.io.FileNotFoundException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;

/**
 * Created by Loren Klingman on 10/19/17.
 * Finds Changes Between Methods of Two Java Source Files
 * from https://stackoverflow.com/a/46851121 with modification
 */
public class MethodDiff {
    public static void main( String[] args )
    {
        if (args.length == 2) {
            String filename1 = args[0];
            String filename2 = args[1];

            HashSet<String> methods = MethodDiff.methodDiffInClass(filename1, filename2);
            methods.forEach(method -> {
                System.out.println(method);
            });
        } else {
            System.out.println("Wrong input: [filename1] [filename2]");
        }
    }

    private static PrettyPrinterConfiguration ppc = null;

    class ClassPair {
        final ClassOrInterfaceDeclaration clazz;
        final String name;
        final String packageName;
        ClassPair(ClassOrInterfaceDeclaration c, String n, String p) {
            clazz = c;
            name = n;
            packageName = p;
        }
    }

    public static PrettyPrinterConfiguration getPPC() {
        if (ppc != null) {
            return ppc;
        }
        PrettyPrinterConfiguration localPpc = new PrettyPrinterConfiguration();
        localPpc.setColumnAlignFirstMethodChain(false);
        localPpc.setColumnAlignParameters(false);
        localPpc.setEndOfLineCharacter("");
        localPpc.setPrintComments(false);
        localPpc.setPrintJavadoc(false);

        ppc = localPpc;
        return ppc;
    }

    public static <N extends Node> List<N> getChildNodesNotInClass(Node n, Class<N> clazz) {
        List<N> nodes = new ArrayList<>();
        for (Node child : n.getChildNodes()) {
            if (child instanceof ClassOrInterfaceDeclaration) {
                // Don't go into a nested class
                continue;
            }
            if (clazz.isInstance(child)) {
                nodes.add(clazz.cast(child));
            }
            nodes.addAll(getChildNodesNotInClass(child, clazz));
        }
        return nodes;
    }

    private List<ClassPair> getClasses(Node n, String parents, boolean inMethod) {
        List<ClassPair> pairList = new ArrayList<>();

        String packageName = null;
        if (n instanceof CompilationUnit) {
            CompilationUnit cu = (CompilationUnit) n;
            if (cu.getPackageDeclaration().isPresent()) {
                packageName = cu.getPackageDeclaration().get().getNameAsString();
            }
        }

        for (Node child : n.getChildNodes()) {
            if (child instanceof ClassOrInterfaceDeclaration) {
                ClassOrInterfaceDeclaration c = (ClassOrInterfaceDeclaration)child;
                String cName = parents + c.getNameAsString();
                
                if (inMethod) {
                    System.out.println(
                            "WARNING: Class " + cName + " is located inside a method. We cannot predict its name at"
                            + " compile time so it will not be diffed."
                    );
                } else {
                    pairList.add(new ClassPair(c, cName, packageName));
                    pairList.addAll(getClasses(c, cName + "$", inMethod));
                }
            } else if (child instanceof MethodDeclaration || child instanceof ConstructorDeclaration) {
                pairList.addAll(getClasses(child, parents, true));
            } else {
                pairList.addAll(getClasses(child, parents, inMethod));
            }
        }
        return pairList;
    }

    private List<ClassPair> getClasses(String file) {
        try {
            JavaParser parser = new JavaParser();
            ParseResult<CompilationUnit> cuParseResult = parser.parse(new File(file));
            CompilationUnit cu;
            if (cuParseResult.getResult().isPresent()) {
                cu = cuParseResult.getResult().get();
            } else {
                Log.error("No CompilationUnit parsed");
                return null;
            }
            return getClasses(cu, "", false);
        } catch (FileNotFoundException f) {
            throw new RuntimeException("EXCEPTION: Could not find file: "+file);
        }
    }

    @SuppressWarnings("unchecked")
    public static String getSignature(ClassPair classPair, Node m) {
        String signature = null;
        if (m instanceof MethodDeclaration) {
            CallableDeclaration<MethodDeclaration> mDeclaration = (CallableDeclaration<MethodDeclaration>) m;
            signature = classPair.name + "::" + mDeclaration.getSignature().asString().replace(" ", "") + " : " + mDeclaration.asMethodDeclaration().getTypeAsString();
        } else if (m instanceof ConstructorDeclaration) {
            signature = classPair.name + "::" + ((CallableDeclaration<ConstructorDeclaration>)m).getSignature().asString();
        } else {
            throw new RuntimeException("EXCEPTION: m is neither MethodDeclaration nor ConstructorDeclaration");
        }
        if (classPair.packageName != null) {
            signature = classPair.packageName + "." + signature;
        }
        return signature;
    }

    public static HashSet<String> methodDiffInClass(String file1, String file2) {
        HashSet<String> changedMethods = new HashSet<>();
        HashMap<String, String> methods = new HashMap<>();

        MethodDiff md = new MethodDiff();

        // Load all the method and constructor values into a Hashmap from File1
        List<ClassPair> cList = md.getClasses(file1);

        for (ClassPair c : cList) {
            List<ConstructorDeclaration> conList = getChildNodesNotInClass(c.clazz, ConstructorDeclaration.class);
            List<MethodDeclaration> mList = getChildNodesNotInClass(c.clazz, MethodDeclaration.class);
            for (MethodDeclaration m : mList) {
                String methodSignature = getSignature(c, m);

                if (m.getBody().isPresent()) {
                    methods.put(methodSignature, m.getBody().get().toString(getPPC()));
                } else {
                    System.out.println("Warning: No Body for " + file1 + " " + methodSignature);
                }
            }
            for (ConstructorDeclaration con : conList) {
                String methodSignature = getSignature(c, con);
                methods.put(methodSignature, con.getBody().toString(getPPC()));
            }
        }

        // Compare everything in file2 to what is in file1 and log any differences
        cList = md.getClasses(file2);
        for (ClassPair c : cList) {
            List<ConstructorDeclaration> conList = getChildNodesNotInClass(c.clazz, ConstructorDeclaration.class);
            List<MethodDeclaration> mList = getChildNodesNotInClass(c.clazz, MethodDeclaration.class);
            for (MethodDeclaration m : mList) {
                String methodSignature = getSignature(c, m);

                if (m.getBody().isPresent()) {
                    String body1 = methods.remove(methodSignature);
                    String body2 = m.getBody().get().toString(getPPC());
                    if (body1 == null || !body1.equals(body2)) {
                        changedMethods.add(methodSignature);
                    }
                } else {
                    System.out.println("Warning: No Body for " + file2 + " " + methodSignature);
                }
            }
            for (ConstructorDeclaration con : conList) {
                String methodSignature = getSignature(c, con);
                String body1 = methods.remove(methodSignature);
                String body2 = con.getBody().toString(getPPC());
                if (body1 == null || !body1.equals(body2)) {
                    changedMethods.add(methodSignature);
                }
            }
            // Anything left in methods was only in the first set and so is "changed"
            for (String method : methods.keySet()) {
                changedMethods.add(method);
            }
        }
        return changedMethods;
    }
}