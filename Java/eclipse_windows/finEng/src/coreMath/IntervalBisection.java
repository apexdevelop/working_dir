package coreMath;
import java.lang.Math;
import java.util.*;
import java.io.*;

public abstract class IntervalBisection
{
//computeFunction is implemented to evaluate successive root estimates//
    public abstract double computeFunction(double rootvalue);
    protected double precisionvalue;
    protected int iterations;
    protected double lowerBound;
    protected double upperBound;
    
//default constructor//
    protected IntervalBisection()
    {
        iterations=20;
        precisionvalue= 1e-3;
    }
//Constructor with user defined repetitions and precision//
    protected IntervalBisection(int iterations, double precisionvalue)
    {
        this.iterations=iterations;
        this.precisionvalue=precisionvalue;
    }
    public int getiterations()
    {
        return iterations;
    }
    public double getprecisionvalue()
    {
        return precisionvalue;
    }

    public double evaluateRoot(double lower, double higher)
//lower and higher are the initial estimates//
    {
        double fa; //fa and fb are the initial ‘guess’ values.//
        double fb;
        double fc; //fc is the function evaluation , f x //
        double midvalue=0;
        int nIter=0;
        fa=computeFunction(lower); //ComputeFunction is implemented
//by the caller//
        fb=computeFunction(higher);
//Check to see if we have the root within the range bounds//
        if (fa*fb>0) { //If fa?fb>0 then both are either positive//
//or negative and don’t bracket zero.//
            midvalue=0;//Terminate program//
        }
        else{
            do
            {
                nIter+=1;
                midvalue=lower+0.5*(higher-lower);
                fc=computeFunction(midvalue); //Computes the f x //
//for the mid value//
                if(fa*fc<0){
                    higher=midvalue;
                } else {
                    if(fa*fc>0){
                        lower=midvalue;
                    }
                }
                System.out.println("New interval: [" + lower + " .. " + higher + "]");   
                                           // Print progress 
            } while(Math.abs(fc)>precisionvalue && nIter<iterations);
//loops until desired number of iterations or precision is reached//
        }
        System.out.println("Approximate solution = " + midvalue );
        return midvalue;
    }
    
//    public double computeFunction(double x){
//        double result;
//        //result = x*x - 3.0;
//        result = 2.0 - Math.exp(x);
//        return result;
//    }
    
//     public static void main(String[] args)
//    {
//        IntervalBisection testBi = new IntervalBisection();
//        double a = 0;
//        double b = 4;
//        testBi.evaluateRoot(a,b);
//    }
}