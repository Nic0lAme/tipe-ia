public class Session {
  String name;
  HyperParameters hp;
  
  NeuralNetwork nn;
  String[] characters;
  
  String[] handTrainingDatas;
  String[] fontTrainingDatas;
  String[] handTestingDatas;
  String[] fontTestingDatas;
  
  LetterDataset ds;
  
  //c Crée une session ayant pour nom _name_ et pour hyperparamètres _hp_
  Session(String name, HyperParameters hp) {
    this.hp = hp;
    
    this.name = name;
    this.characters = allCharacters;

    handTrainingDatas = new String[]{"AntoineME", "NicolasMA", "LenaME", "TheoLA", "ElioKE", "AkramBE", "MaximeMB", "NathanLU", "LubinDE", "MatheoLB", "SachaAD", "MatisBR", "ValerieAR", "ArthurLO", "RomaneFI", "ThelioLA", "YanisIH"};
//String[] handTrainingDatas = new String[]{};
    fontTrainingDatas = new String[]{"Arial", "Bahnschrift", "Eras Demi ITC", "Lucida Handwriting Italique", "DejaVu Serif", "Fira Code Retina Moyen", "Consolas", "Lucida Handwriting Italique", "Playwrite IT Moderna", "Just Another Hand"};
//String[] fontTrainingDatas = new String[]{};

    handTestingDatas = new String[]{"MrMollier", "MrChauvet", "SachaBE", "IrinaRU", "NoematheoBLB"};
    fontTestingDatas = new String[]{"Liberation Serif", "Calibri", "Book Antiqua", "Gabriola", "Noto Serif"};
    
    ds = new LetterDataset(5*hp.w, 5*hp.h);
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
  
    Matrix[] testSampleHand = ds.CreateSample(
      this.characters,
      this.handTestingDatas,
      new String[]{},
    3, startDef);
  
    Matrix[] testSampleFont = ds.CreateSample(
      this.characters,
      new String[]{},
      this.fontTestingDatas,
    3, startDef);
  
    for(int k = 0; k <= phaseNumber; k++) {
      cl.pln("\nPhase", k, "/", phaseNumber);
  
      float deformationRate = map(k, 1, phaseNumber, startDef, endDef);
  
      if(k > 1) {
  
        testSampleHand = ds.CreateSample(
          this.characters,
          this.handTestingDatas,
          new String[]{},
        3, deformationRate);
  
        testSampleFont = ds.CreateSample(
          this.characters,
          new String[]{},
          this.fontTestingDatas,
        3, deformationRate);
      }
  
      if(k != 0) {
        repList = RepList(accuracy, rep, minProp);
  
        sample = ds.CreateSample(
          this.characters,
          this.handTrainingDatas,
          //new String[]{},
          this.fontTrainingDatas,
          repList, deformationRate);
  
        float maxLR = startMaxLR * pow(endMaxLR / startMaxLR, (float)(k-1)/max(1, (phaseNumber-1)));
        float minLR = startMinLR * pow(endMinLR / startMinLR, (float)(k-1)/max(1, (phaseNumber-1)));
        this.nn.MiniBatchLearn(sample, epochPerSet, batchSize, minLR, maxLR, period, new Matrix[][]{testSampleHand, testSampleFont}, k + "/" + phaseNumber);
      }
  
      if(k >= 1) {
        Matrix[] shuffledSample = new Matrix(0).ShuffleCol(sample);
        cl.pln("Accuracy on training set :", String.format("%6.3f", Average(CompilScore(this.AccuracyScore(this.nn, shuffledSample, false)))));
      }
  
      accuracy = CompilScore(this.AccuracyScore(this.nn, new Matrix[][]{testSampleHand, testSampleFont}, false));
  
      cl.pln("Accuracy for test set :", String.format("%6.3f", Average(accuracy)));
      cl.pln();
  
      cl.Update();
    }
    
    cl.pln("Training End");
  }
  
  //f Teste _this.nn_ sur les sets de tests
  void TestImages() {
    frame.setSize(floor(hp.w * rScale * this.characters.length), floor(hp.h * rScale * numOfTestSample));
    Matrix[] testSample = ds.CreateSample(
      this.characters,
      this.handTestingDatas,
      // new String[]{},
      this.fontTestingDatas,
      4, testDerformation);
  
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
  int brushSize = 32;
  
  //f Permet de tester en direct les performances du réseau
  void DirectTest() {
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
  
    ArrayList<ArrayList<PVector>> contours = im.ContourDetection(img);
    for(ArrayList<PVector> contour : contours) {
      if(!im.IsClockwise(contour)) continue;
  
      PImage c = im.ImageFromContour(img, contour, 0.02, 0.89);
      if(keyPressed && keyCode == ENTER) {
        fill(0,255,0);
        text(Result(c).keyArray()[0], contour.get(0).x, contour.get(0).y);
      }
      print(Result(c).keyArray()[0], "");
    }
    println();
  }
  
  float[][] AccuracyScore(NeuralNetwork nn, Matrix[] data, boolean doDraw) {
    return AccuracyScore(nn, new Matrix[][]{data}, doDraw);
  }
  
  float[][] AccuracyScore(NeuralNetwork nn, Matrix[][] data, boolean doDraw) {
    float[][] score = new float[data.length][data[0][1].n];
    int[][] countOutput = new int[data.length][data[0][1].n]; // Compte le nombre d'output ayant pour retour i
  
    int ret = 0; // To draw
    for(int k = 0; k < data.length; k++) {
      Matrix[] d = data[k];
      Matrix prediction = this.nn.Predict(d[0]);
  
      int x = 0; int y = 0;
      textAlign(LEFT, BOTTOM); textSize(hp.w); fill(255,0,0);
  
      int mIndex; double m; // Recherche de la prédiction la plus haute
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
          x = floor(floor(rScale*hp.h*ret) / height * rScale * hp.w);
          y = floor(floor(rScale*hp.h*ret) % height);
          image(ds.GetImageFromInputs(d[0], j), x, y, rScale*hp.w, rScale*hp.h);
  
          noStroke();
          rect(x, y, rScale * hp.w, rScale * hp.h);
  
          if(!isGood) {
            fill(200);
            textSize(rScale * hp.w);
            text(characters[mIndex], x, y, rScale*hp.w, rScale*hp.h);
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
  
  double[] ImgPP(PImage img) { // Images post-processing
    double[] nImg = new double[hp.w*hp.h];
    PImage PPImage = im.Gray(img);
    PPImage = im.Contrast(PPImage, 0.015);
    PPImage = im.AutoCrop(PPImage, 210, 0.05);
    //PPImage = im.Contrast(PPImage, 0.02); // If there is a dark patch in the center
  
    im.Resize(PPImage, hp.w, hp.h);
    PPImage.loadPixels();
    for(int k = 0; k < PPImage.pixels.length; k++) nImg[k] = 1 - (float)brightness(PPImage.pixels[k]) / 255;
  
    return nImg;
  }
  
  FloatDict Result(PImage img) {
    FloatDict result = new FloatDict();
  
    double[] input = ImgPP(img);
    Matrix inputMatrix = new Matrix(hp.w*hp.h,1).ColumnFromArray(0, input);
  
    Matrix outputMatrix = nn.Predict(inputMatrix);
    for(int c = 0; c < outputMatrix.n; c++) {
      result.set(characters[c], (float)outputMatrix.Get(c, 0));
    }
  
    result.sortValuesReverse();
  
    return result;
  }
  
}
