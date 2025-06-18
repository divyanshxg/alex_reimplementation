import vertex_shader from '../../shaders/front_plane/vertexShader.glsl'
import fragment_shader from '../../shaders/front_plane/fragmentShader.glsl'
import { Mesh, Program, Vec2 } from 'ogl';

export default function createFrontPlane(gl, scene, geometry, texture, image_dimensions, containerAR) {

  ////////////////////////////////////////////
  //  Checking Shader Errors
  ////////////////////////////////////////////

  // Compile vertex shader
  const vertexShader = gl.createShader(gl.VERTEX_SHADER);
  gl.shaderSource(vertexShader, vertex_shader);
  gl.compileShader(vertexShader);
  if (!gl.getShaderParameter(vertexShader, gl.COMPILE_STATUS)) {

    console.error(`Vertex shader  - ${vertexShader} compilation failed:`, gl.getShaderInfoLog(vertexShader));
    return null;
  }

  // Compile fragment shader
  const fragmentShader = gl.createShader(gl.FRAGMENT_SHADER);
  gl.shaderSource(fragmentShader, fragment_shader);
  gl.compileShader(fragmentShader);
  if (!gl.getShaderParameter(fragmentShader, gl.COMPILE_STATUS)) {
    console.error(`Fragment shader  - ${fragment_shader} compilation failed:`, gl.getShaderInfoLog(fragmentShader));
    return null;
  }


  ////////////////////////////////////////////


  // Creating Program

  // Creating Program And Mesh
  const program = new Program(gl, {
    vertex: vertex_shader,
    fragment: fragment_shader,
    uniforms: {
      uProgress: {
        value: 0.0,
      },
      uTexture: {
        value: texture
      },
      uImage: {
        value: image_dimensions,
      },
      uPlane: {
        value: new Vec2(containerAR, 1.)
      },
    }
  });

  const mesh = new Mesh(gl, {
    geometry: geometry,
    program: program
  });

  mesh.setParent(scene);


  return mesh


}
