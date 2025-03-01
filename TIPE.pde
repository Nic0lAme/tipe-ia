Matrix[] sample;
LetterDataset dataset;
ConsoleLog cl;
ImageManager im;
int w = 19;
int h = 21;
int rScale = 2; // Scale for the representations (draw)
//String[] characters = new String[]{"0","1","2","3","4","5","6","7","8","9"};
//String[] characters = new String[]{"uA","uB","uC","uD","uE","uF","uG","uH","uI","uJ","uK","uL","uM","uN","uO","uP","uQ","uR","uS","uT","uU","uV","uW","uX","uY","uZ"};
String[] characters = new String[]{
  "uA","uB","uC","uD","uE","uF","uG","uH","uI","uJ","uK","uL","uM","uN","uO","uP","uQ","uR","uS","uT","uU","uV","uW","uX","uY","uZ",
  "la","lb","lc","ld","le","lf","lg","lh","li","lj","lk","ll","lm","ln","lo","lp","lq","lr","ls","lt","lu","lv","lw","lx","ly","lz",
  "0","1","2","3","4","5","6","7","8","9", "+", "-", "cr",
  "@","#","'","pt","im","!","tp","€","$","%","(",")","="
};
int numOfTestSample = 24; //This is just for the tests, not the training
String nameOfProcess; // Name to refer these iterations

NeuralNetwork nn;

void settings() {
  size(w * rScale * characters.length, h * rScale * numOfTestSample, P2D); // For Global Test
  //size(119, 180, P2D); // For Direct Test
}

void setup() {
  background(255);
  dataset = new LetterDataset(5*w, 5*h);
  cl = new ConsoleLog("./Log/log1.txt");
  nameOfProcess = "GlobalTest2" + str(minute()) + str(hour()) + str(day()) + str(month()) + str(year());
  im = new ImageManager(); 
  
  nn = new NeuralNetwork().Import("./NeuralNetworkSave/GlobalTest4.nn");
  //nn = new NeuralNetwork(w*h, 1024, 256, 256, characters.length);
  nn.UseSoftMax();
  
  //TrainForImages(4, 12, 0.7, 0.05);
  
  nn.Export("./NeuralNetworkSave/GlobalTest4.nn");
}

int index = 0;

void draw() {
  //TestImages();
  DirectTest();
}

void TrainForImages(int N, int epochPerSet, float startLR, float endLR) {
  float[] accuracy = new float[nn.outputSize];
  int[] repList;
  Arrays.fill(accuracy, 0.5);

  for(int k = 0; k <= N; k++) {
    cl.pln("\nPhase", k, "/", N);

    if(k != 0) {
      repList = RepList(accuracy, 16, 0.6);

      sample = dataset.CreateSample(
        characters,
        new String[]{"NicolasMA", "LenaME", "ElioKE", "AkramBE", "MaximeMB", "TheoLA", "MatteoPR"},
        //new String[]{},
        new String[]{"Arial", "DejaVu Serif", "Fira Code Retina Moyen", "Consolas", "Noto Serif", "Lucida Handwriting Italique", "Playwrite IT Moderna", "Gabriola", "Just Another Hand"},
        repList);
      
      float lr = startLR * pow(endLR / startLR, k/N);
      nn.MiniBatchLearn(sample, epochPerSet, 64, lr/20, lr, 2, k + "/" + N);
    }
    
    if(k == N) break; //Pas besoin de restester
    
    Matrix[] testSample = dataset.CreateSample(
      characters,
      new String[]{"MrMollier", "MrChauvet", "SachaBE"},
      new String[]{"Liberation Serif", "Calibri", "Book Antiqua"},
    5);

    accuracy = AccuracyScore(nn, testSample[0], testSample[1], true);

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
    new String[]{"MrMollier", "MrChauvet", "SachaBE"},
    // new String[]{},
    new String[]{"Comic Sans MS", "Calibri", "Liberation Serif", "Roboto", "Book Antiqua"},
    3);


  float[] score = AccuracyScore(nn, testSample[0], testSample[1], true);
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


float[] AccuracyScore(NeuralNetwork nn, Matrix inputs, Matrix outputs, boolean doDraw) {
  float[] score = new float[outputs.n];
  int[] countOutput = new int[outputs.n]; // Compte le nombre d'output ayant pour retour i

  Matrix prediction = nn.Predict(inputs);

  int x = 0; int y = 0;
  textAlign(LEFT, BOTTOM); textSize(w); fill(255,0,0);

  int mIndex; double m; // Recherche de la prédiction la plus haute
  for(int j = 0; j < inputs.p; j++) {
    fill(255,0,0,100);

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
          fill(0,255,0,100);
        }
      }
    }


    if(doDraw) {
      x = floor((rScale*h*j) / height) * rScale * w;
      y = (rScale*h*j) % height;
      image(dataset.GetImageFromInputs(inputs, j), x, y, rScale*w, rScale*h);
      
      noStroke();
      rect(x, y, rScale * w, rScale * h);
      
      fill(100);
      textSize(rScale * w * 0.7);
      text(characters[mIndex], x, y, rScale*w, rScale*h);
    }
  }

  for(int i = 0; i < outputs.n; i++) {
    score[i] = countOutput[i] != 0 ? score[i] / (float)countOutput[i] : 0;
  }

  return score;
}

double[] ImgPP(PImage img) { // Images post-processing
  double[] nImg = new double[w*h];
  PImage PPImage = im.Gray(img);
  PPImage = im.Contrast(PPImage, 0.03);
  PPImage = im.AutoCrop(PPImage, 72, 0.07);
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

String RemainingTime(int startTime, int step, int totalStep) {
  return String.format("%.3f", (float)(millis() - startTime) / 1000 * (totalStep - step) / step);
}
