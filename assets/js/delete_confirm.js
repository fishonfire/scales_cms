// Attribute which we use to re-trigger the click event
const CONFIRM_ATTRIBUTE = "data-confirm-fired"

// our dialog from the `root.html.heex`
const DANGER_DIALOG = document.getElementById("danger_dialog");

const execAttr = (el, attrName) => {
  const attr = el.getAttribute(attrName);
  attr && liveSocket.execJS(el, attr);
}

window.addEventListener("ultra-confirm", (event) => {
  const { detail } = event
  const { message } = detail;

  const targetButton = event.target
  const srcElement = event.srcElement
  event.preventDefault()
  targetButton.setAttribute(CONFIRM_ATTRIBUTE, "")

  DANGER_DIALOG.returnValue = "cancel";
  DANGER_DIALOG.querySelector("[data-ref='title']").innerText = message;
  DANGER_DIALOG.showModal();

  DANGER_DIALOG.addEventListener('close', ({ target }) => {
    if (target.returnValue === "confirm") {
      execAttr(srcElement, "phx-ultra-confirm-ok");
    } else {
      execAttr(srcElement, "phx-ultra-confirm-cancel");
      targetButton.removeAttribute(CONFIRM_ATTRIBUTE);
    }
  })
})
