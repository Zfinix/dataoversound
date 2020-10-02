
import 'dart:ui';

import 'package:dart_numerics/dart_numerics.dart' as maths;
import 'package:extended_math/extended_math.dart' as math;

/// ****************************************************************************
///
///  Data type for complex numbers.
///
///  The data type is "immutable" so once you create and initialize
///  a Complex object, you cannot change it. The "final" keyword
///  when declaring re and im enforces this rule, making it a
///  compile-time error to change the .re or .im instance variables after
///  they've been initialized.
///
///  % java Complex
///  a            = 5.0 + 6.0i
///  b            = -3.0 + 4.0i
///  Re(a)        = 5.0
///  Im(a)        = 6.0
///  b + a        = 2.0 + 10.0i
///  a - b        = 8.0 + 2.0i
///  a * b        = -39.0 + 2.0i
///  b * a        = -39.0 + 2.0i
///  a / b        = 0.36 - 1.52i
///  (a / b) * b  = 5.0 + 6.0i
///  conj(a)      = 5.0 - 6.0i
///  |a|          = 7.810249675906654
///  tan(a)       = -6.685231390246571E-6 + 1.0000103108981198i
///
///*****************************************************************************/



 class Complex {
      double re;   // the real part
      double im;   // the imaginary part

    // create a new object with the given real and imaginary parts
     Complex(double real, double imag) {
        this.re = real;
        this.im = imag;
    }

    // return a string representation of the invoking Complex object
     String toString() {
        if (im == 0) return "$re" + "";
        if (re == 0) return "$im" + "i";
        if (im <  0) return "$re" + " - " + "${(-im)}" + "i";
        return '$re' + " + " + '$im' + "i";
    }

    // return abs/modulus/magnitude
     double abs() {
        return math.hypot(re, im);
    }

    // return angle/phase/argument, normalized to be between -pi and pi
     double phase() {
        return math.atan2(im, re);
    }

    // return a new Complex object whose value is (this + b)
     Complex plus(Complex b) {
        Complex a = this;             // invoking object
        double real = a.re + b.re;
        double imag = a.im + b.im;
        return new Complex(real, imag);
    }

    // return a new Complex object whose value is (this - b)
     Complex minus(Complex b) {
        Complex a = this;
        double real = a.re - b.re;
        double imag = a.im - b.im;
        return new Complex(real, imag);
    }

    // return a new Complex object whose value is (this * b)
     Complex times(Complex b) {
        Complex a = this;
        double real = a.re * b.re - a.im * b.im;
        double imag = a.re * b.im + a.im * b.re;
        return new Complex(real, imag);
    }

    // return a new object whose value is (this * alpha)
     Complex scale(double alpha) {
        return new Complex(alpha * re, alpha * im);
    }

    // return a new Complex object whose value is the conjugate of this
     Complex conjugate() {
        return new Complex(re, -im);
    }

    // return a new Complex object whose value is the reciprocal of this
     Complex reciprocal() {
        double scale = re*re + im*im;
        return new Complex(re / scale, -im / scale);
    }

    

    /// return a / b
     Complex divides(Complex b) {
        Complex a = this;
        return a.times(b.reciprocal());
    }

    /// return a new Complex object whose value is the complex exponential of this
     Complex exp() {
        return new Complex(math.exp(re) * math.cos(im), math.exp(re) * math.sin(im));
    }

    // return a new Complex object whose value is the complex sine of this
     Complex sin() {
        return new Complex(math.sin(re) * maths.cosh(im), math.cos(re) * maths.sinh(im));
    }

    // return a new Complex object whose value is the complex cosine of this
     Complex cos() {
        return new Complex(math.cos(re) * maths.cosh(im), -math.sin(re) * maths.sinh(im));
    }

    // return a new Complex object whose value is the complex tangent of this
     Complex tan() {
        return sin().divides(cos());
    }

    // a static version of plus
     static Complex pluss(Complex a, Complex b) {
        double real = a.re + b.re;
        double imag = a.im + b.im;
        Complex sum = new Complex(real, imag);
        return sum;
    }

    // See Section 3.3.
      equals(Complex x) {
        if (x == null) return false;
        if (this != x) return false;
        Complex that =  x;
        return (this.re == that.re) && (this.im == that.im);
    }

    // See Section 3.3.
     int gethashCode() {
        return hashValues(re, im);
    }

}
