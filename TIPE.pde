Matrix[] sample;
LetterDataset dataset;
int w = 19;
int h = 21;

NeuralNetwork nn;

float accuracyOfTraining;

void settings() {
  size(w*5*10, h*5*10, P3D);
}

void setup() {
  background(255);

  nn = new NeuralNetwork(w*h, 128, 32, 32, 10);
  nn.UseSoftMax();
  println(nn);

  dataset = new LetterDataset(w, h);
  sample = dataset.CreateSample(
    new String[]{"0","1","2","3","4","5","6","7","8","9"},
    new String[]{"NicolasMA", "AntoineME", "LenaME", "ElioKE", "AkramBE", "TheoLA"},
    new String[]{"Arial", "Consolas"},
    8);
  
  nn.LearningPhase(sample[0], sample[1], 10000, 0.003, 0.1, 25);
  
  nn.Export("./NeuralNetworkSave/Figures10kEpochTest1.nn");
  
  accuracyOfTraining = AccuracyScore(nn, sample[0], sample[1]);

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
    new String[]{"Comic Sans MS", "DejaVu Serif"},
    2);
    
  System.gc();

  println("Training Set Score :", accuracyOfTraining, "\t-\tTraining Set Score :", AccuracyScore(nn, testSample[0], testSample[1]));
}

float AccuracyScore(NeuralNetwork nn, Matrix inputs, Matrix outputs) {
  float score = 0;

  Matrix prediction = nn.Predict(inputs);

  int x = 0;
  int y = 0;
  int mIndex;
  double m;
  
  textAlign(LEFT, BOTTOM);
  fill(255);
  for(int j = 0; j < inputs.p; j++) {
    x = (5*w*j) % width;
    y = floor((5*w*j) / width) * 5 * h;
    image(dataset.GetImageFromInputs(inputs, j), x, y, 5*w, 5*h);
    
    mIndex = 0;
    m = outputs.Get(0, j);
    for(int i = 0; i < outputs.n; i++) {
      if(prediction.Get(i, j) > m) {
        mIndex = i;
        m = prediction.Get(mIndex, j);
      }
    }
    
    text(str(mIndex), x, y, 5*w, 5*h);
    
    for(int i = 0; i < outputs.n; i++) {
      if(outputs.Get(i,j) == 1 && mIndex == i) score += 1;
    }
  }

  return score / inputs.p;
}
