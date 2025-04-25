import java.util.List;
import java.awt.Frame;

String nameOfProcess = "GlobalTest5" + str(minute()) + str(hour()) + str(day()) + str(month()) + str(year());

Matrix[] sample;
ConsoleLog cl;
ImageManager im;
GraphApplet graphApplet;
DraftingArea draftingArea;
Frame frame;
WordCorrector wc;
Database db;

Session session;

int convolutionTime = 0;


final boolean enableDraftingArea = false;

// Nombre de threads pour les différentes tâches
final int numThreadsDataset = 16; // Création des datasets
final int numThreadsLearning = 1; // Apprentissage (si 1, pas de parallélisation)

// Attention, à ne pas modifier n'importe comment sous peine de conséquences
final AtomicBoolean stopLearning = new AtomicBoolean(false);
final AtomicBoolean abortTraining = new AtomicBoolean(false); // Note: Annule aussi toute construction de dataset

float rScale = 1; // Scale for the representations (draw)
float testDerformation = 1;

//String[] characters = new String[]{"0","1","2","3","4","5","6","7","8","9"};
//String[] characters = new String[]{"uA","uB","uC","uD","uE","uF","uG","uH","uI","uJ","uK","uL","uM","uN","uO","uP","uQ","uR","uS","uT","uU","uV","uW","uX","uY","uZ"};

/*
String[] allCharacters = new String[]{
  "uA","uB","uC","uD","uE","uF","uG","uH","uI","uJ","uK","uL","uM","uN","uO","uP","uQ","uR","uS","uT","uU","uV","uW","uX","uY","uZ"
};

String[] allCharacters = new String[]{
  "uA","uB","uC","uD","uE","uF","uG","uH","uI","uJ","uK","uL","uM","uN","uO","uP","uQ","uR","uS","uT","uU","uV","uW","uX","uY","uZ",
  "la","lb","lc","ld","le","lf","lg","lh","li","lj","lk","ll","lm","ln","lo","lp","lq","lr","ls","lt","lu","lv","lw","lx","ly","lz",
  "0","1","2","3","4","5","6","7","8","9", "+", "-", "cr",
  "@","#","im","!","€","$","%","(",")","="
};
*/

CharactersStorage cs;

int numOfTestSample = 40; //This is just for the tests, not the training

String[] handPolicies = new String[]{
  "AntoineME", "NicolasMA", "LenaME", "TheoLA", "ElioKE", "AkramBE", "IVALUA1", "IVALUA2", "SamuelJE", "QuentinGU",
  "TaoPO","GuillaumeLI","YacoutGA", "LoicRA", "MaximeMB", "NathanLU", "LubinDE", "MatheoLB", "SachaAD", "MatisBR",
  "ValerieAR", "ArthurLO", "RomaneFI", "ThelioLA", "YanisIH", "MrMollier", "MrChauvet", "SachaBE", "IrinaRU", "NoematheoBLB",
  "JeanneAR", "Ivalua3", "Ivalua4", "Ivalua5", "Ivalua6", "MatteoPR", "BCPST00000", "BCPST00001", "BCPST00002", "BCPST00003",
  "BCPST00004", "BCPST00005", "BCPST00006", "BCPST00007", "BCPST00008", "BCPST00009", "BCPST00010", "BCPST00011", "BCPST00012", "BCPST00013",
  "BCPST00014", "BCPST00015", "BCPST00016", "BCPST00017", "BCPST00018", "BCPST00019", "BCPST00020", "BCPST00021", "BCPST00022", "BCPST00023",
  "BCPST00024", "BCPST00025", "BCPST00026", "BCPST00027", "BCPST00028", "BCPST00029", "BCPST00030", "BCPST00031", "BCPST00032", "BCPST00033",
  "BCPST00034", "BCPST00035", "BCPST00036", "BCPST00037", "BCPST00038", "BCPST00039", "BCPST00040", "BCPST00041", "BCPST00042", "BCPST00043",
  "BCPST00044", "BCPST00045", "BCPST00046", "BCPST00047", "BCPST00048", "BCPST00049", "BCPST00050", "BCPST00051", "BCPST00052", "BCPST00053",
  "BCPST00054", "BCPST00055", "BCPST00056", "BCPST00057", "BCPST00058", "BCPST00059", "BCPST00060", "BCPST00061", "BCPST00062", "BCPST00063",
  "BCPST00064", "BCPST00065", "BCPST00066", "BCPST00067", "BCPST00068", "BCPST00069", "BCPST00070", "BCPST00071", "BCPST00072", "BCPST00073",
  "BCPST00074", "BCPST00075", "BCPST00076", "BCPST00077", "BCPST00078", "BCPST00079", "BCPST00080", "BCPST00081"
};

