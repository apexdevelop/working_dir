/**
 * A RationalNumber Class
 * @author Yan Chen
 */
public class RationalNumber {

    /** numerator */
    private int numerator;
  
    /** denominator */ 
    private int denominator;
    
    
    /** Constructs a new rational number to represent the ratio (numerator/denominator).
     * @param numerator numerator
     * @param denominator denominator
     * @throws IllegalArgumentException if denominator is 0.
     */
    public RationalNumber(int numerator, int denominator) {
        if (denominator == 0) {
            throw new IllegalArgumentException("denominator is 0");
        }
        this.numerator=numerator;
        this.denominator=denominator;
        reduce();
    }
    
    /** Constructs a new rational number to represent the ratio (0/1). */
    public RationalNumber() {
        this.numerator=0;
        this.denominator=1;
        reduce();
    }
    
    /**
    * Returns this rational number’s denominator value; for example, if the ratio is (3/5), returns 5.
    */
    public int getDenominator() {
        return denominator;
    }
    
    /**
    * Returns this rational number’s nominator value; for example, if the ratio is (3/5), returns 3.
    */
    public int getNumerator() {
        return numerator;
    }
    
    /** Returns a String representation of this rational number, such as "3/5". 
    * You may wish to omit denominators of 1, returning "4" instead of "4/1".
    */
    public String toString() {
        if (denominator ==1) {
            return numerator + "";
        } else {
            return numerator+ "/" + denominator;
        }
    }
    
    /** Equals method */       
    public boolean equals(Object other){
        if (other instanceof RationalNumber) {
            RationalNumber ration = (RationalNumber) other;
            double ratio1= (double) numerator / denominator;
            double ratio2= (double) ration.getNumerator() / ration.getDenominator();
            if (ratio1 == ratio2){
                return true;
            } else {
               return false;
            }
        } else {
            return false;
        }
    }
    
    /** Rational Addition */         
    public RationalNumber add(RationalNumber other){
        int greatdenom = other.denominator * denominator;       
        int multx = greatdenom / other.denominator;
        int mult = greatdenom / denominator;
        int denom;
        int numer;
        denom = other.denominator * denominator;
        numer = (other.numerator * multx) + (numerator * mult);
        reduce();
        RationalNumber ration = new RationalNumber(numer,denom);
        return ration;
    }

    /** Rational Subtraction  */
    public RationalNumber subtract(RationalNumber other){
        int greatdenom = other.denominator * denominator;    
        int multx = greatdenom / other.denominator;        
        int mult = greatdenom / denominator;
        int denom;
        int numer;
        denom = other.denominator * denominator;
        numer = (numerator * mult) - (other.numerator * multx);
        reduce();
        RationalNumber ration = new RationalNumber(numer,denom);
        return ration;
    }

    /** Multiplication  */     
    public RationalNumber multiply(RationalNumber other){
        int denom;
        int numer;
        numer = numerator * other.numerator;
        denom = denominator* other.denominator;
        reduce();
        RationalNumber ration = new RationalNumber(numer,denom);
        return ration;
    }

    /** Division */       
    public RationalNumber divide(RationalNumber other){
        int numer = numerator * other.denominator;
        int denom = denominator * other.numerator;
        reduce();
        RationalNumber ration = new RationalNumber(numer,denom);
        return ration;
    }
    
    
    /** Fraction simplifier */        
    private void reduce(){
        //Find greatest common divisor
        int r = 1;
        int y = denominator;
        int x = numerator;
        while (y != 0) {
           r = x % y;
           x = y;
           y = r;
        }
        //r=x;
        numerator = numerator / Math.abs(x);
        denominator = denominator / Math.abs(x);
    }
}
  
  