import "./style.css"
import html2canvas from "html2canvas-pro";
import GUI from "lil-gui";
import Scene from "./Experience/Scene";


// const gui = ""

const gui = new GUI({
  width: 400
})

function run() {

  const container = Array.from(document.querySelectorAll(".container"))

  for (let i = 0; i < container.length; i++) {
    html2canvas(container[i].querySelector(".card"), {
      scale: 5,
      useCORS: true,
      logging: false,
      imageTimeout: 30000,
      backgroundColor: null,
      ignoreElements: (element) => {
        return element.classList.contains('do-not-capture');
      },
      onclone: (clonedDoc) => {
        const timestamp = clonedDoc.getElementById('timestamp');
        if (timestamp) {
          timestamp.textContent = new Date().toLocaleString();
        }
      }
    }).then(canvas => {
      const imageDataURL = canvas.toDataURL('image/jpeg');

      const imgElement = new Image();


      imgElement.src = imageDataURL;

      imgElement.onload = () => {


        // Creating a new scene for every container element , in our case it was only one
        const scene = new Scene(container[i].querySelector(".canvas_container"), imgElement.src, gui)

        const reset_btn = container[i].querySelector(".reset_anim_btn")

        reset_btn.addEventListener("click", (e) => {
          scene.onTouchDown()
        })

        // Removing the actual html element from the DOM
        container[i].querySelector(".card").remove()

      }
    }).catch(error => {
      console.error("Error capturing the card:", error);
    });
  }
}

run()
