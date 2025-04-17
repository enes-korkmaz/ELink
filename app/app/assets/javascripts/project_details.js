/*
 * Copyright (C) 2025 Frank Mayer, Enes Korkmaz, Jascha Sonntag, Andreas Rothaler, Eray Akyazililar, Jan Magister
 *
 * This file is part of Elink.
 *
 * Elink is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License as published
 * by the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * Elink is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License
 * along with Elink. If not, see <http://www.gnu.org/licenses/>.
 */

document.addEventListener("DOMContentLoaded", () => {
  // Attach listeners for Add and Edit buttons
  document.body.addEventListener("click", addBtnClickListener);
  document.body.addEventListener("click", editBtnClickListener);

  if (!window.originalContentMap) {
    window.originalContentMap = new Map();
  }

  // Check if the listener is already attached using a data attribute for Add button
  const body = document.body;
  if (body.dataset.addBtnListenerAttached === "true") {
    return; // If the listener is already attached, do nothing
  }

  console.log("Attaching Add button listener");

  // Attach the listener if not already attached
  document.body.addEventListener("click", addBtnClickListener);

  // Mark the listener as attached using a data attribute
  body.dataset.addBtnListenerAttached = "true";

  // Event delegation for form submission dynamically using AJAX
  document.body.addEventListener("submit", function (event) {
    if (
      event.target.closest("form") &&
      event.target.closest("form").getAttribute("data-remote") === "true"
    ) {
      event.preventDefault();
      const form = event.target.closest("form");

      // Find the closest container of the form
      let container = form.closest(".inner-container");
      if (!container) {
        console.error("No .inner-container found for this form.");
        return;
      }

      fetch(form.action, {
        method: "POST",
        body: new FormData(form),
        headers: { "X-Requested-With": "XMLHttpRequest" },
      })
        .then((response) => {
          if (!response.ok && response.status === 422) {
            return response.text().then((html) => {
              container.innerHTML = html; // Replace only the content inside the container
              document.dispatchEvent(new Event("formReplaced")); // Optional for reapplying logic
            });
          }
          return response.json();
        })
        .then((data) => {
          if (data && data.status === "success") {
            window.location.href = data.redirect_url;
          }
        })
        .catch((error) => {
          console.error("Error saving:", error);
        });
    }
  });
});

// Function for handling the "Add" button click
function addBtnClickListener(event) {
  if (event.target.matches(".add-btn")) {
    const container = event.target.closest(".add-container");
    const formTemplate = container.dataset.formTemplate;
    const projectId = container.dataset.projectId;

    if (container.id === "add-container-experts") {
      window.location.href = `/experts?mode=add_to_project&project_id=${projectId}`;
    } else {
      fetch(formTemplate, {
        headers: { "X-Requested-With": "XMLHttpRequest" },
      })
        .then((response) => response.text())
        .then((html) => {
          container.innerHTML = html;
        })
        .catch((error) => console.error("Error loading form:", error));
    }
  }
}

// Function for handling the "Edit" button click
function editBtnClickListener(event) {
  if (event.target.matches(".edit-btn, .edit-btn *")) {
    const button = event.target.closest(".edit-btn");
    const itemId = button.dataset.id;
    const editUrl = button.dataset.url;
    const itemType = button.dataset.type; // Get the item type (e.g., 'partner', 'transport', etc.)

    // Get the container for the clicked edit button, using the dynamic item type
    const container = document.getElementById(`${itemType}-item-${itemId}`);
    if (!container) {
      console.error(
        `Container with ID "${itemType}-item-${itemId}" not found.`,
      );
      return;
    }

    // Reset any other container in edit mode
    for (const [key, value] of window.originalContentMap) {
      if (key !== `${itemType}-item-${itemId}`) {
        const originalContainer = document.getElementById(key);
        if (originalContainer && value) {
          originalContainer.innerHTML = value;
          window.originalContentMap.delete(key); // Clean up
        }
      }
    }

    // Save the original content of the container
    if (!window.originalContentMap.has(`${itemType}-item-${itemId}`)) {
      window.originalContentMap.set(
        `${itemType}-item-${itemId}`,
        container.innerHTML,
      );
    }

    // Load the edit form via AJAX
    fetch(editUrl, {
      headers: { "X-Requested-With": "XMLHttpRequest" },
    })
      .then((response) => response.text())
      .then((html) => {
        container.innerHTML = html;
      })
      .catch((error) => console.error("Error loading edit form:", error));
  }
}

function deleteItem(confirmationMessage, itemId, deleteUrl) {
  if (confirm(confirmationMessage)) {
    if (!deleteUrl) {
      console.error("Delete URL is missing");
      return;
    }

    fetch(deleteUrl, {
      method: "DELETE",
      headers: {
        "X-Requested-With": "XMLHttpRequest",
        "X-CSRF-Token": getCsrfToken(),
      },
    })
      .then((response) => {
        if (!response.ok) {
          console.error("Failed to delete:", response.statusText);
          throw new Error("Failed to delete");
        }
        return response.json();
      })
      .then((data) => {
        if (data.status === "success") {
          window.location.href = data.redirect_url;
        } else {
          alert("Failed to delete the item.");
        }
      })
      .catch((error) => {
        console.error("Error:", error);
        alert("An error occurred. Please try again.");
      });
  }
}

function unassignExpert(expertId, confirmationMessage) {
  if (confirm(confirmationMessage)) {
    const button = document.querySelector(`button[data-id="${expertId}"]`);
    const projectId = button.dataset.projectId;

    fetch(`/projects/${projectId}/unassign_expert/${expertId}`, {
      method: "DELETE",
      headers: {
        "X-Requested-With": "XMLHttpRequest",
        "X-CSRF-Token": getCsrfToken(),
      },
    })
      .then((response) => response.json())
      .then((data) => {
        if (data.status === "success") {
          window.location.reload();
        } else {
          alert("Failed to unassign the expert.");
        }
      })
      .catch((error) => {
        console.error("Error unassigning expert:", error);
        alert("An error occurred while unassigning the expert.");
      });
  }
}

function getCsrfToken() {
  return document.querySelector('meta[name="csrf-token"]').content;
}

// Function to reset the container back to the "Add" button after cancellation or successful save
function cancelForm(containerId, actionType) {
  const container = document.getElementById(containerId);
  if (!container) {
    console.error(`Container with ID "${containerId}" not found.`);
    return;
  }

  if (actionType === "add") {
    container.innerHTML = `
            <button class="btn add-btn">
                Add Partner
            </button>
        `;
  } else if (actionType === "edit") {
    if (window.originalContentMap.has(containerId)) {
      container.innerHTML = window.originalContentMap.get(containerId); // Restore original content
      window.originalContentMap.delete(containerId); // Clean up
    }
  }
}
