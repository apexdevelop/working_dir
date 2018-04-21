package coreMath;

public class testBisec extends IntervalBisection {
    
    public testBisec(int iterations, double precisionvalue){
        super(iterations,precisionvalue);
    }
        
    
    @Override
    public double computeFunction(double x){
        double result;
        //result = x*x - 3.0;
        result = 2.0 - Math.exp(x);
        return result;
    }
    
    public static void main(String[] args) {
        IntervalBisection testBi = new testBisec(20,1e-3);
        double a = 0;
        double b = 4;
        testBi.evaluateRoot(a,b);
    }
}