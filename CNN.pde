class CNN {
   // Paramètres du réseau de neurones simple
  int numLayers; // Nombre de couches
  int[] layers;  // Nombre de neurones par couches
  int entrySize, outputSize;
  Matrix[] weights; // Poids des liaisons (pour un indice i, liaisons entre couche i et couche i+1)
  Matrix[] bias; // Biais (pour un indice i, biais entre couche i et i+1)

  // Paramètre du réseau de convolution
  int cImageSize;
  int cNumLayers;
  float cPool = 2;
  int cFilterSize = 3;
  int[] cNumFilters;
  Matrix[][] cFilters;
  Matrix[] cBias;
  int[] cImageSizes;

  // ADAM Learning Rate Optimization
  boolean useADAM = true;

  Matrix[] ADAMweightsMoment;
  Matrix[] ADAMweightsSqMoment;
  Matrix[] ADAMbiasMoment;
  Matrix[] ADAMbiasSqMoment;

  Matrix[][] cADAMfiltersMoment;
  Matrix[][] cADAMfiltersSqMoment;
  Matrix[] cADAMbiasMoment;
  Matrix[] cADAMbiasSqMoment;

  int numOfLearningCall = 0;
  float b1 = 0.9;
  float b2 = 0.999;
  

  float lambda = 0;

  boolean useSoftMax = false; // Détermine l'utilisation de la fonction softmax sur la dernière couche du réseau

  ExecutorService executor;

  CNN() {
    this(0, new int[]{}, new int[]{});
  }

  //c _sizes_ correspond aux tailles des niveaux
  CNN(int imageSize, int[] cNumFilters, int[] sizes) {
    this.cImageSize = imageSize;

    this.numLayers = sizes.length + 1;
    this.layers = new int[numLayers];
    for (int i = 0; i < numLayers - 1; i++) layers[i+1] = sizes[i];

    this.cNumLayers = cNumFilters.length;
    this.cNumFilters = new int[cNumLayers];
    for (int i = 0; i < cNumLayers; i++) this.cNumFilters[i] = cNumFilters[i];

    executor = Executors.newFixedThreadPool(numThreadsLearning);
    Init();
  }

  public void UseSoftMax() { this.useSoftMax = true; } // Lorsque SoftMax est utilisé, il est nécessaire d'avoir des sorties qui s'additionnent à 1

  private void Init() {
    this.cFilters = new Matrix[cNumLayers][];
    this.cBias = new Matrix[cNumLayers];

    this.cADAMfiltersMoment = new Matrix[cNumLayers][];
    this.cADAMfiltersSqMoment = new Matrix[cNumLayers][];
    this.cADAMbiasMoment = new Matrix[cNumLayers];
    this.cADAMbiasSqMoment = new Matrix[cNumLayers];

    for (int i = 0; i < cNumLayers; i++) {
      this.cFilters[i] = new Matrix[this.cNumFilters[i]];
      this.cADAMfiltersMoment[i] = new Matrix[this.cNumFilters[i]];
      this.cADAMfiltersSqMoment[i] = new Matrix[this.cNumFilters[i]];
    }

    // Calcul de la taille de la première couche du réseau normal
    cImageSizes = new int[cNumLayers + 1];
    cImageSizes[0] = this.cImageSize;
    for(int k = 0; k < cNumLayers; k++) cImageSizes[k+1] = (int)Math.ceil((cImageSizes[k] - this.cFilterSize + 1) / this.cPool);

    layers[0] = cImageSizes[cNumLayers] * cImageSizes[cNumLayers];
    for(int k = 0; k < cNumLayers; k++) layers[0] *= cFilters[k].length;

    entrySize = layers[0];
    outputSize = layers[numLayers-1];


    // Calcul aléatoire d'initialisation des weights et bias du réseau normal
    weights = new Matrix[numLayers-1];
    bias = new Matrix[numLayers-1];

    ADAMweightsMoment = new Matrix[numLayers-1];
    ADAMweightsSqMoment = new Matrix[numLayers-1];
    ADAMbiasMoment = new Matrix[numLayers-1];
    ADAMbiasSqMoment = new Matrix[numLayers-1];

    for (int i = 0; i < numLayers-1; i++) {
      // Normal Xavier Weight Initialization
      bias[i] = new Matrix(layers[i+1], 1).Random(-sqrt(6) / sqrt(layers[i] + layers[i+1]), sqrt(6) / sqrt(layers[i] + layers[i+1]));
      weights[i] = new Matrix(layers[i+1], layers[i]).Random(-sqrt(6) / sqrt(layers[i] + layers[i+1]), sqrt(6) / sqrt(layers[i] + layers[i+1]));

      ADAMweightsMoment[i] = new Matrix(layers[i+1], layers[i]);
      ADAMweightsSqMoment[i] = new Matrix(layers[i+1], layers[i]);
      ADAMbiasMoment[i] = new Matrix(layers[i+1], 1);
      ADAMbiasSqMoment[i] = new Matrix(layers[i+1], 1);
    }
    
    int nin = this.cFilterSize * this.cFilterSize;
    // Calcul aléatoire d'init des filters et bias du CNN
    for (int i = 0; i < cNumLayers; i++) {
      int nout = this.cFilters[i].length;

      for(int f = 0; f < this.cFilters[i].length; f++) {
        // He Kaiming Initialization (for ReLU)
        this.cFilters[i][f] = new Matrix(cFilterSize).RandomGaussian(0, sqrt(2f / nin));
        
        this.cADAMfiltersMoment[i][f] = new Matrix(cFilterSize);
        this.cADAMfiltersSqMoment[i][f] = new Matrix(cFilterSize);
      }
      
      // He Kaiming Initialization (for ReLU)
      cBias[i] = new Matrix(this.cFilters[i].length, 1).RandomGaussian(0, sqrt(2f / nin));
      this.cADAMbiasMoment[i] = new Matrix(this.cFilters[i].length, 1);
      this.cADAMbiasSqMoment[i] = new Matrix(this.cFilters[i].length, 1);
      
      nin *= this.cFilters[i].length;
    }
  }

  //f Sauvegarde les paramètres du réseau de neurones dans _name_
  public void Export(String name) {
    cl.pln("Export begin");
    ArrayList<String> output = new ArrayList<String>();

    // Informations diverses
    output.add(str(cImageSize));
    output.add(str(numLayers));
    output.add(str(cNumLayers));

    // Informations FCL
    output.add("");
    for (int i = 0; i < layers.length; i++) {
      output.set(0, output.get(0) + str(layers[i]) + (i != layers.length - 1 ? "," : ""));
    }

    // Informations CONV
    output.add("");
    for (int i = 0; i < cNumFilters.length; i++) {
      output.set(1, output.get(1) + str(cNumFilters[i]) + (i != cNumFilters.length - 1 ? "," : ""));
    }

    // Stockage FCL (poids puis biais)
    Save1DParam(weights, output);
    Save1DParam(bias, output);
    cl.pln("Export : FCL done");

    // Stockage CONV (poids puis biais)
    Save2DParam(cFilters, output);
    Save1DParam(cBias, output);
    cl.pln("Export : CONV done");

    // Stockage ADAM (FCL puis conv)
    Save1DParam(ADAMweightsMoment, output);
    Save1DParam(ADAMweightsSqMoment, output);
    Save1DParam(ADAMbiasMoment, output);
    Save1DParam(ADAMbiasSqMoment, output);
    Save2DParam(cADAMfiltersMoment, output);
    Save2DParam(cADAMfiltersSqMoment, output);
    Save1DParam(cADAMbiasMoment, output);
    Save1DParam(cADAMbiasSqMoment, output);
    cl.pln("Export : ADAM done");

    String[] writedOutput = new String[output.size()];
    saveStrings(name, output.toArray(writedOutput));
    cl.pln("Export ended");
  }

  //f Importe un réseau de neurones depuis le fichier _name_
  public CNN Import(String name) {
    // à faire :'(

    // Récupère les paramètres (3 premières lignes)
    Init();

    // Remplit les matrices !

    return this;
  }

  private void Save1DParam(Matrix[] param, ArrayList<String> output) {
    for (int i = 0; i < param.length; i++) {
      String[] matrixSave = param[i].SaveToString();
      for (String s : matrixSave) output.add(s);
    }
  }

  private void Save2DParam(Matrix[][] param, ArrayList<String> output) {
    for (int i = 0; i < param.length; i++) {
      for (int j = 0; j < param[i].length; j++) {
        String[] matrixSave = param[i][j].SaveToString();
        for (String s : matrixSave) output.add(s);
      }
    }
  }

  //f Donne la sortie du réseau de neurones _this_ pour l'entrée _entry_
  public Matrix Predict(Matrix[] entries) {
    int size = 128;
    int numOfBatches = ceil((float)entries.length / size);
    Matrix[] ret = new Matrix[numOfBatches];
    for(int b = 0; b < numOfBatches; b++) {
      ret[b] = this.ForwardPropagation(Arrays.copyOfRange(entries, b * size, min((b+1) * size, entries.length)), false)[2][0][0][this.numLayers - 1];
    }
    
    //ret.Debug();
    return new Matrix(0).Concat(ret);
  }

  //f
  public Matrix[][][][] ForwardPropagation(Matrix[] entries, boolean doSavePrevLayers) {
    Matrix[][][] masks = new Matrix[entries.length][this.cNumLayers][];
    Matrix[][][] convVal = new Matrix[entries.length][this.cNumLayers + 1][];

    Matrix convoluted;
    Matrix[] pooled;
    
    int initTime = millis();
      
    Matrix entry = entries[0];
    for(int x = 0; x < entries.length; x++) {
      entry = entries[x];
      if (entry.n != this.cImageSize) {
        println(entry.n, this.cImageSize);
        println("Taille de l'entrée invalide");
        return null;
      }
      
      convVal[x][0] = new Matrix[]{entry};
      for(int k = 0; k < this.cNumLayers; k++) {
        int numOfFilter = this.cFilters[k].length;
        masks[x][k] = new Matrix[convVal[x][k].length * numOfFilter];

        convVal[x][k+1] = new Matrix[convVal[x][k].length * numOfFilter];

        for(int e = 0; e < convVal[x][k].length; e++) {
          for(int f = 0; f < numOfFilter; f++) {
            convoluted = convVal[x][k][e].Convolution(this.cFilters[k][f]).AddScal(this.cBias[k].Get(f, 0));
            //convoluted.Add(new Matrix(convoluted.n).Fill(this.cBias[k].Get(f,0)));

            pooled = convoluted.MaxPooling(2, 2);
            masks[x][k][e * numOfFilter + f] = pooled[1];

            convVal[x][k+1][e * numOfFilter + f] = pooled[0];
          }
        }

        if(!doSavePrevLayers) {
          convVal[x][k] = null;
          masks[x][k] = null;
        }
      }
    }

    int convTime = millis();

    Matrix[] layerVal = new Matrix[this.numLayers];

    int outputArea = convVal[0][this.cNumLayers][0].n * convVal[0][this.cNumLayers][0].p;
    Matrix nnEntry = new Matrix(convVal[0][this.cNumLayers].length * outputArea, entries.length);
    for(int x = 0; x < entries.length; x++) {
      for(int k = 0; k < convVal[x][this.cNumLayers].length; k++) {
        int matN = convVal[x][this.cNumLayers][k].n;
        int matP = convVal[x][this.cNumLayers][k].p;
        for(int i = 0; i < matN; i++) {
          for(int j = 0; j < matP; j++) {
            nnEntry.Set(k * outputArea + i * matP + j, x, convVal[x][this.cNumLayers][k].Get(i, j));
          }
        }
      }
    }
    
    int transitionTime = millis();
    
    //cl.pln("CONV : " + str(convTime - initTime) + " | FCL : " + str(FCLTime - convTime));

    layerVal[0] = nnEntry;
    for(int i = 0; i < this.numLayers - 1; i++) {
      layerVal[i + 1] = CalcLayer(i, layerVal[i]);
      if(!doSavePrevLayers) layerVal[i] = null;
    }
    
    int FCLTime = millis();
    
    println("FORWARD TIME : ", FCLTime - initTime);
    println("Convolution : ", convTime - initTime);
    println("Transition : ", transitionTime - convTime);
    println("FCL : ", FCLTime - transitionTime);

    return new Matrix[][][][]{ convVal, masks, new Matrix[][][]{{layerVal}} }; // :) :)
  }

  //f Calcule la sortie correspondant à l'entrée _in_, de la couche _from_ à la couche _from+1_
  private Matrix CalcLayer(int from, Matrix in) {
    Matrix result = weights[from].GPUMult(in);

    result.Add(bias[from], 1, true);

    if(from == this.numLayers - 2 && this.useSoftMax) {
      float max = result.Get(0,0);
      for(int i = 0; i < result.n; i++)
        for(int j = 0; j < result.p; j++)
          if(result.Get(i,j) > max) max = result.Get(i,j);

      result.Add(new Matrix(result.n, result.p).Fill(-max));

      result.Map((x) -> exp(x));

      result.NormColumn();
      return result;
    }

    result.Map((x) -> sigmoid(x));

    return result;
  }

  int BPFCLTime = 0, BPfirstGradTime = 0, BPmaskTime = 0, BPgradTime = 0, BPnextGTime = 0;


  //f Effectue la rétropropagation du réseau de neurones
  // On prend en entrée les valeurs d'_activations_ des layers
  // On donne les valeurs attendues dans _expectedOutput_
  public Matrix[][][] BackPropagation(Matrix[] activations, Matrix[][][] convActivations, Matrix[][][] masks, Matrix expectedOutput) {

    int inputNumber = convActivations.length;

    //dJ/dZl
    Matrix a = activations[this.numLayers-1].C();
    Matrix gradient = a.C().Add(expectedOutput, -1).HProduct(a.C().HProduct(a.C().AddScal(-1.0).Scale(-1.0)));
    a = null;

    Matrix[] weightGrad = new Matrix[this.numLayers - 1];
    Matrix[] biasGrad = new Matrix[this.numLayers - 1];

    int initTime = millis();

    for(int l = this.numLayers - 2; l >= 0; l--) {

      //dJ/dWl = dJ/dZl * dZl/dWl
      weightGrad[l] = gradient.GPUMult(activations[l].T()).Scale(1/ (float)max(1, expectedOutput.p));

      //dJ/dbl = dJ/dZl * dZl/dbl
      biasGrad[l] = gradient.AvgLine();

      if(lambda != 0) {
        weightGrad[l].Add(weights[l], lambda / max(1, weights[l].n * weights[l].p));
        biasGrad[l].Add(bias[l], lambda / max(1, bias[l].n));
      }

      a = activations[l].C();
      gradient = (weights[l].T().GPUMult(gradient)).HProduct(a.C().Add(a.C().HProduct(a), -1));
      a =  null;
    }

    int FCLTime = millis();

    int areaOfOutput = this.cImageSizes[this.cNumLayers] * this.cImageSizes[this.cNumLayers];
    int numOfImageInOutput = convActivations[0][this.cNumLayers].length;
    assert activations[0].n == areaOfOutput * numOfImageInOutput;

    Matrix[][] cGradient = new Matrix[inputNumber][numOfImageInOutput];
    for(int k = 0; k < numOfImageInOutput; k++) {
      cGradient[0][k] = new Matrix(areaOfOutput, 1);
      for(int i = 0; i < areaOfOutput; i++) cGradient[0][k].values[i * cGradient[0][k].p] = gradient.values[(i + k * areaOfOutput) * gradient.p];
      cGradient[0][k] = cGradient[0][k].FromCol(this.cImageSizes[this.cNumLayers], this.cImageSizes[this.cNumLayers]);
    }

    gradient = null;

    for(int x = 1; x < inputNumber; x++) cGradient[x] = Arrays.copyOf(cGradient[0], cGradient[0].length);

    int firstGradientTime = millis();

    int maskTime = 0, gradTime = 0, nextGTime = 0;

    Matrix[][] cFiltersGrad = new Matrix[this.cNumLayers][];
    Matrix[] cBiasGrad = new Matrix[this.cNumLayers];

    for(int l = 0; l < this.cNumLayers; l++) {
      cBiasGrad[l] = new Matrix(this.cFilters[l].length, 1);
      cFiltersGrad[l] = new Matrix[this.cFilters[l].length];
      for(int f = 0; f < this.cFilters[l].length; f++) cFiltersGrad[l][f] = new Matrix(cFilterSize);
    }

    Matrix[][] cSizedGradient;
    for(int k = this.cNumLayers - 1; k >= 0; k--) {
      int prevLayerOutputSize = cGradient[0].length / this.cFilters[k].length;
      cSizedGradient = new Matrix[inputNumber][cGradient[0].length];
      for(int x = 0; x < inputNumber; x++) {
        int layerTime = millis();


        for(int oImg = 0; oImg < prevLayerOutputSize; oImg++) {
          for(int fImg = 0; fImg < this.cFilters[k].length; fImg++) {
            int g = oImg * this.cFilters[k].length + fImg;
            cSizedGradient[x][g] = new Matrix(convActivations[x][k][0].n - this.cFilterSize + 1);
            for(int i = 0; i < cSizedGradient[x][g].n; i++) {
              for(int j = 0; j < cSizedGradient[x][g].p; j++) {
                cSizedGradient[x][g].Set(i, j, masks[x][k][oImg].Get(i,j) * cGradient[x][g].Get((int)Math.floor((float)i / this.cPool), (int)Math.floor((float)j / this.cPool)));
              }
            }
          }
        }

        int maskFixTime = millis();

        for(int f = 0; f < this.cFilters[k].length; f++) {
          for(int i = 0; i < convActivations[x][k].length; i++) {
            cFiltersGrad[k][f].Add(convActivations[x][k][i].Convolution(cSizedGradient[x][f + i * this.cFilters[k].length]).Scale((float)1/ convActivations[x][k].length / inputNumber));
            cBiasGrad[k].values[f * cBiasGrad[k].p] += cSizedGradient[x][i].TotalSum() / cSizedGradient[x][i].n / cSizedGradient[x][i].p / convActivations[x][k].length / inputNumber;
          }
        }

        int gradFixTime = millis();

        maskTime += maskFixTime - layerTime; gradTime += gradFixTime - maskFixTime;

      }

      /*
      cl.pln("Layer " + str(k));
      cFiltersGrad[k][0].Debug();
      cBiasGrad[k].Debug();
      */

      if (k==0) continue; // Pas besoin de calculer le gradient suivant (et surtout ça ne peut pas)
      int beforeNextG = millis();


      final int filterN = this.cFilterSize;
      final int filterP = this.cFilterSize;
      final int filterArea = this.cFilterSize * this.cFilterSize;
      final int numOfFilters = this.cFilters[k].length;

      float[] rotatedFiltersFlat = new float[numOfFilters * filterArea];
      for(int f = 0; f < this.cFilters[k].length; f++)
        for(int i = 0; i < filterArea; i++)
          rotatedFiltersFlat[filterArea * f + (filterArea - i - 1)] = this.cFilters[k][f].values[i];

      final int gradientN = cSizedGradient[0][0].n;
      final int gradientP = cSizedGradient[0][0].p;
      final int gradientArea = gradientN * gradientP;
      final int gradientNumber = cSizedGradient[0].length;
      final int inputArea = gradientNumber * gradientArea;

      float[] cGradientFlat = new float[inputArea * inputNumber];
      for(int x = 0; x < inputNumber; x++)
        for(int p = 0; p < gradientNumber; p++)
          for(int i = 0; i < gradientArea; i++)
            cGradientFlat[x * inputArea + p * gradientArea + i] = cSizedGradient[x][p].values[i];


      final int outN = cImageSizes[k];
      final int outP = cImageSizes[k];
      float[] output = new float[inputNumber * prevLayerOutputSize * outN * outP];
      
      nextGradKernel.SetData(filterN, filterP, filterArea, numOfFilters, rotatedFiltersFlat, gradientN, gradientP, gradientArea, gradientNumber, inputArea, cGradientFlat, outN, outP, output);
      nextGradKernel.execute(Range.create(inputNumber * prevLayerOutputSize));

      for(int x = 0; x < inputNumber; x++) {
        cGradient[x] = new Matrix[prevLayerOutputSize];
        for(int p = 0; p < prevLayerOutputSize; p++) {
          cGradient[x][p] = new Matrix(cImageSizes[k]);
          for(int i = 0; i < outN; i++)
            for(int j = 0; j < outP; j++)
              cGradient[x][p].values[i * outP + j] = output[x * prevLayerOutputSize * (outN * outP) + p * (outN * outP) + i * outP + j];
        }
      }

      /* ANCIENNE VERSION POUR COMPRENDRE CE QU'IL SE PASSE AU DESSUS
      for(int x = 0; x < inputNumber; x++) {
        Matrix[] nextCGrad = new Matrix[prevLayerOutputSize];
        for(int p = 0; p < prevLayerOutputSize; p++) {
          nextCGrad[p] = new Matrix(cImageSizes[k]);
          for(int f = 0; f < this.cFilters[k].length; f++) {
            nextCGrad[p].Add(this.cFilters[k][f].Rotate180().FullConvolution(cSizedGradient[x][p * this.cFilters[k].length + f]));
          }
        }

        cGradient[x] = nextCGrad;
      }
      */

      nextGTime += millis() - beforeNextG;
    }

    BPFCLTime += FCLTime - initTime;
    BPfirstGradTime += firstGradientTime - FCLTime;
    BPmaskTime += maskTime;
    BPgradTime += gradTime;
    BPnextGTime += nextGTime;

    cGradient = null;

    return new Matrix[][][]{new Matrix[][]{weightGrad}, new Matrix[][]{biasGrad}, cFiltersGrad, new Matrix[][]{cBiasGrad}};
  }

  //f Effectue une étape d'apprentissage, ayant pour entrée _X_ et pour sortie _Y_
  // Le taux d'apprentissage est _learning\_rate_
  public float Learn(Matrix[] X, Matrix Y, float learning_rate) {
    this.numOfLearningCall++;

    BPFCLTime = 0; BPfirstGradTime = 0; BPmaskTime = 0; BPgradTime = 0; BPnextGTime = 0; convolutionTime = 0;

    int initTime = millis();
    int forwardTime = 0, backwardTime = 0;

    // Activation de la dernière couche
    Matrix S = new Matrix(Y.n, X.length);

    Matrix[] weightGrad = new Matrix[this.numLayers - 1];
    Matrix[] biasGrad = new Matrix[this.numLayers - 1];
    Matrix[][] cFiltersGrad = new Matrix[this.cFilters.length][];
    for(int i = 0; i < this.cFilters.length; i++)
      cFiltersGrad[i] = new Matrix[this.cFilters[i].length];
    Matrix[] cBiasGrad = new Matrix[this.cFilters.length];

    // Sans multithreading, back propagation classique
    if (numThreadsLearning <= 1) {
      int startKTime = millis();
      Matrix[][][][] activations = ForwardPropagation(X, true);
      forwardTime += (float)(millis() - startKTime);

      S = activations[2][0][0][this.numLayers - 1].C();

      int startKTimeBis = millis();
      Matrix[][][] gradients = BackPropagation(activations[2][0][0], activations[0], activations[1], Y);
      backwardTime += millis() - startKTimeBis;

      activations = null;

      weightGrad = gradients[0][0];
      biasGrad = gradients[1][0];
      cFiltersGrad = gradients[2];
      cBiasGrad = gradients[3][0];
    }

    // Avec multithreading : le batch est divisé en numThreadsLearning sous-batchs, la
    // back propagation est effectuée sur chaque sous-batchs, et les résultats sont moyennés
    else {
      ArrayList<Callable<Object>> tasks = new ArrayList<Callable<Object>>();

      Matrix[][] slicedTrainingDatas = new Matrix[numThreadsLearning][];
      int size = X.length / numThreadsLearning;
      for(int k = 0; k < numThreadsLearning; k++) {
        // Formule du split égale à Matrix.Split()
        slicedTrainingDatas[k] = Arrays.copyOfRange(X, k*size, k < numThreadsLearning - 1 ? constrain(k*size + size, 0, X.length) : X.length);
      }
      final Matrix[][] trainingData = slicedTrainingDatas;
      final Matrix[] answers = Y.Split(numThreadsLearning);

      final int numOfLayers = this.numLayers;
      final Matrix[][] finalCFilters = this.cFilters;

      // Gradients calculés, par sous-batch et par couche
      // TODO: remplacer les arraylist par des arrays pour éviter erreurs et conversions
      ArrayList<Matrix[]> weightsGradients = new ArrayList<Matrix[]>(numThreadsLearning);
      ArrayList<Matrix[]> biasGradients = new ArrayList<Matrix[]>(numThreadsLearning);
      ArrayList<Matrix[][]> cFiltersGradients = new ArrayList<Matrix[][]>(numThreadsLearning);
      ArrayList<Matrix[]> cBiasGradients = new ArrayList<Matrix[]>(numThreadsLearning);
      final Matrix[] partialS = new Matrix[numThreadsLearning];
      Object syncObject = new Object();

      for (int i = 0; i < numThreadsLearning; i++) {
        final int index = i;

        // Tâche d'apprentissage : backpropagation sur un sous-batch, et les données
        // sont stockées dans les tableaux weightsGradients, biasGradients et partialS
        // Le thread i remplit les cases i des tableaux (quand ce sera des tableaux)
        class LearningTask implements Callable<Object> {
          public Object call() {
            Matrix[] weightGrad = new Matrix[numOfLayers - 1];
            Matrix[] biasGrad = new Matrix[numOfLayers - 1];
            Matrix[][] cFiltersGrad = new Matrix[finalCFilters.length][];
            for(int i = 0; i < finalCFilters.length; i++)
              cFiltersGrad[i] = new Matrix[finalCFilters[i].length];
            Matrix[] cBiasGrad = new Matrix[finalCFilters.length];

            Matrix output = new Matrix(Y.n, trainingData[index].length);

            Matrix[][][][] activations = ForwardPropagation(X, true);

            output= activations[2][0][0][numOfLayers - 1].C();

            Matrix[][][] gradients = BackPropagation(activations[2][0][0], activations[0], activations[1], Y);

            activations = null;

            weightGrad = gradients[0][0];
            biasGrad = gradients[1][0];
            cFiltersGrad = gradients[2];
            cBiasGrad = gradients[3][0];

            synchronized(syncObject) {
              weightsGradients.add(weightGrad);
              biasGradients.add(biasGrad);
              cFiltersGradients.add(cFiltersGrad);
              cBiasGradients.add(cBiasGrad);
              partialS[index] = output;
            }

            return this;
          }
        }
        tasks.add(new LearningTask());
      }

      // Déclenche l'apprentissage des sous-batchs en parallèle
      try {
        List<Future<Object>> executorsAns = executor.invokeAll(tasks);
      } catch (InterruptedException e) {
        cl.pln("CNN, Learn : Erreur critique, bonne chance pour la suite");
      }

      // Recombine les données pour former les gradients et l'activation de la dernière couche
      for (int l = 0; l < this.numLayers-1; l++) {
        float[] coeffs = new float[numThreadsLearning];
        Matrix[] wlGradients = new Matrix[numThreadsLearning]; // Gradients pour les poids de la couche l
        Matrix[] blGradients = new Matrix[numThreadsLearning]; // Gradients pour les biais de la couche l

        for (int k = 0; k < coeffs.length; k++) {
          coeffs[k] = trainingData[k].length;
          wlGradients[k] = weightsGradients.get(k)[l];
          blGradients[k] = biasGradients.get(k)[l];
        }
        weightGrad[l] = new Matrix(0).AvgMatrix(wlGradients, coeffs);
        biasGrad[l] = new Matrix(0).AvgMatrix(blGradients, coeffs);
      }

      for (int l = 0; l < this.cFilters.length; l++) {
        float[] coeffs = new float[numThreadsLearning];
        Matrix[][] cflGradients = new Matrix[this.cFilters[l].length][numThreadsLearning]; // Gradients pour les poids de la couche l
        Matrix[] cblGradients = new Matrix[numThreadsLearning]; // Gradients pour les biais de la couche l

        for (int k = 0; k < coeffs.length; k++) {
          coeffs[k] = trainingData[k].length;
          for(int f = 0; f < this.cFilters[l].length; f++)
            cflGradients[f][k] = cFiltersGradients.get(k)[l][f];
          cblGradients[k] = cBiasGradients.get(k)[l];
        }

        for(int f = 0; f < this.cFilters[l].length; f++)
          cFiltersGrad[l][f] = new Matrix(0).AvgMatrix(cflGradients[f], coeffs);
        cBiasGrad[l] = new Matrix(0).AvgMatrix(cblGradients, coeffs);
      }

      S = new Matrix(0).Concat(partialS);
    }

    synchronized (stopLearning) {
      if (stopLearning.get()) {
        try { println("Learning stopped"); stopLearning.wait(); println("Le retour");}
        catch (Exception e) { e.printStackTrace(); }
      }
    }

    println("BACKPROPAGATION TIME : ", backwardTime, BPFCLTime + BPfirstGradTime + BPmaskTime + BPgradTime + BPnextGTime);
    println("FCL : ", BPFCLTime);
    println("First Grad : ", BPfirstGradTime);
    println("Mask : ", BPmaskTime);
    println("Grad : ", BPgradTime);
    println("Next Grad : ", BPnextGTime);
    println("Convolution Time : ", convolutionTime);

    for(int l = 0; l < this.numLayers - 1; l++) {
      if(!useADAM) {
        this.weights[l].Add(weightGrad[l], -learning_rate);
        this.bias[l].Add(biasGrad[l], -learning_rate);
        continue;
      }

      this.ADAMweightsMoment[l].Scale(b1).Add(weightGrad[l], 1-b1);
      this.ADAMweightsSqMoment[l].Scale(b2).Add(weightGrad[l].HProduct(weightGrad[l]), 1-b2);
      this.weights[l].Add(this.ADAMweightsMoment[l].C()
        .HProduct(this.ADAMweightsSqMoment[l].C().Map((x) -> 1 / sqrt(x + 1e-8)))
        .Scale(sqrt(1 - pow(b2, this.numOfLearningCall)) / (1 - pow(b1, this.numOfLearningCall))),
        -learning_rate);


      this.ADAMbiasMoment[l].Scale(b1).Add(biasGrad[l], 1-b1);
      this.ADAMbiasSqMoment[l].Scale(b2).Add(biasGrad[l].HProduct(biasGrad[l]), 1-b2);
      this.bias[l].Add(this.ADAMbiasMoment[l].C()
        .HProduct(this.ADAMbiasSqMoment[l].C().Map((x) -> 1 / sqrt(x + 1e-8)))
        .Scale(sqrt(1 - pow(b2, this.numOfLearningCall)) / (1 - pow(b1, this.numOfLearningCall))),
        -learning_rate);
    }

    for(int l = 0; l < this.cFilters.length; l++) {
      for(int f = 0; f < this.cFilters[l].length; f++) {
        if(!useADAM) {
          this.cFilters[l][f].Add(cFiltersGrad[l][f], -learning_rate);
          continue;
        }

        this.cADAMfiltersMoment[l][f].Scale(b1).Add(cFiltersGrad[l][f], 1-b1);
        this.cADAMfiltersSqMoment[l][f].Scale(b2).Add(cFiltersGrad[l][f].HProduct(cFiltersGrad[l][f]), 1-b2);
        this.cFilters[l][f].Add(this.cADAMfiltersMoment[l][f].C()
          .HProduct(this.cADAMfiltersSqMoment[l][f].C().Map((x) -> 1 / sqrt(x + 1e-8)))
          .Scale(sqrt(1 - pow(b2, this.numOfLearningCall)) / (1 - pow(b1, this.numOfLearningCall))),
          -learning_rate);

        // DEBUG FILTERS
        /*
        cl.pln("Filters " + str(l) + "," + str(f));
        cFiltersGrad[l][f].Debug();
        this.cFilters[l][f].Debug();
        */
      }

      if(!useADAM) {
        this.cBias[l].Add(cBiasGrad[l], -learning_rate);
      }

      this.cADAMbiasMoment[l].Scale(b1).Add(cBiasGrad[l], 1-b1);
      this.cADAMbiasSqMoment[l].Scale(b2).Add(cBiasGrad[l].HProduct(cBiasGrad[l]), 1-b2);
      this.cBias[l].Add(this.cADAMbiasMoment[l].C()
        .HProduct(this.cADAMbiasSqMoment[l].C().Map((x) -> 1 / sqrt(x + 1e-8)))
        .Scale(sqrt(1 - pow(b2, this.numOfLearningCall)) / (1 - pow(b1, this.numOfLearningCall))),
        -learning_rate);
    }

    int appliedTime = millis();

    println("Forward : " + str(forwardTime) + " | Backward : " + str(backwardTime) + " | Application : " + str(appliedTime - backwardTime - forwardTime - initTime));

    //S.Debug();
    float J = this.ComputeLoss(S, Y);

    weightGrad = null;
    biasGrad = null;
    cFiltersGrad = null;
    cBiasGrad = null;

    return J;
  }

  //f Permet le calcul du loss
  // _S_ est la sortie du système
  // _Y_ est la sortie attendue
  public float ComputeLoss(Matrix S, Matrix Y) {
    float J = 0;
    for(int c = 0; c < Y.p; c++) { //colonne de la sortie
      for(int i = 0; i < Y.n; i++) { //ligne de la sortie
        if((float)S.Get(i, c) != 0) J -= Y.Get(i, c) * Math.log(Math.abs((float)S.Get(i, c))) / Y.p;
      }
    }
    return J;
  }

  public float MiniBatchLearn(Matrix[][] data, int numOfEpoch, int batchSize, float lr) {
    return MiniBatchLearn(data, numOfEpoch, batchSize, lr, lr, 1);
  }

  public float MiniBatchLearn(Matrix[][] data, int numOfEpoch, int batchSize, float minLR, float maxLR, int period) {
    return MiniBatchLearn(data, numOfEpoch, batchSize, minLR, maxLR, period, new Matrix[][][]{data}, "");
  }

  //f Session d'entrainement complète
  // data[0] : liste des entrées Matrix[]
  // data[1][0] : matrice de sortie
  public float MiniBatchLearn(Matrix[][] data, int numOfEpoch, int batchSize, float minLR, float maxLR, int period, Matrix[][][] testSets, String label) {
    cl.pln("Mini Batch Gradient Descent " + label + " - " + numOfEpoch + " Epochs - " + batchSize + " Batch Size - " + String.format("%9.3E", maxLR) + " LR");

    float lossAverage = 0;

    int startTime = millis();
    int numOfBatches = ceil(data[0].length / batchSize);
    for (int k = 0; k < numOfEpoch; k++) {
      float learningRate = CyclicalLearningRate(k, minLR, maxLR, period);
      cl.pln("(" + label + ") \tEpoch " + (k+1) + "/" + numOfEpoch + "\t Learning Rate : " + String.format("%6.4f", learningRate));

      for (int i = 0; i < data[0].length-1; i++) {
        int j = floor(random(i, data[0].length));
        Matrix temp = data[0][i];
        data[0][i] = data[0][j];
        data[0][j] = temp;
        data[1][0].ComutCol(i, j);
      }

      lossAverage = 0;

      for (int i = 0; i < numOfBatches; i++) {
        Matrix[] batch = Arrays.copyOfRange(data[0], i*batchSize, min(i*batchSize + batchSize, data[0].length));
        Matrix batchAns = data[1][0].GetCol(i*batchSize, min(i*batchSize + batchSize - 1, data[0].length - 1));
        float l = this.Learn(batch, batchAns, learningRate);
        lossAverage += l / numOfBatches;
        graphApplet.AddValue(l);

        if (abortTraining.get()) return lossAverage;

        if (i % max(1, (numOfBatches / 4)) == 0)
          cl.pln("\t Epoch " + String.format("%05d",k+1) +
            " Batch " + String.format("%05d",i+1) + " : " + String.format("%9.3E",l) +
            "\t Time remaining " + RemainingTime(startTime, k * numOfBatches + i + 1, numOfBatches * numOfEpoch)
          );
      }

      if((k+1)%2 != 0 && k != numOfEpoch - 1) continue;

      for(int s = 0; s < testSets.length; s++) {
        float[] score = CompilScore(session.AccuracyScore(this, testSets[s], false));
        cl.p("\t Score", str(s), ":", String.format("%7.5f", Average(score)));
      }
      cl.pln();
    }
    
    matrixMultKernel.dispose();
    nextGradKernel.dispose();

    return lossAverage;
  }

  @Override
  public String toString() {
    String str = "CNN[";
    for (int i = 0; i < cNumLayers; i++) {
      str += str(cFilters[i].length);
      if (i < cNumLayers - 1) str += ", ";
      else str += " / ";
    }
    for (int i = 0; i < numLayers; i++) {
      str += str(layers[i]);
      if (i < numLayers -1) str += ", ";
    }
    return str + "]";
  }
}



