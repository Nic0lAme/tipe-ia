import java.util.List;
import java.awt.Frame;

String nameOfProcess = "GlobalTest5" + str(minute()) + str(hour()) + str(day()) + str(month()) + str(year());

Matrix[] sample;
ConsoleLog cl;
ImageManager im;
GraphApplet graphApplet;
Frame frame;

Session session;

// Nombre de threads pour les différentes tâches
final int numThreadsDataset = 8; // Création des datasets
final int numThreadsLearning = 8; // Apprentissage (si 1, pas de parallélisation)

// Attention, à ne pas modifier n'importe comment sous peine de conséquences
final AtomicBoolean stopLearning = new AtomicBoolean(false);

float rScale = 1; // Scale for the representations (draw)
float testDerformation = 1;

//String[] characters = new String[]{"0","1","2","3","4","5","6","7","8","9"};
//String[] characters = new String[]{"uA","uB","uC","uD","uE","uF","uG","uH","uI","uJ","uK","uL","uM","uN","uO","uP","uQ","uR","uS","uT","uU","uV","uW","uX","uY","uZ"};

/*
String[] allCharacters = new String[]{
  "uA","uB","uC","uD","uE","uF","uG","uH","uI","uJ","uK","uL","uM","uN","uO","uP","uQ","uR","uS","uT","uU","uV","uW","uX","uY","uZ"
};
*/


String[] allCharacters = new String[]{
  "uA","uB","uC","uD","uE","uF","uG","uH","uI","uJ","uK","uL","uM","uN","uO","uP","uQ","uR","uS","uT","uU","uV","uW","uX","uY","uZ",
  "la","lb","lc","ld","le","lf","lg","lh","li","lj","lk","ll","lm","ln","lo","lp","lq","lr","ls","lt","lu","lv","lw","lx","ly","lz",
  "0","1","2","3","4","5","6","7","8","9", "+", "-", "cr",
  "@","#","im","!","€","$","%","(",")","="
};

int numOfTestSample = 40; //This is just for the tests, not the training

String[] handPolicies = new String[]{
  "AntoineME", "NicolasMA", "LenaME", "TheoLA", "ElioKE", "AkramBE", "IVALUA1", "IVALUA2", "SamuelJE", "QuentinGU",
  "TaoPO","GuillaumeLI","YacoutGA", "LoicRA", "MaximeMB", "NathanLU", "LubinDE", "MatheoLB", "SachaAD", "MatisBR",
  "ValerieAR", "ArthurLO", "RomaneFI", "ThelioLA", "YanisIH", "MrMollier", "MrChauvet", "SachaBE", "IrinaRU", "NoematheoBLB",
  "JeanneAR", "Ivalua3", "Ivalua4", "Ivalua5", "Ivalua6", "MatteoPR"
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
  "MatteoPR"
};
//String[] handTrainingDatas = new String[]{};
String[] fontTrainingDatas = new String[]{
  "Arial", "Bahnschrift", "Eras Demi ITC", "Lucida Handwriting Italique", "DejaVu Serif",
  "Fira Code Retina Moyen", "Consolas", "Lucida Handwriting Italique", "Playwrite IT Moderna", "Just Another Hand"
};
//String[] fontTrainingDatas = new String[]{};

String[] handTestingDatas = new String[]{"MrMollier", "MrChauvet", "SachaBE", "IrinaRU", "NoematheoBLB"};
String[] fontTestingDatas = new String[]{"Liberation Serif", "Calibri", "Book Antiqua", "Gabriola", "Noto Serif"};

int numOfHyperParameters = 15;

void settings() {
  size(floor(19 * rScale * this.allCharacters.length), floor(21 * rScale * numOfTestSample), JAVA2D); // For Global Test
  //size(119, 180, P2D); // For Direct Test
}

void setup() {
  background(255);
  
  frame = (Frame) ((processing.awt.PSurfaceAWT.SmoothCanvas) surface.getNative()).getFrame();
  frame.setVisible(false); // Cache la fenêtre d'activation java
  frame.setResizable(true);

  im = new ImageManager();
  graphApplet = new GraphApplet();
  cl = new ConsoleLog("./Log/log1.txt");
  
  HyperParameters hp = new HyperParameters();
  session = new Session("", hp);
  
  
  Bayes bayes = new Bayes().Import("./Bayes/Test2.by");
  bayes.GaussianProcess(6, 120);
  bayes.Export("./Bayes/Test3.by");
  
}

int index = 0;
boolean testImages = false;
boolean directTest = false;

void draw() {
  if(testImages) session.TestImages();
  if(directTest) session.DirectTest();
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
