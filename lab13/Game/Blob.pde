import java.util.ArrayList;
import java.util.List;
import java.util.TreeSet;
import java.util.Random;
import java.util.HashSet;

class BlobDetection {
  List<TreeSet<Integer>> labelsEquivalences;
  Random r;
  int[] counts;
  int currentLabel;
  int[] labels;
  PImage input;
  
  BlobDetection(PImage img){
    labelsEquivalences = new ArrayList<TreeSet<Integer>>();
    r = new Random();
    currentLabel = 0;
    input = img;
    labels= new int [input.width*input.height];
  }

  // Gives the surrounding valid neighbors. Removes zeros.
  ArrayList<Integer> findNeighbor(int x, int y, int w){
    ArrayList result = new ArrayList<Integer>();
    
    int cell = y * w + x;
    int left = cell - 1; int upLeft = cell - w - 1; 
    int up = cell - w; int upRight = cell - w + 1;
    
    Boolean hasLeft = x != 0;
    Boolean hasUp = y != 0;
    Boolean hasRight = x != 199;
    
    if (hasLeft && labels[left] != 0)              result.add(labels[left]); 
    if (hasUp && hasRight && labels[upRight] != 0) result.add(labels[upRight]);
    if (hasUp && labels[up] != 0)                  result.add(labels[up]);
    if (hasUp && hasLeft && labels[upLeft] != 0)   result.add(labels[upLeft]);
  
    return result;
  }
  
  PImage findConnectedComponents(Boolean onlyBiggest) {
    // First pass: label the pixels and store labels’ equivalences  
    for (int i = 0; i < input.width*input.height; i++) labels[i] = 0; //initialization

    for (int i=0; i < input.width; i++){
      for (int j=0; j < input.height; j++){      
        if(brightness(input.pixels[j*input.width+i]) >= 10){
          ArrayList<Integer> neighbor = findNeighbor(i, j, input.width);  
          if(neighbor.size() > 0) { //there is at least one non-zero neighbor
            if(allLabelsEqual(neighbor)) {
              labels[j * input.width + i] = neighbor.get(0);
             } else {
               labels[j * input.width + i] = neighbor.get(findMin(neighbor));
               markEquivalence(neighbor);
             }          
           } else {
             currentLabel++;     
             addEquivalenceClass();
             labels[j * input.width + i] = currentLabel;          
           }
         }            
       } 
     }

    // Second pass: re-label the pixels by their equivalent class
    // if onlyBiggest==true, count the number of pixels for each label
    
    for (int i = 0; i < input.width; i++){
      for (int j = 0; j < input.height; j++){
        int label = labels[j * input.width + i];
        if (label != 0){ 
          TreeSet<Integer> ll = labelsEquivalences.get(label-1);
          int l = ll.first();
          labels[j * input.width + i] = l;
        }  
      }
    }
    
    //Find a list of labels associated with a list of occurrences
    ArrayList<Integer> uniqueLabels = new ArrayList<Integer>();
    if(onlyBiggest){    
      for(Integer label: labels){
        if(!uniqueLabels.contains(label) && label != 0){ 
          uniqueLabels.add(label);
        }  
      }  
      counts = new int[uniqueLabels.size()];
      for(int i = 0; i < counts.length; i++) counts[i] = 0; //if we don't assume it is set up to zero
      for(int i = 0; i < uniqueLabels.size(); i++){
        int unique = uniqueLabels.get(i);
        for(Integer label: labels){
          if(label == unique) counts[i] += 1;
        }  
      }  
      
    }
    
    // Finally,
    // if onlyBiggest==false, output an image with each blob colored in one uniform color
    // if onlyBiggest==true, output an image with the biggest blob colored in white and the others in black
    
    if(onlyBiggest){
      if(counts.length > 0){
        int maxIndex = findMax(counts);
        int maxLabel = uniqueLabels.get(maxIndex);

        //change the color of the blobs in the pixels of inputs
        for (int i = 0; i < input.width; i++){
          for (int j = 0; j < input.height; j++){
            int colorIndex = labels[j * input.width + i];
            if (colorIndex == maxLabel){
              input.pixels[j*input.width+i] = color(255,255,255);
            } else {
              input.pixels[j*input.width+i] = color(0,0,0);
            }  
          }
        }
      } else { // everything needs to be black
        for (int i = 0; i < input.pixels.length; i++){
          input.pixels[i] = color(0,0,0);  
        }
      }  
    } else {
      ArrayList<PVector> randColor= new ArrayList<PVector>();
      for (int k = 0; k < currentLabel; k++){
        randColor.add(new PVector(r.nextInt(256), r.nextInt(256), r.nextInt(256)));
      }
      //change the color of the blobs in the pixels of inputs
      for (int i = 0; i < input.width; i++){
        for (int j = 0; j < input.height; j++){
          int colorIndex = labels[j * input.width + i];
          if (colorIndex != 0){
            input.pixels[j*input.width+i] = color(randColor.get(colorIndex).x, randColor.get(colorIndex).y, randColor.get(colorIndex).z);
          }
        }
      }
    }  
    
    input.updatePixels();
    return input;
  }
  
  // Ensure that this is call with a non-empty array list.
  Boolean allLabelsEqual(ArrayList<Integer> a){
    Boolean allEqual = true;
    int sample = a.get(0);
    for (int k = 0; k < a.size() && allEqual; k++){
      if (a.get(k) != sample){
        allEqual = false;
      }  
    }
    return allEqual;
  }  
   // Ensure that this is call with a non-empty array list.
  int findMin(ArrayList<Integer> a){
    int min = a.get(0);
    int index = 0;
    for (int k = 1; k < a.size(); k++){
      if (a.get(k) < min){
        min = a.get(k);
        index = k;
      }
    }
    return index;
  }  
  // Ensure that this is call with a non-empty array list.
  int findMax(ArrayList<Integer> a){
    int max = a.get(0);
    int index = 0;
    for (int k = 1; k < a.size(); k++){
      if (a.get(k) > max){
        max = a.get(k);
        index = k;
      }
    }
    return index;
  } 
  
  // Ensure that this is call with a non-empty array list.
  int findMax(int[] a){
    int max = a[0];
    int index = 0;
    for (int k = 1; k < a.length; k++){
      if (a[k] > max){
        max = a[k];
        index = k;
      }
    }
    return index;
  }
  
  void markEquivalence(ArrayList<Integer> a){  
    //building equivalence classes
    for (int i = 0; i < a.size() ; i++){ // representant of equivalence class
      int representant = a.get(i);
      for (int j = 0; j < a.size(); j++){ // element to add to the class       
        int equivalent = a.get(j);
        for(Integer related: labelsEquivalences.get(equivalent-1)){
          labelsEquivalences.get(representant-1).add(related);
        }               
      }
    }       
  }
  
  void addEquivalenceClass(){
    // create the equivalence class for this element
    TreeSet<Integer> set = new TreeSet<Integer>();
    set.add(currentLabel);
    labelsEquivalences.add(set);
  }  
 
}