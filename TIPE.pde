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

// KERNEL CLASSES
MatrixMultKernel matrixMultKernel;
NextGradKernel nextGradKernel;
ForwardConvolutionKernel forwardConvolutionKernel;

int convolutionTime = 0;
int numOfHyperParameters = 18;
final boolean enableDraftingArea = false;
float rScale = 1; // Scale for the representations (draw)
float testDerformation = 1;
Random globalRandom = new Random();
String globalSketchPath;

int imgSize = 22;

// Nombre de threads pour les différentes tâches
final int numThreadsDataset = 16; // Création des datasets
final int numThreadsLearning = 1; // Apprentissage (si 1, pas de parallélisation)

// Attention, à ne pas modifier n'importe comment sous peine de conséquences
final AtomicBoolean stopLearning = new AtomicBoolean(false);
final AtomicBoolean abortTraining = new AtomicBoolean(false); // Note : Annule aussi toute construction de dataset

Matrix[][] testSample;

void settings() {
  size(floor(28 * rScale * 26), floor(28 * rScale * numOfTestSample), JAVA2D); // For Global Test
  //size(119, 180, P2D); // For Direct Test
}

void setup() {
  background(255);
  globalSketchPath = sketchPath();
  cl = new ConsoleLog("./Log/log1.txt");

  matrixMultKernel = new MatrixMultKernel();
  nextGradKernel = new NextGradKernel();
  forwardConvolutionKernel = new ForwardConvolutionKernel();

  cs = new CharactersStorage();
  cs.LoadLettersOnly();

  frame = (Frame) ((processing.awt.PSurfaceAWT.SmoothCanvas) surface.getNative()).getFrame();
  frame.setVisible(false); // Cache la fenêtre d'activation java
  frame.setResizable(true);

  im = new ImageManager();
  graphApplet = new GraphApplet();

  wc = new WordCorrector();
  wc.ImportWords();

  //wc.CompareFunctions(new DistanceFunction[]{(w1, w2) -> wc.SimpleDistance(w1, w2), (w1, w2) -> wc.LevenshteinDistance(w1, w2)}, 1000, 0.15, 0.05);

  if (enableDraftingArea) draftingArea = new DraftingArea();

  db = new Database("https://tipe-877f6-default-rtdb.europe-west1.firebasedatabase.app/");

  /*
  PImage toScramble = loadImage("./TextFileGetter/output/la/la - MrMollier.jpg");
  ScrambleVisual sv = new ScrambleVisual(toScramble, 78, 87, 7, 5, "Mollier a");
  */

  HyperParameters hp = new HyperParameters();
  session = new Session("", hp);

  // ImageSeparator is1 = new ImageSeparator(loadImage("AuxiliarFiles/FullImage.jpg"));
  // ImageSeparator is2 = new ImageSeparator(loadImage("AuxiliarFiles/OtherTest.jpg"));
  // ImageSeparator is3 = new ImageSeparator(loadImage("AuxiliarFiles/TheLastOne.jpg"));
  // ImageSeparator is4 = new ImageSeparator(loadImage("TextFileGetter/output/Message/Message - MrChauvet.jpg"));
  // is1.SaveSeparationPreview("test1.png", true, true);
  // is2.SaveSeparationPreview("test2.png", true, true);
  // is3.SaveSeparationPreview("test3.png", true, true);
  // is4.SaveSeparationPreview("test4.png", true, true);
  // exit();

  /*
  Bayes bayes = new Bayes("RandomONTeste");
  //bayes.GaussianProcess(5, 5);
  bayes.RandomFill(5, 5);
  */

  /*
  for(int k = 0; k < 10; k++)
    bayes.SERV_Export(new HyperParameters().Random(), random(1));
  */

  //CNN cnn = new CNN(28, new int[]{4, 8}, new int[]{64, cs.GetChars().length});
  // CNN cnn = new CNN().Import("./CNN/Test21.cnn");
  // cnn.UseSoftMax();
  // cnn.useADAM = true;
  //
  /*
  Matrix[][] sample = session.ds.CreateSample(
      cs.GetChars(),
      //new String[]{"NicolasMA", "AntoineME", "LenaME", "IrinaRU", "TheoLA"},
      handTrainingDatas,
      //new String[]{},
      fontTrainingDatas,
      1, 1);

  Matrix[][] testSample = session.ds.CreateSample(
      cs.GetChars(),
      //new String[]{"NicolasMA", "AntoineME", "LenaME", "IrinaRU", "TheoLA"},
      handTestingDatas,
      //new String[]{},
      fontTestingDatas,
      1, 1);

  cnn.MiniBatchLearn(sample, 8, 256, 0.001, 0.001, 2, new Matrix[][][]{testSample}, "");
  cnn.Export("./CNN/Test21.cnn");
  session.AccuracyScore(cnn, testSample, true);
  */

  Tester tester = new Tester((NeuralNetwork) null);
  ImageSeparator is = new ImageSeparator(loadImage("test.png"));
  is.SaveSeparationPreview("test1.png", true, true);
}

int index = 0;
boolean testImages = false;
boolean directTest = false;

void draw() {
  if(testImages) session.TestImages();
  //if(directTest) session.DirectTest();
}

void SetMainSession(Session newSession) {
  session = newSession;
  graphApplet.SetNetworkName(session.nn.toString());
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

void SaveIntListAsCSV(int[] list, String filename) {
  String line = "";
  for(int i = 0; i < list.length; i++) {
    line += list[i];
    if (i < list.length - 1) line += ",";
  }

  saveStrings(filename, new String[]{line});
}