String[] fontPolicies = new String[]{
  "Arial", "Bahnschrift", "Eras Demi ITC", "Lucida Handwriting Italique", "DejaVu Serif",
  "Fira Code Retina Moyen", "Consolas", "Lucida Handwriting Italique", "Playwrite IT Moderna", "Just Another Hand",
  "Liberation Serif", "Calibri", "Book Antiqua", "Gabriola", "Noto Serif"
};


String[] handTrainingDatas = new String[]{
  "AntoineME", "NicolasMA", "LenaME", "TheoLA", "ElioKE", "AkramBE", "IVALUA1", "IVALUA2", "SamuelJE", "QuentinGU",
  "TaoPO","GuillaumeLI","YacoutGA", "LoicRA", "MaximeMB", "NathanLU", "LubinDE", "MatheoLB", "SachaAD", "MatisBR",
  "ValerieAR", "ArthurLO", "RomaneFI", "ThelioLA", "YanisIH", "JeanneAR", "Ivalua3", "Ivalua4", "Ivalua5", "Ivalua6",
  "MatteoPR", "BCPST00000", "BCPST00001", "BCPST00002", "BCPST00003", "BCPST00077", "BCPST00078", "BCPST00079", "BCPST00080", "BCPST00081",
  "BCPST00004", "BCPST00005", "BCPST00006", "BCPST00007", "BCPST00008", "BCPST00009", "BCPST00010", "BCPST00011", "BCPST00012", "BCPST00013",
  "BCPST00014", "BCPST00015", "BCPST00016", "BCPST00017", "BCPST00018", "BCPST00019", "BCPST00020", "BCPST00021", "BCPST00022", "BCPST00023",
  "BCPST00024", "BCPST00025", "BCPST00026", "BCPST00027", "BCPST00028", "BCPST00029", "BCPST00030", "BCPST00031", "BCPST00032", "BCPST00033",
  "BCPST00034", "BCPST00035", "BCPST00036", "BCPST00037", "BCPST00038", "BCPST00039", "BCPST00040", "BCPST00041", "BCPST00042", "BCPST00043",
  "BCPST00044", "BCPST00045", "BCPST00046", "BCPST00047", "BCPST00048", "BCPST00049", "BCPST00050", "BCPST00051", "BCPST00052", "BCPST00053",
  "BCPST00054", "BCPST00055", "BCPST00056", "BCPST00057", "BCPST00058", "BCPST00059", "BCPST00060", "BCPST00061", "BCPST00062", "BCPST00063",
  "BCPST00064", "BCPST00065", "BCPST00066", "BCPST00067", "BCPST00068", "BCPST00069", "BCPST00070", "BCPST00071"
};
//String[] handTrainingDatas = new String[]{};
String[] fontTrainingDatas = new String[]{
  "Arial", "Bahnschrift", "Eras Demi ITC", "Lucida Handwriting Italique", "DejaVu Serif",
  "Fira Code Retina Moyen", "Consolas", "Lucida Handwriting Italique", "Playwrite IT Moderna", "Just Another Hand"
};
//String[] fontTrainingDatas = new String[]{};

