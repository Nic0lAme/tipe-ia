class CharactersStorage {
  String[] allC;
  char[] display;
  double[][][] letterCorrespondance;
  
  //c
  CharactersStorage(int numOfChar) {
    allC = new String[numOfChar];
    display = new char[numOfChar];
    
    letterCorrespondance = new double[numOfChar][][];
  }
  
  int index = 0;
  //f Ajoute le caractère donc le fichier est _name_, associé au caractère _d_, qui sera associé pour l'alphabet par _correspondance_
  // Dans _correpondance_, on a la liste des couple de lettre ressemblantes, avec la part de ressemble
  // _exemple : correspondance = {{8, 0.3}, {11, 0.3}}) pour le 1, qui ressemble au i et au l_
  void AddChar(String name, char d, double[][] correspondance) {
    if(index >= allC.length) {
      cl.pln("Can't add " + name + " because storage is full");
      return;
    }
    
    allC[index] = name;
    display[index] = d;
    letterCorrespondance[index] = correspondance;
    
    index++;
  }
  
  //f Permet d'obtenir les probabilités pour chacune des 26 lettres à partir de la sortie du réseau _allProb_
  double[] GetProb(double[] allProb) {
    double[] ret = new double[26];
    
    for(int i = 0; i < allProb.length; i++) {
      for(double[] c : letterCorrespondance[i]) ret[(int)c[0]] += allProb[i] * c[1];
    }
    
    return ret;
  }
}
