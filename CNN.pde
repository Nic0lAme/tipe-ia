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
  double cPool = 2;
  int cFilterSize = 3;
  Matrix[][] cFilters;
  Matrix[] cBias;
  int[] cImageSizes;

  double lambda = 0;

  boolean useSoftMax = false; // Détermine l'utilisation de la fonction softmax sur la dernière couche du réseau

  ExecutorService executor;

  //c _sizes_ correspond aux tailles des niveaux
  CNN(int imageSize, int[] cNumFilters, int[] sizes) {
    this.numLayers = sizes.length + 1;
    this.layers = new int[numLayers];
    for (int i = 0; i < numLayers - 1; i++) layers[i+1] = sizes[i];
    
    this.cNumLayers = cNumFilters.length;
    this.cFilters = new Matrix[cNumLayers][];
    this.cBias = new Matrix[cNumLayers];
    for (int i = 0; i < cNumLayers; i++) cFilters[i] = new Matrix[cNumFilters[i]];
    
    this.cImageSize = imageSize;
    
    executor = Executors.newFixedThreadPool(numThreadsLearning);

    Init();
  }

  public void UseSoftMax() { this.useSoftMax = true; } // Lorsque SoftMax est utilisé, il est nécessaire d'avoir des sorties qui s'additionnent à 1

  private void Init() {
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

    for (int i = 0; i < numLayers-1; i++) {
      // Normal Xavier Weight Initialization
      bias[i] = new Matrix(layers[i+1], 1).Random(-sqrt(6) / sqrt(layers[i] + layers[i+1]), sqrt(6) / sqrt(layers[i] + layers[i+1]));
      weights[i] = new Matrix(layers[i+1], layers[i]).Random(-1, 1);
    }
    
    // Calcul aléatoire d'init des filters et bias du CNN
    for (int i = 0; i < cNumLayers; i++) {
      for(int k = 0; k < this.cFilters[i].length; k++) {
        this.cFilters[i][k] = new Matrix(cFilterSize).Random(-1, 1);
      }
      
      cBias[i] = new Matrix(this.cFilters[i].length, 1).Random(-1, 1);
    }
  }
  

  //f Donne la sortie du réseau de neurones _this_ pour l'entrée _entry_
  public Matrix Predict(Matrix[] entry) {
    Matrix[] outputs = new Matrix[entry.length];
    for(int k = 0; k < entry.length; k++) outputs[k] = ForwardPropagation(entry[k])[2][0][this.numLayers - 1];
    return new Matrix(0).Concat(outputs);
  }

  //f  
  public Matrix[][][] ForwardPropagation(Matrix entry) {
    if (entry.n != this.cImageSize) {
      println(entry.n, this.cImageSize);
      println("Taille de l'entrée invalide");
      return null;
    }
    
    Matrix[][] masks = new Matrix[this.cNumLayers][];
    Matrix[][] convVal = new Matrix[this.cNumLayers + 1][];
    convVal[0] = new Matrix[]{entry};
    for(int k = 0; k < this.cNumLayers; k++) {
      int numOfFilter = this.cFilters[k].length;
      masks[k] = new Matrix[convVal[k].length * numOfFilter];
      
      convVal[k+1] = new Matrix[convVal[k].length * numOfFilter];
      
      for(int e = 0; e < convVal[k].length; e++) {
        for(int f = 0; f < numOfFilter; f++) {
          Matrix convoluted = convVal[k][e].Convolution(this.cFilters[k][f]).AddScal(this.cBias[k].Get(f, 0));
          //convoluted.Add(new Matrix(convoluted.n).Fill(this.cBias[k].Get(f,0)));
          
          Matrix[] pooled = convoluted.MaxPooling(2,2);
          masks[k][e * numOfFilter + f] = pooled[1];
          
          convVal[k+1][e * numOfFilter + f] = pooled[0];
        }
      }
    }
    
    Matrix[] layerVal = new Matrix[this.numLayers];
    
    int outputArea = convVal[this.cNumLayers][0].n * convVal[this.cNumLayers][0].p;
    Matrix nnEntry = new Matrix(convVal[this.cNumLayers].length * outputArea, 1);
    for(int k = 0; k < convVal[this.cNumLayers].length; k++) {
      Matrix col = convVal[this.cNumLayers][k].ToCol();
      for(int i = 0; i < outputArea; i++) {
        nnEntry.Set(k * outputArea + i, 0, col.Get(i, 0));
      }
    }
    
    layerVal[0] = nnEntry;
    for(int i = 0; i < this.numLayers - 1; i++) {
      layerVal[i + 1] = CalcLayer(i, layerVal[i]);
    }

    return new Matrix[][][]{ convVal, masks, new Matrix[][]{layerVal} }; // :) :)
  }

  //f Calcule la sortie correspondant à l'entrée _in_, de la couche _from_ à la couche _from+1_
  private Matrix CalcLayer(int from, Matrix in) {
    Matrix result = weights[from].Mult(in);

    result.Add(bias[from], 1, true);

    if(from == this.numLayers - 2 && this.useSoftMax) {
      double max = result.Get(0,0);
      for(int i = 0; i < result.n; i++)
        for(int j = 0; j < result.p; j++)
          if(result.Get(i,j) > max) max = result.Get(i,j);

      result.Add(new Matrix(result.n, result.p).Fill(-max));

      result.Map((x) -> Math.exp(x));

      result.NormColumn();
      return result;
    }

    result.Map((x) -> sigmoid(x));

    return result;
  }
  
  
  //f Effectue la rétropropagation du réseau de neurones
  // On prend en entrée les valeurs d'_activations_ des layers
  // On donne les valeurs attendues dans _expectedOutput_
  public Matrix[][][] BackPropagation(Matrix[] activations, Matrix[][] convActivations, Matrix[][] masks, Matrix expectedOutput) {

    //dJ/dZl
    Matrix a = activations[this.numLayers-1].C();
    Matrix gradient = a.C().Add(expectedOutput, -1).HProduct(a.C().HProduct(a.C().AddScal(-1.0).Scale(-1.0)));

    Matrix[] weightGrad = new Matrix[this.numLayers - 1];
    Matrix[] biasGrad = new Matrix[this.numLayers - 1];

    for(int l = this.numLayers - 2; l >= 0; l--) {

      //dJ/dWl = dJ/dZl * dZl/dWl
      weightGrad[l] = gradient.Mult(activations[l].T()).Scale(1/ (double)max(1, expectedOutput.p));

      //dJ/dbl = dJ/dZl * dZl/dbl
      biasGrad[l] = gradient.AvgLine();

      if(lambda != 0) {
        weightGrad[l].Add(weights[l], lambda / max(1, weights[l].n * weights[l].p));
        biasGrad[l].Add(bias[l], lambda / max(1, bias[l].n));
      }

      a = activations[l].C();
      gradient = (weights[l].T().Mult(gradient)).HProduct(a.C().Add(a.C().HProduct(a), -1));
    }
    
    int areaOfOutput = this.cImageSizes[this.cNumLayers] * this.cImageSizes[this.cNumLayers];
    int numOfImageInOutput = convActivations[this.cNumLayers].length;
    assert activations[0].n == areaOfOutput * numOfImageInOutput;

    Matrix[] cGradient = new Matrix[numOfImageInOutput];
    for(int k = 0; k < numOfImageInOutput; k++) {
      //  A REFAIRE PROPREMENT
      cGradient[k] = gradient.T().GetCol(k * areaOfOutput, (k+1) * areaOfOutput - 1).T().FromCol(this.cImageSizes[this.cNumLayers], this.cImageSizes[this.cNumLayers]);
    }
    
    Matrix[][] cFiltersGrad = new Matrix[this.cNumLayers][];
    Matrix[] cBiasGrad = new Matrix[this.cNumLayers];
    for(int k = this.cNumLayers - 1; k >= 0; k--) {
      int prevLayerOutputSize = cGradient.length / this.cFilters[k].length;
      
      cBiasGrad[k] = new Matrix(this.cFilters[k].length, 1);
      Matrix[] cSizedGradient = new Matrix[cGradient.length];
      for(int oImg = 0; oImg < prevLayerOutputSize; oImg++) {
        for(int fImg = 0; fImg < this.cFilters[k].length; fImg++) {
          int g = oImg * this.cFilters[k].length + fImg;
          cSizedGradient[g] = new Matrix(convActivations[k][0].n - this.cFilterSize + 1);
          for(int i = 0; i < cSizedGradient[g].n; i++) {
            for(int j = 0; j < cSizedGradient[g].p; j++) {
              cSizedGradient[g].Set(i, j, masks[k][oImg].Get(i,j) * cGradient[g].Get((int)Math.floor((float)i / this.cPool), (int)Math.floor((float)j / this.cPool)));
            }
          }
        }
      }
      
      cFiltersGrad[k] = new Matrix[this.cFilters[k].length];
      for(int f = 0; f < this.cFilters[k].length; f++) {
        cFiltersGrad[k][f] = new Matrix(cFilterSize);
        for(int i = 0; i < convActivations[k].length; i++) {
          cFiltersGrad[k][f].Add(convActivations[k][i].Convolution(cSizedGradient[f + i * this.cFilters[k].length]).Scale((double)1/convActivations[k].length));
          cBiasGrad[k].values[f][0] += cSizedGradient[i].TotalSum() / cSizedGradient[i].n / cSizedGradient[i].p / convActivations[k].length;
        }
      }
      
      /*
      cl.pln("Layer " + str(k));
      cFiltersGrad[k][0].Debug();
      cBiasGrad[k].Debug();
      */
      
      if (k==0) continue; // Pas besoin de calculer le gradient suivant (et surtout ça ne peut pas)
      
      Matrix[] nextCGrad = new Matrix[prevLayerOutputSize];
      for(int x = 0; x < prevLayerOutputSize; x++) {
        nextCGrad[x] = new Matrix(cImageSizes[k]);
        for(int f = 0; f < this.cFilters[k].length; f++) {
          nextCGrad[x].Add(this.cFilters[k][f].Rotate180().FullConvolution(cSizedGradient[x * this.cFilters[k].length + f]));
        }
      }
      
      cGradient = nextCGrad;
    }

    return new Matrix[][][]{new Matrix[][]{weightGrad}, new Matrix[][]{biasGrad}, cFiltersGrad, new Matrix[][]{cBiasGrad}};
  }

  //f Effectue une étape d'apprentissage, ayant pour entrée _X_ et pour sortie _Y_
  // Le taux d'apprentissage est _learning\_rate_
  public double Learn(Matrix[] X, Matrix Y, double learning_rate) {
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
      for(int k = 0; k < X.length; k++) {
        Matrix[][][] activations = ForwardPropagation(X[k]);
        S.ColumnFromArray(k, activations[2][0][this.numLayers - 1].C().ColumnToArray(0));
        
        Matrix[][][] gradients = BackPropagation(activations[2][0], activations[0], activations[1], Y.GetCol(k));
        
        for(int i = 0; i < this.numLayers - 1; i++) {
          if(k==0) {
            weightGrad[i] = gradients[0][0][i].Scale((double)1/X.length);
            biasGrad[i] = gradients[1][0][i].Scale((double)1/X.length);
            continue;
          }
          
          weightGrad[i].Add(gradients[0][0][i].Scale((double)1/X.length));
          biasGrad[i].Add(gradients[1][0][i].Scale((double)1/X.length));
        }
        
        for(int i = 0; i < this.cFilters.length; i++) {
          for(int f = 0; f < this.cFilters[i].length; f++) {
            if(k==0) {
              cFiltersGrad[i][f] = gradients[2][i][f].Scale((double)1/X.length);
              continue;
            }
            cFiltersGrad[i][f].Add(gradients[2][i][f].Scale((double)1/X.length));
          }
          if(k==0) {
            cBiasGrad[i] = gradients[3][0][i].Scale((double)1/X.length);
            continue;
          }
          
          cBiasGrad[i].Add(gradients[3][0][i].Scale((double)1/X.length));
        }
      }
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

            for(int k = 0; k < trainingData[index].length; k++) {
              Matrix[][][] activations = ForwardPropagation(trainingData[index][k]);
              output.ColumnFromArray(k, activations[2][0][numOfLayers - 1].C().ColumnToArray(0));
              
              Matrix[][][] gradients = BackPropagation(activations[2][0], activations[0], activations[1], answers[index].GetCol(k));
              
              for(int i = 0; i < numOfLayers - 1; i++) {
                if(k==0) {
                  weightGrad[i] = gradients[0][0][i].Scale((double)1/trainingData[index].length);
                  biasGrad[i] = gradients[1][0][i].Scale((double)1/trainingData[index].length);
                  continue;
                }
                
                weightGrad[i].Add(gradients[0][0][i].Scale((double)1/trainingData[index].length));
                biasGrad[i].Add(gradients[1][0][i].Scale((double)1/trainingData[index].length));
              }
              
              for(int i = 0; i < finalCFilters.length; i++) {
                for(int f = 0; f < finalCFilters[i].length; f++) {
                  if(k==0) {
                    cFiltersGrad[i][f] = gradients[2][i][f].Scale((double)1/trainingData[index].length);
                    continue;
                  }
                  cFiltersGrad[i][f].Add(gradients[2][i][f].Scale((double)1/trainingData[index].length));
                }
                if(k==0) {
                  cBiasGrad[i] = gradients[3][0][i].Scale((double)1/trainingData[index].length);
                  continue;
                }
                
                cBiasGrad[i].Add(gradients[3][0][i].Scale((double)1/trainingData[index].length));
              }
            }

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
        double[] coeffs = new double[numThreadsLearning];
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
        double[] coeffs = new double[numThreadsLearning];
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
    
    for(int l = 0; l < this.numLayers - 1; l++) {
      this.weights[l].Add(weightGrad[l], -learning_rate);
      this.bias[l].Add(biasGrad[l], -learning_rate);
    }
    
    for(int l = 0; l < this.cFilters.length; l++) {
      for(int f = 0; f < this.cFilters[l].length; f++) {
        this.cFilters[l][f].Add(cFiltersGrad[l][f], -learning_rate);
        
        // DEBUG FILTERS
        /*
        cl.pln("Filters " + str(l) + "," + str(f));
        cFiltersGrad[l][f].Debug();
        this.cFilters[l][f].Debug();
        */
      }
      this.cBias[l].Add(cBiasGrad[l], -learning_rate);
    }
    
    //S.Debug();
    double J = this.ComputeLoss(S, Y);
    return J;
  }

  //f Permet le calcul du loss
  // _S_ est la sortie du système
  // _Y_ est la sortie attendue
  public double ComputeLoss(Matrix S, Matrix Y) {
    double J = 0;
    for(int c = 0; c < Y.p; c++) { //colonne de la sortie
      for(int i = 0; i < Y.n; i++) { //ligne de la sortie
        if((double)S.Get(i, c) != 0) J -= Y.Get(i, c) * Math.log(Math.abs((double)S.Get(i, c))) / Y.p;
      }
    }
    return J;
  }

  public double MiniBatchLearn(Matrix[][] data, int numOfEpoch, int batchSize, double lr) {
    return MiniBatchLearn(data, numOfEpoch, batchSize, lr, lr, 1);
  }

  public double MiniBatchLearn(Matrix[][] data, int numOfEpoch, int batchSize, double minLR, double maxLR, int period) {
    return MiniBatchLearn(data, numOfEpoch, batchSize, minLR, maxLR, period, new Matrix[][][]{data}, "");
  }
  
  //f Session d'entrainement complète
  // data[0] : liste des entrées Matrix[]
  // data[1][0] : matrice de sortie
  public double MiniBatchLearn(Matrix[][] data, int numOfEpoch, int batchSize, double minLR, double maxLR, int period, Matrix[][][] testSets, String label) {
    cl.pln("Mini Batch Gradient Descent " + label + " - " + numOfEpoch + " Epochs - " + batchSize + " Batch Size - " + String.format("%9.3E", maxLR) + " LR");

    double lossAverage = 0;

    int startTime = millis();
    int numOfBatches = ceil(data[0].length / batchSize);
    for (int k = 0; k < numOfEpoch; k++) {
      double learningRate = CyclicalLearningRate(k, minLR, maxLR, period);
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
        double l = this.Learn(batch, batchAns, learningRate);
        lossAverage += l / numOfBatches;
        graphApplet.AddValue(l);

        if (abortTraining.get()) return lossAverage;

        if (i % max(1, (numOfBatches / 4)) == 0)
          cl.pln("\t Epoch " + String.format("%05d",k+1) +
            " Batch " + String.format("%05d",i+1) + " : " + String.format("%9.3E",l) +
            "\t Time remaining " + RemainingTime(startTime, k * numOfBatches + i + 1, numOfBatches * numOfEpoch)
          );
      }

      if((k+1)%6 != 0 && k != numOfEpoch - 1) continue;

      for(int s = 0; s < testSets.length; s++) {
        float[] score = CompilScore(session.AccuracyScore(this, testSets[s], false));
        cl.p("\t Score", str(s), ":", String.format("%7.5f", Average(score)));
      }
      cl.pln();
    }

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
