import java.util.List;

String nameOfProcess = "GlobalTest5" + str(minute()) + str(hour()) + str(day()) + str(month()) + str(year());

NeuralNetwork nn;
Matrix[] sample;
LetterDataset dataset;
ConsoleLog cl;
ImageManager im;
GraphApplet graphApplet;// = new GraphApplet(nameOfProcess);

// Nombre de threads pour les différentes tâches
final int numThreadsDataset = 8; // Création des datasets
final int numThreadsLearning = 8; // Apprentissage (si 1, pas de parallélisation)

int w = 19;
int h = 21;
float rScale = 1; // Scale for the representations (draw)
float testDerformation = 0.5;

//String[] characters = new String[]{"0","1","2","3","4","5","6","7","8","9"};
//String[] characters = new String[]{"uA","uB","uC","uD","uE","uF","uG","uH","uI","uJ","uK","uL","uM","uN","uO","uP","uQ","uR","uS","uT","uU","uV","uW","uX","uY","uZ"};
String[] characters = new String[]{
  "uA","uB","uC","uD","uE","uF","uG","uH","uI","uJ","uK","uL","uM","uN","uO","uP","uQ","uR","uS","uT","uU","uV","uW","uX","uY","uZ",
  "la","lb","lc","ld","le","lf","lg","lh","li","lj","lk","ll","lm","ln","lo","lp","lq","lr","ls","lt","lu","lv","lw","lx","ly","lz",
  "0","1","2","3","4","5","6","7","8","9", "+", "-", "cr",
  "@","#","'","pt","im","!","tp","€","$","%","(",")","="
};
int numOfTestSample = 40; //This is just for the tests, not the training


String[] handTrainingDatas = new String[]{"AntoineME", "NicolasMA", "LenaME", "AkramBE", "MaximeMB", "NathanLU", "LubinDE", "MatheoLB", "SachaAD", "MatisBR", "RomaneFI", "ThelioLA", "YanisIH"};
String[] fontTrainingDatas = new String[]{"Arial", "DejaVu Serif", "Fira Code Retina Moyen", "Consolas", "Lucida Handwriting Italique", "Playwrite IT Moderna", "Just Another Hand"};

String[] handTestingDatas = new String[]{"MrMollier", "MrChauvet", "SachaBE", "IrinaRU", "NoematheoBLB"};
String[] fontTestingDatas = new String[]{"Liberation Serif", "Calibri", "Book Antiqua", "Gabriola", "Noto Serif"};

void settings() {
  size(floor(w * rScale * characters.length), floor(h * rScale * numOfTestSample), P2D); // For Global Test
  //size(119, 180, P2D); // For Direct Test
}

void setup() {
  background(255);
  dataset = new LetterDataset(5*w, 5*h);
  cl = new ConsoleLog("./Log/log1.txt");
  im = new ImageManager();

  // nn = new NeuralNetwork().Import("./NeuralNetworkSave/GlobalTest7.nn");
  nn = new NeuralNetwork(w*h, 512, 64, 64, 64, characters.length);
  nn.UseSoftMax();

  // TrainForImages(
  //   12, 16,     // # of phase - # of epoch per phase
  //   1.5, 0.5, // Learning Rate
  //   0.5, 0.5,     // Deformation Rate
  //   10, 0.8);    // Repetition - Min prop


  // nn.Export("./NeuralNetworkSave/GlobalTest7.nn");
}

int index = 0;

void draw() {
  TestImages();
  //DirectTest();
}

void TrainForImages(int phaseNumber, int epochPerSet, float startLR, float endLR, float startDef, float endDef, int rep, float minProp) {
  float[] accuracy = new float[nn.outputSize];
  int[] repList;
  Arrays.fill(accuracy, 0.5);

  Matrix[] testSampleHand = dataset.CreateSample(
    characters,
    handTestingDatas,
    new String[]{},
  3, startDef);

  Matrix[] testSampleFont = dataset.CreateSample(
    characters,
    new String[]{},
    fontTestingDatas,
  3, startDef);

  for(int k = 0; k <= phaseNumber; k++) {
    cl.pln("\nPhase", k, "/", phaseNumber);

    float deformationRate = map(k, 1, phaseNumber, startDef, endDef);

    if(k > 1) {

      testSampleHand = dataset.CreateSample(
        characters,
        handTestingDatas,
        new String[]{},
      3, deformationRate);

      testSampleFont = dataset.CreateSample(
        characters,
        new String[]{},
        fontTestingDatas,
      3, deformationRate);
    }

    if(k != 0) {
      repList = RepList(accuracy, rep, minProp);

      sample = dataset.CreateSample(
        characters,
        handTrainingDatas,
        //new String[]{},
        fontTrainingDatas,
        repList, deformationRate);

      float lr = startLR * pow(endLR / startLR, (float)(k-1)/max(1, (phaseNumber-1)));
      nn.MiniBatchLearn(sample, epochPerSet, 64, lr/32, lr, 2, new Matrix[][]{testSampleHand, testSampleFont}, k + "/" + phaseNumber);
    }

    if(k == phaseNumber) break; //Pas besoin de retester

    accuracy = CompilScore(AccuracyScore(nn, new Matrix[][]{testSampleHand, testSampleFont}, true));

    cl.pln("Accuracy for test set :", Average(accuracy));
    cl.pln();

    cl.Update();
  }
}

