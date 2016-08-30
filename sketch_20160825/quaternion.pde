class Quaternion {
  float w;
  Vec v;
  
  Quaternion(float _w, Vec _v) {
    w = _w;
    v = _v;
  }
  
  Quaternion() {
    w = 1.0;
    v = new Vec(0.0, 0.0, 0.0);
  }
  
  public String toString() {
    return "Quaternion(" + w + "; " + v.x + ", " + v.y + ", " + v.z + ")";
  }
  
  Quaternion multiply(Quaternion _q) {
    Vec tv = new Vec(0.0, 0.0, 0.0);
    tv = tv.add(_q.v.scale(w));
    tv = tv.add(v.scale(_q.w));
    tv = tv.add(v.cross(_q.v));
    return new Quaternion(
      w * _q.w - v.dot(_q.v),
      tv
    );
  }
  
  Quaternion inverse() {
    return new Quaternion(
      w,
      v.neg()
    );
  }
  
  PMatrix3D toPMatrix3D() {
    Vec x = new Vec(1.0, 0.0, 0.0).rotate(this);
    Vec y = new Vec(0.0, 1.0, 0.0).rotate(this);
    Vec z = new Vec(0.0, 0.0, 1.0).rotate(this);
    
    return new PMatrix3D(
      x.x, x.y, x.z, 0.0,
      y.x, y.y, y.z, 0.0,
      z.x, z.y, z.z, 0.0,
      0.0, 0.0, 0.0, 1.0
    );
  }
}

Quaternion rotateQuaternion(float _t, Vec _a) {
  return new Quaternion(
    cos(_t / 2.0),
    _a.scale(sin(_t / 2.0))
  );
}