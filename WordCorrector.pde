import java.util.*;
import java.util.stream.*;

class WordCorrector {
  char[] charList =           new char[] {'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z'};
  float[] letterFrequencies = new float[]{8.173, 0.901, 3.345, 3.669, 16.716, 1.066, 0.866, 0.737, 7.529, 0.613, 0.074, 5.456, 2.968, 7.095, 5.796, 2.521, 1.362, 6.693, 7.948, 7.244, 6.311, 1.838, 0.049, 0.427, 0.128, 0.326};
  float[] letterSpreading = new float[]{0.1, 0.05};
  float fiability = 1; // 0 -> c'est vraiment très mauvais / 1 -> c'est vraiment excellent
  
  float probThreshold = 0.2;
  int maxNumberOfCandidates = 10;
  
  int maxCharDiff = 2;
  
  int[][] words;
  
  //c
  WordCorrector() {}
  
  //f Importe l'ensemble des mots du fichier _scrabble.txt_ dans la variable _this.words_
  public void ImportWords() {
    String[] wordsList = loadStrings("./AuxiliarFiles/scrabble.txt");
    String[] auxList = loadStrings("./AuxiliarFiles/auxDic.txt");
    
    this.words = new int[wordsList.length + auxList.length][];
    
    for(int k = 0; k < wordsList.length; k++) {
      String w = wordsList[k].strip();
      int[] wordRepresentation = new int[w.length()];
      
      for(int c = 0; c < w.length(); c++) {
        char character = w.charAt(c);
        wordRepresentation[c] = character - 'A';
      }
      
      this.words[k] = wordRepresentation;
    }
    
    for(int k = 0; k < auxList.length; k++) {
      String w = auxList[k].strip();
      int[] wordRepresentation = new int[w.length()];
      
      for(int c = 0; c < w.length(); c++) {
        char character = w.charAt(c);
        wordRepresentation[c] = character - 'A';
      }
      
      this.words[k + wordsList.length] = wordRepresentation;
    }
  }
  
  public String IntArrayToString(Integer[] chars) {
    return IntArrayToString(Arrays.stream(chars).mapToInt(Integer::intValue).toArray());
  }
  
  public String IntArrayToString(int[] chars) {
    String text = "";
    for(int i = 0; i < chars.length; i++) {
      text += charList[chars[i]];
    }
    return text;
  }
  
  public int[] StringToIntArray(String word) {
    int[] ret = new int[word.length()];
    int index = -1;
    for(char c : word.toLowerCase().toCharArray()) {
      index++;
      if(c < 'a' || c > 'z') continue;
      ret[index] = c - 'a';
    }
    return ret;
  }
  
  public String WordAutoCorrection(float[][] letterProb) {
    return WordAutoCorrection(letterProb, probThreshold, 0);
  }
  
  public String WordAutoCorrection(float[][] letterProb, float threshold, int depth) {
    // Réccupérer les candidates plausibles par lettre
    HashMap<Integer, Float>[] charCandidates = new HashMap[letterProb.length];
    int numberOfWordCandidate = 1;
    for(int letter = 0; letter < letterProb.length; letter++) {
      charCandidates[letter] = new HashMap<>();
      for(int i = 0; i < letterProb[letter].length; i++) {
        if(letterProb[letter][i] < threshold) continue;
        charCandidates[letter].put(i, letterProb[letter][i]);
      }
      numberOfWordCandidate *= charCandidates[letter].values().size();
      if(charCandidates[letter].size() == 0) charCandidates[letter].put(4, 0.1); //Si ne trouve pas de caractères, part du principe que c'est un e (la lettre la plus fréquente)
    }
    
    //println(depth, threshold, numberOfWordCandidate);
    
    if(numberOfWordCandidate == 0) {
      /*
      if(threshold < 0.025) {
        cl.pln(this, threshold, "WordAutoCorrection", "Some char isn't available"); Exception e = new Exception(); e.printStackTrace(); return "_";
      }
      */
      
      // Diminue le threshold jusqu'à qu'on soit bon
      if(depth < 50) return WordAutoCorrection(letterProb, threshold - 0.004, depth + 1);
    }
    
    if(abs(numberOfWordCandidate) > 5 * maxNumberOfCandidates) {
      // Augmente le threshold jusqu'à qu'on soit bon
      return WordAutoCorrection(letterProb, threshold + 0.001, depth + 1);
    }
    
    if(numberOfWordCandidate == 0) return "_";
    
    // Réccupérer ainsi les mots bruts plausibles
    HashMap<Integer[], Float> wordCandidates = new HashMap<>();
    Backtrack(charCandidates, 0, new ArrayList<>(), 1, wordCandidates);
    
    // Les trie par probabilité
    HashMap<Integer[], Float> sortedCandidates = wordCandidates.entrySet()
      .stream()
      .sorted(Map.Entry.comparingByValue(Comparator.reverseOrder()))
      .limit(this.maxNumberOfCandidates)
      .collect(Collectors.toMap(
          Map.Entry::getKey,
          Map.Entry::getValue,
          (e1, e2) -> e1,
          LinkedHashMap::new // pour garder l'ordre trié
    ));
    
    int minDistance = Integer.MAX_VALUE;
    int[] bestWord = new int[0];
    for(Map.Entry<Integer[], Float> m : sortedCandidates.entrySet()) {
      int[] candidate = Arrays.stream(m.getKey()).mapToInt(Integer::intValue).toArray();
      int[][] evaluation = FindBestWord(candidate, (w1, w2) -> LevenshteinDistance(w1,w2), this.maxCharDiff);
      if(evaluation[1][0] < minDistance) {
        minDistance = evaluation[1][0];
        bestWord = evaluation[0];
      }
    }
    
    return IntArrayToString(bestWord);
  }
  
