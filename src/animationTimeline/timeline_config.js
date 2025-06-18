import gsap from "gsap"
import { CustomEase } from 'gsap/CustomEase'

gsap.registerPlugin(CustomEase)


CustomEase.create('io', '.8,0.2,.10,1');
export default function getConfig() {
  return {

    // All the animation are started from the start , and have been spaced using a delay like "start+=0.5" means there is 0.5 sec delay in the start of that particular sequence from the moment the entire transition has started

    // Front Plane Scale down
    front_scale_first_duration: 1.3,
    front_scale_first_ease: "power1.inOut",
    front_scale_first_timeline: "start",

    // Going a little up 
    front_position_one_duration: 1.1,
    front_position_one_ease: "power2.in",
    front_position_one_timeline: `start+=0`,

    //going a little down for a bounce effect
    front_position_two_duration: 0.2,
    front_position_two_ease: "power2.in",
    front_position_two_timeline: `start+=1.1`,

    //going out of view (up)
    front_position_three_duration: 2.5 - 1.5,
    front_position_three_ease: CustomEase.create("custom", "M0,0 C0.076,0 0.317,0.031 0.5,0.2 0.774,0.452 1,0.889 1,1 "),
    front_position_three_timeline: `start+=1.1`,

    // Texture Stretch of the front plane
    front_progress_duration: 2.2 - 1.3,
    front_progress_ease: CustomEase.create("custom", "M0,0 C0.109,0.196 0.537,0.781 1,1 "),
    front_progress_timeline: `start+=1.3`,

    // scaling down
    front_scale_second_duration: 1.5 - 1.3,
    front_scale_second_ease: CustomEase.create("custom", "M0,0 C0.109,0.196 0.537,0.781 1,1 "),
    front_scale_second_timeline: `start+=1.3`,




    //glow wave
    // back_glow_wave_ease: CustomEase.create("custom", "M0,0 C0.06,0.271 0.635,0.076 0.824,0.282 0.962,0.432 0.925,0.717 1,1 "),
    // back_glow_wave_duration: 3.0, // front_scale_first_duration
    // back_glow_wave_timeline: `start+=0`,
    back_glow_wave_ease: CustomEase.create("custom", "M0,0 C0.06,0.271 0.635,0.076 0.824,0.282 0.962,0.432 0.925,0.717 1,1 "),
    back_glow_wave_duration: 3.0, // front_scale_first_duration
    back_glow_wave_timeline: `start+=0`,

    // glow Radius
    glow_radius_ease: CustomEase.create("custom", "M0,0 C0,0.082 0.156,1 0.322,1 0.409,1 0.568,1.068 0.66,0.911 0.745,0.764 0.67,0.116 0.866,0.116 0.999,0.116 0.951,0.1 1,0.1 "),
    glow_radius_duration: 3.0,
    glow_radius_timeline: "start+=0",


    // unblur
    back_unblur_duration: 1,
    back_unblur_ease: "none",
    back_unblur_timeline: `start+=${2.0}`,


    // Shock wave configuration
    back_plane_ripple_wave_duration: 3.5,
    // back_plane_ripple_wave_ease: CustomEase.create("custom", "M0,0 C0.015,0.3 0,0.44 0.16,0.585 0.344,0.749 0.818,1.001 1,1 "),
    back_plane_ripple_wave_ease: "io",
    back_plane_ripple_wave_timeline: "start+=1.",


    // Texture Stretch of background plane
    back_wave_progress_stretch_ease: CustomEase.create("custom", "M0,0 C0.03,0.094 0.117,0.422 0.246,0.67 0.351,0.873 0.493,1.014 0.578,1 0.681,0.981 0.669,0.163 0.73,-0.054 0.767,-0.188 0.756,-0.107 0.813,-0.032 0.871,0.042 0.972,0 1,0 "),
    back_wave_stretch_timeline: "start+=1.3",
    back_wave_stretch_duration: 1.2,

    // notch animation
    notch_scale_duration: 2.3 - 1.5 + 0.3,
    notch_scale_ease: CustomEase.create("custom", "M0,0 C0,0.096 0.249,0.699 0.5,0.7 0.749,0.7 1,0.097 1,0 "),
    notch_scale_timeline: `start+=1.35`,
  };


}

