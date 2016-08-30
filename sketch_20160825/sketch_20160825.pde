Quaternion gq;
float gz;
float time;
int ny;
float trans;
int frames = 300;

Vec[][][] vs;

Spring sprN;
Spring sprR;
Spring sprQ;
Spring sprQ2;
Spring sprRing;
Spring sprAxis;

int clamp( int _i, int _a, int _b ) {
  return min( max( _i, _a ), _b );
}

float clamp( float _i, float _a, float _b ) {
  return min( max( _i, _a ), _b );
}

float saturate( float _i ) {
  return clamp( _i, 0.0, 1.0 );
}

void dotline( float _x1, float _y1, float _x2, float _y2, float _r, float _i ) {
  float dx = _x2 - _x1;
  float dy = _y2 - _y1;
  float l = dist( _x1, _y1, _x2, _y2 );
  float nx = dx / l;
  float ny = dy / l;
  float d = l / 2.0;
  
  while ( 0 < d ) {
    float x = _x1 + nx * d;
    float y = _y1 + ny * d;
    ellipse( x, y, _r, _r );
    
    if ( d != l / 2.0 ) {
      x = _x2 - nx * d;
      y = _y2 - ny * d;
      ellipse( x, y, _r, _r );
    }
    
    d -= _i;
  }
}

void cullTri( float _x1, float _y1, float _x2, float _y2, float _x3, float _y3 ) {
  if ( 0.0 < ( _x2 - _x1 ) * ( _y3 - _y1 ) - ( _x3 - _x1 ) * ( _y2 - _y1 ) ) {
    
  } else {
    fill( lerpColor( color( 0 ), g.fillColor, 0.4 ) );
  }
  triangle( _x1, _y1, _x2, _y2, _x3, _y3 );
}

color surfaceColor( float _t, Vec _v ) {
  return color(
    lerpColor(
      lerpColor(
        color( 0 ),
        color( 180, 0, 60 ),
        0.0 < _t ? sin( exp( -_t * 100.0 ) * PI ) : 0.0
      ),
      color( _v.z * 20 + 20, _v.y * 50 + 90, _v.x * 30 + 70 ),
      0.02 < _t ? 1.0 - exp( -( _t - 0.02 ) * 80.0 ) : 0.0
    )
  );
}

void setup() {
  size( 800, 800, P2D );
  
  strokeJoin( ROUND );
  strokeCap( ROUND );
  
  gz = -2.0;
  
  sprN = new Spring( 4000.0 );
  sprN.target = 3.0;
  sprN.pos = 3.0;
  
  sprR = new Spring( 5000.0 );
  sprR.target = 0.0;
  sprR.pos = 0.0;
  
  sprQ = new Spring( 5000.0 );
  sprQ.target = 0.0;
  sprQ.pos = 0.0;
  
  sprQ2 = new Spring( 5000.0 );
  sprQ2.target = 0.0;
  sprQ2.pos = 0.0;
  
  sprRing = new Spring( 5000.0 );
  sprRing.target = 0.0;
  sprRing.pos = 0.0;
  
  sprAxis = new Spring( 5000.0 );
  sprAxis.target = 0.0;
  sprAxis.pos = 0.0;
}

void spring( float _deltaTime ) {
  if ( time < 0.2 ) { sprN.target = 3.0; }
  else if ( time < 0.26 ) { sprN.target = 4.0; }
  else if ( time < 0.32 ) { sprN.target = 5.0; }
  else if ( time < 0.38 ) { sprN.target = 6.0; }
  else if ( time < 0.44 ) { sprN.target = 7.0; }
  sprN.update( _deltaTime );
  
  if ( time < 0.05 ) { sprR.target = 0.0; }
  else if ( time < 0.9 ) { sprR.target = 1.0; }
  else { sprR.target = 0.0; }
  sprR.update( _deltaTime );
  
  if ( time < 0.6 ) { sprQ.target = 0.0; }
  else { sprQ.target = 1.0; }
  sprQ.update( _deltaTime );
  
  if ( time < 0.76 ) { sprQ2.target = 0.0; }
  else { sprQ2.target = 1.0; }
  sprQ2.update( _deltaTime );
  
  if ( time < 0.1 ) { sprRing.target = 0.0; }
  else if ( time < 0.50 ) { sprRing.target = 1.0; }
  else { sprRing.target = 0.0; }
  sprRing.update( _deltaTime );
  
  if ( time < 0.0 ) { sprAxis.target = 0.0; }
  else if ( time < 0.50 ) { sprAxis.target = 1.0; }
  else { sprAxis.target = 0.0; }
  sprAxis.update( _deltaTime );
}

