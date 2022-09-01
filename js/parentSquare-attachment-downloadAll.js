// ==UserScript==
// @name         New Userscript
// @namespace    http://tampermonkey.net/
// @version      0.1
// @description  download all attachments from ParentSquare, if the 'download all' button is not there, it will create a 'download all' button for you.
//               this script could be used in tampermonkey, or just run this script in the browser console.
// @author       metasong
// @match        https://www.parentsquare.com/feeds/*
// @icon         https://www.google.com/s2/favicons?domain=parentsquare.com
// @grant        none
// ==/UserScript==

(function () {
  var all = document.body.querySelector('a[aria-label="Download All"]')
  if(all) {
    var msg = 'there already is a "Download All" button, please use it!'
    console.log(msg)
    alert(msg)
    return
  }

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
    Download All🪂`;
    return d;
  }

  function downloadAllPic() {
    let a = document.body.querySelector(".attachments");
    let b = a.querySelectorAll("a:not(.thumbnail)");
    b.forEach((l) => l.click());
  }

  let butt = createButton(
    'download with this link if no "Download All" button',
    downloadAllPic
  );
  let nav = document.body.querySelector(".nav-stacked");
  nav.appendChild(butt);
  // Your code here...
})();
