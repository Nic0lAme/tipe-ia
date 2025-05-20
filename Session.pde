public class Session {
  String name;
  HyperParameters hp;

  int w, h;

  NeuralNetwork nn;
  Matrix[] sample;
  String[] characters;

  String[] sessionHandTrainingDatas;
  String[] sessionFontTrainingDatas;
  String[] sessionHandTestingDatas;
  String[] sessionFontTestingDatas;

  LetterDataset ds;

  private boolean inTraining = false;

  //c Crée une session ayant pour nom _name_ et pour hyperparamètres _hp_
  Session(String name, HyperParameters hp) {
    this.hp = hp;

    this.w = 21;
    this.h = 21;

    this.name = name;
    this.characters = cs.GetChars();

    this.sessionHandTrainingDatas = handTrainingDatas;
    //this.handTrainingDatas = new String[]{};
    this.sessionFontTrainingDatas = fontTrainingDatas;
    //this.fontTrainingDatas = new String[]{};

    this.sessionHandTestingDatas = handTestingDatas;
    this.sessionFontTestingDatas = fontTestingDatas;

    ds = new LetterDataset(5*this.w, 5*this.h);
  }

  //f Indique si la session est en cours d'entrainement ou non
  public boolean IsInTraining() {
    return inTraining;
  }

  //f Demande l'arrêt de l'entrainement
  // Note: L'arrêt n'est pas instantané, il faut que l'IA finisse son itération
  public void AskStopTraining() {
    if (abortTraining.get()) return;
    abortTraining.set(true);
  }

  //f Entraine le réseau _this.nn_
  // _phaseNumber_ est le nombre de phase de test (création de nouveaux dataset)
  // _epochPerSet_ est le nombre d'epoch à chaque phase
  // _startMinLR_, _endMinLR_, _startMaxLR_ et _endMaxLR_ permettent de définir l'évolution du learning rate
  // _period_ désigne la période de changement du learning rate entre haut et bas
  // _batchSize_ représente la taille des batchs (taille des découpes d'échantillons à chaque epoch)
  // _startDef_ et _endDef_ correspondent à l'évolution du taux de déformation
  // _rep_ est le nombre de répétition de chaque échantillon
  // _prop_ est la proportion minimale de _rep_ pour chaque échantillon, modulé par la performance du réseau sur le charactère associé
  void TrainForImages(int phaseNumber, int epochPerSet, float startMinLR, float endMinLR, float startMaxLR, float endMaxLR, int period, int batchSize, float startDef, float endDef, int rep, float minProp) {
    float[] accuracy = new float[nn.outputSize];
    int[] repList;
    Arrays.fill(accuracy, 0.5);

    inTraining = true;

    Matrix[] testSampleHand = ds.SampleLining(ds.CreateSample(
      this.characters,
      this.sessionHandTestingDatas,
      new String[]{},
    3, startDef));

    Matrix[] testSampleFont = ds.SampleLining(ds.CreateSample(
      this.characters,
      new String[]{},
      this.sessionFontTestingDatas,
    3, startDef));

    for(int k = 0; k <= phaseNumber; k++) {
      cl.pln("\nPhase", k, "/", phaseNumber);

      float deformationRate = map(k, 1, phaseNumber, startDef, endDef);

      if(k > 1) {

        testSampleHand = ds.SampleLining(ds.CreateSample(
          this.characters,
          this.sessionHandTestingDatas,
          new String[]{},
        3, deformationRate));

        testSampleFont = ds.SampleLining(ds.CreateSample(
          this.characters,
          new String[]{},
          this.sessionFontTestingDatas,
        3, deformationRate));
      }

      if(k != 0) {
        repList = RepList(accuracy, rep, minProp);

        sample = ds.SampleLining(ds.CreateSample(
          this.characters,
          this.sessionHandTrainingDatas,
          //new String[]{},
          this.sessionFontTrainingDatas,
          repList, deformationRate));

        float maxLR = startMaxLR * pow(endMaxLR / startMaxLR, (float)(k-1)/max(1, (phaseNumber-1)));
        float minLR = startMinLR * pow(endMinLR / startMinLR, (float)(k-1)/max(1, (phaseNumber-1)));
        this.nn.MiniBatchLearn(sample, epochPerSet, batchSize, minLR, maxLR, period, new Matrix[][]{testSampleHand, testSampleFont}, k + "/" + phaseNumber);

        if (abortTraining.get()) {
          cl.pln("Training aborted");
          break;
        }
      }

      float averageTrainingAccuracy = 0;
      if(k >= 1) {
        Matrix[] shuffledSample = new Matrix(0).ShuffleCol(sample);
        averageTrainingAccuracy = Average(CompilScore(this.AccuracyScore(this.nn, shuffledSample, false)));
        cl.pln("Accuracy on training set :", String.format("%6.3f", averageTrainingAccuracy));
      }

      accuracy = CompilScore(this.AccuracyScore(this.nn, new Matrix[][]{testSampleHand, testSampleFont}, false));
      float averageTestingAccuracy = Average(accuracy);

      cl.pln("Accuracy on test set :", String.format("%6.3f", averageTestingAccuracy));
      cl.pln();

      if (k >= 1) graphApplet.AddTestResult(averageTrainingAccuracy, averageTestingAccuracy);

      cl.Update();
    }

    abortTraining.set(false);
    inTraining = false;
    cl.pln("Training End");
  }

  //f Teste _this.nn_ sur les sets de tests
  void TestImages() {
    frame.setSize(new Dimension(floor(this.w * rScale * cs.NumChars()), floor(this.h * rScale * numOfTestSample)));

    Matrix[] testSample = ds.SampleLining(ds.CreateSample(
      this.characters,
      this.sessionHandTestingDatas,
      // new String[]{},
      this.sessionFontTestingDatas,
      4, testDerformation));

    frame.setVisible(true);
    background(255);

    float[] score = CompilScore(this.AccuracyScore(this.nn, testSample, true));
    cl.pln("Training Set Score :", Average(score));
    cl.pFloatList(score, "Accuracy");


    save("./Representation/" + str(frameCount) + " " + str(Average(score)) + " " + nameOfProcess + ".jpg");

    testSample[0].Delete();
    testSample[1].Delete();

    System.gc();

    cl.Update();
  }

  /* HOW TO USE DIRECT TEST
    click to write (left -> black, right -> white)
    +/- to change brush size
    space to reset
    enter to show prediction directly on the sketch
  */
  int brushSize = 16;

  /*
  //f Permet de tester en direct les performances du réseau
  void DirectTest() {
    frame.setPreferredSize(new Dimension(500, 400));
    frame.setVisible(true);

    if(keyPressed && key == ' ') background(255);
    if(keyPressed && key == '+') {
      brushSize += 1;
      println("Brush Size", brushSize);
    }
    if(keyPressed && key == '-') {
      brushSize -= 1;
      println("Brush Size", brushSize);
    }

    if(!mousePressed && (!keyPressed || keyCode != ENTER)) return;

    if(mouseButton == LEFT) stroke(0);
    if(mouseButton == RIGHT) stroke(255);

    strokeWeight(brushSize);
    line(mouseX, mouseY, pmouseX, pmouseY);

    PImage img = get(0, 0, width, height);
    img.filter(THRESHOLD, 0.5);

    ArrayList<float[]> charactersProb = new ArrayList<float[]>();

    ArrayList<ArrayList<PVector>> contours = im.ContourDetection(img);
    for(ArrayList<PVector> contour : contours) {
      if(!im.IsClockwise(contour)) continue;

      PImage c = im.ImageFromContour(img, contour, 0.02, 0.89);
      charactersProb.add(this.CharactersProb(c));

      if(keyPressed && keyCode == ENTER) {
        fill(0,255,0);
        text(Result(c).keyArray()[0], contour.get(0).x, contour.get(0).y);
      }
      print(Result(c).keyArray()[0], "");
    }

    println(wc.WordAutoCorrection(charactersProb.toArray(new float[0][])));

    println();
  }
  */

  float[][] AccuracyScore(NeuralNetwork nn, Matrix[] data, boolean doDraw) {
    return AccuracyScore(nn, new Matrix[][]{data}, doDraw);
  }

  float[][] AccuracyScore(NeuralNetwork nn, Matrix[][] data, boolean doDraw) {
    float[][] score = new float[data.length][data[0][1].n];
    int[][] countOutput = new int[data.length][data[0][1].n]; // Compte le nombre d'output ayant pour retour i

    int ret = 0; // To draw
    for(int k = 0; k < data.length; k++) {
      Matrix[] d = data[k];
      Matrix prediction = nn.Predict(d[0]);

      int x = 0; int y = 0;
      textAlign(LEFT, BOTTOM); textSize(this.w); fill(255,0,0);

      int mIndex; float m; // Recherche de la prédiction la plus haute
      for(int j = 0; j < d[0].p; j++) {
        boolean isGood = false;
        fill(255,0,0,100);

        mIndex = -1;
        m = -1;
        for(int i = 0; i < d[1].n; i++) {
          if(prediction.Get(i, j) > m) {
            mIndex = i;
            m = prediction.Get(mIndex, j);
          }
        }

        for(int i = 0; i < d[1].n; i++) {
          if(d[1].Get(i,j) == 1) {
            countOutput[k][i] += 1;
            if(mIndex == i) {
              score[k][i] += 1;
              fill(0,255,0,100);
              isGood = true;
            }
          }
        }


        if(doDraw) {
          x = floor(floor(rScale*this.h*ret) / height * rScale * this.w);
          y = floor(floor(rScale*this.h*ret) % height);
          image(ds.GetImageFromInputs(d[0], j), x, y, rScale*this.w, rScale*this.h);

          noStroke();
          rect(x, y, rScale * this.w, rScale * this.h);

          if(!isGood) {
            fill(200);
            //textSize(rScale * this.w);
            //text(characters[mIndex], x, y, rScale*this.w, rScale*this.h);
          }
        }

        ret++;
      }
      for(int i = 0; i < data[0][1].n; i++) {
        score[k][i] = countOutput[k][i] != 0 ? score[k][i] / (float)countOutput[k][i] : 0;
      }
    }

    return score;
  }

  float[][] AccuracyScore(CNN nn, Matrix[][] data, boolean doDraw) {
    return AccuracyScore(nn, new Matrix[][][]{data}, doDraw);
  }

  float[][] AccuracyScore(CNN nn, Matrix[][][] data, boolean doDraw) {
    float[][] score = new float[data.length][data[0][1][0].n];
    int[][] countOutput = new int[data.length][data[0][1][0].n]; // Compte le nombre d'output ayant pour retour i

    int ret = 0; // To draw
    for(int k = 0; k < data.length; k++) {
      Matrix[][] d = data[k];
      Matrix prediction = nn.Predict(d[0]);

      int x = 0; int y = 0;
      textAlign(LEFT, BOTTOM); textSize(this.w); fill(255,0,0);

      int mIndex; float m; // Recherche de la prédiction la plus haute
      for(int j = 0; j < d[0].length; j++) {
        boolean isGood = false;
        fill(255,0,0,100);

        mIndex = -1;
        m = -1;
        for(int i = 0; i < d[1][0].n; i++) {
          if(prediction.Get(i, j) > m) {
            mIndex = i;
            m = prediction.Get(mIndex, j);
          }
        }

        for(int i = 0; i < d[1][0].n; i++) {
          if(d[1][0].Get(i,j) == 1) {
            countOutput[k][i] += 1;
            if(mIndex == i) {
              score[k][i] += 1;
              fill(0,255,0,100);
              isGood = true;
            }
          }
        }


        if(doDraw) {
          x = floor(floor(rScale*this.h*ret) / height * rScale * this.w);
          y = floor(floor(rScale*this.h*ret) % height);
          image(ds.CNNGetImageFromInputs(d[0][j]), x, y, rScale*this.w, rScale*this.h);

          noStroke();
          rect(x, y, rScale * this.w, rScale * this.h);

          if(!isGood) {
            fill(200);
            //textSize(rScale * this.w);
            //text(characters[mIndex], x, y, rScale*this.w, rScale*this.h);
          }
        }

        ret++;
      }
      for(int i = 0; i < data[0][1][0].n; i++) {
        score[k][i] = countOutput[k][i] != 0 ? score[k][i] / (float)countOutput[k][i] : 0;
      }
    }

    return score;
  }

  Matrix ImgPP(PImage img) { // Images post-processing
    PImage PPImage = im.Gray(img);
    PPImage = im.Contrast(PPImage, 0.02);
    PPImage = im.AutoCrop(PPImage, 128, 0);
    PPImage = im.TargetRatio(PPImage, 1);
    //PPImage = im.Contrast(PPImage, 0.02); // If there is a dark patch in the center

    im.Resize(PPImage, this.w, this.h);
    PPImage.loadPixels();

    Matrix ret = new Matrix(this.h, this.w);
    for(int i = 0; i < this.h; i++)
      for(int j = 0; j < this.w; j++)
        ret.values[i * ret.p + j] = 1 - brightness(PPImage.pixels[i * this.w + j])/255;

    return ret;
  }

  /*
  FloatDict Result(PImage img) {
    FloatDict result = new FloatDict();

    float[] input = ImgPP(img);
    Matrix inputMatrix = new Matrix(this.w*this.h,1).ColumnFromArray(0, input);

    Matrix outputMatrix = nn.Predict(inputMatrix);
    for(int c = 0; c < outputMatrix.n; c++) {
      result.set(characters[c], (float)outputMatrix.Get(c, 0));
    }

    result.sortValuesReverse();

    return result;
  }

  float[] CharactersProb(PImage img) {
    float[] input = ImgPP(img);
    Matrix inputMatrix = new Matrix(this.w*this.h,1).ColumnFromArray(0, input);

    Matrix outputMatrix = nn.Predict(inputMatrix);
    return cs.GetProb(outputMatrix.ColumnToArray(0));
  }
  */

}
