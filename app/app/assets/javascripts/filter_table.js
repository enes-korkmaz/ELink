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

const filterDatas = new Array();

function initFilterTable() {
  const tableFilters = document.getElementsByClassName("filter_table");
  for (let i = 0; i < tableFilters.length; i++) {
    const tableFilter = tableFilters.item(i);
    tableFilter.innerHTML = "";
    const tableId = tableFilter.dataset.for;
    const tableEl = document.getElementById(tableId);
    if (!tableEl) {
      continue;
    }

    const ths = tableEl.querySelectorAll("thead tr th");
    const filterData = new Array(ths.length);
    for (let j = 0; j < ths.length; j++) {
      const th = ths.item(j);
      const filterType = th.dataset.filterType || "string";
      const thText = th.innerText.trim();
      if (thText === "" || thText === "#") {
        continue;
      }

      const labelEl = document.createElement("label");
      labelEl.style.display = "block";
      labelEl.style.marginTop = "1rem";
      labelEl.innerText = th.innerText;

      const inputEl = document.createElement("input");
      if (filterType === "number") {
        inputEl.type = "number";
      }
      inputEl.style.display = "block";
      inputEl.style.border = "1px solid #D1D5DB";
      inputEl.style.borderRadius = "0.375rem";
      inputEl.style.padding = "0.5rem";
      inputEl.style.width = "100%";
      inputEl.style.outline = "none";
      labelEl.appendChild(inputEl);
      inputEl.addEventListener("input", () => {
        switch (filterType) {
          case "number":
            filterData[j] = Number.parseFloat(inputEl.value);
            break;
          case "string":
            filterData[j] = RegExp(
              escapeRegex(inputEl.value).replace(/\s+/g, ".*"),
              "i",
            );
            break;
          default:
            alert(`invalid filter type ${filterType}`);
            break;
        }
        applyFilter(filterData, tableEl);
      });

      tableFilter.append(labelEl);
    }
    filterDatas.push(filterData);
  }
}

function applyFilter(filterData, tableEl) {
  const rows = tableEl.querySelectorAll("tbody tr");
  for (let r = 0; r < rows.length; r++) {
    const rowEl = rows.item(r);
    const cols = rowEl.querySelectorAll("td");
    let showRow = true;
    cols_loop: for (let c = 0; c < cols.length; c++) {
      const colFilterData = filterData[c];
      if (!colFilterData) continue; // undefined at start (no input)
      colEl = cols.item(c);

      switch (typeof colFilterData) {
        case "object": // RegExp => type object
          // Filter innerHTML: innerText is "" if visible = "collapse"
          if (!colFilterData.test(colEl.innerHTML.replace(/\s+/g, " "))) {
            showRow = false;
            break cols_loop;
          }
          break;
        case "number":
          if (
            !Number.isNaN(colFilterData) && // filter is empty string
            colFilterData != Number.parseFloat(colEl.innerHTML)
          ) {
            showRow = false;
            break cols_loop;
          }
          break;
      }
    }
    rowEl.style.visibility = showRow ? "visible" : "collapse";
  }
}

function escapeRegex(s) {
  return s.replace(/[.*+?^${}()|[\]\\]/g, "\\$&");
}

initFilterTable();
