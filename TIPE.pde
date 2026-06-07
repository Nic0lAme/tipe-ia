String nameOfProcess = "GlobalTest5" + str(minute()) + str(hour()) + str(day()) + str(month()) + str(year());

ConsoleLog cl;
ImageManager im;
GraphApplet graphApplet;
DraftingArea draftingArea;
Frame frame;
WordCorrector wc;
Database db;
Session session;
CharactersStorage cs;
ImageReader ir;

MatrixMultKernel matrixMultKernel;
NextGradKernel nextGradKernel;
ForwardConvolutionKernel forwardConvolutionKernel;

int convolutionTime = 0;
int numOfHyperParameters = 18;
final boolean enableDraftingArea = false;
float rScale = 1; // Échelle pour la représentation graphique
float testDerformation = 1;
Random globalRandom = new Random();
String globalSketchPath;

int imgSize = 22;

// Nombre de threads pour les différentes tâches
final int numThreadsDataset = 12; // Création des datasets
final int numThreadsLearning = 1; // Apprentissage (si 1, pas de parallélisation)
boolean doGPUMult = true;

// Attention, à ne pas modifier n'importe comment
final AtomicBoolean stopLearning = new AtomicBoolean(false);
final AtomicBoolean abortTraining = new AtomicBoolean(false); // Note : Annule aussi toute construction de dataset

Matrix[][] testSample;

void settings() {
  size(floor(28 * rScale * 26), floor(28 * rScale * numOfTestSample), JAVA2D); // Pour le test global
  //size(119, 180, P2D); // Pour le test en direct
}

void setup() {
  // Fonctions pour initialiser les différentes parties
  background(255);
  globalSketchPath = sketchPath();
  cl = new ConsoleLog("./Log/log1.txt");

  matrixMultKernel = new MatrixMultKernel();
  nextGradKernel = new NextGradKernel();
  forwardConvolutionKernel = new ForwardConvolutionKernel();

  cs = new CharactersStorage();
  cs.LoadFull();

  frame = (Frame) ((processing.awt.PSurfaceAWT.SmoothCanvas) surface.getNative()).getFrame();
  frame.setVisible(false); // Cache la fenêtre d'activation java
  frame.setResizable(true);

  im = new ImageManager();
  graphApplet = new GraphApplet();

  wc = new WordCorrector();
  wc.ImportWords();

  if (enableDraftingArea) draftingArea = new DraftingArea();

  db = new Database("https://tipe-877f6-default-rtdb.europe-west1.firebasedatabase.app/");
  HyperParameters hp = new HyperParameters();
  session = new Session("", hp);

  /*
  PImage toScramble = loadImage("./TextFileGetter/output/uG/uG - NicolasMA.jpg");
  ScrambleVisual sv = new ScrambleVisual(toScramble, 28, 28, 7, 5, "NicolasMA G");
  */

  // Exemple de code pour séparer les lettres au sein d'une image
  // ImageSeparator is = new ImageSeparator(loadImage("imgage.png"));
  // is.SaveSeparationPreview("visualisation.png", true, true);
  // exit();

  // Exemple de code pour entrainer un réseau de neurones
  NeuralNetwork nn = new NeuralNetwork(imgSize*imgSize, 95, 85, cs.GetChars().length);
  nn.UseSoftMax();
  Matrix[] testSample = session.ds.SampleLining(session.ds.CreateSample(
      cs.GetChars(),
      //new String[]{"NicolasMA", "AntoineME", "LenaME", "IrinaRU", "TheoLA"},
      // handTestingDatas,
      new String[]{},
      fontTestingDatas,
      2, 1));


  int numOfIter = 10;
  String tr = "", ts = "";
  for(int iter = 0; iter < numOfIter; iter++) {
    cl.pln("ITERATION " + str(iter+1) + "/" + str(numOfIter));
    float[] accuracy = CompilScore(session.AccuracyScore(nn, new Matrix[][]{testSample}, false));
    int[] repList = RepList(accuracy, 2, 0.2);

    Matrix[] sample = session.ds.SampleLining(session.ds.CreateSample(
        cs.GetChars(),
        //new String[]{"NicolasMA", "AntoineME", "LenaME", "IrinaRU", "TheoLA"},
        // handTrainingDatas,
        new String[]{},
        biggerFontTrainingDatas,
        repList, 2));

    nn.MiniBatchLearn(sample, 2, 150, 5, 5, 12, new Matrix[][]{testSample, sample}, "");

    float[] accuracyTest = CompilScore(session.AccuracyScore(nn, testSample, false));
    float averageTestingAccuracy = Average(accuracyTest);

    Matrix[] shuffledSample = new Matrix(0).ShuffleCol(sample);
    float[] accuracyTrain = CompilScore(session.AccuracyScore(nn, shuffledSample, false));
    float averageTrainingAccuracy = Average(accuracyTrain);

    graphApplet.AddTestResult(averageTrainingAccuracy, averageTestingAccuracy);
    tr = String.format("%.2f",averageTrainingAccuracy*100);
    ts = String.format("%.2f",averageTestingAccuracy*100);

    try {
      Thread.sleep(2000);
    } catch (Exception e) {
    }
  }
}

int index = 0;
boolean testImages = true;
boolean directTest = false;

void draw() {
  if(testImages) session.TestImages();
  //if(directTest) session.DirectTest();
}

void SetMainSession(Session newSession) {
  session = newSession;
  graphApplet.SetNetworkName(session.nn.toString());
}

// Outils divers

// Renvoie une liste de repetitions pour chaque caractères en fonction de la performance précédente
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

void SaveIntListAsCSV(int[] list, String filename) {
  String line = "";
  for(int i = 0; i < list.length; i++) {
    line += list[i];
    if (i < list.length - 1) line += ",";
  }

  saveStrings(filename, new String[]{line});
}


double Variance(float[] a) {
    int n = a.length;

    float sum = 0;
    for (int i = 0; i < n; i++)
        sum += a[i];
    double mean = (double)sum /
                  (double)n;

    double sqDiff = 0;
    for (int i = 0; i < n; i++)
        sqDiff += (a[i] - mean) *
                  (a[i] - mean);
    return sqDiff / n;
}

double StandardDeviation(float[] arr) {
    return sqrt((float)Variance(arr));
}
