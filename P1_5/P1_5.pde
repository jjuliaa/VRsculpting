
   import gab.opencv.*;
    import processing.video.*;
    import java.awt.Rectangle;
    
    import toxi.geom.*;
    import toxi.geom.mesh.*;
    import java.util.Iterator;
    
    import toxi.physics.*;
    import toxi.physics.behaviors.*;
     import toxi.physics.constraints.*;
    //for 2d
    import toxi.geom.*;
    import toxi.geom.mesh2d.*;
    
        import toxi.util.*;
        import toxi.util.datatypes.*;
    
        import toxi.processing.*;
       
        WETriangleMesh mesh1;
        VerletPhysics physics, emptyp, phys;
        ToxiclibsSupport gfx;
        Voronoi voronoi = new Voronoi();
    
    
        
        ArrayList triangles = new ArrayList();
        ArrayList points = new ArrayList();
        ArrayList centroids = new ArrayList();
        int s;
        
        AttractionBehavior inflate, attractor;
            // attractor settings
    float ATT_RADIUS=20;
    float ATT_ELEVATION=50;
        
    boolean drawer = false;
    boolean drawT = false;
    boolean drawL = false;
    boolean drawA = false;
    boolean mesher = true;
    boolean rec = false;
    
    
    
    PShape poly;
    PImage dpixels, dest;
    PGraphics pg, background, record;

    float weight=0;
    color clicked;
    
        int RESX=50;
    int RESZ=30;
    int SCALE=10;
    
    
    Capture video;
    OpenCV opencv;
    PImage src, src2, colorFilteredImage, ex;
    ArrayList<Contour> contours;
     int rangeLow = 10;
     int rangeHigh = 35;
       int Rw;
       int Rh;
  
    
    void setup() {
      gfx = new ToxiclibsSupport(this);
      
      String[] cameras = Capture.list();
         println("Available cameras:");
         println(cameras);
         
      
      video = new Capture(this, 640, 480, cameras[15]);
      video.start();
      
      opencv = new OpenCV(this, video.width, video.height);
      contours = new ArrayList<Contour>();
      
      mesh1 = new WETriangleMesh("doodle");
      size(1450,999, P3D);
      smooth(); 
      
      phys=new VerletPhysics();
      // create & attach a custom attraction behavior (see below)
      attractor=new YAxisAttractor(new Vec3D(0, ATT_ELEVATION, 0), ATT_RADIUS, 2, 0.01);
      phys.addBehavior(attractor);
      
      record = createGraphics(900, 900);
      ex = loadImage("ex2.png");
      
      
       background = createGraphics(900, 900);
          background.beginDraw();
         
         background.background(255);
         image(background, 640, 0);
         
           background.endDraw();
    }
    
       
    
    
    void draw() {
      
      
    for (Vertex v : mesh1.vertices.values()) {
        v.set(physics.particles.get(v.id));
    }
   
   // for (Vertex v : box.vertices.values()) {
      //  physics.particles.get(v.id).set(v);
   // }
  
     
            
             updatePixels();
              if (video.available()) {
                  video.read();
                }
                opencv.loadImage(video);
                opencv.useColor();
                src = opencv.getSnapshot();
                src2 = opencv.getSnapshot();
                opencv.useColor(HSB);
                opencv.setGray(opencv.getH().clone());
                opencv.inRange(rangeLow, rangeHigh);
                colorFilteredImage = opencv.getSnapshot();
                contours = opencv.findContours(true, true);
                image(src, 0, 0);
                src2.resize(src.width-150, src.height-150);
                src.loadPixels();
                //image(colorFilteredImage, src.width, 0);
                 
                   if (contours.size() > 0) {
                  //update voronoi per frame
                  voronoi = new Voronoi();
                  Contour biggestContour = contours.get(0);
                  Rectangle r = biggestContour.getBoundingBox();
                  
                  biggestContour.setPolygonApproximationFactor(2);
                  Contour ApproxContour = biggestContour.getPolygonApproximation();
                  
                  
           
            
           
    
    ex.resize(src.width, src.height);
    image(ex, src.width, src.height);
    image(src2, 0, src.height);
 
   
    
    
                  //get texture pixels only in contour
                  //dpixels = createImage(r.width, r.height, RGB);
                  dpixels = get(r.x, r.y, r.width, r.height);
                   //getTexture(r.width, r.height, ApproxContour, dpixels);
                   dpixels.updatePixels();
              
                          noStroke(); 
                         // fill(255, 0, 0);
                          //ellipse(r.x + r.width/2, r.y + r.height/2, 30, 30);
                   if (drawer == true) {
                   pushMatrix();
                   fill(red(clicked), green(clicked), blue(clicked));
                             
                    strokeWeight(2); 
                    stroke(255, 0, 0);
                    stroke(100, 100, 100);
                     biggestContour.getPolygonApproximation().draw();
                     stroke(255, 0, 0);
                     biggestContour.draw();
                     popMatrix();
                          }
                          
              //getTexture(r.x, r.y, r.width, r.height, ApproxContour);
              //for (Vertex v : mesh1.vertices.values()) {
              //v.set(physics.particles.get(v.id)); }
              //convert countour to points
                  
                  for (PVector point : ApproxContour.getPoints()) {
                    //vertex(point.x, point.y, point.z);
                    // println("points:", point.x, ",", point.y);
                             voronoi.addPoint(new Vec2D(point.x, point.y));
                             points.add(new PVector(point.x, point.y, point.z));
                  }
                  
        
             
                   for (Vec2D c : voronoi.getSites()) {
                     
                     if (drawA == true) {
                           fill(0, 255, 0);
                          stroke(0, 255, 0);
                           ellipse(c.x, c.y, 2, 2);
                     }
             //for each voronoi site, create a vec 3d physics particle
                           physics = new VerletPhysics();
                           physics.addParticle(new VerletParticle(new Vec3D(c.x, c.y, 0)));
             //for (Vertex v : mesh1.vertices.values()) {
                       
      }
      
      
   
           println("particles:",  physics.particles);
           pushMatrix();
           //image(dpixels, 0, src.height);
           popMatrix();
           //getTexture(r.width, r.height, ApproxContour, dest);
           addMesh(mesh1, ApproxContour);
          // calcTextureCoordinates(mesh1);
           println("colorc???", red(clicked), blue(clicked), green(clicked));
           drawMesh(r.x + r.width/2, r.y +r.height/2);
           //;
           
            float x=map(mouseX, 0, width, -0.5, 0.5)*SCALE*RESX;
      float z=map(mouseY, 0, height, 0.5, -0.5)*SCALE*RESZ;
      attractor.getAttractor().set(x, ATT_ELEVATION, z);
      // update physics
      phys.update();
      // update mesh vertices by moving them to the current position
      // of their associated particles
     /* for (int i=0, num=phys.particles.size(); i<num; i++) {
        mesh1.getVertexForID(i).set(phys.particles.get(i));
      }
      */
      // update mesh normals
     // mesh1.computeFaceNormals();
     
        mesh1.computeVertexNormals();
      
      
      
      
           Clear();
           //initPhysics(mesh1);
          
            // image(dest, 0, src.height);
           
   
  } 
  
  



   } //<>//
                
  //   <<   DRAW   >>   <<     MESH    >> \\
  