  public int[][] FindBestWord(int[] candidate, DistanceFunction distFunc, int maxGap) {
    int minDistance = Integer.MAX_VALUE;
    int[] bestWord = new int[0];
    
    for(int[] word : this.words) {
      if(abs(word.length - candidate.length) > maxGap) continue;
      int dist = distFunc.apply(candidate, word);
      if(dist < minDistance) {
        minDistance = dist;
        bestWord = word;
      }
    }
    
    return new int[][]{bestWord, {minDistance}};
  }
  
  public int SimpleDistance(int[] w1, int[] w2) {
    if(w1.length > w2.length) return SimpleDistance(w2, w1); // On a toujours w1 plus petit que w2
    int n = w1.length; int m = w2.length;
    
    /*
    if(w1[0] != w2[0] && w1[n - 1] != w2[m - 1]) {
      //print("too different");
      return Integer.MAX_VALUE;
    }
    */
    
    int distance = Integer.MAX_VALUE;
    if(m != n) {
      for(int k = 0; k < n + 1; k++) { // Position du départ du trou
        int kdist = m - n;
        for(int i = 0; i < k; i++) {
          if(w1[i] != w2[i]) kdist += 1;
        }
        
        for(int i = k + m - n; i < m; i++) {
          if(w1[i - m + n] != w2[i]) kdist += 1;
        }
        
        if(kdist < distance) {
          distance = kdist;
        }
      }
    } else {
      distance = m-n;
      for(int i = 0; i < n; i++) {
        if(w1[i] != w2[i]) distance++;
      }
    }
    
    return distance;
  }
  
  public int LevenshteinDistance(int[] w1, int[] w2) {
    if(w1.length < w2.length) return LevenshteinDistance(w2, w1);
    int[] prevRow = new int[w2.length + 1];
    int[] currentRow = new int[w2.length + 1];
    
    for(int j = 0; j < w2.length + 1; j++) {
      prevRow[j] = j;
    }
    
    for(int i = 1; i < w1.length + 1; i++) {
      currentRow[0] = i;
      for(int j = 1; j < w2.length + 1; j++) {
        currentRow[j] = Math.min(
          Math.min(prevRow[j] + 1,                     // Insertion
          currentRow[j-1] + 1),                // Deletion
          prevRow[j-1] + (w1[i - 1] != w2[j - 1] ? 1 : 0)   // Substitution   
        );
      }
      
      int[] temp = prevRow;
      prevRow = currentRow;
      currentRow = temp;
    }
    
    return prevRow[w2.length];
  }
  
  private void Backtrack(HashMap<Integer, Float>[] input, int index, List<Integer> current, float currentProb, HashMap<Integer[], Float> results) {
    if(index == input.length) {
      results.put(current.toArray(new Integer[0]), currentProb);
      return;
    }
    
    input[index].forEach((k, p) -> {
      current.add(k);
      
      this.Backtrack(input, index + 1, current, currentProb * p, results);
      
      current.remove(current.size() - 1);
    });
  }
  
  public String OLD_WordAutoCorrection(float[][] letterProb) {
    float[] etalonnedProp = new float[this.charList.length];
    Arrays.fill(etalonnedProp, 1); 
    return OLD_WordAutoCorrection(letterProb, etalonnedProp);
  }
    
