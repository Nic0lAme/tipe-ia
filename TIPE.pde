Matrix[] sample;
LetterDataset dataset;
ConsoleLog cl;
int w = 19;
int h = 21;
int rScale = 2; // Scale for the representations (draw)
//String[] characters = new String[]{"0","1","2","3","4","5","6","7","8","9"};
String[] characters = new String[]{"uA","uB","uC","uD","uE","uF","uG","uH","uI","uJ","uK","uL","uM","uN","uO","uP","uQ","uR","uS","uT","uU","uV","uW","uX","uY","uZ"};
int numOfTestSample = 20;
String nameOfProcess; // Name to refer these iterations

NeuralNetwork nn;

void settings() {
  size(w * rScale * characters.length, h * rScale * numOfTestSample, P3D);
}

void setup() {
  background(255);
  dataset = new LetterDataset(w, h);
  cl = new ConsoleLog("./Log/log1.txt");
  nameOfProcess = "LetterTest2" + str(minute()) + str(hour()) + str(day()) + str(month()) + str(year());
  
  //nn = new NeuralNetwork(w*h, 512, 64, 64, 64, characters.length);
  nn = new NeuralNetwork().Import("./NeuralNetworkSave/LetterTest4.nn");
  
  TrainForImages();
}

int index = 0;

void draw() {
  background(255);
  // PImage img = dataset.GetImageFromInputs(sample[0], index);
  // imageMode(CENTER);
  // image(img, width/2, height/2, w, h);
  // index = (index+1)%sample[0].p;
  
  TestImages();
  
  delay(10000);
}

void TrainForImages() {
  nn.UseSoftMax();
  cl.pln(nn);

  int N = 8;
  float[] accuracy = new float[nn.outputSize];
  int[] repList;
  Arrays.fill(accuracy, 0.5);
  
  for(int k = 0; k <= N; k++) {
    cl.pln("\nPhase", k, "/", N);
    
    if(k != 0) {
      repList = RepList(accuracy, 8, 0.5);
      cl.pFloatList(float(repList), "Repetition list");
      
      sample = dataset.CreateSample(
        characters,
        new String[]{"NicolasMA", "LenaME", "ElioKE", "AkramBE", "MaximeMB"},
        new String[]{"Consolas", "Noto Serif", "Liberation Serif", "Roboto", "Playwrite IT Moderna", "Just Another Hand"},
        repList);
      
      nn.LearningPhase(
        ImgPP(sample[0]),            // X
        sample[1],            // Y
        1024,                 // Number of iteration (not epoch actually)
        0.02,                // Min learning rate
        0.8,                 // Max learning rate
        256,                  // Learning Rate period
        256,                  // Number of sample taken by iteration
        str(k) + "/" + str(N) // Label
      );
      
      sample[0].Delete();
      sample[1].Delete();
    }
    
    Matrix[] testSample = dataset.CreateSample(
      characters,
      new String[]{"MrMollier", "MrChauvet", "SachaBE"},
      new String[]{"Comic Sans MS", "Calibri"},
    5);
    
    accuracy = AccuracyScore(nn, ImgPP(testSample[0]), testSample[1], true);
    
    testSample[0].Delete();
    testSample[1].Delete();
    System.gc();
    
    cl.pln("Accuracy :", Average(accuracy));
    cl.pln();
    
    cl.Update();
  }
  
  nn.Export("./NeuralNetworkSave/LetterTest4.nn");
}

void TestImages() {
  Matrix[] testSample = dataset.CreateSample(
    characters,
    new String[]{"MrMollier", "MrChauvet", "SachaBE"},
    new String[]{"Comic Sans MS", "Calibri"},
    4);
    
  
  float[] score = AccuracyScore(nn, ImgPP(testSample[0]), testSample[1], true);
  cl.pln("Training Set Score :", Average(score));
  cl.pFloatList(score, "Accuracy");
  save("./Representation/" + str(frameCount) + " " + nameOfProcess + ".jpg");
  
  testSample[0].Delete();
  testSample[1].Delete();

  System.gc();
  
  cl.Update();
}

void KeyPressed() {
  if(keyCode == ENTER) {
    cl.End();
    exit();
  }
}


float[] AccuracyScore(NeuralNetwork nn, Matrix inputs, Matrix outputs, boolean doDraw) {
  float[] score = new float[outputs.n];
  int[] countOutput = new int[outputs.n]; // Compte le nombre d'output ayant pour retour i

  Matrix prediction = nn.Predict(inputs);

  int x = 0; int y = 0;
  textAlign(LEFT, BOTTOM); textSize(w); fill(255,0,0);
  
  int mIndex; double m; // Recherche de la prédiction la plus haute
  for(int j = 0; j < inputs.p; j++) {
    fill(255,0,0);
    
    mIndex = -1;
    m = -1;
    for(int i = 0; i < outputs.n; i++) {
      if(prediction.Get(i, j) > m) {
        mIndex = i;
        m = prediction.Get(mIndex, j);
      }
    }
    
    for(int i = 0; i < outputs.n; i++) {
      if(outputs.Get(i,j) == 1) {
        countOutput[i] += 1;
        if(mIndex == i) {
          score[i] += 1;
          fill(0,255,0);
        }
      }
    }
    
    
    if(doDraw) {
      x = floor((rScale*h*j) / height) * rScale * w;
      y = (rScale*h*j) % height;
      image(dataset.GetImageFromInputs(inputs, j), x, y, rScale*w, rScale*h);
      text(characters[mIndex], x, y, rScale*w, rScale*h);
    }
  }
  
  for(int i = 0; i < outputs.n; i++) {
    score[i] = countOutput[i] != 0 ? score[i] / (float)countOutput[i] : 0;
  }

  return score;
}

// return a list of the repetition needed depending on the performance for each characters
int[] RepList(float[] score, int baseRep, float minProp) {
  float[] logScore = new float[score.length];
  for(int k = 0; k < score.length; k++) logScore[k] = -log(0.9 * (score[k] - 1) + 1);
  
  float sum = 0;
  for(int k = 0; k < score.length; k++) sum += logScore[k];
  
  if(sum == 0) sum = 1; // Dans le cas où tout vaut 1, dans tous les cas on ne changera rien
  
  int[] repList = new int[score.length];
  for(int k = 0; k < score.length; k++) repList[k] = floor((minProp / score.length + (1 - minProp) * logScore[k] / sum)  * baseRep * score.length) + 1;
  
  return repList;
}

Matrix ImgPP(Matrix img) { // Images post-processing
  Matrix nImg = img.C();
  
  for(int j = 0; j < img.p; j++) {
    double minVal = 1;
    double maxVal = 0;
    
    for(int i = 0; i < img.n; i++) {
      minVal = Math.min(minVal, img.Get(i,j));
      maxVal = Math.max(maxVal, img.Get(i,j));
    }
    
    if(minVal == maxVal) continue; //Dans le cas où l'image est strictement unie
    
    for(int i = 0; i < img.n; i++) {
      nImg.Set(i,j, ContrastF( (img.Get(i,j) - minVal) / (maxVal - minVal)));
    }
  }
  
  return nImg;
}

double ContrastF(double x) { return x; } //On pourra tenter des trucs plus ambitieux un jour

float Sum(float[] list) {
  float sum = 0;
  for(int k = 0; k < list.length; k++) sum += list[k];
  return sum;
}

float Average(float[] list) {
  float avg = 0;
  for(int k = 0; k < list.length; k++) avg += list[k] / list.length;
  return avg;
}
