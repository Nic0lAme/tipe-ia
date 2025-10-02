class WordCorrector {
  char[] charList = new char[]{'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z'};
  float[] letterSpreading = new float[]{0.1, 0.05};
  float fiability = 0.9; // 0 -> c'est vraiment très mauvais / 1 -> c'est vraiment excellent
  
  int[][] words;
  
  //c
  WordCorrector() {}
  
  //f Importe l'ensemble des mots du fichier _scrabble.txt_ dans la variable _this.words_
  public void ImportWords() {
    String[] wordsList = loadStrings("./AuxiliarFiles/scrabble.txt");
    
    this.words = new int[wordsList.length][];
    
    for(int k = 0; k < wordsList.length; k++) {
      String w = wordsList[k].strip();
      int[] wordRepresentation = new int[w.length()];
      
      for(int c = 0; c < w.length(); c++) {
        char character = w.charAt(c);
        wordRepresentation[c] = character - 'A';
      }
      
      this.words[k] = wordRepresentation;
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
      int[][] evaluation = FindBestWord(candidate, (w1, w2) -> LevenshteinDistance(w1,w2), this.maxCharDiff, this.maxDist);
      if(evaluation[1][0] < minDistance) {
        minDistance = evaluation[1][0];
        bestWord = evaluation[0];
      }
    }
    
    return IntArrayToString(bestWord);
  }
  
  public int[][] FindBestWord(int[] candidate, DistanceFunction distFunc, int maxGap, int maxDistance) {
    int minDistance = maxDistance;
    int[] bestWord = candidate;
    
    for(int[] word : this.words) {
      if(abs(word.length - candidate.length) > maxGap) continue;
      int dist = distFunc.apply(candidate, word);
      if(dist <= minDistance) {
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
  
  public int LevenshteinDistance(String w1, String w2) {
    return this.LevenshteinDistance(w1.toCharArray(), w2.toCharArray());
  }
  
  public int LevenshteinDistance(char[] w1, char[] w2) {
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
  public String WordAutoCorrection(float[][] letterProb) {
    float[][] processedProb = new float[letterProb.length][this.charList.length];
    
    for(int letter = 0; letter < letterProb.length; letter++) {
      // Permet de normer les probabilités (somme vaut un)
      float sum = 1 - this.fiability;
      for(int k = 0; k < this.charList.length; k++) {
        sum += letterProb[letter][k];
      }
      
      for(int k = 0; k < this.charList.length; k++) {
        processedProb[letter][k] = (letterProb[letter][k] + (1 - this.fiability) / this.charList.length) / sum;
      }
    }
    
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
    
    int[] bestWord = words[0];
    float bestProb = 0;
    
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
    
    String ret = "";
    for(int l : bestWord) ret += charList[l];
    
    cl.pln(ret, "\twith prob", String.format("%9.3e", bestProb));
    return ret;
  }
}
