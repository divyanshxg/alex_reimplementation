import vertex_shader from '../../shaders/notch_shader/vertexShader.glsl'
import fragment_shader from '../../shaders/notch_shader/fragmentShader.glsl'
import { Mesh, Plane, Program, Vec2 } from 'ogl';
export default function createNotch(gl, scene) {
  console.log(gl, scene)

  ////////////////////////////////////////////
  //  Checking Shader Errors
  ////////////////////////////////////////////

  // Compile vertex shader
  const vertexShader = gl.createShader(gl.VERTEX_SHADER);
  gl.shaderSource(vertexShader, vertex_shader);
  gl.compileShader(vertexShader);
  if (!gl.getShaderParameter(vertexShader, gl.COMPILE_STATUS)) {

    console.error(`Vertex shader ${elementIndex} - ${vertexShader} compilation failed:`, gl.getShaderInfoLog(vertexShader));
    return null;
  }

  // Compile fragment shader
  const fragmentShader = gl.createShader(gl.FRAGMENT_SHADER);
  gl.shaderSource(fragmentShader, fragment_shader);
  gl.compileShader(fragmentShader);
  if (!gl.getShaderParameter(fragmentShader, gl.COMPILE_STATUS)) {
    console.error(`Fragment shader ${elementIndex} - ${fragment_shader} compilation failed:`, gl.getShaderInfoLog(fragmentShader));
    return null;
  }


  ////////////////////////////////////////////

  const geo = new Plane(gl)

  // Dimensions of notch
  const plane_dim = new Vec2(0.14, 0.04);

  const program = new Program(gl, {
    vertex: vertex_shader,
    fragment: fragment_shader,
    uniforms: {
      uPlane: {
        value: plane_dim
      }

    }
  })

  const notch = new Mesh(gl, {
    program: program,
    geometry: geo
  })
  notch.scale.set(plane_dim.x, plane_dim.y, 1)
  notch.setParent(scene)
  notch.position.y += 0.46 // positioning the notch to top

  return notch

}
