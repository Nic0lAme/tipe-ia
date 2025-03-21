class Bayes {
  ArrayList<HyperParameters> xs = new ArrayList<HyperParameters>();
  ArrayList<Double> ys = new ArrayList<Double>();
  
  HyperParameters bestHP;
  
  double fBest;
  
  double h = 2;
  int numOfCandidate = 2048;
  double overfittingImportance = 0.3;
  
  //c
  Bayes() {
    
  }
  
  //f Exporte le Bayes _this_
  public void Export(String name) {
    Matrix xMatrix = new Matrix(numOfHyperParameters, xs.size());
    Matrix yMatrix = new Matrix(1, ys.size());
    
    for(int i = 0; i < xs.size(); i++) {
      xMatrix.ColumnFromArray(i, xs.get(i).ToArray());
      yMatrix.Set(0, i, ys.get(i));
    }
    
    ArrayList<String> output = new ArrayList<String>();
    output.add(str(xs.size()));
    
    String[] xString = xMatrix.SaveToString();
    for (String s : xString) output.add(s);
    
    String[] yString = yMatrix.SaveToString();
    for (String s : yString) output.add(s);
    
    String[] writedOutput = new String[output.size()];
    saveStrings(name, output.toArray(writedOutput));
  }
  
  //f Importe le Bayes à partir venant de _name_
  public Bayes Import(String name) {
    String[] input = loadStrings(name);
    int size = int(split(input[0], ',')[0]);
   
    String[] xString = new String[numOfHyperParameters];
    for(int i = 1; i < numOfHyperParameters + 1; i++) {
      xString[i - 1] = input[i];
    }
   
    Matrix xMatrix = new Matrix(numOfHyperParameters, size);
    xMatrix.LoadString(xString);
   
   
    String[] yString = new String[1];
    yString[0] = input[numOfHyperParameters + 1];
   
    Matrix yMatrix = new Matrix(1, size);
    yMatrix.LoadString(yString);

    xs = new ArrayList<HyperParameters>();
    ys = new ArrayList<Double>();
   
    for(int i = 0; i < size; i++) {
      xs.add(new HyperParameters().FromArray(xMatrix.ColumnToArray(i)));
      ys.add(yMatrix.Get(0, i));
    }
    
    MinLoss();
    
    return this;
  }
  
  //f Kernel
  // Calcule la "covariance" entre _hp1_ et _hp2_
  public double Kernel(HyperParameters hp1, HyperParameters hp2) {
    double k = 0;
    double[] list1 = hp1.ToArray();
    double[] list2 = hp2.ToArray();
    for(int i = 0; i < list1.length; i++)
      k += Math.exp(- 0.5 * Math.pow((list2[i] - list1[i]) / h, 2)) / (h * Math.sqrt(2 * Math.PI));
    return k / list1.length;
  }
  
  //f Cherche le candidat ayant potentiellement le meilleur résultat
  public HyperParameters FindCandidate() {
    println(fBest);
    Matrix K = new Matrix(xs.size());
    for(int i = 0; i < xs.size(); i++)
      for(int j = 0; j < xs.size(); j++)
        K.Set(i, j, Kernel(xs.get(i), xs.get(j)));
        
    K.Debug();
    println("is inversing...");
    Matrix KInv = K.Inversed();
    println("has been inversed");
        
    Matrix Y = new Matrix(this.ys.size(), 1);
    for(int i = 0; i < this.ys.size(); i++) Y.Set(i, 0, this.ys.get(i));
    
    HyperParameters[] params = new HyperParameters[numOfCandidate];
    double[] EIs = new double[numOfCandidate];
    
    for (int cIdx = 0; cIdx < numOfCandidate; cIdx++) {
      params[cIdx] = new HyperParameters().Random();
      
      Matrix Kstar = new Matrix(xs.size(), 1);
      for(int i = 0; i < xs.size(); i++) Kstar.Set(i, 0, Kernel(params[cIdx], xs.get(i)));
      double Kstarstar = Kernel(params[cIdx], params[cIdx]);
      
      double mu = Kstar.T().Mult(KInv).Mult(Y).Get(0,0);
      double sigma = Math.sqrt(Kstarstar - Kstar.T().Mult(KInv).Mult(Kstar).Get(0,0));
      
      double Z = (fBest - mu) / sigma;
      EIs[cIdx] = (fBest - mu) * CNDF(Z) + sigma * NDF(Z); // Peut-être qu'il y a un moins
    }
    
    double max = EIs[0];
    int maxIdx = 0;
    for(int cIdx = 0; cIdx < numOfCandidate; cIdx++) {
      if(EIs[cIdx] > max) {
        max = EIs[cIdx];
        maxIdx = cIdx;
      }
    }
    
    cl.pln("Maximum EI", String.format("%7.4f", max));
    
    return params[maxIdx];
  }
  
  
  public double GaussianProcess(int iter, int time) {
    LetterDataset ds = new LetterDataset(5*session.w, 5*session.h);
    Matrix[] globalTrainingData = ds.CreateSample(
        allCharacters,
        handTrainingDatas,
        fontTrainingDatas,
        16, 1);
    Matrix[] globalTestingData = ds.CreateSample(
        allCharacters,
        handTestingDatas,
        fontTestingDatas,
        8, 1);
    
    for(int i = 0; i < iter; i++) {
      HyperParameters candidate = new HyperParameters();
      if(xs.size() == 0) candidate = new HyperParameters().Random();
      else candidate = FindCandidate();
      double loss = Evaluate(candidate, globalTrainingData, globalTestingData, time);
      
      cl.pln("Score", String.format("%7.3f", loss));
      
      xs.add(candidate);
      ys.add(loss);
      
      MinLoss();
    }
    
    cl.pln("Bayes process is finished");
    return fBest;
  }
  
  //f Trouve le meilleur candidat dans la liste proposée
  public HyperParameters MinLoss() {
    double minLoss = ys.get(0);
    for(int i = 1; i < xs.size(); i++) {
      if(ys.get(i) < minLoss) {
        minLoss = ys.get(i);
        bestHP = xs.get(i);
      }
    }
    
    fBest = minLoss;
    return bestHP;
  }
  
  //f Permet d'évaluer la force d'une combinaison d'hyperparamètres
  public double Evaluate(HyperParameters hp, Matrix[] trainSet, Matrix[] testSet, int time) {
    int startTime = millis();
    
    println(hp.ToArray());
    
    int[] layers = new int[hp.layerSize.length + 2];
    layers[0] = session.w * session.h;
    for(int k = 0; k < hp.layerSize.length; k++) layers[k+1] = hp.layerSize[k];
    layers[hp.layerSize.length + 1] = allCharacters.length;
    
    NeuralNetwork nn = new NeuralNetwork(layers);
    nn.lambda = hp.lambda * hp.batchSize;
    nn.UseSoftMax();
    
    double trainLoss = 1;
    double testLoss = 1;
    
    int iterNum = 0;
    while(millis() < startTime + 1000 * time) {
      double lr = CyclicalLearningRate(iterNum, hp.minLR, hp.maxLR, hp.period);
      trainLoss = nn.MiniBatchLearn(trainSet, 1, hp.batchSize, lr, lr, 1, new Matrix[0][], String.format("%05d", iterNum + 1));
      
      iterNum++;
    }
    
    testLoss = nn.ComputeLoss(nn.Predict(testSet[0]), testSet[1]);
    
    double accuracy = Average(session.AccuracyScore(nn, testSet, false));
    
    cl.pln("Training loss", String.format("%8.6f", trainLoss), "\t|\tTesting loss", String.format("%8.6f", testLoss));
    cl.pln("Accuracy", String.format("%6.4f", accuracy));
    
    return testLoss  * Math.pow(testLoss / trainLoss, overfittingImportance) / accuracy;
  }
  
  
  //f Piqué sur un site mais on n'a pas enregistré lequel
  // Calcul de la *fonction de répartition cumulative de la distribution normale standard*
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
  
  //f Calcul de la *Fonction de densité de probabilité de la distribution normale standard*
  double NDF(double x) {
    return Math.exp(- x * x / 2) / Math.sqrt(2 * Math.PI);
  }
}
