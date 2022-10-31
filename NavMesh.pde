import java.util.*;

class Node
{
  String id;
  ArrayList<Wall> polygon;
  ArrayList<Integer> indices = new ArrayList<Integer>();
  PVector center;
  ArrayList<Node> neighbours = new ArrayList<Node>();
  
  
  Node(String id, ArrayList<Wall> polygon)
  {
    this.id = id;
    this.polygon = polygon;
    center = findCenter();
  }
  
  PVector findCenter()
  {
    int x_avg = 0;
    int y_avg = 0;
    
    for(Wall w: polygon) {
      x_avg += w.start.x;
      y_avg += w.start.y;
    }
    x_avg /=polygon.size();
    y_avg /=polygon.size();
    return new PVector(x_avg, y_avg);
  }
  
  boolean isNeighbours(Node n)
  {
     int prev = indices.get(indices.size()-1);
     for(Integer i: indices)
     {
       if (n.indices.contains(prev) && n.indices.contains(i)) return true;
       prev = i;
     }
     
     return false;
  }
    
}


class SearchFrontier{
  Node node;
  SearchFrontier prev_frontier;
  float distanceToEnd;
  float distanceToLast = 0;
  
  SearchFrontier(Node n, SearchFrontier from, PVector end)
  {
    this.node = n;
    this.distanceToEnd = PVector.dist(n.center, end);
    if (from != null)
    {
       this.prev_frontier = from;
       this.distanceToLast = PVector.dist(n.center, from.node.center) + from.distanceToLast;
    }
      
  }
  
  float heuristicSum()
  {
    return distanceToEnd + distanceToLast;
  }
}


class NavMesh
{
  ArrayList<Node> nodes = new ArrayList<Node>();
  int recursionDepth = 0;
  int maxDepth = 1000;
  int pointAmount = 0;
  
  HashMap<PVector, Integer> vert_lookup_map = new HashMap<PVector, Integer>();
  ArrayList<PVector> mapVectors = new ArrayList<PVector>();
  
  PVector midpoint(Node a, Node b)
  {
     int start = 0;
     int end = 0;
    
     int prev_index = a.indices.get(a.indices.size()-1);
     for(Integer i: a.indices)
     {
       if (b.indices.contains(prev_index) && b.indices.contains(i)) {
         start = prev_index;
         end = i;
         break;
       }
       prev_index = i;
     }
     println(a.id + " and " + b.id + " share indices " + start + " and " + end);
     
     
     PVector start_vect, end_vect;
     start_vect = mapVectors.get(start);
     end_vect = mapVectors.get(end);
     
     return new PVector(start_vect.x + (end_vect.x - start_vect.x)/2,
     start_vect.y + (end_vect.y - start_vect.y)/2);
  }

  
  void calculateAdjacencies()
  {
    for (Node n: nodes)
    {
      n.neighbours.clear();
    }
      
    //for(int i = 0; i < nodes.size(); i++){
    
    //if(i + 1 >= nodes.size()) continue;
    //Node a = nodes.get(i);
    //Node b = nodes.get(i + 1);
    
    //if(a.isneighbours(b)) a.neighbours.add(b);
    
    
    //}
    for (Node a: nodes)
    {      
      
      for (Node b: nodes)
      {
         if (b.equals(a)) continue;
         if (a.isNeighbours(b)) a.neighbours.add(b);
      }
    }
  }
  void setIndices(Node node)
  {
     for(Wall w: node.polygon)
     {
         node.indices.add(vert_lookup_map.get(w.start));
     }
  }

  //assume index_1 < index_2
  void splitMap(Node node, int index_1, int index_2)
  {
    
    ArrayList<Wall> polygon_1 = new ArrayList<Wall>();
    ArrayList<Wall> polygon_2 = new ArrayList<Wall>();
    
    //get the vertex positions from your original node
    ArrayList<PVector> node_verts = new ArrayList<PVector>();
    for(Wall w: node.polygon)
    {
      node_verts.add(w.start);
    }
    
    //for polygon_1, just make a polygon from index A to B
    for(int i = index_1; i<=index_2; i++)
    {
      //finishes the polygon
      if (i == index_2) {
        polygon_1.add( new Wall(node_verts.get(index_2), node_verts.get(index_1)) );
        break;
      }
      
      int next_index = i+1;
      if (next_index > node_verts.size()-1) next_index = 0;
      polygon_1.add(new Wall(node_verts.get(i), node_verts.get(next_index)));
    }
    

    
    //start from index_2 and go further until you hit index A. You are guaranteed to finish the polygon once you connect A and B.
    int i = index_2;
    boolean completedpolygon_2 = false;
    while (!completedpolygon_2) {
      if (i == index_1) {
        polygon_2.add( new Wall(node_verts.get(index_1), node_verts.get(index_2)) );
        completedpolygon_2 = true;
        break;
      }
      
      int next_index = i+1;
      if (next_index > node_verts.size()-1) next_index = 0;
      polygon_2.add( new Wall(node_verts.get(i), node_verts.get(next_index)) );
      
      i = next_index;
    }
    
  

    Node nodeA = new Node(recursionDepth+"A", polygon_1);
    setIndices(nodeA);
    nodes.add(nodeA);
    

    Node nodeB = new Node(recursionDepth+"B", polygon_2);
    setIndices(nodeB);    
    nodes.add(nodeB);
    
    
    

    recursionDepth++;
    if (recursionDepth == maxDepth) return;
   
    if (findReflexVertex(polygon_1) != -1) {
      nodes.remove(nodeA);
      convexDecomposition(nodeA);
    }
    if (findReflexVertex(polygon_2) != -1) {
      nodes.remove(nodeB);
      convexDecomposition(nodeB);
    }
  }


