// Attribute which we use to re-trigger the click event
const CONFIRM_ATTRIBUTE = "data-confirm-fired"

// our dialog from the `root.html.heex`
const DANGER_DIALOG = document.getElementById("danger_dialog");

const execAttr = (el, attrName) => {
  const attr = el.getAttribute(attrName);
  attr && liveSocket.execJS(el, attr);
}

window.addEventListener("ultra-confirm", (event) => {
  const { detail, srcElement } = event
  const { message } = detail;

  const targetButton = event.target

  // We do this since `window.confirm` prevents all execution by default.
  // To recreate this behaviour we `preventDefault`
  // Then add an attribute which will allow us to re-trigger the click event while skipping the dialog
  event.preventDefault()
  targetButton.setAttribute(CONFIRM_ATTRIBUTE, "")


  DANGER_DIALOG.returnValue = "cancel";
  DANGER_DIALOG.querySelector("[data-ref='title']").innerText = message;

  // <dialog> is a very cool element and provides a lot of cool things out of the box, like showing the modal in the #top-layer
  DANGER_DIALOG.showModal();

  // Re-triggering logic
  DANGER_DIALOG.addEventListener('close', ({ target }) => {
    if (target.returnValue === "confirm") {
      execAttr(srcElement, "phx-ultra-confirm-ok");
    } else {
      execAttr(srcElement, "phx-ultra-confirm-cancel");
      targetButton.removeAttribute(CONFIRM_ATTRIBUTE);
    }
  })
})
