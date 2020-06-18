import 'dart:math' as math;

import 'Complex.dart';

//   Compilation:  javac FFT.java
//   Execution:    java FFT n
//   Dependencies: Complex.java
//
//   Compute the FFT and inverse FFT of a length n complex sequence
//   using the radix 2 Cooley-Tukey algorithm.
//
//   Bare bones implementation that runs in O(n log n) time. Our goal
//   is to optimize the clarity of the code, rather than performance.
//
//   Limitations
//   -----------
//    -  assumes n is a power of 2
//
//    -  not the most memory efficient algorithm (because it uses
//       an object type for representing complex numbers and because
//       it re-allocates memory for the subarray, instead of doing
//       in-place or reusing a single temporary array)
//
//   For an in-place radix 2 Cooley-Tukey FFT, see
//  https://introcs.cs.princeton.edu/java/97data/InplaceFFT.java.html
//

 class FFT {

    // compute the FFT of x[], assuming its length is a power of 2
     static List<Complex> fft(List<Complex> x) {
        int n = x.length;

        // base case
        if (n == 1) return  <Complex> [x[0] ];

        // radix 2 Cooley-Tukey FFT
        if (n % 2 != 0) {
            throw  "n is not a power of 2";
        }

        // fft of even terms
        List<Complex> even = new List<Complex>(n~/2);
        for (int k = 0; k < n/2; k++) {
            even[k] = x[2*k];
        }
        List<Complex> q = fft(even);

        // fft of odd terms
        List<Complex> odd  = even;  // reuse the array
        for (int k = 0; k < n/2; k++) {
            odd[k] = x[2*k + 1];
        }
        List<Complex> r = fft(odd);

        // combine
        List<Complex> y = new List<Complex>(n);
        for (int k = 0; k < n/2; k++) {
            double kth = -2 * k * math.pi / n;
            Complex wk = new Complex(math.cos(kth), math.sin(kth));
            y[k]       = q[k].plus(wk.times(r[k]));
            y[k + n~/2] = q[k].minus(wk.times(r[k]));
        }
        return y;
    }

    // compute the inverse FFT of x[], assuming its length is a power of 2
     static List<Complex> ifft(List<Complex> x) {
        int n = x.length;
        List<Complex> y = new List<Complex>(n);

        // take conjugate
        for (int i = 0; i < n; i++) {
            y[i] = x[i].conjugate();
        }

        // compute forward FFT
        y = fft(y);

        // take conjugate again
        for (int i = 0; i < n; i++) {
            y[i] = y[i].conjugate();
        }

        // divide by n
        for (int i = 0; i < n; i++) {
            y[i] = y[i].scale(1.0 / n);
        }

        return y;

    }

    // compute the circular convolution of x and y
     static List<Complex> cconvolve(List<Complex> x, List<Complex> y) {

        // should probably pad x and y with 0s so that they have same length
        // and are powers of 2
        if (x.length != y.length) {
            throw  "Dimensions don't agree";
        }

        int n = x.length;

        // compute FFT of each sequence
        List<Complex> a = fft(x);
        List<Complex> b = fft(y);

        // point-wise multiply
        List<Complex> c = new List<Complex>(n);
        for (int i = 0; i < n; i++) {
            c[i] = a[i].times(b[i]);
        }

        // compute inverse FFT
        return ifft(c);
    }

    // compute the linear convolution of x and y
     static List<Complex> convolve(List<Complex> x, List<Complex> y) {
        Complex ZERO = new Complex(0, 0);

        List<Complex> a = new List<Complex>(2*x.length);
        for (int i = 0;        i <   x.length; i++) a[i] = x[i];
        for (int i = x.length; i < 2*x.length; i++) a[i] = ZERO;

        List<Complex> b = new List<Complex>(2*y.length);
        for (int i = 0;        i <   y.length; i++) b[i] = y[i];
        for (int i = y.length; i < 2*y.length; i++) b[i] = ZERO;

        return cconvolve(a, b);
    }
}