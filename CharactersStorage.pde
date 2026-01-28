/////////////////////////////////////////////////////////////////

int numOfTestSample = 30; // Juste pour les tests, pas pour les entrainements

// Toutes les polices à la main
String[] handPolicies = new String[] {
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
  "BCPST00074", "BCPST00075", "BCPST00076", "BCPST00077", "BCPST00078", "BCPST00079", "BCPST00080", "BCPST00081", "MPSIB00000", "MPSIB00001",
  "MPSIB00002", "MPSIB00003", "MPSIB00004", "MPSIB00005", "MPSIB00006", "MPSIB00007", "MPSIB00008", "MPSIB00009", "MPSIB00010", "MPSIB00011",
  "MPSIB00012", "MPSIB00013", "MPSIB00014", "MPSIB00015", "MPSIB00016", "MPSIB00017", "MPSIB00018", "MPSIB00019", "MPSIB00020", "MPSIB00021",
  "MPSIB00022", "MPSIB00023", "MPSIB00024", "MPSIB00025", "MPSIB00026"
};

String[] BCPSTPolicies = new String[] {
  "BCPST00004", "BCPST00005", "BCPST00006", "BCPST00007", "BCPST00008", "BCPST00009", "BCPST00010", "BCPST00011", "BCPST00012", "BCPST00013",
  "BCPST00014", "BCPST00015", "BCPST00016", "BCPST00017", "BCPST00018", "BCPST00019", "BCPST00020", "BCPST00021", "BCPST00022", "BCPST00023",
  "BCPST00024", "BCPST00025", "BCPST00026", "BCPST00027", "BCPST00028", "BCPST00029", "BCPST00030", "BCPST00031", "BCPST00032", "BCPST00033",
  "BCPST00034", "BCPST00035", "BCPST00036", "BCPST00037", "BCPST00038", "BCPST00039", "BCPST00040", "BCPST00041", "BCPST00042", "BCPST00043",
  "BCPST00044", "BCPST00045", "BCPST00046", "BCPST00047", "BCPST00048", "BCPST00049", "BCPST00050", "BCPST00051", "BCPST00052", "BCPST00053",
  "BCPST00054", "BCPST00055", "BCPST00056", "BCPST00057", "BCPST00058", "BCPST00059", "BCPST00060", "BCPST00061", "BCPST00062", "BCPST00063",
  "BCPST00064", "BCPST00065", "BCPST00066", "BCPST00067", "BCPST00068", "BCPST00069", "BCPST00070", "BCPST00071", "BCPST00072", "BCPST00073",
  "BCPST00074", "BCPST00075", "BCPST00076", "BCPST00077", "BCPST00078", "BCPST00079", "BCPST00080", "BCPST00081", "BCPST00000", "BCPST00001",
  "BCPST00002", "BCPST00003"
};

String[] MPSIPolicies = new String[] {
  "AntoineME", "NicolasMA", "LenaME", "TheoLA", "ElioKE", "AkramBE", "SamuelJE", "QuentinGU", "MatteoPR", "NoematheoBLB",
  "TaoPO", "GuillaumeLI","YacoutGA", "LoicRA", "MaximeMB", "NathanLU", "LubinDE", "MatheoLB", "SachaAD", "MatisBR",
  "ArthurLO", "RomaneFI", "ThelioLA", "YanisIH", "MrMollier", "MrChauvet", "SachaBE", "IrinaRU",
};

// Toutes les polices d'ordinateurs
String[] fontPolicies = new String[] {
  "Arial", "Bahnschrift", "Eras Demi ITC", "Lucida Handwriting Italique", "DejaVu Serif",
  "Fira Code Retina Moyen", "Consolas", "Lucida Handwriting Italique", "Playwrite IT Moderna", "Just Another Hand",
  "Liberation Serif", "Calibri", "Book Antiqua", "Gabriola", "Noto Serif",
  "Baskerville Old Face", "Garamond", "Palatino Linotype", "Georgia", "Tahoma",
  "Elephant", "Corbel", "Pristina", "Rockwell", "Cooper Black",
  "Trebuchet MS", "Bell MT", "Perpetua", "Times New Roman", "Franklin Gothic Book"
};

String[] mostPopularPolicies = new String[]{
  "Roboto Regular", "Noto Sans Regular", "Open Sans Regular", "Lato Regular", "Montserrat Regular",
  "Source Sans 3 Regular", "Source Code Pro Regular", "Raleway Regular", "Charter", "Helvetica",
  "Oswald Regular", "PT Sans", "Noto Serif", "Ubuntu Regular", "Times New Roman",
  "Arial", "Calibri", "Cambria", "Tahoma", "Verdana"
};