void prepareVertices() {
  vs = new Vec[ ny ][ 2 ][ ( ny - 1 ) * 4 ];
  
  for ( int id = 0; id < 2; id ++ ) {
    Vec v = new Vec( 0.0, ( id * 2.0 - 1.0 ) * sprR.pos, 0.0 );
    float t = time - 0.8 - noise( v.x / 0.181, v.y / 0.147, v.z / 0.129 ) * 0.1;
    float a = pow( noise( v.x / 0.61, v.y / 0.53, v.z / 0.77 ) * 1.3, 3.0 );
    
    v = v.rotate( gq );
    v = v.add( new Vec( 0.0, 0.0, -0.4 ).scale( sprQ.pos ) );
    v = v.add( new Vec( 0.0, 0.0, 0.9 ).scale( sprQ2.pos ) );
    v = v.add( new Vec( 3.0, 2.0, 1.0 ).scale( 0.0 < t ? a * sprR.pos : 0.0 ) );
    
    vs[ 0 ][ id ][ 0 ] = v;
  }
  
  for ( int iy = 1; iy < ny; iy ++ ) {
    for ( int id = 0; id < 2; id ++ ) {
      for ( int ix = 0; ix < iy * 4; ix ++ ) {
        float ry = PI / 2.0 * ( id * 2 - 1 ) * saturate( lerp(
          1.0 * ( ( ny - 1 ) - iy ) / ( ny - 1 ),
          1.0 * ( ( ny - 1.999 ) - iy ) / ( ny - 1.999 ),
          trans
        ) );
        
        float rx = PI * 2.0 * ( lerp(
          1.0 * ix / ( 4.0 * iy ),
          1.0 * ( ix - ix / iy ) / ( 4.0 * ( iy - 0.999 ) ),
          iy == ( ny - 1 ) ? trans : 0.0
        ) );
        
        Vec v = new Vec( sprR.pos, 0.0, 0.0 );
        v = v.rotate( rotateQuaternion( ry, new Vec( 0.0, 0.0, 1.0 ) ) );
        v = v.rotate( rotateQuaternion( rx, new Vec( 0.0, 1.0, 0.0 ) ) );
        float t = time - 0.8 - noise( v.x / 0.181, v.y / 0.147, v.z / 0.129 ) * 0.1;
        float a = pow( noise( v.x / 0.61, v.y / 0.53, v.z / 0.77 ) * 1.3, 3.0 );
        
        v = v.rotate( gq );
        v = v.add( new Vec( 0.0, 0.0, -0.4 ).scale( sprQ.pos ) );
        v = v.add( new Vec( 0.0, 0.0, 0.9 ).scale( sprQ2.pos ) );
        v = v.add( new Vec( 3.0, 2.0, 1.0 ).scale( 0.0 < t ? a * sprR.pos : 0.0 ) );
        
        vs[ iy ][ id ][ ix ] = v;
      }
    }
  }
}

void drawGrid() {
  noStroke();
  
  float i = 1.0;
  int n = 6;
  for ( int iz = -n; iz <= n; iz ++ ) {
    for ( int iy = -n; iy <= n; iy ++ ) {
      for ( int ix = -n; ix <= n; ix ++ ) {
        Vec v = new Vec( i * ix, i * iy, i * iz );
        v = v.rotate( gq );
        
        Vec sv = v.toScreen( gz );
        if ( 0.0 < sv.z ) {
          fill( 170 * exp( -sv.z * 0.3 ) );
          ellipse( sv.x, sv.y, 4.0, 4.0 );
        }
      }
    }
  }
}

