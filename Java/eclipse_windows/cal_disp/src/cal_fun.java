public class cal_fun {    
	public static void main(String[] args)
    {
        ReadArray read_arr = new ReadArray();
		String[][] s = read_arr.read_data();
    	calculate(s);
    }
    
    
    public static void calculate(String[][] s)
    {
        
        int nRow = s.length;
        int nCol = s[0].length;
    	
        double[][] numbers = new double[nRow][nCol];

        double[] sums = new double[nCol];
        double[] avgs = new double[nCol];
        
        for (int i=0;i<nRow;i++) {
        	for (int j = 0; j<nCol; j++) {
                	if (s[i][j].contentEquals("NaN")) {
                		numbers[i][j] =0.00;
                	} else {
                		numbers[i][j] = Double.parseDouble(s[i][j]);
                	}
                    sums[j]+=numbers[i][j];
        	}
        }                

        for (int i=0;i<nCol;i++) {
            avgs[i] = sums[i] /nRow;
            System.out.format("Col %d : %.2f%n",i,avgs[i]);
        }
    }
	
}