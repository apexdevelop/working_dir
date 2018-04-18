import java.util.*;
import java.io.*;

/**
 * Open a file with the name hello.txt
 * Store the message "Hello, World!\nNAME" in the file, where "NAME" is replaced with your name
 * Close the file
 * Open the same file again
 * Read the message in line by line and print it to console
 * @author Yan Chen
 */
public class HelloInOut {

    /**
     * Starts the program
     * 
     * @param args array of command line arguments
     */
    public static void main(String[] args) throws FileNotFoundException {
        processFile();
    }

    /**
     * Open a file with the name hello.txt
     * Store the message "Hello, World!\nNAME" in the file, where "NAME" is replaced with your name
     * Close the file
     * Open the same file again
     * Read the message in line by line and print it to console
     */
    public static void processFile() throws FileNotFoundException {
        String fileName = "hello.txt";        
            
        File outFile = new File(fileName);                    
        PrintStream output = new PrintStream(outFile);
        String content = "Hello, World!\nYan Chen";                       
        output.println(content);
        output.close();
        
        File inFile = new File(fileName);
        Scanner input = new Scanner(inFile);
        
        while (input.hasNextLine()) {
            String line = input.nextLine(); 
            System.out.println(line);   
        }
    }
}