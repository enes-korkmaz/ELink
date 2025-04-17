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

/**
 * @param {HTMLElement} th
 * @param {((string)=>number)|undefined} transformValue
 */
function orderBy(th, transformValue) {
  const parent = th.parentElement;
  if (!parent) return;

  let i = 0;
  for (i = 0; i < parent.children.length; i++) {
    const el = parent.children.item(i);
    if (el === th) {
      break;
    }
    el.dataset.sortMode = 0;
  }
  for (j = i + 1; j < parent.children.length; j++) {
    parent.children.item(j).dataset.sortMode = 0;
  }

  const tableEl = upTo(th, "TABLE");
  if (!tableEl) return;

  const tbodyEl = tableEl.getElementsByTagName("tbody").item(0);
  if (!tbodyEl) return;

  const rows = tbodyEl.getElementsByTagName("tr");
  const rowArr = Array.from(rows);

  th.dataset.sortMode ??= "0";
  let mode = Number(th.dataset.sortMode);
  switch (mode) {
    case 0:
      mode = 1;
      th.dataset.sortMode = "1";
      break;
    case 1:
      mode = -1;
      th.dataset.sortMode = "-1";
      break;
    case -1:
      // reset to default
      mode = 1;
      i = 0;
      th.dataset.sortMode = "0";
      transformValue = Number.parseInt;
      break;
    default:
      mode = 1;
      break;
  }

  rowArr.sort(getSortValue(transformValue, i, mode));

  for (const el of rowArr) {
    tbodyEl.appendChild(el);
  }
}

/**
 * @param {HTMLElement} self
 * @param {string} tag
 * @returns {HTMLElement|null}
 */
function upTo(self, tag) {
  let el = self;
  while (el) {
    if (el.tagName === tag) {
      return el;
    }
    el = el.parentElement;
  }
  return null;
}

/**
 * @param {((string)=>number)|undefined} transformValue
 * @param {number} i
 * @param {-1|1} mode
 * @returns {(a: HTMLTableRowElement, b: HTMLTableRowElement) => number}
 */
function getSortValue(transformValue, i, mode) {
  transformValue ??= (x) => x;
  return (a, b) => {
    const aEl = a.children.item(i);
    const bEl = b.children.item(i);
    const aVal = transformValue(
      (aEl?.innerText ?? aEl?.innerHTML ?? "").trim(),
    );
    const bVal = transformValue(
      (bEl?.innerText ?? bEl?.innerHTML ?? "").trim(),
    );
    if (aVal > bVal) return mode;
    if (bVal > aVal) return -1 * mode;
    return 0;
  };
}
