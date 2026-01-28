class Bayes {
  String name;
  String filePath;

  ArrayList<HyperParameters> xs = new ArrayList<HyperParameters>();
  ArrayList<Float> ys = new ArrayList<Float>();

  HyperParameters bestHP;

  float fBest;

  float[] h;
  int numOfCandidate = 32768;
  float overfittingImportance = 0.3;

  int trainingRep = 12;
  int testingRep = 5;
  
  boolean doCNNBayes = false;
  boolean[] parametersForNN;

  private boolean isLoaded = false;
  public int etalonnedTime = 0;
  final private LetterDataset ds = new LetterDataset(5*session.w, 5*session.h);
  Matrix[][] globalCNNTrainingData, globalCNNTestingData;
  Matrix[] globalTrainingData, globalTestingData;

  //c
  Bayes(String n) {
    this.name = n;
    this.filePath = sketchPath() + "/Bayes/" + n + ".by";
    
    h = new HyperParameters().GetH();
    parametersForNN = new HyperParameters().ParametersForNN();

	/*
    File f = dataFile(filePath);
    if(f.isFile()) {
      this.Import(filePath);
    }
    */

    this.SERV_Import();
  }

  //f Charge les images (test et train) à utiliser pendant l'optimisation
  private void LoadImageData() {
    int startTime = millis();
    globalCNNTrainingData = ds.CreateSample(
        cs.GetChars(),
        //handTrainingDatas,
        new String[]{},
        fontTrainingDatas,
        trainingRep, 1);
    globalCNNTestingData = ds.CreateSample(
        cs.GetChars(),
        //handTestingDatas,
        new String[]{},
        fontTestingDatas,
        testingRep, 1);
    
    globalTrainingData = ds.SampleLining(this.globalCNNTrainingData);
    globalTestingData = ds.SampleLining(this.globalCNNTestingData);
        
    isLoaded = true;
    etalonnedTime = millis() - startTime;
  }

  //f Exporte le Bayes _this_ dans le fichier _name_
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
    ys = new ArrayList<Float>();

    for(int i = 0; i < size; i++) {
      xs.add(new HyperParameters().FromArray(xMatrix.ColumnToArray(i)));
      ys.add(yMatrix.Get(0, i));
    }

    MinLoss();

    return this;
  }

  //f Exporte l'hyperparamètre _hp_, associé à son score _score_
  public void SERV_Export(HyperParameters hp, float loss, float acc) {
    JSONObject output = new JSONObject();

    output.setJSONObject("HyperParameters", hp.toJSON());
    output.setFloat("Score", (float)loss);
    output.setFloat("Accuracy", (float)acc);

    db.PostData("Bayes/" + this.name, output);
  }

  //f Importe l'ensemble du dataset
  public Bayes SERV_Import() {
    JSONArray candidates = db.GetData("Bayes/" + this.name);
    if(candidates.size() == 0) return this;

    this.xs = new ArrayList<HyperParameters>();
    this.ys = new ArrayList<Float>();

    for(int k = 0; k < candidates.size(); k++) {
      JSONObject obj = candidates.getJSONObject(k);
      this.xs.add(new HyperParameters().FromJSON(obj.getJSONObject("HyperParameters")));
      this.ys.add((float)obj.getFloat("Score"));
    }

    MinLoss();

    return this;
  }
  
  //f Trouver le meilleur résultat
  public HyperParameters SERV_GetBest() {
    JSONArray candidates = db.GetData("Bayes/" + this.name);
    if(candidates.size() == 0) return null;
    
    HyperParameters bestAccParams = new HyperParameters();
    HyperParameters bestLossParams = new HyperParameters();
    float bestAcc = 0;
    float bestLoss = 1000;
    float averageLoss = 0;
    float averageAcc = 0;

    for(int k = 0; k < candidates.size(); k++) {
      JSONObject obj = candidates.getJSONObject(k);
      
      float acc = (float)obj.getFloat("Accuracy");
      float loss = (float)obj.getFloat("Score");
      
      averageLoss += loss;
      averageAcc += acc;
      
      if(acc > bestAcc) {
        bestAcc = acc;
        bestAccParams = new HyperParameters().FromJSON(obj.getJSONObject("HyperParameters"));
      }
      
      if(loss < bestLoss) {
        bestLoss = loss;
        bestLossParams = new HyperParameters().FromJSON(obj.getJSONObject("HyperParameters"));
      }
    }

    averageAcc /= candidates.size();
    averageLoss /= candidates.size();
    
    cl.pln("Best Loss " + String.format("%6.3f", bestLoss) + " | Best Accuracy " + String.format("%6.3f", bestAcc));
    cl.pln("Average Loss " + String.format("%6.3f", averageLoss) + " | Average Accuracy " + String.format("%6.3f", averageAcc));
    
    println("Best Accuracy Parameters");
    println(bestAccParams);
    
    println("Best Loss Parameters");
    println(bestLossParams);

    return bestLossParams;
  }

  //f Kernel
  // Calcule la "covariance" entre _hp1_ et _hp2_
  public float Kernel(HyperParameters hp1, HyperParameters hp2) {
    float penalty = 0.5;
    float cPenalty = 0.5;
    
    float norm = 0;
    float[] list1 = hp1.ToArray();
    float[] list2 = hp2.ToArray();
    for(int i = 0; i < 7; i++)
      if(this.doCNNBayes || this.parametersForNN[i]) norm += Math.pow((list2[i] - list1[i]) / this.h[i], 2);
      
    //Pénalité à appliquer pour les différences de couches
    int minLayers = Math.min(hp1.layerSize.length, hp2.layerSize.length);
    int maxLayers = Math.max(hp1.layerSize.length, hp2.layerSize.length);
    
    for(int k = 0; k < minLayers; k++) {
        float logSize1 = (float)Math.log(hp1.layerSize[k]);
        float logSize2 = (float)Math.log(hp2.layerSize[k]);
        norm += (float)Math.pow((logSize2 - logSize1) / this.h[7+k],2);
    }
    norm += (float)Math.pow((maxLayers - minLayers) * penalty, 2);
    
    if(!this.doCNNBayes) return (float)Math.exp(- 0.5 * norm);
    
    int cMinLayers = Math.min(hp1.cNumFilters.length, hp2.cNumFilters.length);
    int cMaxLayers = Math.max(hp1.cNumFilters.length, hp2.cNumFilters.length);
    
    for(int k = 0; k < cMinLayers; k++) {
        float logSize1 = (float)Math.log(hp1.cNumFilters[k]);
        float logSize2 = (float)Math.log(hp2.cNumFilters[k]);
        norm += (float)Math.pow((logSize2 - logSize1) / this.h[7 + hp1.maxNumberOfLayers +k], 2);
    }
    norm += (float)Math.pow((cMaxLayers - cMinLayers) * cPenalty, 2);
    
    return (float)Math.exp(- 0.5 * norm);
  }

  //f Cherche le candidat ayant potentiellement le meilleur résultat
  public HyperParameters FindCandidate() {
    //Normaliser Y
    float meanY = 0;
    for (float y : ys) meanY += y;
    meanY /= ys.size();
    
    float stdY = 0;
    for (float y : ys) stdY += (y - meanY) * (y - meanY);
    stdY = (float)Math.sqrt(stdY / Math.max(ys.size() - 1, 1));
    if (stdY < 1e-6) stdY = 1.0f;
    
    float fBest_norm = (fBest - meanY) / stdY;
    
    Matrix K = new Matrix(xs.size());
    float noise = 0.01;
    
    for(int i = 0; i < xs.size(); i++)
      for(int j = 0; j < xs.size(); j++)
        // On rajoute du bruit d'observation pour limiter le risque d'avoir une matrice non inversible (ou peu de déterminant très faible)
        K.Set(i, j, Kernel(xs.get(i), xs.get(j)) + (i == j ? noise : 0));

    Matrix KInv = K.Inversed();

    Matrix Y = new Matrix(this.ys.size(), 1);
    for(int i = 0; i < this.ys.size(); i++) Y.Set(i, 0, (this.ys.get(i) - meanY) / stdY);

    HyperParameters[] params = new HyperParameters[numOfCandidate];
    float[] EIs = new float[numOfCandidate];

    for (int cIdx = 0; cIdx < numOfCandidate; cIdx++) {
      params[cIdx] = new HyperParameters().Random();

      Matrix Kstar = new Matrix(xs.size(), 1);
      for(int i = 0; i < xs.size(); i++) Kstar.Set(i, 0, Kernel(params[cIdx], xs.get(i)));
      float Kstarstar = Kernel(params[cIdx], params[cIdx]) + noise;


      float mu = Kstar.T().Mult(KInv).Mult(Y).Get(0,0);
      float sigma = sqrt(Kstarstar - Kstar.T().Mult(KInv).Mult(Kstar).Get(0,0));
      
      if(sigma > 0) {
        float Z = (fBest_norm - mu) / sigma;
        EIs[cIdx] = (fBest_norm - mu) * CNDF(Z) + sigma * NDF(Z);
      } else {
        EIs[cIdx] = 0;
      }
      
      /*
      System.out.printf("Cand %d: Kstar max=%.6f, min=%.6f, mu=%.6f, sigma=%.6f, EI=%.6f%n",
                 cIdx, 
                 max(Kstar.ColumnToArray(0)), min(Kstar.ColumnToArray(0)), 
                 mu, sigma, EIs[cIdx]);
                 */
    }

    float max = EIs[0];
    int maxIdx = 0;
    for(int cIdx = 0; cIdx < numOfCandidate; cIdx++) {
      if(EIs[cIdx] > max) {
        max = EIs[cIdx];
        maxIdx = cIdx;
      }
    }

    cl.pln("Maximum EI", String.format("%9.3E", max));

    return params[maxIdx];
  }

  //f Ajoute _numSamples_ données à la database (pour initialiser Bayes)
  // On limite le temps de recherche par hyperparamètres à un multiple _numOfEtalon_
  // du temps de création des datasets
  public void RandomFill(int numSamples, float numOfEtalon) {
    if (!isLoaded) LoadImageData();
    cl.pln("Bayes random fill start - Time per candidate : " + String.format("%7.3f", (float)(numOfEtalon * this.etalonnedTime) / 1000));

    for (int i = 0; i < numSamples; i++) {
      cl.pln("\nCandidate n°", String.format("%04d", i + 1), "/", String.format("%04d", numSamples));

      HyperParameters hp = new HyperParameters().Random();
      cl.pln(hp.toString());

      float[] scores = Evaluate(hp, globalTrainingData, globalTestingData, globalCNNTrainingData, globalCNNTestingData, numOfEtalon * this.etalonnedTime);
      float loss = scores[0];
      float acc = scores[1];
      xs.add(hp);
      ys.add(loss);

      cl.pln("Loss", String.format("%7.3f", loss), "| Accuracy :", String.format("%7.3f", acc));


      this.SERV_Export(hp, loss, acc);
    }

    cl.pln("Bayes random fill end");
  }

  //f Effectue le processus Gaussien de recherche de meilleur candidat
  // Effectué _iter_ fois
  // On limite le temps de recherche par candidat à un multiple _numOfEtalon_
  // du temps de création des datasets
  public float GaussianProcess(int iter, float numOfEtalon) {
    if (!isLoaded) LoadImageData();

    cl.pln("Bayes gaussian process start - Time per candidate : " + String.format("%7.3f", (float)(numOfEtalon * this.etalonnedTime) / 1000));
    for(int i = 0; i < iter; i++) {
      cl.pln("\nCandidate n°", String.format("%04d", i + 1), "/", String.format("%04d", iter));

      this.SERV_Import();

      HyperParameters candidate = new HyperParameters();
      if(xs.size() == 0) candidate = new HyperParameters().Random();
      else candidate = FindCandidate();

      cl.pln(candidate.toString());

      float[] scores = Evaluate(candidate, globalTrainingData, globalTestingData, globalCNNTrainingData, globalCNNTestingData, numOfEtalon * this.etalonnedTime);
      float loss = scores[0];
      float acc = scores[1];

      cl.pln("Loss", String.format("%7.3f", loss), "| Accuracy :", String.format("%7.3f", acc));

      xs.add(candidate);
      ys.add(loss);

      MinLoss();
      this.SERV_Export(candidate, loss, acc);
    }

    cl.pln("Bayes gaussian process end");
    return fBest;
  }

  //f Trouve le meilleur candidat dans la liste proposée
  public HyperParameters MinLoss() {
    float minLoss = ys.get(0);
    for(int i = 1; i < xs.size(); i++) {
      if(ys.get(i) < minLoss) {
        minLoss = ys.get(i);
        bestHP = xs.get(i);
      }
    }

    fBest = minLoss;
    cl.pln("Best Score", String.format("%7.4f", fBest));
    return bestHP;
  }

  //f Permet d'évaluer la force d'une combinaison d'hyperparamètres
  public float[] Evaluate(HyperParameters hp, Matrix[] trainSet, Matrix[] testSet, Matrix[][] trainCNNSet, Matrix[][] testCNNSet, float time) {
    int startTime = millis();

    int[] layers = new int[hp.layerSize.length + 2];
    layers[0] = session.w * session.h;
    for(int k = 0; k < hp.layerSize.length; k++) layers[k+1] = hp.layerSize[k];
    layers[hp.layerSize.length + 1] = cs.NumChars();
    
    CNN cnn = new CNN(session.w, hp.cNumFilters, layers);
    cnn.lambda = hp.lambda * hp.batchSize;
    cnn.UseSoftMax();
    cnn.useADAM = true;
    cnn.b1 = hp.b1;
    cnn.b2 = hp.b2;
    
    NeuralNetwork nn = new NeuralNetwork(layers);
    nn.lambda = hp.lambda * hp.batchSize;
    nn.UseSoftMax();

    graphApplet.ClearGraph();

    float trainLoss = 1;
    float testLoss = 1;

    int iterNum = 0;
    while (millis() < startTime + time) {
      float lr = CyclicalLearningRate(iterNum, hp.minLR, hp.maxLR, hp.period);
      if(this.doCNNBayes) {
        trainLoss = cnn.MiniBatchLearn(trainCNNSet, 1, hp.batchSize, lr, lr, 1, new Matrix[0][][], String.format("%05d", iterNum + 1));
      } else {
        trainLoss = nn.MiniBatchLearn(trainSet, 1, hp.batchSize, lr, lr, 1, new Matrix[0][], String.format("%05d", iterNum + 1));
      }

      cl.pln("Candidate Remaining Time", String.format("%7.3f", (float)(time - millis() + startTime) / 1000));

      iterNum++;
    }
    
    
    float accuracy = 0;
    
    if(this.doCNNBayes) {
      testLoss = cnn.ComputeLoss(cnn.Predict(testCNNSet[0]), testCNNSet[1][0]);
      trainLoss = cnn.ComputeLoss(cnn.Predict(trainCNNSet[0]), trainCNNSet[1][0]);
      accuracy = Average(session.AccuracyScore(cnn, testCNNSet, false));
    } else {
      testLoss = nn.ComputeLoss(nn.Predict(testSet[0]), testSet[1]);
      trainLoss = nn.ComputeLoss(nn.Predict(trainSet[0]), trainSet[1]);
      accuracy = Average(session.AccuracyScore(nn, testSet, false));
    }
    

    cl.pln("Training loss", String.format("%8.6f", trainLoss), "\t|\tTesting loss", String.format("%8.6f", testLoss));
    cl.pln("Accuracy", String.format("%6.4f", accuracy));

    return new float[]{testLoss, accuracy};
  }

  //f Piqué sur un site mais on n'a pas enregistré lequel
  // Calcul de la *fonction de répartition cumulative de la distribution normale standard*
  float CNDF(float x) {
    int neg = (x < 0d) ? 1 : 0;
    if ( neg == 1)
        x *= -1d;

    float k = (1f / ( 1f + 0.2316419 * x));
    float y = (((( 1.330274429 * k - 1.821255978) * k + 1.781477937) *
                   k - 0.356563782) * k + 0.319381530) * k;
    y = 1.0 - 0.398942280401 * exp(-0.5 * x * x) * y;

    return (1f - neg) * y + neg * (1f - y);
  }

  //f Calcul de la *Fonction de densité de probabilité de la distribution normale standard*
  float NDF(float x) {
    return exp(- x * x / 2) / sqrt(2 * (float)Math.PI);
  }
}