String[] handTestingDatas = new String[]{"MrMollier", "MrChauvet", "SachaBE", "IrinaRU", "NoematheoBLB", "BCPST00072", "BCPST00073", "BCPST00074", "BCPST00075", "BCPST00076"};
String[] fontTestingDatas = new String[]{"Liberation Serif", "Calibri", "Book Antiqua", "Gabriola", "Noto Serif"};

int numOfHyperParameters = 15;

void settings() {
  size(floor(25 * rScale * 75), floor(25 * rScale * numOfTestSample), JAVA2D); // For Global Test
  //size(119, 180, P2D); // For Direct Test
}

void setup() {
  background(255);
  InitCStorage();
  frame = (Frame) ((processing.awt.PSurfaceAWT.SmoothCanvas) surface.getNative()).getFrame();
  frame.setVisible(false); // Cache la fenêtre d'activation java
  frame.setResizable(true);

  im = new ImageManager();
  graphApplet = new GraphApplet();
  cl = new ConsoleLog("./Log/log1.txt");
  wc = new WordCorrector();
  wc.ImportWords();

  if (enableDraftingArea) draftingArea = new DraftingArea();

  db = new Database("https://tipe-877f6-default-rtdb.europe-west1.firebasedatabase.app/");


  HyperParameters hp = new HyperParameters();
  session = new Session("", hp);

  Bayes bayes = new Bayes("RandomInitFois5");
  // bayes.GaussianProcess(5, 5);
  //bayes.RandomFill(5, 5);
  /*
  for(int k = 0; k < 10; k++)
    bayes.SERV_Export(new HyperParameters().Random(), random(1));
  */
  
  CNN cnn = new CNN(28, new int[]{32, 32}, new int[]{128, cs.allC.length});
  cnn.UseSoftMax();
  cnn.useADAM = true;
  
  Matrix[][] sample = session.ds.CreateSample(
      cs.allC,
      //new String[]{"NicolasMA", "AntoineME", "LenaME", "IrinaRU", "TheoLA"},
      //handTrainingDatas,
      new String[]{},
      fontTrainingDatas,
      2, 1);
      
  Matrix[][] testSample = session.ds.CreateSample(
      cs.allC,
      //new String[]{"NicolasMA", "AntoineME", "LenaME", "IrinaRU", "TheoLA"},
      handTestingDatas,
      //new String[]{},
      fontTestingDatas,
      1, 1);
      
  cnn.MiniBatchLearn(sample, 256, 16, 0.001, 0.001, 4, new Matrix[][][]{sample, testSample}, "");
  
  session.AccuracyScore(cnn, testSample, true);
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


void InitCStorage() {
  //cs = new CharactersStorage(62);
  cs = new CharactersStorage(10);
  
  /*
  cs.AddChar("uA",'A', new double[][]{{0, 1}});
  cs.AddChar("uB",'B', new double[][]{{1, 1}});
  cs.AddChar("uC",'C', new double[][]{{2, 1}});
  cs.AddChar("uD",'D', new double[][]{{3, 1}});
  cs.AddChar("uE",'E', new double[][]{{4, 1}});
  cs.AddChar("uF",'F', new double[][]{{5, 1}});
  cs.AddChar("uG",'G', new double[][]{{6, 1}});
  cs.AddChar("uH",'H', new double[][]{{7, 1}});
  cs.AddChar("uI",'I', new double[][]{{8, 1}});
  cs.AddChar("uJ",'J', new double[][]{{9, 1}});
  cs.AddChar("uK",'K', new double[][]{{10, 1}});
  cs.AddChar("uL",'L', new double[][]{{11, 1}});
  cs.AddChar("uM",'M', new double[][]{{12, 1}});
  cs.AddChar("uN",'N', new double[][]{{13, 1}});
  cs.AddChar("uO",'O', new double[][]{{14, 1}});
  cs.AddChar("uP",'P', new double[][]{{15, 1}});
  cs.AddChar("uQ",'Q', new double[][]{{16, 1}});
  cs.AddChar("uR",'R', new double[][]{{17, 1}});
  cs.AddChar("uS",'S', new double[][]{{18, 1}});
  cs.AddChar("uT",'T', new double[][]{{19, 1}});
  cs.AddChar("uU",'U', new double[][]{{20, 1}});
  cs.AddChar("uV",'V', new double[][]{{21, 1}});
  cs.AddChar("uW",'W', new double[][]{{22, 1}});
  cs.AddChar("uX",'X', new double[][]{{23, 1}});
  cs.AddChar("uY",'Y', new double[][]{{24, 1}});
  cs.AddChar("uZ",'Z', new double[][]{{25, 1}});
  cs.AddChar("la",'a', new double[][]{{0, 1}});
  cs.AddChar("lb",'b', new double[][]{{1, 1}});
  cs.AddChar("lc",'c', new double[][]{{2, 1}});
  cs.AddChar("ld",'d', new double[][]{{3, 1}});
  cs.AddChar("le",'e', new double[][]{{4, 1}});
  cs.AddChar("lf",'f', new double[][]{{5, 1}});
  cs.AddChar("lg",'g', new double[][]{{6, 1}});
  cs.AddChar("lh",'h', new double[][]{{7, 1}});
  cs.AddChar("li",'i', new double[][]{{8, 1}});
  cs.AddChar("lj",'j', new double[][]{{9, 1}});
  cs.AddChar("lk",'k', new double[][]{{10, 1}});
  cs.AddChar("ll",'l', new double[][]{{11, 1}});
  cs.AddChar("lm",'m', new double[][]{{12, 1}});
  cs.AddChar("ln",'n', new double[][]{{13, 1}});
  cs.AddChar("lo",'o', new double[][]{{14, 1}});
  cs.AddChar("lp",'p', new double[][]{{15, 1}});
  cs.AddChar("lq",'q', new double[][]{{16, 1}});
  cs.AddChar("lr",'r', new double[][]{{17, 1}});
  cs.AddChar("ls",'s', new double[][]{{18, 1}});
  cs.AddChar("lt",'t', new double[][]{{19, 1}});
  cs.AddChar("lu",'u', new double[][]{{20, 1}});
  cs.AddChar("lv",'v', new double[][]{{21, 1}});
  cs.AddChar("lw",'w', new double[][]{{22, 1}});
  cs.AddChar("lx",'x', new double[][]{{23, 1}});
  cs.AddChar("ly",'y', new double[][]{{24, 1}});
  cs.AddChar("lz",'z', new double[][]{{25, 1}});
  */
  
  cs.AddChar("0",'0', new double[][]{{14, 0.8}});
  cs.AddChar("1",'1', new double[][]{{8, 0.3}, {11, 0.3}});
  cs.AddChar("2",'2', new double[][]{});
  cs.AddChar("3",'3', new double[][]{{1, 0.1}});
  cs.AddChar("4",'4', new double[][]{{0, 0.4}});
  cs.AddChar("5",'5', new double[][]{{18, 0.5}});
  cs.AddChar("6",'6', new double[][]{{18, 0.2}});
  cs.AddChar("7",'7', new double[][]{{8, 0.1}});
  cs.AddChar("8",'8', new double[][]{{1, 0.5}});
  cs.AddChar("9",'9', new double[][]{{6, 0.5}});

  /*
  cs.AddChar("+",'+', new double[][]{});
  cs.AddChar("-",'-', new double[][]{});
  cs.AddChar("cr",'×', new double[][]{});
  cs.AddChar("@",'@', new double[][]{{0, 0.2}});
  cs.AddChar("#",'#', new double[][]{});
  cs.AddChar("im",'?', new double[][]{});
  cs.AddChar("!",'!', new double[][]{});
  cs.AddChar("€",'€', new double[][]{{4, 0.2}});
  cs.AddChar("$",'$', new double[][]{{18, 0.4}});
  cs.AddChar("%",'%', new double[][]{});
  cs.AddChar("(",'(', new double[][]{});
  cs.AddChar(")",')', new double[][]{});
  cs.AddChar("=",'=', new double[][]{});
  */
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
