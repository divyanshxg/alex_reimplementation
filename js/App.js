import * as THREE from 'three';
import gsap from 'gsap';
import { CustomEase } from 'gsap/CustomEase';

import fragment from './shader/sharedLayer/fragment.glsl';
import vertex from './shader/sharedLayer/vertex.glsl';
import frag from './shader/firstLayer/frag.glsl';
import vert from './shader/firstLayer/vert.glsl';

import img from '../images/1.png';

export default class App {
  constructor(options) {
    this.scene = new THREE.Scene();

    this.container = options.dom;
    this.width = this.container.offsetWidth;
    this.height = this.container.offsetHeight;
    this.renderer = new THREE.WebGLRenderer({ alpha: true });
    this.renderer.setPixelRatio(Math.min(window.devicePixelRatio, 2));
    this.renderer.setSize(this.width, this.height);
    this.renderer.setClearColor(0xeeeeee, 1);

    this.container.appendChild(this.renderer.domElement);

    var frustumSize = this.height;
    var aspect = this.width / this.height;
    this.camera = new THREE.OrthographicCamera(
      frustumSize * aspect / -2,
      frustumSize * aspect / 2,
      frustumSize / 2,
      frustumSize / -2,
      -1000,
      1000
    );
    this.camera.position.set(0, 0, 2);

    this.loader = new THREE.TextureLoader();

    this.createGeometry();
    this.createEasing();
    this.addFixedLayer();
    this.addSharedLayer();
    this.moveIsland();
    this.resize();
    this.render();
    this.setupResize();
  }

  createGeometry() {
    this.geometry = new THREE.PlaneGeometry(1, 1, 100, 100);
    this.texture = this.loader.load(img);
  }

  createEasing() {
    gsap.registerPlugin(CustomEase);
    CustomEase.create('io', '.8,0.2,.10,1');
    // CustomEase.create("io", "M0,0 C0.503,0 0.017,1 1,1 ")
    // CustomEase.create("io")
  }

  moveIsland() {
    gsap.to('.island', {
      y: '-40px',
      duration: 0.9 * 0.8,
      ease: 'io',
      delay: 1.35,
    });

    gsap.to('.island', {
      y: 0,
      duration: 0.8 * 1.32,
      ease: 'io',
      delay: 0.8 * 2.87,
    });
  }

  addFixedLayer() {
    const material = new THREE.ShaderMaterial({
      uniforms: {
        tex: { value: this.texture },
        uTexelSize: {
          value: new THREE.Vector2(),
        },
        p: { value: 0 },
        p2: { value: 0 },
        p3: { value: 0 },
        p4: { value: 0 },
        resolution: { value: new THREE.Vector2(198, 423) },
      },
      transparent: true,
      vertexShader: vert,
      fragmentShader: frag,
    });

    const image = new Image();
    image.src = img;
    image.onload = _ => {
      material.uniforms.uTexelSize.value.x = 1 / image.naturalWidth;
      material.uniforms.uTexelSize.value.y = 1 / image.naturalHeight;
    };

    const mesh = new THREE.Mesh(this.geometry, material);
    this.scene.add(mesh);
    mesh.scale.set(this.width, this.height, 1);

    gsap.to(material.uniforms.p, {
      value: 1,
      duration: 0.8 * 3,
      ease: 'io',
      delay: 2.1,
    });

    gsap.to(material.uniforms.p3, {
      value: 1,
      duration: 0.8 * 1.8,
      ease: 'Power2.easeInOut',
      delay: 1.1,
    });

    gsap.to(material.uniforms.p3, {
      value: 0,
      duration: 0.8 * 2.49,
      ease: 'io',
      delay: 2,
    });

    gsap.to(material.uniforms.p2, {
      value: 2.,
      duration: 10,
      // ease: 'io',
      // ease: 'M0,0 C0.305,0 0.072,1.103 1,1 ',
      // ease: 'none',
      ease: CustomEase.create("io1", "M0,0 C0.303,0 0.031,1.076 1,1 "),
      // delay: 2.4,
      delay: 0.55,
    });
    gsap.to(material.uniforms.p4, {
      value: 1.,
      duration: 1.5,
      ease: "none",
      delay: 1.75,
    });

  }

  addSharedLayer() {
    const material = new THREE.ShaderMaterial({
      uniforms: {
        tex: { value: this.texture },
        time: { value: 0 },
        p: { value: 1 },
        p2: { value: 0 },
        p3: { value: 1 },
        resolution: { value: new THREE.Vector2(198, 423) },
      },
      transparent: true,
      vertexShader: vertex,
      fragmentShader: fragment,
    });

    const mesh = new THREE.Mesh(this.geometry, material);
    this.scene.add(mesh);
    mesh.scale.set(this.width, this.height, 1);

    // mesh.visible = false;
    gsap.to(material.uniforms.p, {
      value: 0,
      duration: 0.8 * 2,
      ease: 'Expo.easeOut',
      delay: 1,
    });

    gsap.to(material.uniforms.p3, {
      value: 0,
      duration: 0.8 * 2,
      ease: 'Power2.easeOut',
      delay: 1,
    });

    gsap.to(material.uniforms.p2, {
      value: 1,
      duration: 0.8 * 1.65,
      ease: 'io',
      delay: 1.5,
    });

  }

  setupResize() {
    window.addEventListener('resize', this.resize.bind(this));
  }

  resize() {
    this.width = this.container.offsetWidth;
    this.height = this.container.offsetHeight;
    this.renderer.setSize(this.width, this.height);
    this.camera.aspect = this.width / this.height;
    this.camera.updateProjectionMatrix();
  }

  render() {
    requestAnimationFrame(this.render.bind(this));
    this.renderer.render(this.scene, this.camera);
  }
}

new App({
  dom: document.getElementById('gl'),
});

document.addEventListener('keydown', function (event) {

  if (event.key === 'Control' && !event.altKey && !event.shiftKey && !event.metaKey) {
    console.log('Control key pressed! Refreshing page...');
    window.location.reload(); // Reloads the current page
  }

});
