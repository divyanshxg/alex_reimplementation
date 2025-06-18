# Project Implementation Summary


## Implementation Steps

 1. Created an HTML card with styled elements and placed it within a container.
 2. Used `html2canvas-pro` library to capture the card's HTML+CSS as an image snapshot on JavaScript load.
 3. Initialized a WebGL environment using the OGL library, passing the snapshot as a texture and targeting the container element.
 4. Configured the WebGL environment to match the container's dimensions, applying transformations to ensure the plane geometry covers the entire container.
 5. Implemented a perspective camera to position and render the scene accurately.
 6. Defined three meshes for the interaction:
    - **Front Plane**: Animates upwards with scaling and bounce effects.
    - **Back Plane**: Applies distortion effects like glow, blur, and ripple wave.
    - **Notch Plane**: Scales to enhance the visual effect.
 7. Integrated GSAP for animation timelines to control plane movements, scaling, and texture distortions.
 8. Added a debug UI using `lil-gui` to adjust parameters like distortion intensity, shockwave speed, and animation speed.
 9. Implemented event listeners for window resizing to update the aspect ratio and maintain responsiveness.
10. Configured shader compilation checks to ensure vertex and fragment shaders compile without errors.
11. Applied texture properties for optimal rendering.
12. Used a custom GSAP timeline configuration to synchronize animations across all meshes.
13. Added a reset button to restart the animation on user interaction.
14. Optimized the WebGL renderer with antialiasing and alpha transparency for smooth visuals.
15. Ensured the back plane is positioned behind the front plane and notch for proper layering.


## Assumptions

1. Radius of border is different for different screens, So in the shader `src/shaders/back_plane/fragmentShader.glsl`, `src/shaders/front_plane/fragmentShader.glsl` I have defined a variable at the top to let you vary the border radius of the geometry.

2. Similar case with the dimensions of the notch , value assumed by me can be found in `src/Experience/Meshes/notch.js`.

3. The y position of notch is also present in the above specified file , If you wish to change it , then make the same change in the define variable called `CUTOFF_OFFSET` preset in `src/shaders/front_plane/fragmentShader.glsl`.


## NOTE
After you have come up with a satisfactory values for the speed and uniforms from the debug ui , place those values in the guiObj in the  `src/Experience/Media.js`.so that they get loaded by default.
Furthermore for the uniform values coming from debug UI , you can remove those uniforms and hardcode those values with the same variable name in the shader `src/shaders/back_plane/fragmentShader.glsl`
Also don't vary the value to extremes from debug UI as they can cause weird artifacts.