void drawMesh(int x, int y) {
 
 
        if (keyPressed==true && key == ' ') {
         clicked = get(mouseX, mouseY);
         
         }
               lights();
  directionalLight(255,255,255,x/2, y/2, 30);
  pointLight(51, 102, 126, x/2, y/2, 10);
  specular(255);
  shininess(50);
          fill(clicked);
      //strokeWeight(1);
      ambientLight(red(clicked), green(clicked), blue(clicked));
         pushMatrix();
         mesh1.computeFaceNormals();
         mesh1.faceOutwards();
         mesh1.computeVertexNormals();
         //mesh1.center(null);
          mesh1.subdivide();
    calcTextureCoordinates(mesh1);
         

      translate(x, y, 0);
      mesh1.center(null);
      
      //rotateY((width / 2 - mouseX) * 0.01f);
      // rotateX((width / 2 - mouseY) * 0.01f);
      //rotateZ((width / 2 - mouseX) * 0.01f);
     
      
      
      noSmooth();
      if (drawL == true) {
      stroke(0, 100, 255);
      strokeWeight(1);
      }
        else
        noStroke();
      
      fill(clicked);
      //rotateY(x * 0.01);
      
      //strokeWeight(1);
      ambientLight(red(clicked), green(clicked), blue(clicked));
        
      textureMode(IMAGE);
      if (mesher == true) {
      //gfx.texturedMesh(mesh1, dpixels, true); 
      
       gfx.mesh(mesh1, true, 0);
      }
      popMatrix();
     

    
     //background.beginDraw();
     
    //copy
   // pushMatrix();
    if (clicked != 0) {
       // pushMatrix();
    translate(x + 600 , y, 1);
    //translate(o , (p)-600, 0);
  
     //rotateX((r.x+r.width/2) * 0.01f);
     //rotateY((r.height) * 0.01f);
     mesh1.center(null);
     gfx.mesh(mesh1, false, 0);
    //gfx.mesh(sun, false, 0);
    // popMatrix();
     //background.endDraw();
    }
    }
    
 
         

                
             
  void resetMesh(WETriangleMesh TheMesh, VerletPhysics P) {
    
       P.update();
      for (Vertex v : TheMesh.vertices.values()) {
          v.set(P.particles.get(v.id));
      }
      TheMesh.center(null);
      for (Vertex v : TheMesh.vertices.values()) {
          P.particles.get(v.id).set(v);
      }
      TheMesh.computeFaceNormals();
      TheMesh.faceOutwards();
      TheMesh.computeVertexNormals();
    
  }
  
  
  void Clear() {
     mesh1.clear();  
    
  }
  

  
  
  void getTexture(int rW, int rH, Contour cont, PImage dest) {
       src.loadPixels();
       dest = new PImage(rW, rH);
       dest.loadPixels();
    
     
                  for (int x = 0; x < rW; x++){
                    for (int y= 0; y < rH; y++) {
                       int loc = y*rW + x;
                       
                        // check if it is in the contour
                    if (cont.containsPoint(x, y) == true) {
                     //get the color 
                        color pix = src.pixels[loc];
                        
                    float rd = red(pix);
                    float gd = green(pix);
                    float bd = blue(pix);
                    color g = color(rd,gd,bd);
                    
                     dest.set(x, y, pix);
                     //dpixels.pixels[loc] = color(pix);

                  
                    }
                    //else { dpixels.pixels[loc] = color(255, 255, 255, 60);
                   // }
                    //dpixels.updatePixels();
                      
                    }
                    
                  }
                  dest.updatePixels();
               
  }
                    
                             
              
  void addMesh(WETriangleMesh mesh, Contour cont) {
    mesh=new WETriangleMesh();
    
               
               for (Triangle2D t : voronoi.getTriangles()) {
                    Vec2D tcentroid = new Vec2D(t.computeCentroid());
                    
                   // if (cont.containsPoint(int(tcentroid.x), int(tcentroid.y)) == false) {
                    //  voronoi.getTriangles.remove(t);
                       
                      if (cont.containsPoint(int(tcentroid.x), int(tcentroid.y)) == true) {
               
        
            //noFill();
            if (drawT == true) {
              beginShape();
              stroke(0, 205,200);
              strokeWeight(0.5);
             gfx.triangle(t, false);
               endShape();  
            }
            
            
            Vec3D a = new Vec3D((t.a.x), (t.a.y), 0);
            //Vec3D b = new Vec3D((t.a.x), 0, (t.a.y));
            Vec3D min = new Vec3D(0, 0, 0);
            Vec3D max = new Vec3D(Rw, Rh, 1  );

  float mx = (max.x - min.x);
  float my = (max.y - min.y);
  
  float i = (t.a.x+min.x)*mx;
  float o = (t.b.y+min.y)*my;
  
   //Vec2D uvi = new Vec2D(i, i);
   //Vec2D uvo = new Vec2D(o, o);
   
 
    

   if (abs(a.x)!=10000 && abs(a.y)!=10000) {
               
                  //mesh1.addFace(t.b.to3DXY(), t.a.to3DXY(), t.c.to3DXY());
                    //println("faces", "-", a, "-");
                   // compute UV coords for all 4 vertices...
                  // define scale vector to create normalized UV coordinates
            Vec2D scaleUV=new Vec2D(Rw-1, Rh-1).reciprocal();
            Vec2D uva=new Vec2D(i,o).scaleSelf(scaleUV);
            Vec2D uvb=new Vec2D(i+1,o).scaleSelf(scaleUV);
            Vec2D uvc=new Vec2D(i+1,o+1).scaleSelf(scaleUV);
            
            
            mesh1.addFace(t.a.to3DXY(), t.b.to3DXY(), t.c.to3DXY(), uva, uvb, uvc);
               
                   
            }
                      }
                   }
                   
                    // lock the 4 corners of the grid plane
      Vec3D min=mesh1.getBoundingBox().getMin();
      Vec3D max=mesh1.getBoundingBox().getMax();
      
        // create a physics particle for each mesh vertex
      for (Vec3D v : mesh1.getVertices()) {
        phys.addParticle(new VerletParticle(v));
      }

               }
            

  
    
    
    

    

    
    
    void mousePressed() {
      
      color clicked = get(mouseX, mouseY);
      println("r: " + red(clicked) + " g: " + green(clicked) + " b: " + blue(clicked));
      
       
      int hue = int(map(hue(clicked), 0, 255, 0, 180));
      println("hue to detect: " + hue);
      
      rangeLow = hue - 7;
      rangeHigh = hue + 7;
      
      
    }
    


    
    
    
    
    void keyPressed() {
      if (key=='s') {
        mesh1.saveAsOBJ(sketchPath("doodle.obj"));
        mesh1.saveAsSTL(sketchPath("doodle.stl"));
      } 
      else {
        mesh1.clear();
      }
      
      if (key == 'd') {
        drawer = !drawer;
      }
   
      if (key == 't') {
        drawT = !drawT; 
      }
      if (key == 'r') {
        drawL = !drawL; 
      }
    
      if (key == 'v') {
        drawA = !drawA; 
       
    }
     if (key == 'm') {
       mesher = !mesher;
     }
     
     if (key == 'p') {
       rec = !rec;
     }
    }
    
    
    
