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
final int numThreadsDataset = 12; // Création des datasets
final int numThreadsLearning = 1; // Apprentissage (si 1, pas de parallélisation)
boolean doGPUMult = true;

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
  cs.LoadFull();

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
  PImage toScramble = loadImage("./TextFileGetter/output/uG/uG - NicolasMA.jpg");
  ScrambleVisual sv = new ScrambleVisual(toScramble, 28, 28, 7, 5, "NicolasMA G");
  */
  

  HyperParameters hp = new HyperParameters();
  session = new Session("", hp);
  
  /* COMPARAISON VITESSE NN AVEC ET SANS MULTITHREADS
  Matrix[][] testSample = session.ds.CreateSample(
       cs.GetChars(),
       //new String[]{"NicolasMA", "AntoineME", "LenaME", "IrinaRU", "TheoLA"},
       handTestingDatas,
       //new String[]{},
       fontTestingDatas,
       8, 1);
       
  CNN cnn = new CNN(imgSize, new int[]{16, 32}, new int[]{256, cs.GetChars().length});
  cnn.UseSoftMax();
  cnn.useADAM = true;
  
  int initTime = millis();
  
  cnn.MiniBatchLearn(testSample,  8, 256, 0.001, 0.001, 2, new Matrix[][][]{testSample}, "");
  
  println("Total time :", millis() - initTime);
  */
  

  /* COMPARAISON VITESSE DE CALCUL CPU & GPU
  
  int totalNormalTime = 0;
  int totalGPUTime = 0;
  int N = 10000;
  int W = 128;
  int H = 128;
  for(int i = 0; i < N; i++) {
    Matrix a = new Matrix(W, H).Random();
    Matrix b = new Matrix(W, H).Random();
    
    int initTime = millis();
    a.Mult(b);
    totalNormalTime += millis() - initTime;
    
    initTime = millis();
    a.GPUMult(b);
    totalGPUTime += millis() - initTime;
    
    println(i, "Normal : ", totalNormalTime / (i+1));
    println(i, "GPU : ", totalGPUTime / (i+1));
  }
  
  println(totalNormalTime);
  println(totalGPUTime);
  
  */

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

  //cl.pln(wc.SimpleDistance(new int[]{21,8,6,7,19}, new int[]{7,4,6,7,19}));

  //CNN cnn = new CNN(imgSize, new int[]{32, 64}, new int[]{256, cs.GetChars().length});

  /////////////////////////////////////////////////////////////////

  // Ça ne compilait plus depuis ton dernier commit j'ai l'impression

  /////////////////////////////////////////////////////////////////

  // CNN cnn = new CNN().Import("./CNN/22x22_32_64_LettersOnly.cnn");
  // cnn.UseSoftMax();
  // cnn.useADAM = true;
  //
  //
  // //NeuralNetwork nn = new NeuralNetwork(0).Import("./NeuralNetworkSave/RepListTest000.nn");
  // NeuralNetwork nn = new NeuralNetwork(imgSize * imgSize, 256, 128, 128, cs.GetChars().length);
  // nn.UseSoftMax();
  //
  //
  // ir = new ImageReader(cnn);
  // //WholeTextTestVisual wttv = new WholeTextTestVisual(100, "Arial", 36);
  // println("NeuralNetwork");
  // println(ir.cnn);
  //
  // String text = ir.Read(loadImage("./AuxiliarFiles/FullImage.jpg"), true);
  // println(text);
  //
  //
  // if(true) return;
  //
  // Matrix[][] testSample = session.ds.CreateSample(
  //     cs.GetChars(),
  //     //new String[]{"NicolasMA", "AntoineME", "LenaME", "IrinaRU", "TheoLA"},
  //     handTestingDatas,
  //     //new String[]{},
  //     fontTestingDatas,
  //     1, 1);
  //
  // cnn.MiniBatchLearn(sample, 8, 256, 0.001, 0.001, 2, new Matrix[][][]{testSample}, "");
  // cnn.Export("./CNN/Test21.cnn");
  // session.AccuracyScore(cnn, testSample, true);
  //
  // // Tester tester = new Tester((NeuralNetwork) null);
  // // ImageSeparator is = new ImageSeparator(loadImage("test.png"));
  // // is.SaveSeparationPreview("test1.png", true, true);
  //
  // NeuralNetwork nn = new NeuralNetwork(imgSize*imgSize, 256, 128, cs.GetChars().length);
  // nn.UseSoftMax();
  // Tester tester = new Tester(nn);
  // Matrix[] testSample = session.ds.SampleLining(session.ds.CreateSample(
  //     cs.GetChars(),
  //     //new String[]{"NicolasMA", "AntoineME", "LenaME", "IrinaRU", "TheoLA"},
  //     //handTestingDatas,
  //     new String[]{},
  //     fontTestingDatas,
  //     3, 1));
  //
  //   Matrix[][] testSampleForTrain = session.ds.SampleLining(session.ds.CreateSample(
  //     cs.GetChars(),
  //     //new String[]{"NicolasMA", "AntoineME", "LenaME", "IrinaRU", "TheoLA"},
  //     //handTestingDatas,
  //     new String[]{},
  //     fontTrainingDatas,
  //     3, 1));
  //
  // int globalInitTime = millis();
  // int numOfIter = 4;
  //
  // double[] varianceArray = new double[numOfIter];
  //
  // for(int iter = 0; iter < numOfIter; iter++) {
  //   cl.pln("ITERATION " + str(iter+1) + "/" + str(numOfIter));
  //   float[] accuracy = CompilScore(session.AccuracyScore(cnn, new Matrix[][][]{testSample}, true));
  //   int[] repList = RepList(accuracy, 5, 0.9);
  //
  //   int[] intAcc = new int[accuracy.length];
  //   for(int i = 0; i < accuracy.length; i++)
  //     intAcc[i] = (int)(accuracy[i] * 1000);
  //   SaveIntListAsCSV(intAcc, "./AuxiliarFiles/Accuracies.csv");
  //   varianceArray[iter] = StandardDeviation(accuracy);
  //   cl.pln(varianceArray[iter]);
  //
  //   cl.pList(repList, "Repetitions");
  //
  //   Matrix[][] sample = session.ds.SampleLining(session.ds.CreateSample(
  //       cs.GetChars(),
  //       //new String[]{"NicolasMA", "AntoineME", "LenaME", "IrinaRU", "TheoLA"},
  //       //handTrainingDatas,
  //       new String[]{},
  //       fontTrainingDatas,
  //       8, 1));
  //
  //   nn.MiniBatchLearn(sample, 5, 64, 3.5, 3, 2, new Matrix[][]{testSample, sample}, "");
  //
  //   session.AccuracyScore(nn, testSample, true);
  //   float[] accuracyTest = CompilScore(session.AccuracyScore(nn, testSample, true));
  //   float averageTestingAccuracy = Average(accuracyTest);
  //
  //   Matrix[] shuffledSample = new Matrix(0).ShuffleCol(sample);
  //   float[] accuracyTrain = CompilScore(session.AccuracyScore(nn, shuffledSample, false));
  //   float averageTrainingAccuracy = Average(accuracyTrain);
  //
  //   graphApplet.AddTestResult(averageTrainingAccuracy, averageTestingAccuracy);
  //   String tr = String.format("%.2f",averageTrainingAccuracy*100);
  //   String ts = String.format("%.2f",averageTestingAccuracy*100);
  //
  //   // Results r = tester.RunNTest(10);
  //   // println("[RÉSULTAT DU TEST] : Score = " + r.time);
  //   // println("[RÉSULTAT DU TEST] : Distance = " + r.score);
  // }
  //
  // int[] intVar = new int[varianceArray.length];
  // for(int i = 0; i < varianceArray.length; i++)
  //   intVar[i] = (int)(varianceArray[i] * 1000);
  // SaveIntListAsCSV(intVar, "./AuxiliarFiles/Variances.csv");
  //
  // // Results r = tester.RunNTest(10, true);
  // // println("[RÉSULTAT DU TEST] : Temps = " + r.time);
  // // println("[RÉSULTAT DU TEST] : Score = " + r.score);
  // // tester.SaveTest();
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


double Variance(float[] a) {
    int n = a.length;

    float sum = 0;
    for (int i = 0; i < n; i++)
        sum += a[i];
    double mean = (double)sum /
                  (double)n;

    // Compute sum squared
    // differences with mean.
    double sqDiff = 0;
    for (int i = 0; i < n; i++)
        sqDiff += (a[i] - mean) *
                  (a[i] - mean);
    return sqDiff / n;
}

double StandardDeviation(float[] arr) {
    return sqrt((float)Variance(arr));
}