  int findReflexVertex(ArrayList<Wall> polygon)
  { 

    for (int i = 0; i<polygon.size(); i++)
    {
     // finding the reflex angle by finding where it turns right
     int j = i + 1;
     // for index out of bounds
     if( j >= polygon.size()) j = 0;
      if (polygon.get(i).normal.dot(polygon.get(j).direction) >= 0) {
        return j;
      }
    }
    
    return -1;
  }
  
  
  int joiningVertex(ArrayList<Wall> polygon, int convex_index)
  {
    //you need the PVectors for this one
    ArrayList<PVector> vertices = new ArrayList<PVector>();
    for(Wall w: polygon)
    {
      vertices.add(w.start);
    }
    
    PVector pointAtIndex = vertices.get(convex_index);

   
    int next_index = convex_index + 1;
    if (next_index >= vertices.size()) next_index = 0;

    int lastIndex = convex_index - 1;
    if (lastIndex < 0) lastIndex = vertices.size() - 1;

    for (int potentialConnecting = vertices.size()-1; potentialConnecting>=0; potentialConnecting--)
    {
      
      if (potentialConnecting == next_index || potentialConnecting == convex_index || potentialConnecting == lastIndex) continue;

      PVector potentialConnectingPoint = vertices.get(potentialConnecting);
      
      if (!map.intersectsWall(pointAtIndex, potentialConnectingPoint))
      {
        return potentialConnecting;
      }
    }
    
    return -1;
  }
  
  
  void convexDecomposition(Node node)
  {
    int convex_index = findReflexVertex(node.polygon);
    if (convex_index == -1) return;
    
    int joining_index = joiningVertex(node.polygon, convex_index);
    if (joining_index == -1) return;
    
   
    splitMap(node, min(convex_index, joining_index), max(convex_index, joining_index));
  }

  //creates a hashmap with key PVector and value Integer
 
  void setVertexMap(Map map)
  {
    //clear all lookups and map vectors
    mapVectors.clear();
    vert_lookup_map.clear();
    
    for (int i = 0; i < map.walls.size(); i++)
    {
      vert_lookup_map.put(map.walls.get(i).start, i);
      mapVectors.add(map.walls.get(i).start);
     
    }
  }

  void bake(Map map)
  {    
    //reset recursions and other values
    recursionDepth = 0;
    nodes.clear();
    pointAmount = map.walls.size();
    
    vert_lookup_map.clear();
    mapVectors.clear();
    
    //make hashmap of vertices
    setVertexMap(map);
    
    //create a node with the whole map walls
    Node m = new Node("Map", map.outline);
    setIndices(m);
    
   
    convexDecomposition(m);
    
   
    calculateAdjacencies();
       
    
  }

 Node nodeFromPoint(PVector p)
  {
    for (Node n: nodes)
    {
      if (isPointInPolygon(p,n.polygon))
        return n;
    }
    
    return null;
  }
  //Uses A* to find a path from start to dest
  ArrayList<PVector> findPath(PVector start, PVector dest)
  {
    println("dest vec " + dest);
    ArrayList<SearchFrontier> frontier = new ArrayList<SearchFrontier>(); 
    ArrayList<Node> visited_nodes = new ArrayList<Node>(); 
    Node node_start = nodeFromPoint(start);
    Node node_dest = nodeFromPoint(dest);
    println("dest node " + node_dest);
    //for (Node n: nodes)
    //{
    //  if (isPointInPolygon(start,n.polygon)) node_start = n;
    //  else if (isPointInPolygon(dest,n.polygon)) node_dest = n;
    //  //else println("node_dest is null");
        
    //}
   
    
    SearchFrontier s = new SearchFrontier(node_start, null, node_dest.findCenter());
    frontier.add(s);
    visited_nodes.add(frontier.get(0).node);
    
    println("frontier " + frontier);
    //till the end of of frontier
    while (frontier.get(0).node != node_dest)
    {
      
      SearchFrontier first_frontier = frontier.get(0);
      // add all the neighbours of first
      
      for (Node neighbours: first_frontier.node.neighbours)
      {
        println("loop");
        if (!visited_nodes.contains(neighbours))
        {
          frontier.add(new SearchFrontier(neighbours, first_frontier, node_dest.findCenter())); 
        }
      }

      frontier.remove(0);
      //sort via lambda function
      
      frontier.sort((a,b) -> {
        if (a.heuristicSum() > b.heuristicSum()) return 1;
        else if (a.heuristicSum() < b.heuristicSum()) return -1;
        else return 0;
      });
      //add the removed node to visited list
      visited_nodes.add(first_frontier.node);
    }
    
    return findDestPath(dest, node_start, frontier);
  }
  
 
  
  //given a list of frontiers, create a PVector path from the start to dest
  ArrayList<PVector> findDestPath(PVector dest, Node node_start, ArrayList<SearchFrontier> genPath)
  {
    
    
    ArrayList<PVector> res = new ArrayList<PVector>();
    //add the end
    res.add(dest);
    SearchFrontier front = genPath.get(0);
    while (front.node != node_start) {
      PVector midPoint = midpoint(front.node, front.prev_frontier.node);
      res.add(midPoint);
      
      //assign previous frontier to start
      front = front.prev_frontier;
    }
    
    
    Collections.reverse(res);
    println("result " + res);
    return res;
  }

  
  void update(float dt)
  {
    draw();
  }

  void draw()
  {
    
    strokeWeight(3);
    
    
    for (Node n: nodes)
    {
      for (Wall w: n.polygon)
      {
         stroke(0,255,255);
         strokeWeight(3);
          line(w.start.x, w.start.y, w.end.x, w.end.y);
          //w.draw();
      }
    }
  }
}