public class NextGradKernel extends Kernel {
  private int filterN;
  private int filterP;
  private int filterArea;
  private int numOfFilters;

  private float[] rotatedFiltersFlat;

  private int gradientN;
  private int gradientP;
  private int gradientArea;
  private int gradientNumber;
  private int inputArea;

  private float[] cGradientFlat;


  private int outN;
  private int outP;
  private float[] output;
  
  private int prevLayerOutputSize;
  
  public void SetData(int filterN, int filterP, int filterArea, int numOfFilters, float[] rotatedFiltersFlat, int gradientN, int gradientP, int gradientArea, int gradientNumber, int inputArea, float[] cGradientFlat, int outN, int outP, float[] output, int prevLayerOutputSize) {
    this.filterN = filterN;
    this.filterP = filterP;
    this.filterArea = filterArea;
    this.numOfFilters = numOfFilters;
  
    this.rotatedFiltersFlat = rotatedFiltersFlat;
  
    this.gradientN = gradientN;
    this.gradientP = gradientP;
    this.gradientArea = gradientArea;
    this.gradientNumber = gradientNumber;
    this.inputArea = inputArea;
  
    this.cGradientFlat = cGradientFlat;
  
  
    this.outN = outN;
    this.outP = outP;
    this.output = output;
    
    this.prevLayerOutputSize = prevLayerOutputSize;
  }
  
  @Override
  public void run() {
    int gid = getGlobalId();
    int x = gid / prevLayerOutputSize;
    int p = gid % prevLayerOutputSize;

    for(int i = 0; i < outN; i++) {
      for(int j = 0; j < outP; j++) {
        float sum = 0f;

        for(int f = 0; f < numOfFilters; f++) {
          for(int gi = 0; gi < gradientN; gi++) {
            for(int gj = 0; gj < gradientP; gj++) {
              int ii = i - gi;
              int jj = j - gj;

              if(ii < 0 || ii >= filterN || jj < 0 || jj >= filterP) continue;

              sum += rotatedFiltersFlat[f * filterArea + ii * filterP + jj] * cGradientFlat[x * inputArea + (p * numOfFilters + f) * gradientArea + gi * gradientP + gj];
            }
          }
        }

        output[x * prevLayerOutputSize * (outN * outP) + p * (outN * outP) + i * outP + j] = sum;
      }
    }
  }
}
