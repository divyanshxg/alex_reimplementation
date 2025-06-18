import gsap from 'gsap'
import getConfig from './timeline_config';
import { CustomEase } from 'gsap/CustomEase'
import { GSDevTools } from 'gsap/GSDevTools';

gsap.registerPlugin(CustomEase)
gsap.registerPlugin(GSDevTools)
export default function animationTimeline(front_plane, back_plane, notch, timeScale) {

  // let tl = gsap.timeline({ id: "timeline" })
  let tl = gsap.timeline({ id: "global_timeline" })

  CustomEase.create('io', '.8,0.2,.10,1');


  // Front Plane Scale down
  tl.to(front_plane.scale, {
    x: 0.4,
    y: 0.4,
    duration: 1.,
    ease: "power1.inOut",
    id: "front_plane_scale_down"
  }, "start");


  // going a little down
  tl.to(front_plane.position, {
    y: 0.00,
    duration: 0.8,
    ease: "power2.in",
    id: "front_plane_down_slightly"
  }, "start+=0.5");

  // going all the way up
  tl.to(front_plane.position, {
    y: 1,
    duration: 1.0, // 2.5 - 1.5
    ease: CustomEase.create("custom", "M0,0 C0.076,0 0.317,0.031 0.5,0.2 0.774,0.452 1,0.889 1,1 "),
    id: "front_plane_up_all_the_way"
  }, "start+=0.8");

  // Texture Stretching of the front plane
  tl.to(front_plane.program.uniforms.uProgress, {
    value: 2.,
    duration: 0.9, // 2.2 - 1.3
    ease: CustomEase.create("custom", "M0,0 C0.109,0.196 0.537,0.781 1,1 "),
    id: "front_plane_texture_stretch"
  }, "start+=0.93");

  // scaling down a little more
  tl.to(front_plane.scale, {
    y: 0.37,
    x: 0.35,
    duration: 0.4, // 1.5 - 1.3
    ease: CustomEase.create("custom", "M0,0 C0.109,0.196 0.537,0.781 1,1 "),
    id: "front_plane_scale_down_more"
  }, "start+=0.9");

  // // Unblur Timeline
  tl.to(back_plane.program.uniforms.unblur_p, {
    value: 1,
    duration: 0.5,
    ease: "none",
    id: "back_plane_unblur"
  }, "start+=2.5");
  //

  // Notch Timeline
  tl.to(notch.scale, {
    x: 0.19,
    y: 0.055,
    ease: CustomEase.create("custom", "M0,0 C0,0.096 0.249,0.699 0.5,0.7 0.749,0.7 1,0.097 1,0 "),
    duration: 1.1,// 2.3 - 1.5 + 0.3
    id: "notch_scaling_timeline",
  }, "start+=1.3");



  let diff = 0.25
  tl.to(back_plane.program.uniforms.p3, {
    value: 1,
    duration: 0.9,
    ease: 'Power2.easeInOut',
    id: "back_plane_scaling_up_texture"
  }, `start+=${1.1 - diff}`);

  tl.to(back_plane.program.uniforms.p3, {
    value: 0,
    duration: 1.6,
    ease: 'io',
    id: "back_plane_scaling_down_texture"
  }, `start+=${2 - diff}`);

  tl.to(back_plane.program.uniforms.p4, {
    value: 1.,
    duration: 1.7,
    ease: 'none',
    id: "back_plane_glow_timeline"
  }, `start+=${1.3 - diff}`);

  tl.to(back_plane.program.uniforms.p2, {
    value: 2.,
    duration: 10,
    ease: CustomEase.create("io1", "M0,0 C0.303,0 0.031,1.076 1,1 "),
    // ease: CustomEase.create("io2", "M0,0 C0.285,0.083 0.031,1.076 1,1 "),
    id: "back_plane_wave_timeline"
  }, `start+=${0.36 - diff}`)


  GSDevTools.create({ animation: tl })

  return tl
}

