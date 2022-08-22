// ==UserScript==
// @name         New Userscript
// @namespace    http://tampermonkey.net/
// @version      0.1
// @description  download all attachement from ParentSquare, if the 'download all' button is not there, run this script.
// @author       metasong
// @match        https://www.parentsquare.com/feeds/*
// @icon         https://www.google.com/s2/favicons?domain=parentsquare.com
// @grant        none
// ==/UserScript==

(function () {
  console.log('click "download all" to download...');
  ("use strict");
  function createButton(title, action) {
    var d = document.createElement("a");
    //d.classList.add('add-list-item')
    d.title = title;
    d.setAttribute("role", "button");
    d.addEventListener("click", action, false);
    // d.textContent = '🪂 Download All'
    d.innerHTML = `<i class="fa fa-download fa-fw color-highlight"></i> 
    Download All`;
    return d;
  }

  function downloadAllPic() {
    let a = document.body.querySelector(".attachments");
    let b = a.querySelectorAll("a:not(.thumbnail)");
    b.forEach((l) => l.click());
  }

  let butt = createButton(
    'download with this link if no "Download All"',
    downloadAllPic
  );
  let nav = document.body.querySelector(".nav-stacked");
  nav.appendChild(butt);
  // Your code here...
})();
