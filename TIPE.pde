Matrix[] sample;
LetterDataset dataset;
int w = 19;
int h = 21;

void setup() {
  size(500, 500, P3D);
  background(255);

  NeuralNetwork nn = new NeuralNetwork(w*h, 64, 32, 2);
  nn.UseSoftMax();
  println(nn);

  dataset = new LetterDataset(w, h);
  sample = dataset.CreateSample(
    new String[]{"uA", "uB"},
    new String[]{"NicolasMA", "AntoineME", "LenaME", "ElioKE", "AkramBE", "TheoLA"},
    new String[]{"Arial", "Consolas"},
    12);

  for(int k = 0; k < 100; k++)
    println(k+1, "\t-\t", nn.Learn(sample[0], sample[1], 0.1));

  println(AccuracyScore(nn, sample[0], sample[1]));

  frameRate(5);
}

int index = 0;

void draw() {
  background(255);
  // PImage img = dataset.GetImageFromInputs(sample[0], index);
  // imageMode(CENTER);
  // image(img, width/2, height/2, w, h);
  // index = (index+1)%sample[0].p;
}

float AccuracyScore(NeuralNetwork nn, Matrix inputs, Matrix outputs) {
  float score = 0;

  Matrix prediction = nn.Predict(inputs);

  prediction.Debug();
  outputs.Debug();

  for(int j = 0; j < inputs.p; j++) {
    for(int i = 0; i < outputs.n; i++) {
      if(outputs.Get(i,j) == 0) {
        score += prediction.Get(i,j);
        break;
      }
    }
  }

  return score / inputs.p;
}
