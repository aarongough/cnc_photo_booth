# CNC Photo Booth

A program for using a CNC machine as the plotter for a Photo Booth!

The CNC photo booth was conceived as a safe and friendly way to introduce people to the power and accuracy of a machine tool up close! Most people never get the chance to run a machining center or similar tool, allowing them to do so in a casual environment when actual cutting is involved is too risky, so we use a marker and paper instead!

This system would work well for Makerspaces/Makerfaires as a safe and interactive way to demo CNC routers and so on.

## How it works

Right now the CNC photo booth is only really setup for use on Mac OSX. Replacement of the the image capture system would be required for it to run on other OSes, but that is completely feasible!

The image capture side of the application is currently implemented as an Automator workflow. The basic steps are:

  * Prompt the user to enter their name
  * Launch the webcam
  * Prompt the user to take a photo
  * Save the photo to disk (filename is their name)
  * Increase the contrast and saturation of the image
  * Resize the image to 85x110 pixels
  * Convert the image to greyscale
  * Posterize the image
  * Convert the image to PNG
  * Run a Ruby script on the image to create the G-Code and SVG preview
  * Open the SVG preview in Chrome to allow the user to see the likely result

The ruby script basically performs the following steps:

  * Load the image as an array of pixels
  * Iterate over the array
  * Output G-Code and SVG lines that represent the grey level of each pixel
  * Save the output to disk

The 'CNC Photo Booth' application in this repo is actually an Automator workflow bundled in an App shell. It can be edited with the automator application on OSX.

## G-Code format

The G-Code that the system currently produces is intended for use on Fadal machining centers, however it is all ANSI compliant G-Code with the exception of the M codes on the 2nd and 3rd lines. Edit those lines in the script to reflect the setup that your machine needs!

## Using the CNC Photo Booth

To setup/use the photo booth really all you need to do is download all the files and then double-click the 'CNC Photo Booth'. It will create folders on your desktop containing the source photos and the generated G-Code and SVG files.

## License

Released under the MIT license, see LICENSE.txt for details.