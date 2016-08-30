class Vec {
  float x, y, z;

  // コンストラクタ
  Vec(float x, float y, float z) {
    this.x = x; this.y = y; this.z = z;
  }
  
  // println時にわかりやすく表示する
  public String toString() {
    return "Vec(" + x + ", " + y + ", " + z + ")";
  }
  
  // ベクトル同士の加算
  Vec add(Vec v) {
    return new Vec(x + v.x, y + v.y, z + v.z);
  }
  
  // ベクトル同士の減算
  Vec sub(Vec v) {
    return new Vec(x - v.x, y - v.y, z - v.z);
  }
  
  // ベクトルの定数倍
  Vec scale(float s) {
    return new Vec(x * s, y * s, z * s);
  }
  
  // 逆向きのベクトルを返す
  Vec neg() {
    return new Vec(-x, -y, -z);
  }
  
  // ベクトルの長さを返す
  float len() {
    return sqrt(x * x + y * y + z * z);
  }
  
  // 正規化（単位ベクトル化）したベクトルを返す
  Vec normalize() {
    return scale(1.0 / len());
  }
  
  // 内積
  float dot(Vec v) {
    return x * v.x + y * v.y + z * v.z;
  }
  
  // 外積
  Vec cross(Vec v) {
    return new Vec(y * v.z - v.y * z,
                   z * v.x - v.z * x,
                   x * v.y - v.x * y);
  }
  
  Vec rotate(Quaternion _q) {
    Quaternion p = new Quaternion(0.0, this);
    Quaternion r = _q.inverse();
    return _q.multiply(p).multiply(r).v;
  }
  
  Vec toScreen( float _z ) {
    float z = ( this.z - _z );
    float x = this.x / z * width / 2.0 + width / 2.0;
    float y = this.y / z * width / 2.0 + height / 2.0;
    return new Vec( x, y, z );
  }
}