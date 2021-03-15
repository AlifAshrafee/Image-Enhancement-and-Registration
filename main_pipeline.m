## Copyright (C) 2021 Alif Ashrafee
## 
## This program is free software: you can redistribute it and/or modify it
## under the terms of the GNU General Public License as published by
## the Free Software Foundation, either version 3 of the License, or
## (at your option) any later version.
## 
## This program is distributed in the hope that it will be useful, but
## WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
## 
## You should have received a copy of the GNU General Public License
## along with this program.  If not, see
## <https://www.gnu.org/licenses/>.

## -*- texinfo -*- 
## @deftypefn {} {@var{retval} =} main_pipeline (@var{input1}, @var{input2})
##
## @seealso{}
## @end deftypefn

## Author: Alif Ashrafee <Alif Ashrafee@DESKTOP-VP696I1>
## Created: 2021-02-13

function retval = main_pipeline (input1)

%adding noise and using average filter to smooth it
pkg load image

#img = imread('Y6.jpg');
#img = imread('star2_1.jpg');

img = input1;

noisy_img = imnoise(img, "gaussian", 0.005);
PSF = fspecial("motion", 20, 11);
blurred_noisy = imfilter(im2double(noisy_img), PSF, "conv", "circular");

subplot(2,3,1)
imshow(blurred_noisy); title('Original Image')

noisefree_img = imsmooth(blurred_noisy, 'average');

subplot(2,3,2)
imshow(noisefree_img); title('Noise free Image')

deblur = deconvwnr(noisefree_img, PSF, 0);

subplot(2,3,3)
imshow(deblur); title('Noise & Blur free Image')

color = 0;

b = size(img);
if size(b,2)==3
color = 1;
end

if color == 1
original = rgb2gray(blurred_noisy);
noiseless = rgb2gray(noisefree_img);
blurless = rgb2gray(deblur);
else
original = blurred_noisy;
noiseless = noisefree_img;
blurless = deblur;
endif

freq_dom_original = abs(fftshift(fft2(double(original))));
freq_dom_noiseless = abs(fftshift(fft2(double(noiseless))));
freq_dom_blurless = abs(fftshift(fft2(double(blurless))));

subplot(2,3,4)
imshow(log(1+abs(freq_dom_original)),[]); title('Frquency Domain of original noisy & blurry image')
subplot(2,3,5)
imshow(log(1+abs(freq_dom_noiseless)),[]); title('Frquency Domain of noise free image')
subplot(2,3,6)
imshow(log(1+abs(freq_dom_blurless)),[]); title('Frquency Domain of noise & blur free image')

retval = deblur;

endfunction
