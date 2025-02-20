Matrix[] sample;
LetterDataset dataset;
ConsoleLog cl;
int w = 19;
int h = 21;

NeuralNetwork nn;

void settings() {
  size(w*5*10, h*5*10, P3D);
}

void setup() {
  background(255);
  dataset = new LetterDataset(w, h);
  cl = new ConsoleLog("./Log/log1.txt");
  
  //nn = new NeuralNetwork(w*h, 256, 64, 64, 32, 10);
  nn = new NeuralNetwork().Import("./NeuralNetworkSave/Figures256646432_20022025.nn");
  nn.UseSoftMax();

  
  nn.UseSoftMax();
  cl.pln(nn);

  int N = 16;
  float[] accuracy = new float[nn.outputSize];
  int[] repList;
  Arrays.fill(accuracy, 0.5);
  
  for(int k = 0; k <= N; k++) {   
    repList = RepList(accuracy, 12, 0.6);
    
    sample = dataset.CreateSample(
      new String[]{"0","1","2","3","4","5","6","7","8","9"},
      new String[]{"NicolasMA", "AntoineME", "LenaME", "ElioKE", "AkramBE", "TheoLA", "MatteoPR", "MaximeMB"},
      new String[]{"Arial", "Consolas", "Fira Code Retina Moyen", "Noto Serif", "Liberation Serif"},
      repList);
    
    cl.pln("\nPhase", k+1, "/", N);
    cl.pln(repList);
    nn.LearningPhase(sample[0], sample[1], k == 0 ? 1 : 2048, 0.003, 0.05, 256, 256, str(k) + "/" + str(N));
    
    sample[0].Delete();
    sample[1].Delete();
    
    Matrix[] testSample = dataset.CreateSample(
      new String[]{"0","1","2","3","4","5","6","7","8","9"},
      new String[]{"MrMollier", "MrChauvet", "SachaBE"},
      new String[]{"Comic Sans MS", "Calibri"},
    10);
    
    accuracy = AccuracyScore(nn, testSample[0], testSample[1], false);
    
    testSample[0].Delete();
    testSample[1].Delete();
    System.gc();
    
    cl.pln("Accuracy :", Average(accuracy));
    cl.pln();
    
    cl.Update();
  }
  
  nn.Export("./NeuralNetworkSave/Figures256646432_20022025.nn");
  
  
  frameRate(1);
}

int index = 0;

void draw() {
  background(255);
  // PImage img = dataset.GetImageFromInputs(sample[0], index);
  // imageMode(CENTER);
  // image(img, width/2, height/2, w, h);
  // index = (index+1)%sample[0].p;
  
  Matrix[] testSample = dataset.CreateSample(
    new String[]{"0","1","2","3","4","5","6","7","8","9"},
    new String[]{"MrMollier", "MrChauvet", "SachaBE"},
    new String[]{"Comic Sans MS", "Calibri"},
    2);
    

  cl.pln("Training Set Score :", Average(AccuracyScore(nn, testSample[0], testSample[1], true)));
  
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
    mIndex = 0;
    m = outputs.Get(0, j);
    for(int i = 0; i < outputs.n; i++) {
      if(prediction.Get(i, j) > m) {
        mIndex = i;
        m = prediction.Get(mIndex, j);
      }
    }
    
    for(int i = 0; i < outputs.n; i++) {
      if(outputs.Get(i,j) == 1) {
        countOutput[i] += 1;
        if(mIndex == i) score[i] += 1;
      }
    }
    
    
    if(doDraw) {
      x = (5*w*j) % width;
      y = floor((5*w*j) / width) * 5 * h;
      image(dataset.GetImageFromInputs(inputs, j), x, y, 5*w, 5*h);
      text(str(mIndex), x, y, 5*w, 5*h);
    }
  }
  
  for(int i = 0; i < outputs.n; i++) {
    score[i] /= (float)countOutput[i];
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