void drawAxis() {
  stroke( 160 );
  strokeWeight( 3 );
  noFill();
  
  float l = saturate( sprAxis.pos - 0.03 );
  {
    Vec v1 = new Vec( 0.0, -2.7 * l, 0.0 );
    v1 = v1.rotate( gq );
    Vec v2 = new Vec( 0.0, 2.7 * l, 0.0 );
    v2 = v2.rotate( gq );
    
    Vec sv1 = v1.toScreen( gz );
    Vec sv2 = v2.toScreen( gz );
    line( sv1.x, sv1.y, sv2.x, sv2.y );
  }
}

void drawDotLine() {
  for ( int iy = 1; iy < ny; iy ++ ) {
    for ( int id = 0; id < 2; id ++ ) {
      for ( int ix = 0; ix < iy * 4; ix ++ ) {
        if ( id == 1 && iy == ny - 1 ) { continue; }
        Vec v1 = vs[ iy ][ id ][ ix ];
        Vec v2 = vs[ iy ][ id ][ ( ix + 1 ) % ( iy * 4 ) ];
        Vec sv1 = v1.toScreen( gz );
        Vec sv2 = v2.toScreen( gz );
        
        noStroke();
        fill( 80 );
        
        dotline( sv1.x, sv1.y, sv2.x, sv2.y, 3, 7 );
      }
    }
  }
        
  for ( int iy = 1; iy < ny; iy ++ ) {
    for ( int id = 0; id < 2; id ++ ) {
      for ( int ix = 0; ix < iy * 4; ix ++ ) {
        for ( int ip = ( ix % iy == 0 ) ? 0 : -1; ip < 1; ip ++ ) {
          int xMax = ( ( iy - 1 ) * 4 );
          Vec v1 = vs[ iy ][ id ][ ix ];
          Vec v2 = iy == 1 ? vs[ 0 ][ id ][ 0 ] : vs[ iy - 1 ][ id ][ ( ix - ix / iy + ip + xMax ) % xMax ];
          Vec sv1 = v1.toScreen( gz );
          Vec sv2 = v2.toScreen( gz );
          
          noStroke();
          fill( 80 );
          
          dotline( sv1.x, sv1.y, sv2.x, sv2.y, 3, 7 );
        }
      }
    }
  }
}

void drawRing() {
  stroke( 120 );
  strokeWeight( 3 );
  noFill();
  
  for ( int iy = 1; iy < ny; iy ++ ) {
    for ( int id = 0; id < 2; id ++ ) {
      if ( id == 1 && iy == ny - 1 ) { continue; }
      beginShape();
      for ( int ix = 0; ix < 64; ix ++ ) {
        float ry = PI / 2.0 * ( id * 2 - 1 ) * saturate( lerp(
          1.0 * ( ( ny - 1 ) - iy ) / ( ny - 1 ),
          1.0 * ( ( ny - 1.999 ) - iy ) / ( ny - 1.999 ),
          trans
        ) );
        float rx = ix * PI * 2.0 / 63.0 * sprRing.pos;
        
        Vec v = new Vec( sprR.pos, 0.0, 0.0 );
        v = v.rotate( rotateQuaternion( ry, new Vec( 0.0, 0.0, 1.0 ) ) );
        v = v.rotate( rotateQuaternion( rx, new Vec( 0.0, 1.0, 0.0 ) ) );
        v = v.rotate( gq );
        
        Vec sv = v.toScreen( gz );
        vertex( sv.x, sv.y );
      }
      endShape();
    }
  }
}

void drawVertices() {
  for ( int iy = 1; iy < ny; iy ++ ) {
    for ( int id = 0; id < 2; id ++ ) {
      for ( int ix = 0; ix < iy * 4; ix ++ ) {
        if ( id == 1 && iy == ny - 1 ) { continue; }
        Vec v = vs[ iy ][ id ][ ix ];
        Vec sv = v.toScreen( gz );
        
        noStroke();
        fill( 255 );
        
        ellipse( sv.x, sv.y, 10.0, 10.0 );
      }
    }
  }
  
  for ( int id = 0; id < 2; id ++ ) {
    Vec v = vs[ 0 ][ id ][ 0 ];
    Vec sv = v.toScreen( gz );
    
    noStroke();
    fill( 255 );
    
    ellipse( sv.x, sv.y, 10.0, 10.0 );
  }
}

