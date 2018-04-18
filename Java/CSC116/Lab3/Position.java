/**
 * calculate Position of an object
 * @author Yan Chen
 */
 
 public class Position{
       
       public static void main(String[] args) {
       double s0 = 12.0;
       double v0 = 3.5;
       double a = 4.3;
       int t = 5;
       double s;
       s = s0 + v0 * t + 0.5 * a * t * t;
       System.out.println("s: " + s);
       }
 }