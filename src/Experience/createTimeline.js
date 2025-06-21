import gsap from 'gsap'
import { CustomEase } from 'gsap/CustomEase'
import { GSDevTools } from 'gsap/GSDevTools';

gsap.registerPlugin(CustomEase)
gsap.registerPlugin(GSDevTools)
export default function animationTimeline(front_plane, back_plane, notch) {

  let tl = gsap.timeline({ id: "global_timeline" })

  CustomEase.create('io', '.8,0.2,.10,1');
  let eas = "0.54, 0.05, 0, 0.84" // short hand of writing cubic bezier

  // Front Plane Scale down
  tl.to(front_plane.scale, {
    x: 0.4,
    y: 0.4,
    duration: 1.,
    ease: "power1.inOut",
    id: "front_plane_scale_down"
  }, "start");

  // going all the way up
  tl.to(front_plane.position, {
    y: 1,
    duration: 1.0,
    ease: CustomEase.create("custom", "M0,0 C0.076,0 0.317,0.031 0.5,0.2 0.774,0.452 1,0.889 1,1 "),
    id: "front_plane_up_all_the_way"
  }, "start+=0.65");

  // Texture Stretching of the front plane
  tl.to(front_plane.program.uniforms.uProgress, {
    value: 2.,
    duration: 1.,
    ease: CustomEase.create("custom", "M0,0 C0.109,0.196 0.537,0.781 1,1 "),
    id: "front_plane_texture_stretch"
  }, "start+=0.88");

  // scaling down a little more
  tl.to(front_plane.scale, {
    y: 0.37,
    x: 0.35,
    duration: 0.6,
    ease: CustomEase.create("custom", "M0,0 C0.109,0.196 0.537,0.781 1,1 "),
    id: "front_plane_scale_down_more"
  }, "start+=0.9");

  // Notch Timeline

  tl.to(notch.scale, {
    x: 1.3,
    y: 1.2,
    ease: "power2.inOut",
    duration: 0.6,
    id: "notch_scaling_up_timeline",
  }, "start+=0.9");

  tl.to(notch.scale, {
    x: 1.,
    y: 1.,
    ease: "power2.inOut",
    duration: 0.8,
    id: "notch_scaling_down_timeline",
  }, "start+=1.7");


  // Back Plane Animation


  tl.to(back_plane.program.uniforms.texture_stretch_p, {
    value: 1,
    duration: 1.3,
    ease: 'Power2.easeInOut',
    id: "back_plane_scaling_up_texture"
  }, `start+=0.6`);

  tl.to(back_plane.program.uniforms.texture_stretch_p, {
    value: 0,
    duration: 0.9,
    ease: 'Power2.easeInOut',
    id: "back_plane_scaling_down_texture"
  }, `start+=1.75`);

  tl.to(back_plane.program.uniforms.wave_p, {
    value: 1.,
    duration: 2.3,
    ease: eas,
    id: "back_plane_wave_timeline"
  }, `start+=1.7`)

  tl.to(back_plane.program.uniforms.wave_fade_p, {
    value: 1.,
    duration: 1.7,
    ease: "none",
    id: "back_plane_wave_fade_timeline"
  }, `start+=1.8`)

  tl.to(back_plane.program.uniforms.distortion_wave_p, {
    value: 1.3,
    duration: 2.4,
    ease: CustomEase.create("custom", "M0,0 C0.401,0 0.428,1.033 1,1 "),
    id: "back_plane_distortion_wave_timeline"
  }, `start+=1.7`)

  GSDevTools.create({ animation: tl })

  return tl
}