// Polices à la main pour l'entrainement
String[] handTrainingDatas = new String[] {
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
  "BCPST00064", "BCPST00065", "BCPST00066", "BCPST00067", "BCPST00068", "BCPST00069", "BCPST00070", "BCPST00071", "MPSIB00000", "MPSIB00001",
  "MPSIB00002", "MPSIB00003", "MPSIB00004", "MPSIB00005", "MPSIB00006", "MPSIB00007", "MPSIB00008", "MPSIB00009", "MPSIB00010", "MPSIB00011",
  "MPSIB00012", "MPSIB00013", "MPSIB00014", "MPSIB00015", "MPSIB00016", "MPSIB00017", "MPSIB00018", "MPSIB00019", "MPSIB00020", "MPSIB00021",
  "MPSIB00022", "MPSIB00023", "MPSIB00024", "MPSIB00025", "MPSIB00026"
};

// Polices d'ordinateur pour l'entrainement
String[] fontTrainingDatas = new String[]{
  "Arial", "Bahnschrift", "Eras Demi ITC", "Lucida Handwriting Italique", "DejaVu Serif",
  "Fira Code Retina Moyen", "Consolas", "Lucida Handwriting Italique", "Playwrite IT Moderna", "Just Another Hand",
  "Baskerville Old Face", "Garamond", "Palatino Linotype", "Georgia", "Tahoma",
  "Elephant", "Corbel", "Pristina", "Rockwell", "Cooper Black",
  "Trebuchet MS", "Bell MT", "Perpetua", "Times New Roman", "Franklin Gothic Book"
};

String[] biggerFontTrainingDatas = new String[]{
  "Arial", "Bahnschrift", "Eras Demi ITC", "Lucida Handwriting Italique", "DejaVu Serif",
  "Fira Code Retina Moyen", "Consolas", "Lucida Handwriting Italique", "Playwrite IT Moderna", "Just Another Hand",
  "Baskerville Old Face", "Garamond", "Palatino Linotype", "Georgia", "Tahoma",
  "Elephant", "Corbel", "Pristina", "Rockwell", "Cooper Black",
  "Trebuchet MS", "Bell MT", "Perpetua", "Times New Roman", "Franklin Gothic Book",
  "Roboto Regular", "Noto Sans Regular", "Open Sans Regular", "Lato Regular", "Montserrat Regular",
  "Source Sans 3 Regular", "Source Code Pro Regular", "Raleway Regular", "Charter", "Helvetica",
  "Oswald Regular", "PT Sans", "Noto Serif", "Ubuntu Regular", "Times New Roman",
  "Arial", "Calibri", "Cambria", "Tahoma", "Verdana"
};

// Polices pour les tests
String[] handTestingDatas = new String[]{"MrMollier", "MrChauvet", "SachaBE", "IrinaRU", "NoematheoBLB", "BCPST00072", "BCPST00073", "BCPST00074", "BCPST00075", "BCPST00076"};
String[] fontTestingDatas = new String[]{"Liberation Serif", "Calibri", "Book Antiqua", "Gabriola", "Noto Serif"};

/////////////////////////////////////////////////////////////////

class CharactersStorage {
  final String characterFilePath = "AuxiliarFiles/characters.txt";

  // (ne pas modifier) Ensemble des noms des caractères à réccupérer dans les fichiers
  private final String[] fullCharacters = new String[]{
    "uA","uB","uC","uD","uE","uF","uG","uH","uI","uJ","uK","uL","uM","uN","uO","uP","uQ","uR","uS","uT","uU","uV","uW","uX","uY","uZ",
    "la","lb","lc","ld","le","lf","lg","lh","li","lj","lk","ll","lm","ln","lo","lp","lq","lr","ls","lt","lu","lv","lw","lx","ly","lz",
    "0","1","2","3","4","5","6","7","8","9", "+", "-", "cr",
    "@","#","im","!","€","$","%","(",")","="
  };

  private ArrayList<String> usedChars;
  private ArrayList<Character> display;
  private ArrayList<float[][]> letterCorrespondance;

  //c
  CharactersStorage() {
    usedChars = new ArrayList<String>();
    display = new ArrayList<Character>();;
    letterCorrespondance = new ArrayList<float[][]>();
  }

  //f Permet de réccupérer une des polices d'entrainements aléatoirement
  PFont GetRandomTrainingFont(float fontSize) {
    int numOfFonts = fontTestingDatas.length;
    int randomIndex = (int)(random(1) * numOfFonts);

    return createFont(fontTestingDatas[randomIndex], fontSize);
  }

  //f Ajoute le caractère dont le fichier est _name_, associé au caractère _d_, qui sera associé pour l'alphabet par _correspondance_
  // Dans _correspondance_, on a la liste des couple de lettres ressemblantes, avec la part de ressemblance
  // _Exemple : correspondance = {{8, 0.3}, {11, 0.3}}) pour le 1, qui ressemble au i et au l_
  public void AddChar(String name, char d, float[][] correspondance) {
    usedChars.add(name);
    display.add(d);
    letterCorrespondance.add(correspondance);
  }

  //f Réccupère la liste des caractère considérés par le programme
  public String[] GetChars() {
    return usedChars.toArray(new String[usedChars.size()]);
  }

  //f Réccupère le nombre de caractères considérés par le programme
  public int NumChars() {
    return usedChars.size();
  }