void drawSurface() {
  for ( int iy = 1; iy < ny; iy ++ ) {
    for ( int id = 0; id < 2; id ++ ) {
      for ( int ix = 0; ix < iy * 4; ix ++ ) {
        int xMax = ( iy - 1 ) * 4;
        
        {
          float t = time - 0.75 + noise( iy / 1.29, id / 1.21, ix / 1.52 ) * 0.1;
          
          Vec v1 = vs[ iy ][ id ][ ix ];
          Vec v2 = vs[ iy ][ id ][ ( ix + 1 ) % ( iy * 4 ) ];
          Vec v3 = iy == 1 ? vs[ 0 ][ id ][ 0 ] : vs[ iy - 1 ][ id ][ ( ix - ix / iy ) % xMax ];
          
          Vec vm = v1.add( v2 ).add( v3 ).scale( 1.0 / 3.0 );
          Vec vmn = vm.normalize();
          
          float fw = exp( -t * 80.0 ) * 0.1;
          v1 = v1.add( vmn.scale( fw ) );
          v2 = v2.add( vmn.scale( fw ) );
          v3 = v3.add( vmn.scale( fw ) );
          
          Vec sv1 = v1.toScreen( gz );
          Vec sv2 = id == 0 ? v2.toScreen( gz ) : v3.toScreen( gz );
          Vec sv3 = id == 0 ? v3.toScreen( gz ) : v2.toScreen( gz );
          
          noStroke();
          fill( surfaceColor( t, vmn ) );
          cullTri( sv1.x, sv1.y, sv2.x, sv2.y, sv3.x, sv3.y );
        }
        
        if ( ix % iy != 0 ) {
          float t = time - 0.75 + noise( iy / 1.61, id / 1.77, ix / 1.12 ) * 0.1;
          
          Vec v1 = vs[ iy ][ id ][ ix ];
          Vec v2 = iy == 1 ? vs[ 0 ][ id ][ 0 ] : vs[ iy - 1 ][ id ][ ( ix - ix / iy ) % xMax ];
          Vec v3 = iy == 1 ? vs[ 0 ][ id ][ 0 ] : vs[ iy - 1 ][ id ][ ( ix - ix / iy - 1 + xMax ) % xMax ];
          
          Vec vm = v1.add( v2 ).add( v3 ).scale( 1.0 / 3.0 );
          Vec vmn = vm.normalize();
          
          float fw = exp( -t * 80.0 ) * 0.1;
          v1 = v1.add( vmn.scale( fw ) );
          v2 = v2.add( vmn.scale( fw ) );
          v3 = v3.add( vmn.scale( fw ) );
          
          Vec sv1 = v1.toScreen( gz );
          Vec sv2 = id == 0 ? v2.toScreen( gz ) : v3.toScreen( gz );
          Vec sv3 = id == 0 ? v3.toScreen( gz ) : v2.toScreen( gz );
          
          noStroke();
          fill( surfaceColor( t, vmn ) );
          cullTri( sv1.x, sv1.y, sv2.x, sv2.y, sv3.x, sv3.y );
        }
      }
    }
  }
}

void draw() {
  time = ( frameCount * 1.0 / frames ) % 1.0;
  
  background( 30, 40, 50 );
  
  blendMode( ADD );
  
  spring( 1.0 / frames );
  
  ny = int( sprN.pos );
  trans = 1.0 - ( sprN.pos % 1.0 );
  if ( time < 0.2 ) {
    ny = 2;
    trans = 0.0;
  }
  
  gq = rotateQuaternion( 0.3, new Vec( 1.0, 0.0, -3.0 ).normalize() );
  gq = gq.multiply( rotateQuaternion( sprQ.pos * -2.2, new Vec( 1.0, 1.0, 2.0 ).normalize() ) );
  gq = gq.multiply( rotateQuaternion( sprQ2.pos * 0.8, new Vec( -2.0, 3.0, -1.0 ).normalize() ) );
  gq = gq.multiply( rotateQuaternion( time - 0.3, new Vec( 0.0, 1.0, 0.0 ).normalize() ) );
  
  prepareVertices();
  
  drawGrid();
  drawAxis();
  drawDotLine();
  drawRing();
  drawVertices();
  drawSurface();
  
  if ( frames <= frameCount && frameCount < frames * 2 ) {
    //saveFrame( "out/#####.png" );
  }
}