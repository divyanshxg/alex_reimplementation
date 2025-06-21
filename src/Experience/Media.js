import { Mesh, Plane, Program, Texture, Vec2 } from "ogl";
import gsap from "gsap";
import { CustomEase } from 'gsap/CustomEase'
import animationTimeline from "../animationTimeline/create_timeline";
import createNotch from "./Meshes/notch";
import createFrontPlane from "./Meshes/front_plane";
import createBackPlane from "./Meshes/back_plane";
import createDebugUI from "../utils/debug";
import demo_1 from '../../assets/demo_1.png'
import demo_2 from '../../assets/demo_2.png'
import demo_3 from '../../assets/client_photo_3.jpg'
import demo_4 from '../../assets/client_photo_4.png'

gsap.registerPlugin(CustomEase)

export default class Media {
  constructor({ renderer, scene, geometry, img, gl, gui, containerAR }) {

    // GUI DEBUG properties 

    this.guiObj = {
      overallSpeed: 1,
      shockWaveSpeed: 1,
      distortionIntensity: 0.09,
      topRingSmoothness: 0.02,
      bottomRingSmoothness: 0.1,
      Image: demo_3,
    }

    this.first = true;


    this.containerAR = containerAR;
    this.gui = gui
    this.gui.add(this.guiObj, "Image", {
      Live_UI: img,
      Demo_1: demo_1,
      Demo_2: demo_2,
      Demo_3: demo_3,
    }).onChange((e) => {
      this.front_plane.visible = false;
      this.back_plane.visible = false;
      this.tl = ""
      this.createMeshes(e)
      // this.tl = animationTimeline(this.front_plane, this.back_plane, this.notch, this.guiObj.overallSpeed)
      // this.tl.pause()



    })
    this.renderer = renderer;
    this.scene = scene;
    this.img = img;
    this.geometry = geometry;
    this.gl = gl;
    this.image_dimensions = new Vec2(0, 0);
    this.createMeshes(this.guiObj.Image)
  }

  createMeshes(this_img) {



    // creating a texture with some basic properties
    const texture = new Texture(this.gl, {
      minFilter: this.gl.LINEAR_MIPMAP_LINEAR,
      magFilter: this.gl.LINEAR,
      generateMipmaps: true,
      wrapS: this.gl.CLAMP_TO_EDGE,
      wrapT: this.gl.CLAMP_TO_EDGE,
      // wrapS: this.gl.REPEAT,
      // wrapT: this.gl.REPEAT,
    });

    const image = new Image();
    image.onload = () => {
      texture.image = image;

      // getting natural width for object cover to implement object cover behaviour
      this.image_dimensions = new Vec2(image.naturalWidth, image.naturalHeight);


      // Creating Front Plane , Back Plane and Notch
      this.front_plane = createFrontPlane(this.gl, this.scene, this.geometry, texture, this.image_dimensions, this.containerAR)

      this.back_plane = createBackPlane(this.gl, this.scene, this.geometry, texture, this.image_dimensions, this.containerAR, this.guiObj)

      this.notch = createNotch(this.gl, this.scene)


      // Updating the natural Width of image in the uniforms of front and back plane
      if (this.front_plane && this.front_plane.program) {
        this.front_plane.program.uniforms.uImage.value = this.image_dimensions;
      }

      if (this.back_plane && this.back_plane.program) {
        this.back_plane.program.uniforms.uImage.value = this.image_dimensions;
      }

      // placing the back plane at last , on top of which is front plane and then notch
      this.back_plane.position.z -= 0.001
      this.front_plane.position.z = 0.00
      this.notch.position.z = 0.001

      // animation timeline
      // setting the overallSpeed to 1 at start(from guiObj)

      // pausing it so doesn't run on load
      this.createGUI()


      // if (this.first) {
      this.tl = animationTimeline(this.front_plane, this.back_plane, this.notch, this.guiObj.overallSpeed)
      this.tl.pause()
      // this.first = false;
      // }

    };
    image.src = this_img;

  }


  createGUI() {

    // passing Media instance to change the animation timeline of this instance
    createDebugUI(this.gui, this.guiObj, this.back_plane, this)

  }

  onResize() { }

  updateAspectRatio(newAR) {

    // Updating Uniforms after window resizing

    this.containerAR = newAR;
    if (this.front_plane && this.front_plane.program) {
      this.front_plane.program.uniforms.uPlane.value = new Vec2(this.containerAR, 1);
    }
    if (this.back_plane && this.back_plane.program) {
      this.back_plane.program.uniforms.uPlane.value = new Vec2(this.containerAR, 1);
    }
  }

  // start/restart animation
  onClick() {
    this.tl.restart();
  }

  update() {
  }
}
