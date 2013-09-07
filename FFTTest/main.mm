//  main.cpp
//  FFTTest
//
//  Created by Harry-Chris Stamatopoulos on 11/23/12.
//


// http://stackoverflow.com/questions/6358764/iphone-fft-with-accelerate-framework-vdsp
// http://en.wikipedia.org/wiki/Hilbert_transform

/*
 This is an example of a hilbert transformer using
 Apple's VDSP fft/ifft & other VDSP calls.
 Output signal has a PI/2 phase shift.
 COMPLEX_SPLIT vector "B" was used to cross-check
 real and imaginary parts coherence with the original vector "A"
 that is obtained straight from the fft.
 Tested and working.
 Cheers!
 */


#include <iostream>
#include <Accelerate/Accelerate.h>
#define PI 3.14159265
#define DEBUG_PRINT 1

int main(int argc, const char * argv[])
{

    
    float fs = 44100;           //sample rate
    float f0 = 440;             //sine frequency
    uint32_t i = 0;
    
    
    uint32_t L = 512;
    
    /* vector allocations*/
    float *input = new float [L];
    float *output = new float[L];
    float *mag = new float[L/2];
    float *phase = new float[L/2];
    
    
    for (i = 0 ; i < L; i++)
    {
        input[i] = 0;
//         input[i] = i;
    }
    
// fill all real parts with 1
//    for (i = 0 ; i < L/2; i++)
//    {
//        input[i*2] = 1;
//    }
    
    input[ (L/2) -2]= (1.0/(2*L)); //fill an impulse signal (real part)
    
    input[ (L/2) -12]= (1.0/(2*L));
    
    
    input[ (L/2) -24]= (1.0/(2*L));
    
    uint32_t log2n = log2f((float)L);
    uint32_t n = 1 << log2n;
    //printf("FFT LENGTH = %lu\n", n);
    
    
    FFTSetup fftSetup;
    COMPLEX_SPLIT A;
    COMPLEX_SPLIT B;
    A.realp = (float*) malloc(sizeof(float) * L/2);
    A.imagp = (float*) malloc(sizeof(float) * L/2);
    
    B.realp = (float*) malloc(sizeof(float) * L/2);
    B.imagp = (float*) malloc(sizeof(float) * L/2);
    
    
    fftSetup = vDSP_create_fftsetup(log2n, FFT_RADIX2);
    
    /// FREQ DOMAIN
    /// 1. take the interleaved planar buffer (r1,i1,r2,i2,...) into the split complex buffer
    vDSP_ctoz((COMPLEX *) input, 2, &A, 1, L/2);
    
    /// TIME DOMAIN
    /// 2. convert to a wave take the inverse transform of the complex split buffer
    vDSP_fft_zrip(fftSetup, &A, 1, log2n, FFT_INVERSE);
    
    
    /// CONVERT THE COMPLEX WAVE TO PCM
    /// 3. somehow convert the complex number into a wave
    /// GET THE MAGNITUDES
    /// 8. take the forward transform of the wave amplitude
    mag[0] = sqrtf(A.realp[0]*A.realp[0]);
    
 

    //get magnitude;
    for(i = 1; i < L/2; i++){
        mag[i] = sqrtf(A.realp[i]*A.realp[i] + A.imagp[i] * A.imagp[i]);
    }
    
    printf("----magnitude\n");
    for (i = 0 ; i < L/4; i++)
    {
        printf("%f\n", mag[i]);
    }
    printf("----magnitude\n");
    
    /// TRANSMIT THE WAVE IN PCM
    /// 4. use OS fameworks to encode and transmit
    
    /// RECEIVE THE WAVE  FROM PCM
    //  5. use OS frameworks to receive and decode pcm samples
    
    /// TURN THE AMPLITUDE SCALAR INTO A COMPLEX
    /// 6. using cToz convert the amplitude into a complex
    
     vDSP_ctoz((COMPLEX *) mag, 2, &A, 1, L/4);
    

    /// MAKE THE FORWARD TRANSFORM
    /// 7. take the forward transform of the wave amplitude
    vDSP_fft_zrip(fftSetup, &A, 1, log2n, FFT_FORWARD);

//     printf("FORWARD");
//    for (i = 0 ; i < L/2; i++)
//    {
//        printf("input[%d] A FORWARD REAL = %f \t A IMAG = %f \n",i, A.realp[i], A.imagp[i]);
//    }
//    
    
    /// GET THE MAGNITUDES
    /// 8. take the forward transform of the wave amplitude
    mag[0] = sqrtf(A.realp[0]*A.realp[0]);

    
    //get magnitude;
    for(i = 1; i < L/4; i++){
        mag[i] = sqrtf(A.realp[i]*A.realp[i] + A.imagp[i] * A.imagp[i]);
    }
    
    
    // MAGNITUDES SHOULD CONTAIN THE SELECTED SINUSOIDS IN input
    printf("----magnitude\n");
    for (i = 0 ; i < L/4; i++)
    {
        printf("%f\n", mag[i]);
    }
    printf("----magnitude\n");
    
    
    
    
    //release resources
    free(input);
    free(output);
    free(A.realp);
    free(A.imagp);
    free(B.imagp);
    free(B.realp);
    free(mag);
    free(phase);
    return 0;
}