void calcTextureCoordinates(WETriangleMesh mesh) {

  AABB bbox = mesh.getBoundingBox();
  Vec3D min = bbox.getMin();
  Vec3D max = bbox.getMax();

  float mx = 1/(max.x - min.x);
  float my = 1/(max.y - min.y);

  for (Face f : mesh.getFaces()) {
    f.uvA = new Vec2D((f.a.x+min.x)*mx, (f.a.z+min.y)*my);
    f.uvB = new Vec2D((f.b.x+min.x)*mx, (f.b.z+min.y)*my);
    f.uvC = new Vec2D((f.c.x+min.x)*mx, (f.c.z+min.y)*my);
    
   // f.uvA = new Vec2D((f.a.x), (f.a.z));
   // f.uvB = new Vec2D((f.b.x), (f.b.z));
    //f.uvC = new Vec2D((f.c.x), (f.c.z));
    
  }
}


void initPhysics(WETriangleMesh mesh){

//physics = new VerletPhysics();
    //physics.setWorldBounds(new AABB(new Vec3D(), 180));
    // turn mesh vertices into physics particles
    for (Vertex v : mesh.vertices.values()) {
        physics.addParticle(new VerletParticle(v));
    }
    // turn mesh edges into springs
    for (WingedEdge e : mesh.edges.values()) {
        VerletParticle a = physics.particles.get(((WEVertex) e.a).id);
        VerletParticle b = physics.particles.get(((WEVertex) e.b).id);
        physics.addSpring(new VerletSpring(a, b, a.distanceTo(b), 0.005f));
    }
    
     inflate=new AttractionBehavior(new Vec3D(), 40, 20, 0.001f);
     physics.addBehavior(inflate);
}


    
  
  // custom attractor only taking distance in XZ plane into account
    // (everything else inherited from standard AttractionBehavior)
    class YAxisAttractor extends AttractionBehavior {

      public YAxisAttractor(Vec3D attractor, float radius, float strength, float jitter) {
        super(attractor, radius, strength, jitter);
      }
      
      public void apply(VerletParticle p) {
        // compute 2D distance in XZ plane
        Vec2D delta = attractor.to2DXZ().sub(p.to2DXZ());
        float dist = delta.magSquared();
        if (dist < radiusSquared) {
          // compute attraction force in 3D
          Vec3D f = attractor.sub(p).normalizeTo((1.0f - dist / radiusSquared))
            .jitter(jitter).scaleSelf(attrStrength);
          p.addForce(f);
        }
      }
    }

    