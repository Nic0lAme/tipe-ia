class HyperParameters {
  int w, h;
  int numLayers;
  int layerSize;
  
  HyperParameters Random() {
    return this;
  }
  
  double[] ToArray() {
    return new double[]{
      this.w,
      this.h,
      this.numLayers,
      this.layerSize
    };
  }
}
