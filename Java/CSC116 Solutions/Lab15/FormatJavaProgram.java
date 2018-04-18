import java.io.*;
import java.util.*;

/**
 * Program that takes an unformatted Java program and prints out the same Java
 * program with proper indentation.
 * 
 * @author Dr. Sarah S. Heckman
 * @author Dr. Jessica Young Schmidt
 */
public class FormatJavaProgram {

    /** Constant representing number of spaces to indent */
    public static final int NUM_SPACES = 4;

    /**
     * Starts the program
     * 
     * @param args An array of command line arguments
     */
    public static void main(String[] args) {
        userInterface();
    }

    /**
     * Program's user interface.
     */
    public static void userInterface() {
        // Create null objects as placeholders for scope
        // We specifically want a File object since we are basing the
        // output file's name on the input file's name
        File file = null;
        Scanner inputFile = null;

        Scanner console = new Scanner(System.in);

        // While we have not gotten a valid file that can make a Scanner
        // we'll get an input file, and try to create a Scanner.
        while (inputFile == null) {
            file = getInputFile(console);
            inputFile = getInputScanner(file);
        }

        // Create a PrintStream based on the valid file
        // passed in by the user
        PrintStream outputFile = getOutputPrintStream(file);

        // If the PrintStream could be created, then process the
        // Java file.
        if (outputFile != null) {
            processJavaFile(inputFile, outputFile);
        } else {
            System.out.println("Output file cannot be written");
        }
    }

    /**
     * Returns a File object from the file name entered by the user
     * 
     * @param console scanner for the console to read from user
     * @return a File representing the file on the OS entered by the user
     */
    public static File getInputFile(Scanner console) {
        File file = null;
        while (file == null) {
            System.out.println("Java File to Format?");
            String name = console.nextLine();
            file = new File(name);
            if (file.exists()) {
                return file;
            }
        }
        return file;
    }

    /**
     * Returns a Scanner for the specified file, or null if the file does not
     * exist.
     * 
     * @param file the File entered by the user
     * @return a Scanner to read the file
     */
    public static Scanner getInputScanner(File file) {
        Scanner inputFile = null;
        try {
            inputFile = new Scanner(file);
        } catch (FileNotFoundException e) {
            System.out.println("File Not Found. Please try again.");
        }
        return inputFile;
    }

    /**
     * Returns a PrintStream for the specified file, or null if the file cannot
     * be created. PrintStream should be format of ProgramName_Formatted.java
     * based on name of file.
     * 
     * @param file the File entered by the user
     * @return a PrintStream to print to the file.
     */
    public static PrintStream getOutputPrintStream(File file) {
        PrintStream outputFile = null;
        String name = file.getName();
        try {
            name = name.substring(0, name.indexOf(".java"));
            outputFile = new PrintStream(new File(name + "_Formatted.java"));
        } catch (FileNotFoundException e) {
            System.out.println("File unable to be written.");
        }
        return outputFile;
    }

    /**
     * Processes a Java file and provides the proper indentation
     * 
     * @param inputFile the Java file to process
     * @param outputFile the file to write the formated code to
     */
    public static void processJavaFile(Scanner inputFile, PrintStream outputFile) {
        int indentLevels = 0;
        while (inputFile.hasNextLine()) {
            String line = inputFile.nextLine().trim(); // trim() cuts of leading
                                                       // and ending whitespace

            // If line contains both { and } like a catch line
            if (line.contains("}") && line.contains("{")) {
                indentLevels--;
                outputFile.println(getFormattedLine(line, indentLevels));
                indentLevels++;
            } else if (line.contains("}")) { // If the line only contains a
                                             // closing bracket
                indentLevels--;
                outputFile.println(getFormattedLine(line, indentLevels));
            } else if (line.contains("{")) { // If the line only contains an
                                             // opening bracket
                outputFile.println(getFormattedLine(line, indentLevels));
                indentLevels++;
            } else { // All other lines
                outputFile.println(getFormattedLine(line, indentLevels));
            }
        }
    }

    /**
     * Returns a line of Java code formatted to the proper indentation
     * 
     * @param line the line to format
     * @param indentLevels the number of levels of indentation
     * @return the formatted line
     */
    public static String getFormattedLine(String line, int indentLevels) {
        String formattedLine = "";
        for (int i = 0; i < indentLevels; i++) {
            for (int j = 0; j < NUM_SPACES; j++) {
                formattedLine += " ";
            }
        }
        formattedLine += line;
        return formattedLine;
    }

}