void TestImages() {
  if(frameCount != 0) delay(10000);
  background(255);

  Matrix[] testSample = dataset.CreateSample(
    characters,
    handTestingDatas,
    // new String[]{},
    fontTestingDatas,
    4, testDerformation);


  float[] score = CompilScore(AccuracyScore(nn, testSample, true));
  cl.pln("Training Set Score :", Average(score));
  cl.pFloatList(score, "Accuracy");
  save("./Representation/" + str(frameCount) + " " + str(Average(score)) + " " + nameOfProcess + ".jpg");

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

/* HOW TO USE DIRECT TEST
  click to write (left -> black, right -> white)
  +/- to change brush size
  space to reset
  enter to show prediction directly on the sketch
*/
int brushSize = 32;
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
    Matrix prediction = nn.Predict(d[0]);

    int x = 0; int y = 0;
    textAlign(LEFT, BOTTOM); textSize(w); fill(255,0,0);

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
        x = floor(floor(rScale*h*ret) / height * rScale * w);
        y = floor(floor(rScale*h*ret) % height);
        image(dataset.GetImageFromInputs(d[0], j), x, y, rScale*w, rScale*h);

        noStroke();
        rect(x, y, rScale * w, rScale * h);

        if(!isGood) {
          fill(200);
          textSize(rScale * w);
          text(characters[mIndex], x, y, rScale*w, rScale*h);
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
  double[] nImg = new double[w*h];
  PImage PPImage = im.Gray(img);
  PPImage = im.Contrast(PPImage, 0.015);
  PPImage = im.AutoCrop(PPImage, 210, 0.05);
  //PPImage = im.Contrast(PPImage, 0.02); // If there is a dark patch in the center

  im.Resize(PPImage, w, h);
  PPImage.loadPixels();
  for(int k = 0; k < PPImage.pixels.length; k++) nImg[k] = (float)brightness(PPImage.pixels[k]) / 255;

  return nImg;
}

FloatDict Result(PImage img) {
  FloatDict result = new FloatDict();

  double[] input = ImgPP(img);
  Matrix inputMatrix = new Matrix(w*h,1).ColumnFromArray(0, input);

  Matrix outputMatrix = nn.Predict(inputMatrix);
  for(int c = 0; c < outputMatrix.n; c++) {
    result.set(characters[c], (float)outputMatrix.Get(c, 0));
  }

  result.sortValuesReverse();

  return result;
}


// TOOL

// return a list of the repetition needed depending on the performance for each characters
int[] RepList(float[] score, int baseRep, float minProp) {
  float[] logScore = new float[score.length];
  for(int k = 0; k < score.length; k++) logScore[k] = -log(0.9 * (score[k] - 1) + 1);

  float sum = 0;
  for(int k = 0; k < score.length; k++) sum += logScore[k];

  if(sum == 0) sum = 1; // Dans le cas où tout vaut 1, dans tous les cas on ne changera rien

  int[] repList = new int[score.length];
  for(int k = 0; k < score.length; k++) repList[k] = max(floor((minProp / score.length + (1 - minProp) * logScore[k] / sum)  * baseRep * score.length), 1);

  return repList;
}



float Sum(float[] list) {
  float sum = 0;
  for(int k = 0; k < list.length; k++) sum += list[k];
  return sum;
}

float[] CompilScore(float[][] list) {
  float[] score = new float[list[0].length];
  for(float[] l : list) {
    for(int s = 0; s < list[0].length; s++) score[s] += (float)l[s] / list.length;
  }

  return score;
}

float Average(float[][] list) {
  int s = 0;
  for(int k = 0; k < list.length; k++) s+=list[k].length;
  float[] lst = new float[s];

  int index = 0;
  for(int k = 0; k < list.length; k++) {
    for(int i = 0; i < list[k].length; i++) {
      lst[index] = list[k][i];
      index++;
    }
  }

  return Average(lst);
}

float Average(float[] list) {
  float avg = 0;
  for(int k = 0; k < list.length; k++) avg += list[k] / list.length;
  return avg;
}

String RemainingTime(int startTime, int step, int totalStep) {
  return String.format("%9.3f", (float)(millis() - startTime) / 1000 * (totalStep - step) / step);
}
