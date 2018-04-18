import java.io.*;
import java.util.*;
public class GraduateInformation {

    public static void main(String[] args)  {
        
        if(args.length != 1) {
            System.out.println("Usage: java GraduateInformation filename");
            System.exit(0);
        } 
        
        File file0 = new File(args[0]);
        if(file0.exists()==false) {
            System.out.println("Unable to access input file: " + args[0]);
            System.exit(0);
        } 
        //get number of lines
        int countL=0;
        try {
            File file = new File(args[0]);
            Scanner fileScanner = new Scanner(file); 
            while (fileScanner.hasNextLine()) {
                String line = fileScanner.nextLine();
                countL+=1;
            }
            fileScanner.close(); 
        } catch (FileNotFoundException e) {
                System.out.println("Error reading file: " + e);                
        } 
               
        
        //create array of graduates      
        Graduate[] graduates = new Graduate[countL];
        //Scanner fileScanner2 = null;
        try {
            File file2 = new File(args[0]);
            Scanner fileScanner2 = new Scanner(file2); 
            for (int i=0;i<=countL-1;i++) {
                String line2 = fileScanner2.nextLine();            
                Scanner lineScan = new Scanner(line2);
                String strName = lineScan.next();
                String strDegree = lineScan.next();
                int intYear = lineScan.nextInt();
                graduates[i] = new Graduate(strName, strDegree, intYear);
            }
            //begin main menu
            Scanner console = new Scanner(System.in); 
            menu(console,graduates);
        } catch (FileNotFoundException e) {
                //System.out.println("Error reading file: " + e);                
        }                

    }
    
    /** main menu
    *@param Scanner console
    *@param array graduates
    */
    public static void menu(Scanner console, Graduate[] graduates) {
        String choice ="";
        do{
            System.out.println("Graduate Information - Please enter an option below." 
            + "\n\nS - Display statistics" + "\nL - List all graduates"
            + "\nD - List graduates by degree" + "\nY - List graduates by year"
            + "\nQ - Quit the program");
            System.out.print("Option:");
            choice = console.next();
            if (choice.equals("S") || choice.equals("s")){
                displayStatistics(graduates);
            } else if (choice.equals("L") || choice.equals("l")) {
                listAll(graduates);
            } else if (choice.equals("D") || choice.equals("d")) {
                listByDegree(console,graduates);
            } else if (choice.equals("Y") || choice.equals("y")) {
                listByYear(console,graduates);
            } else if (choice.equals("Q") || choice.equals("q")) {
                System.out.println("Goodbye!");
                System.exit(1);
            } else {
                System.out.println("Invalid action. Please try again.");
            }
        } while (!choice.equals("S") && !choice.equals("s") && !choice.equals("L") 
        && !choice.equals("l") && !choice.equals("D") && !choice.equals("d") 
        && !choice.equals("Y") && !choice.equals("y")&& !choice.equals("Q") && !choice.equals("q"));
    }                    
    
    /**Display statistics as shown above
    *@param array graduates 
    */
    public static void displayStatistics(Graduate[] graduates) {
        int n =graduates.length;
        System.out.println("Number of graduates:" + n);
        int nB = 0;
        int nM=0;
        int nP=0;
        
        int n1 = 0;
        int n2=0;
        int n3=0;
        int n4=0;
        int n5=0;
        int n6=0;
        
        for (int i=0;i<=n-1;i++) {
            String degree=graduates[i].getDegree();
            if (degree.equals("B.S.")){
                nB+=1;
            } else if (degree.equals("M.S.")){
                nM+=1;
            } else {
                nP+=1;
            }
            int year = graduates[i].getYear();
            
            if (year>=1960 && year <=1969){
                n1+=1;
            } else if (year>=1970 && year <=1979){
                n2+=1;
            } else if (year>=1980 && year <=1989){
                n3+=1;
            } else if (year>=1990 && year <=1999){
                n4+=1;
            } else if (year>=2000 && year <=2009){
                n5+=1;
            } else {
                n6+=1;
            } 
        }
        System.out.println("By degree");
        System.out.println("   B.S.: " + nB);
        System.out.println("   M.S.: " + nM);
        System.out.println("   Ph.D.: " + nP);
        
        
        System.out.println("By year");
        System.out.println("   1960-69: " + n1);
        System.out.println("   1970-79: " + n2);
        System.out.println("   1980-89: " + n3);
        System.out.println("   1990-99: " + n4);
        System.out.println("   2000-09: " + n5);
        System.out.println("   2010-19: " + n6);
        
    }
    
    /** List all graduates as shown above
    *@param array graduates
    */
    public static void listAll(Graduate[] graduates) {
        int n =graduates.length;
        System.out.println("Year Degree Name");
        for (int i=0;i<=n-1;i++) {
            String degree=graduates[i].getDegree();
            String name=graduates[i].getName();
            int year = graduates[i].getYear();
            System.out.print(year + "  " + degree + "  " + name);
            System.out.println();
        }
        
    }
    
    /**Prompt the user for a degree and list all graduates with that degree as shown above
    *@param Scanner console
    *@param array graduates
    */
    public static void listByDegree(Scanner console, Graduate[] graduates) {
        System.out.print("Enter degree (B.S., M.S.,Ph.D.):");
        String choice = console.next();
        if (choice.equals("B.S.") || choice.equals("M.S.") || choice.equals("Ph.D.")) {
            System.out.println("Graduates with degree: " + choice);
            int n =graduates.length;
            for (int i=0;i<=n-1;i++) {
                String degree=graduates[i].getDegree();
                if (degree.equals(choice)) {
                    String name=graduates[i].getName();
                    int year = graduates[i].getYear();
                    System.out.println(year + "   " + name);
                }
            }
        } else {
           System.out.println("Invalid degree");
           System.out.println();
           menu(console,graduates);
        }
    }
    
    /** Prompt the user for a year and list all graduates with that year as shown above
    *@param Scanner console
    *@param array graduates 
    */
    public static void listByYear(Scanner console, Graduate[] graduates) {
        System.out.print("Enter graduation year (1960-2020): ");
        int choice = console.nextInt();
        if (choice>=1960 && choice<=2020) {
            System.out.println("Graduates with graduation date: " + choice);
            int n =graduates.length;
            for (int i=0;i<=n-1;i++) {
                int year = graduates[i].getYear();                
                if (choice==year) {
                    String degree=graduates[i].getDegree();
                    String name=graduates[i].getName();                    
                    System.out.println(degree + "   " + name);
                }
            }
        } else {
           System.out.println("Invalid year");
           System.out.println();
           menu(console,graduates);
        }
    }

}