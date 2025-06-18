import Media from "./Media"
import { Renderer, Camera, Transform, Plane } from 'ogl'

export default class Scene {
  constructor(container, snapshot_img, gui) {
    this.gui = gui
    this.img = snapshot_img
    this.container = container
    this.containerAR = this.container.getBoundingClientRect().width / this.container.getBoundingClientRect().height;
    this.createRenderer()
    this.createCamera()
    this.createScene()
    this.gl.canvas.style.zIndex = 3

    this.createGeometry()

    this.onResize()

    this.createMedias()

    this.update()

    this.addEventListeners()
  }

  createRenderer() {
    this.renderer = new Renderer({
      dpr: 2,
      antialias: true,
      autoClear: true,
      alpha: true
    })

    this.gl = this.renderer.gl
    this.gl.clearColor(1., 1., 1., 1.0)
    this.container.appendChild(this.gl.canvas)
  }

  // perspective camera
  createCamera() {

    this.fov = 45;
    this.camera = new Camera(this.gl, {
      fov: 45,
      near: 0.01,
      far: 100,
      aspect: this.containerAR
    })
    const distance = 1 / (2 * Math.tan((this.fov * Math.PI / 180) / 2))

    // positioning camera so that plane covers the scene
    this.camera.position.z = distance

  }

  createScene() {
    this.scene = new Transform()
  }


  // plane geometry for the effect
  createGeometry() {
    this.planeGeometry = new Plane(this.gl, {
      width: this.containerAR,
      height: 1,
      widthSegments: 100,
      heightSegments: 100
    })
  }


  createMedias() {
    this.medias = new Media({
      renderer: this.renderer,
      scene: this.scene,
      geometry: this.planeGeometry,
      img: this.img,
      gl: this.gl,
      gui: this.gui,
      containerAR: this.containerAR,
    })
  }

  /**
   * Events.
   */
  onTouchDown(event) {
    if (this.medias) {
      this.medias.onClick()
    }

  }
  updateTimeline(ease) {

    if (this.medias) {
      if (this.medias.tl) {
        this.medias.tl.kill(); // Kill the existing GSAP timeline
      }
      // Recreate the timeline with the new easing
      // this.medias.createTimeline(ease);
      this.medias.createTimeline(ease)
    }
  }

  onTouchMove(event) {

  }

  onTouchUp(event) {

  }

  onWheel(event) {

  }

  /**
   * Resize.
   */
  onResize() {
    this.screen = {
      height: window.innerHeight,
      width: window.innerWidth
    }

    this.renderer.setSize(this.container.getBoundingClientRect().width, this.container.getBoundingClientRect().height)

    // Update plane geometry if aspect ratio changes
    this.containerAR = this.container.getBoundingClientRect().width / this.container.getBoundingClientRect().height;
    this.planeGeometry.width = this.containerAR;
    this.planeGeometry.height = 1;

    const distance = 1 / (2 * Math.tan((this.fov * Math.PI / 180) / 2));
    this.camera.position.z = distance;

    // Update medias with new aspect ratio
    if (this.medias) {
      this.medias.updateAspectRatio(this.containerAR);
    }


    this.camera.perspective({
      aspect: this.containerAR,
      fov: this.fov
    })

  }

  /**
   * Update.
   */
  update() {
    this.renderer.render({
      scene: this.scene,
      camera: this.camera
    })


    if (this.medias) {
      this.medias.update()
    }

    window.requestAnimationFrame(this.update.bind(this))
  }

  /**
   * Listeners.
   */
  addEventListeners() {
    window.addEventListener('resize', this.onResize.bind(this))

    window.addEventListener('mousewheel', this.onWheel.bind(this))
    window.addEventListener('wheel', this.onWheel.bind(this))

    window.addEventListener('mousemove', this.onTouchMove.bind(this))
    window.addEventListener('mouseup', this.onTouchUp.bind(this))

    window.addEventListener('touchmove', this.onTouchMove.bind(this))
    window.addEventListener('touchend', this.onTouchUp.bind(this))
  }
}

