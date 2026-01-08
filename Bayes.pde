class Bayes {
  String name;
  String filePath;

  ArrayList<HyperParameters> xs = new ArrayList<HyperParameters>();
  ArrayList<Float> ys = new ArrayList<Float>();

  HyperParameters bestHP;

  float fBest;

  float h = 2;
  int numOfCandidate = 32768;
  float overfittingImportance = 0.3;

  int trainingRep = 1;
  int testingRep = 1;

  private boolean isLoaded = false;
  public int etalonnedTime = 0;
  final private LetterDataset ds = new LetterDataset(5*session.w, 5*session.h);
  Matrix[][] globalTrainingData, globalTestingData;

  //c
  Bayes(String n) {
    this.name = n;
    this.filePath = sketchPath() + "/Bayes/" + n + ".by";

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
    globalTrainingData = ds.CreateSample(
        cs.GetChars(),
        handTrainingDatas,
        fontTrainingDatas,
        trainingRep, 1);
    globalTestingData = ds.CreateSample(
        cs.GetChars(),
        handTestingDatas,
        fontTestingDatas,
        testingRep, 1);
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
  public void SERV_Export(HyperParameters hp, float score) {
    JSONObject output = new JSONObject();

    output.setJSONObject("HyperParameters", hp.toJSON());
    output.setFloat("Score", (float)score);

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

  //f Kernel
  // Calcule la "covariance" entre _hp1_ et _hp2_
  public float Kernel(HyperParameters hp1, HyperParameters hp2) {
    float norm = 0;
    float[] list1 = hp1.ToArray();
    float[] list2 = hp2.ToArray();
    for(int i = 0; i < list1.length; i++)
      norm += list2[i] - list1[i];
    return (float)(Math.exp(- 0.5 * Math.pow(norm / h, 2)) / (h * Math.sqrt(2 * Math.PI)));
  }

  //f Cherche le candidat ayant potentiellement le meilleur résultat
  public HyperParameters FindCandidate() {
    Matrix K = new Matrix(xs.size());
    for(int i = 0; i < xs.size(); i++)
      for(int j = 0; j < xs.size(); j++)
        K.Set(i, j, Kernel(xs.get(i), xs.get(j)));

    Matrix KInv = K.Inversed();

    Matrix Y = new Matrix(this.ys.size(), 1);
    for(int i = 0; i < this.ys.size(); i++) Y.Set(i, 0, this.ys.get(i));

    HyperParameters[] params = new HyperParameters[numOfCandidate];
    float[] EIs = new float[numOfCandidate];

    for (int cIdx = 0; cIdx < numOfCandidate; cIdx++) {
      params[cIdx] = new HyperParameters().Random();

      Matrix Kstar = new Matrix(xs.size(), 1);
      for(int i = 0; i < xs.size(); i++) Kstar.Set(i, 0, Kernel(params[cIdx], xs.get(i)));
      float Kstarstar = Kernel(params[cIdx], params[cIdx]);

      float mu = Kstar.T().Mult(KInv).Mult(Y).Get(0,0);
      float sigma = sqrt(Kstarstar - Kstar.T().Mult(KInv).Mult(Kstar).Get(0,0));

      float Z = (fBest - mu) / sigma;
      EIs[cIdx] = (fBest - mu) * CNDF(Z) + sigma * NDF(Z); // Peut-être qu'il y a un moins
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
  public void RandomFill(int numSamples, int numOfEtalon) {
    if (!isLoaded) LoadImageData();
    cl.pln("Bayes random fill start - Time per candidate : " + String.format("%7.3f", (float)(numOfEtalon * this.etalonnedTime) / 1000));

    for (int i = 0; i < numSamples; i++) {
      cl.pln("\nCandidate n°", String.format("%04d", i + 1), "/", String.format("%04d", numSamples));

      HyperParameters hp = new HyperParameters().Random();
      cl.pln(hp.toString());

      float loss = Evaluate(hp, globalTrainingData, globalTestingData, numOfEtalon * this.etalonnedTime);
      xs.add(hp);
      ys.add(loss);

      cl.pln("Score", String.format("%7.3f", loss));


      this.SERV_Export(hp, loss);
    }

    cl.pln("Bayes random fill end");
  }

  //f Effectue le processus Gaussien de recherche de meilleur candidat
  // Effectué _iter_ fois
  // On limite le temps de recherche par candidat à un multiple _numOfEtalon_
  // du temps de création des datasets
  public float GaussianProcess(int iter, int numOfEtalon) {
    if (!isLoaded) LoadImageData();

    cl.pln("Bayes gaussian process start - Time per candidate : " + String.format("%7.3f", (float)(numOfEtalon * this.etalonnedTime) / 1000));
    for(int i = 0; i < iter; i++) {
      cl.pln("\nCandidate n°", String.format("%04d", i + 1), "/", String.format("%04d", iter));

      this.SERV_Import();

      HyperParameters candidate = new HyperParameters();
      if(xs.size() == 0) candidate = new HyperParameters().Random();
      else candidate = FindCandidate();

      cl.pln(candidate.toString());

      float loss = Evaluate(candidate, globalTrainingData, globalTestingData, numOfEtalon * this.etalonnedTime);

      cl.pln("Score", String.format("%7.3f", loss));

      xs.add(candidate);
      ys.add(loss);

      MinLoss();
      this.SERV_Export(candidate, loss);
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
  public float Evaluate(HyperParameters hp, Matrix[][] trainSet, Matrix[][] testSet, int time) {
    int startTime = millis();

    int[] layers = new int[hp.layerSize.length + 2];
    layers[0] = session.w * session.h;
    for(int k = 0; k < hp.layerSize.length; k++) layers[k+1] = hp.layerSize[k];
    layers[hp.layerSize.length + 1] = cs.NumChars();
    
    CNN nn = new CNN(session.w, hp.cNumFilters, layers);
    nn.lambda = hp.lambda * hp.batchSize;
    nn.UseSoftMax();
    nn.useADAM = true;
    nn.b1 = hp.b1;
    nn.b2 = hp.b2;

    graphApplet.ClearGraph();

    float trainLoss = 1;
    float testLoss = 1;

    int iterNum = 0;
    while (millis() < startTime + time) {
      float lr = CyclicalLearningRate(iterNum, hp.minLR, hp.maxLR, hp.period);
      trainLoss = nn.MiniBatchLearn(trainSet, 1, hp.batchSize, lr, lr, 1, new Matrix[0][][], String.format("%05d", iterNum + 1));

      cl.pln("Candidate Remaining Time", String.format("%7.3f", (float)(time - millis() + startTime) / 1000));

      iterNum++;
    }

    testLoss = nn.ComputeLoss(nn.Predict(testSet[0]), testSet[1][0]);

    float accuracy = Average(session.AccuracyScore(nn, testSet, false));

    cl.pln("Training loss", String.format("%8.6f", trainLoss), "\t|\tTesting loss", String.format("%8.6f", testLoss));
    cl.pln("Accuracy", String.format("%6.4f", accuracy));

    // Puissance pour éviter d'avoir un écart en log, permettant d'augmenter l'écart type ie l'exploration
    return testLoss  * pow(testLoss / trainLoss, overfittingImportance) / accuracy / 100;
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
