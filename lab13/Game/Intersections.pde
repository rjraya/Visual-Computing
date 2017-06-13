import java.util.Arrays;

void drawIntersections(ArrayList<PVector> intersections) {
  for (PVector i : intersections) {
    fill(255, 128, 0);
    ellipse(i.x, i.y, 10, 10);
  }
}

ArrayList<PVector> getQuad(ArrayList<PVector> lines, int imgWidth, int imgHeight) {
  QuadGraph graph = new QuadGraph();
  graph.build(lines, imgWidth, imgHeight);
  graph.findCycles(false);
  ArrayList<int[]> cycles = new ArrayList<int[]>(graph.cycles);
  for (int[] cycle : cycles) {
    PVector l1 = lines.get(cycle[0]);
    PVector l2 = lines.get(cycle[1]);
    PVector l3 = lines.get(cycle[2]);
    PVector l4 = lines.get(cycle[3]);
    PVector c12 = graph.intersection(l1, l2);
    PVector c23 = graph.intersection(l2, l3);
    PVector c34 = graph.intersection(l3, l4);
    PVector c41 = graph.intersection(l4, l1);
    if (graph.isConvex(c12, c23, c34, c41) &&
        graph.validArea(c12, c23, c34, c41, imgWidth*imgHeight, (imgWidth*imgHeight)/100) != 0 && 
        graph.nonFlatQuad(c12, c23, c34, c41)) {
      return new ArrayList<PVector>(Arrays.asList(c12, c23, c34, c41, l1, l2, l3, l4));
    }
  }
  return new ArrayList<PVector>();
}


void drawBorderLines(ArrayList<PVector> lines, int imgWidth) {
  for (PVector l : lines) {
    float r = l.x;
    float phi = l.y;
    int x0 = 0;
    int y0 = (int) (r / sin(phi));
    int x1 = (int) (r / cos(phi));
    int y1 = 0;
    int x2 = imgWidth;
    int y2 = (int) (-cos(phi) / sin(phi) * x2 + r / sin(phi));
    int y3 = imgWidth;
    int x3 = (int) (-(y3 - r / sin(phi)) * (sin(phi) / cos(phi)));
    // Finally, plot the lines
    stroke(204, 102, 0);
    if (y0 > 0) {
      if (x1 > 0)
        line(x0, y0, x1, y1);
      else if (y2 > 0)
        line(x0, y0, x2, y2);
      else
        line(x0, y0, x3, y3);
    } else {
      if (x1 > 0) {
        if (y2 > 0)
          line(x1, y1, x2, y2);
        else
          line(x1, y1, x3, y3);
      } else
        line(x2, y2, x3, y3);
    }
  }
}