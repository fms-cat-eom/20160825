class Spring {
  float pos;
  float vel;
  float target;
  float k = 100.0;
  
  Spring( float _k ) {
    k = _k;
  }
  
  void update( float _deltaTime ) {
    vel += ( -k * ( pos - target ) - 2.0 * vel * sqrt( k ) ) * _deltaTime;
    pos += vel * _deltaTime;
  }
}