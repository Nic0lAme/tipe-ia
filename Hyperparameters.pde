class HyperParameters {
  int numLayers;
  int layerSize;
  double minLR;
  double maxLR;
  double lambda;
  int period;
  int batchSize;
  
  HyperParameters Random() {
    return this;
  }
  
  double[] ToArray() {
    return new double[]{
      this.numLayers,
      this.layerSize,
      this.minLR,
      this.maxLR,
      this.lambda,
      this.period,
      this.bacthSize
    };
  }
}
