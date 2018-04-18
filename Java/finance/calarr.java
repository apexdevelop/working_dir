import java.util.*;
import java.io.*;

//when save from csv to txt, choose tab delimited format, if choose UTF16 Unicode, won't be able to read

public class calarr
{
    public static final int INI_MIN=10000;
    public static final int INI_MAX=-10000;
    public static final int INI_LEN=10000;
    
    public static void main(String[] args)
    {
        //prepare_data();
        calculate();
    }
    
    
    public static void calculate()
    {
        
        Scanner console = new Scanner(System.in);
        int length=INI_LEN;
        //int [] numbers = new int[]{1,2,3,4,5,6,7,8,9};
        double[] numbers = new double[length];
        double sum = 0;
        double max = INI_MAX;
        double min = INI_MIN;
        double sumDev = 0;
        int count = 0;
        
        //put in data
        Scanner fileScanner = getInputScanner(console);
        
        while (fileScanner.hasNextLine()) {
            String line = fileScanner.nextLine();
            Scanner lineScan = new Scanner(line);
            while (lineScan.hasNext()) {
                //String date = lineScan.next();
                //String mm = date.substring(4, 6);
                //String dd = date.substring(6);
                //String yyyy= date.substring(0,4);
                //System.out.print(mm + "/" + dd + "/" + yyyy + " ");
                numbers[count] = lineScan.nextDouble();
                //System.out.println("new_number:  " + numbers[count]);
                sum+=numbers[count];
                
                if (numbers[count] > max) {
                    max = numbers[count];
                } 
                if (numbers[count] < min) {
                    min = numbers[count];
                }
                count+=1;
            }
        }
        
        double average = sum /count;
        System.out.println("Average value is : " + average);
        
        System.out.println("max number is : " + max);
        
        System.out.println("min number is : " + min);
        
        for (int i=0; i<count;i++)
        {
           sumDev=sumDev+(numbers[i]-average)*(numbers[i]-average);
           //System.out.println("new_number:  " + numbers[i]);
        }
        double standardDeviation = Math.sqrt(sumDev/(count-1));
        //System.out.println("The standard deviation is : " + standardDeviation);
        System.out.format("The standard deviation is : %.2f%n",standardDeviation);
        
    }
    
    /**
     * Reads filename from user until the file exists, then return a file
     * scanner
     * 
     * @param console Scanner that reads from the console
     * 
     * @return a scanner to read input from the file
     */
    public static Scanner getInputScanner(Scanner console) {
        System.out.print("Enter a file name to process: ");
        File file = new File(console.next());
        while (!file.exists()) {
            System.out.print("File doesn't exist. " + "Enter a file name to process: ");
            file = new File(console.next());
        }
        Scanner fileScanner = null;// null signifies NO object reference
                                   // while (result == null) {
        try {
            fileScanner = new Scanner(file);
        } catch (FileNotFoundException e) {
            System.out.println("Input file not found. ");
            System.out.println(e.getMessage());
            System.exit(1);
        }
        return fileScanner;
    }
}