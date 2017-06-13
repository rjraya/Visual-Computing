class HoughComparator implements java.util.Comparator<Integer> {
  int[] accumulator;
  public HoughComparator(int[] accumulator) {
    this.accumulator = accumulator;
  }
  @Override
  public int compare(Integer l1, Integer l2) {
    if (accumulator[l1] > accumulator[l2] || (accumulator[l1] == accumulator[l2] && l1 < l2)) {
      return -1;
    }
    return 1;
  }
}

class HoughAlgorithm{
  float discretizationStepsPhi = 0.005f;
  float discretizationStepsR = 2.5f;
  int phiDim = (int) (Math.PI / discretizationStepsPhi);
  PImage edgeImg;
  int rDim;
  int minVotes = 100;
  int neighbourhood = 10;
  
  HoughAlgorithm(PImage img){
    rDim = (int) ((sqrt(img.width*img.width + img.height*img.height) * 2) / discretizationStepsR +1);
    edgeImg = img;
  }  
  
  ArrayList<PVector> hough(int nLines) {  
    int[] accumulator = getHoughAccumulator();
    ArrayList<Integer> bestCandidates  = getBestCandidates(rDim, phiDim, accumulator);
    ArrayList<PVector> linesAsVectorArray = getLines(bestCandidates, rDim, nLines);
    return linesAsVectorArray;
  }
 
  
  ArrayList<Integer> getBestCandidates(int rDim, int phiDim, int[] accumulator) {
    ArrayList<Integer> bestCandidates = new ArrayList<Integer>();
    for (int accR = 0; accR < rDim; accR++) {
      for (int accPhi = 0; accPhi < phiDim; accPhi++) {
        int idx = (accPhi + 1) * (rDim + 2) + accR + 1;
        if (accumulator[idx] > minVotes) {
          boolean bestCandidate = true;
          for (int dPhi = -neighbourhood/2; dPhi < neighbourhood / 2 + 1; dPhi++) {
            if ( accPhi + dPhi < 0 || accPhi+dPhi >= phiDim) continue;
            for (int dR = -neighbourhood/2; dR < neighbourhood / 2 + 1; dR++) {
              if (accR + dR < 0 || accR + dR >= rDim) continue;
              int neighbourIdx = (accPhi + dPhi + 1) * (rDim + 2) + accR + dR + 1;
              if (accumulator[idx] < accumulator[neighbourIdx]) {
                bestCandidate = false;
                break;
               }
             }
            if (!bestCandidate) break;
          }
          if (bestCandidate) { bestCandidates.add(idx); }     
        }
      }
    }
    Collections.sort(bestCandidates, new HoughComparator(accumulator));
    for(Integer i: bestCandidates){ 
      println("minVotes was: "+ accumulator[i]);
    }
    return bestCandidates;
  } 

  ArrayList<PVector> getLines(ArrayList<Integer> bestCandidates, int rDim, int nLines) {
    ArrayList<PVector> lines = new ArrayList<PVector>();
    List<Integer> bestLines = bestCandidates.subList(0, min(nLines, bestCandidates.size()));
    for (int idx : bestLines) {
      // first, compute back the (r, phi) polar coordinates:
      int accPhi = (int) (idx / (rDim + 2)) - 1;
      int accR = idx - (accPhi + 1) * (rDim + 2) - 1;
      float r = (accR - (rDim - 1) * 0.5f) * discretizationStepsR;
      float phi = accPhi * discretizationStepsPhi;
      PVector line = new PVector(r, phi);
      lines.add(line);
    }
    return lines;
  }

  int[] getHoughAccumulator() {   
    float[] tabSin = new float[phiDim];
    float[] tabCos = new float[phiDim];
    float ang = 0;
    float inverseR = 1.f / discretizationStepsR;
    for (int accPhi = 0; accPhi < phiDim; ang += discretizationStepsPhi, accPhi++) {
      tabSin[accPhi] = (float) (Math.sin(ang) * inverseR);
      tabCos[accPhi] = (float) (Math.cos(ang) * inverseR);
    }

    int[] accumulator = new int[(phiDim + 2) * (rDim + 2)];
    for (int y = 0; y < edgeImg.height; ++y) {
      for (int x = 0; x < edgeImg.width; ++x) {
        if (brightness(edgeImg.pixels[y * edgeImg.width + x]) != 0) {
          for (int i = 0; i < phiDim; ++i) {
            double r = x*tabCos[i] + y*tabSin[i];
            int radius = (int)Math.round(r + (rDim -1)/2);
            accumulator[(i+1)*(rDim+2) + radius+1] += 1;
          }
        }
      }
    }
    return accumulator;
  } 
}