  //f Permet d'obtenir les probabilités pour chacune des 26 lettres à partir de la sortie du réseau _allProb_
  // En fonction 
  float[] GetProb(float[] allProb) {
    float[] ret = new float[26];

    for (int i = 0; i < allProb.length; i++) {
      for (float[] c : letterCorrespondance.get(i)) {
        if((int)c[0] >= 26) continue;
        ret[(int)c[0]] += allProb[i] * c[1];
      }
    }

    return ret;
  }

  //s Tous les caractères sont ajoutés
  private void ParseCharFile(String filePath) {
    ParseCharFile(filePath, fullCharacters);
  }

  //f Permet de trouver les proportions de chaque lettres détectées par un réseau selon leurs ressemblance
  public float[] GetEtalonnedProp(CNN cnn) {
    Matrix[][] testSample = session.ds.CreateSample(
      cs.GetChars(),
      //new String[]{"NicolasMA", "AntoineME", "LenaME", "IrinaRU", "TheoLA"},
      //handTestingDatas,
      new String[]{},
      fontTestingDatas,
      2, 1);
    Matrix output = cnn.Predict(testSample[0]);

    float[] allProp = new float[output.n];
    for(int j = 0; j < output.p; j++) {
      for(int i = 0; i < output.n; i++) allProp[i] += output.Get(i, j) / output.n / output.p;
    }

    return GetProb(allProp);
  }

  //s
  public float[] GetEtalonnedProp(NeuralNetwork nn) {
    Matrix[] testSample = session.ds.SampleLining(session.ds.CreateSample(
      cs.GetChars(),
      //new String[]{"NicolasMA", "AntoineME", "LenaME", "IrinaRU", "TheoLA"},
      //handTestingDatas,
      new String[]{},
      fontTestingDatas,
      2, 1));
    Matrix output = nn.Predict(testSample[0]);

    float[] allProp = new float[output.n];
    for(int j = 0; j < output.p; j++) {
      for(int i = 0; i < output.n; i++) allProp[i] += output.Get(i, j) / output.n / output.p;
    }

    return GetProb(allProp);
  }

  //f Ajoute tous les caractères présents dans le fichier _filePath_
  // et dans la liste _listChars_
  // Le format du fichier est (attention, à l’espace près !) :
  // name char / lettre1 proba1, lettre2 proba2, lettre3 proba3
  // Exemple : uB B / uB 1, uA 0.2
  private void ParseCharFile(String filePath, String[] listChars) {
    String[] lines = loadStrings(filePath);
    for (String l : lines) {
      if (l.charAt(0) == '/' && l.charAt(1) == '/') continue; // Une ligne commentaire !
      String[] parts = split(l, " / ");

      String[] fp = split(parts[0], " ");
      String name = fp[0];
      // println(name);
      char d = fp[1].charAt(0);

      boolean found = false;
      for (String c : listChars) {
        if (c.equals(name)) found = true;
      }
      if (!found) continue;

      String[] sp = split(parts[1], ", ");
      float[][] corr = new float[sp.length][];
      for (int i = 0; i < corr.length; i++) {
        String[] spl = split(sp[i], " ");
        int charNameInd = FindIndex(spl[0]);
        corr[i] = new float[]{charNameInd, Float.parseFloat(spl[1])};
      }

      // println(name, d);
      // for (int i = 0; i < corr.length; i++) print("[" + corr[i][0] + "," + corr[i][1] + "] ");
      // println();
      AddChar(name, d, corr);
    }
  }

  //f Renvoie l'indice correspondant à _name_ dans la liste fullCharacters
  private int FindIndex(String name) {
    for (int i = 0; i < fullCharacters.length; i++) {
      if (name.equals(fullCharacters[i])) return i;
    }
    cl.pln("Erreur dans FindIndex : " + name + " non trouvé !");
    return 0;
  }

  //f Charger les chiffres
  public void LoadNumbersOnly() {
    String[] allowed = new String[10];
    int start = FindIndex("0");
    for (int i = 0; i < 10; i++) allowed[i] = fullCharacters[start + i];
    ParseCharFile(characterFilePath, allowed);
  }

  //f Charger les lettres majuscules
  public void LoadMajOnly() {
    String[] allowed = new String[26];
    for (int i = 0; i < 26; i++) allowed[i] = fullCharacters[i];
    ParseCharFile(characterFilePath, allowed);
  }

  //f Charger toutes les lettres
  public void LoadLettersOnly() {
    String[] allowed = new String[52];
    for (int i = 0; i < 52; i++) allowed[i] = fullCharacters[i];
    ParseCharFile(characterFilePath, allowed);
  }

  //f Charger toutes les lettres et chiffres
  public void LoadLettersAndNumbers() {
    String[] allowed = new String[62];
    for (int i = 0; i < 62; i++) allowed[i] = fullCharacters[i];
    ParseCharFile(characterFilePath, allowed);
  }

  //f Charger toutes les lettres, les chiffres et les caractères spéciaux
  public void LoadFull() {
    ParseCharFile(characterFilePath);
  }
}
