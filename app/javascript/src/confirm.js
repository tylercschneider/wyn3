// Custom TailwindCSS modals for confirm dialogs
//
// Example usage:
//
//   <%= button_to "Delete", my_path, method: :delete, form: {
//     data: {
//       turbo_confirm: "Are you sure?",
//       turbo_confirm_description: "This will delete your record. Enter the record name to confirm.",
//       turbo_confirm_text: "record name", # require the user to type this before confirming
//       turbo_confirm_accept: "Yes, delete it",
//       turbo_confirm_reject: "No, keep it"
//     }
//   } %>

function insertConfirmModal(message, element, button) {
  let confirmInput = ""

  // button is nil if using link_to with data-turbo-confirm
  let confirmText = button?.dataset?.turboConfirmText || element.dataset.turboConfirmText
  let description = button?.dataset?.turboConfirmDescription || element.dataset.turboConfirmDescription || ""
  let accept = button?.dataset?.turboConfirmAccept || element.dataset.turboConfirmAccept || "Confirm"
  let reject = button?.dataset?.turboConfirmReject || element.dataset.turboConfirmReject || "Cancel"

  if (confirmText) {
    confirmInput = `<input type="text" class="mt-4 form-control" data-behavior="confirm-text" />`
  }
  let id = `confirm-modal-${new Date().getTime()}`

  let content = `
    <dialog id="${id}" class="modal rounded-lg max-w-md w-full backdrop:backdrop-blur-xs backdrop:bg-black/50">
      <form method="dialog">
        <div class="bg-white mx-auto rounded-sm shadow-sm p-6 max-w-md dark:bg-gray-900">
          <h5 class="text-lg">${message}</h5>
          <p class="mt-2 text-sm text-gray-700 dark:text-gray-200">${description}</p>

          ${confirmInput}

          <div class="flex justify-end items-center flex-wrap gap-2 mt-4">
            <button value="cancel" class="btn btn-secondary">${reject}</button>
            <button value="confirm" class="btn btn-danger">${accept}</button>
          </div>
        </div>
      </form>
    </dialog>
  `

  document.body.insertAdjacentHTML('beforeend', content)
  let modal = document.getElementById(id)

  // Focus on the first button in the modal after rendering
  modal.querySelector("button").focus()

  // Disable commit button until the value matches confirmText
  if (confirmText) {
    let commitButton = modal.querySelector("[value='confirm']")
    commitButton.disabled = true
    modal.querySelector("input[data-behavior='confirm-text']").addEventListener("input", (event) => {
      commitButton.disabled = (event.target.value != confirmText)
    })
  }

  return modal
}

Turbo.config.forms.confirm = (message, element, button) => {
  let dialog = insertConfirmModal(message, element, button)
  dialog.showModal()

  return new Promise((resolve, reject) => {
    dialog.addEventListener("close", () => {
      resolve(dialog.returnValue == "confirm")
    }, { once: true })
  })
}
