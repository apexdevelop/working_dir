import java.util.Scanner;

/**
 * tell if a triangle is valid and the type of triangle
 * @author Yan Chen
 */
 
 public class Triangle{       
       public static void main(String[] args) {
           // Set up Scanner for console
           Scanner in = new Scanner(System.in);
           // Prompt for entering length of three sides
           System.out.print("Enter length of three sides: ");
           int a = in.nextInt();
           int b = in.nextInt();
           int c = in.nextInt();           
           String type = getTriangleType(a,b,c); 
           System.out.println("The Triangle is " + type);        
       }
       
       /**
        * tell if three sides could form a Triangle
        * @param a
        * @param b
        * @param c
        */
       public static boolean isValidTriangle(int a, int b, int c) {
           boolean isValid;
           if ( a+b<=c || a+c<=b || b+c<=a || a<=0 || b<=0 || c<=0) {
               isValid = false;
           } else {
               isValid = true;
           }
           return isValid;
       }
       
       /**
        * tell the type a Triangle (equilateral, isosceles, scalene)
        * @param a
        * @param b
        * @param c
        */
        
       public static String getTriangleType(int a, int b, int c) {
           boolean isValid = isValidTriangle(a,b,c);
           String type= "";
           if ( isValid == true ) {
               if ( a == b && b == c) {
                   type = "equilateral" ;
               } else if (( a == b && b != c) || ( a == c && b != c) || ( b == c && b != a)) {
                   type = "isosceles" ;
               } else if ( a!=b && b!=c && c!=a) {
                   type = "scalene" ;
               }
           } else {
             type = "invalid" ;
           }
           return type;
       }
 }