class Bayes {
  
  int numOfCandidate;
  ArrayList<HyperParameters> xs = new ArrayList<HyperParameters>();
  ArrayList<Double> ys = new ArrayList<Double>();
  double fBest;
  double h = 2;
  
  //c
  Bayes() {
    
  }
  
  public double Kernel(HyperParameters hp1, HyperParameters hp2) {
    double k = 0;
    double[] list1 = hp1.ToArray();
    double[] list2 = hp2.ToArray();
    for(int i = 0; i < list1.length; i++)
      k += Math.exp(- 0.5 * Math.pow((list2[i] - list1[i]) / h, 2)) / (h * Math.sqrt(2 * Math.PI));
    return k / list1.length;
  }
  
  public HyperParameters FindCandidate() {
    Matrix K = new Matrix(xs.size());
    for(int i = 0; i < xs.size(); i++)
      for(int j = 0; j < xs.size(); j++)
        K.Set(i, j, Kernel(xs.get(i), xs.get(j)));
    Matrix KInv = K.Inversed();
        
    Matrix Y = new Matrix(this.ys.size(), 1);
    for(int i = 0; i < this.ys.size(); i++) Y.Set(i, 0, this.ys.get(i));
    
    HyperParameters[] params = new HyperParameters[numOfCandidate];
    double[] EIs = new double[numOfCandidate];
    
    for (int cIdx = 0; cIdx < numOfCandidate; cIdx++) {
      params[cIdx].Random();
      
      Matrix Kstar = new Matrix(xs.size(), 1);
      for(int i = 0; i < xs.size(); i++) Kstar.Set(i, 0, Kernel(params[cIdx], xs.get(i)));
      double Kstarstar = Kernel(params[cIdx], params[cIdx]);
      
      double mu = Kstar.T().Mult(KInv).Mult(Y).Get(0,0);
      double sigma = Math.sqrt(Kstarstar - Kstar.T().Mult(KInv).Mult(Kstar).Get(0,0));
      
      double Z = (mu - fBest) / sigma;
      EIs[cIdx] = (mu - fBest) * CNDF(Z) + sigma * NDF(Z); // Peut-être qu'il y a un moins
    }
    
    double min = EIs[0];
    int minIdx = 0;
    for(int cIdx = 0; cIdx < numOfCandidate; cIdx++) {
      if(EIs[cIdx] < min) {
        min = EIs[cIdx];
        minIdx = cIdx;
      }
    }
    
    return params[minIdx];
  }
  
  
  public double GaussianProcess(int iter) {
    LetterDataset ds = new LetterDataset(5*session.hp.w, 5*session.hp.h);
    Matrix[] globalTrainingData = ds.CreateSample(
        allCharacters,
        handTrainingDatas,
        fontTrainingDatas,
        20, 1);
    Matrix[] globalTestingData = ds.CreateSample(
        allCharacters,
        handTestingDatas,
        fontTestingDatas,
        6, 1);
    
    for(int i = 0; i < iter; i++) {
      HyperParameters candidate = FindCandidate();
      double loss = Evaluate(candidate);
      
      xs.add(candidate);
      ys.add(loss);
      
      if(loss < fBest) fBest = loss;
    }
    
    return fBest;
  }
  
  
  
  double CNDF(double x) {
    int neg = (x < 0d) ? 1 : 0;
    if ( neg == 1) 
        x *= -1d;
  
    double k = (1d / ( 1d + 0.2316419 * x));
    double y = (((( 1.330274429 * k - 1.821255978) * k + 1.781477937) *
                   k - 0.356563782) * k + 0.319381530) * k;
    y = 1.0 - 0.398942280401 * Math.exp(-0.5 * x * x) * y;
  
    return (1d - neg) * y + neg * (1d - y);
  }
  
  double NDF(double x) {
    return Math.exp(- x * x / 2) / Math.sqrt(2 * Math.PI);
  }
}
