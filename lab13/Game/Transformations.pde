int N = 3;

PImage scharr(PImage img) {
  float[][] vKernel = {
  { 3, 0, -3 }, 
  { 10, 0, -10 }, 
  { 3, 0, -3}}; 
  float[][] hKernel = {
  { 3, 10, 3 }, 
  { 0, 0, 0 }, 
  { -3, -10, -3 } };
  
  float hSum, vSum, sum, max = 0;
  PImage result = createImage(img.width, img.height, ALPHA);
  for (int i = 0; i < img.width * img.height; i++) result.pixels[i] = color(0); // clear the image
  
  int margin = N/2;
  float[] buffer = new float[img.width * img.height];
  for (int x = margin; x < img.width - margin; x++) {
    for (int y = margin; y < img.height - margin; y++) {
      hSum = 0; vSum = 0;
      for (int i = 0; i < N; i++) {
        for (int j = 0; j < N; j++) {
          hSum += brightness(img.get((x + j - margin), (y + i - margin))) * hKernel[i][j];
          vSum += brightness(img.get((x + j - margin), (y + i - margin))) * vKernel[i][j];
        }
      }
      sum = sqrt((hSum*hSum) + (vSum*vSum));
      if (sum > max) max = sum;
      buffer[y * result.width + x] = sum;
    }
  }

  for (int y = 2; y < img.height - 2; y++) { // Skip top and bottom edges
    for (int x = 2; x < img.width - 2; x++) { // Skip left and right
      int val=(int) ((buffer[y * img.width + x] / max)*255);
      result.pixels[y * img.width + x]=color(val);
    }
  }

  return result;
}


//Functions for trying gaussian Blur.
PImage gaussianBlur(PImage img) {
  float kernel[][] = {{9, 12, 9}, 
    {12, 15, 12}, 
    {9, 12, 9}};
  float weight = 99;
  return convolute(img, kernel, weight);
}

PImage convolute(PImage img, float[][] kernel, float normFactor) {
  PImage result = createImage(img.width, img.height, ALPHA);
  int margin = N/2;
  for (int x = margin; x < img.width - margin; x++) {
    for (int y = margin; y < img.height - margin; y++) {
      float val = 0;
      for (int i = 0; i < N; i++) {
        for (int j = 0; j < N; j++) {
          val += brightness(img.pixels[(y + i - margin) * img.width + (x + j - margin)]) * kernel[i][j];
        }
      }
      result.pixels[y * img.width + x] = color(val / normFactor);
    }
  }
  return result;
}