  //f Donne le mot le plus probable pour une entrée _letterProb_
  // _letterProb_ contient pour chaque emplacement les probabilités de chaque caractère
  // Simule toutes les manipulations possibles de manière probabiliste
  // Algorithme assez (très) naïf, donc à voir dans la pratique
  public String OLD_WordAutoCorrection(float[][] letterProb, float[] etalonnedProp) {
    float[][] processedProb = new float[letterProb.length][this.charList.length];
    
    for(int letter = 0; letter < letterProb.length; letter++) {
      // Permet de normer les probabilités (somme vaut un)
      float sum = 1 - this.fiability;
      for(int k = 0; k < this.charList.length; k++) {
        sum += letterProb[letter][k];
      }
      
      for(int k = 0; k < this.charList.length; k++) {
        processedProb[letter][k] = (letterProb[letter][k] + (1 - this.fiability) / this.charList.length) / sum / (float)Math.pow(etalonnedProp[k], 1 - this.fiability);
      }
    }
    
    //println(letterProb[0]);
    
    /*
    // Simule l'insertion / la délétion de lettre
    for(int letter = 0; letter < letterProb.length + this.letterSpreading.length; letter++) {
      for(int k = 0; k < this.charList.length; k++) {
        for(int delta = 1; delta <= this.letterSpreading.length; delta++) {
          if(k - delta >= 0) processedProb[letter][k] += this.letterSpreading[delta] * processedProb[letter][k - delta];
          if(k + delta < processedProb.length) processedProb[letter][k] += this.letterSpreading[delta] * processedProb[letter][k + delta];
        }
      }
    }
    */
    
    
    
    int[] bestWord = new int[processedProb.length];
    float bestProb = 1;
    
    float maxProb = 0;
    int maxChar = 0;
    for(int letter = 0; letter < processedProb.length; letter++) {
      maxProb = 0;
      for(int k = 0; k < this.charList.length; k++) {
        if(processedProb[letter][k] < maxProb) continue;
        maxProb = processedProb[letter][k];
        maxChar = k;
      }
      
      bestWord[letter] = maxChar;
      bestProb *= maxProb;
    }
    
    bestProb /= Math.pow(10, processedProb.length);
    
    println(bestProb);
    println(bestWord);
    
    if(fiability < 1) {
      for(int[] word : this.words) {
        if(word.length != processedProb.length) continue;
        
        float prob = 1;
        for(int letter = 0; letter < word.length; letter++) {
          prob *= processedProb[letter][word[letter]];
        }
        
        if(prob > bestProb) {
          bestProb = prob;
          bestWord = word;
        }
      }
    }
    
    String ret = "";
    for(int l : bestWord) ret += charList[l];
    
    cl.pln(ret, "\twith prob", String.format("%9.3e", bestProb));
    return ret;
  }
  
  public int[] CorruptWord(int[] word, float substitutionProb, float insertDelProb) {
    List<Integer> corruptedWord = new ArrayList<>();
    for(int c : word) {
      if(random(1) < insertDelProb / 2) continue; // Deletion
      if(random(1) < insertDelProb / 2) corruptedWord.add((int)random(0, 25.999)); // Insertion
      corruptedWord.add(random(1) < substitutionProb ? (int)random(0, 25.999) : c); // Substitution
    }
    if(random(1) < insertDelProb / 2) corruptedWord.add((int)random(0, 25.999)); // Insertion
    
    return corruptedWord.stream().mapToInt(Integer::intValue).toArray();
  }
  
  public void CompareFunctions(DistanceFunction[] functions, int numOfWord, float substitutionProb, float insertDelProb) {
    int[][] wordList = new int[numOfWord][];
    int[][] corruptedWordList = new int[numOfWord][];
    
    for(int i = 0; i < numOfWord; i++) {
      wordList[i] = this.words[int(random(this.words.length))];
      corruptedWordList[i] = this.CorruptWord(wordList[i], substitutionProb, insertDelProb);
    }
    
    for(DistanceFunction f : functions) {
      int numOfRight = 0;
      int initTime = millis();
      
      for(int i = 0; i < numOfWord; i++) {
        int[] word = FindBestWord(corruptedWordList[i], f, this.maxCharDiff)[0];
        if(Arrays.equals(word, wordList[i])) numOfRight += 1;
      }
      
      println("Bonnes réponses :", numOfRight, " - Temps :", (float)(millis() - initTime) / 1000);
    }
  }
  
}


@FunctionalInterface
interface DistanceFunction {
  int apply(int[] a, int[] b);
}
