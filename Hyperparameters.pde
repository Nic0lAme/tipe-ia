class HyperParameters {
  int maxNumberOfLayers = 10;
  
  int[] layerSize;
  float minLR;
  float maxLR;
  float lambda;
  int period;
  int batchSize;
  
  //f Tire des hyperparamètres aléatoirement
  HyperParameters Random() {
    maxLR = LogRandom(0.1, 10);
    minLR = LogRandom(0.0001, 1);
    lambda = LogRandom(0.0000001, 0.1);
    period = constrain(PoissonRandom(6), 1, 100);
    batchSize = (int)LogRandom(8, 512);
    
    int numberOfLayer = constrain(PoissonRandom(3), 1, maxNumberOfLayers);
    layerSize = new int[numberOfLayer];
    
    for(int k = 0; k < numberOfLayer; k++) layerSize[k] = (int)LogRandom(16, 1024);
    
    return this;
  }
  
  //f Fonction de random uniforme entre _min_ et _max_
  float UniRandom(float min, float max) {
    return (float)random((float)min, (float)max);
  }
  
  //f Fonction de Random log-normale entre _min_ et _max_
  float LogRandom(float min, float max) {
    return min * pow(max / min, random(1));
  }
  
  //f Fonction de Random de poisson de paramètre _lambda_
  int PoissonRandom(float lambda) {
    float L = exp(-lambda);
    int k = 0;
    
    float p = 1;
    do {
      p *= random(1);
      k++;
    } while (p > L);
    
    return k - 1;
  }
  
  //f Fonction de Random Gamma de paramètre _shape_ et _scale_
  // C'est majoritairement de la magie noire cette fonction
  // https://chrispiech.github.io/probabilityForComputerScientists/en/part4/beta/
  float GammaRandom(float shape, float scale) {
    if(shape < 1) {
      float u = random(1);
      return GammaRandom(shape + 1, scale) * pow(u, 1.0 / shape);
    }
    
    float d = shape - 1.0/3.0;
    float c = 1.0 / sqrt(9.0 * d);
    
    float x, v, u;
    do {
      do {
        x = random(1);
        v = 1.0 + c * x;
      } while(v <= 0.0);
      v *= v*v;
      u = random(1);
    } while(u >= (1.0 - 0.331 * x * x * x * x) && log(u) >= 0.5 * x * x + d * (1.0 - v + log(v)));
    return scale * d * v;
  }
  
  //f Fonction de Random Beta de paramètre _alpha_ et _beta_
  float BetaRandom(float alpha, float beta) {
    float x = GammaRandom(alpha, 1.0);
    float y = GammaRandom(beta, 1.0);
    
    return x / (x+y);
  }
  
  float[] ToArray() {
    float[] ret = new float[numOfHyperParameters];
    ret[0] = this.minLR;
    ret[1] = this.maxLR;
    ret[2] = this.lambda;
    ret[3] = this.period;
    ret[4] = this.batchSize;
    for(int k = 0; k < layerSize.length; k++) ret[5+k] = this.layerSize[k];
    
    return ret;
  }
  
  HyperParameters FromArray(float[] array) {
    this.minLR = array[0];
    this.maxLR = array[1];
    this.lambda = array[2];
    this.period = (int)array[3];
    this.batchSize = (int)array[4];
    
    ArrayList<Integer> layerList = new ArrayList<Integer>();
    for(int k = 0; k < maxNumberOfLayers; k++) {
      if(array[k+5] != 0) layerList.add((int)array[k+5]);
      else break;
    }
    
    this.layerSize = new int[layerList.size()];
    for(int k = 0; k < this.layerSize.length; k++) {
      this.layerSize[k] = layerList.get(k);
    }
    
    return this;
  }
  
  public HyperParameters fromJSON(JSONObject json) { return FromJSON(json); }
  
  public HyperParameters FromJSON(JSONObject json) {
    this.minLR = (float)json.getFloat("MinLR");
    this.maxLR = (float)json.getFloat("MaxLR");
    this.period = json.getInt("Period");
    this.batchSize = json.getInt("BatchSize");
    this.lambda = json.getFloat("Lambda");
    
    String[] items = json.getString("Layers").replaceAll("\\[", "").replaceAll("\\]", "").replaceAll("\\s", "").split(",");

    int[] results = new int[items.length];
    
    for (int i = 0; i < items.length; i++) {
      try {
        results[i] = Integer.parseInt(items[i]);
      } catch (NumberFormatException nfe) {
        //NOTE: write something here if you need to recover from formatting errors
      };
    }
    
    this.layerSize = results;
    
    return this;
  }
  
  public JSONObject toJSON() { return ToJSON(); }
  
  public JSONObject ToJSON() {
    JSONObject json = new JSONObject();
    
    json.setFloat("MinLR", (float)this.minLR);
    json.setFloat("MaxLR", (float)this.maxLR);
    json.setInt("Period", this.period);
    json.setInt("BatchSize", this.batchSize);
    json.setFloat("Lambda", (float)this.lambda);
    
    json.setString("Layers", Arrays.toString(this.layerSize));
    
    return json;
  }
  
  @Override
  public String toString() {
    String str = "HyperParameters | Layers[";
    for (int i = 0; i < this.layerSize.length; i++) {
      str += str(this.layerSize[i]);
      if (i < this.layerSize.length - 1) str += ", ";
    }
    
    str += "] Learning Rate from " + String.format("%8.5f", this.minLR) + " to " + String.format("%8.5f", this.maxLR) +
      " | Period " + str(this.period) +
      " | Batch Size " + str(this.batchSize) +
      " | Lambda " + String.format("%9.3E", this.lambda);
    
    return str;
  }
}
