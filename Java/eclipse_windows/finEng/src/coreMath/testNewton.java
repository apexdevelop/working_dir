package coreMath;
//import java.lang.*;
public class testNewton extends NewtonRaphson {
    
    @Override
    public double newtonroot(double x){
        double result;
        result = 2 - Math.exp(x);
        return result;
    }
    
    public static void main(String[] args) {
    	NewtonRaphson testD = new testNewton();
    	double precision = 1e-6;
    	int iterations = 10;
    	testD.accuracy(precision,iterations);
        double x = 1;
        testD.newtraph(x);
    }
}