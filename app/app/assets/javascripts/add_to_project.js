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

function replaceCreateWithAddButton() {
  const createButton = document.querySelector(".sidebar .create-btn");
  const addButton = document.querySelector(".sidebar .add-btn");

  if (createButton) {
    createButton.classList.add("hidden");
  }

  if (addButton) {
    addButton.classList.remove("hidden");
    addButton.addEventListener("click", addExpertsToProject);
  }
}

function toggleSelectMode(enabled) {
  const tableRows = document.querySelectorAll("#experts_table tbody tr");
  const checkboxes = document.querySelectorAll(".expert-checkbox");
  const addButton = document.querySelector(".add-btn");

  const checkboxColumn = document.querySelector(
    "#experts_table thead th:first-child",
  );
  checkboxColumn.classList.toggle("hidden", !enabled);

  checkboxes.forEach((checkbox) => {
    checkbox.parentElement.classList.toggle("hidden", !enabled);
  });

  if (addButton) {
    addButton.classList.toggle("hidden", !enabled);
  }

  tableRows.forEach((row) => {
    if (enabled) {
      row.classList.remove("cursor-pointer");
      row.onclick = null;
    } else {
      row.classList.add("cursor-pointer");
      row.onclick = function () {
        window.location = row.dataset.expertId;
      };
    }
  });
}

function enableExpertSelection() {
  const headerRow = document.querySelector("#experts_table thead tr");
  const checkboxHeader = document.createElement("th");
  checkboxHeader.classList.add("checkbox-header");
  checkboxHeader.textContent = "";
  headerRow.insertBefore(checkboxHeader, headerRow.firstChild);

  const rows = document.querySelectorAll("#experts_table tbody tr");
  rows.forEach((row) => {
    const checkboxCell = document.createElement("td");
    const checkbox = document.createElement("input");
    checkbox.type = "checkbox";
    checkbox.classList.add("expert-checkbox");
    checkboxCell.appendChild(checkbox);
    row.insertBefore(checkboxCell, row.firstChild);
  });

  toggleSelectMode(true);
  replaceCreateWithAddButton();
}

function addExpertsToProject() {
  const selectedExperts = [];
  const checkboxes = document.querySelectorAll(".expert-checkbox:checked");
  const urlParams = new URLSearchParams(window.location.search);
  const projectId = urlParams.get("project_id");

  checkboxes.forEach((checkbox) => {
    const expertId = checkbox.closest("tr").dataset.expertId;
    selectedExperts.push(expertId);
  });

  const csrfToken = document
    .querySelector("meta[name='csrf-token']")
    .getAttribute("content");

  fetch(`/projects/${projectId}/add_experts`, {
    method: "POST",
    body: JSON.stringify({ expert_ids: selectedExperts }),
    headers: {
      "Content-Type": "application/json",
      "X-CSRF-Token": csrfToken,
    },
  })
    .then((response) => {
      if (!response.ok) {
        return response.text().then((text) => {
          throw new Error(text);
        });
      }
      return response.json();
    })
    .then((data) => {
      if (data.success) {
        if (data.already_assigned && data.already_assigned.length > 0) {
          const names = data.already_assigned.join(", ");
          alert(`The following experts were already assigned: ${names}`);
        }
        window.location.href = `/projects/${projectId}?tab=expert`;
      } else {
        alert("Failed to add experts.");
      }
    })
    .catch((error) => {
      console.error("Error adding experts:", error);
      alert("Expert already assigned to this project!");
    });
}

// Check if the current page is in "add to project" mode
const urlParams = new URLSearchParams(window.location.search);
const isAddToProjectMode = urlParams.get("mode") === "add_to_project";

if (isAddToProjectMode) {
  enableExpertSelection();
}
